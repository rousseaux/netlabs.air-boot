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

; This file is included by various sources, it expects CS==DS and
;  ES is supposed to point to an area, where it's possible to put track 0
;  of the current harddrive 0 (around 32000 bytes). That way it's possible to
;  reuse this main code in multiple projects.

; Currently used by AiR-BOOT Installer for DOS
;                   AiR-BOOT Installer for Floppy (and bootable CD-ROM image)

RunInstaller:   ; -------------------------------------------> Verify our image
                call    Init_VerifyImage

                ; -------------------------------------------> Load current MBR
                call    Init_CheckHarddisc
                jc      SkipLoadTrack0
                mov     si, offset TXT_START_LoadMBR
                call    APIShowMessage
                call    APILockVolume
                call    Init_LoadTrackZero
                mov     si, offset TXT_Okay
                call    APIShowMessage

                ; ---------------------------------> Verify Code/Data integrity
SkipLoadTrack0: mov     si, offset TXT_STATUS_Main
                call    APIShowMessage

                call    Init_VerifyCode
                mov     al, iStatus_Code
                mov     dx, InstalledVersion_Code
                call    Init_ShowStatus

                mov     si, offset TXT_STATUS_Config
                call    APIShowMessage
                call    Init_VerifyConfig
                mov     al, iStatus_Config
                mov     dx, InstalledVersion_Config
                call    Init_ShowStatus

                ; Display language as well, if Code installed
                mov     al, iStatus_Code
                cmp     al, Status_Installed
                je      ShowLanguage
                cmp     al, Status_InstalledMGU
                jne     SkipShowLanguage
ShowLanguage:   mov     si, offset TXT_STATUS_Language
                call    APIShowMessage
                mov     al, InstalledLanguageID
                call    Init_ShowLanguage
                mov     si, offset TXT_CR
                call    APIShowMessage

SkipShowLanguage:
                cmp     iStatus_Code, Status_Impossible
                jne     InstPossible
                call    APIExitProgram

                ; ---------------------------------------> Analyse installation
InstPossible:   cmp     Option_ForceCode, 1
                je      CodeInstallNeeded
                cmp     iStatus_Code, Status_Installed
                jne     CodeInstallNeeded
                ; So we got Code installed - is it up-to-date?
                mov     al, InstalledLanguageID
                cmp     al, ImageLanguageID
                je      NoCodeNeeded
                ; If Language-ID is the same -> No install needed
CodeInstallNeeded:
                mov     Install_Code, 1     ; Not/Corrupt/Update

NoCodeNeeded:   cmp     Option_ForceConfig, 1
                je      ConfigInstallNeeded
                cmp     iStatus_Config, Status_Installed
                je      NoConfigNeeded
ConfigInstallNeeded:
                mov     Install_Config, 1   ; Not/Corrupt
NoConfigNeeded: mov     al, 1
                cmp     iStatus_Code, Status_Corrupt
                je      WonderfulCorrupt
                cmp     iStatus_Config, Status_Corrupt
                je      WonderfulCorrupt
                xor     al, al
WonderfulCorrupt:
                mov     Install_IsCorrupt, al

                ; --------------------------------------------> Virus detection
                ;  Check-Table:
                ; --------------
                ; Code==Not Installed, Config==Not Installed => Check MBR
                ; Code==Installed, Config==Installed => Check MBR (->Virus?)
                ; Code==Not Installed, Config==Installed => (->Virus?)
                ; Code==Installed, Config==Not Installed => Check MBR (->Virus?)
                cmp     iStatus_Code, Status_NotInstalled
                jne     FoundInstall
                cmp     iStatus_Config, Status_NotInstalled
                jne     FoundInstall
                ; Nothing Found, so Check MBR, if squashed simply stop system
                call    Init_CheckCurrentMBR
                jnc     VirusSkip           ; Skip Virus-Stuff Code
                ; AiR-BOOT 100% not found and Partition Table broken
                mov     si, offset TXT_MBRfail_Argh
                call    APIShowMessage
                call    APIExitProgram

FoundInstall:   cmp     iStatus_Code, Status_NotInstalled
                je      VirusPossible
                ; Just check MBR...if squashed show up virus and check for backup
SimplyCheckMBR: call    Init_CheckCurrentMBR
                jnc     VirusSkip

                ; Virus Proposed to have squashed the MBR, perhaps backup is
                ; available, so check for it.
VirusPossible:  mov     si, offset TXT_Virus_Main
                call    APIShowMessage
                call    Init_CheckForStealthVirus
                jz      StealthVirusPossible
                mov     si, offset TXT_Virus_Normal
                call    APIShowMessage
                jmp     VirusWarning
StealthVirusPossible:
                mov     si, offset TXT_Virus_Severe
                call    APIShowMessage

VirusWarning:   mov     si, offset TXT_Virus_Always
                call    APIShowMessage

                call    Init_CheckCurrentMBR
                jnc     VirusSkip
                mov     si, offset TXT_MBRfail_Normal
                call    APIShowMessage
                call    Init_CheckBackupMBR
                jc      VirusNoBackUp
                mov     si, offset TXT_MBRfail_Strike
                call    APIShowMessage
