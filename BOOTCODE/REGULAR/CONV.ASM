; AiR-BOOT (c) Copyright 1998-2008 M. Kiewitz
;
; This file is part of AiR-BOOT
;
; AiR-BOOT is free software: you can redistribute it and/or modify it under
;  the terms of the GNU General Public License as published by the Free
;  Software Foundation, either version 3 of the License, or (at your option)
;  any later version.
;
; AiR-BOOT is distributed in the hope that it will be useful, but WITHOUT ANY
;  WARRANTY: without even the implied warranty of MERCHANTABILITY or FITNESS
;  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
;  details.
;
; You should have received a copy of the GNU General Public License along with
;  AiR-BOOT. If not, see <http://www.gnu.org/licenses/>.
;
;---------------------------------------------------------------------------
;                                                    AiR-BOOT / CONVERSION
;---------------------------------------------------------------------------


; ----------------------
; Rousseau: # CONV.ASM #
; ----------------------
; This module contains various conversion routines.
; Some have to do with bin to ascii, others with translation.


IFDEF   MODULE_NAMES
DB 'CONV',0
ENDIF

; Convert a byte in AL to it's Hex Ascii value.
; In:          AL - value to convert
; Out:         AX - two (Hex) Ascii digits
; Destroyed:   none
CONV_BinToAsc   Proc  Near
        mov     ah,al                      ; Save value to process high nibble later
        and     al,0fh                     ; Mask low nibble
        add     al,'0'                     ; Convert to ASCII
        cmp     al,'9'                     ; Is it in the range of '0' - '9' ?
        jbe     CONV_BinToAsc_DecDigit_1   ; Yep, done
        add     al,7                       ; Nope, adjust to Hex Ascii
    CONV_BinToAsc_DecDigit_1:
        xchg    al,ah                      ; Exchange with saved value to process high nibble
        shr     al,4                       ; Move high nibble to low nibble (80186+)
        ;shr     al
        ;shr     al
        ;shr     al
        add     al,'0'                     ; Convert to ASCII
        cmp     al,'9'                     ; Is it in the range of '0' - '9' ?
        jbe     CONV_BinToAsc_DecDigit_2
        add     al,7                       ; Nope, adjust to Hex Ascii
    CONV_BinToAsc_DecDigit_2:
        xchg    al,ah                      ; Correct order, AX now contains the two (hex) digits
        ret
CONV_BinToAsc   Endp



; See if a character is printable.
; Replace with a '.' if not.
; In:          AL - char to print
;              AH - char to print if AL is non-printable
; Out:         AL - char printed (could be dot)
; Destroyed:   none
CONV_ConvertToPrintable     Proc  Near
        cmp     al,20h
        jb      CONV_ConvertToPrintable_NP       ; Below space, so not printable
        cmp     al,7eh                           ; Above tilde, so not printable
        ja      CONV_ConvertToPrintable_NP
        jmp     CONV_ConvertToPrintable_End   ; Go output it
    CONV_ConvertToPrintable_NP:
        mov     al,ah                            ; Use the replacement character
    CONV_ConvertToPrintable_End:
        ret
CONV_ConvertToPrintable     EndP



