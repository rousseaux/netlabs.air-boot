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

JUMPS

Include ..\..\..\Include\asm.inc
include ..\..\..\include\dos\airboot.inc

		.386p
                model large, basic

code_seg        segment public use16
                assume  cs:code_seg, ds:nothing, es:nothing, ss:nothing
                org     100h
air_boot_setup: jmp     SETABOOT_Start

Introduction:           db 'SETABOOT - AiR-BOOT Configuration Utility (DOS) - (c) 2004-2009 by M. Kiewitz',13,10
                        db 0


TXT_SYNTAX_Show         db 'Syntax:', 13, 10
                        db '  SETABOOT [/T:x or /T:NO][/B][/IBA:name]', 13, 10
                        db 'where the parameters are:', 13, 10
                        db '  T:x       Sets timeout value to x seconds.', 13, 10
                        db '  T:NO      Disables timeout.', 13, 10
                        db '  B         Restarts the system.', 13, 10
                        db '  IBA:name  Restarts the system and automatically boot from partition/volume', 13, 10
                        db '            specified as "name".', 13, 10
                        db 0

TXT_ERROR_IO            db 'Could not access harddrive', 13, 10, 0
TXT_ERROR_NoBootManager db 'SETABOOT: AiR-BOOT is not installed.', 13, 10, 0
TXT_ERROR_CodeDamaged   db 'SETABOOT: AiR-BOOT Code damaged!', 13, 10, 0
TXT_ERROR_ConfigDamaged db 'SETABOOT: AiR-BOOT Config damaged!', 13, 10, 0
TXT_ERROR_BadParm       db 'SETABOOT: Bad parameter', 13, 10, 0
TXT_ERROR_PartNotFound  db 'SETABOOT: Partition not found in IPT.', 13, 10, 0
TXT_ERROR_AnyRequired   db 'SETABOOT: AiR-BOOT required for this feature.', 13, 10, 0
TXT_ERROR_094required   db 'SETABOOT: AiR-BOOT v0.94 required for this feature.', 13, 10, 0
TXT_ERROR_PwdProtected  db 'SETABOOT: This feature needs password protection to be off.', 13, 10, 0
TXT_ERROR_NotBootable   db 'SETABOOT: Partition not set bootable.', 13, 10, 0
TXT_ConfigUpdated       db 'SETABOOT: Configuration updated!', 13, 10, 0
TXT_NowRebooting        db 'SETABOOT: Now rebooting system...', 13, 10, 0

TXT_AiRBOOTdetected     db 'SETABOOT: AiR-BOOT ', 0
                        db ' detected.', 13, 10, 0

   Include ..\..\..\include\dos\Const.asm

AiRBOOTdetected         db 0

DoSetTimer              db 0             ; /T:xx
DoSetTimerValue         db 0
DoUnSetTimer            db 0             ; /T:NO
DoReboot                db 0             ; /B
DoDirectBoot            db 0             ; /IBA:xx
DoDirectBootPart        db 0

