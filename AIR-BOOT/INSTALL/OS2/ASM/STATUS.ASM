
Public INST_Status_CheckImage
Public INST_Status_CheckCode
Public INST_Status_CheckConfig
Public INST_Status_GetLanguageName

; -----------------------------------------------------------------------------

;        In: BX - Base Check, ESI - Pointer to 512-byte-area to be included
;       Out: BX - Base Check Result
; Destroyed: ESI will get updated (+512)
GetCheckOfSector                Proc Near   Uses eax ecx
   mov    ecx, 256
  GetCheckOfSector_Loop:
      lodsw
      xor    ax, 0BABEh
      xor    bx, ax
   loop   GetCheckOfSector_Loop
   or     bx, bx
   jnz    GetCheckOfSector_NoFixUp
   mov    bx, 1                          ; dont allow 0, because 0 means "empty"
  GetCheckOfSector_NoFixUp:
   ret
GetCheckOfSector                EndP

; This routine will fill out some variables depending on the included AiR-BOOT
;  Image.
INST_Status_CheckImage          Proc Near   Uses esi
   mov     esi, AiRBOOT_ImageSectorsPtr
   mov     ax, [esi+13]                  ; Gets Version of Code-Image
   xchg    al, ah
   mov     Image_CodeVersion, ax
   mov     al, [esi+15]                  ; Gets LanguageID of Image
   mov     Image_LanguageID, al
   mov     ax, [esi+6C0Dh]               ; Gets Version of Config-Image
   xchg    al, ah
   mov     Image_ConfigVersion, ax
   ret
INST_Status_CheckImage          EndP

; This routine is called once to check AiRBOOT_MBRSectors and fill out all
;  the different variables to contain details on possible current installation
;  and fill out the AiRBOOT_ImageSectors as well, so Installer can simply write
;  that to harddrive...
INST_Status_CheckCode           Proc Near   Uses ebx ecx edx esi edi
   cmp     iStatus_Code, Status_Impossible
   jne     DoRealChecking
   ret

  DoRealChecking:
   call    INST_Status_CheckForEZSETUP
   jne     NoEZSETUP
   mov     iStatus_Code, Status_Impossible
   mov     Impossible_Cause, TXT_STATUS_EZSETUP
   ret

  NoEZSETUP:
   ; Check Master-Boot-Record Signature
   cmp     wptr [MBR_CurrentSectors+01FEh], 0AA55h
   jne     NotInstalled
   ; Check AiR-BOOT String...
   mov     esi, offset MBR_CurrentSectors+2
   mov     edi, offset MBR_AiRBOOTCodeSig
   mov     cx, MBR_AiRBOOTCodeSigLen
   repe    cmpsb
   je      IDfound
  NotInstalled:
   ; kein AiR-BOOT MBR Image gefunden
   mov     iStatus_Code, Status_NotInstalled
   ret

  IDfound:
   ; Check actual Code
   movzx   cx, bptr [MBR_CurrentSectors+0010h] ; Total-Code-Sectors-Used
   mov     esi, offset MBR_CurrentSectors+512
   xor     bx, bx
  CheckSumLoop:
      call    GetCheckOfSector
   loop    CheckSumLoop
   cmp     bx, wptr [MBR_CurrentSectors+0011h]
   je      CheckSumOK
   mov     iStatus_Code, Status_Corrupt
   ret

  CheckSumOK:
   mov     al, [MBR_CurrentSectors+0Fh]   ; Current Language ID
   mov     Installed_LanguageID, al
   mov     cx, wptr [MBR_CurrentSectors+0Dh] ; Current Version ID
   mov     dx, Image_CodeVersion          ; My Image Version ID
   xchg    ch, cl
   mov     Installed_CodeVersion, cx      ; remember installed code version
   cmp     cx, dx                         ; If version number in image is higher
   jb      MayGradeUp                     ;  -> Upgradeable
   mov     iStatus_Code, Status_Installed
   ret
  MayGradeUp:
   mov     iStatus_Code, Status_InstalledMGU
   ret