VirusKeyLoop:      call    APIReadKeyboard
                   or      al, 20h                     ; Lower-Case Input
                   cmp     al, 'y'
                   je      VirusRestoreYes
                   cmp     al, 'z'
                   je      VirusRestoreYes
                   cmp     al, 'n'
                   je      VirusRestoreNo
                   jmp     VirusKeyLoop

VirusRestoreYes:call    Init_CopyBackupMBR
VirusRestoreNo: jmp     VirusSkip

VirusNoBackup:  mov     si, offset TXT_MBRfail_Buuuhh
                call    APIShowMessage
VirusSkip:

                ; --------------------------------------------------> Main-Menu
                mov     si, offset TXT_MENU_Main
                call    APIShowMessage
                mov     si, offset TXT_MENU_Repair
                test    Install_IsCorrupt, 1
                jnz     MenuShowMessage
                mov     si, offset TXT_MENU_Add
                cmp     iStatus_Code, Status_NotInstalled
                je      MenuShowMessage
                mov     si, offset TXT_MENU_Update
MenuShowMessage:call    APIShowMessage

                mov     dx, ImageVersion
                mov     al, dh
                call    ShowNumber
                mov     al, '.'
                call    APIShowChar
                mov     al, dl
                call    ShowNumber2
                mov     al, '/'
                call    APIShowChar
                mov     al, ImageLanguageID
                call    Init_ShowLanguage
                mov     si, offset TXT_MENU_OnCurSystem
                call    APIShowMessage

                mov     si, offset TXT_MENU_Delete
                call    APIShowMessage
                mov     si, offset TXT_MENU_Quit
                call    APIShowMessage

                ; Silent operation? Always add AiR-BOOT to system
                cmp     Option_Silent, 1
                je      MenuProcessADD

MenuKeyLoop:       call    APIReadKeyboard
                   or      al, 20h          ; Lower-Case Input
                   cmp     al, 'a'
                   je      MenuProcessADD
                   cmp     al, 'r'
                   je      MenuProcessADD
                   cmp     al, 'u'
                   je      MenuProcessADD
                   cmp     al, 'd'
                   je      MenuProcessDELETE
                   cmp     al, 'q'
                   je      MenuProcessQUIT
                   jmp     MenuKeyLoop

MenuProcessADD: mov     si, offset TXT_PROCESS_Split
                call    APIShowMessage
                call    ProcessADD
                mov     si, offset TXT_AfterAdd
                call    APIShowMessage
                call    MenuWaitForENTER
                call    APIAfterAdd

MenuProcessDELETE:
                mov     si, offset TXT_PROCESS_Split
                call    APIShowMessage
                mov     si, offset TXT_DELETE_NotPossible
                call    APIShowMessage
                mov     si, offset TXT_AfterDelete
                call    APIShowMessage
                call    MenuWaitForENTER
                call    APIAfterDelete

MenuProcessQUIT:mov     si, offset TXT_AfterQuit
                call    APIShowMessage
                call    MenuWaitForENTER
                call    APIAfterQuit

MenuWaitForEnter               Proc Near  Uses
   cmp     Option_Silent, 1
   je      MWFE_Skip
  MWFE_Loop:
   call    APIReadKeyboard
   cmp     al, 0Dh
   jne     MWFE_Loop
  MWFE_Skip:
   ret
MenuWaitForEnter               EndP

ProcessADD                     Proc Near  Uses
   mov     si, offset TXT_PROCESS_Add
   call    APIShowMessage
   xor     di, di
   test    Install_Code, 1
   ; ALLTIME ADD - For Debugging Purposes (Remark next line)
   IFNDEF DebugVersion
      jz      MPA_NoCode
   ENDIF
   mov     si, offset TXT_ADD_Code
   call    APIShowMessage
   call    InstallCode
   mov     si, offset TXT_Okay
   call    APIShowMessage
   inc     di
  MPA_NoCode:
   test    Install_Config, 1
   jz      MPA_NoConfig
      mov     si, offset TXT_ADD_Config
      call    APIShowMessage
      call    InstallConfig
      mov     si, offset TXT_Okay
      call    APIShowMessage
      inc     di
  MPA_NoConfig:
   or      di, di
   jz      MPA_NothingDone
   mov     si, offset TXT_ADD_SetupOkay
   call    APIShowMessage
   ret

  MPA_NothingDone:
   mov     si, offset TXT_ADD_NothingToDo
   call    APIShowMessage
   ret
ProcessADD                     EndP

InstallCode                    Proc Near  Uses
   ; Calculates new code checksum...
   mov     si, offset BootImage+512  ; Sector 2 (Start of Code-Image)
   xor     bx, bx
   movzx   cx, bptr ds:[BootImage+0010h] ; Total sectors used (hard-coded)
 IC_CalcCodeLoop:
      call    GetCheckOfImageSector
   loop    IC_CalcCodeLoop
   mov     wptr ds:[BootImage+0011h], bx ; set Checksum
   call    InstallCode_MergeMBRs     ; Merges BootCodeMBR and actual MBR
   ; -------------------------------------------------------------------------
   mov     cx, 0001h                 ; Cylinder 0, Sector 1
   mov     dx, 0080h                 ; Head 0, Drive 80 (MBR Write)
   mov     si, offset BootImage
   ; ...writes the new MBR...
   call    SaveImageSector

   ; ...and writes the following sectors...
   movzx   ax, bptr ds:[BootImage+0010h] ; Total sectors used
   or      ax, ax
   jz      IC_NoSectors
  IC_WriteCodeLoop:
      call    SaveImageSector
   dec     ax
   jnz     IC_WriteCodeLoop
  IC_NoSectors:
   ret
