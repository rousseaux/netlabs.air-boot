
;  ù Ä ÄÄÄÄÍÍ = Ä  ù  Ä = ÍÍÄÄÄÄ Ä ù
;  ³                               ³
;     ÜÛÛÛÛÛÛÛÜ   ÜÛÜ  ÜÛÛÛÛÛÛÛÛÜ          ú  úÄÄÄÍÄÄÍÄÍÍÄÄÍÍÍÍÄÍÍÍÍÍÍÍÍÍÎÄ
;  ³ ÛÛÛÛßßßÛÛÛÛ ÛÛÛÛÛ ÛÛÛß   ßÛÛÛ ³      AiR-BOOT - BootSTRAP Installer º
;  º ÛÛÛÛÜÜÜÛÛÛÛ ÛÛÛÛÛ ÛÛÛÜ   ÜÛÛÛ º      ú ÄÄÄÄÍÄÍÍÄÄÍÍÍÍÄÍÍÍÍÍÍÍÍÄÍÍÍÍÍÎÄ
;  º ÛÛÛÛÛÛÛÛÛÛÛ ÛÛÛÛÛ ÛÛÛÛÛÛÛÛÛß  º       Section: AiR-BOOTUP Package   º
;  º ÛÛÛÛ   ÛÛÛÛ ÛÛÛÛÛ ÛÛÛÛ ßÛÛÛÛÜ º     ³ Created: 21/07/98             º
;  ³ ßÛÛß   ßÛÛß  ßÛß  ßÛÛß   ßÛÛß ³     ³ Last Modified:                ³
;                   ÜÜÜ                  ³ Number Of Modifications: 000  ³
;  ù              ÜÛÛß             ù     ³ INCs required: *none*         ³
;       ÄÄÄÄÄÄÄ ÜÛÛß                     º Written By: Martin Kiewitz    ³
;  ³     Ú¿Ú¿³ÜÛÛÛÜÜÛÛÛÜ           ³     º (c) Copyright by              ³
;  º     ÀÙ³ÀÙßÛÛÛßßÜÛÛß           º     º      AiR ON-Line Software '98 ú
;  º    ÄÄÄÄÄÄÄ    ÜÛÛÝ            º     º All rights reserved.
;  º              ÜÛÛÛÄÄÄÄÄÄÄÄÄ    º    ÄÎÍÍÍÄÍÍÍÍÍÄÍÍÍÍÄÍÍÄÄÍÄÄÍÄÄÄúÄÄ  ú
;  º             ÜÛÛÛÝ³ ³Ú¿³³Ä     º
;  ³            ÜÛÛÛÛ ÀÄ³³ÀÙ³Ä     ³
;              ßÛÛÛÛÝÄÄÄÄÄÄÄÄÄÄ     
;  ³             ßß                ³
;  ù Ä´-=’iç éï-Liïî SéŸâW’çî=-ÃÄÄ ù


; RealMode means -> Actual MBR-Code, otherwise it will produce debugable Code
RealMode        equ     -1
; Debug Version will implement Always-Add-Code
; DebugVersion    equ     -1

JUMPS

; First all Equs

IFDEF RealMode
   ExecBaseSeg     equ     00000h
   ExecBasePtr     equ     07C00h
  ELSE
   ExecBaseSeg     equ     00BFBh
   ExecBasePtr     equ     00100h  ; BIOS starts our MBR at 0:7C00
ENDIF
ImageBaseSeg    equ     8000h
ImageBasePtr    equ     0h      ; We put our AiR-BOOT image to this location
MBR_CurrentSectorsSeg           equ     9000h ; We put current MBR into this seg
StackSeg        equ     7000h

Include ..\..\..\..\JimiHelp\asm.inc\stdmacro.inc
Include ..\global.asm\airboot.inc

		.386p
                model large, basic

code_seg        segment public use16
                assume  cs:code_seg, ds:nothing, es:nothing, ss:nothing
IFDEF RealMode
                org     0
air_boot_inst:  db      0   ; to fix this to COM file
ENDIF

;---------------------------------------------------------------------------
                org     ExecBasePtr
IFNDEF RealMode
air_boot_inst:
ENDIF
air_boot_begin: jmp     INST_RealStart

                                db 61 dup (0)

                                db 'AiR-BOOT: LOAD ERROR!', 0
MBR_Error_LoadError             Proc Near  Uses
   mov     ax, offset $
   mov     si, ax
   sub     si, 22
   push    cs
   pop     ds
   call    MBR_Teletype
  MBR_Error_LoadError_Halt:
   jmp     MBR_Error_LoadError_Halt
MBR_Error_LoadError             EndP

                                db 'AiR-BOOT: SAVE ERROR!', 0
MBR_Error_SaveError             Proc Near  Uses
   mov     ax, offset $
   mov     si, ax
   sub     si, 22
   push    cs
   pop     ds
   call    MBR_Teletype
  MBR_Error_SaveError_Halt:
   jmp     MBR_Error_SaveError_Halt
MBR_Error_SaveError             EndP

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

;---------------------------------------------------------------------------
TXT_START_Copyright             db      'AiR-BOOT Installer v1.00 for AiR-BOOT', 13, 10
                                db      ' - (c) Copyright ''98-''02 by Martin Kiewitz.', 13, 10
                                db      13, 10
                                db      '-> ...Please wait... <-', 13, 10
                                db      ' - Loading code from disc...', 0