; Convert CHS values to LBA address
; Formula: LBA = ((c * H) + h) * S + s -1
; c,h,s: requested
; H,S: heads per cylinder and sectors per track
; In:          DX:AX - Cylinder
;              BX    - Head
;              CX    - Sector
; Out:         BX:CX:DX:AX - LBA address (64-bits)
;              ZF=1 if upper 32-bits are zero (LBA32)
; Destroyed:   none
CONV_CHS2LBA    Proc  Near
        local   req_cyl:dword
        local   req_head:word
        local   req_sec:word
        local   lba:qword

        ; Save parameters
        mov     word ptr [req_cyl],ax      ; save low cyl
        mov     word ptr [req_cyl+2],dx    ; save high cyl
        mov     [req_head],bx              ; save head
        test    cx,cx
        jnz     CONV_CHS2LBA_sec_ok
        mov     cx,1                       ; cannot have sector 0, so change to 1
    CONV_CHS2LBA_sec_ok:
        dec     cx                         ; prepare for calculation later
        mov     [req_sec],cx               ; save sec

        ; Clear return value
        xor     ax,ax
        mov     word ptr [lba+6],ax
        mov     word ptr [lba+4],ax
        mov     word ptr [lba+2],ax
        mov     word ptr [lba+0],ax

        ; Cyls * Heads
        mov     dx,word ptr [req_cyl+2]    ; high word of requested cylinder
        mov     ax,word ptr [req_cyl+0]    ; low word of requested cylinder
        xor     bx,bx                      ; zero for 32-bit math
        mov     cx,word ptr [BIOS_Heads]   ; number of heads
        call    MATH_Mul32

        ; WE DISCARD HIGH 32-BITS HERE BECAUSE CALCULATION
        ; WOULD REQUIRE 64-bits MATH.
        ; THIS WILL BE FIXED LATER.
        ; THIS MEANS LBA >2TiB IS NOT SUPPORTED YET.

        ; Add requested head
        add     ax,[req_head]
        adc     dx,0
        ;adc     cx,0
        ;adc     bx,0

        ; * Secs
        xor     bx,bx
        mov     cx,word ptr [TrueSecs]       ; Implicitly address disk 80h
        call    MATH_Mul32

        ; Add requested sec
        add     ax,[req_sec]
        adc     dx,0
        ;adc     cx,0
        ;adc     bx,0

        xor     bx,bx
        xor     cx,cx

        ; Set ZF if high upper 32-bits are zero
        or      bx,cx

      ret
CONV_CHS2LBA    EndP


CONV_LBA2CYLS   Proc  Near
        ret
CONV_LBA2CYLS   Endp


; Convert a character to upper-case
CONV_ToUpper    Proc  Near
        cmp     al,'a'
        jb      CONV_ToUpperSkip1
        cmp     al,'z'
        ja      CONV_ToUpperSkip1
        sub     al,20h
    CONV_ToUpperSkip1:
        ret
CONV_ToUpper   EndP


;
; The bitfield functions below are used to pack values into arrays.
; A buffer needs to be provided, a bitfield width and an index into the array.
; These functions are used to pack the hidden partition-table which is
; too small in the 45-partition version.
;


; IN:   DL = Index to store bitfield
;       DH = Bitfield width (1-8)
;       BX = Pointer to bitfield array
; OUT:  AL = Value of requested bitfield
;       AH = Mask value
CONV_GetBitfieldValue   Proc    Near    Uses bx cx dx
        ; Normalize bit-width in DH.
        dec     dh          ; Decrement bitfield width to mask invalid values.
        and     dh,07h      ; Only 3 bits are significant to determine width.
        mov     cl,dh       ; Save for later use to calculate mask.
        inc     dh          ; Put back to normalized value.

        ; Calculate corresponding AND-mask in CH.
        mov     ch,2        ; Were going to shift 2...
        shl     ch,cl       ; to obtain the mask corresponding...
        dec     ch          ; to the bitfield width.

        ; Calculate byte-index.
        mov     al,dl       ; Index in AL.
        inc     al          ; Increment for calculations.
        mul     dh          ; Multiply by bitfield width to get bits.
        mov     cl,8        ; Nr. of bits in a byte.
        div     cl          ; Divide to get byte index.

        ; Advance pointer to byte-index.
        add     bl,al       ; Advance pointer...
        adc     bh,0        ; to byte index.

        ; Determine if we need 1 or 2 byte access to extract the bitfield.
        mov     cl,ah       ; Get remainder in CL.
        sub     cl,dh       ; Substract bitfield width to get shift-count.
        mov     ah,0        ; Prepare upper=0 when field spans no byte bound.
                            ; Don't change to xor ah,ah or any CY will be lost.

        ; Jump if the bitfield does not span byte boundaries.
        ; (Remainder - bitfield width >= 0)
        jae     CONV_GetBitfieldValue_nospan

        ; Bit-field spans byte boundaries, so adjust shift-count
        ; and use AH to get first part of bitfield.
        add     cl,8        ; Adjust shift-count.
        mov     ah,[bx]     ; Get byte into AH instead.
        dec     bx          ; Adjust pointer to load rest of bitfield.

    CONV_GetBitfieldValue_nospan:
        mov     al,[bx]     ; Load (rest of) bitfield into AL.
        shr     ax,cl       ; Shift bitfield to the right.
        mov     ah,ch       ; Get mask in AH.
        and     al,ah       ; Mask value.
        ret
