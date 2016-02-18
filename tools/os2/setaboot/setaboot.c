// AiR-BOOT (c) Copyright 1998-2008 M. Kiewitz
//
// This file is part of AiR-BOOT
//
// AiR-BOOT is free software: you can redistribute it and/or modify it under
//  the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
// AiR-BOOT is distributed in the hope that it will be useful, but WITHOUT ANY
//  WARRANTY: without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
// You should have received a copy of the GNU General Public License along with
//  AiR-BOOT. If not, see <http://www.gnu.org/licenses/>.
//

/*
// Rousseau: 2011-02-05
// - Made volumes compare case insensitive so fs-label matches volume-name on command-line.  (around line 510)
//   This means bootable volumes cannot not have the same and only differ in case.
*/


#include    "setaboot.h"


#define INCL_BASE
#define INCL_WINSHELLDATA
#define INCL_DOS
#define INCL_DOSDEVIOCTL
#include <os2.h>
#include <malloc.h>

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <conio.h>
#include <string.h>

#include "msghelp.c"

// Msg-IDs from OSO001.msg
#define TXT_QUERY_TimeLimit_None          860
#define TXT_QUERY_TimeLimit_Show          861
#define TXT_QUERY_Mode_Extended           863
#define TXT_QUERY_Mode_Normal             864
#define TXT_SYNTAX_Show                   867
#define TXT_ERROR_DuringAccessHDD         868
#define TXT_ERROR_NoValueFor              870
#define TXT_ERROR_NeedsValueFor           871
#define TXT_ERROR_BadParameter            872
#define TXT_ERROR_BadValueFor             873
#define TXT_ERROR_NoBootManager           874

#pragma pack(1)

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
   CHAR   Identifier[13];                                                        // Rousseau: INVISIBLE CHAR AT END !
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
   UCHAR  IgnoreLVM;
   UCHAR  Reserved[82];
   CHAR   InstallVolume[12];
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

#pragma pack()

#define AiRBOOTIPENTRY_Flags_BootAble       0x01

CHAR            Track0[62*512];      // Space for Track-0
PAiRBOOTCODESIG AiRBOOT_CodeSig = 0;
PAiRBOOTCONFIG  AiRBOOT_Config = 0;
PAiRBOOTIPENTRY AiRBOOT_IPT = 0;
USHORT          AiRBOOT_ConfigCheckSum = 0;
UCHAR           AiRBOOT_IPTCount = 0;


/* Executables to search for */
PCHAR	classic_setboots[] = {
   "SETBM.EXE",
   NULL
};