INST_RealStart: mov     ax, StackSeg
                mov     ss, ax
                mov     sp, 7FFFh
                mov     ax, cs
                mov     ds, ax
                mov     es, ax       ; Set DS&ES to new segment
                ; Shows Copyright message
                mov     si, offset TXT_START_Copyright
                call    MBR_Teletype
IFNDEF RealMode
                jmp     INST_Begin
ENDIF
                ; Loads missing part from disk
                mov     bx, offset FurtherMoreLoad
                mov     dx, 0000h         ; Erstes FDD, Sektor 2
                mov     cx, 0002h         ; Cylinder 0
                mov     ax, 0207h         ; restliche 7 Sektoren...
                int     13h
                jnc     MBR_RealStart_NoError
   MBR_RealStart_GotError:
                call    MBR_Error_LoadError                ; Will Abort BootUp
   MBR_RealStart_NoError:
                mov     bx, offset INST_Begin
                mov     dx, 0000h         ; Erstes FDD, Sektor 1
                mov     cx, 0101h         ; Cylinder 1
                mov     ax, 0208h         ; weitere 8 Sektoren...
                int     13h
                jc      MBR_RealStart_GotError
                jmp     INST_Begin

                org     ExecBasePtr + 1FEh
                db      55h, 0AAh
;---------------------------------------------------------------------------
                org     ExecBasePtr + 200h                      ; 512 Boundry
FurtherMoreLoad:
MBR_HaltSystem: cli
                jmp     MBR_HaltSystem

   ; Contains all texts used by the Installer
   include ..\GLOBAL.ASM\ConstTXT.asm

; ===============================================================> Variables...
iStatus_Code                   db  0     ; Status of each component
iStatus_Config                 db  0

InstalledVersion_Code          dw  0     ; Version of each installed component
InstalledVersion_Config        dw  0
InstalledLanguageID            db  0     ; Language ID of installed AiR-BOOT

ImageVersion                   dw  0     ; Version of the Image contained
ImageLanguageID                db  0     ; Language ID of Image contained



Install_Code                   db  0     ; What Installation has to be done...
Install_Config                 db  0     ; Set to 1, if component not available or defect
Install_IsCorrupt              db  0     ; Is anything defect ? (Add/Repair-Switch)

Impossible_Cause               dw  0     ; Offset to text-message, why Impossible Status

Status_NotInstalled           equ  0     ; No ID found
Status_Corrupt                equ  1     ; ID found, Checksum failure
Status_Installed              equ  2     ; ID found, Checksum valid
Status_InstalledMGU           equ  3     ; ID, Checksum, may get updated
Status_Impossible             equ  4     ; Unable/Not willing to install

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

;------------------------------------------------------------------------------
   org    ExecBasePtr + 1000h                                       ; Sector 9
INST_Begin:
   ; =============================================================
   ;                         START
   ; =============================================================
   mov     si, offset TXT_Okay
   call    MBR_Teletype
   ; -----------------------------------------> LOAD AiR-BOOT IMAGE
   mov     si, offset TXT_START_LoadImage
   call    MBR_Teletype
   call    INST_Start_LoadImage
   mov     si, offset TXT_Okay
   call    MBR_Teletype
   ; -----------------------------------------> LOAD CURRENT MBR
   call    INST_Status_CheckHarddisc
   jz      INST_PRE_HarddiscTooSmall
   mov     si, offset TXT_START_LoadMBR
   call    MBR_Teletype
;IFDEF RealMode
   call    INST_Start_LoadMBR
