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

JUMPS

Include ..\..\include\asm.inc
; include ..\..\include\dos\airboot.inc

		.386p
                model large, basic

code_seg        segment public use16
                assume  cs:code_seg, ds:code_seg, es:nothing, ss:nothing
                org     100h
COM_StartUp:    jmp     COM_Init

COM_Copyright   db 'AiR-BOOT Bootcode Image Fix', 13, 10
                db ' - (c) Copyright 2009 by M. Kiewitz', 13, 10, '$'
COM_LoadCode    db ' - Loading bootcode from file...$'
COM_CodeName    db 'air-boot.com', 0
COM_LoadMBR     db ' - Loading MBR-protection from file...$'
COM_MBRName     db 'mbr-prot\mbr_prot.com', 0
COM_MergeMBR    db ' - Merging MBR-protection into bootcode...$'
COM_CountCode   db ' - Count code in bootcode-image...$'
COM_WriteCode   db ' - Saving bootcode to file...$'
COM_Okay        db 'ok', 13, 10, '$'
COM_Failed      db 'failed', 13, 10, '$'

COM_FailedOpenCode    db 'air-boot.com not found', 13, 10, '$'
COM_FailedReadCode    db 'Read air-boot.com failed', 13, 10, '$'
COM_FailedInvalidCode db 'Invalid air-boot.com', 13, 10, '$'
COM_FailedOpenMBR     db 'mbr-prot\mbr_prot.com not found', 13, 10, '$'
COM_FailedReadMBR     db 'Read mbr-prot\mbr_prot.com failed', 13, 10, '$'
COM_FailedInvalidMBR  db 'Invalid mbr-prot\mbr_prot.com', 13, 10, '$'
COM_FailedWriteCode   db 'Write air-boot.com failed', 13, 10, '$'

MBRProtectionSignature     db 'AiR-BOOT MBR-Protection Image'
MBRProtectionSignatureLen equ 29

ShowMessage     Proc Near  Uses ax
   mov     ah, 09h
   int     21h              ; DOS: WRITE STRING DS:DX TO CONSOLE
   ret
ShowMessage     EndP

ShowError       Proc Near  Uses
   mov     ah, 09h
   int     21h              ; DOS: WRITE STRING DS:DX TO CONSOLE
  EndProgram:
   mov     ax, 4C00h
   int     21h              ; DOS: TERMINATE PROGRAM
ShowError       EndP

COM_Init:       mov     ax, cs
                mov     ds, ax
                mov     es, ax           ; CS==DS==ES
                mov     dx, offset COM_Copyright
                call    ShowMessage

                ; =========================================== Load air-boot.bin
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

                mov     ah, 3Fh
                mov     cx, 30720        ; Image size
                mov     dx, offset BootCode
                int     21h              ; DOS: READ FILE
                jnc     DoneReadCode
                mov     dx, offset COM_FailedReadCode
                call    ShowError

DoneReadCode:   cmp     ax, 30720
                je      DoneReadCode2
InvalidCode:    mov     dx, offset COM_FailedInvalidCode
                call    ShowError

DoneReadCode2:  mov     ah, 3Fh
                mov     cx, 1
                mov     dx, offset BootCode
                int     21h              ; DOS: READ FILE
                jc      DoneReadCode3
                or      ax, ax
                jz      DoneReadCode3    ; EOF -> is now expected
                jmp     InvalidCode

DoneReadCode3:  mov     ah, 3Eh
                int     21h              ; DOS: CLOSE FILE

                mov     dx, offset COM_Okay
                call    ShowMessage

                ; =================================== Load MBR-protection image
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

                mov     ah, 3Fh
                mov     cx, 1024         ; Image size
                mov     dx, offset MBRProtection
                int     21h              ; DOS: READ FILE
                jnc     DoneReadMBR
                mov     dx, offset COM_FailedReadMBR
                call    ShowError

DoneReadMBR:    cmp     ax, 1024
                je      DoneReadMBR2
InvalidMBR:     mov     dx, offset COM_FailedInvalidMBR
                call    ShowError

DoneReadMBR2:   mov     ah, 3Fh
                mov     cx, 1
                mov     dx, offset MBRProtection
                int     21h              ; DOS: READ FILE
                jc      DoneReadMBR3
                or      ax, ax
                jz      DoneReadMBR3     ; EOF -> is now expected
                jmp     InvalidMBR

DoneReadMBR3:   mov     ah, 3Eh
                int     21h              ; DOS: CLOSE FILE

                mov     dx, offset COM_Okay
                call    ShowMessage

                ; ========================== Merge MBR-Protection into Bootcode
                mov     dx, offset COM_MergeMBR
                call    ShowMessage

                ; Search for signature in Bootcode
                mov     si, offset BootCode
                mov     di, offset MBRProtectionSignature
                mov     cx, MBRProtectionSignatureLen
                mov     dx, 54 ; 54 sectors where signature may be
COM_SignatureLoop:
                push    cx si di
                   repe    cmpsb
                pop     di si cx
                je      COM_GotSignature
                add     si, 512
                dec     dx
                jnz     COM_SignatureLoop
                mov     dx, offset COM_Failed
                call    ShowMessage
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
                add     si, 512*53
                mov     cx, 256
                mov     dx, 53
COM_CodeEndLoop:push    cx si di
COM_CodeEndLoop2:
                   cmp     wptr ds:[si], 0
                   jne     COM_ExitCodeEndLoop
                   add     si, 2
                   dec     cx
                   jnz     COM_CodeEndLoop2
COM_ExitCodeEndLoop:
                pop     di si cx
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
                mov     cx, 30720        ; Image size
                mov     dx, offset BootCode
                int     21h              ; DOS: WRITE FILE
                jnc     DoneWriteCode
FailedWriteCode:mov     dx, offset COM_FailedWriteCode
                call    ShowError

DoneWriteCode:  cmp     ax, 30720
                jne     FailedWriteCode

                mov     ah, 3Eh
                int     21h              ; DOS: CLOSE FILE

                mov     dx, offset COM_Okay
                call    ShowMessage
                jmp     EndProgram

; Buffers for files
BootCode        db 30720 dup (?)
MBRProtection   db  1024 dup (?)

COM_EndOfSegment:

code_seg	ends
		end	COM_StartUp
