
// щ Д ДДДДНН = Д  щ  Д = ННДДДД Д щ
// і                               і
//    ЬЫЫЫЫЫЫЫЬ   ЬЫЬ  ЬЫЫЫЫЫЫЫЫЬ          ъ  ъДДДНДДНДННДДННННДНННННННННОД
// і ЫЫЫЫЯЯЯЫЫЫЫ ЫЫЫЫЫ ЫЫЫЯ   ЯЫЫЫ і           AiR-BOOT - Installer/2    є
// є ЫЫЫЫЬЬЬЫЫЫЫ ЫЫЫЫЫ ЫЫЫЬ   ЬЫЫЫ є      ъ ДДДДНДННДДННННДННННННННДНННННОД
// є ЫЫЫЫЫЫЫЫЫЫЫ ЫЫЫЫЫ ЫЫЫЫЫЫЫЫЫЯ  є       Section: AiR-BOOTUP Package   є
// є ЫЫЫЫ   ЫЫЫЫ ЫЫЫЫЫ ЫЫЫЫ ЯЫЫЫЫЬ є     і Created: 24/10/02             є
// і ЯЫЫЯ   ЯЫЫЯ  ЯЫЯ  ЯЫЫЯ   ЯЫЫЯ і     і Last Modified:                і
//                  ЬЬЬ                  і Number Of Modifications: 000  і
// щ              ЬЫЫЯ             щ     і INCs required: *none*         і
//      ДДДДДДД ЬЫЫЯ                     є Written By: Martin Kiewitz    і
// і     ЪїЪїіЬЫЫЫЬЬЫЫЫЬ           і     є (c) Copyright by              і
// є     АЩіАЩЯЫЫЫЯЯЬЫЫЯ           є     є      AiR ON-Line Software '02 ъ
// є    ДДДДДДД    ЬЫЫЭ            є     є All rights reserved.
// є              ЬЫЫЫДДДДДДДДД    є    ДОНННДНННННДННННДННДДНДДНДДДъДД  ъ
// є             ЬЫЫЫЭі іЪїііД     є
// і            ЬЫЫЫЫ АДііАЩіД     і
//             ЯЫЫЫЫЭДДДДДДДДДД     
// і             ЯЯ                і
// щ Дґ-=’iз йп-Liпо SйџвW’зо=-ГДД щ

#define INCL_NOPMAPI
#define INCL_BASE
#include <os2.h>
#include <bsesub.h>
#include <malloc.h>

#define INCLUDE_STD_MAIN
#include <global.h>
#include <msg.h>

#include <asm\main.h>
#include <physdisk.h>
#include <shutdown.h>
#include <airboot_msg.h>

UCHAR Inkey (void) {
   KBDKEYINFO UserKey;

   KbdCharIn(&UserKey,0,0);
   return UserKey.chChar;
 }

BOOL INST_Start_LoadMBR (void) {
   USHORT IOCTLHandle;
   USHORT NumDrives;
   USHORT SectorsPerTrack;

   NumDrives   = PHYS_EnumeratePhysicalDisks();
   if (NumDrives==0) {
      MSG_Print (TXT_START_NoPhysicalDrives);
      return FALSE;
    }

   IOCTLHandle = PHYS_GetIOCTLHandle("1:");
   SectorsPerTrack = PHYS_GetGeometrySectorsPerTrack(IOCTLHandle);
   if (SectorsPerTrack>61) {
      if (!PHYS_ReadPhysicalSector(IOCTLHandle,0,0,60,(PBYTE)&MBR_CurrentSectors)) {
         puts ("LOAD ERROR!");
         return FALSE;
       }
    } else {
      iStatus_Code     = Status_Impossible;
      Impossible_Cause = TXT_STATUS_Hd2Small;
    }
   PHYS_FreeIOCTLHandle (IOCTLHandle);
   return TRUE;
 }

BOOL INST_Add_WriteMBR (void) {
   USHORT IOCTLHandle;

   IOCTLHandle = PHYS_GetIOCTLHandle("1:");
   if (!PHYS_WritePhysicalSector(IOCTLHandle,0,0,60,(PBYTE)&MBR_CurrentSectors)) {
      puts ("SAVE ERROR!");
      return FALSE;
    }
   PHYS_FreeIOCTLHandle (IOCTLHandle);
   return TRUE;
 }

