
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

#define INCL_BASE
#define INCL_WINSHELLDATA
#include <os2.h>
#include <bsesub.h>
#include <malloc.h>

#define INCLUDE_STD_MAIN
#include <global.h>
#include <msg.h>

#include <physdisk.h>
#include <shutdown.h>
#include <setaboot_msg.h>

// This structure needs NOT to get optimized, otherwise it will screw up...
typedef struct _AiRBOOTCODESIG {
   CHAR   Identifier[7];
   UCHAR  DayOfRelease;
   UCHAR  MonthOfRelease;
   USHORT YearOfRelease;
   UCHAR  MajorVersion;
   UCHAR  MinorVersion;
   CHAR   ReleaseLanguage;
   UCHAR  TotalCodeSectors;
   USHORT CheckSumOfCode;
 } AiRBOOTCODESIG;
typedef AiRBOOTCODESIG *PAiRBOOTCODESIG;

typedef struct _AiRBOOTCONFIG {
   CHAR   Identifier[13];
   UCHAR  MajorVersion;
   UCHAR  MinorVersion;
   CHAR   ReleaseLanguage;
   ULONG  EditCounter;
   USHORT CheckSumOfConfig;
   UCHAR  Partitions;
   UCHAR  Meaningless1;
   UCHAR  DefaultPartition;
   UCHAR  LastPartition;
   UCHAR  TimedBoot;
   UCHAR  TimedSeconds;
   USHORT Meaningless2;
   UCHAR  TimedBootLast;
   UCHAR  RememberBoot;
   UCHAR  RememberTimed;
   UCHAR  IncludeFloppy;
   UCHAR  BootMenuActive;
   UCHAR  PartitionsDetect;
   UCHAR  PasswordedSetup;
   UCHAR  PasswordedSystem;
   UCHAR  PasswordedChangeBoot;
   UCHAR  ProtectMBRTSR;
   UCHAR  ProtectMBRignore;
   UCHAR  FloppyGetName;
   UCHAR  DetectVirus;
   UCHAR  DetectStealth;
   UCHAR  DetectVIBR;
   UCHAR  AutoEnterSetup;
   UCHAR  MasterPassword[8];
   UCHAR  BootPassword[8];
   UCHAR  Meaningless3;
   UCHAR  LinuxPartition;
   UCHAR  TimedKeyHandling;
   UCHAR  MakeSound;
   UCHAR  FloppyGetTimer;
   UCHAR  ResumeBIOSbootSeq;
   UCHAR  CooperBars;
   CHAR   LinuxCommandLine[75];
   UCHAR  LinuxKernelPartition;
   CHAR   LinuxDefaultKernel[11];
   UCHAR  LinuxKernelNameEnd;
   CHAR   LinuxLastKernel[11];
   UCHAR  LinuxKernelNameEnd2;
   UCHAR  ExtPartitionMShack;
   UCHAR  AutomaticBoot;
   UCHAR  AutomaticPartition;
   UCHAR  ForceLBAUsage;
 } AiRBOOTCONFIG;
typedef AiRBOOTCONFIG *PAiRBOOTCONFIG;

typedef struct _AiRBOOTIPENTRY {
   ULONG  SerialNumber;
   CHAR   PartitionName[11];
   UCHAR  Drive;
   UCHAR  PartitionID;
   UCHAR  Flags;
   USHORT CheckSum;
   UCHAR  LocationBegin[3];
   UCHAR  LocationPartTab[3];
   ULONG  AbsoluteBegin;
   ULONG  AbsolutePartTab;
 } AiRBOOTIPENTRY;
typedef AiRBOOTIPENTRY *PAiRBOOTIPENTRY;

#define AiRBOOTIPENTRY_Flags_BootAble       0x01

CHAR            TrackZero[31744];         // Space for Track-0
PAiRBOOTCODESIG AiRBOOT_CodeSig = 0;
PAiRBOOTCONFIG  AiRBOOT_Config = 0;
PAiRBOOTIPENTRY AiRBOOT_IPT = 0;
USHORT          AiRBOOT_ConfigCheckSum = 0;
UCHAR           AiRBOOT_IPTCount = 0;