;ENDIF
   mov     si, offset TXT_Okay
   call    MBR_Teletype
  INST_PRE_HarddiscTooSmall:

   ; =============================================================
   ;                        STATUS
   ; =============================================================
   mov     si, offset TXT_STATUS_Main
   call    MBR_Teletype
   call    INST_Status_CheckCode
   mov     al, iStatus_Code
   mov     dx, InstalledVersion_Code
   call    INST_Status_TeletypeCode
   mov     si, offset TXT_STATUS_Config
   call    MBR_Teletype
   call    INST_Status_CheckConfig
   mov     al, iStatus_Config
   mov     dx, InstalledVersion_Config
   call    INST_Status_TeletypeCode

   ; Display language as well, if Code installed
   mov     al, iStatus_Code
   cmp     al, Status_Installed
   je      INST_STATUS_ShowLanguage
   cmp     al, Status_InstalledMGU
   jne     INST_STATUS_SkipLanguage
  INST_STATUS_ShowLanguage:
   mov     si, offset TXT_STATUS_Language
   call    MBR_Teletype
   mov     al, InstalledLanguageID
   call    INST_Status_TeletypeLanguage
   mov     si, offset TXT_CR
   call    MBR_Teletype

  INST_STATUS_SkipLanguage:
   cmp     iStatus_Code, Status_Impossible
   jne     INST_STATUS_GoFurther
   mov     si, offset TXT_SystemHalted
   call    MBR_Teletype
   jmp     MBR_HaltSystem

  INST_STATUS_GoFurther:
   ; =============================================================
   ;                      PRE-CHECKING
   ; =============================================================

   cmp     iStatus_Code, Status_Installed
   jne     INST_STATUS_CodeInstallNeeded
   ; So, we got Code installed and up-to-date
   mov     al, InstalledLanguageID
   cmp     al, ImageLanguageID
   je      INST_STATUS_NoCodeNeeded
   ; If Language-ID is the same -> No install needed
  INST_STATUS_CodeInstallNeeded:
   mov     Install_Code, 1          ; Not/Corrupt/Update
  INST_STATUS_NoCodeNeeded:
   cmp     iStatus_Config, Status_Installed
   je      INST_STATUS_NoConfigNeeded
   mov     Install_Config, 1        ; Not/Corrupt
  INST_STATUS_NoConfigNeeded:

   mov     al, 1
   cmp     iStatus_Code, Status_Corrupt
   je      INST_STATUS_WonderfulCorruption
   cmp     iStatus_Config, Status_Corrupt
   je      INST_STATUS_WonderfulCorruption
   xor     al, al
  INST_STATUS_WonderfulCorruption:
   mov     Install_IsCorrupt, al

   ; =============================================================
   ;                         VIRUS
   ; =============================================================

   ; Falls-Tabelle:
   ;----------------
   ; Code==Not Installed, Config==Not Installed => Check MBR
   ; Code==Installed, Config==Installed => Check MBR (->Virus?)
   ; Code==Not Installed, Config==Installed => (->Virus?)
   ; Code==Installed, Config==Not Installed => Check MBR (->Virus?)
   cmp     iStatus_Code, Status_NotInstalled
   jne     INST_VIRUS_SomethingFound
   cmp     iStatus_Config, Status_NotInstalled
   jne     INST_VIRUS_SomethingFound
   ; Nothing Found, so Check MBR, if squashed simply stop system
   call    INST_VIRUS_CheckCurrentMBR
   jnc     INST_VIRUS_Skip  ; Skip Virus-Stuff Code
   ; AiR-BOOT 100% not found and Partition Table broken
   mov     si, offset TXT_MBRfail_Argh
   call    MBR_Teletype
   mov     si, offset TXT_SystemHalted
   call    MBR_Teletype
   jmp     MBR_HaltSystem

  INST_VIRUS_SomethingFound:
   cmp     iStatus_Code, Status_NotInstalled
   je      INST_VIRUS_VirusProposed ; to have overwritten MBR
   ; Just check MBR...if squashed show up virus and check for backup
  INST_VIRUS_SimplyCheckMBR:
   call    INST_VIRUS_CheckCurrentMBR
   jnc     INST_VIRUS_Skip  ; Skip Virus-Stuff Code

   ; Virus Proposed to have squashed the MBR, perhaps backup is
   ; available, so check for it.
  INST_VIRUS_VirusProposed:
   mov     si, offset TXT_Virus_Main
   call    MBR_Teletype
   call    INST_VIRUS_CheckForStealth
   jz      INST_VIRUS_ProbablyStealth
   mov     si, offset TXT_Virus_Normal
   call    MBR_Teletype
   jmp     INST_VIRUS_DisplayAlways
  INST_VIRUS_ProbablyStealth:
   mov     si, offset TXT_Virus_Severe
   call    MBR_Teletype

  INST_VIRUS_DisplayAlways:
   mov     si, offset TXT_Virus_Always
   call    MBR_Teletype

   call    INST_VIRUS_CheckCurrentMBR
   jnc     INST_VIRUS_Skip
   mov     si, offset TXT_MBRfail_Normal
   call    MBR_Teletype
   call    INST_VIRUS_CheckForBackUpMBR
   jc      INST_VIRUS_NoBackUp
   mov     si, offset TXT_MBRfail_Strike
   call    MBR_Teletype
  INST_VIRUS_KeyLoop:
      mov     ah, 0
      int     16h                         ; KEYBOARD WAIT, AH - Keycode
      or      al, 20h                     ; Lower-Case Input
      cmp     al, 'y'
      je      INST_VIRUS_KeyYes
      cmp     al, 'z'
      je      INST_VIRUS_KeyYes
      cmp     al, 'n'
      je      INST_VIRUS_KeyNo
      jmp     INST_VIRUS_KeyLoop

  INST_VIRUS_KeyYes:
   call    INST_VIRUS_CopyBackUpMBR
  INST_VIRUS_KeyNo:
   jmp     INST_VIRUS_Skip
  INST_VIRUS_NoBackUp:
   mov     si, offset TXT_MBRfail_Buuuhh
   call    MBR_Teletype
  INST_VIRUS_Skip:

   ; =============================================================
   ;                         MENU
   ; =============================================================
   mov     si, offset TXT_MENU_Main
   call    MBR_Teletype
   mov     si, offset TXT_MENU_Repair
   test    Install_IsCorrupt, 1
   jnz     INST_MENU_UseThis
   mov     si, offset TXT_MENU_Add
   cmp     iStatus_Code, Status_NotInstalled
   je      INST_MENU_UseThis
   mov     si, offset TXT_MENU_Update
  INST_MENU_UseThis:
   call    MBR_Teletype

   mov     dx, ImageVersion
   mov     al, dh
   call    MBR_TeletypeNumber
   mov     al, '.'
   call    MBR_TeletypeSingle
   mov     al, dl
   call    MBR_TeletypeNumber2
   mov     al, '/'
   call    MBR_TeletypeSingle
   mov     al, ImageLanguageID
   call    INST_Status_TeletypeLanguage
   mov     si, offset TXT_MENU_OnCurSystem
   call    MBR_Teletype

   mov     si, offset TXT_MENU_Delete
   call    MBR_Teletype
   mov     si, offset TXT_MENU_Quit
   call    MBR_Teletype

  INST_MENU_KeyLoop:
      mov     ah, 0
      int     16h              ; KEYBOARD WAIT, AH - Keycode
      or      al, 20h          ; Lower-Case Input
      cmp     al, 'a'
      je      INST_MENU_Do_ADD
      cmp     al, 'r'
      je      INST_MENU_Do_ADD
      cmp     al, 'u'
      je      INST_MENU_Do_ADD
      cmp     al, 'd'
      je      INST_MENU_Do_DELETE
      cmp     al, 'q'
      je      INST_MENU_DidNothing
      jmp     INST_MENU_KeyLoop

  INST_MENU_Do_ADD:
   mov     si, offset TXT_PROCESS_Split
   call    MBR_Teletype
   call    INST_Add_DoIt
   jmp     INST_MENU_DidSomething

  INST_MENU_Do_DELETE:
   mov     si, offset TXT_PROCESS_Split
   call    MBR_Teletype
   mov     si, offset TXT_DELETE_NotPossible
   call    MBR_Teletype
   jmp     INST_MENU_DidSomething

  INST_MENU_DidSomething:
  INST_KeyAfter:
      mov     ah, 0    ; wartet auf ENTER
      int     16h 
      cmp     ah, 1Ch
      jne     INST_KeyAfter

  INST_MENU_DidNothing:
   mov     si, offset TXT_CR
   call    MBR_Teletype
   mov     si, offset TXT_CR
   call    MBR_Teletype

   IFNDEF RealMode
      mov     ax, 6200h
      int     21h
      mov     es, bx
      mov     ax, 4C00h     ; Quit program
      int     21h
   ENDIF

   ; ------------------------------------- LOAD MBR FROM HARDDRIVE...
   push    ExecBaseSeg
   pop     es
   mov     bx, ExecBasePtr
   mov     cx, 0001h
   mov     dx, 0080h
   call    MBR_LoadSector

   mov     dl, 80h                        ; Booted from first HDD
   db      0EAh
   dw      ExecBasePtr
   dw      ExecBaseSeg
