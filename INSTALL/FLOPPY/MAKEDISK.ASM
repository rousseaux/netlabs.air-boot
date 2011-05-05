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

include ..\..\include\asm.inc

		.386p
                model large, basic

code_seg        segment public use16
                assume  cs:code_seg, ds:nothing, es:nothing, ss:nothing
                org     100h
AiRBOOTMakeDisk:jmp     MakeDisk_Start

TXT_Intro:      db      'AiR-BOOT DOS Install-Disc Maker - (c) 2002-2009 by M. Kiewitz', 13, 10
                db      ' uses FreeDOS bootrecord (c) 1997 by Svante Frey', 13, 10
                db      13, 10
                db      'This program will generate an install-bootdisc, so AiR-BOOT can be installed',13,10
                db      'for any OS, like many of them do not allow direct harddisc access.',13,10
                db      13,10
                db      'Please note: The floppy needs to be already formated using FAT.', 13, 10
                db      '             The file kernel.sys will get created.',13,10
                db      13,10
                db      'Please insert a floppy-disc into drive A: and hit ENTER...',13,10
                db      ' ...any other key will abort this program... $'

TXT_Abort:      db      'Program aborted!', 13, 10, '$'

TXT_ReadingFloppy:
                db      ' þ Reading floppy bootrecord...', '$'
TXT_FloppyNoFAT:db      '    This floppy is not formated using FAT filesystem.', 13, 10, '$'
TXT_WritingFloppy:
                db      ' þ Writing floppy bootrecord...', '$'

TXT_ReadingBootcode:
                db      ' þ Reading bootcode...', '$'
TXT_FailedOpenBootCode:
                db      'airboot.bin not found!', 13, 10, '$'
TXT_FailedReadBootCode:
                db      'could not read airboot.bin', 13, 10, '$'
TXT_InvalidBootCode:
                db      'invalid airboot.bin', 13, 10, '$'

TXT_WritingData:db      ' þ Writing data to floppy...', '$'

TXT_FailedOpenKernelSys:
                db      'could not create a:\kernel.sys', 13, 10, '$'
TXT_FailedWriteKernelSys:
                db      'could not write a:\kernel.sys', 13, 10, '$'

TXT_Okay:       db      'ok', 13, 10, '$'

TXT_ReadError:  db      'LOAD ERROR!', 13, 10
                db      '    Try a different floppy or No floppy in drive', 13, 10, '$'
TXT_WriteError: db      'WRITE ERROR!', 13, 10
                db      '    Try a different floppy', 13, 10, '$'
TXT_Done:       db      'Please activate write-protection on this disc!',13,10,'$'

AiRBOOTVolume   db      'AiRBOOT    '

BootCodeFile    db      'airboot.bin', 0

KernelSysFile   db      'a:\kernel.sys', 0

RetryCount      db      0

APIShowMessage: mov     ah, 09
                int     21h              ; DIRECT CONSOLE STRING OUTPUT
                retn
APIShowError:   mov     ah, 09
                int     21h              ; DIRECT CONSOLE STRING OUTPUT
                jmp     GoByeBye

MakeDisk_Start: mov     ax, cs
                mov     ds, ax
                mov     es, ax           ; DS==ES==CS
                mov     dx, offset TXT_Intro
                call    APIShowMessage

                mov     ah, 07h
                int     21h              ; DIRECT CONSOLE INPUT
                cmp     al, 13
                je      GoGoCreate
                mov     dx, offset TXT_Abort
                call    APIShowError

                ; Now at first load first sector of floppy into memory...
GoGoCreate:     mov     ah, 06h
                mov     dl, 13
                int     21h              ; DIRECT CONSOLE OUTPUT
                mov     dl, 10
                int     21h              ; DIRECT CONSOLE OUTPUT

                mov     dx, offset TXT_ReadingFloppy
                call    APIShowMessage

                ; First we read the 1st sector of the floppy...
                mov     RetryCount, 3
                mov     bx, offset FloppyBootRecord
ReadFloppy:     mov     cx, 0001h        ; Cylinder 0, Sector 1
                xor     dx, dx           ; Disc 0 (floppy), Head 0
                mov     ax, 0201h
                int     13h              ; BIOS - LOAD ONE SECTOR
                jnc     ReadFloppyDone
                cmp     ah, 9            ; DMA Boundary problem?
                jne     NoDMAboundary
                mov     bx, offset FloppyBootRecord2
NoDMAboundary:  xor     ah, ah
                int     13h              ; BIOS - RESET DISC
                dec     RetryCount
                jnz     ReadFloppy
                mov     dx, offset TXT_ReadError
                call    APIShowError

ReadFloppyDone: push    bx dx
                   mov     dx, offset TXT_Okay
                   call    APIShowMessage
                pop     dx bx
                ; Check, if floppy is formated using FAT
                mov     si, bx
                add     si, 54
                cmp     wptr [si], 'AF'
                jne     FloppyNoFAT
                cmp     bptr [si+2], 'T'
                je      FloppyIsFAT      ; Some have 'FAT' some have 'FAT12'