BOOL TRACK0_Load (void) {
   USHORT IOCTLHandle;
   USHORT NumDrives;
   USHORT SectorsPerTrack;

   NumDrives = PHYS_EnumeratePhysicalDisks();
   if (NumDrives==0) {
      MSG_Print (TXT_ERROR_DuringAccessHDD);
      return FALSE;
    }

   IOCTLHandle = PHYS_GetIOCTLHandle("1:");
   SectorsPerTrack = PHYS_GetGeometrySectorsPerTrack(IOCTLHandle);
   if (SectorsPerTrack>61) {
      if (!PHYS_ReadPhysicalSector(IOCTLHandle,0,0,59,TrackZero)) {
         MSG_Print (TXT_ERROR_DuringAccessHDD);
         return FALSE;
       }
    }
   PHYS_FreeIOCTLHandle (IOCTLHandle);
   return TRUE;
 }

BOOL TRACK0_Write (void) {
   USHORT IOCTLHandle;

   IOCTLHandle = PHYS_GetIOCTLHandle("1:");
   if (!PHYS_WritePhysicalSector(IOCTLHandle,0,0,59,TrackZero)) {
      MSG_Print (TXT_ERROR_DuringAccessHDD);
      return FALSE;
    }
   PHYS_FreeIOCTLHandle (IOCTLHandle);
   return TRUE;
 }

USHORT TRACK0_GetCheckOfSector (USHORT BaseCheck, USHORT SectorNo) {
   PUSHORT CurPos     = (PUSHORT)((ULONG)&TrackZero+(SectorNo-1)*512);
   USHORT  LengthLeft = 256;

   while (LengthLeft-->0)
      BaseCheck ^= (*CurPos++ ^ 0x0BABE);
   if (BaseCheck==0) BaseCheck = 1;
   return BaseCheck;
 }

BOOL TRACK0_DetectAirBoot (void) {
   USHORT ResultCheck;
   USHORT CurSectorNo = 0;

   AiRBOOT_CodeSig = (PAiRBOOTCODESIG)&TrackZero[2];
   AiRBOOT_Config  = (PAiRBOOTCONFIG)&TrackZero[(55-1)*512];
   AiRBOOT_IPT     = (PAiRBOOTIPENTRY)&TrackZero[(56-1)*512];

   if (strncmp(AiRBOOT_CodeSig->Identifier, "AiRBOOT", 7)!=0) {
      return FALSE;
    }

   if ((AiRBOOT_CodeSig->TotalCodeSectors)>53) {
      puts ("AiR-BOOT Code damaged!");
      return FALSE;
    }

   ResultCheck = 0; CurSectorNo = 0;
   while (CurSectorNo<AiRBOOT_CodeSig->TotalCodeSectors) {
      ResultCheck = TRACK0_GetCheckOfSector(ResultCheck, CurSectorNo+2);
      CurSectorNo++;
    }
   if (ResultCheck!=AiRBOOT_CodeSig->CheckSumOfCode) {
      puts ("AiR-BOOT Code damaged!");
      return FALSE;
    }

   if (strncmp(AiRBOOT_Config->Identifier, "AiRCFG-TABLE­", 13)!=0) {
      puts ("AiR-BOOT Config damaged!");
      return FALSE;
    }

   // Set Config-CheckSum to 0
   AiRBOOT_ConfigCheckSum = AiRBOOT_Config->CheckSumOfConfig;
   AiRBOOT_Config->CheckSumOfConfig = 0;

   // Calculate CheckSum...
   ResultCheck = 0; CurSectorNo = 55;
   while (CurSectorNo<60) {
      ResultCheck = TRACK0_GetCheckOfSector(ResultCheck, CurSectorNo);
      CurSectorNo++;
    }
   if (ResultCheck!=AiRBOOT_ConfigCheckSum) {
      puts ("AiR-BOOT Config damaged!");
      return FALSE;
    }
   return TRUE;
 }