; =============================================================================

INST_Start_LoadImage           Proc Near  Uses es
   push    ImageBaseSeg
   pop     es
   mov     bx, ImageBasePtr
   mov     cx, 0201h                      ; Cylinder 2, Sektor 1
   mov     dx, 0000h                      ; Head 0, Drive 0 (Floppy)
  INST_SLI_Loop:
      call    MBR_LoadSector
      cmp     cl, 9
      jne     INST_SLI_ContinueNoFix
      inc     ch
      mov     cl, 1
  INST_SLI_ContinueNoFix:
   cmp     cx, AiR_BOOT_MaxInstallDiscLocation
   jne     INST_SLI_Loop
   mov     ax, wptr es:[000Dh]            ; Version of Image
   xchg    al, ah
   mov     ImageVersion, ax
   mov     al, bptr es:[000Fh]            ; Language ID of Image
   mov     ImageLanguageID, al
   ret
INST_Start_LoadImage           EndP

INST_Start_LoadMBR             Proc Near  Uses es
   push    MBR_CurrentSectorsSeg
   pop     es
   xor     bx, bx                        ; ES:BX - CurrentSectorsSegment
   mov     cx, 0001h                     ; Cylinder 0, Sektor 1
   mov     dx, 0080h                     ; Head 0, Drive 80 (MBR Load)
  INST_SLMBR_Loop:
      call    MBR_LoadSector
   cmp     cl, 63
   jne     INST_SLMBR_Loop
   ret
INST_Start_LoadMBR             EndP


; =============================================================================

INST_Status_CheckCode          Proc Near  Uses ds si es di
   call    INST_Status_CheckHarddisc
   jnz     INST_SCC_HarddiscSizeOK
   mov     cs:iStatus_Code, Status_Impossible
   mov     cs:Impossible_Cause, offset TXT_STATUS_Hd2Small
   ret

  INST_SCC_HarddiscSizeOK:
   call    INST_Status_CheckForEZSETUP
   jne     INST_SCC_NoEZSETUP
   mov     cs:iStatus_Code, Status_Impossible
   mov     cs:Impossible_Cause, offset TXT_STATUS_EZSETUP
   ret

  INST_SCC_NoEZSETUP:
   mov     si, offset MBR_AiRBOOTCodeSig
   push    MBR_CurrentSectorsSeg
   pop     es
   ; Check Master-Boot-Record Signature
   cmp     wptr es:[01FEh], 0AA55h
   jne     INST_SCC_NotInstalled
   ; Check AiR-BOOT String...
   mov     di, 2
   mov     cx, MBR_AiRBOOTCodeSigLen
   repe    cmpsb
   je      INST_SCC_IDfound
  INST_SCC_NotInstalled:
   ; kein AiR-BOOT MBR Image gefunden
   mov     cs:iStatus_Code, Status_NotInstalled
   ret

  INST_SCC_IDfound:
   ; Check actual Code
   movzx   cx, bptr es:[0010h]            ; Total-Code-Sectors-Used
   push    es
   pop     ds
   mov     si, 512
   xor     bx, bx
  INST_SCC_CheckSumLoop:
      call    MBR_GetCheckOfSector
   loop    INST_SCC_CheckSumLoop
   cmp     bx, wptr es:[0011h]
   je      INST_SCC_CheckSumOK
   mov     cs:iStatus_Code, Status_Corrupt
   ret

  INST_SCC_CheckSumOK:
   push    ImageBaseSeg
   pop     ds
   mov     al, es:[000Fh]                 ; Current Language ID
   mov     InstalledLanguageID, al
   mov     cx, es:[000Dh]                 ; Current Version ID
   mov     dx, ImageVersion               ; My Image Version ID
   xchg    ch, cl
   mov     InstalledVersion_Code, cx      ; remember installed code version
   cmp     cx, dx                         ; If version number in image is higher
   jb      INST_SCC_MGU                   ;  -> Upgradeable
   mov     cs:iStatus_Code, Status_Installed
   ret
  INST_SCC_MGU:
   mov     cs:iStatus_Code, Status_InstalledMGU
   ret
