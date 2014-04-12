; AiR-BOOT (c) Copyright 1998-2009 M. Kiewitz
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

; This program fixes air-boot.com image.
;  a) it includes MBR protection image from mbr-prot\mbr_prot.com
;  b) it writes totally used sectors to byte at offset 10h in the image

;JUMPS

Include ../../INCLUDE/ASM.INC

		.286p
                .model small, basic

fixcode         group code_seg,bss_data

code_seg        segment  use16 public 'CODE'
                ;assume  cs:code_seg, ds:code_seg, es:nothing, ss:nothing
                assume  cs:fixcode, ds:fixcode, es:nothing, ss:nothing
                org     100h
COM_StartUp:    jmp     COM_Init

COM_Copyright   db 'AiR-BOOT Bootcode Image Fix', 13, 10
                db ' - (c) Copyright 2009 by M. Kiewitz', 13, 10, '$'
COM_LoadCode    db ' - Loading bootcode from file...$'
COM_CodeName    db 'AIR-BOOT.COM', 0
COM_LoadMBR     db ' - Loading MBR-protection from file...$'
COM_MBRName     db 'MBR-PROT\MBR-PROT.BIN', 0
COM_MergeMBR    db ' - Merging MBR-protection into bootcode...$'
COM_CountCode   db ' - Count code in bootcode-image...$'
COM_WriteCode   db ' - Saving bootcode to file...$'
COM_Okay        db 'ok', 13, 10, '$'
COM_Failed      db 'failed', 13, 10, '$'

COM_FailedOpenCode    db 'air-boot.com not found', 13, 10, '$'
COM_FailedReadCode    db 'Read air-boot.com failed', 13, 10, '$'
COM_FailedInvalidCode db 'Invalid air-boot.com', 13, 10, '$'
COM_FailedOpenMBR     db 'mbr-prot\mbr-prot.bin not found', 13, 10, '$'
COM_FailedReadMBR     db 'Read mbr-prot\mbr-prot.bin failed', 13, 10, '$'
COM_FailedInvalidMBR  db 'Invalid mbr-prot\mbr-prot.bin', 13, 10, '$'
COM_FailedWriteCode   db 'Write air-boot.com failed', 13, 10, '$'

MBRProtectionSignature     db 'AiR-BOOT MBR-Protection Image'
MBRProtectionSignatureLen equ 29

ShowMessage     Proc Near  Uses ax
   mov     ah, 09h
   int     21h              ; DOS: WRITE STRING DS:DX TO CONSOLE
   ret
ShowMessage     EndP

ShowError   Proc Near
        mov     ah, 09h
        int     21h             ; DOS: WRITE STRING DS:DX TO CONSOLE
        mov     al,1            ; Error code
        jmp     EndProgram
        ret
ShowError   EndP

COM_Init:
                ; Setup and Copyright.
                mov     ax, cs
                mov     ds, ax
                mov     es, ax           ; CS==DS==ES
                mov     dx, offset COM_Copyright
                call    ShowMessage

                ; Open AIR-BOOT.COM
                mov     dx, offset COM_LoadCode
                call    ShowMessage
                mov     ax, 3D00h
                mov     dx, offset COM_CodeName
                xor     cl, cl
                int     21h              ; DOS: OPEN EXISTING FILE
                jnc     DoneOpenCode
                mov     dx, offset COM_FailedOpenCode
                call    ShowError

DoneOpenCode:   mov     bx, ax           ; BX = Filehandle

                ; Load AIR-BOOT.COM
                mov     ah, 3Fh
                mov     cx, image_size   ; Image size
                mov     dx, offset BootCode
                int     21h              ; DOS: READ FILE
                jnc     DoneReadCode
                mov     dx, offset COM_FailedReadCode
                call    ShowError


DoneReadCode:
                ; See if at least 'image-size' is loaded.
                cmp     ax, image_size
                je      DoneReadCode2
InvalidCode:    mov     dx, offset COM_FailedInvalidCode
                call    ShowError

                ; Try to read again which is expected to fail.
                ; Otherwise image is too large.
DoneReadCode2:  mov     ah, 3Fh
                mov     cx, 1
                mov     dx, offset BootCode
                int     21h              ; DOS: READ FILE
                jc      DoneReadCode3
                or      ax, ax
                jz      DoneReadCode3    ; EOF -> is now expected
                jmp     InvalidCode

                ; It's loaded now, close it.
DoneReadCode3:  mov     ah, 3Eh
                int     21h              ; DOS: CLOSE FILE

                mov     dx, offset COM_Okay
                call    ShowMessage

                ; Open MBR_PROT.BIN
                mov     dx, offset COM_LoadMBR
                call    ShowMessage
                mov     ax, 3D00h
                mov     dx, offset COM_MBRName
                xor     cl, cl
                int     21h              ; DOS: OPEN EXISTING FILE
                jnc     DoneOpenMBR
                mov     dx, offset COM_FailedOpenMBR
                call    ShowError