INST_Status_CheckCode           EndP

INST_Status_CheckForEZSETUP     Proc Near
   mov     esi, offset MBR_CurrentSectors+8Fh
   mov     edi, offset MBR_EZSETUPCodeSig
   mov     ecx, MBR_EZSETUPCodeSigLen
   repe    cmpsb
   ret
INST_Status_CheckForEZSETUP     EndP

INST_Status_CheckConfig         Proc Near   Uses ebx ecx edx esi edi
   ; First check for current Config-Format...
   mov     esi, offset MBR_CurrentSectors+6C00h ; Sector 55
   mov     edi, offset MBR_AiRBOOTConfigSig
   mov     ecx, MBR_AiRBOOTConfigSigLen
   repe    cmpsb
   jne     CheckPrior026
   mov     esi, offset MBR_CurrentSectors+6C00h ; Sector 55
   mov     dx, wptr [esi+20]             ; DX - current Checksum
   mov     wptr [esi+20], 0              ; Kills current Checksum
   xor     bx, bx
   mov     ecx, 5                        ; Total of 5 Sectors
  CheckSumLoop:
      call    GetCheckOfSector
   loop    CheckSumLoop
   ; Restore Checksum and check, if calculated matches...
   mov     wptr [MBR_CurrentSectors+6C14h], dx
   cmp     bx, dx
   je      CheckSumOK
   mov     iStatus_Config, Status_Corrupt
   ret
  CheckSumOK:
   mov     cx, wptr [MBR_CurrentSectors+6C0Dh]
   mov     ax, wptr Image_ConfigVersion  ; My Image Version ID
   xchg    cl, ch
   mov     Installed_ConfigVersion, cx   ; remember installed config version
   cmp     cx, ax
   jb      UpgradeConfig
   mov     iStatus_Config, Status_Installed
   jmp     NoUpgradeConfig
   ; ==========================================================================
   ;  Those Upgrades will copy useful configuration data to the Image Config
   ;  If new configuration data was added, those spaces are not overwritten.
   ;  Sector 60 (MBR-BackUp) *MUST BE* copied, otherwise it's lost.
   ; ==========================================================================
  UpgradeConfig:
   mov     iStatus_Config, Status_InstalledMGU
   cmp     cx, 0027h
   jbe     Upgrade027
   cmp     cx, 0091h
   jbe     Upgrade091
  NoUpgradeConfig:
   ; If we don't need to "upgrade" the configuration, we simply copy it over.
   ; Sector 55 (never copy header/version)
   mov     esi, offset MBR_CurrentSectors+6C00h+16
   mov     edi, AiRBOOT_ImageSectorsPtr
   add     edi, 6C00h+16
   mov     ecx, (3072-16)/2              ; Copy all 6 sectors w/o modification
   rep     movsw
   ret

   ; ----------------------------------------- UPGRADE v0.27 and prior versions
  Upgrade027:
   ; Sector 55 (never copy header/version)
   mov     esi, offset MBR_CurrentSectors+6C00h+16
   mov     edi, AiRBOOT_ImageSectorsPtr
   add     edi, 6C00h+16
   mov     ecx, (69-16)
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
   add     esi, 101+262+34
   add     edi, 101+262+34
   mov     ecx, 46/2
   rep     movsw                         ; Copy remaining of sector 55
   mov     ecx, 1924/2
   rep     movsw                         ; Copy sectors 56-57 & Hide-Config
   ; Changes: Sector 59 - Offset 388 Length 30 - Logical-Drive-Letter Table
   add     esi, 124
   add     edi, 124
   mov     ecx, 512/2
   rep     movsw                         ; Copy sector 60 unmodified
   ret

   ; ----------------------------------------- UPGRADE v0.91 and prior versions
  Upgrade091:
   ; Sector 55 (never copy header/version)
   mov     esi, offset MBR_CurrentSectors+6C00h+16
   mov     edi, AiRBOOT_ImageSectorsPtr
   add     edi, 6C00h+16
   mov     ecx, (512-16)/2
   rep     movsw                         ; Copy sector 55
   mov     ecx, 1924/2
   rep     movsw                         ; Copy sectors 56-57 & Hide-Config
   ; Changes: Sector 59 - Offset 388 Length 30 - Logical-Drive-Letter Table
   add     esi, 124
   add     edi, 124
   mov     ecx, 512/2
   rep     movsw                         ; Copy sector 60 unmodified
   ret

   ; ==========================================================================
   ; Check for Prior 0.26b format...
  CheckPrior026:
   mov     esi, offset MBR_CurrentSectors+7000h ; Sector 57
   mov     edi, offset MBR_AiRBOOTConfigSig
   mov     ecx, MBR_AiRBOOTConfigSigLen
   repe    cmpsb
   je      PriorIDfound
   ; kein AiR-BOOT MBR Image gefunden
   mov     iStatus_Config, Status_NotInstalled
   ret
  PriorIDfound:
   mov     esi, offset MBR_CurrentSectors+7000h ; Sector 57
   mov     dx, wptr [esi+20]             ; DX - current checksum
   mov     wptr [esi+20], 0              ; NULs current checksum
   xor     bx, bx
   mov     ecx, 3                        ; Total of 3 Sectors
  PriorCheckSumLoop:
      call    GetCheckOfSector
   loop    PriorCheckSumLoop
   ; Restore Checksum and check, if calculated matches...
   mov     wptr [MBR_CurrentSectors+7014h], dx
   cmp     bx, dx
   je      PriorCheckSumOK
   mov     iStatus_Config, Status_Corrupt
   ret
  PriorCheckSumOK:
   mov     iStatus_Config, Status_InstalledMGU
   ; ==========================================================================
   ; Now convert Pre-0.26b-configuration layout to new one.
   ;  Sector 57-59 containing Base-Config and IPT are compatible but have to
   ;  get moved to Sector 55-57 and Hide-Configuration has to be taken from
   ;  Image-default-configuration.
   ; After that a normal version upgrade will be performed additionally.
   ; ==========================================================================
   ; DS == ES == Current Image
   mov     esi, offset MBR_CurrentSectors+7000h ; Current Sector 57 (prior cfg)
   mov     edi, AiRBOOT_ImageSectorsPtr
   add     edi, 6C00h                    ; -> Image - Sector 55
   mov     cx, 768                       ; Total of 3 sectors...
   rep     movsw
   mov     esi, offset MBR_CurrentSectors+7200h ; Current Sector 58 (prior cfg)
   mov     cx, 512                       ; Total of 2 sectors...
   rep     movsw
   jmp     CheckSumOK                    ; Resume to upgrade config more
INST_Status_CheckConfig         EndP

INST_Status_GetLanguageName    Proc Near  Uses si, LanguageID:byte
   mov    al, LanguageID
   cmp    al, 'U'
   je     LangUS
   cmp    al, 'D'
   je     LangDT
   cmp    al, 'G'
   je     LangDE
   cmp    al, 'F'
   je     LangFR
   cmp    al, 'I'
   je     LangIT
   cmp    al, 'R'
   je     LangRU
   cmp    al, 'S'
   je     LangSW
   mov    eax, TXT_Language_Huh             ; Unknown to me
   jmp    PrintOut

  LangUS:
   mov    eax, TXT_Language_US
   jmp    PrintOut
  LangDT:
   mov    eax, TXT_Language_DT
   jmp    PrintOut
  LangDE:
   mov    eax, TXT_Language_DE
   jmp    PrintOut
  LangFR:
   mov    eax, TXT_Language_FR
   jmp    PrintOut
  LangIT:
   mov    eax, TXT_Language_IT
   jmp    PrintOut
  LangRU:
   mov    eax, TXT_Language_RU
   jmp    PrintOut
  LangSW:
   mov    eax, TXT_Language_SW
  PrintOut:
   ret
INST_Status_GetLanguageName    EndP