INST_Status_CheckCode          EndP

INST_Status_CheckForEZSETUP    Proc Near  Uses
   mov     si, offset MBR_EZSETUPCodeSig
   push    MBR_CurrentSectorsSeg
   pop     es
   mov     di, 8Fh
   mov     cx, MBR_EZSETUPCodeSigLen
   repe    cmpsb
   ret
INST_Status_CheckForEZSETUP    EndP

INST_Status_CheckConfig        Proc Near  Uses ds si es di
   ; First check for current Config-Format...
   mov     si, offset MBR_AiRBOOTConfigSig
   push    MBR_CurrentSectorsSeg
   pop     es                            ; ES == Current Image
   mov     di, 6C00h                     ; Sector 55
   mov     cx, MBR_AiRBOOTConfigSigLen
   repe    cmpsb
   jne     INST_SCCFG_CheckPrior026
   push    es
   pop     ds                            ; DS == Current Image
   mov     si, 6C00h                     ; Sector 55
   mov     dx, wptr ds:[si+20]           ; DX - Current Checksum
   mov     wptr ds:[si+20], 0            ; Kills current Checksum
   xor     bx, bx
   mov     cx, 5                         ; Total of 5 Sectors
  INST_SECFG_CheckSumLoop:
      call    MBR_GetCheckOfSector
   loop    INST_SECFG_CheckSumLoop
   cmp     bx, dx
   je      INST_SCCFG_CheckSumOK
   mov     cs:iStatus_Config, Status_Corrupt
   ret
  INST_SCCFG_CheckSumOK:
   push    ImageBaseSeg
   pop     es                            ; ES == Image
   ; DS == Current Image, ES == Image
   mov     cx, ds:[6C0Dh]
   mov     ax, es:[6C0Dh]
   xchg    cl, ch
   xchg    al, ah
   mov     InstalledVersion_Config, cx   ; remember installed config version
   cmp     cx, ax
   jb      INST_SCCFG_UpgradeConfig
   mov     cs:iStatus_Config, Status_Installed
   jmp     INST_SCCFG_NoUpgradeConfig
   ; ==========================================================================
   ;  Those Upgrades will copy useful configuration data to the Image Config
   ;  If new configuration data was added, those spaces are not overwritten.
   ;  Sector 60 (MBR-BackUp) *MUST BE* copied, otherwise it's lost.
   ; ==========================================================================
  INST_SCCFG_UpgradeConfig:
   mov     cs:iStatus_Config, Status_InstalledMGU
   cmp     cx, 0027h
   jbe     INST_SCCFG_Upgrade027
   cmp     cx, 0091h
   jbe     INST_SCCFG_Upgrade091
  INST_SCCFG_NoUpgradeConfig:
   ; If we don't need to "upgrade" the configuration, we simply copy it over.
   mov     si, 6C00h+16                  ; Sector 55 (never copy header/version)
   mov     di, si
   mov     cx, (3072-16)/2               ; Copy all 6 sectors w/o modification
   rep     movsw
   ret

   ; ----------------------------------------- UPGRADE v0.27 and prior versions
  INST_SCCFG_Upgrade027:
   mov     si, 6C00h+16                  ; Sector 55 (never copy header/version)
   mov     di, si
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
   ret

   ; ----------------------------------------- UPGRADE v0.91 and prior versions
  INST_SCCFG_Upgrade091:
   mov     si, 6C00h+16                  ; Sector 55 (never copy header/version)
   mov     di, si
   mov     cx, (512-16)/2
   rep     movsw                         ; Copy sector 55
   mov     cx, 1924/2
   rep     movsw                         ; Copy sectors 56-57 & Hide-Config
   ; Changes: Sector 59 - Offset 388 Length 30 - Logical-Drive-Letter Table
   add     si, 124
   add     di, 124
   mov     cx, 512/2
   rep     movsw                         ; Copy sector 60 unmodified
   ret

   ; ==========================================================================
   ; Check for Prior 0.26b format...
  INST_SCCFG_CheckPrior026:
   mov     si, offset MBR_AiRBOOTConfigSig
   mov     di, 7000h                   ; Sector 57
   mov     cx, MBR_AiRBOOTConfigSigLen
   repe    cmpsb
   je      INST_SCCFG_PriorIDfound
   ; kein AiR-BOOT MBR Image gefunden
   mov     cs:iStatus_Config, Status_NotInstalled
   ret
  INST_SCCFG_PriorIDfound:
   push    es
   pop     ds                            ; DS == Current Image
   mov     si, 7000h
   mov     dx, wptr ds:[si+20]           ; DX - jetzige Checksum
   mov     wptr ds:[si+20], 0            ; l”scht jetzige Checksum
   xor     bx, bx
   mov     cx, 3                         ; Total of 3 Sectors
  INST_SECFG_PriorCheckSumLoop:
      call    MBR_GetCheckOfSector
   loop    INST_SECFG_PriorCheckSumLoop
   cmp     bx, dx
   je      INST_SCCFG_PriorCheckSumOK
   mov     cs:iStatus_Config, Status_Corrupt
   ret
  INST_SCCFG_PriorCheckSumOK:
   mov     cs:iStatus_Config, Status_InstalledMGU
   ; ==========================================================================
   ; Now convert Pre-0.26b-configuration layout to new one.
   ;  Sector 57-59 containing Base-Config and IPT are compatible but have to
   ;  get moved to Sector 55-57 and Hide-Configuration has to be taken from
   ;  Image-default-configuration.
   ; After that a normal version upgrade will be performed additionally.
   ; ==========================================================================
   ; DS == ES == Current Image
   mov     si, 7000h                     ; Current - Sector 57 (Prior config)
   mov     di, 6C00h                     ; -> Current - Sector 55 (cur. config)
   mov     cx, 768                       ; Total of 3 sectors...
   rep     movsw
   push    ImageBaseSeg
   pop     ds
   mov     si, 7200h                     ; Image - Sector 58 (Hide-Config)
   mov     cx, 512                       ; Total of 2 sectors...
   rep     movsw
   push    es
   pop     ds                            ; DS == Current Image
   jmp     INST_SCCFG_CheckSumOK         ; Resume to upgrade config more
