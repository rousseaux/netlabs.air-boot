// AiR-BOOT (c) Copyright 1998-2009 M. Kiewitz
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

#if defined(__OS2__) && !defined(OS2)
   // OS/2 platform
   #define INCL_NOPMAPI
   #define INCL_BASE
   #define INCL_DOS
   #define INCL_DOSDEVIOCTL
   #include <os2.h>
   #include <malloc.h>
   #define PLATFORM_OS2
#elif defined(__NT__)
   // Win32 platform
   #include <windows.h>
   #define PLATFORM_WINNT
#else
   #error Unsupported platform
#endif
#include <ctype.h>
#include <stdio.h>
#include <conio.h>
#include <string.h>


#define STATUS_NOTINSTALLED 0 // No ID found
#define STATUS_CORRUPT      1 // ID found, Checksum failure
#define STATUS_INSTALLED    2 // ID found, Checksum valid
#define STATUS_INSTALLEDMGU 3 // ID found, Checksum valid, may get updated
#define STATUS_IMPOSSIBLE   4 // Unable/Not willing to install

// ============================================================================
//  Variables
// ============================================================================
CHAR   Track0[60*512];   // current track 0 from harddrive
CHAR   Bootcode[60*512]; // bootcode image from airboot.bin

UCHAR  Bootcode_LanguageID    = ' ';
USHORT Bootcode_Version       = 0;
USHORT Bootcode_ConfigVersion = 0;

UCHAR  Status_Code             = STATUS_NOTINSTALLED;
UCHAR  Status_Config           = STATUS_NOTINSTALLED;
USHORT Installed_CodeVersion   = 0;
USHORT Installed_ConfigVersion = 0;
UCHAR  Installed_LanguageID    = ' ';

BOOL   Option_ForceCode        = FALSE;
BOOL   Option_ForceConfig      = FALSE;
BOOL   Option_Silent           = FALSE;

BOOL   Install_Code            = FALSE;
BOOL   Install_Config          = FALSE;
BOOL   Install_IsCorrupt       = FALSE;

USHORT StatusCode = 0;
PSZ    ImpossibleCause = NULL;

