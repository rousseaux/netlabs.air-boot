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
;                                          AiR-BOOT SETUP / ALL SETUP MENUS
; v001 - English - by Martin Kiewitz
;---------------------------------------------------------------------------

; Main Setup - Items - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUP_PartitionSetup       db 'PARTITION SETUP', 0
TXT_SETUP_BasicOptions         db 'BASIC OPTIONS', 0
TXT_SETUP_AdvOptions           db 'ADVANCED OPTIONS', 0
TXT_SETUP_ExtOptions           db 'EXTENDED BOOT OPTIONS', 0
TXT_SETUP_DefMasterPwd         db 'DEFINE MASTER PASSWORD', 0
TXT_SETUP_DefBootPwd           db 'DEFINE BOOT PASSWORD', 0
TXT_SETUP_SaveAndExit          db 'SAVE & EXIT SETUP', 0
TXT_SETUP_JustExit             db 'EXIT WITHOUT SAVING', 0

; The Letters for all flags in Partition Setup
TXT_SETUP_FlagLetterBootable   equ 'B'
TXT_SETUP_FlagLetterVIBR       equ 'V'
TXT_SETUP_FlagLetterHide       equ 'H'
TXT_SETUP_FlagLetterDrvLetter  equ 'L'
TXT_SETUP_FlagLetterExtMShack  equ 'P'

TXT_SETUP_LetterYes            equ 'Y'
TXT_SETUP_LetterYes2           equ 'Z'
TXT_SETUP_LetterNo             equ 'N'

; Basic Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_DefaultSelection     db 'Default Selection', 0
TXT_SETUP_TimedBoot            db 'Timed Boot', 0
TXT_SETUP_TimedBootDelay       db 'Timed Boot Delay (sec)', 0
TXT_SETUP_TimedKeyHandling     db 'Timed Key Handling', 0
TXT_SETUP_BootLastIfTimed      db 'Boot From Last If Timed', 0
TXT_SETUP_RememberLastBoot     db 'Remember Last Boot', 0
TXT_SETUP_RememberTimedBoot    db 'Remember Timed Boot', 0
TXT_SETUP_IncludeFloppy        db 'Include Floppy Drive', 0
TXT_SETUP_ShowLVMDriveLetters  db 'Show LVM Drive Letters',0
TXT_SETUP_MbrProtection        db 'MBR Protection', 0
TXT_SETUP_IgnoreMbrWrites      db '-> Ignore MBR Writes', 0
TXT_SETUP_MakeSounds           db 'Make Sounds', 0
TXT_SETUP_CooperBars           db 'Cooper Bars', 0

; Advanced Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_BootMenu             db 'Boot Menu', 0
TXT_SETUP_PartAutoDetect       db 'Partitions Autodetect', 0
TXT_SETUP_SecurityOptions      db '-> Security Options <-', 0
TXT_SETUP_PasswordedSetup      db 'Passworded Setup', 0
TXT_SETUP_PasswordedSystem     db 'Passworded System', 0
TXT_SETUP_PasswordedChangeBoot db 'Passworded Change Boot', 0
TXT_SETUP_GetFloppyName        db 'Get Floppy Name', 0
TXT_SETUP_GetFloppyName2Sec    db '-> Get Every 2 Seconds', 0
TXT_SETUP_VirusDetect          db 'Virus Detection', 0
TXT_SETUP_StealthDetect        db 'Stealth Detection', 0
TXT_SETUP_VIBRdetect           db 'VIBR Detection', 0
TXT_SETUP_ContinueBIOSboot     db 'Continue BIOS Boot Seq', 0

; Extended Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
; [Linux support removed since v1.02]
;TXT_SETUP_LinuxKernelPart      db 'Linux Kernel Partition', 0
;TXT_SETUP_LinuxDefaultKernel   db 'Linux Default Kernel', 0
;TXT_SETUP_LinuxRootPart        db 'Linux Root Partition', 0
; This here may be larger than 23 chars...
;TXT_SETUP_DefLinuxCmd          db 'DEFINE COMMAND LINE FOR LINUX', 0
TXT_SETUP_IgnoreLVM            db 'Ignore LVM information', 0
;~ TXT_SETUP_ForceLBAUsage        db 'Force BIOS-LBA Usage', 0
TXT_SETUP_ExtPartMShack        db 'Ext-Part MS Workaround', 0