INST_Status_CheckConfig        EndP

; al - type to display text
; dx - version number
INST_Status_TeletypeCode       Proc Near  Uses si
   cmp     al, Status_Corrupt
   jb      INST_STC_NotInstalled
   je      INST_STC_Corrupt
   cmp     al, Status_Impossible
   je      INST_STC_Impossible
   ; --- Intact (and possibly Update-able)
   push    ax
      mov     si, offset TXT_STATUS_Intact
      call    MBR_Teletype
      ; Include version number...
      mov     al, dh
      call    MBR_TeletypeNumber
      mov     al, '.'
      call    MBR_TeletypeSingle
      mov     al, dl
      call    MBR_TeletypeNumber2
      mov     al, ')'
      call    MBR_TeletypeSingle
   pop     ax
   cmp     al, Status_InstalledMGU
   jne     INST_STC_NoMGU
   mov     si, offset TXT_STATUS_Update
   call    MBR_Teletype
  INST_STC_NoMGU:
   jmp     INST_STC_End

  INST_STC_NotInstalled:
   mov     si, offset TXT_STATUS_ninstall
   jmp     INST_STC_EndWithTeletype
  INST_STC_Corrupt:
   mov     si, offset TXT_STATUS_nintact
   jmp     INST_STC_EndWithTeletype
  INST_STC_Impossible:
   mov     si, cs:Impossible_Cause
  INST_STC_EndWithTeletype:
   call    MBR_Teletype
  INST_STC_End:
   mov     si, offset TXT_CR
   call    MBR_Teletype
   ret
INST_Status_TeletypeCode       EndP

; al - Language ID
INST_Status_TeletypeLanguage   Proc Near  Uses si
   cmp     al, 'U'
   je      INST_STL_US
   cmp     al, 'D'
   je      INST_STL_DT
   cmp     al, 'G'
   je      INST_STL_DE
   cmp     al, 'F'
   je      INST_STL_FR
   cmp     al, 'I'
   je      INST_STL_IT
   cmp     al, 'R'
   je      INST_STL_RU
   cmp     al, 'S'
   je      INST_STL_SW
   mov     si, offset TXT_Language_Huh    ; Unknown to me
   jmp     INST_STL_PrintOut

  INST_STL_US:
   mov     si, offset TXT_Language_US
   jmp     INST_STL_PrintOut
  INST_STL_DT:
   mov     si, offset TXT_Language_DT
   jmp     INST_STL_PrintOut
  INST_STL_DE:
   mov     si, offset TXT_Language_DE
   jmp     INST_STL_PrintOut
  INST_STL_FR:
   mov     si, offset TXT_Language_FR
   jmp     INST_STL_PrintOut
  INST_STL_IT:
   mov     si, offset TXT_Language_IT
   jmp     INST_STL_PrintOut
  INST_STL_RU:
   mov     si, offset TXT_Language_RU
   jmp     INST_STL_PrintOut
  INST_STL_SW:
   mov     si, offset TXT_Language_SW
  INST_STL_PrintOut:
   call    MBR_Teletype
   ret
INST_Status_TeletypeLanguage   EndP

; =============================================================================

INST_VIRUS_CheckForStealth     Proc Near  Uses ds si es di
   push    MBR_CurrentSectorsSeg
   pop     ds
   xor     si, si                        ; DS:SI - CurrentSectorsSegment
   xor     bx, bx
  INST_VCFS_CheckLoop:
      cmp     si, 512
      ja      INST_VCFS_EndLoop
      lodsb
      cmp     al, 0CDh
      jne     INST_VCFS_CheckLoop
      cmp     bptr ds:[si], 13h
      jne     INST_VCFS_CheckLoop
      inc     bx
      jmp     INST_VCFS_CheckLoop

  INST_VCFS_EndLoop:
   or      bx, bx                        ; Sets Zero-Flag if no CD 13hs found...
   ret