InstallCode                    EndP

InstallCode_MergeMBRs          Proc Near  Uses ds si es di
   push    ds es
   pop     ds es                     ; Exchange DS&ES, DS==HDD, ES==New BootCode
   xor     si, si
   mov     di, offset BootImage
   add     si, 1B8h                      ; 1B8h - Windoze NT Mickeysoft hdd signature
   add     di, 1B8h                      ; 1BEh - Real Partition Table start
   mov     cx, 72                        ; 66 without Mickeysoft signature
   rep     movsb                         ; Copies parition table and NT signature
   ret
InstallCode_MergeMBRs          EndP

InstallConfig                  Proc Near  Uses
   ; Calculate new Config-CheckSum
   mov     si, offset BootImage+6C00h    ; Configuration location
   mov     wptr ds:[si+20], 0            ; delete current CheckSum
   xor     bx, bx

   ;mov     cx, 7     ; Rousseau: changed to 7 for v1.0.7+

   ; Rousseau: Changed back to 5 to be compatible with the v1.07 OS/2 and WIN
   ; installers AIRBOOT2.EXE and AIRBOOTW.EXE dat do a CRC over 5 sectors.
   mov     cx, 5

  IC_CalcConfigLoop:
      call    GetCheckOfImageSector
   loop    IC_CalcConfigLoop
   mov     wptr ds:[BootImage+6C00h+20], bx ; new checksum set
   ; -------------------------------------------------------------------------
   mov     cx, 0037h                 ; Cylinder 0, Sektor 55
   mov     dx, 0080h                 ; Head 0, Drive 80 (CONFIG Write)
   mov     si, offset BootImage+6C00h ; Config-Location

   call    SaveImageSector           ; Configuration                (sec 55)

   ; Rousseau: Added 2 extra SaveImageSector calls for the v1.07+
   ; 45-partition version.
   ; Note the MBR backup at sector 62 (LBA 61).
   call    SaveImageSector           ; Partition Table part 1       (sec 56)
   call    SaveImageSector           ; Partition Table part 2       (sec 57)
   call    SaveImageSector           ; Partition Table part 3       (sec 58)

   call    SaveImageSector           ; Hide-Partition Table part 1  (sec 59)
   call    SaveImageSector           ; Hide-Partition Table part 2  (sec 60)
   call    SaveImageSector           ; Hide-Partition Table part 3  (sec 61)

   call    SaveImageSector           ; MBR BackUp                   (sec 62)

   ret
InstallConfig                  EndP



;       Out: Carry Flag SET if Harddisc failed 62-sectors test
Init_CheckHarddisc             Proc Near  Uses
   mov     ah, 08h
   mov     dl, 80h
   int     13h
   and     cl, 111111b
   cmp     cl, 62
   jae     INITCH_Success
   stc
   ret
  INITCH_Success:
   clc
   ret
Init_CheckHarddisc             EndP

;        In: CH = Cylinder, CL = Sector, ES:BX = Sector Ptr
;            DH = Head, DL = Drive
LoadHDDSector                  Proc Near  Uses ax es
  LHDDS_Retry:
   push    bx cx dx
      mov     ax, 0201h  ; load one sector
      int     13h
      jnc     LHDDS_Success
      xor     ah, ah
      xor     dl, dl
      int     13h              ; BIOS: READ SECTOR VIA CHS
   pop     dx cx bx
   jmp     LHDDS_Retry
  LHDDS_Success:
   pop     dx cx bx
   add     bx, 512
   inc     cl               ; sector fixing must be done manual
   ret
LoadHDDSector                  EndP

;        In: CH = Cylinder, CL = Sector, DS:SI = Sector Ptr
;            DH = Head, DL = Drive
SaveImageSector                Proc Near  Uses ax bx dx es
   push    ds
   pop     es                            ; ES==DS -> bootcode image segment
   mov     bx, si                        ; ES:BX - sector buffer to write
  SIS_Retry:
   push    bx cx dx
      mov     ax, 0301h
      int     13h                        ; BIOS: WRITE SECTOR
      jnc     SIS_Success
      mov     ah, 00h    ; reset disc
      mov     dl, 00h
      int     13h
   pop     dx cx bx
   jmp     SIS_Retry
  SIS_Success:
   pop     dx cx bx
   add     si, 512                       ; go to next sector
   inc     cl                            ; add 1 to sector
   ret
SaveImageSector                EndP

;        In: BX - Base Check, ES:SI - Pointer to 512-byte-area to be included
;       Out: BX - Base Check Result
; Destroyed: SI will get updated (+512)
GetCheckOfHDDSector          Proc Near   Uses ds
   push    es
   pop     ds                            ; DS now points to HDD Track 0
   call    GetCheckOfImageSector
   ret
GetCheckOfHDDSector          EndP