; DYNAMIC LENGTH, maximum 11 chars excluding ending zero
;----------------------------------|---------|------------------------------
TXT_SETUP_MAGIC_Enabled        db 'Enabled', 0
TXT_SETUP_MAGIC_Disabled       db 'Disabled', 0
TXT_SETUP_MAGIC_Detailed       db 'Detailed', 0
TXT_SETUP_MAGIC_NoBootable     db 'No Bootable', 0
; [Linux support removed since v1.02]
;TXT_SETUP_MAGIC_NoLinux        db 'No Linux', 0
TXT_SETUP_MAGIC_DoNothing      db 'Do Nothing', 0
TXT_SETUP_MAGIC_ResetTime      db 'Reset Time', 0
TXT_SETUP_MAGIC_StopTime       db 'Stop Time', 0
TXT_SETUP_MAGIC_CDROM          db 'CD-ROM', 0
TXT_SETUP_MAGIC_Network        db 'Network', 0
TXT_SETUP_MAGIC_ZIPLS          db 'ZIP/LS120', 0
; Max Length: 10 (used in Hide-Configuration as well)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Hidden         db 'Hidden', 0
TXT_SETUP_MAGIC_Unhidden       db 'Unhidden', 0
; Max Length: 10 ("C:" will be appended afterwards)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Set            db 'set ', 0

; Setup Control Help - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUPHELP_Main             db 24,32,25,32,26,32,27,' : Choose Action', 0
                               db               'Enter   : Select Action', 0
                               db               'F10 : Save&Exit Setup', 0
                               db               'Esc : Quit Setup', 0

TXT_SETUPHELP_SubMenu          db 24,32,25,32,26,32,27,' : Choose Item', 0
                               db               'PgUp/Dn : Change Item', 0
                               db               'F1  : Show help for Item', 0
                               db               'Esc : Return to main-menu', 0

TXT_SETUPHELP_PartSetup        db 24,32,25,32,26,32,27,' : Choose partition', 0
                               db               'Enter   : Edit label', 0
                               db               'F1  : Flags (press key to toogle)', 0
                               db               'Esc : Return to main-menu', 0

; HELP FOR EVERY MENU-ITEM, Maximum Length = 22 chars PER line. Maximum 5 lines

                                  ;1234567890123456789012
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_PartitionSetup   db 'Make your partitions', 0
                               db 'bootable, change their', 0
                               db 'name, define hiding', 0
                               db 'and much more.', 0
                               db 0
TXT_SETUPHELP_BasicOptions     db 'These options are for', 0
                               db 'non-experienced users.', 0
                               db 0
TXT_SETUPHELP_AdvOptions       db 'These are for advanced', 0
                               db 'users. If you do not', 0
                               db 'what they do, leave', 0
                               db 'them like they are.', 0
                               db 0
TXT_SETUPHELP_ExtOptions       db 'Extended options for', 0
                               db 'specific OSes.', 0
                               db 0
TXT_SETUPHELP_DefMasterPwd     db 'Define a password for', 0
                               db 'access to setup and', 0
                               db 'system.', 0
                               db 0
TXT_SETUPHELP_DefBootPwd       db 'Define a password for', 0
                               db 'access to system.', 0
                               db 0
TXT_SETUPHELP_SaveAndExit      db 'Will continue boot-', 0
                               db 'process and save the', 0
                               db 'current options.', 0
                               db 0
TXT_SETUPHELP_JustExit         db 'Will continue, but', 0
                               db 'discard any changes', 0
                               db 'done to options.', 0
                               db 0

TXT_SETUPHELP_InPartitionSetup db 'B - Bootable', 0
                               db 'V - VIBR-Detection', 0
                               db 'H - Hidden Support', 0
                               db 'L - Partition Letter', 0
                               db 'P - Ext-Part MS invent', 0
                               db 0

TXT_SETUPHELP_HideSetup        db 'Select the state at', 0
                               db 'which the partitions', 0
                               db 'shall be, when the', 0
                               db 'currently selected', 0
                               db 'partition is booted.', 0
                               db 0

; Basic Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_DefaultSelection db 'Changes your default', 0
                               db 'selection. It can be', 0
                               db 'used on Timed Boot.', 0
                               db 0