DoneOpenMBR:    mov     bx, ax           ; BX = Filehandle

                ; Load MBR-PROT.BIN
                mov     ah, 3Fh
                mov     cx, 1024         ; Image size
                mov     dx, offset MBRProtection
                int     21h              ; DOS: READ FILE
                jnc     DoneReadMBR
                mov     dx, offset COM_FailedReadMBR
                call    ShowError

DoneReadMBR:
                ; See if at least 1kB is loaded.
                cmp     ax, 1024
                je      DoneReadMBR2
InvalidMBR:     mov     dx, offset COM_FailedInvalidMBR
                call    ShowError

                ; Try to read again which is expected to fail.
                ; Otherwise image is too large.
DoneReadMBR2:   mov     ah, 3Fh
                mov     cx, 1
                mov     dx, offset MBRProtection
                int     21h              ; DOS: READ FILE
                jc      DoneReadMBR3
                or      ax, ax
                jz      DoneReadMBR3     ; EOF -> is now expected
                jmp     InvalidMBR

                ; It's loaded now, close file.
DoneReadMBR3:   mov     ah, 3Eh
                int     21h              ; DOS: CLOSE FILE

                mov     dx, offset COM_Okay
                call    ShowMessage



                ; ========================== Merge MBR-Protection into Bootcode
                mov     dx, offset COM_MergeMBR
                call    ShowMessage

                ; Search for signature in Bootcode
                ; Note the search is with sector granularity.
                ; This means the signature must be 512 bytes aligned.
                mov     si, offset BootCode
                mov     di, offset MBRProtectionSignature
                mov     cx, MBRProtectionSignatureLen
                ; 54 sectors where signature may be.
                ; (all sectors preceding config sector)
                mov     dx, 54
COM_SignatureLoop:
                push    cx
                push    si
                push    di
                   repe    cmpsb
                pop     di
                pop     si
                pop     cx
                je      COM_GotSignature
                add     si, 512
                dec     dx
                jnz     COM_SignatureLoop
                mov     dx, offset COM_Failed
                call    ShowMessage
                mov     al,2            ; Error code
                jmp     EndProgram

COM_GotSignature:
                ; Now copy MBR-protection into bootcode
                mov     di, si
                mov     si, offset MBRProtection
                mov     cx, 512
                rep     movsw
                mov     dx, offset COM_Okay
                call    ShowMessage

                ; ====================== Count code sectors and adjust bootcode
                mov     dx, offset COM_CountCode
                call    ShowMessage

                mov     si, offset BootCode
                add     si, 512*53  ; 6A00
                mov     cx, 256     ; 512 bytes
                mov     dx, 53      ; initial count
COM_CodeEndLoop:push    cx
                push    si
                push    di
COM_CodeEndLoop2:
                   cmp     wptr ds:[si], 0
                   jne     COM_ExitCodeEndLoop
                   add     si, 2
                   dec     cx
                   jnz     COM_CodeEndLoop2
COM_ExitCodeEndLoop:
                pop     di
                pop     si
                pop     cx
                jne     COM_FoundCodeEnd
                sub     si, 512
                dec     dx
                jnz     COM_CodeEndLoop
                mov     dx, offset COM_Failed
                call    ShowError

COM_FoundCodeEnd:
                mov     [BootCode+10h], dl
                mov     dx, offset COM_Okay
                call    ShowMessage

                ; ================================ Save bootcode back into file
                mov     dx, offset COM_WriteCode
                call    ShowMessage
                mov     ax, 3D02h
                mov     dx, offset COM_CodeName
                xor     cl, cl
                int     21h              ; DOS: OPEN EXISTING FILE
                jnc     DoneOpenCode2
                mov     dx, offset COM_FailedOpenCode
                call    ShowError

DoneOpenCode2:  mov     bx, ax           ; BX = Filehandle

                mov     ah, 40h
                mov     cx, image_size   ; Image size
                mov     dx, offset BootCode
                int     21h              ; DOS: WRITE FILE
                jnc     DoneWriteCode
FailedWriteCode:mov     dx, offset COM_FailedWriteCode
                call    ShowError

DoneWriteCode:  cmp     ax, image_size
                jne     FailedWriteCode

                mov     ah, 3Eh
                int     21h              ; DOS: CLOSE FILE

                mov     dx, offset COM_Okay
                call    ShowMessage
                xor     al,al           ; No Error
                jmp     EndProgram


EndProgram:
   ; DOS: TERMINATE PROGRAM
   mov     ah, 04Ch
   int     21h



COM_EndOfSegment:

code_seg	ends

bss_data    segment  use16 public   'BSS'
; Buffers for files
BootCode        db  image_size dup (?)
MBRProtection   db  1024 dup (?)
bss_data    ends

		end	COM_StartUp