;        In: BX - Base Check, DS:SI - Pointer to 512-byte-area to be included
;       Out: BX - Base Check Result
; Destroyed: SI will get updated (+512)
GetCheckOfImageSector          Proc Near   Uses ax cx
   mov     cx, 256
  GCOIS_Loop:
      lodsw
      xor     ax, 0BABEh
      xor     bx, ax
   loop    GCOIS_Loop
   or      bx, bx
   jnz     GCOIS_NoFixUp
   mov     bx, 1                         ; dont allow 0, cause 0 means "empty"
  GCOIS_NoFixUp:
   ret
GetCheckOfImageSector          EndP

Init_LoadTrackZero             Proc Near  Uses ES
   xor     bx, bx                        ; ES:0 - Ptr to load current track-0
   mov     cx, 0001h                     ; Cylinder 0, Sektor 1
   mov     dx, 0080h                     ; Head 0, Drive 80
  INITLTZ_Loop:
      call    LoadHDDSector
   cmp     cl, 63
   jne     INITLTZ_Loop
   ret
Init_LoadTrackZero             EndP

; al - type to display text
; dx - version number
Init_ShowStatus                Proc Near  Uses si
   cmp     al, Status_Corrupt
   jb      ISSV_NotInstalled
   je      ISSV_Corrupt
   cmp     al, Status_Impossible
   je      ISSV_Impossible
   ; --- Intact (and possibly Update-able)
   push    ax
      mov     si, offset TXT_STATUS_Intact
      call    APIShowMessage
      ; Include version number...
      mov     al, dh
      call    ShowNumber
      mov     al, '.'
      call    APIShowChar
      mov     al, dl
      call    ShowNumber2
      mov     al, ')'
      call    APIShowChar
   pop     ax
   cmp     al, Status_InstalledMGU
   jne     ISSV_NoMGU
   mov     si, offset TXT_STATUS_Update
   call    APIShowMessage
  ISSV_NoMGU:
   jmp     ISSV_End

  ISSV_NotInstalled:
   mov     si, offset TXT_STATUS_ninstall
   jmp     ISSV_EndWithTeletype
  ISSV_Corrupt:
   mov     si, offset TXT_STATUS_nintact
   jmp     ISSV_EndWithTeletype
  ISSV_Impossible:
   mov     si, Impossible_Cause
  ISSV_EndWithTeletype:
   call    APIShowMessage
  ISSV_End:
   mov     si, offset TXT_CR
   call    APIShowMessage
   ret
Init_ShowStatus                EndP

; al - Language ID
Init_ShowLanguage              Proc Near  Uses si
   cmp     al, 'E'
   mov     si, offset TXT_Language_EN
   je      ISL_Done
   cmp     al, 'D'
   mov     si, offset TXT_Language_NL
   je      ISL_Done
   cmp     al, 'G'
   mov     si, offset TXT_Language_DE
   je      ISL_Done
   cmp     al, 'F'
   mov     si, offset TXT_Language_FR
   je      ISL_Done
   cmp     al, 'I'
   mov     si, offset TXT_Language_IT
   je      ISL_Done
   cmp     al, 'R'
   mov     si, offset TXT_Language_RU
   je      ISL_Done
   cmp     al, 'S'
   mov     si, offset TXT_Language_SW
   je      ISL_Done
   mov     si, offset TXT_Language_Huh    ; Unknown to us
  ISL_Done:
   call    APIShowMessage
   ret
Init_ShowLanguage              EndP

;        In: AL - BCD-number to type to screen
; Destroyed: *nothing*
ShowNumber                     Proc Near   Uses ax bx
   mov     ah, al
   and     ah, 0Fh
   shr     al, 4
   add     ax, 3030h
   cmp     al, 30h
   je      SN_SkipDigit
   call    APIShowChar
  SN_SkipDigit:
   mov     al, ah
   call    APIShowChar
   ret
ShowNumber                     EndP

;        In: AL - BCD-number to type to screen (full 2 digits everytime)
; Destroyed: *nothing*
ShowNumber2                    Proc Near   Uses ax bx
   mov     ah, al
   and     ah, 0Fh
   shr     al, 4
   add     ax, 3030h
   call    APIShowChar
   mov     al, ah
;   cmp     al,'8'
;   jb      ShowNumber2_skip_dot
   ; Display separation dot
   push    ax
   mov     al,'.'
   call    APIShowChar
   pop     ax
;  ShowNumber2_skip_dot:
   call    APIShowChar
   ret
ShowNumber2                    EndP

; Verifies our bootcode installation image
Init_VerifyImage               Proc Near   Uses
   ; First we verify the image, this is done by using the same checksum method
   ;  as on real harddrive images. This is mainly for detecting, that we are
   ;  really seeing an AiR-BOOT image and not some other data file.

   ; Identifies image...
   mov     ax, wptr ds:[BootImage+000Dh] ; Version of Image
   xchg    al, ah
   mov     ImageVersion, ax
   mov     al, bptr ds:[BootImage+000Fh] ; Language ID of Image
   mov     ImageLanguageID, al
   ret
Init_VerifyImage               EndP