INST_VIRUS_CheckForStealth     EndP

; Carry set, if invalid MBR
INST_VIRUS_CheckCurrentMBR     Proc Near  Uses ds si es di
   push    MBR_CurrentSectorsSeg
   pop     ds
   xor     si, si
   call    INST_VIRUS_CheckThisMBR
   ret
INST_VIRUS_CheckCurrentMBR     EndP

; Carry set, if invalid BackUp
INST_VIRUS_CheckForBackUpMBR   Proc Near  Uses ds si es di
   push    MBR_CurrentSectorsSeg
   pop     ds
   mov     si, 7600h                     ; Fixed location of backup
   call    INST_VIRUS_CheckThisMBR
   ret
INST_VIRUS_CheckForBackUpMBR   EndP

; Internal
INST_VIRUS_CheckThisMBR        Proc Near  Uses
   cmp     wptr ds:[si+01FEh], 0AA55h
   jne     INST_VIRUS_InvalidMBR
   xor     cx, cx                        ; No entries checked
   xor     dx, dx                        ; No entries in MBR
   add     si, 446                       ; Auf start Partition table seeken
  INST_VIRUS_PartitionLoop:
      mov     al, ds:[si+3]              ; Cylinder
      mov     ah, ds:[si+2]
      shr     ah, 6                      ; oberen Bits von Cylinder
      shl     eax, 16                    ; bringt Cylinder nach EAX[16-31]
      mov     ah, ds:[si+1]              ; Seite nach EAX[8-15]
      mov     al, ds:[si+2]
      and     al, 111111b                ; Sektor nach EAX[0-7]
      ; Anfangs-Wert fertig
      mov     bl, ds:[si+7]              ; Cylinder
      mov     bh, ds:[si+6]
      shr     bh, 6                      ; oberen Bits von Cylinder
      shl     ebx, 16                    ; bringt Cylinder nach EAX[16-31]
      mov     bh, ds:[si+5]              ; Seite nach EAX[8-15]
      mov     bl, ds:[si+6]
      and     bl, 111111b                ; Sektor nach EAX[0-7]
      ; Anfangs-Wert fertig
      cmp     eax, ebx                   ; vergleichen, falls Begin kleiner
      ja      INST_VIRUS_InvalidMBR

      inc     cx
      cmp     bptr ds:[si+4], 0          ; nur falls was definiert ist
      je      INST_VIRUS_ValidButNone
      cmp     wptr ds:[si+14], 0         ; Absolute mit 0 vergleichen,
      jne     INST_VIRUS_ValidOne        ; falls ==0 -> Fehlerhaft
      cmp     wptr ds:[si+12], 0
      je      INST_VIRUS_InvalidMBR
     INST_VIRUS_ValidOne:
      inc     dx
     INST_VIRUS_ValidButNone:
      add     si, 16
   cmp     cx, 4
   jne     INST_VIRUS_PartitionLoop
   cmp     dx, 1
   jb      INST_VIRUS_InvalidMBR
   clc
   ret
  INST_VIRUS_InvalidMBR:
   stc
   ret
INST_VIRUS_CheckThisMBR        EndP

; Copies BackUp MBR into current MBR area, so it will get installed
INST_VIRUS_CopyBackUpMBR       Proc Near  Uses ds si es di
   mov     ax, MBR_CurrentSectorsSeg
   mov     ds, ax
   mov     es, ax
   mov     si, 7600h                     ; Sector 60...
   xor     di, di                        ;  -> to Sector 1
   mov     cx, 256
   rep     movsw                         ; Copies 1 sector...
   ret
INST_VIRUS_CopyBackUpMBR       EndP

; =============================================================================

INST_Add_DoIt                  Proc Near  Uses
   mov     si, offset TXT_PROCESS_Add
   call    MBR_Teletype
   xor     di, di
   test    Install_Code, 1
   ; ALLTIME ADD - For Debugging Purposes (Remark next line)
   IFNDEF DebugVersion
      jz      INST_Add_NoCode
   ENDIF
   mov     si, offset TXT_ADD_Code
   call    MBR_Teletype
   call    INST_Add_InstallCodeImage
   mov     si, offset TXT_Okay
   call    MBR_Teletype
   inc     di
  INST_Add_NoCode:
   test    Install_Config, 1
   jz      INST_Add_NoConfig
      mov     si, offset TXT_ADD_Config
      call    MBR_Teletype
      call    INST_Add_InstallConfigImage
      mov     si, offset TXT_Okay
      call    MBR_Teletype
      inc     di
  INST_Add_NoConfig:
   or      di, di
   jz      INST_Add_NothingDone
   mov     si, offset TXT_ADD_SetupOkay
   call    MBR_Teletype
   mov     si, offset TXT_ADD_Finished
   call    MBR_Teletype
   ret

  INST_Add_NothingDone:
   mov     si, offset TXT_ADD_NothingToDo
   call    MBR_Teletype
   mov     si, offset TXT_ADD_NoneFin
   call    MBR_Teletype
   ret
INST_Add_DoIt                  EndP