/*
// ProtoTypes.
*/
BOOL Track0DetectAirBoot (BOOL* ab_bad);
BOOL Track0WriteAiRBOOTConfig (void);



   USHORT CountHarddrives (void) {
      USHORT NumDrives = 0;

      if (DosPhysicalDisk(INFO_COUNT_PARTITIONABLE_DISKS, &NumDrives, sizeof(NumDrives),NULL, 0) != 0)
         return 0;
      return NumDrives;
    }

   USHORT OS2_GetIOCTLHandle () {
      USHORT IOCTLHandle = 0;

      if (DosPhysicalDisk(INFO_GETIOCTLHANDLE, &IOCTLHandle, sizeof(IOCTLHandle),"1:" , 3) != 0)
         return 0;
      return IOCTLHandle;
    }

   void OS2_FreeIOCTLHandle (USHORT IOCTLHandle) {
      DosPhysicalDisk(INFO_FREEIOCTLHANDLE, NULL, 0, &IOCTLHandle, sizeof(IOCTLHandle));
      return;
    }

   BOOL Track0Load (void) {
      USHORT      IOCTLHandle;
      ULONG       TrackLayoutLen  = sizeof(TRACKLAYOUT)+sizeof(ULONG)*(62-1);
      TRACKLAYOUT *TrackLayoutPtr = malloc(TrackLayoutLen);
      ULONG       cbParms = sizeof(TrackLayoutPtr);
      ULONG       cbData  = 512;
      int         i;
      BOOL        Success = FALSE;

      IOCTLHandle = OS2_GetIOCTLHandle();

      TrackLayoutPtr->bCommand      = 0x01;
      TrackLayoutPtr->usHead        = 0;
      TrackLayoutPtr->usCylinder    = 0;
      TrackLayoutPtr->usFirstSector = 0;
      TrackLayoutPtr->cSectors      = 62;

      for (i=0; i<62; i++) {
         TrackLayoutPtr->TrackTable[i].usSectorNumber = i+1;
         TrackLayoutPtr->TrackTable[i].usSectorSize   = 512;
       }

      if (!DosDevIOCtl(IOCTLHandle, IOCTL_PHYSICALDISK, PDSK_READPHYSTRACK,
           TrackLayoutPtr, cbParms, &cbParms, &Track0, cbData, &cbData))
         Success = TRUE;
      OS2_FreeIOCTLHandle (IOCTLHandle);
      free (TrackLayoutPtr);
      return Success;
    }

   BOOL Track0Write (void) {
      USHORT      IOCTLHandle;
      ULONG       TrackLayoutLen  = sizeof(TRACKLAYOUT)+sizeof(ULONG)*(62-1);
      TRACKLAYOUT *TrackLayoutPtr = malloc(TrackLayoutLen);
      ULONG       cbParms = sizeof(TrackLayoutPtr);
      ULONG       cbData  = 512;
      INT         i;
      BOOL        Success = FALSE;

      IOCTLHandle = OS2_GetIOCTLHandle();


      TrackLayoutPtr->bCommand      = 0x01;
      TrackLayoutPtr->usHead        = 0;
      TrackLayoutPtr->usCylinder    = 0;
      TrackLayoutPtr->usFirstSector = 0;
      TrackLayoutPtr->cSectors      = 62;

      for (i=0; i<62; i++) {
         TrackLayoutPtr->TrackTable[i].usSectorNumber = i+1;
         TrackLayoutPtr->TrackTable[i].usSectorSize   = 512;
       }

      if (!DosDevIOCtl(IOCTLHandle, IOCTL_PHYSICALDISK, PDSK_WRITEPHYSTRACK,
          TrackLayoutPtr, cbParms, &cbParms, &Track0, cbData, &cbData))
         Success = TRUE;
      OS2_FreeIOCTLHandle (IOCTLHandle);
      free (TrackLayoutPtr);
      return Success;
    }

   #define CATEGORY_DOSSYS 0xD5
   #define FUNCTION_REBOOT 0xAB

   void RebootSystem (void) {
      HFILE  DosHandle;
      ULONG  DosOpenAction;

      DosSleep (2000);
      if (!DosOpen("DOS$", &DosHandle, &DosOpenAction, 0, FILE_NORMAL, FILE_OPEN, OPEN_ACCESS_READWRITE|OPEN_SHARE_DENYNONE, NULL)) {
         DosDevIOCtl(DosHandle, CATEGORY_DOSSYS, FUNCTION_REBOOT, NULL, 0, NULL, NULL, 0, NULL);
         DosSleep (60000);
       }
      DosClose(DosHandle);
    }


APIRET QueryBootDrive(char *bootdrv)
{
	ULONG	aulSysInfo[QSV_MAX]	= {0};                                             // System Information Data Buffer
	APIRET	rc				= NO_ERROR;											               // Return code

	if(bootdrv==0) return 1;

	rc = DosQuerySysInfo(1L,														            // Request all available system
							QSV_MAX ,												               // information
							(PVOID)aulSysInfo,										            // Pointer to buffer
							sizeof(ULONG)*QSV_MAX);									            // Size of the buffer

	if (rc != NO_ERROR) {
		return 1;
	}
	else {
		//printf("Bootable drive: %c:\n",
		//		aulSysInfo[QSV_BOOT_DRIVE-1]+'A'-1);  /* Max length of path name */
		bootdrv[0]=aulSysInfo[QSV_BOOT_DRIVE-1]+'A'-1;

		/*
		printf("Total physical memory is %u bytes.\n",
				aulSysInfo[QSV_TOTPHYSMEM-1]);
		*/

		return 0;
	}


}