; Verifies existing code-image from current HDD...
Init_VerifyCode                Proc Near  Uses ds si es di
   call    Init_CheckHarddisc
   jnc     IVC_HarddiscOK
   mov     iStatus_Code, Status_Impossible
   mov     Impossible_Cause, offset TXT_STATUS_Hd2Small
   ret

  IVC_HarddiscOK:
   call    Init_CheckForEZSETUP
   jne     IVC_NoEZSETUP
   mov     iStatus_Code, Status_Impossible
   mov     Impossible_Cause, offset TXT_STATUS_EZSETUP
   ret

  IVC_NoEZSETUP:
   mov     si, offset MBR_AiRBOOTCodeSig
   ; Check Master-Boot-Record Signature
   cmp     wptr es:[01FEh], 0AA55h
   jne     IVC_NotInstalled
   ; Check AiR-BOOT String...
   mov     di, 2
   mov     cx, MBR_AiRBOOTCodeSigLen
   repe    cmpsb
   je      IVC_IDfound
  IVC_NotInstalled:
   ; No AiR-BOOT MBR Image found...
   mov     iStatus_Code, Status_NotInstalled
   ret

  IVC_IDfound:
   ; Check actual Code
   movzx   cx, bptr es:[0010h]            ; Total-Code-Sectors-Used
   mov     si, 512
   xor     bx, bx
  IVC_CheckSumLoop:
      call    GetCheckOfHDDSector
   loop    IVC_CheckSumLoop
   cmp     bx, wptr es:[0011h]
   je      IVC_CheckSumOK
   mov     iStatus_Code, Status_Corrupt
   ret

  IVC_CheckSumOK:
   mov     al, es:[000Fh]                 ; Current Language ID
   mov     InstalledLanguageID, al
   mov     cx, es:[000Dh]                 ; Current Version ID
   mov     dx, ImageVersion               ; My Image Version ID
   xchg    ch, cl
   mov     InstalledVersion_Code, cx      ; remember installed code version
   cmp     cx, dx                         ; If version number in image is higher
   jb      IVC_MGU                        ;  -> Upgradeable
   mov     iStatus_Code, Status_Installed
   ret
  IVC_MGU:
   mov     iStatus_Code, Status_InstalledMGU
   ret
Init_VerifyCode                EndP

Init_CheckForEZSETUP           Proc Near  Uses
   mov     si, offset MBR_EZSETUPCodeSig
   mov     di, 8Fh
   mov     cx, MBR_EZSETUPCodeSigLen
   repe    cmpsb
   ret
Init_CheckForEZSETUP           EndP