INST_Add_InstallCodeImage      Proc Near  Uses ds si es di
   ; Berechnet neue Code-CheckSum
   push    ImageBaseSeg
   pop     ds
   mov     si, 512                   ; Sector 2 (Start of Code-Image)
   xor     bx, bx
   movzx   cx, bptr ds:[TotalSectorsUsedPtr]
 INST_AICI_CalcCodeCheck:
      call    MBR_GetCheckOfSector
   loop    INST_AICI_CalcCodeCheck
   mov     ds:[0011h], bx            ; CheckSum gesetzt
   call    INST_Add_FixMyImageMBR    ; Partition-Tabelle von original Sektor
   ; -------------------------------------------------------------------------
   mov     cx, 0001h                 ; Cylinder 0, Sektor 1
   mov     dx, 0080h                 ; Head 0, Drive 80 (MBR Write)
   push    ImageBaseSeg
   pop     es
   mov     bx, ImageBasePtr
   ; ...Schreibt den neuen MBR...
   call    MBR_SaveSector

   ; ...und schreibt' die folgenden Sektoren...
   xor     di, di
   movzx   ax, bptr es:[TotalSectorsUsedPtr]
  INST_AICI_WriteImageLoop:
      call    MBR_SaveSector
      inc     di
   cmp     di, ax
   jbe     INST_AICI_WriteImageLoop
   ret
INST_Add_InstallCodeImage      EndP

INST_Add_InstallConfigImage    Proc Near  Uses ds si es di
   ; Calculate new Config-CheckSum
   push    ImageBaseSeg
   pop     ds
   mov     si, ImageBasePtr
   add     si, 6C00h                 ; Configuration Location
   mov     wptr ds:[si+20], 0        ; delete current CheckSum
   xor     bx, bx
   mov     cx, 5
  INST_AICI_CalcConfigCheck:
      call    MBR_GetCheckOfSector
   loop    INST_AICI_CalcConfigCheck
   mov     ds:[ImageBasePtr+6C00h+20], bx ; new checksum set
   ; -------------------------------------------------------------------------
   mov     cx, 0037h                 ; Cylinder 0, Sektor 55
   mov     dx, 0080h                 ; Head 0, Drive 80 (CONFIG Write)
   push    ImageBaseSeg
   pop     es
   mov     bx, ImageBasePtr
   add     bx, 6C00h                 ; Config-Location in Memory
   call    MBR_SaveSector            ; Configuration
   call    MBR_SaveSector            ; Partition Table 1
   call    MBR_SaveSector            ; Partition Table 2
   call    MBR_SaveSector            ; Hide-Partition Table 1
   call    MBR_SaveSector            ; Hide-Partition Table 2
   call    MBR_SaveSector            ; MBR BackUp (just to be sure, no valid is there)
   ret
INST_Add_InstallConfigImage    EndP

INST_Add_FixMyImageMBR         Proc Near  Uses ds si es di
   push    MBR_CurrentSectorsSeg
   pop     ds
   xor     si, si                        ; DS:SI - CurrentSectorsSegment
   push    ImageBaseSeg
   pop     es
   mov     di, ImageBasePtr
   add     si, 1B8h                      ; 1B8h - Windoze NT Mickeysoft hdd signature
   add     di, 1B8h                      ; 1BEh - Real Partition Table start
   mov     cx, 72                        ; 66 without Mickeysoft signature
   rep     movsb                         ; kopiert die Partitionstabelle in AiR-BOOT
   ret
INST_Add_FixMyImageMBR         EndP


;       Out: Zero Flag SET if Harddisc failed 62-sectors test
INST_Status_CheckHarddisc       Proc Near  Uses
   mov     ah, 08h
   mov     dl, 80h
   int     13h
   and     cl, 111111b
   mov     ah, 1
   cmp     cl, 62
   jae     IS_CheckHarddisc_Success
   xor     ah, ah
  IS_CheckHarddisc_Success:
   or      ah, ah
   ret
INST_Status_CheckHarddisc      EndP

;        In: CH = Cylinder, CL = Sector, ES:BX = Sector Ptr
;            DH = Head, DL = Drive
MBR_LoadSector                 Proc Near  Uses ax es
  MBR_LoadSector_Retry:
   push    bx cx dx
      mov     ax, 0201h  ; load one sector
      int     13h
      jnc     MBR_LoadSector_Success
      mov     ah, 00h    ; reset disc
      mov     dl, 00h
      int     13h
   pop     dx cx bx
   jmp     MBR_LoadSector_Retry
     MBR_LoadSector_Success:
   pop     dx cx bx
   add     bx, 512
   inc     cl      ; sector fixing must be done manual
   ret
MBR_LoadSector                 EndP

;        In: CH = Cylinder, CL = Sector, ES:BX = Sector Ptr
;            DH = Head, DL = Drive
MBR_SaveSector                 Proc Near  Uses ax es
  MBR_SaveSector_Retry:
   push    bx cx dx
      mov     ax, 0301h  ; save one sector
      int     13h
      jnc     MBR_SaveSector_Success
      mov     ah, 00h    ; reset disc
      mov     dl, 00h
      int     13h
   pop     dx cx bx
   jmp     MBR_SaveSector_Retry
     MBR_SaveSector_Success:
   pop     dx cx bx
   add     bx, 512
   inc     cl      ; sector fixing must be done manual
   ret
MBR_SaveSector                 EndP

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

code_seg	ends
		end	air_boot_inst
