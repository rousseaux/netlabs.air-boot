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
;---------------------------------------------------------------------------
;                                           AiR-BOOT SETUP / MENU STRUCTURE
;---------------------------------------------------------------------------

; Format of a Menu Item:
; =======================
;    RoutinePtr            :WORD      - Points to Modification/Exec-Routine
;                                        if 0, item is empty and will get skiped
;    VariablePtr           :WORD      - Points to actual Item-Data
;                                        if 0, no ItemPack. Is used for e.g.
;                                        main menu items and will exec only
;    ItemNamePtr           :WORD      - Points to Item-Name
;    ItemHelpPtr           :WORD      - Points to Item-Help Text
;    If VariablePtr>0:
;       ItemPack           :BYTE*12   - Spaceholder for displaying
;
;
; Example:
;  dw offset MBRS_Magic_ChangePartition, offset CFG_PartDefault
;  dw offset TXT_SETUP_DefaultPart, offset TXT_SETUPHELP_DefaultPart
;  dw 6 dup (0)
;
; Will be a normal item-entry (not a menu-entry).
; If modified MBRS_Magic_ChangePartition will get called and CFG_PartDefault
;  will get modified according to the users key press.
; The name of the item will be taken from TXT_SETUP_DefaultPart and if help is
;  requested TXT_SETUPHELP_DefaultPart will get shown.
;
;
; Further Example:
;  dw offset MBRS_Routines_EnterMenu_PartitionSetup, 0
;  dw offset TXT_SETUP_PartitionSetup, offset TXT_SETUPHELP_PartitionSetup
;
; Will be a menu-entry (due VariablePtr==0)
; If enter is pressed MBRS_Routines_EnterMenu_PartitionSetup will get called
; The name of the menu-entry will be taken from TXT_SETUP_PartitionSetup and
;  if help is requested TXT_SETUPHELP_PartitionSetup will get shown.
;

IFDEF ModuleNames
DB 'MENUS',0
ENDIF

LocMENU_LenOfMenuPtrBlock    equ          8
LocMENU_LenOfItemPack        equ         12
LocMENU_RoutinePtr           equ          0
LocMENU_VariablePtr          equ          2
LocMENU_ItemNamePtr          equ          4
LocMENU_ItemHelpPtr          equ          6
LocMENU_ItemPack             equ          8 ; only if VariablePtr>0

SETUP_MainMenu:
                db      0                ; Where Current Item will get saved
                dw      offset TXT_SETUPHELP_MAIN ; Pointer to help information
                ; The Menu-Items start here...
                dw      offset SETUP_EnterMenu_PartitionSetup, 0
                dw      offset TXT_SETUP_PartitionSetup, offset TXT_SETUPHELP_PartitionSetup
                dw      0, 0
                dw      0, 0
                dw      offset SETUP_EnterMenu_BasicOptions, 0
                dw      offset TXT_SETUP_BasicOptions, offset TXT_SETUPHELP_BasicOptions
                dw      0, 0
                dw      0, 0
                dw      offset SETUP_EnterMenu_AdvancedOptions, 0
                dw      offset TXT_SETUP_AdvOptions, offset TXT_SETUPHELP_AdvOptions
                dw      0, 0
                dw      0, 0
                dw      offset SETUP_EnterMenu_ExtendedOptions, 0
                dw      offset TXT_SETUP_ExtOptions, offset TXT_SETUPHELP_ExtOptions
                ; The Menu-Items of the right side start here...
                dw      offset SETUP_EnterMenu_DefineMasterPassword, 0
                dw      offset TXT_SETUP_DefMasterPwd, offset TXT_SETUPHELP_DefMasterPwd
                dw      0, 0
                dw      0, 0
                dw      offset SETUP_EnterMenu_DefineBootPassword, 0
                dw      offset TXT_SETUP_DefBootPwd, offset TXT_SETUPHELP_DefBootPwd
                dw      0, 0
                dw      0, 0
                dw      offset SETUP_EnterMenu_SaveAndExitSetup, 0
                dw      offset TXT_SETUP_SaveAndExit, offset TXT_SETUPHELP_SaveAndExit
                dw      0, 0
                dw      0, 0
                dw      offset SETUP_EnterMenu_ExitWithoutSaving, 0
                dw      offset TXT_SETUP_JustExit, offset TXT_SETUPHELP_JustExit

SETUP_BasicOptions:
                db      0                ; Where Current Item will get saved
                dw      offset TXT_SETUPHELP_SUBMENU ; Pointer to help info
                ; The Menu-Items start here...
                dw      offset SETUPMAGIC_ChangeDefaultSelection, offset CFG_PartDefault
                dw      offset TXT_SETUP_DefaultSelection, offset TXT_SETUPHELP_DefaultSelection
                dw      6 dup (0)
                ; ATTENTION: ChangeDefaultSelection is redrawn hardcoded in
                ;             SETUPMAGIC_ChangeFloppyDisplay.
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_TimedBoot
                dw      offset TXT_SETUP_TimedBoot, offset TXT_SETUPHELP_TimedBoot
                dw      6 dup (0)
                dw      offset SETUPMAGIC_ChangeBootDelay, offset CFG_TimedSecs
                dw      offset TXT_SETUP_TimedBootDelay, offset TXT_SETUPHELP_TimedBootDelay
                dw      6 dup (0)
                dw      offset SETUPMAGIC_ChangeTimedKeyHandling, offset CFG_TimedKeyHandling
                dw      offset TXT_SETUP_TimedKeyHandling, offset TXT_SETUPHELP_TimedKeyHandling
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_TimedBootLast
                dw      offset TXT_SETUP_BootLastIfTimed, offset TXT_SETUPHELP_BootLastIfTimed
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_RememberBoot
                dw      offset TXT_SETUP_RememberLastBoot, offset TXT_SETUPHELP_RememberLastBoot
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_RememberTimed
                dw      offset TXT_SETUP_RememberTimedBoot, offset TXT_SETUPHELP_RememberTimeBoot
                dw      6 dup (0)
                ; The Menu-Items of the right side start here...
                dw      offset SETUPMAGIC_ChangeFloppyDisplay, offset CFG_IncludeFloppy
                dw      offset TXT_SETUP_IncludeFloppy, offset TXT_SETUPHELP_IncludeFloppy
                dw      6 dup (0)
                dw      0, 0
                dw      0, 0
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_ProtectMBR
                dw      offset TXT_SETUP_MBRprotection, offset TXT_SETUPHELP_MBRprotection
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_IgnoreWriteToMBR
                dw      offset TXT_SETUP_IgnoreMBRwrites, offset TXT_SETUPHELP_IGNOREMBRWRITES
                dw      6 dup (0)
                dw      0, 0
                dw      0, 0
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_MakeSound
                dw      offset TXT_SETUP_MakeSounds, offset TXT_SETUPHELP_MakeSounds
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_CooperBars
                dw      offset TXT_SETUP_CooperBars, offset TXT_SETUPHELP_CooperBars
                dw      6 dup (0)