Init_VerifyConfig              Proc Near  Uses ds si es di
   ; First check for current Config-Format...
   mov     si, offset MBR_AiRBOOTConfigSig
   mov     di, 6C00h                     ; Sector 55
   mov     cx, MBR_AiRBOOTConfigSigLen
   repe    cmpsb
   jne     IVC_CheckPrior026
   mov     si, 6C00h                     ; Sector 55
   mov     dx, wptr es:[si+20]           ; DX - Current Checksum
   mov     wptr es:[si+20], 0            ; Kills current Checksum
   xor     bx, bx

   ;mov     cx, 7                         ; Total of 7 Sectors
                                         ; Rousseau: changed above to 7
   ; Rousseau: Changed back to 5 to be compatible with the v1.07 OS/2 and WIN
   ; installers AIRBOOT2.EXE and AIRBOOTW.EXE dat do a CRC over 5 sectors.
   mov     cx, 5

  IVC_CheckSumLoop2:
      call    GetCheckOfHDDSector
   loop    IVC_CheckSumLoop2
   cmp     bx, dx
   je      IVC_CheckSumOK2
   mov     iStatus_Config, Status_Corrupt
   ret
  IVC_CheckSumOK2:
   ; DS == New BootCode, ES == HDD
   mov     cx, es:[6C0Dh]
   mov     ax, wptr ds:[BootImage+6C0Dh]
   xchg    cl, ch
   xchg    al, ah
   mov     InstalledVersion_Config, cx   ; remember installed config version
   cmp     cx, ax
   jb      IVC_UpgradeConfig
   mov     iStatus_Config, Status_Installed
   jmp     IVC_NoUpgradeConfig
   ; ==========================================================================
   ;  Those Upgrades will copy useful configuration data to the Image Config
   ;  If new configuration data was added, those spaces are not overwritten.
   ;  Sector 60 (MBR-BackUp) *MUST BE* copied, otherwise it's lost.
   ; ==========================================================================
  IVC_UpgradeConfig:
   mov     iStatus_Config, Status_InstalledMGU
  IVC_NoUpgradeConfig:
   ; We exchange DS and ES, be careful from now on!
   push    ds es
   pop     ds es                         ; DS = HDD, ES = BootCode
   cmp     cx, 0027h
   jbe     IVC_Upgrade027
   cmp     cx, 0091h
   jbe     IVC_Upgrade091
   ; If we don't need to "upgrade" the configuration, we simply copy it over.
   mov     si, 6C00h+16                  ; Sector 55 (never copy header/version)
   mov     di, si
   add     di, offset BootImage
   mov     cx, (3072-16)/2               ; Copy all 6 sectors w/o modification
   rep     movsw
   ; DS&ES will get restored here
   ret

   ; ----------------------------------------- UPGRADE v0.27 and prior versions
  IVC_Upgrade027:
   mov     si, 6C00h+16                  ; Sector 55 (never copy header/version)
   mov     di, si
   add     di, offset BootImage
   mov     cx, (69-16)
   rep     movsb
   ; Changes: Sector 55 - Offset  69 Length 75 - Linux Command Line
   ;                      Offset 144 Length  1 - Linux Kernel Partition
   ;                      Offset 145 Length 11 - Default Kernel Name
   ;                      Offset 156 Length  1 - Kernel Name Terminator 1
   ;                      Offset 157 Length 11 - Last Kernel Name
   ;                      Offset 168 Length  1 - Kernel Name Terminator 2
   ;                      Offset 169 Length  1 - Ext. Partition M$-Hack Enable
   ;                       -> Total-Length 101
   ; Changes: Sector 55 - Offset 432 Length 34 - New IPT entry (BIOS continued)
   add     si, 101+262+34
   add     di, 101+262+34
   mov     cx, 46/2
   rep     movsw                         ; Copy remaining of sector 55
   mov     cx, 1924/2
   rep     movsw                         ; Copy sectors 56-57 & Hide-Config
   ; Changes: Sector 59 - Offset 388 Length 30 - Logical-Drive-Letter Table
   add     si, 124
   add     di, 124
   mov     cx, 512/2
   rep     movsw                         ; Copy sector 60 unmodified
   ; DS&ES will get restored here
   ret

   ; ----------------------------------------- UPGRADE v0.91 and prior versions
  IVC_Upgrade091:
   mov     si, 6C00h+16                  ; Sector 55 (never copy header/version)
   mov     di, si
   add     di, offset BootImage
   mov     cx, (512-16)/2
   rep     movsw                         ; Copy sector 55
   mov     cx, 1924/2
   rep     movsw                         ; Copy sectors 56-57 & Hide-Config
   ; Changes: Sector 59 - Offset 388 Length 30 - Logical-Drive-Letter Table
   add     si, 124
   add     di, 124
   mov     cx, 512/2
   rep     movsw                         ; Copy sector 60 unmodified
   ; DS&ES will get restored here
   ret

   ; ==========================================================================
   ; Check for Prior 0.26b format...
  IVC_CheckPrior026:
   mov     si, offset MBR_AiRBOOTConfigSig
   mov     di, 7000h                   ; Sector 57
   mov     cx, MBR_AiRBOOTConfigSigLen
   repe    cmpsb
   je      IVC_PriorIDfound
   ; kein AiR-BOOT MBR Image gefunden
   mov     iStatus_Config, Status_NotInstalled
   ret
  IVC_PriorIDfound:
   mov     si, 7000h
   mov     dx, wptr es:[si+20]           ; DX - jetzige Checksum
   mov     wptr es:[si+20], 0            ; l”scht jetzige Checksum
   xor     bx, bx
   mov     cx, 3                         ; Total of 3 Sectors
  IVC_PriorCheckSumLoop:
      call    GetCheckOfHDDSector
   loop    IVC_PriorCheckSumLoop
   cmp     bx, dx
   je      IVC_PriorCheckSumOK
   mov     iStatus_Config, Status_Corrupt
   ret
  IVC_PriorCheckSumOK:
   mov     iStatus_Config, Status_InstalledMGU
   ; ==========================================================================
   ; Now convert Pre-0.26b-configuration layout to new one.
   ;  Sector 57-59 containing Base-Config and IPT are compatible but have to
   ;  get moved to Sector 55-57 and Hide-Configuration has to be taken from
   ;  Image-default-configuration.
   ; After that a normal version upgrade will be performed additionally.
   ; ==========================================================================
   ; Exchange DS and ES, so DS == HDD and ES == New BootCode
   push    ds es
   pop     ds es
   mov     si, 7000h                     ; Current - Sector 57 (Prior config)
   mov     di, 6C00h                     ; -> Current - Sector 55 (cur. config)
   mov     cx, 768                       ; Total of 3 sectors...
   rep     movsw
   mov     si, 7200h                     ; Image - Sector 58 (Hide-Config)
   mov     cx, 512                       ; Total of 2 sectors...
   rep     movsw
   ; Exchange DS and ES again, so state is normal...
   push    ds es
   pop     ds es
   jmp     IVC_CheckSumOK         ; Resume to upgrade config more
Init_VerifyConfig              EndP

; Carry set, if invalid MBR
Init_CheckCurrentMBR           Proc Near  Uses si
   xor     si, si
   call    Init_CheckThisMBR
   ret
Init_CheckCurrentMBR           EndP

; Carry set, if invalid BackUp
Init_CheckBackupMBR            Proc Near  Uses si
   mov     si, 7600h                     ; Fixed location of backup
   call    Init_CheckThisMBR
   ret
Init_CheckBackupMBR            EndP