USHORT GetChecksumOfSector (USHORT BaseCheck, USHORT SectorNo) {
   PUSHORT CurPos     = (PUSHORT)((ULONG)&Track0+(SectorNo-1)*512);
   USHORT  LengthLeft = 256;

   while (LengthLeft-->0)
      BaseCheck ^= (*CurPos++ ^ 0x0BABE);
   if (BaseCheck==0) BaseCheck = 1;
   return BaseCheck;
 }




/*
// If AiR-BOOT is not installed, the user probably meant to control OS/2 BM with this utility.
// Since the functionality of this utility is for AiR-BOOT only, we will pass the request to
// the OS/2 BM SETBOOT utility which is called SETBM.EXE as of eCS 2.1.
// In this case also the return-value of SETBM.EXE is returned.
*/
int   DoClassicActions(int argc, char **argv) {
   APIRET      rc             = -1;
   RESULTCODES	crc			   = {-1,-1};
//   PTIB        ptib           = NULL;
//   PPIB        ppib           = NULL;
   char        buffer[256]    = "\0";
   char        cmdline[256]   = "\0";
   PSZ         path           = NULL;
   char        sresult[256]   = "\0";
   char        bootdrive      = '?';
   char*       p              = NULL;
   int         i              = 0;

   //printf("\nCLASSIC ACTIONS !! (%d)\n", argc);

   rc = QueryBootDrive(&bootdrive);

   rc = DosScanEnv("PATH", &path);
   rc = DosSearchPath(SEARCH_CUR_DIRECTORY | SEARCH_IGNORENETERRS,
                        path,
                        classic_setboots[0],
                        sresult,
                        sizeof(sresult));

   //printf("SRESULT: rc=%d, %s\n", rc, sresult);

   if (rc) {
      printf("\n");
      printf("ERROR: SETBOOT (AiR-BOOT version)\n");
      printf("Since the AiR-BOOT Boot Manager is not installed,\n");
      printf("this program (SETBOOT.EXE), funcions as a wrapper\n");
      printf("to %s that should be used to control IBM Boot Manager.\n", classic_setboots[0]);
      printf("However, %s could not be found in the PATH, the error-code is: %d\n", classic_setboots[0], rc);
      printf("You can resolve this situation by renaming a valid SETBOOT.EXE to %s\n", classic_setboots[0]);
      printf("and put it in your %c:\\OS2 directory.", bootdrive);
      printf("\n");
      exit(rc);
   }




   memset(cmdline, 0, sizeof(cmdline));                                          // Clear the command-line buffer.
   p = cmdline;                                                                  // Temporary pointer to insert arguments.
   strcpy(p, sresult);                                                           // Copy the program-name.
   p += strlen(sresult)+1;                                                       // Advance to point for space separated parameters.

   /*
   // Process all the arguments,
   // inserting the separated by a space.
   */
   for (i=1; i<argc; i++) {
      strcpy(p, argv[i]);                                                        // Copy the argument.
      p += strlen(argv[i]);                                                      // Advance pointer past argument.
      *p++ = ' ';                                                                // Space separation.
   }

   /*
   for (i=0; i<100; i++) {
      printf("%c", cmdline[i] ? cmdline[i] : '#');
   }
   printf("\n");
   */

   //printf("CMDLINE: %s\n", cmdline);
   //printf("CMDLINE+: %s\n", cmdline+strlen(sresult)+1);

   rc = DosExecPgm(buffer,
            sizeof(buffer),
            EXEC_SYNC,
            cmdline,
            NULL,
            &crc,
            sresult);

   //rc = 3;
   if (rc) {
      printf("\n");
      printf("ERROR: SETBOOT (AiR-BOOT version)\n");
      printf("Since the AiR-BOOT Boot Manager is not installed,\n");
      printf("this program (SETBOOT.EXE), funcions as a wrapper\n");
      printf("to %s that should be used to control IBM Boot Manager.\n", classic_setboots[0]);
      printf("However, something went wrong when executing %s.\n", classic_setboots[0]);
      printf("The error-code is: %d and the termination-code is: %d\n", rc, crc.codeTerminate);
      printf("\n");
      exit(rc);
   }


   //printf("DosExecPgm: rc=%08X, codeterminate=%08X, coderesult=%08X\n", rc, crc.codeTerminate, crc.codeResult);

   /*
   rc = DosGetInfoBlocks(&ptib, &ppib);

   rc = DosQueryModuleName(ppib->pib_hmte, sizeof(buffer), buffer);
   printf("MODULE: %s\n", buffer);
   printf("CMDLINE: %s\n", ppib->pib_pchcmd);
   */

   return crc.codeResult;
}

