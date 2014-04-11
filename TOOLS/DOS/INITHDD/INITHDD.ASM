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

;JUMPS

Include ../../../INCLUDE/ASM.INC

		.386p
                .model large, basic

code_seg        segment public use16
                assume  cs:code_seg, ds:nothing, es:nothing, ss:nothing
                org     100h
air_boot_setup: jmp     INITHDD_Start

Introduction            db 'INITHDD - AiR-BOOT Initialize HDD Utility (DOS) - (c) 2004 by M. Kiewitz',13,10
                        db 0

TXT_ERROR_IO            db 'Could not access harddrive', 13, 10, 0
TXT_ERROR_NotNeeded     db 'INITHDD: Initialization not needed.', 13, 10, 0
TXT_Done                db 'INITHDD: HDD was successfully initialized.', 13, 10, 0
TXT_Cleared             db 'INITHDD: Reserved Sectors successfully cleared.', 13, 10, 0      ; Rousseau: added

StandardMBR:
   dw 02BFAh, 08EC0h, 0B8D0h, 07C00h, 0E08Bh, 0FCFBh, 0C02Bh, 0D88Eh, 000BEh
   dw 0B87Ch, 00060h, 0C08Eh, 0FF2Bh, 000B9h, 0F301h, 0EAA5h, 00024h, 00060h
   dw 0C88Ch, 0D88Eh, 004B9h, 0BF00h, 001BEh, 0158Bh, 0FA80h, 07480h, 0800Ch
   dw 000FAh, 05075h, 0C783h, 0E210h, 0CDEFh, 08B18h, 0EBF7h, 0830Dh, 010C7h
   dw 0058Bh, 0803Ch, 03C74h, 0003Ch, 03875h, 0F1E2h, 005B9h, 0B800h, 00000h
   dw 0C08Eh, 000BBh, 0B47Ch, 0B002h, 05101h, 04C8Bh, 0CD02h, 05913h, 00B73h
   dw 000B4h, 013CDh, 0E5E2h, 0C9BEh, 0EB00h, 02616h, 0BF81h, 001FEh, 0AA55h
   dw 00575h, 000EAh, 0007Ch, 0BE00h, 000B5h, 003EBh, 09DBEh, 0AC00h, 0243Ch
   dw 0FE74h, 0BB56h, 00007h, 00EB4h, 010CDh, 0EB5Eh, 049F0h, 0766Eh, 06C61h
   dw 06469h, 07020h, 07261h, 06974h, 06974h, 06E6Fh, 07420h, 06261h, 0656Ch
   dw 04E24h, 0206Fh, 0706Fh, 07265h, 07461h, 06E69h, 02067h, 07973h, 07473h
   dw 06D65h, 04F24h, 06570h, 06172h, 06974h, 0676Eh, 07320h, 07379h, 06574h
   dw 0206Dh, 06F6Ch, 06461h, 06520h, 07272h, 0726Fh, 00024h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h, 00000h
   dw 00000h, 00000h, 00000h, 0AA55h

;   Include ../../../INCLUDE\DOS\CONST.ASM

INITHDD_Start:  mov     ax, cs
                mov     ds, ax
                mov     es, ax           ; DS==ES==CS
                ; Show Introduction message
                mov     si, offset Introduction
                call    MBR_Teletype

                mov     ax, cs
                mov     es, ax
                mov     bx, offset CurMBR
                mov     dx, 0080h          ; First harddrive, Sector 1
                mov     cx, 0001h
                mov     ax, 0201h          ; Read 1 sector
                int     13h
                jnc     Clear                                                    ; Rousseau: added (only clear)
                jnc     LoadMBR_NoError
                mov     si, offset TXT_ERROR_IO
                call    MBR_Teletype
                jmp     GoByeBye
               LoadMBR_NoError:
                ; Check Master-Boot-Record Signature
                cmp     wptr ds:[CurMBR+01FEh], 0AA55h
                ;;je      AlreadyInitialized                                     ; Rousseau: always initialize

                mov     ax, cs
                mov     es, ax           ; Make sure that ES is right
                mov     bx, offset StandardMBR
                mov     dx, 0080h        ; First harddrive, Sector 1...
                mov     cx, 0001h
                mov     ax, 0301h        ; Function 03, 1 sector to write
                int     13h
                jnc     Done
                mov     si, offset TXT_ERROR_IO
                call    MBR_Teletype
                jmp     GoByeBye
               Done:
                mov     si, offset TXT_Done
                call    MBR_Teletype

                ; Rousseau: added
               Clear:
                call    MBR_ClearReservedSectors
                mov     si, offset TXT_Cleared
                call    MBR_Teletype
                ; Rousseau: end added

                jmp     GoByeBye

               AlreadyInitialized:
                mov     si, offset TXT_Error_NotNeeded
                call    MBR_Teletype

GoByeBye:       mov     ax, 4C00h
                int     21h              ; Terminate us...
                ; End-Of-Code

;        In: SI - Pointer to begin of string (EOS is 0)
; Destroyed: SI
MBR_Teletype                    Proc Near   Uses ax bx cx
   mov     ah, 0Eh
   mov     bx, 7
  MBR_Teletype_Loop:
      lodsb
      or      al, al
      jz      MBR_Teletype_End
      int     10h
      jmp     MBR_Teletype_Loop
  MBR_Teletype_End:
   ret
MBR_Teletype                    EndP


; Rousseau: added
MBR_ClearReservedSectors        Proc Near
   mov   ax, cs
   mov   es, ax                           ; Make sure that ES is right
   mov   cx, 2                            ; Index of first reserved sector to clear
  MBR_ClearReservedSectors_loop:
   push  cx                               ; Put on stack for later use
   mov   bx, offset ZeroSEC               ; Block of 0's
   mov   dx, 0080h                        ; First harddrive, Sector in cx
   ;mov   cx, 0001h
   mov   ax, 0301h                        ; Function 03, 1 sector to write
   int   13h
   pop   cx                               ; Pop sector-index
   inc   cx                               ; Next sector
   cmp   cx, 62                           ; If below 63 (Possible LVM) then...
   jbe   MBR_ClearReservedSectors_loop    ; Repeat
   ret
MBR_ClearReservedSectors        EndP



CurMBR                  db      512 dup (?)
ZeroSEC                 db      512 dup (0)                                      ; Rousseau: added

code_seg	ends
		end	air_boot_setup