VOID INST_Status_SetInsert (ULONG iStatus, USHORT iVersion) {
   switch (iStatus) {
    case Status_NotInstalled: {
       MSG_FillInsert (1, TXT_STATUS_ninstall);
       break;
     }
    case Status_Corrupt: {
       MSG_FillInsert (1, TXT_STATUS_nintact);
       break;
     }
    case Status_Installed:
    case Status_InstalledMGU: {
       sprintf (MSG_Insert[0], "%x.%x", iVersion>>8, iVersion & 0x0FF);
       if (iStatus==Status_InstalledMGU)
          MSG_FillInsert (2, TXT_STATUS_Update);
         else
          MSG_Insert[1][0] = 0;
       MSG_FillInsert (1, TXT_STATUS_Intact);
       break;
     }
    case Status_Impossible: {
       MSG_FillInsert (1, Impossible_Cause);
       break;
     }
    default:
    break;
    }
 }

ushort maincode (int argc, char *argv[]) {
   PSZ    ArgumentPtr     = argv[0];
   ULONG  ArgumentLen     = 0;
   UCHAR  UserKey;
   ULONG  BootDrive;
   struct {
      ULONG       ulVSN;
      VOLUMELABEL vol;
    } InfoLevel2;

   // Define message-file...
   if (!MSG_Init("AIRBOOT2.MSG"))
      return 1;

   MSG_Print (TXT_START_Copyright);
   AiRBOOT_ImageSectorsPtr = (PUCHAR)&AiRBOOT_ImageSectors;

   MSG_Print (TXT_START_LoadMBR);
   if (!INST_Start_LoadMBR()) {
      return 1;
    }
   MSG_Print (TXT_Okay);

   // Sets some variables depending on the image that got included into our EXE
   INST_Status_CheckImage();

   // =============================================================
   //                        STATUS
   // =============================================================
   MSG_Print (TXT_STATUS_Main);
   INST_Status_CheckCode();
   INST_Status_SetInsert (iStatus_Code, Installed_CodeVersion);
   MSG_Print (TXT_STATUS_Code);
   if (iStatus_Code==Status_Impossible)
      return 1;
   INST_Status_CheckConfig();
   INST_Status_SetInsert (iStatus_Config, Installed_ConfigVersion);
   MSG_Print (TXT_STATUS_Config);

   // Display language as well, if Code installed
   if ((iStatus_Code==Status_Installed) | (iStatus_Code==Status_InstalledMGU)) {
   MSG_FillInsert (1, INST_Status_GetLanguageName(Installed_LanguageID));
   MSG_Print (TXT_STATUS_Language);
    } else if (iStatus_Code==Status_Impossible)
      return 0;

   // =============================================================
   //                      PRE-CHECKING
   // =============================================================
   if ((iStatus_Code!=Status_Installed) | (Installed_LanguageID!=Image_LanguageID))
      Install_Code = TRUE;      // If LanguageID different or not installed...
   if (iStatus_Config!=Status_Installed)
      Install_Config = TRUE;    // If not installed...

   if ((iStatus_Code==Status_Corrupt) | (iStatus_Config==Status_Corrupt))
      Install_IsCorrupt = TRUE; // If anything is corrupt...

   // =============================================================
   //                         VIRUS
   // =============================================================

   // If-Table:
   //-----------
   //  Code==Not Installed, Config==Not Installed => Check MBR
   //  Code==Installed, Config==Installed => Check MBR (->Virus?)
   //  Code==Not Installed, Config==Installed => (->Virus?)
   //  Code==Installed, Config==Not Installed => Check MBR (->Virus?)
   if ((iStatus_Code==Status_NotInstalled) & (iStatus_Config==Status_NotInstalled)) {
      // Nothing installed, so check MBR, if squashed...
      if (!INST_Virus_CheckCurrentMBR()) {
         MSG_Print (TXT_MBRfail_Argh);
         MSG_Print (TXT_InstallHalted);
         return 1;
       }
    } else {
      if ((iStatus_Code==Status_NotInstalled) | (!INST_Virus_CheckCurrentMBR())) {
         // Code not installed, but Config or MBR squashed...
         //  -> Virus proposed, check for backup (if available)
         MSG_Print (TXT_Virus_Main);
         if (INST_Virus_CheckForStealth())
            MSG_Print (TXT_Virus_Severe);
           else
            MSG_Print (TXT_Virus_Normal);
         MSG_Print (TXT_Virus_Always);
         if (!INST_Virus_CheckCurrentMBR()) {
            // MBR squashed, so check backup and display message
            MSG_Print (TXT_MBRfail_Normal);
            if (INST_Virus_CheckForBackUpMBR()) {
               MSG_Print (TXT_MBRfail_Strike);
               // User selection, Y/N, if he wants to restore MBR
               //  also CID-able
               do {
                  UserKey = Inkey() | 0x20;
                } while (!((UserKey=='y') | (UserKey=='n')));
               if (UserKey=='y')
                  INST_Virus_CopyBackUpMBR();
             } else {
               MSG_Print (TXT_MBRfail_Buuuhh);
             }
          }
       }
    }

   // =============================================================
   //                         MENU
   // =============================================================
   MSG_Print (TXT_MENU_Main);
   sprintf (MSG_Insert[0], "%x.%x", Image_CodeVersion>>8, Image_CodeVersion & 0x0FF);
   MSG_FillInsert (2, INST_Status_GetLanguageName(Image_LanguageID));
   if (Install_IsCorrupt)                         MSG_Print (TXT_MENU_Repair);
      else if (iStatus_Code==Status_NotInstalled) MSG_Print (TXT_MENU_Add);
      else                                        MSG_Print (TXT_MENU_Update);
   MSG_Print (TXT_MENU_Delete);
   MSG_Print (TXT_MENU_Quit);

   // Let user make selection or use CID-mode
   do {
      UserKey = Inkey() | 0x20;
    } while (!((UserKey=='a') | (UserKey=='r') | (UserKey=='u') | (UserKey=='d') | (UserKey=='q')));

   MSG_Print (TXT_PROCESS_Split);
   switch (UserKey) {
    case 'a':
    case 'r':
    case 'u': {
       MSG_Print (TXT_PROCESS_Add);
       if (Install_Code | Install_Config) {
          DosQuerySysInfo (QSV_BOOT_DRIVE, QSV_BOOT_DRIVE, &BootDrive, sizeof(BootDrive));
          // BootDrive - 1-A:, 2-B:, 3-C:
          if ((BootDrive>2) & (!DosQueryFSInfo(BootDrive, FSIL_VOLSER, (PVOID)(&InfoLevel2), sizeof(InfoLevel2)))) {
             AutoDriveLetter       = BootDrive+0x7D;
             AutoDriveLetterSerial = InfoLevel2.ulVSN;
           }
        }
//       Install_Code = TRUE; // <-- always adding only for debug purposes...
       if (Install_Code) {
          MSG_Print (TXT_ADD_Code);
          INST_Add_IncludeCode();
          MSG_Print (TXT_Okay);
        }
       if (Install_Config) {
          MSG_Print (TXT_ADD_Config);
          INST_Add_IncludeConfig();
          MSG_Print (TXT_Okay);
        }
       if (Install_Code | Install_Config) {
          if (!INST_Add_WriteMBR()) {
             return 1;
           }
          MSG_Print (TXT_PROCESS_FinishedExitOrReboot);
          do {
             UserKey = Inkey();             // React on ENTER or ESC
           } while (!((UserKey==0x0D) || (UserKey==0x1B)));
          if (UserKey==0x0D) {              // ENTER reboots system...
             MSG_Print (TXT_PROCESS_Rebooting);
             DosSleep (2000);
             SHUTDOWN_Reboot();
           }
        } else {
          MSG_Print (TXT_ADD_NothingToDo);
          MSG_Print (TXT_PROCESS_FinishedExitOnly);
          while (Inkey()!=0x0D);
        }
       break;
     }
    case 'd': {
       MSG_Print (TXT_DELETE_NotPossible);
       break;
     }
    case 'q': {
       break;
     }
    default:
    break;
    }

   return 0;
 }