/*
// This funtion is invoked when AiR-BOOT is installed.
// It mimics the behavior of the original SETBOOT.EXE utility,
// but operates on AiR-BOOT.
*/
int   DoAirBootActions(int argc, char **argv, BOOL ab_detected, BOOL ab_bad) {
   ULONG           CurArgument      = 0;
   ULONG           ArgumentLen      = 0;
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
   BOOL            DisableDirectBoot= FALSE;
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
   ULONG           WriteLeft        = 0;
   ULONG           TmpLength        = 0;
   ULONG           TmpLength2       = 0;
   ULONG           XWPBootCount     = 0;
   CHAR            XWPBootName[30][12];
   CHAR            XWPBootCommand[30][28];                                       // 'setaboot /IBA:""' (16 chars)
   BOOL            XWPEntryFound    = FALSE;
   BOOL            CDBoot           = FALSE;                                     // TRUE if booted from CD; New System will be added when using /4:"LABEL"
//   BOOL            Track0Loaded     = FALSE;                                     // Assume track0 did not load correctly.
   BOOL            AiRBOOTBad       = FALSE;

   //printf("\nAiR-BOOT ACTIONS !!\n");

   AiRBOOTDetected = ab_detected;
   AiRBOOTBad = ab_bad;

   if (AiRBOOTBad)
      return 1;

   // Use OSO001.MSG, so we safe us the trouble of translating :)
   if (!MSG_Init("OSO001.MSG"))
      return 1;

   /*
   // Rousseau: changed version to be the same as the AiR-BOOT is accompanies.
   */
   //puts ("SETABOOT - AiR-BOOT Configuration Utility (OS/2) - (c) 2004-2009 by M. Kiewitz");
   //puts ("SETABOOT v1.07a - AiR-BOOT Configuration Utility - (c) 2004-2011 by M. Kiewitz");
   puts ("SETABOOT v"
    BLDLVL_MAJOR_VERSION"."
    BLDLVL_MIDDLE_VERSION"."
    BLDLVL_MINOR_VERSION" - AiR-BOOT Configuration Utility - (c) 2004-"
    BLDLVL_YEAR
    " by M. Kiewitz");


   //return 0;

   /*
   // Rousseau:
   // Log some debug stuff to (virtual) flop.
   */
   /*
   {
      char        buf[512]="\0";
      FILE*       fp = NULL;
      int         i = 0;

      fp = fopen("A:\\SETBOOT.TXT", "a");
      sprintf(buf, "Bliep");
      fprintf(fp,"Program: %s\n", argv[0]);
      fprintf(fp,"Arguments: %d\n", argc);
      for (i=0; i<argc-1; i++) {
         fprintf(fp, "Arg %d: %s\n", i+1, argv[i+1]);
      }
      fprintf(fp, "\n");
      fclose(fp);
   }
   */



   /*
   // Rousseau: ## Enable boot-through when installing new system ##
   // In the install-environment, the MEMDRIVE env-var is defined.
   // This modifies the behavior after phase 1.
   */
   if (getenv("MEMDRIVE")) {
      printf("CDBoot Environment.\n");
      CDBoot = TRUE;
   }


   if (argc==1) {
      MSG_Print (TXT_SYNTAX_Show);
      return 1;
    }




   // Now we check for AiR-BOOT existance...
   /*
   if (CountHarddrives()>0) {
      if (Track0Load()) {
         // Rousseau: Track0DetectAirBoot() will init globals.
         if (Track0DetectAirBoot()) // REPLACE WITH BOOL
            AiRBOOTDetected = TRUE;
       }
       else {
         MSG_Print (TXT_ERROR_DuringAccessHDD);
       }
    }
    else {
      MSG_Print (TXT_ERROR_DuringAccessHDD);
   }
   */

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
                  puts ("SETABOOT: AiR-BOOT v0.91 required for this feature.");
                  BadValue = TRUE;
                }
             } else BadParm = TRUE;
            break;
          case 'I':
          case '4':
            DoDirectBoot = TRUE;
            if (CurChar=='I') {
               if ((ArgumentLen>4) && (ArgumentLen<16) && (toupper(*StartPos++)=='B') && (toupper(*StartPos++)=='A') && (*StartPos==':')) {
                  DoReboot     = TRUE; // IBA: requires us to reboot
                  ArgumentLen -= 4;
                } else {
                  BadParm = TRUE;
                  break;
                }
             } else {
               if ((ArgumentLen>1) && (ArgumentLen<33) && (*StartPos==':')) {
                  ArgumentLen -= 2;
                } else {
                  BadParm = TRUE;
                  break;
                }
             }

            *StartPos = 0; StartPos++;

            // Search that partition in IPT of AiR-BOOT...
            if ((CurChar=='4') && (ArgumentLen==0)) {
               // '4:' and no partition name means disable automatic boot
               DoDirectBoot      = FALSE;
               DisableDirectBoot = TRUE;
               break;
             }
            if (ArgumentLen>11)
               ArgumentLen = 11;

            if (!AiRBOOTDetected) {
               MSG_Print (TXT_ERROR_NoBootManager);
               return 1;
             }


            /*
            // Rousseau:
            // Insert label of newly installed system in AiR-BOOT configuration.
            // Note that it is changed to uppercase because AiR-BOOT uses the FS-label when
            // scanning partitions and LVM-info is not found. (Otherwise PART-label)
            // The auto-boot flag is not set in this case as this is handled by the AiR-BOOT loader.
            */
            if (CDBoot) {
               strncpy(AiRBOOT_Config->InstallVolume, _strupr(StartPos), ArgumentLen);
               AiRBOOT_Config->InstallVolume[ArgumentLen] = '\0';
               printf("Writing Install Volume: %s to AiR-BOOT configuration.\n", AiRBOOT_Config->InstallVolume);
               Track0WriteAiRBOOTConfig();
               return 0;
            }




            BadValue = TRUE;
            CurPartitionNo = 0; CurIPTEntry = AiRBOOT_IPT;
            while (CurPartitionNo<AiRBOOT_Config->Partitions) {
               /*
               // Rousseau: Changed below to case-insensitive compare.
               // This solves the part/vol-label (mixed-case) v.s. fs-label (upper-case) issue.
               */
               /*if (strncmp(CurIPTEntry->PartitionName, StartPos, ArgumentLen)==0) {*/
               if (strnicmp(CurIPTEntry->PartitionName, StartPos, ArgumentLen)==0) {
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
               puts ("SETABOOT: Partition not found in IPT.");
             } else {
               if (CurIPTEntry->Flags & AiRBOOTIPENTRY_Flags_BootAble) {
                  DirectBootPart = CurPartitionNo;
                  if ((AiRBOOT_CodeSig->MajorVersion==0x00) && (AiRBOOT_CodeSig->MinorVersion<0x94)) {
                     puts ("SETABOOT: AiR-BOOT v0.94 required for this feature.");
                     BadValue = TRUE;
                   } else if ((AiRBOOT_Config->PasswordedSystem) || (AiRBOOT_Config->PasswordedChangeBoot)) {
                     puts ("SETABOOT: This feature needs password protection to be off.");
                     BadValue = TRUE;
                   }
                } else {
                  BadValue = TRUE;
                  puts ("SETABOOT: Partition not set bootable.");
                }
             }
            break;
          case 'X':
            if ((ArgumentLen==3) && (toupper(*StartPos++)=='W') && (toupper(*StartPos++)=='P')) {
               if (!AiRBOOTDetected) {
                  MSG_Print (TXT_ERROR_NoBootManager);
                  return 1;
                }
               if ((AiRBOOT_CodeSig->MajorVersion==0x00) && (AiRBOOT_CodeSig->MinorVersion<0x94)) {
                  puts ("SETABOOT: AiR-BOOT v0.94 required for this feature.");
                  BadValue = TRUE;
                } else DoXWPSupport = TRUE;
               break;
             }
          case 'N':
            puts ("SETABOOT: No support for this option.");
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
         puts ("SETABOOT: /XWP needs XWorkPlace.");
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

      puts ("SETABOOT: XWorkPlace updated.");
      return 0;
    }
   if (DoQuery) {
      if (!AiRBOOTDetected) {
         MSG_Print (TXT_ERROR_NoBootManager);
         return 1;
       }
      printf("SETABOOT: AiR-BOOT %X.%02X detected.\n\n", AiRBOOT_CodeSig->MajorVersion, AiRBOOT_CodeSig->MinorVersion);
      //printf("DEBUG: InstallVolume: %s\n", AiRBOOT_Config->InstallVolume);
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
         if (AiRBOOT_Config->BootMenuActive==0)
            AiRBOOT_Config->BootMenuActive = 1;
         AiRBOOT_Config->TimedBoot    = 0; // Switches off Timed-Boot
       } else {
         if (AiRBOOT_Config->BootMenuActive==0)
            AiRBOOT_Config->BootMenuActive = 1;
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
      puts ("SETABOOT: Automatic boot enabled.");
    }
   if (DisableDirectBoot) {
      if (!AiRBOOTDetected) {
         MSG_Print (TXT_ERROR_NoBootManager);
         return 1;
       }
      AiRBOOT_Config->AutomaticBoot      = 0; // Switches off Automatic-Boot
      AiRBOOT_Config->AutomaticPartition = 0;
      AiRBOOTChanged = TRUE;
      puts ("SETABOOT: Automatic boot disabled.");
    }
   if (AiRBOOTChanged) {
      if (!Track0WriteAiRBOOTConfig())
         return 1;
    }
   if (DoReboot) {
      puts ("SETABOOT: Now rebooting system...");
      RebootSystem();
    }
   return 0;



}


