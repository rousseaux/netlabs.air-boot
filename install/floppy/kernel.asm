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

; If ReleaseCode is not defined, it will produce debug-able code...
ReleaseCode                 equ    -1

JUMPS

; First all Equs

IFDEF ReleaseCode
   ExecBaseSeg     equ     00060h
   ExecBasePtr     equ     00000h ; FreeDOS BR starts us at 0060:0000
  ELSE
   ExecBaseSeg     equ     00BFBh
   ExecBasePtr     equ     00100h
ENDIF
StackSeg        equ     7000h

Include ../../INCLUDE/ASM.INC

		.386p
                model large, basic

code_seg        segment public use16
                assume  cs:code_seg, ds:nothing, es:nothing, ss:nothing
;---------------------------------------------------------------------------
                org     ExecBasePtr
AiRBOOT_Installer:
KernelStart:    jmp     KernelRealStart

;---------------------------------------------------------------------------
TXT_START_Copyright             db      13, 10
                                db      'AiR-BOOT Installer v1.00', 13, 10
                                db      ' - (c) Copyright 1998-2009 by M. Kiewitz.', 13, 10
                                db      ' - FreeDOS bootrecord (c) 1997 by Svante Frey', 13, 10
                                db      13, 10
                                db      '-> ...Please wait... <-', 13, 10, 0

TXT_AfterAdd:
TXT_AfterDelete:
TXT_AfterQuit   db 13, 10, 'Please hit ENTER to reboot your system...', 0

KernelRealStart:mov     ax, StackSeg
                mov     ss, ax
                mov     sp, 7FFFh
                mov     ax, cs
                mov     ds, ax
                mov     es, ax       ; Set DS&ES to new segment
                ; Shows Copyright message
                mov     si, offset TXT_START_Copyright
                call    APIShowMessage

COM_DoneAlloc:  mov     ax, 8000h
                mov     es, ax           ; ES = 8000h - space for track 0
                jmp     RunInstaller

APIExitProgram:
APIAfterAdd:
APIAfterDelete:
APIAfterQuit:   mov     ax, 8600h
                mov     cx, 65
                xor     dx, dx
                int     15h              ; Wait a little bit...
                db      0EAh             ; Jump to eternity
                dw      0FFF0h
                dw      0F000h

; =============================================================================
; DS:SI - NUL-terminated message to display to console
APIShowMessage: push    ax
                push    bx
                push    si
                   mov     ah, 0Eh
                   mov     bx, 7
ASM_Loop:          lodsb
                   or      al, al
                   jz      ASM_Done
                   int     10h           ; BIOS: TELETYPE
                   jmp     ASM_Loop
ASM_Done:       pop     si
                pop     bx
                pop     ax
                retn

; =============================================================================
APIShowChar:    push    ax
                push    bx
                   mov     ah, 0Eh
                   mov     bx, 7
                   int     10h           ; BIOS: TELETYPE
                pop     bx
                pop     ax
                retn

; =============================================================================
APIShowError:   call    APIShowMessage
                call    APIExitProgram

; =============================================================================
; Returns AL - Keyboard character that was pressed
APIReadKeyboard:xor     ah, ah
                int     16h              ; BIOS: GET KEYSTROKE
                ; Result in AL
                retn

APILockVolume:  retn

                Include ../INST_X86/INSTALL.INC ; Execute generic code
COM_EndOfSegment:

code_seg	ends
		end	AiRBOOT_Installer
