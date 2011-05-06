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


IFDEF ModuleNames
DB 'CONV',0
ENDIF

; Convert a byte in AL to it's Hex Ascii value.
; In:          AL - value to convert
; Out:         AX - two (Hex) Ascii digits
; Destroyed:   none
CONV_BinToAsc  Proc  Near
      mov      ah,al                      ; Save value to process high nibble later
      and      al,0fh                     ; Mask low nibble
      add      al,'0'                     ; Convert to ASCII
      cmp      al,'9'                     ; Is it in the range of '0' - '9' ?
      jbe      CONV_BinToAsc_DecDigit_1   ; Yep, done
      add      al,7                       ; Nope, adjust to Hex Ascii
   CONV_BinToAsc_DecDigit_1:
      xchg     al,ah                      ; Exchange with saved value to process high nibble
      shr      al,4                         ; Move high nibble to low nibble (80186+)
      ;shr      al
      ;shr      al
      ;shr      al
      add      al,'0'                     ; Convert to ASCII
      cmp      al,'9'                     ; Is it in the range of '0' - '9' ?
      jbe      CONV_BinToAsc_DecDigit_2
      add      al,7                       ; Nope, adjust to Hex Ascii
   CONV_BinToAsc_DecDigit_2:
      xchg     al,ah                      ; Correct order, AX now contains the two (hex) digits
      ret
CONV_BinToAsc  Endp



; See if a character is printable.
; Replace with a '.' if not.
; In:          AL - char to print
;              AH - char to print if AL is non-printable
; Out:         AL - char printed (could be dot)
; Destroyed:   none
CONV_ConvertToPrintable    Proc  Near
      cmp      al,20h
      jb       CONV_ConvertToPrintable_NP       ; Below space, so not printable
      cmp      al,7eh                           ; Above tilde, so not printable
      ja       CONV_ConvertToPrintable_NP
      jmp      CONV_ConvertToPrintable_End   ; Go output it
   CONV_ConvertToPrintable_NP:
      mov      al,ah                            ; Use the replacement character
   CONV_ConvertToPrintable_End:
      ret
CONV_ConvertToPrintable    EndP



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
CONV_CHS2LBA   Proc  Near
      local    req_cyl:dword
      local    req_head:word
      local    req_sec:word
      local    lba:qword

      ; Save parameters
      mov      word ptr [req_cyl],ax      ; save low cyl
      mov      word ptr [req_cyl+2],dx    ; save high cyl
      mov      [req_head],bx              ; save head
      test     cx,cx
      jnz      CONV_CHS2LBA_sec_ok
      mov      cx,1                       ; cannot have sector 0, so change to 1
   CONV_CHS2LBA_sec_ok:
      dec      cx                         ; prepare for calculation later
      mov      [req_sec],cx               ; save sec

      ; Clear return value
      xor      ax,ax
      mov      word ptr [lba+6],ax
      mov      word ptr [lba+4],ax
      mov      word ptr [lba+2],ax
      mov      word ptr [lba+0],ax

      ; Cyls * Heads
      mov      dx,word ptr [req_cyl+2]    ; high word of requested cylinder
      mov      ax,word ptr [req_cyl+0]    ; low word of requested cylinder
      xor      bx,bx                      ; zero for 32-bit math
      mov      cx,word ptr [BIOS_Heads]   ; number of heads
      call     MATH_Mul32

      ; WE DISCARD HIGH 32-BITS HERE BECAUSE CALCULATION
      ; WOULD REQUIRE 64-bits MATH.
      ; THIS WILL BE FIXED LATER.
      ; THIS MEANS LBA >2TiB IS NOT SUPPORTED YET.

      ; Add requested head
      add      ax,[req_head]
      adc      dx,0
      ;adc      cx,0
      ;adc      bx,0

      ; * Secs
      xor      bx,bx
      mov      cx,word ptr [TrueSecs]
      call     MATH_Mul32

      ; Add requested sec
      add      ax,[req_sec]
      adc      dx,0
      ;adc      cx,0
      ;adc      bx,0

      xor      bx,bx
      xor      cx,cx

      ; Set ZF if high upper 32-bits are zero
      or       bx,cx

      ret
CONV_CHS2LBA   EndP


CONV_LBA2CYLS  Proc  Near


      ret
CONV_LBA2CYLS  Endp

; Convert a character to upper-case
CONV_ToUpper   Proc  Near
      cmp      al,'a'
      jb       CONV_ToUpperSkip1
      cmp      al,'z'
      ja       CONV_ToUpperSkip1
      sub      al,20h
   CONV_ToUpperSkip1:
      ret
CONV_ToUpper   EndP