/*
// Rousseau:
// Global pointers will be initialized here !
*/
BOOL Track0DetectAirBoot (BOOL* ab_bad) {
   USHORT ResultCheck;
   USHORT CurSectorNo = 0;

   /* Globals that get initialized */
   AiRBOOT_CodeSig = (PAiRBOOTCODESIG)&Track0[2];
   AiRBOOT_Config  = (PAiRBOOTCONFIG)&Track0[(55-1)*512];
   AiRBOOT_IPT     = (PAiRBOOTIPENTRY)&Track0[(56-1)*512];

   if (strncmp(AiRBOOT_CodeSig->Identifier, "AiRBOOT", 7)!=0) {
      *ab_bad = FALSE;
      return FALSE;
    }

   if ((AiRBOOT_CodeSig->TotalCodeSectors)>53) {
      puts ("SETABOOT: AiR-BOOT Code damaged!");
      *ab_bad = TRUE;
      return TRUE;
    }

   ResultCheck = 0; CurSectorNo = 0;
   while (CurSectorNo<AiRBOOT_CodeSig->TotalCodeSectors) {
      ResultCheck = GetChecksumOfSector(ResultCheck, CurSectorNo+2);
      CurSectorNo++;
    }
   if (ResultCheck!=AiRBOOT_CodeSig->CheckSumOfCode) {
      puts ("SETABOOT: AiR-BOOT Code damaged!");
      *ab_bad = TRUE;
      return TRUE;
    }

   if (strncmp(AiRBOOT_Config->Identifier, "AiRCFG-TABLE­", 13)!=0) {            // Rousseau: INVISIBLE CHAR HERE !
      puts ("SETABOOT: AiR-BOOT Config damaged!");
      *ab_bad = TRUE;
      return TRUE;
    }

   // Set Config-CheckSum to 0
   AiRBOOT_ConfigCheckSum = AiRBOOT_Config->CheckSumOfConfig;
   AiRBOOT_Config->CheckSumOfConfig = 0;

   // Calculate CheckSum...
   // Rousseau: Only check 5 sectors for v1.07 compatibility.
   ResultCheck = 0; CurSectorNo = 55;
   while (CurSectorNo<60) {
      ResultCheck = GetChecksumOfSector(ResultCheck, CurSectorNo);
      CurSectorNo++;
    }
   if (ResultCheck!=AiRBOOT_ConfigCheckSum) {
      puts ("SETABOOT: AiR-BOOT Config damaged!");
      *ab_bad = TRUE;
      return TRUE;
    }
   *ab_bad = FALSE;
   return TRUE;
 }

