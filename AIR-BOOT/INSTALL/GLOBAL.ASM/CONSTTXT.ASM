Public TXT_Okay,                    TXT_CR
Public TXT_START_Copyright;
Public TXT_START_NoPhysicalDrives;
Public TXT_START_LoadCode;
Public TXT_START_LoadImage,         TXT_START_LoadMBR
Public TXT_STATUS_Main
Public TXT_STATUS_Code,             TXT_STATUS_Config
Public TXT_STATUS_Language,         TXT_STATUS_Intact
Public TXT_STATUS_nintact,          TXT_STATUS_ninstall
Public TXT_STATUS_Update,           TXT_STATUS_Hd2Small
Public TXT_STATUS_EZSETUP
IFDEF Flat
   Public TXT_InstallHalted
  ELSE
   Public TXT_SystemHalted
ENDIF
Public TXT_Language_US,             TXT_Language_DT
Public TXT_Language_DE,             TXT_Language_FR
Public TXT_Language_IT,             TXT_Language_RU
Public TXT_Language_Huh
Public TXT_Virus_Main,              TXT_Virus_Normal
Public TXT_Virus_Severe,            TXT_Virus_Always
Public TXT_MBRfail_Normal,          TXT_MBRfail_Strike
Public TXT_MBRfail_Buuuhh,          TXT_MBRfail_Argh
Public TXT_MENU_Main
Public TXT_MENU_Add,                TXT_MENU_Repair
Public TXT_MENU_Update,             TXT_MENU_OnCurSystem
Public TXT_MENU_Delete,             TXT_MENU_Quit
Public TXT_PROCESS_Split,           TXT_PROCESS_Add
Public TXT_ADD_Code,                TXT_ADD_Config
Public TXT_ADD_NothingToDo,         TXT_ADD_SetupOkay
Public TXT_ADD_NoneFin,             TXT_ADD_Finished
Public TXT_DELETE_NotPossible

TXT_Okay                       db 'ok'
TXT_CR                         db 13, 10, 0

IFDEF Flat
   TXT_START_Copyright            db 'AiR-BOOT Installer/2 v1.00 for AiR-BOOT', 13, 10
                                  db ' - (c) Copyright ''98-''02 by Martin Kiewitz.', 13, 10
                                  db 13, 10
                                  db '-> ...Please wait... <-', 13, 10, 0
ENDIF
TXT_START_NoPhysicalDrives     db ' - No physical drives found on this system. Install impossible.', 13, 10, 0
TXT_START_LoadCode             db ' - Loading code from disc...', 0
TXT_START_LoadImage            db ' - Loading image from disc...', 0
TXT_START_LoadMBR              db ' - Loading MBR from harddisc...', 0
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

TXT_Language_US                db 'english', 0
TXT_Language_DT                db 'dutch', 0
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
TXT_PROCESS_Add                db 'Add/Repair/Update AiR-BOOT in Progress...', 13, 10, 0

TXT_ADD_Code                   db ' þ Writing AiR-BOOT Code...', 0
TXT_ADD_Config                 db ' þ Writing AiR-BOOT Configuration...', 0
TXT_ADD_NothingToDo            db ' þ All components of AiR-BOOT are intact and up-to-date. Nothing to do.', 13, 10, 0
TXT_ADD_SetupOkay              db 13, 10
                               db 'Your copy of AiR-BOOT is now fully functional.', 13, 10, 0
TXT_ADD_NoneFin                db 13, 10
IFDEF Flat
   TXT_ADD_Finished               db 'You may shutdown your system and reboot to access AiR-BOOT.', 13, 10
                                  db 'Please hit ENTER to exit Installer/2...', 13, 10, 0
  ELSE
   TXT_ADD_Finished               db 'Please remove disc and hit ENTER to directly boot via AiR-BOOT...', 0
ENDIF

IFDEF Flat
   TXT_DELETE_NotPossible         db ' þ Removing AiR-BOOT automatically is not possible at this time.', 13, 10
                                  db '    The backup file AIRBOOT.OMB was not found. You may remove AiR-BOOT manually', 13, 10
                                  db '    by entering "FDISK /MBR" or "LVM /NEWMBR" in commandline.', 13, 10
                                  db 13, 10
                                  db 'Please hit ENTER to exit Installer/2...', 0
  ELSE
   TXT_DELETE_NotPossible         db ' þ Removing AiR-BOOT automatically is not possible at any time.', 13, 10
                                  db '    Boot your favourite OS and restore/overwrite the MBR manually.', 13, 10
                                  db '    As for DOS/Windows 9x: enter "FDISK /MBR" in commandline.', 13, 10
                                  db '    As for OS/2: enter "FDISK /MBR" or "LVM /NEWMBR" in commandline.', 13, 10
                                  db '    For other OSes, please consult the corresponding manual.', 13, 10
                                  db 13, 10
                                  db 'Please hit ENTER to continue boot-process...', 0
ENDIF

MBR_AiRBOOTCodeSig              db 'AiRBOOT'
MBR_AiRBOOTCodeSigLen          equ  7
MBR_EZSETUPCodeSig              db '528+Mbyte(C)1993,94 Micro House Int',39,'l',0
MBR_EZSETUPCodeSigLen          equ 38
MBR_AiRBOOTConfigSig            db 'AiRCFG-TABLE­'
MBR_AiRBOOTConfigSigLen        equ 13