TXT_SETUPHELP_TimedBoot        db 'AiR-BOOT will proceed', 0
                               db 'automatically after a', 0
                               db 'specified delay.', 0
                               db 0
TXT_SETUPHELP_TimedBootDelay   db 'The mentioned delay', 0
                               db 'for Timed Boot.', 0
                               db 0
TXT_SETUPHELP_TimedKeyHandling db 'If you press a key in', 0
                               db 'Boot Menu, when using', 0
                               db 'TimedBoot, what shall', 0
                               db 'AiR-BOOT do ?', 0
                               db 0
TXT_SETUPHELP_BootLastIfTimed  db 'AiR-BOOT will use the', 0
                               db 'last-booted partition', 0
                               db 'when timed booting.', 0
                               db 'Otherwise it will use', 0
                               db 'the default one.', 0
                               db 0
TXT_SETUPHELP_RememberLastBoot db 'AiR-BOOT will put', 0
                               db 'the menu-bar on the', 0
                               db 'last booted partition', 0
                               db 'at startup.', 0
                               db 0
TXT_SETUPHELP_RememberTimeBoot db 'Like the last option,', 0
                               db 'AiR-BOOT will save', 0
                               db 'the bar on timed', 0
                               db 'boots, too.', 0
                               db 0
TXT_SETUPHELP_IncludeFloppy    db 'AiR-BOOT will allow', 0
                               db 'booting from A: via', 0
                               db 'menu.', 0
                               db 0
TXT_SETUPHELP_ShowLVMDriveLetters   db 'AiR-BOOT will show', 0
                                    db 'LVM Drive Letters', 0
                                    db 'in the menu.', 0
                                    db 0
TXT_SETUPHELP_MbrProtection    db 'Protects your MBR via', 0
                               db 'resident code. Needs', 0
                               db '1 KByte of base-memory', 0
                               db 'May be incompatible', 0
                               db 'with some OS.', 0
                               db 0
TXT_SETUPHELP_IgnoreMbrWrites  db 'If this is enabled,', 0
                               db 'all writes will get', 0
                               db 'ignored, otherwise', 0
                               db 'system will "crash".', 0
                               db 0
TXT_SETUPHELP_MakeSounds       db 'AiR-BOOT is able to', 0
                               db 'make sounds using your', 0
                               db 'internal speaker.', 0
                               db 0
TXT_SETUPHELP_CooperBars       db 'Will make some fancy', 0
                               db 'effect during bootup.', 0
                               db 0

; Advanced Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_BootMenu         db 'Disabled will not show', 0
                               db 'menu and directly boot', 0
                               db 'default partition.', 0
                               db 'Detailed will show', 0
                               db 'more information.', 0
                               db 0
TXT_SETUPHELP_PartAutoDetect   db 'If AiR-BOOT finds new', 0
                               db 'partitions, it will', 0
                               db 'make them boot-able.', 0
                               db 0
TXT_SETUPHELP_PasswordedSetup  db 'When entering this', 0
                               db 'setup, you will be', 0
                               db 'asked for a password.', 0
                               db 0
TXT_SETUPHELP_PasswordedSystem db 'When booting your', 0
                               db 'computer, you will', 0
                               db 'be asked for it.', 0
                               db 0
TXT_SETUPHELP_PasswordedBoot   db 'When not Timed Booting', 0
                               db 'you will get asked.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName    db 'When showing floppy', 0
                               db 'disc in boot-menu,', 0
                               db 'AiR-BOOT will get the', 0
                               db 'floppy name.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName2Sec db 'Additionally it will', 0
                               db 'update the floppy name', 0
                               db 'every 2 seconds.', 0
                               db 0
TXT_SETUPHELP_VirusDetect      db 'Will detect normal', 0
                               db 'virus (lame ones).', 0
                               db 0
TXT_SETUPHELP_StealthDetect    db 'Will detect Stealth', 0
                               db 'virus.', 0
                               db 0
TXT_SETUPHELP_VIBRdetect       db 'Will detect VIBR.', 0
                               db 'VIBR stands for', 0
                               db 'Virus-In-Boot-Record.', 0
                               db 0
