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

JUMPS

Include ..\..\include\asm.inc

		.386p
                model large, basic

code_seg        segment public use16
                assume  cs:code_seg, ds:code_seg, es:nothing, ss:nothing
                org     100h
COM_StartUp:    jmp     COM_Init

COM_Copyright   db 'AiR-BOOT Installer for DOS v1.00', 13, 10
                db ' - (c) Copyright 2008-2009 by M. Kiewitz.', 13, 10
                db 13, 10
                db '-> ...Please wait... <-', 13, 10, 0

COM_LoadFile    db ' - Loading bootcode from file...', 0

COM_ImageName   db 'airboot.bin', 0

COM_FailedOpen  db 'airboot.bin not found', 13, 10, 0
COM_FailedRead  db 'Read airboot.bin failed', 13, 10, 0
COM_FailedRead2 db 'Invalid airboot.bin', 13, 10, 0
COM_FailedAlloc db 'Not enough memory!', 13, 10, 0

COM_LockFailed  db 'Unable to lock harddrive', 13, 10, 0

COM_CmdForceCode       db 'forcecode'
COM_CmdForceCodeLen   equ  9
COM_CmdForceConfig     db 'forceconfig'
COM_CmdForceConfigLen equ 11
COM_CmdSilent          db 'silent'
COM_CmdSilentLen      equ  6

TXT_AfterAdd    db 13, 10, 'Please hit ENTER to reboot your system...', 0
TXT_AfterDelete:
TXT_AfterQuit   db 13, 10, 'Please hit ENTER to quit AiR-BOOT Installer for DOS', 0

COM_Init:       mov     ax, cs
                mov     ds, ax
                mov     es, ax           ; CS==DS==ES
                mov     si, offset COM_Copyright
                call    APIShowMessage

                ; Resize our own memory block
                mov     bx, 1000h
                mov     ah, 4Ah
                int     21h              ; DOS: RESIZE MEMORY BLOCK

                ; We now analyse the commandline...
                mov     ah, 62h
                int     21h              ; GET CURRENT PSP (into BX)
                push    es
                mov     es, bx           ; ES points now to PSP-Segment
                movzx   dx, es:[80h]     ; CX - Length of Command-Line
                or      dx, dx
                jz      COM_CmdLineDone
                mov     cx, dx
                mov     si, 81h
COM_CmdLineLowcaseLoop:
                   or      bptr [si], 20h
                   inc     si
                dec     cx
                jnz     COM_CmdLineLowcaseLoop
                mov     di, 81h          ; Start at that position
               COM_CmdLineLoop:
                   cmp     bptr es:[di], '/'
                   jne     COM_CmdLineNextChar
                   ; Found a delimiter
                   inc     di
                   dec     dx
                   jz      COM_CmdLineDone
                   mov     cx, COM_CmdSilentLen
                   mov     si, offset COM_CmdSilent
                   call    COM_CheckCmdParm
                   jne     COM_CmdLineNextParm
                   mov     Option_Silent, 1
                  COM_CmdLineNextParm:
                   mov     cx, COM_CmdForceCodeLen
                   mov     si, offset COM_CmdForceCode
                   call    COM_CheckCmdParm
                   jne     COM_CmdLineNextParm2
                   mov     Option_ForceCode, 1
                  COM_CmdLineNextParm2:
                   mov     cx, COM_CmdForceConfigLen
                   mov     si, offset COM_CmdForceConfig
                   call    COM_CheckCmdParm
                   jne     COM_CmdLineLoop
                   mov     Option_ForceConfig, 1
                   jmp     COM_CmdLineLoop
                  COM_CmdLineNextChar:
                   inc     di
                dec     dx
                jnz     COM_CmdLineLoop
                jmp     COM_CmdLineDone

COM_CheckCmdParm:
                push    cx si di
                   repe    cmpsb
                pop     di si cx
                retn

COM_CmdLineDone:; Now read airboot.bin into memory at DS:
                mov     si, offset COM_LoadFile
                call    APIShowMessage
                mov     ax, 3D00h
                mov     dx, offset COM_ImageName
                xor     cl, cl
                int     21h              ; DOS: OPEN EXISTING FILE
                jnc     COM_DoneOpen
                mov     si, offset COM_FailedOpen
                call    APIShowError