SETABOOT_Start: mov     ax, cs
                mov     ds, ax
                mov     es, ax           ; DS==ES==CS
                ; Show Introduction message
                mov     si, offset Introduction
                call    MBR_Teletype

                mov     ax, cs
                mov     es, ax
                mov     bx, offset TrackZero
                mov     dx, 0080h          ; First harddrive, Sector 1
                mov     cx, 0001h
                mov     ax, 023Bh          ; Read 59 sectors
                int     13h
                jnc     LoadTrackZero_NoError
                mov     si, offset TXT_ERROR_IO
                call    MBR_Teletype
                jmp     GoByeBye
               LoadTrackZero_NoError:
                ; Check Master-Boot-Record Signature
                cmp     wptr ds:[TrackZero+01FEh], 0AA55h
                jne     CmdLine_Analyse
                mov     si, offset MBR_AiRBOOTCodeSig
                mov     di, offset TrackZero+2
                mov     cx, MBR_AiRBOOTCodeSigLen
                repe    cmpsb
                jne     CmdLine_Analyse
                ; We found AiR-BOOT signature, so check if code is intact...
                movzx   cx, bptr ds:[TrackZero+10h]
                ; CX - Total-Code-Sectors-Used
                ; Now start at Sector 2 (Code-Image)...
                mov     si, offset TrackZero+512
                xor     bx, bx
               CheckCode_CheckSumLoop:
                   call    MBR_GetCheckOfSector
                loop    CheckCode_CheckSumLoop
                cmp     bx, wptr ds:[TrackZero+11h]
                jne     AiRBOOTCodeCorrupt
                ; We found AiR-BOOT code that is intact
                mov     ax, wptr ds:[TrackZero+0Dh]
                mov     InstalledVersion_Code, ax
                ; Check, if Track-Zero also contains Config-Image
                mov     si, offset MBR_AiRBOOTConfigSig
                mov     di, offset TrackZero+6C00h
                mov     cx, MBR_AiRBOOTConfigSigLen
                repe    cmpsb
                jne     AiRBOOTConfigCorrupt
                ; We found AiR-BOOT CONFIG signature, so check if config okay...
                mov     si, offset TrackZero+6C00h
                mov     dx, wptr ds:[si+20]
                mov     wptr ds:[si+20], 0
                ; Save Config-Checksum in DX and kill it in [TrackZero]
                xor     bx, bx
                mov     cx, 5            ; Total of 5 sectors
               CheckConfig_CheckSumLoop:
                   call    MBR_GetCheckOfSector
                loop    CheckConfig_CheckSumLoop
                cmp     bx, dx
                jne     AiRBOOTConfigCorrupt
                mov     ax, wptr ds:[TrackZero+6C0Dh]
                mov     InstalledVersion_Config, ax
                jmp     AiRBOOTfound

               AiRBOOTnotFound:
                mov     si, offset TXT_ERROR_NoBootManager
                call    MBR_Teletype
                jmp     GoByeBye
               AiRBOOTCodeCorrupt:
                mov     si, offset TXT_ERROR_CodeDamaged
                call    MBR_Teletype
                jmp     GoByeBye
               AiRBOOTConfigCorrupt:
                mov     si, offset TXT_ERROR_ConfigDamaged
                call    MBR_Teletype
                jmp     GoByeBye

                ; We found 100% INTACT AiR-BOOT...
               AiRBOOTfound:
                mov     AiRBOOTdetected, 1
                mov     si, offset TXT_AiRBOOTdetected
                call    MBR_Teletype
                mov     ax, InstalledVersion_Code
                call    MBR_TeletypeNumber
                mov     al, '.'
                call    MBR_TeletypeSingle
                mov     al, ah
                call    MBR_TeletypeNumber2
                ; Now finish sentence ("detected")
                call    MBR_Teletype

               CmdLine_Analyse:
                ; We now analyse the commandline...
                mov     ah, 62h
                int     21h              ; GET CURRENT PSP (into BX)
                push    es
                mov     es, bx           ; ES points now to PSP-Segment
                movzx   cx, es:[80h]     ; CX - Length of Command-Line
                or      cx, cx
                jz      CmdLine_Done
                mov     di, 81h          ; Start at that position
               CmdLine_Loop:
                   cmp     bptr es:[di], '/'
                   jne     CmdLine_NextChar
                   ; Found a delimiter
                   inc     di
                   dec     cx
                   jz      CmdLine_Done
                   mov     al, bptr es:[di] ; AL - Char that follows '/'
                   cmp     al, '?'
                   je      CmdLine_ShowSyntax
                   and     al, 0DFh         ; Upcase AL
                   cmp     al, 'T'
                   je      CmdLine_SetTimeout
                   cmp     al, 'B'
                   je      CmdLine_Reboot
                   cmp     al, 'I'
                   je      CmdLine_RebootTo
                  CmdLine_NextChar:
                   inc     di
                loop    CmdLine_Loop
                jmp     CmdLine_Done

               CmdLine_ShowSyntax:
                mov     si, offset TXT_SYNTAX_Show
                call    MBR_Teletype
                jmp     GoByeBye

               CmdLine_SetTimeout:
                cmp     AiRBOOTdetected, 1
                je      CmdLine_SetTimeoutGo
                mov     si, offset TXT_ERROR_AnyRequired
                call    MBR_Teletype
                jmp     GoByeBye
               CmdLine_SetTimeoutGo:
                inc     di
                dec     cx
                jz      CmdLine_BadParm
                cmp     bptr es:[di], ':'
                jne     CmdLine_BadParm
                inc     di
                dec     cx
                jz      CmdLine_BadParm
                ; Now get number or 'NO' for disabling timer
                mov     dl, bptr es:[di]
                cmp     dl, '0'
                jb      CmdLine_BadParm
                cmp     dl, '9'
                jbe     CmdLine_SetTimeoutNumber
                cmp     dl, 'N'
                jne     CmdLine_BadParm
                ; We expect that 'N' to get followed by 'O' -> 'NO'
                inc     di
                dec     cx
                jz      CmdLine_BadParm
                cmp     bptr es:[di], 'O'
                jne     CmdLine_BadParm
                ; We actually disable Timed-Boot
                mov     DoUnSetTimer, 1
                jmp     CmdLine_NextChar

                ; We expect this to be a number (0-255)
               CmdLine_SetTimeoutNumber:
                mov     DoSetTimer, 1
                xor     ax, ax
                mov     bx, 10
               CmdLine_SetTimeoutNumberLoop:
                   ; we definitely got a number in DL
                   sub     dl, '0'       ; Make 0 out of '0'
                   mul     bl            ; AX = AL * 10
                   add     al, dl
                   adc     ah, 0         ; Add the number to AX
                   ; Now get next byte if available
                   inc     di
                   dec     cx            ; No more left, so we are done!
                   jz      CmdLine_SetTimeoutNumberDone
                   mov     dl, bptr es:[di]
                   cmp     dl, ' '       ; Followed by space? -> Done!
                   je      CmdLine_SetTimeoutNumberDone
                   cmp     dl, '0'
                   jb      CmdLine_BadParm
                   cmp     dl, '9'
                   ja      CmdLine_BadParm
                jmp     CmdLine_SetTimeoutNumberLoop
               CmdLine_SetTimeoutNumberDone:
                cmp     ax, 255
                ja      CmdLine_BadParm
                mov     DoSetTimerValue, al
                or      cx, cx           ; Nothing left on commandline? -> Done
                jz      CmdLine_Done
                jmp     CmdLine_NextChar

               CmdLine_Reboot:
                mov     DoReboot, 1
                jmp     CmdLine_NextChar

               CmdLine_RebootTo:
                cmp     AiRBOOTdetected, 1
                jne     CmdLine_RebootToAiRBOOTrequired
                mov     ax, InstalledVersion_Code
                xchg    ah, al
                cmp     ax, 094h
                jae     CmdLine_RebootToVersionOkay
               CmdLine_RebootToAiRBOOTrequired:
                mov     si, offset TXT_ERROR_094required
                call    MBR_Teletype
                jmp     GoByeBye
               CmdLine_RebootToVersionOkay:
                ; Check, if PasswordSystem:BYTE or PasswordedChngBoot:BYTE
                ;  is active. We don't allow automatic boot on passworded
                ;  systems.
                cmp     wptr ds:[TrackZero+6C00h+37], 0
                je      CmdLine_RebootToNoPassword
                mov     si, offset TXT_ERROR_PwdProtected
                call    MBR_Teletype
                jmp     GoByeBye
               CmdLine_RebootToNoPassword:
                mov     DoDirectBoot, 1
                mov     DoReboot, 1
                cmp     cx, 5            ; We need at least 4 more chars
                jb      CmdLine_BadParm
                mov     ax, wptr es:[di+1]
                and     ax, 0DFDFh       ; Upcase AX
                cmp     ax, 'AB'
                jne     CmdLine_BadParm
                cmp     bptr es:[di+3], ':'
                jne     CmdLine_BadParm
                add     di, 4
                sub     cx, 4
                ; We now need to extract the partition/volume name and
                ;  compare it to IPT entries...
                ;  First we will check, if there is a '"' in front. If that's
                ;  the case, we look for an ending '"'. Otherwise till ' '/EOL
                mov     al, ' '
                cmp     bptr es:[di], '"'
                jne     CmdLine_RebootToExtractName
                mov     al, '"'
                inc     di
                dec     cx
                jz      CmdLine_BadParm
               CmdLine_RebootToExtractName:
                ; AL is ending character to look for (or EOL)
                mov     si, di           ; Save start of name
                push    cx
                  CmdLine_RebootToExtractNameLoop:
                      cmp     bptr es:[di], al
                      je      CmdLine_RebootToExtractNameDone
                      inc     di
                   dec     cx
                   jnz     CmdLine_RebootToExtractNameLoop
                  CmdLine_RebootToExtractNameDone:
                pop     cx
                mov     bx, di
                sub     bx, si           ; SI (BX) -> Partition/Volume Name
                or      bx, bx
                jz      CmdLine_BadParm  ; If Length==0 -> Bad parameter
                cmp     al, '"'          ; Skip over '"', if not already at EOS
                jne     CmdLine_RebootToNoFixup
                or      cx, cx
                jz      CmdLine_RebootToNoFixup
                inc     di
                dec     cx
               CmdLine_RebootToNoFixup:
                cmp     bx, 11
                jbe     CmdLine_RebootToLengthFine
                mov     bx, 11           ; Maximum 11 chars
               CmdLine_RebootToLengthFine:
                ; Now we compare that name to the names in our IPT
                ;  SI will keep pointing to partition/volume name to search for
                ;  DI will point to IPT-entry (PartitionName-Item)
                ;  BX contains length of name to search for
                ;  DL holds total IPT entries to go
                ;  DH holds current partition number (base 0)
                push    cx es di
                   mov     ax, ds
                   mov     es, ax        ; ES == DS for now
                   movzx   dx, bptr [TrackZero+6C00h+22] ; [Partition count]
                   or      dl, dl
                   jz      CmdLine_RebootToNotFound
                   mov     di, offset TrackZero+6E00h ; Starting at sector 56
                  CmdLine_RebootToSearchLoop:
                      push    si di
                         add     di, 4   ; Seek to "PartitionName" item
                         mov     cx, bx
                         rep     cmpsb
                      pop     di si
                      je      CmdLine_RebootToSearchDone
                      add     di, 34     ; Length of IPT entry
                      inc     dh         ; Partition number +1
                      dec     dl         ; One partition less to look for
                      jnz     CmdLine_RebootToSearchLoop
                  CmdLine_RebootToSearchDone:
                   mov     bl, ds:[di+17] ; Get "Flags"
                pop     di es cx
                or      dl, dl           ; If no partitions left -> not found
                jz      CmdLine_RebootToNotFound
                test    bl, 1b           ; Check, if that's bootable
                jz      CmdLine_RebootToNotBootable
                ; Remember partition number for later
                mov     DoDirectBootPart, dh
                or      cx, cx           ; Nothing left on commandline? -> Done
                jz      CmdLine_Done
                jmp     CmdLine_NextChar
               CmdLine_RebootToNotFound:
                mov     si, offset TXT_ERROR_PartNotFound
                call    MBR_Teletype
                jmp     GoByeBye
               CmdLine_RebootToNotBootable:
                mov     si, offset TXT_ERROR_NotBootable
                call    MBR_Teletype
                jmp     GoByeBye

               CmdLine_BadParm:
                mov     si, offset TXT_ERROR_BadParm
                call    MBR_Teletype
                jmp     GoByeBye

               CmdLine_Done:
                ; Set ES back again to DS
                mov     ax, ds
                mov     es, ax

                mov     dl, 1            ; DL shows if anything was changed

                test    DoSetTimer, 1
                jz      NoSetTimer
                mov     al, DoSetTimerValue
                or      al, al
                jz      SetTimerDisableBootmenu
                ; Set Value [TimedBoot:BYTE] to 1 to enable Timed Boot
                mov     bptr ds:[TrackZero+6C00h+26], 1
                ; Set Value [TimedSeconds:BYTE]
                mov     bptr ds:[TrackZero+6C00h+27], al
                jmp     DoneSetTimer
               SetTimerDisableBootmenu:
                ; Set Value [BootMenuActive:BYTE] to 0 to disable boot menu
                mov     bptr ds:[TrackZero+6C00h+34], 0
               DoneSetTimer:
                xor     dl, dl
               NoSetTimer:

                test    DoUnSetTimer, 1
                jz      NoUnSetTimer
                ; Set Value [TimedBoot:BYTE] to 0 to disable Timed Boot
                mov     bptr ds:[TrackZero+6C00h+26], 0
                xor     dl, dl
               NoUnSetTimer:

                test    DoDirectBoot, 1
                jz      NoDirectBoot
                ; Set Value [AutomaticBoot:BYTE] to 1 to enable direct boot
                mov     bptr ds:[TrackZero+6C00h+170], 1
                mov     al, DoDirectBootPart
                ; Set Value [AutomaticPartition:BYTE] to selection
                mov     bptr ds:[TrackZero+6C00h+171], al
                xor     dl, dl
               NoDirectBoot:

                or      dl, dl
                jnz     NothingChanged
                ; Save configuration here...
                ;  Update counter first...
                add     wptr ds:[TrackZero+6C00h+16], 1
                adc     wptr ds:[TrackZero+6C00h+18], 0
                ; Now update checksum...
                mov     si, offset TrackZero+6C00h
                ; Save Config-Checksum in DX and kill it in [TrackZero]
                xor     bx, bx
                mov     cx, 5            ; Total of 5 sectors
                push    si
                  SaveConfig_CheckSumLoop:
                      call    MBR_GetCheckOfSector
                   loop    SaveConfig_CheckSumLoop
                pop     si
                mov     wptr ds:[si+20], bx
                mov     ax, cs
                mov     es, ax           ; Make sure that ES is right
                mov     bx, si
                mov     dx, 0080h        ; First harddrive, Sector 55...
                mov     cx, 0037h
                mov     ax, 0305h        ; Function 03, 5 sectors to write
                int     13h
                jnc     ConfigUpdated
                mov     si, offset TXT_ERROR_IO
                call    MBR_Teletype
                jmp     GoByeBye
               ConfigUpdated:
                mov     si, offset TXT_ConfigUpdated
                call    MBR_Teletype
               NothingChanged:

                test    DoReboot, 1
                jz      NoReboot
                mov     si, offset TXT_NowRebooting
                call    MBR_Teletype
                mov     ax, 8600h
                mov     cx, 65
                xor     dx, dx
                int     15h              ; Wait a little bit...
                db      0EAh             ; Jump to eternity
                dw      0FFF0h
                dw      0F000h
               NoReboot:

GoByeBye:       mov     ax, 4C00h
                int     21h              ; Terminate us...
                ; End-Of-Code

;        In: BX - Base Check, DS:SI - Pointer to 512-byte-area to be included
;       Out: BX - Base Check Result
; Destroyed: SI will get updated (+512)
MBR_GetCheckOfSector         Proc Near   Uses ax cx
   mov     cx, 256
  MBR_GetCheckOfSector_Loop:
      lodsw
      xor     ax, 0BABEh
      xor     bx, ax
   loop    MBR_GetCheckOfSector_Loop
   or      bx, bx
   jnz     MBR_GetCheckOfSector_NoFixUp
   mov     bx, 1                         ; dont allow 0, cause 0 means "empty"
  MBR_GetCheckOfSector_NoFixUp:
   ret
MBR_GetCheckOfSector         EndP

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

;        In: AL - Single char to type to screen
; Destroyed: *nothing*
MBR_TeletypeSingle              Proc Near   Uses ax bx
   mov     ah, 0Eh
   mov     bx, 7
   int     10h
   ret
MBR_TeletypeSingle              EndP

;        In: AL - BCD-number to type to screen
; Destroyed: *nothing*
MBR_TeletypeNumber              Proc Near   Uses ax bx
   mov     ah, al
   and     ah, 0Fh
   shr     al, 4
   add     ax, 3030h
   cmp     al, 30h
   je      MBR_TTN_SkipDigit
   call    MBR_TeletypeSingle
  MBR_TTN_SkipDigit:
   mov     al, ah
   call    MBR_TeletypeSingle
   ret
MBR_TeletypeNumber              EndP

;        In: AL - BCD-number to type to screen (full 2 digits everytime)
; Destroyed: *nothing*
MBR_TeletypeNumber2             Proc Near   Uses ax bx
   mov     ah, al
   and     ah, 0Fh
   shr     al, 4
   add     ax, 3030h
   call    MBR_TeletypeSingle
   mov     al, ah
   call    MBR_TeletypeSingle
   ret
MBR_TeletypeNumber2             EndP

InstalledVersion_Code   dw ?
InstalledVersion_Config dw ?
TrackZero:              db      30976 dup (?)

code_seg	ends
		end	air_boot_setup