// ============================================================================
//  Platform-specific helper functions
// ============================================================================
#ifdef PLATFORM_OS2
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

   // Special feature for OS/2, finds out boot drive letter and sends this
   //  information to AiR-BOOT, so that it's able to set that information
   //  during boot phase. Otherwise the user would have to set this.
   UCHAR AutoDriveLetter = ' ';
   ULONG AutoDriveLetterSerial = 0;

   void OS2_GetBootAutoDriveLetter (void) {
      ULONG  BootDrive;
      struct {
         ULONG       ulVSN;
         VOLUMELABEL vol;
       } InfoLevel2;
      DosQuerySysInfo (QSV_BOOT_DRIVE, QSV_BOOT_DRIVE, &BootDrive, sizeof(BootDrive));
      // BootDrive - 1-A:, 2-B:, 3-C:
      if ((BootDrive>2) & (!DosQueryFSInfo(BootDrive, FSIL_VOLSER, (PVOID)(&InfoLevel2), sizeof(InfoLevel2)))) {
         AutoDriveLetter       = BootDrive+0x7D;
         AutoDriveLetterSerial = InfoLevel2.ulVSN;
printf("%X\n", InfoLevel2.ulVSN);
       }
    }

   BOOL HarddriveCheckGeometry (void) {
      USHORT               IOCTLHandle;
      USHORT               SectorsPerTrack = 0;
      DEVICEPARAMETERBLOCK DeviceParmBlock;
      ULONG                ulDataLength; 

      IOCTLHandle = OS2_GetIOCTLHandle();

      if (!DosDevIOCtl(IOCTLHandle, IOCTL_PHYSICALDISK, PDSK_GETPHYSDEVICEPARAMS, NULL, 0, NULL, &DeviceParmBlock, sizeof(DeviceParmBlock), &ulDataLength))
         SectorsPerTrack = DeviceParmBlock.cSectorsPerTrack;
      OS2_FreeIOCTLHandle (IOCTLHandle);
      if (SectorsPerTrack>61) return TRUE;
      // OS/2 is only able to support 512-byte/sector media, so we dont need to check this
      return FALSE;
    }

   BOOL Track0Load (void) {
      USHORT      IOCTLHandle;
      ULONG       TrackLayoutLen  = sizeof(TRACKLAYOUT)+sizeof(ULONG)*(60-1);
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
      TrackLayoutPtr->cSectors      = 60;

      for (i=0; i<60; i++) {
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
      ULONG       TrackLayoutLen  = sizeof(TRACKLAYOUT)+sizeof(ULONG)*(60-1);
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
      TrackLayoutPtr->cSectors      = 60;

      for (i=0; i<60; i++) {
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
#endif

#ifdef PLATFORM_WINNT
   // Checks, if we are under NT
   BOOL CheckWindowsVersion (void) {
      OSVERSIONINFO Version;
      Version.dwOSVersionInfoSize = sizeof(Version);
      GetVersionEx(&Version);
      if (Version.dwPlatformId == VER_PLATFORM_WIN32_NT) return TRUE;
      printf(" - This installer is for WindowsNT family only.\n");
      printf("    Please use DOS installer for Windows9x.\n");
      return FALSE;
    }


   HANDLE WINNT_GetIOCTLHandle (void) {
      return CreateFile("\\\\.\\physicaldrive0", GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ|FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0);
    }

   void WINNT_FreeIOCTLHandle (HANDLE IOCTLHandle) {
      CloseHandle(IOCTLHandle);
    }
  
   USHORT CountHarddrives (void) {
      return 1;
    }

   BOOL HarddriveCheckGeometry (void) {
      HANDLE        IOCTLHandle;
      DISK_GEOMETRY Geometry;
      USHORT        SectorsPerTrack = 0;
      DWORD         Dummy;

      IOCTLHandle = WINNT_GetIOCTLHandle();
      if (DeviceIoControl(IOCTLHandle, IOCTL_DISK_GET_DRIVE_GEOMETRY, NULL, 0, &Geometry, sizeof(Geometry), &Dummy, NULL))
         SectorsPerTrack = Geometry.SectorsPerTrack;
      WINNT_FreeIOCTLHandle(IOCTLHandle);
      if (SectorsPerTrack>61) return TRUE;
      return FALSE;
    }

   BOOL Track0Load (void) {
      HANDLE      IOCTLHandle;
      DWORD       BytesRead = 0;
      BOOL        Success = FALSE;

      IOCTLHandle = WINNT_GetIOCTLHandle();
      SetFilePointer(IOCTLHandle, 0, 0, FILE_BEGIN);
      if (ReadFile(IOCTLHandle, &Track0, 60*512, &BytesRead, NULL))
         Success = TRUE;
      WINNT_FreeIOCTLHandle(IOCTLHandle);
      return Success;
    }

   BOOL Track0Write (void) {
      HANDLE      IOCTLHandle;
      DWORD       BytesWritten = 0;
      BOOL        Success = FALSE;

      IOCTLHandle = WINNT_GetIOCTLHandle();
      SetFilePointer(IOCTLHandle, 0, 0, FILE_BEGIN);
      if (WriteFile(IOCTLHandle, &Track0, 60*512, &BytesWritten, NULL))
         Success = TRUE;
      WINNT_FreeIOCTLHandle(IOCTLHandle);
      return Success;
    }

   void RebootSystem (void) {
      HANDLE           token;
      TOKEN_PRIVILEGES tokenpriv;
      OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES|TOKEN_QUERY, &token);
      LookupPrivilegeValue(NULL, SE_SHUTDOWN_NAME, &tokenpriv.Privileges[0].Luid);
      tokenpriv.PrivilegeCount = 1;
      tokenpriv.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
      AdjustTokenPrivileges(token, FALSE, &tokenpriv, 0, NULL, 0);
      ExitWindowsEx(EWX_REBOOT, 0);
    }
#endif

USHORT GetChecksumOfSector (USHORT Checksum, PCHAR SectorPtr) {
   PUSHORT TempPtr = (PUSHORT)SectorPtr;
   USHORT  i;
   for (i=0; i<256; i++) {
      Checksum = *TempPtr ^ 0xBABE ^ Checksum;
      TempPtr++;
    }
   if (Checksum==0) Checksum = 1;
   return Checksum;
 }

// Loads airboot.bin into memory (if possible) and sets some variables
//  also makes sure that airboot.bin has correct length
BOOL LoadBootcodeFromFile (void) {
   FILE  *FileHandle = NULL;
   ULONG BootcodeSize = 0;

   FileHandle = fopen("airboot.bin", "rb");
   if (!FileHandle) {
      printf("airboot.bin not found\n");
      return FALSE;
    }
   // Read whole file into memory...
   fseek (FileHandle, 0, SEEK_END);
   BootcodeSize = ftell(FileHandle);
   if (BootcodeSize!=30720) {
      fclose (FileHandle);
      printf("Invalid airboot.bin\n");
      return FALSE;
    }
   fseek (FileHandle, 0, SEEK_SET);
   fread (&Bootcode, 1, 30720, FileHandle);
   fclose (FileHandle);

//   Read airboot.bin failed

   Bootcode_Version = (Bootcode[13] << 8) | Bootcode[14];
   Bootcode_LanguageID = Bootcode[15];
   Bootcode_ConfigVersion = (Bootcode[0x6C0D] << 8) | Bootcode[0x6C0E];
   return TRUE;
 }

void Status_CheckCode (void) {
   USHORT TotalCodeSectorsUsed = 0;
   USHORT Checksum = 0;
   PCHAR  SectorPtr = NULL;

   if (Status_Code==STATUS_IMPOSSIBLE) return;
   // EZ-Setup check!
   Status_Code = STATUS_NOTINSTALLED;
   if ((Track0[0x1FE]!=0x55) || (Track0[0x1FF]!=0xAA)) return;
   if (strncmp(&Track0[2], "AiRBOOT", 7)!=0) return;
   // MBR and AiR-BOOT signature found...
   TotalCodeSectorsUsed = Track0[0x10];
   SectorPtr = &Track0[1*512]; // Start at sector 2
   while (TotalCodeSectorsUsed>0) {
      Checksum = GetChecksumOfSector(Checksum, SectorPtr);
      SectorPtr += 512;
      TotalCodeSectorsUsed--;
    }
   if (Checksum!=*(PUSHORT)&Track0[0x11]) {
      Status_Code = STATUS_CORRUPT; return;
    }
   // Checksum fine...
   Installed_LanguageID  = Track0[0x0F];
   Installed_CodeVersion = (Track0[0x0D] << 8) | Track0[0x0E];
   if (Installed_CodeVersion<Bootcode_Version)
      Status_Code = STATUS_INSTALLEDMGU;
     else
      Status_Code = STATUS_INSTALLED;
 }

void Status_CheckConfig (void) {
   PCHAR  ConfigSectorPtr = &Track0[0x6C00];
   PCHAR  SectorPtr = NULL;
   USHORT Checksum = 0;
   USHORT ConfigChecksum = 0;
   USHORT SectorCount = 0;

   if (strncmp(ConfigSectorPtr, "AiRCFG-TABLE­", 13)==0) {
      // AiR-BOOT signature found...
      SectorPtr = &Track0[54*512]; // Start at sector 55
      ConfigChecksum = *(PUSHORT)&Track0[54*512+20];
      // Remove checksum
      *(PUSHORT)&Track0[54*512+20] = 0;
      SectorCount = 5;
      while (SectorCount>0) {
         Checksum = GetChecksumOfSector(Checksum, SectorPtr);
         SectorPtr += 512;
         SectorCount--;
       }
      // Restore checksum
      *(PUSHORT)&Track0[54*512+20] = ConfigChecksum;
      if (Checksum!=ConfigChecksum) {
        Status_Config = STATUS_CORRUPT; return;
        return;
       }
      // Checksum fine
      Installed_ConfigVersion = (Track0[54*512+0x0D] << 8) | Track0[54*512+0x0E];
      if (Installed_ConfigVersion>=Bootcode_ConfigVersion) {
         Status_Config = STATUS_INSTALLED; return;
       }
      Status_Config = STATUS_INSTALLEDMGU;
      // Those upgrades will copy useful configuration data to the image config
      //  If new configuration data was added, those spaces are not overwritten
      // Sector 60 (MBR-BackUp) *MUST BE* copied, otherwise it would be lost.
      if (Installed_ConfigVersion<=0x27) {
         // UPGRADE v0.27 and prior versions

         // Sector 55
         // Changes: Offset  69 length 75 - Linux command line
         //          Offset 144 length  1 - Linux kernel partition
         //          Offset 145 Length 11 - Default kernel name
         //          Offset 156 Length  1 - Kernel name terminator 1
         //          Offset 157 Length 11 - Last kernel name
         //          Offset 168 Length  1 - Kernel name terminator 2
         //          Offset 169 Length  1 - Ext. partition M$-hack enable
         //           -> Total-length 101
         //          Offset 432 Length 34 - New IPT entry (BIOS continued)
         memcpy(&Bootcode[54*512+16], &Track0[54*512+16], 69-16);
         memcpy(&Bootcode[54*512+466], &Track0[54*512+466], 46);
         // Sector 56-57 no changes
         memcpy(&Bootcode[55*512], &Track0[55*512], 1024);
         // Sector 58-59
         // Changes: Offset 900 Length 30 - Logical driveletter table
         memcpy(&Bootcode[57*512], &Track0[57*512], 900);
         // Sector 60 copy unmodified
         memcpy(&Bootcode[59*512], &Track0[59*512], 512);
         return;
       }
      if (Installed_ConfigVersion<=0x91) {
         // UPGRADE v0.91 and prior versions
         // Sector 55-57 no changes
         memcpy(&Bootcode[54*512+16], &Track0[54*512+16], 512+1024-16);
         // Sector 58-59
         // Changes: Offset 900 Length 30 - Logical driveletter table
         memcpy(&Bootcode[57*512], &Track0[57*512], 900);
         // Sector 60 copy unmodified
         memcpy(&Bootcode[59*512], &Track0[59*512], 512);
         return;
       }
      // UPGRADE all later versions
      //  We don't need to "upgrade" the configuration, we simply copy it over.
      //   From Sector 55, 6 sectors in total but never header/version
      memcpy(&Bootcode[54*512+16], &Track0[54*512+16], 512*6-16);
      return;
    }
   // Check for prior v0.26 signature
   // not supported in C version anymore
   //  Don't have this version here for testing and I can't risk breaking
   //  configuration
 }

// Checks partition table for valid data
BOOL Virus_CheckThisMBR (PCHAR MBRptr) {
   USHORT PartitionNo;
   ULONG  CHSStart, CHSEnd;

   if (*(PUSHORT)(MBRptr + 510)!=0x0AA55) return FALSE;
   MBRptr += 446;
   for (PartitionNo=0; PartitionNo<4; PartitionNo++) {
      if (*(MBRptr+4)!=0) {
         // Partition-type defined, analyse partition data
         CHSStart = (*(MBRptr+3) | ((*(MBRptr+2) >> 6) << 8)) << 16; // Cylinder
         CHSStart |= (*(MBRptr+2) & 0x3F) | ((*(MBRptr+1) << 8)); // Sector / Head

         CHSEnd = (*(MBRptr+7) | ((*(MBRptr+6) >> 6) << 8)) << 16; // Cylinder
         CHSEnd |= (*(MBRptr+6) & 0x3F) | ((*(MBRptr+5) << 8)); // Sector / Head

         if (CHSStart<CHSEnd) {
            if (*(PULONG)(MBRptr+12)!=0) // Absolute length > 0?
               return TRUE;
          }
       }
      // Go to next partition
      MBRptr += 16;
    }
   // No partitions defined/no valid partitions found
   return FALSE;
 }

BOOL Virus_CheckCurrentMBR (void) {
   return Virus_CheckThisMBR(&Track0);
 }

BOOL Virus_CheckForBackUpMBR (void) {
   return Virus_CheckThisMBR(&Track0[59*512]);
 }

BOOL Virus_CheckForStealth (void) {
   PCHAR  CurPtr = &Track0;
   USHORT i;

   for (i=0; i<511; i++) {
      if (*(PUSHORT)CurPtr==0x13CD) return FALSE;
      CurPtr++;
    }
   // No CD13h found? possible stealth
   return TRUE;
 }

// Copies backup MBR into current MBR on current memory copy of track 0
void Virus_CopyBackUpMBR (void) {
   memcpy(&Track0, &Track0[59*512], 512);
 }

void Status_PrintF (ULONG Status, USHORT Version) {
   switch (Status) {
    case STATUS_NOTINSTALLED: {
       printf("not installed\n");
       break;
     }
    case STATUS_CORRUPT: {
       printf("not intact\n");
       break;
     }
    case STATUS_INSTALLED:
    case STATUS_INSTALLEDMGU:
       printf("intact (v%x.%02x)", Version>>8, Version & 0x0FF);
       if (Status==STATUS_INSTALLEDMGU) printf(", but may be updated");
       printf("\n");
       break;
    case STATUS_IMPOSSIBLE:
       printf(ImpossibleCause);
       break;
    }
 }

void Language_PrintF(UCHAR LanguageID) {
   switch (LanguageID) {
     case 'E': printf("english"); break;
     case 'D': printf("dutch"); break;
     case 'G': printf("german"); break;
     case 'F': printf("french"); break;
     case 'I': printf("italian"); break;
     case 'R': printf("russian"); break;
     case 'S': printf("swedish"); break;
     default:  printf("unknown");
    }
 }

// Doesn't actually write code/config, but writes it to track0 memory
void Install_WriteCode (void) {
   USHORT TotalCodeSectorsUsed = 0;
   USHORT SectorCount = 0;
   USHORT Checksum = 0;
   PCHAR  SectorPtr = NULL;

   // Calculate checksum for code...
   TotalCodeSectorsUsed = Bootcode[0x10];
   SectorPtr = &Bootcode[1*512]; // Start at sector 2
   SectorCount = TotalCodeSectorsUsed;
   while (SectorCount>0) {
      Checksum = GetChecksumOfSector(Checksum, SectorPtr);
      SectorPtr += 512;
      SectorCount--;
    }
   *(PUSHORT)&Bootcode[0x11] = Checksum;

   // Copy MBR till offset 0x1B8 (Windows NT hdd signature location)
   memcpy(&Track0, &Bootcode, 0x1B8);

   // Copy over code sectors...
   memcpy(&Track0[512], &Bootcode[512], TotalCodeSectorsUsed*512);
 }

void Install_WriteConfig (void) {
   USHORT SectorCount = 0;
   USHORT Checksum = 0;
   PCHAR  SectorPtr = NULL;

   #ifdef PLATFORM_OS2
      if (AutoDriveLetter!=0) {
         // Add DriveLetter Automatic veriables, if set
         Bootcode[54*512+0x1AB] = AutoDriveLetter;
         *(PULONG)&Bootcode[54*512+0x1AC] = AutoDriveLetterSerial;
       }
   #endif

   // Delete current checksum
   *(PUSHORT)&Bootcode[54*512+20] = 0;

   SectorPtr = &Bootcode[54*512]; // Start at sector 55
   SectorCount = 5;
   while (SectorCount>0) {
      Checksum = GetChecksumOfSector(Checksum, SectorPtr);
      SectorPtr += 512;
      SectorCount--;
    }
   *(PUSHORT)&Bootcode[54*512+20] = Checksum;

   // Copy configuration sectors
   memcpy(&Track0[54*512], &Bootcode[54*512], 6*512);
 }

#define MAXCMDPARMLEN 11

int main (int argc, char **argv) {
   ULONG  CurArgument = 0;
   ULONG  ArgumentLen = 0;
   PCHAR  StartPos    = 0;
   CHAR   TempSpace[MAXCMDPARMLEN+1];
   UCHAR  UserKey     = ' ';
   BOOL   ExitOnly    = FALSE;

   printf("AiR-BOOT Installer v1.00\n");
   printf(" - (c) Copyright 1998-2009 by Martin Kiewitz.\n");
   printf("\n-> ...Please wait... <-\n");

   // Check commandline parameters
   CurArgument = 1;
   while (CurArgument<argc) {
      StartPos = argv[CurArgument];
      ArgumentLen = strlen(StartPos);

      if (((*StartPos=='-') || (*StartPos=='/')) && (ArgumentLen>1)) {
         StartPos++; ArgumentLen--;
         if (ArgumentLen>MAXCMDPARMLEN) ArgumentLen = MAXCMDPARMLEN;
         strncpy(&TempSpace, StartPos, ArgumentLen);
         TempSpace[ArgumentLen] = 0;
         StartPos = &TempSpace;
         while (*StartPos!=0) {
            *StartPos = tolower(*StartPos); StartPos++;
          }
         if (strcmp(&TempSpace, "forcecode")==0) Option_ForceCode = TRUE;
         if (strcmp(&TempSpace, "forceconfig")==0) Option_ForceConfig = TRUE;
         if (strcmp(&TempSpace, "silent")==0) Option_Silent = TRUE;
       }
      CurArgument++;
    }

   #ifdef PLATFORM_WINNT
      if (CheckWindowsVersion()==FALSE) return 1;
   #endif

   if (CountHarddrives()==0) {
      printf(" - No physical drives found on this system. Install impossible.\n");
      return 1;
    }

   printf(" - Loading bootcode from file...");
   if (LoadBootcodeFromFile()==FALSE) return 1;
   printf("ok\n");

   printf(" - Loading MBR from harddisc...");
   if (HarddriveCheckGeometry()) {
      // No EZ-SETUP check here, because we are under 32-bit OS and this
      //  wouldn't make any sense
      if (!Track0Load()) {
         printf("LOAD ERROR!\n");
         return 1;
       }
    } else {
      StatusCode = STATUS_IMPOSSIBLE;
      ImpossibleCause = "unable to install\n   Your harddisc does not have at least 62 sectors per track.";
    }
   printf("ok\n");


   printf("\n-> ...Current Status... <-\n");
   Status_CheckCode();
   printf(" - AiR-BOOT is ");
   Status_PrintF(Status_Code, Installed_CodeVersion);
   if (StatusCode==STATUS_IMPOSSIBLE) return 1;
   Status_CheckConfig();
   printf(" - Configuration is ");
   Status_PrintF(Status_Config, Installed_ConfigVersion);
   // Display language as well, if code installed
   if ((Status_Code==STATUS_INSTALLED) || (Status_Code==STATUS_INSTALLEDMGU)) {
      printf(" - Language is ");
      Language_PrintF(Installed_LanguageID);
      printf("\n");
    }

   // =============================================================
   //  PRE-CHECKING, WHAT WE ARE SUPPOSED TO DO...
   // =============================================================
   if ((Option_ForceCode) || (Status_Code!=STATUS_INSTALLED) || (Installed_LanguageID!=Bootcode_LanguageID))
      Install_Code = TRUE;  // If LanguageID different or not installed
   if ((Option_ForceConfig) || (Status_Config!=STATUS_INSTALLED))
      Install_Config = TRUE; // If not installed

   if ((Status_Code==STATUS_CORRUPT) || (Status_Config==STATUS_CORRUPT))
      Install_IsCorrupt = TRUE; // If anything is corrupt

   // =============================================================
   //  VIRUS
   // =============================================================
   // If-Table
   // ---------
   //  Code==not installed, Config=not installed -> Check MBR
   //  Code==installed, config==installed -> Check MBR (-> Virus?)
   //  Code==not installed, config==installed -> (-> Virus?)
   //  Code==installed, config==not installed -> Check MBR (-> Virus?)
   if ((Status_Code==STATUS_NOTINSTALLED) & (Status_Config==STATUS_NOTINSTALLED)) {
      // Nothing installed, so check MBR, if squashed...
      if (!Virus_CheckCurrentMBR()) {
         printf("\n\n");
         printf("AiR-BOOT detected that the data on your harddisc got damaged.\n");
         printf("If you had AiR-BOOT installed before: the corruption killed AiR-BOOT completly!\n");
         printf("Installation halted.\n");
         return 1;
       }
    } else {
      if ((Status_Code==STATUS_NOTINSTALLED) | (!Virus_CheckCurrentMBR())) {
         // Code not installed, but Config or MBR squashed...
         //  -> Virus proposed, check for backup (if available)
         printf("\n\n");
         printf("-> ...!ATTENTION!... <-\n");
         if (Virus_CheckForStealth())
            printf("Your system GOT infected by a stealth-virus (or your MBR got trashed).\n");
           else
            printf("Probably your system was infected by a virus.\n");
         printf("Repairing AiR-BOOT will normally squash the virus.\n");
         printf("But to be sure it's gone, you should check your harddisc using a virus-scanner.\n");
         if (!Virus_CheckCurrentMBR()) {
            // MBR squashed, so check backup and display message
            printf("\n");
            printf("AiR-BOOT detected that the virus has broken your partition-table.\n");
            if (Virus_CheckForBackUpMBR()) {
               printf("Good news: AiR-BOOT has found a (hopefully) functional backup.\n");
               printf("Shall I use this backup, instead of the current active one? (Y/N)\n");
               // User selection, Y/N, if he wants to restore MBR
               //  *NOT* CID (silent) able
               do {
                  UserKey = getch() | 0x20;
                } while (!((UserKey=='y') | (UserKey=='n')));
               if (UserKey=='y')
                  Virus_CopyBackUpMBR();
             } else {
               printf("Sadly the virus also broke AiR-BOOT's backup. You will have to help yourself.\n");
             }
          }
       }
    }

   // =============================================================
   //  MAIN-MENU
   // =============================================================
   printf("\n-> ...Please press... <-\n");

   if (Install_IsCorrupt) printf(" <R> - Repair AiR-BOOT ");
    else if (Status_Code==STATUS_NOTINSTALLED) printf(" <A> - Add AiR-BOOT ");
    else printf(" <U> - Update/Change AiR-BOOT to ");
   printf("'v%x.%02x/", Bootcode_Version>>8, Bootcode_Version & 0x0FF);
   Language_PrintF(Bootcode_LanguageID);
   printf("' on current system\n");

   printf(" <D> - Delete AiR-BOOT from current system\n");
   printf(" <Q> - Quit without any change\n");

   if (Option_Silent) {
      // Silent operation? Always add AiR-BOOT then
      UserKey = 'a';
    } else {
      do {
         UserKey = getch() | 0x20;
       } while (!((UserKey=='a') || (UserKey=='r') || (UserKey=='u') || (UserKey=='d') || (UserKey=='q')));
    }

   printf("\n\n\n-------------------------------------------------------------------------------\n");
   switch (UserKey) {
    case 'a':
    case 'r':
    case 'u': {
      if (Install_Code || Install_Config) {
         printf("Add/Repair/Update AiR-BOOT in progress...\n");
         #ifdef PLATFORM_OS2
            OS2_GetBootAutoDriveLetter();
         #endif
         if (Install_Code) {
            printf(" þ Writing AiR-BOOT code...");
            Install_WriteCode();
            printf("ok\n");
          }
         if (Install_Config) {
            printf(" þ Writing AiR-BOOT configuration...");
            Install_WriteConfig();
            printf("ok\n");
          }

         if (!Track0Write()) {
            printf("SAVE ERROR!\n");
            return 1;
          }
         printf("\n");
         printf("Your copy of AiR-BOOT is now fully functional.\n");
         printf("Please hit ESC to exit AiR-BOOT installer or ENTER to reboot your system...\n");
         if (Option_Silent) {
            // Silent operation? Always reboot system (shall we do this really?)
            UserKey = 0x0D;
          } else {
            do {
               UserKey = getch();             // React on ENTER or ESC
             } while (!((UserKey==0x0D) || (UserKey==0x1B)));
          }
         if (UserKey==0x0D) {              // ENTER reboots system...
            printf("Now rebooting system...\n");
            RebootSystem();
          }
       } else {
         printf(" þ All components of AiR-BOOT are intact and up-to-date. Nothing to do.\n");
         ExitOnly = TRUE;
        }
       break;
     }
    case 'd': {
      printf(" þ Removing AiR-BOOT automatically is not possible at this time.\n");
      #ifdef PLATFORM_OS2
         printf("    You may remove AiR-BOOT manually by entering \"FDISK /MBR\" or \"LVM /NEWMBR:1\"\n");
         printf("    in commandline.\n");
      #endif
      #ifdef PLATFORM_WINNT
         printf("    You may remove AiR-BOOT manually by entering \"FDISK /MBR\" in commandline.\n");
      #endif
      ExitOnly = TRUE;
      break;
     }
    default:
     break;
    }

   if (ExitOnly) {
      printf("\n");
      printf("Please hit ENTER to exit AiR-BOOT installer...\n");
      if (!Option_Silent) {
         while (getch()!=0x0D);
       }
    }
   return 0;
 }