COM_DoneOpen:   mov     bx, ax           ; BX = Filehandle

                mov     ah, 3Fh
                mov     cx, 30720        ; Image size
                mov     dx, offset BootImage
                int     21h              ; DOS: READ FILE
                jnc     COM_DoneRead
                mov     si, offset COM_FailedRead
                call    APIShowError

COM_DoneRead:   cmp     ax, 30720
                je      COM_DoneRead2
COM_InvalidFile:mov     si, offset COM_FailedRead2
                call    APIShowError

COM_DoneRead2:  mov     ah, 3Fh
                mov     cx, 1
                mov     dx, offset BootImage
                int     21h              ; DOS: READ FILE
                jc      COM_DoneRead3
                or      ax, ax
                jz      COM_DoneRead3    ; EOF -> is now expected
                jmp     COM_InvalidFile

COM_DoneRead3:  mov     ah, 3Eh
                int     21h              ; DOS: CLOSE FILE

                mov     si, offset TXT_Okay
                call    APIShowMessage

                ; And allocate space for reading in track 0 (generic code)
                mov     ah, 48h
                mov     bx, 800h         ; 32768 Bytes
                int     21h              ; DOS: ALLOCATE MEMORY
                jnc     COM_DoneAlloc
                mov     si, offset COM_FailedAlloc
                call    APIShowError

COM_DoneAlloc:  mov     es, ax           ; ES = memory space for track 0
                jmp     RunInstaller

; =============================================================================
APIExitProgram: mov     ax, ds
                mov     bx, es
                cmp     ax, bx
                je      AEP_SkipFree
                mov     ah, 49h
                int     21h              ; DOS: FREE MEMORY
AEP_SkipFree:   mov     ax, 4C00h
                int     21h              ; DOS: TERMINATE PROGRAM

; =============================================================================
APIAfterAdd:    ; Reboot system
                mov     ax, 8600h
                mov     cx, 65
                xor     dx, dx
                int     15h              ; Wait a little bit...
                db      0EAh             ; Jump to eternity
                dw      0FFF0h
                dw      0F000h

APIAfterDelete:
APIAfterQuit:   jmp     APIExitProgram

; =============================================================================
; DS:SI - NUL-terminated message to display to console
APIShowMessage: push    ax dx si
                   mov     ah, 02h
ASM_Loop:          lodsb
                   or      al, al
                   jz      ASM_Done
                   mov     dl, al
                   int     21h           ; DOS: WRITE CHARACTER TO CONSOLE
                   jmp     ASM_Loop
ASM_Done:       pop     si dx ax
                retn

; =============================================================================
APIShowChar:    push    ax dx
                   mov     ah, 02h
                   mov     dl, al
                   int     21h           ; DOS: WRITE CHARACTER TO CONSOLE
                pop     dx ax
                retn

; =============================================================================
APIShowError:   call    APIShowMessage
                call    APIExitProgram

; =============================================================================
; Returns AL - Keyboard character that was pressed
APIReadKeyboard:mov     ah, 07h
                int     21h              ; DOS: DIRECT CONSOLE INPUT
                ; Result in AL
                retn

APILockVolume:  push    ax bx cx dx
                   mov     ax, 3000h
                   int     21h           ; DOS: GET DOS VERSION
                   cmp     ax, 0700h
                   jne     ALV_SkipLock
                   mov     ax, 440Bh
                   mov     cx, 084Bh
                   mov     bx, 0303h
                   xor     dx, dx
                   int     21h           ; DOS 7.0: LOCK PHYSICAL DRIVE
ALV_SkipLock:
                pop     dx cx bx ax
                jc      ALV_Error
                retn
ALV_Error:      mov     si, offset COM_LockFailed
                call    APIShowError

                Include ..\INST_X86\install.inc ; Execute generic code
COM_EndOfSegment:

code_seg	ends
		end	COM_StartUp