; Internal
Init_CheckThisMBR              Proc Near  Uses
   cmp     wptr es:[si+01FEh], 0AA55h
   jne     ICTM_InvalidMBR
   xor     cx, cx                        ; No entries checked
   xor     dx, dx                        ; No entries in MBR
   add     si, 446                       ; Auf start Partition table seeken
  ICTM_PartitionLoop:
      mov     al, es:[si+3]              ; Cylinder
      mov     ah, es:[si+2]
      shr     ah, 6                      ; oberen Bits von Cylinder
      shl     eax, 16                    ; bringt Cylinder nach EAX[16-31]
      mov     ah, es:[si+1]              ; Seite nach EAX[8-15]
      mov     al, es:[si+2]
      and     al, 111111b                ; Sektor nach EAX[0-7]
      ; Anfangs-Wert fertig
      mov     bl, es:[si+7]              ; Cylinder
      mov     bh, es:[si+6]
      shr     bh, 6                      ; oberen Bits von Cylinder
      shl     ebx, 16                    ; bringt Cylinder nach EAX[16-31]
      mov     bh, es:[si+5]              ; Seite nach EAX[8-15]
      mov     bl, es:[si+6]
      and     bl, 111111b                ; Sektor nach EAX[0-7]
      ; Anfangs-Wert fertig
      cmp     eax, ebx                   ; vergleichen, falls Begin kleiner
      ja      ICTM_InvalidMBR

      inc     cx
      cmp     bptr es:[si+4], 0          ; nur falls was definiert ist
      je      ICTM_ValidButNone
      cmp     wptr es:[si+14], 0         ; Absolute mit 0 vergleichen,
      jne     ICTM_ValidOne              ; falls ==0 -> Fehlerhaft
      cmp     wptr es:[si+12], 0
      je      ICTM_InvalidMBR
     ICTM_ValidOne:
      inc     dx
     ICTM_ValidButNone:
      add     si, 16
   cmp     cx, 4
   jne     ICTM_PartitionLoop
   cmp     dx, 1
   jb      ICTM_InvalidMBR
   clc
   ret
  ICTM_InvalidMBR:
   stc
   ret
Init_CheckThisMBR              EndP

; Copies BackUp MBR into current MBR area, so it will get installed
Init_CopyBackupMBR             Proc Near  Uses ds si es di
   push    ds es
   pop     ds es                         ; Exchange DS&ES so DS==HDD, ES==New BootCode
   mov     si, 7600h                     ; Sector 60...
   mov     di, offset BootImage          ;  -> to Sector 1 of New BootCode
   mov     cx, 256
   rep     movsw                         ; Copies 1 sector...
   ret
Init_CopyBackupMBR             EndP

Init_CheckForStealthVirus      Proc Near  Uses ds si es di
   xor     si, si                        ; ES:SI - HDD (MBR)
   xor     bx, bx
  ICFSV_CheckLoop:
      cmp     si, 512
      ja      ICFSV_EndLoop
      mov     al, es:[si]
      inc     si
      cmp     al, 0CDh
      jne     ICFSV_CheckLoop
      cmp     bptr es:[si], 13h
      jne     ICFSV_CheckLoop
      inc     bx
      jmp     ICFSV_CheckLoop

  ICFSV_EndLoop:
   or      bx, bx                        ; Sets Zero-Flag if no CD 13hs found...
   ret
Init_CheckForStealthVirus      EndP

TXT_Okay                       db 'ok'
TXT_CR                         db 13, 10, 0

TXT_START_NoPhysicalDrives     db ' - No physical drives found on this system. Install impossible.', 13, 10, 0
TXT_START_LoadMBR              db ' - Loading Track-0 from harddisc...', 0
TXT_STATUS_Main                db 13, 10, 13, 10
                               db '-> ...Current Status... <-', 13, 10
TXT_STATUS_Code                db ' - AiR-BOOT is ', 0
TXT_STATUS_Config              db ' - Configuration is ', 0
TXT_STATUS_Language            db ' - Language is ', 0
TXT_STATUS_Intact              db 'intact (v', 0
TXT_STATUS_nintact             db 'not intact', 0
TXT_STATUS_ninstall            db 'not installed', 0
TXT_STATUS_Update              db ', but may be updated', 0
TXT_STATUS_Hd2Small            db 'unable to install', 13, 10
                               db '   Your harddisc does not have at least 62 sectors per track.', 0
TXT_STATUS_EZSETUP             db 'not willing to install', 13, 10
                               db '   Your harddisc contains EZ-SETUP.', 13, 10
                               db '   This program is required, so your computer is able to access the harddisc', 13, 10
                               db '   completly. Installation of AiR-BOOT would overwrite it.', 0
IFDEF Flat
   TXT_InstallHalted              db 'Installation halted.', 0
  ELSE
   TXT_SystemHalted               db 'System halted.', 0
ENDIF

TXT_Language_EN                db 'english', 0
TXT_Language_NL                db 'dutch', 0
TXT_Language_DE                db 'german', 0
TXT_Language_FR                db 'french', 0
TXT_Language_IT                db 'italian', 0
TXT_Language_RU                db 'russian', 0
TXT_Language_SW                db 'swedish', 0
TXT_Language_Huh               db 'unknown', 0

TXT_Virus_Main                 db 13, 10, 13, 10
                               db '-> ...!ATTENTION!... <-', 13, 10, 0
TXT_Virus_Normal               db 'Probably your system was infected by a virus.', 13, 10, 0
TXT_Virus_Severe               db 'Your system GOT infected by a stealth-virus (or your MBR got trashed).', 13, 10, 0
TXT_Virus_Always               db 'Repairing AiR-BOOT will normally squash the virus.', 13, 10
                               db 'But to be sure it''s gone, you should check your harddisc using a virus-scanner.', 13, 10, 0

