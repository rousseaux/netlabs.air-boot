
JUMPS

Include ..\..\..\..\JimiHelp\asm.inc\stdmacro.inc
include ..\global.asm\airboot.inc

		.386p
                model large, basic

code_seg        segment public use16
                assume  cs:code_seg, ds:nothing, es:nothing, ss:nothing
                org     100h
air_boot_setup: jmp     SETUP_Start

Introduction:   db      'AiR-BOOT DOS Install-Disc Maker - (c) 2002 by Martin Kiewitz',13,10
                db      13,10
                db      'This program will generate an install-bootdisc, so AiR-BOOT can be installed',13,10
                db      'for any OS, like many of them do not allow direct harddisc access.',13,10
                db      13,10
                db      'Please note: This disc will be ''squashed'', so all of its contents will get',13,10
                db      '             lost. Do not use it anymore for any other purpose than AiR-BOOT.',13,10
                db      13,10
                db      'Please insert a non-used disc into drive A: and strike ENTER...',13,10
                db      ' ...any other key will abort this program... $'

ProgramAbort:   db      'Program aborted!',13,10,'$'

ProgramReadErr: db      'LOAD ERROR! - Try a different floppy or No floppy in drive',13,10,'$'
ProgramWriteErr db      'WRITE ERROR! - Try a different floppy',13,10,'$'
ProgramDone:    db      'done',13,10
                db      'Please activate write-protection on this disc!',13,10,'$'

AiRBOOTvolName: db      'AiR-BOOT   '

RetryCount      db      0


SETUP_Start:    mov     ax, cs
                mov     ds, ax
                mov     es, ax           ; DS==ES==CS
                mov     ah, 09h
                mov     dx, offset Introduction
                int     21h              ; DIRECT CONSOLE STRING OUTPUT

                mov     ah, 07h
                int     21h              ; DIRECT CONSOLE INPUT
                cmp     al, 13
                je      GoGoWriteDisc
                mov     ah, 09h
                mov     dx, offset ProgramAbort
                int     21h
                jmp     GoByeBye

                ; Now at first load first sector of floppy into memory...
GoGoWriteDisc:  
                mov     ah, 06h
                mov     dl, 13
                int     21h              ; DIRECT CONSOLE OUTPUT
                mov     dl, 10
                int     21h              ; DIRECT CONSOLE OUTPUT

                mov     ah, 06h
                mov     dl, '.'
                int     21h              ; DIRECT CONSOLE OUTPUT

                ; First we read the 1st sector of the floppy...
                mov     RetryCount, 3
                mov     bx, offset TransferTemp
ReadFloppy:     mov     cx, 0001h        ; Cylinder 0, Sector 1
                xor     dx, dx           ; Disc 0 (floppy), Head 0
                mov     ax, 0201h
                int     13h              ; BIOS - LOAD ONE SECTOR
                jnc     ReadFloppyDone
                cmp     ah, 9            ; DMA Boundary problem?
                jne     NoDMAboundary
                mov     bx, offset TransferTemp2
NoDMAboundary:  xor     ah, ah
                int     13h              ; BIOS - RESET DISC
                dec     RetryCount
                jnz     ReadFloppy
                mov     ah, 09h
                mov     dx, offset ProgramReadErr
                int     21h              ; DIRECT CONSOLE STRING OUTPUT
                jmp     GoByeBye

ReadFloppyDone: mov     si, bx
                add     si, 3
                mov     di, offset InstallerCode+3
                mov     cx, 30
                rep     movsw            ; Copy Offset 2, 60 bytes...
                mov     si, offset AiRBOOTvolName
                mov     di, bx
                add     di, 43
                mov     cx, 11
                rep     movsb

                ; Now we write the installer code to floppy
                ; Resulting into Cylinder 0&1, Sector 1-8 each -> 8192 bytes

                mov     si, offset InstallerCode
                mov     cx, 0001h        ; Cylinder 0, Sector 1
                xor     dx, dx           ; Disc 0 (floppy), Head 0
WriteFloppyLoop:   call    WriteSector
                inc     cl               ; Go to next sector
                cmp     cl, 8
                jbe     WriteFloppyLoop
                mov     cl, 1            ; Sector 1 again...
                inc     ch               ; Go to next cylinder
                cmp     ch, 9            ; till sector 10 (not inclusive)
                jbe     WriteFloppyLoop

                mov     ah, 09h
                mov     dx, offset ProgramDone
                int     21h              ; DIRECT CONSOLE STRING OUTPUT
                
                ; Terminate ourselves...
GoByeBye:       mov     ax, 4C00h
                int     21h              ; Terminate us...


; DS:BX - points to TransferTemp or TransferTemp2 for transfering sectors
;    SI - points to sector to get transfered (InstallerCode/MainImage)
;    CX - filled up with needed Cylinder/Sector-Count
;    DX - filled up with needed Drive/Head-Count
WriteSector:    push    cx dx
                   mov     ah, 06h
                   mov     dl, '.'
                   int     21h           ; DIRECT CONSOLE OUTPUT
                   mov     di, bx
                   mov     cx, 256
                   rep     movsw         ; Copy over next sector...
                pop     dx cx
                mov     RetryCount, 3
WriteSectorLoop:   mov     ax, 0301h
                   int     13h           ; BIOS - WRITE ONE SECTOR
                   jnc     WriteSectorDone
                   xor     ah, ah
                   int     13h           ; BIOS - RESET DISC
                dec     RetryCount
                jnz     WriteSector
                mov     ah, 09h
                mov     dx, offset ProgramWriteErr
                int     21h           ; DIRECT CONSOLE STRING OUTPUT
                jmp     GoByeBye
WriteSectorDone:retn

; Here we got some place for AiR-BOOT image and the installation disc code...

                org     7168
TransferTemp:   db      512 dup (0)      ; We need 2, because of DMA boundary
TransferTemp2:  db      512 dup (0)
InstallerCode:  db      8192 dup (0)
MainImage:      db      30976 dup (0)

code_seg	ends
		end	air_boot_setup