TXT_SETUPHELP_ContinueBIOSboot db 'If activated, this', 0
                               db 'option will return', 0
                               db 'control to BIOS for', 0
                               db 'the specified device.', 0
                               db 0

; Extended Options - Help
;----------------------------------|--------------------|-------------------
; [Linux support removed since v1.02]
;TXT_SETUPHELP_LinuxKernelPart  db 'Defines the FAT-16', 0
;                               db 'partition that holds', 0
;                               db 'your Linux kernels.', 0
;                               db 0
;TXT_SETUPHELP_LinuxDefaultKrnl db 'Defines your default', 0
;                               db 'kernel filename.', 0
;                               db 0
;TXT_SETUPHELP_LinuxRootPart    db 'Changes your Linux', 0
;                               db 'root partition.', 0
;                               db 0
;TXT_SETUPHELP_DefLinuxCmd:     db 'Defines the command', 0
;                               db 'line for Linux, if', 0
;                               db 'available.', 0
;                               db 0
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_IgnoreLVM        db 'If activated, AiR-BOOT', 0
                               db 'won''t even look for', 0
                               db 'LVM information.', 0
                               db 0
;~ TXT_SETUPHELP_ForceLBAUsage    db 'Forces the usage of', 0
                               ;~ db 'BIOS LBA APIs instead', 0
                               ;~ db 'of mixed usage of CHS', 0
                               ;~ db 'and LBA.', 0
                               ;~ db 0
TXT_SETUPHELP_ExtPartMShack    db 'Enables dynamic change', 0
                               db 'of the ext. partition', 0
                               db 'type id to standard or', 0
                               db 'MS-invention.', 0
                               db '(defined by P-flag)', 0
                               db 0

; Maximum 26 chars (should not be reached)
;----------------------------------|------------------------|---------------
TXT_SETUPHELP_Base             db ' HELP ', 0
TXT_SETUPHELP_Enter            db '<ENTER>', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_PasswordOld          db 'Old Password:', 0
TXT_SETUP_PasswordDefine       db 'Define Password:', 0
TXT_SETUP_PasswordVerify       db 'Verify Password:', 0
TXT_SETUP_PasswordIncorrect    db 'Old Password Incorrect, Sorry', 0
TXT_SETUP_PasswordMismatch     db 'Mismatched, Old Password Retained', 0
TXT_SETUP_PasswordDisabled     db 'No Password -> Protection Disabled', 0
TXT_SETUP_PasswordMatched      db '** Matched, New Password Set **', 0

; Maximum 60 chars (should not be reached anyway)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_SaveAndExitNow       db 'SAVE & EXIT NOW', 0
TXT_SETUP_QuitWithoutSaveNow   db 'QUIT WITHOUT SAVE', 0
; Must be shorter than SaveAndExitNow / QuitWithoutSaveNow
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_AreYouSure1          db 'ARE YOU SURE?', 0
TXT_SETUP_AreYouSure2          db '(Y/N)', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
; [Linux support removed since v1.02]
;TXT_SETUP_EnterLinuxCmdLine    db 'Please enter/modify your Linux command-line:', 0
;TXT_SETUP_NoLinuxInstalled     db 'You do not have Linux installed', 0
TXT_SETUP_NoLDLpartition       db 'The selected partition is not HPFS/FAT16/JFS', 0

;;;;;;;;;

; Maximum 34 chars (should not be reached)
;----------------------------------|--------------------------------|-------
TXT_SETUP_HideFeature          db 'Hide Feature', 0
;----------------------------------|---------------------|------------------
TXT_SETUP_HideFeature2         db 'State when booting ', 0

; Drive-Letter Menu Header - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUP_DriveLetter          db 'Partition Letter', 0

; Drive-Letter Keys - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUPHELP_DriveLetter      db 'Press C-Z', 0

; Colors for special words hard-coded. Keep all 0s.
;TXT_SETUP_LowerMessage      db 0,'Free',0,' private usage, but NOT for people that are/were working for US government',0
;                            db 'This software is released under ', 0, 'GPLv3+.', 0
;                            db 'For more information and source, please visit', 0
;                            db 'http://AiR-BOOT.sourceforge.net', 0
;                            db 'Contact via e-mail: ', 0, 'm_kiewitz [AT] users.sourceforge.net', 0