TXT_MBRfail_Normal             db 13, 10
                               db 'AiR-BOOT detected that the virus has broken your partition-table.', 13, 10, 0
TXT_MBRfail_Strike             db 'Good news: AiR-BOOT has found a (hopefully) functional backup.', 13, 10
                               db 'Shall I use this backup, instead of the current active one ? (Y/N)', 13, 10, 0
TXT_MBRfail_Buuuhh             db 'Sadly the virus also broke AiR-BOOT''s backup. You will have to help yourself.', 13, 10, 0

TXT_MBRfail_Argh               db 13, 10, 13, 10
                               db 'AiR-BOOT detected that the data on your harddisc got damaged.', 13, 10
                               db 'If you had AiR-BOOT installed before: The corruption killed AiR-BOOT completly!', 13, 10, 0

TXT_MENU_Main                  db 13, 10, 13, 10
                               db '-> ...Please press... <-', 13, 10, 0
TXT_MENU_Add                   db ' <A> - Add AiR-BOOT ''v', 0
TXT_MENU_Repair                db ' <R> - Repair AiR-BOOT ''v', 0
TXT_MENU_Update                db ' <U> - Update/Change AiR-BOOT to ''v', 0
TXT_MENU_OnCurSystem           db ''' on current system', 13, 10, 0
TXT_MENU_Delete                db ' <D> - Delete AiR-BOOT from current system', 13, 10, 0
TXT_MENU_Quit                  db ' <Q> - Quit without any change', 13, 10, 0

TXT_PROCESS_Split              db 13, 10, 13, 10, 13, 10
                               db '-------------------------------------------------------------------------------', 13, 10, 0
TXT_PROCESS_Add                db 'Add/Repair/Update AiR-BOOT in progress...', 13, 10, 0

TXT_ADD_Code                   db ' þ Writing AiR-BOOT code...', 0
TXT_ADD_Config                 db ' þ Writing AiR-BOOT configuration...', 0
TXT_ADD_NothingToDo            db ' þ All components of AiR-BOOT are intact and up-to-date. Nothing to do.', 13, 10, 0
TXT_ADD_SetupOkay              db 13, 10
                               db 'Your copy of AiR-BOOT is now fully functional.', 13, 10, 0

TXT_DELETE_NotPossible         db ' þ Removing AiR-BOOT automatically is not possible here.', 13, 10
                               db '    Boot your favourite OS and restore/overwrite the MBR manually.', 13, 10
                               db '    As for DOS/Windows 9x: enter "FDISK /MBR" in commandline.', 13, 10
                               db '    As for OS/2: enter "FDISK /MBR" or "LVM /NEWMBR:1" in commandline.', 13, 10
                               db '    For other OSes, please consult the corresponding manual.', 13, 10
                               db 13, 10, 0

MBR_AiRBOOTCodeSig              db 'AiRBOOT'
MBR_AiRBOOTCodeSigLen          equ  7
MBR_EZSETUPCodeSig              db '528+Mbyte(C)1993,94 Micro House Int',39,'l',0
MBR_EZSETUPCodeSigLen          equ 38
MBR_AiRBOOTConfigSig            db 'AiRCFG-TABLE­'
MBR_AiRBOOTConfigSigLen        equ 13

; ===============================================================> Variables...
iStatus_Code                   db  0     ; Status of each component
iStatus_Config                 db  0

InstalledVersion_Code          dw  0     ; Version of each installed component
InstalledVersion_Config        dw  0
InstalledLanguageID            db  0     ; Language ID of installed AiR-BOOT

ImageVersion                   dw  0     ; Version of the Image contained
ImageLanguageID                db  0     ; Language ID of Image contained


Option_ForceCode               db  0     ; Request to write code anytime
Option_ForceConfig             db  0     ; Request to write config anytime
Option_Silent                  db  0     ; Request for silent operation

Install_Code                   db  0     ; What Installation has to be done...
Install_Config                 db  0     ; Set to 1, if component not available or defect
Install_IsCorrupt              db  0     ; Is anything defect ? (Add/Repair-Switch)

Impossible_Cause               dw  0     ; Offset to text-message, why Impossible Status

Status_NotInstalled           equ  0     ; No ID found
Status_Corrupt                equ  1     ; ID found, Checksum failure
Status_Installed              equ  2     ; ID found, Checksum valid
Status_InstalledMGU           equ  3     ; ID, Checksum, may get updated
Status_Impossible             equ  4     ; Unable/Not willing to install

; Layout of AiR-BOOT bootcode image
; ---------------------------
; |  1 | Master Boot Record | Code
; |  2 | System-Table       | Code
; |  3 | Code               | Code
; | .. | ...                | Code
; | 55 | Configuration      | Config
; | 56 | Partitiontable 1   | Config
; | 57 | Partitiontable 2   | Config
; | 58 | Hide-Partitiontable| Config
; | 59 | Hide-Partitiontable| Config
; | 60 | Backup of our MBR  | Config
; ---------------------------

; Space for bootcode-image
BootImage       db 31744 dup (?)