SETUP_AdvancedOptions:
                db      0                ; Where Current Item will get saved
                dw      offset TXT_SETUPHELP_SUBMENU ; Pointer to help info
                ; The Menu-Items start here...
                dw      offset SETUPMAGIC_ChangeBootMenu, offset CFG_BootMenuActive
                dw      offset TXT_SETUP_BootMenu, offset TXT_SETUPHELP_BootMenu
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_PartitionsDetect
                dw      offset TXT_SETUP_PartAutoDetect, offset TXT_SETUPHELP_PartAutoDetect
                dw      6 dup (0)
                dw      0, 0
                dw      0, 0
                ; Separator Line
                dw      0, 0
                dw      offset TXT_SETUP_SECURITYOPTIONS, 0
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_PasswordSetup
                dw      offset TXT_SETUP_PasswordedSetup, offset TXT_SETUPHELP_PasswordedSetup
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_PasswordSystem
                dw      offset TXT_SETUP_PasswordedSystem, offset TXT_SETUPHELP_PasswordedSystem
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_PasswordChangeBoot
                dw      offset TXT_SETUP_PasswordedChangeBoot, offset TXT_SETUPHELP_PasswordedBoot
                dw      6 dup (0)
                ; The Menu-Items of the right side start here...
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_FloppyBootGetName
                dw      offset TXT_SETUP_GetFloppyName, offset TXT_SETUPHELP_GetFloppyName
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_FloppyBootGetTimer
                dw      offset TXT_SETUP_GetFloppyName2Sec, offset TXT_SETUPHELP_GetFloppyName2Sec
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_DetectVirus
                dw      offset TXT_SETUP_VirusDetect, offset TXT_SETUPHELP_VirusDetect
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_DetectStealth
                dw      offset TXT_SETUP_StealthDetect, offset TXT_SETUPHELP_StealthDetect
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_DetectVIBR
                dw      offset TXT_SETUP_VIBRdetect, offset TXT_SETUPHELP_VIBRdetect
                dw      6 dup (0)
                dw      0, 0
                dw      0, 0
                dw      offset SETUPMAGIC_ChangeBIOSbootSeq, offset CFG_ResumeBIOSbootSeq
                dw      offset TXT_SETUP_ContinueBIOSboot, offset TXT_SETUPHELP_ContinueBIOSboot
                dw      6 dup (0)


SETUP_ExtendedBootOptions:
                db      0                ; Where Current Item will get saved
                dw      offset TXT_SETUPHELP_SUBMENU ; Pointer to help information
                ; The Menu-Items start here...
; [Linux support removed since v1.02]
;                dw      offset SETUPMAGIC_ChangeLinuxKernelPart, offset CFG_LinuxKrnlPartition
;                dw      offset TXT_SETUP_LinuxKernelPart, offset TXT_SETUPHELP_LinuxKernelPart
;                dw      6 dup (0)
;                dw      offset SETUPMAGIC_ChangeLinuxDefaultKernel, offset CFG_LinuxDefaultKernel
;                dw      offset TXT_SETUP_LinuxDefaultKernel, offset TXT_SETUPHELP_LinuxDefaultKrnl
;                dw      6 dup (0)
;                dw      offset SETUPMAGIC_ChangeLinuxRootPart, offset CFG_LinuxRootPartition
;                dw      offset TXT_SETUP_LinuxRootPart, offset TXT_SETUPHELP_LinuxRootPart
;                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_IgnoreLVM
                dw      offset TXT_SETUP_IgnoreLVM, offset TXT_SETUPHELP_IgnoreLVM
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_ForceLBAUsage            ; Rousseau: LBA
                dw      offset TXT_SETUP_ForceLBAUsage, offset TXT_SETUPHELP_ForceLBAUsage
                dw      6 dup (0)
                dw      offset SETUPMAGIC_EnableDisable, offset CFG_ExtPartitionMShack
                dw      offset TXT_SETUP_ExtPartMShack, offset TXT_SETUPHELP_ExtPartMShack
                dw      6 dup (0)
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                ; The Menu-Items of the right side start here...
                dw      0, 0
                dw      0, 0
; [Linux support removed since v1.02]
                dw      0, 0
                dw      0, 0
;                dw      offset SETUP_EnterMenu_LinuxCommandLine, 0
;                dw      offset TXT_SETUP_DefLinuxCmd, offset TXT_SETUPHELP_DefLinuxCmd
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
                dw      0, 0