CONV_GetBitfieldValue   EndP




; IN:   AL = Value to store
;       DL = Index to store bitfield
;       DH = Bitfield width (1-8)
;       BX = Pointer to bitfield array
; OUT:  AL = Value of stored bitfield
;       AH = Mask value
CONV_SetBitfieldValue   Proc    Near    Uses bx cx dx
        ; Push value for later use.
        push    ax

        ; Normalize bit-width in DH.
        dec     dh          ; Decrement bitfield width to mask invalid values.
        and     dh,07h      ; Only 3 bits are significant to determine width.
        mov     cl,dh       ; Save for later use to calculate mask.
        inc     dh          ; Put back to normalized value.

        ; Calculate corresponding AND-mask in CH.
        mov     ch,2        ; Were going to shift 2...
        shl     ch,cl       ; to obtain the mask corresponding...
        dec     ch          ; to the bitfield width.

        ; Calculate byte-index.
        mov     al,dl       ; Index in AL.
        inc     al          ; Increment for calculations.
        mul     dh          ; Multiply by bitfield width to get bits.
        mov     cl,8        ; Nr. of bits in a byte.
        div     cl          ; Divide to get byte index.

        ; Advance pointer to byte-index.
        add     bl,al       ; Advance pointer...
        adc     bh,0        ; to byte index.

        ; Determine if we need 1 or 2 byte access to extract the bitfield.
        mov     cl,ah       ; Get remainder in CL.
        sub     cl,dh       ; Substract bitfield width to get shift-count.

        ; Restore value to poke.
        pop     ax


        ; Jump if the bitfield does not span byte boundaries.
        ; (Remainder - bitfield width >= 0)
        jae     CONV_SetBitfieldValue_nospan

        ; Bit-field spans byte boundaries, so adjust shift-count
        ; and use 16-bit access.
        add     cl,8        ; Adjust shift-count.

        ; Merge the bitfield to the array.
        push    cx          ; Save mask (CH) and shift-count (CL).
        push    ax          ; Save value to store.
        xor     ah,ah       ; Clear upper byte so we can shift in it.
        and     al,ch       ; Mask value.
        shl     ax,cl       ; Move the bitfield to the proper location.
        mov     dh,[bx]     ; Get 1st part of bitfield from array.
        dec     bx          ; Adjust pointer.
        mov     dl,[bx]     ; Get 2nd part of bitfield from array.
        push    bx          ; We need BX so save it.
        xor     bh,bh       ; Clear upper byte so we can shift in it.
        mov     bl,ch       ; Put mask in BL.
        shl     bx,cl       ; Shift mask to proper location.
        not     bx          ; Complement it to mask-out the required bitfield.
        and     dx,bx       ; Mask-out the required bitfield.
        pop     bx          ; Restore pointer.
        or      ax,dx       ; Merge the bitfields.
        mov     [bx],al     ; Store lower byte.
        inc     bx          ; Adjust pointer.
        mov     [bx],ah     ; Store upper byte.
        pop     ax          ; Restore value.
        pop     cx          ; Restore mask and shift-count.

        ; Done.
        jmp     CONV_SetBitfieldValue_end

    CONV_SetBitfieldValue_nospan:
        ; Merge the bitfield to the array.
        push    cx          ; Save mask (CH) and shift-count (CL).
        push    ax          ; Save value to store.
        and     al,ch       ; Mask value.
        shl     al,cl       ; Move the bitfield to the proper location.
        mov     dl,[bx]     ; Get byte containing bitfield.
        shl     ch,cl       ; Shift mask to proper location.
        not     ch          ; Complement it to mask-out the required bitfield.
        and     dl,ch       ; Mask-out the required bitfield.
        or      al,dl       ; Merge the bitfields.
        mov     [bx],al     ; Store byte containing bitfield.
        pop     ax          ; Restore value.
        pop     cx          ; Restore mask and shift-count.

    CONV_SetBitfieldValue_end:
        mov     ah,ch       ; Get mask in AH.
        and     al,ah       ; Mask value.
        ret
CONV_SetBitfieldValue   EndP