BOOL TRACK0_WriteAiRBOOTConfig (void) {
   USHORT ResultCheck;
   USHORT CurSectorNo = 0;

   // Update Edit-Counter...
   AiRBOOT_Config->EditCounter++;
   AiRBOOT_Config->CheckSumOfConfig = 0;

   // Calculate CheckSum...
   ResultCheck = 0; CurSectorNo = 55;
   while (CurSectorNo<60) {
      ResultCheck = TRACK0_GetCheckOfSector(ResultCheck, CurSectorNo);
      CurSectorNo++;
    }
   AiRBOOT_Config->CheckSumOfConfig = ResultCheck;

   if (!TRACK0_Write())
      return FALSE;
   return TRUE;
 }

ushort maincode (int argc, char *argv[]) {
   ULONG           CurArgument      = 0;
   ULONG           ArgumentLen      = 0;
   UCHAR           UserKey;
   PCHAR           StartPos         = 0;
   PCHAR           EndPos           = 0;
   PCHAR           CurPos           = 0;
   CHAR            CurChar          = 0;
   BOOL            DoXWPSupport     = FALSE;
   BOOL            DoQuery          = FALSE;
   BOOL            DoSetTimer       = FALSE;
   SHORT           SetTimerValue    = 0;
   BOOL            DoSetBootMenu    = FALSE;
   BOOL            BootMenuDetailed = FALSE;
   BOOL            DoDirectBoot     = FALSE;
   UCHAR           DirectBootPart   = 0;
   BOOL            DoReboot         = FALSE;
   BOOL            AiRBOOTDetected  = FALSE;
   BOOL            AiRBOOTChanged   = FALSE;
   BOOL            BadParm          = FALSE;
   BOOL            BadValue         = FALSE;
   UCHAR           CurPartitionNo   = 0;
   PAiRBOOTIPENTRY CurIPTEntry      = 0;
   CHAR            TempBuffer[10];
   ULONG           XWPStringSize    = 0;
   PCHAR           XWPOrgStringPtr  = 0;
   PCHAR           XWPNewStringPtr  = 0;
   ULONG           WriteLeft        = 0;
   ULONG           TmpLength        = 0;
   ULONG           TmpLength2       = 0;
   ULONG           XWPBootCount     = 0;
   CHAR            XWPBootName[30][12];
   CHAR            XWPBootCommand[30][28]; // 'setaboot /IBA:""' (16 chars)
   BOOL            XWPEntryFound    = FALSE;

   // Use OSO001.MSG, so we safe us the trouble of translating :)
   if (!MSG_Init("OSO001.MSG"))
      return 1;

   if (argc==1) {
      MSG_Print (TXT_SYNTAX_Show);
      return 1;
    }

   // Now we check for AiR-BOOT existance...
   if ((TRACK0_Load()) && (TRACK0_DetectAirBoot()))
      AiRBOOTDetected = TRUE;

   CurArgument = 1;
   while (CurArgument<argc) {
      StartPos = argv[CurArgument];
      ArgumentLen = strlen(StartPos);

      if ((*StartPos=='/') && (ArgumentLen>1)) {
         StartPos++; ArgumentLen--;
         CurChar = toupper(*StartPos++);

         switch (CurChar) {
          case '?':
            MSG_Print (TXT_SYNTAX_Show);
            return 1;
          case 'B':
            if (ArgumentLen==1) DoReboot = TRUE;
             else BadParm = TRUE;
            break;
          case 'Q':
            if (ArgumentLen==1) DoQuery = TRUE;
             else BadParm = TRUE;
            break;
          case 'T':
            DoSetTimer = TRUE;
            if ((ArgumentLen>2) && (*StartPos==':')) {
               *StartPos = 0; StartPos++;
               CurPos = StartPos;
               while (*CurPos!=0) {
                  if ((*CurPos<'0') || (*CurPos>'9')) {
                     BadValue = TRUE;
                     break;
                   }
                  CurPos++;
                }
               if (!BadValue) {
                  SetTimerValue = atoi(StartPos);
                  if ((SetTimerValue<0) || (SetTimerValue>255))
                     BadValue = TRUE;
                } else {
                  if ((ArgumentLen==4) && (toupper(*CurPos)=='N') && (toupper(*(CurPos+1))=='O')) {
                     BadValue = FALSE;
                     SetTimerValue = -1;    // Disable Timer
                   }
                }
             } else BadParm = TRUE;
            break;
          case 'M':
            DoSetBootMenu = TRUE;
            if ((ArgumentLen>2) && (*StartPos==':')) {
               *StartPos = 0; StartPos++;
               CurChar = toupper(*StartPos);
               switch (CurChar) {
                case 'N':
                  BootMenuDetailed = FALSE;
                  break;
                case 'A':
                  BootMenuDetailed = TRUE;
                  break;
                default:
                  BadValue = TRUE;
                  break;
                }
               if ((AiRBOOT_CodeSig->MajorVersion==0x00) && (AiRBOOT_CodeSig->MinorVersion<0x91)) {
                  puts ("AiR-BOOT/SETABOOT: AiR-BOOT v0.91 required for this feature.");
                  BadValue = TRUE;
                }
             } else BadParm = TRUE;
            break;
          case 'I':
            DoDirectBoot = TRUE;
            if ((ArgumentLen>4) && (ArgumentLen<16) && (toupper(*StartPos++)=='B') && (toupper(*StartPos++)=='A') && (*StartPos==':')) {
               *StartPos = 0; StartPos++;
               // Search that partition in IPT of AiR-BOOT...
               ArgumentLen -= 4;

               if (!AiRBOOTDetected) {
                  MSG_Print (TXT_ERROR_NoBootManager);
                  return 1;
                }

               BadValue = TRUE;
               CurPartitionNo = 0; CurIPTEntry = AiRBOOT_IPT;
               while (CurPartitionNo<AiRBOOT_Config->Partitions) {
                  if (strncmp(CurIPTEntry->PartitionName, StartPos, ArgumentLen)==0) {
                     if (ArgumentLen==11) {
                        BadValue = FALSE;
                        break;
                      } else {
                        CurPos = CurIPTEntry->PartitionName+ArgumentLen;
                        EndPos = CurIPTEntry->PartitionName+11;
                        while ((CurPos<EndPos) && ((*CurPos==0x00) || (*CurPos==0x20)))
                           CurPos++;
                        if (CurPos==EndPos) {
                           BadValue = FALSE;
                           break;
                         }
                      }
                   }
                  CurPartitionNo++; CurIPTEntry++;
                }

               if (BadValue) {
                  puts ("AiR-BOOT/SETABOOT: Partition not found in IPT.");
                } else {
                  if (CurIPTEntry->Flags & AiRBOOTIPENTRY_Flags_BootAble) {
                     DirectBootPart = CurPartitionNo;
                     if ((AiRBOOT_CodeSig->MajorVersion==0x00) && (AiRBOOT_CodeSig->MinorVersion<0x94)) {
                        puts ("AiR-BOOT/SETABOOT: AiR-BOOT v0.94 required for this feature.");
                        BadValue = TRUE;
                      } else if ((AiRBOOT_Config->PasswordedSystem) || (AiRBOOT_Config->PasswordedChangeBoot)) {
                        puts ("AiR-BOOT/SETABOOT: This feature needs password protection to be off.");
                        BadValue = TRUE;
                      }
                   } else {
                     BadValue = TRUE;
                     puts ("AiR-BOOT/SETABOOT: Partition not set bootable.");
                   }
                }
             } else BadParm = TRUE;
            break;
          case 'X':
            if ((ArgumentLen==3) && (toupper(*StartPos++)=='W') && (toupper(*StartPos++)=='P')) {
               if (!AiRBOOTDetected) {
                  MSG_Print (TXT_ERROR_NoBootManager);
                  return 1;
                }
               if ((AiRBOOT_CodeSig->MajorVersion==0x00) && (AiRBOOT_CodeSig->MinorVersion<0x94)) {
                  puts ("AiR-BOOT/SETABOOT: AiR-BOOT v0.94 required for this feature.");
                  BadValue = TRUE;
                } else DoXWPSupport = TRUE;
               break;
             }
          case 'N':
            puts ("AiR-BOOT/SETABOOT: No support for this option.");
          default:
            BadParm = TRUE;
          }
       } else BadParm = TRUE;

      if (BadParm) {
         MSG_SetInsertViaPSZ (1, argv[CurArgument]);
         MSG_Print (TXT_ERROR_BadParameter);
         return 1;
       }
      if (BadValue) {
         MSG_SetInsertViaPSZ (1, StartPos);
         MSG_SetInsertViaPSZ (2, argv[CurArgument]);
         MSG_Print (TXT_ERROR_BadValueFor);
         return 1;
       }

      CurArgument++;
    }

   if (DoXWPSupport) {
      if ((!PrfQueryProfileSize(HINI_USERPROFILE, "XWorkplace", "XShutdown", &XWPStringSize))) {
         puts ("AiR-BOOT/SETABOOT: /XWP needs XWorkPlace.");
         return 1;
       }
      // First, get the current string...
      CurPos    = XWPOrgStringPtr = malloc(65536);
      WriteLeft = XWPStringSize = 65536;
      if (!PrfQueryProfileData (HINI_USERPROFILE, "XWorkplace", "RebootTo", XWPOrgStringPtr, &XWPStringSize))
         XWPStringSize = 0;
      EndPos    = CurPos+XWPStringSize;

      CurPartitionNo = 0; CurIPTEntry = AiRBOOT_IPT;
      while (CurPartitionNo<AiRBOOT_Config->Partitions) {
         if (CurIPTEntry->Flags & AiRBOOTIPENTRY_Flags_BootAble) {
            strncpy (XWPBootName[XWPBootCount], CurIPTEntry->PartitionName, 11);
            XWPBootName[XWPBootCount][11] = 0;
            sprintf (XWPBootCommand[XWPBootCount], "setaboot /IBA:\"%s\"", XWPBootName[XWPBootCount]);
            XWPBootCount++;
          }
         CurPartitionNo++; CurIPTEntry++;
       }

      while ((CurPos<EndPos) && (*CurPos!=0)) {
         StartPos = CurPos; TmpLength = strlen(CurPos)+1;
         CurPos  += TmpLength; TmpLength2 = strlen(CurPos)+1;

         XWPEntryFound = FALSE;
         for (CurPartitionNo=0; CurPartitionNo<XWPBootCount; CurPartitionNo++) {
             if ((strcmp(StartPos, XWPBootName[CurPartitionNo])==0) && (strcmp(CurPos, XWPBootCommand[CurPartitionNo])==0))
                XWPBootCommand[CurPartitionNo][0] = 0;
          }
         CurPos    += TmpLength2;
         WriteLeft -= TmpLength+TmpLength2;
       }

      for (CurPartitionNo=0; CurPartitionNo<XWPBootCount; CurPartitionNo++) {
         if (XWPBootCommand[CurPartitionNo][0]!=0) {
            if (WriteLeft>11+27) {
               TmpLength  = strlen(XWPBootName[CurPartitionNo])+1;
               TmpLength2 = strlen(XWPBootCommand[CurPartitionNo])+1;
               strcpy (CurPos, XWPBootName[CurPartitionNo]);
               CurPos    += TmpLength;
               strcpy (CurPos, XWPBootCommand[CurPartitionNo]);
               CurPos    += TmpLength2;
               WriteLeft += TmpLength+TmpLength2;
             }
          }
       }
      *CurPos = 0; CurPos++;
      XWPStringSize = CurPos-XWPOrgStringPtr;

      PrfWriteProfileData (HINI_USERPROFILE, "XWorkplace", "RebootTo", XWPOrgStringPtr, XWPStringSize);
      free(XWPOrgStringPtr);
       
      puts ("AiR-BOOT/SETABOOT: XWorkPlace updated.");
      return 0;
    }
   if (DoQuery) {
      if (!AiRBOOTDetected) {
         MSG_Print (TXT_ERROR_NoBootManager);
         return 1;
       }
      printf ("AiR-BOOT/SETABOOT: AiR-BOOT %X.%02X detected.\n\n", AiRBOOT_CodeSig->MajorVersion, AiRBOOT_CodeSig->MinorVersion);
      if (AiRBOOT_Config->BootMenuActive) {
         if (AiRBOOT_Config->TimedBoot) {
            itoa (AiRBOOT_Config->TimedSeconds, (PCHAR)&TempBuffer, 10);
            MSG_SetInsertViaPSZ (1, TempBuffer);
            MSG_Print (TXT_QUERY_TimeLimit_Show);
          } else {
            MSG_Print (TXT_QUERY_TimeLimit_None);
          }
         if (AiRBOOT_Config->BootMenuActive>1)
            MSG_Print (TXT_QUERY_Mode_Extended);
           else
            MSG_Print (TXT_QUERY_Mode_Normal);
       } else {
         MSG_SetInsertViaPSZ (1, "0");
         MSG_Print (TXT_QUERY_TimeLimit_Show);
         MSG_Print (TXT_QUERY_Mode_Normal);
       }
      return 0;
    }
   if (DoSetTimer) {
      if (!AiRBOOTDetected) {
         MSG_Print (TXT_ERROR_NoBootManager);
         return 1;
       }
      // Set Timer to "SetTimerValue" (1-255 -> seconds, -1 -> disable)
      //  0 is a special case, which will disable the BootMenu
      if (SetTimerValue==0) {
         // 0 is a special case, that will disable the bootmenu
         AiRBOOT_Config->BootMenuActive = 0; // Switches off Boot-Menu
       } else if (SetTimerValue==-1) {
         // -1 will disable Timed-Boot
         AiRBOOT_Config->TimedBoot    = 0; // Switches off Timed-Boot
       } else {
         AiRBOOT_Config->TimedBoot    = 1; // Switches on Timed-Boot
         AiRBOOT_Config->TimedSeconds = SetTimerValue;
       }
      AiRBOOTChanged = TRUE;
    }
   if (DoSetBootMenu) {
      if (!AiRBOOTDetected) {
         MSG_Print (TXT_ERROR_NoBootManager);
         return 1;
       }
      // Sets type of Boot-menu
      //  Switches BootMenu between Enabled and Detailed state...
      if (BootMenuDetailed)
         AiRBOOT_Config->BootMenuActive = 2; // Switch to Detailed mode
        else
         AiRBOOT_Config->BootMenuActive = 1; // Switch to Enabled (Normal)
      AiRBOOTChanged = TRUE;
    }
   if (DoDirectBoot) {
      if (!AiRBOOTDetected) {
         MSG_Print (TXT_ERROR_NoBootManager);
         return 1;
       }
      // Sets Automatic-Booting to "DirectBootPart" (IPT-Entry)
      AiRBOOT_Config->AutomaticBoot      = 1; // Switches on Automatic-Boot
      AiRBOOT_Config->AutomaticPartition = DirectBootPart;
      AiRBOOTChanged = TRUE;
      DoReboot       = TRUE;                // Will also reboot system...
    }
   if (AiRBOOTChanged) {
      if (!TRACK0_WriteAiRBOOTConfig())
         return 1;
    }
   if (DoReboot) {
      puts ("AiR-BOOT/SETABOOT: Now rebooting system...");
      DosSleep (2000);
      SHUTDOWN_Reboot();
    }
   return 0;
 }