FloppyNoFAT:    mov     dx, offset TXT_FloppyNoFAT
                call    APIShowError

FloppyIsFAT:    push    bx cx dx
                   mov     dx, offset TXT_WritingFloppy
                   call    APIShowMessage
                   mov     di, bx
                   mov     si, offset FreeDOSBootRecord
                   mov     cx, 3
                   rep     movsb         ; Copy first 3 bytes of FreeDOS BR
                   add     si, 40
                   add     di, 40
                   mov     cx, 11
                   rep     movsb         ; Copy over volume label ('AiRBOOT')
                   add     si, 8
                   add     di, 8
                   mov     cx, 450/2     ; Copy rest of FreeDOS BR
                   rep     movsw
                pop     dx cx bx
                ; Now we write it back...
                mov     ax, 0301h
                int     13h              ; BIOS - WRITE ONE SECTOR
                jnc     WriteFloppyDone
                mov     dx, offset TXT_WriteError
                call    APIShowError

WriteFloppyDone:mov     dx, offset TXT_Okay
                call    APIShowMessage

                ; Now we create kernel.sys on the floppy and that's it
                ;  kernel.sys is actually kernel.com (KernelSys label) and
                ;  airboot.bin appended afterwards

                mov     dx, offset TXT_ReadingBootcode
                call    APIShowMessage

                mov     ax, 3D00h
                mov     dx, offset BootCodeFile
                xor     cl, cl
                int     21h              ; DOS: OPEN EXISTING FILE
                jnc     DoneOpenBootCode
                mov     dx, offset TXT_FailedOpenBootCode
                call    APIShowError

DoneOpenBootCode:
                mov     bx, ax           ; BX = Filehandle
                mov     ah, 3Fh
                mov     cx, 30720        ; Image size
                mov     dx, offset BootCodeImage
                int     21h              ; DOS: READ FILE
                jnc     DoneReadBootCode
                mov     dx, offset TXT_FailedReadBootCode
                call    APIShowError

DoneReadBootCode:
                cmp     ax, 30720
                je      DoneReadBootCode2
InvalidBootCode:mov     dx, offset TXT_InvalidBootCode
                call    APIShowError

DoneReadBootCode2:
                mov     ah, 3Fh
                mov     cx, 1
                mov     dx, offset BootCodeImage
                int     21h              ; DOS: READ FILE
                jc      DoneReadBootCode3
                or      ax, ax
                jz      DoneReadBootCode3 ; EOF -> is now expected
                jmp     InvalidBootCode

DoneReadBootCode3:
                mov     ah, 3Eh
                int     21h              ; DOS: CLOSE FILE
                mov     dx, offset TXT_Okay
                call    APIShowMessage

                ; Now create a:\kernel.sys
                mov     dx, offset TXT_WritingData
                call    APIShowMessage

                mov     ax, 3C02h
                mov     dx, offset KernelSysFile
                xor     cl, cl
                int     21h              ; DOS: CREATE/TRUNCATE FILE
                jnc     DoneOpenKernelSys
                mov     dx, offset TXT_FailedOpenKernelSys
                call    APIShowMessage

DoneOpenKernelSys:
                mov     bx, ax           ; BX = Filehandle

                mov     ah, 40h
                mov     cx, 4280         ; kernel.com size
                mov     dx, offset KernelSys
                int     21h              ; DOS: WRITE FILE
                jnc     DoneWriteKernelSys1
FailedWriteKernelSys:
                mov     dx, offset TXT_FailedWriteKernelSys
                call    APIShowError
DoneWriteKernelSys1:
                cmp     ax, 4280
                jne     FailedWriteKernelSys

                mov     ah, 40h
                mov     cx, 30720        ; Bootcode image size
                mov     dx, offset BootCodeImage
                int     21h              ; DOS: WRITE FILE
                jc      FailedWriteKernelSys
                cmp     ax, 30720
                jne     FailedWriteKernelSys

                mov     ah, 3Eh
                int     21h              ; DOS: CLOSE FILE

                mov     dx, offset TXT_Okay
                call    APIShowMessage
                mov     dx, offset TXT_Done
                call    APIShowMessage
                
                ; Terminate ourselves...
GoByeBye:       mov     ax, 4C00h
                int     21h              ; Terminate us...

; Uninitialized variables come here...
;  Attention: FreeDOS and kernel-code need to come here first because we will
;              append them to makedisk.com. Also if you change kernel-code,
;              you will need to adjust length accordingly
FreeDOSBootRecord:
                db   512 dup(?)
KernelSys:      db  4280 dup(?)

FloppyBootRecord:  db   512 dup (?)
FloppyBootRecord2: db   512 dup (?)

BootCodeImage:  db 30720 dup (?)


code_seg	ends
		end	AiRBOOTMakeDisk