BOOL Track0WriteAiRBOOTConfig (void) {
   USHORT ResultCheck;
   USHORT CurSectorNo = 0;

   // Update Edit-Counter...
   AiRBOOT_Config->EditCounter++;
   AiRBOOT_Config->CheckSumOfConfig = 0;

   // Calculate CheckSum...
   ResultCheck = 0; CurSectorNo = 55;

   /*
   // Rousseau: # Keep compatible with v1.07 CRC #
   // AB v1.07 had bugs in writing the wrong number of AB config sectors.
   // This is fixed in v1.0.8+ but the CRC has to be calculated the "v1.07 way"
   // otherwise v1.07 SET(A)BOOT and INSTALL2.EXE will think the AB config
   // is corrupted.
   // So the CRC is calculated over 5 sectors instead of 7.
   */
   while (CurSectorNo<60) {
      ResultCheck = GetChecksumOfSector(ResultCheck, CurSectorNo);
      CurSectorNo++;
    }
   AiRBOOT_Config->CheckSumOfConfig = ResultCheck;

   if (!Track0Write())
      return FALSE;
   return TRUE;
 }


/*
// Rousseau: # This is the main entry-point #
// Special behavior if eCS is booted from CDROM and phase 1 called this program.
// In that case, the name of the newly installed system is put in the AiR-BOOT configuration.
// This will cause AiR-BOOT to boot through after phase 1.
*/
int main (int argc, char **argv) {
   BOOL  AiRBOOTDetected   = FALSE;
   BOOL  Track0Loaded      = FALSE;                                              // Assume track0 did not load correctly.
   BOOL  AiRBOOTBad        = FALSE;
   int   rc                = -1;


   /*
   // Rousseau: ## Changed order to first check for AiR-BOOT existance ##
   // If AiR-BOOT is not installed, all action is passed-thru to IBM SETBOOT (SETBM.EXE).
   */


   /*
   // Try to load track zero.
   // We don't care if no harddisk is present, since we first want to know if AiR-BOOT is
   // installed to adjust our behaviour.
   // If it's not installed, or a loading error occurs, all actions will be deferred to
   // IBM SETBOOT (SETBM.EXE).
   // This means we also let IBM SETBOOT handle the situation in which no HD's are present.
   */
   Track0Loaded = Track0Load();

   /*
   // Now see if AiR-BOOT is present.
   // If there was a loading error, no AiR-BOOT signature will be present, so
   // we pass-thru to IBM SETBOOT.
   */
   AiRBOOTDetected = Track0DetectAirBoot(&AiRBOOTBad);

   if (AiRBOOTDetected) {
      rc = DoAirBootActions(argc, argv, AiRBOOTDetected, AiRBOOTBad);
   }
   else {
      rc = DoClassicActions(argc, argv);
   }


   return rc;
 }
