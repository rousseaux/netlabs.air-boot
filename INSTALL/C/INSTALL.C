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
   #include <stdlib.h>                                                           // Rousseau: added to use getenv()
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


#define  STATUS_NOTINSTALLED     0 // No ID found
#define  STATUS_CORRUPT          1 // ID found, Checksum failure
#define  STATUS_INSTALLED        2 // ID found, Checksum valid
#define  STATUS_INSTALLEDMGU     3 // ID found, Checksum valid, may get updated
#define  STATUS_IMPOSSIBLE       4 // Unable/Not willing to install

/* Rousseau: added */
#define  GPT                     0xEE                                            // GPT Disk, AiR-BOOT will abort
#define  BYTES_PER_SECTOR        512                                             // This could be higher in the future
#define  IMAGE_SIZE_60SECS       30720                                           // Normal image-size    (max. 30 partitions)
#define  IMAGE_SIZE_62SECS       31744                                           // Extended image-size  (max. 45 partitions)
//#define  IMAGE_SIZE              IMAGE_SIZE_60SECS                               // Use the normal image
#define  IMAGE_SIZE              IMAGE_SIZE_62SECS                               // Use the extended image
#define  SECTOR_COUNT            IMAGE_SIZE / BYTES_PER_SECTOR                   // Size of the image in sectors
#define  CONFIG_OFFSET           0x6C00                                          // Byte offset of config-sector
#define  SECTORS_BEFORE_CONFIG   CONFIG_OFFSET / BYTES_PER_SECTOR                // Nr of sectors before config-sector



// ============================================================================
//  Variables
// ============================================================================
CHAR   Track0[SECTOR_COUNT * BYTES_PER_SECTOR];                                  // current track 0 from harddrive
CHAR   Bootcode[SECTOR_COUNT * BYTES_PER_SECTOR];                                // bootcode image from airboot.bin

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

BOOL   Option_CID              = FALSE;                                          // Rousseau: added

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
         if (!Option_CID) {
            printf("%X\n", InfoLevel2.ulVSN);
         }
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
      //if (SectorsPerTrack > 61) return TRUE;              // >60 should also be ok for normal image (60 for image 1 for lvm)
      if (SectorsPerTrack > SECTOR_COUNT) return TRUE;      // Note: This is 1 sector smaller than above !!
      // OS/2 is only able to support 512-byte/sector media, so we dont need to check this
      return FALSE;
    }

   BOOL Track0Load (void) {
      USHORT      IOCTLHandle;
      ULONG       TrackLayoutLen  = sizeof(TRACKLAYOUT)+sizeof(ULONG)*(SECTOR_COUNT-1);
      TRACKLAYOUT *TrackLayoutPtr = malloc(TrackLayoutLen);
      ULONG       cbParms = sizeof(TrackLayoutPtr);
      ULONG       cbData  = BYTES_PER_SECTOR;
      int         i;
      BOOL        Success = FALSE;

      IOCTLHandle = OS2_GetIOCTLHandle();

      TrackLayoutPtr->bCommand      = 0x01;
      TrackLayoutPtr->usHead        = 0;
      TrackLayoutPtr->usCylinder    = 0;
      TrackLayoutPtr->usFirstSector = 0;
      TrackLayoutPtr->cSectors      = SECTOR_COUNT;

      for (i=0; i<SECTOR_COUNT; i++) {
         TrackLayoutPtr->TrackTable[i].usSectorNumber = i+1;
         TrackLayoutPtr->TrackTable[i].usSectorSize   = BYTES_PER_SECTOR;
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
      ULONG       TrackLayoutLen  = sizeof(TRACKLAYOUT)+sizeof(ULONG)*(SECTOR_COUNT-1);
      TRACKLAYOUT *TrackLayoutPtr = malloc(TrackLayoutLen);
      ULONG       cbParms = sizeof(TrackLayoutPtr);
      ULONG       cbData  = BYTES_PER_SECTOR;
      INT         i;
      BOOL        Success = FALSE;

      IOCTLHandle = OS2_GetIOCTLHandle();


      TrackLayoutPtr->bCommand      = 0x01;
      TrackLayoutPtr->usHead        = 0;
      TrackLayoutPtr->usCylinder    = 0;
      TrackLayoutPtr->usFirstSector = 0;
      TrackLayoutPtr->cSectors      = SECTOR_COUNT;

      for (i=0; i<SECTOR_COUNT; i++) {
         TrackLayoutPtr->TrackTable[i].usSectorNumber = i+1;
         TrackLayoutPtr->TrackTable[i].usSectorSize   = BYTES_PER_SECTOR;
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
      if (!Option_CID) {
         printf(" - This installer is for WindowsNT family only.\n");
         printf("    Please use DOS installer for Windows9x.\n");
      }
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
      //if (SectorsPerTrack > 61) return TRUE;              // >60 should also be ok for normal image (60 for image 1 for lvm)
      if (SectorsPerTrack > SECTOR_COUNT) return TRUE;      // Note: This is 1 sector smaller than above !!
      return FALSE;
    }

   BOOL Track0Load (void) {
      HANDLE      IOCTLHandle;
      DWORD       BytesRead = 0;
      BOOL        Success = FALSE;

      IOCTLHandle = WINNT_GetIOCTLHandle();
      SetFilePointer(IOCTLHandle, 0, 0, FILE_BEGIN);
      if (ReadFile(IOCTLHandle, &Track0, SECTOR_COUNT * BYTES_PER_SECTOR, &BytesRead, NULL))
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
      if (WriteFile(IOCTLHandle, &Track0, SECTOR_COUNT * BYTES_PER_SECTOR, &BytesWritten, NULL))
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
      if (!Option_CID) {
         printf("airboot.bin not found\n");
      }
      return FALSE;
    }
   // Read whole file into memory...
   fseek (FileHandle, 0, SEEK_END);
   BootcodeSize = ftell(FileHandle);
   if (BootcodeSize!=IMAGE_SIZE) {
      fclose (FileHandle);
      if (!Option_CID) {
         printf("Invalid airboot.bin\n");
      }
      return FALSE;
    }
   fseek (FileHandle, 0, SEEK_SET);
   fread (&Bootcode, 1, IMAGE_SIZE, FileHandle);
   fclose (FileHandle);

//   Read airboot.bin failed

   Bootcode_Version = (Bootcode[13] << 8) | Bootcode[14];
   Bootcode_LanguageID = Bootcode[15];
   Bootcode_ConfigVersion = (Bootcode[0x6C0D] << 8) | Bootcode[0x6C0E];
   return TRUE;
 }

/**
 * Check MBR and AB signatures.
 * Also check code sectors if AB is installed.
 * Set global status accordingly.
 */
void Status_CheckCode (void) {
   USHORT TotalCodeSectorsUsed = 0;
   USHORT Checksum = 0;
   PCHAR  SectorPtr = NULL;

   if (Status_Code==STATUS_IMPOSSIBLE) return;
   // EZ-Setup check!
   Status_Code = STATUS_NOTINSTALLED;
   if ((Track0[0x1FE]!=0x55) || (Track0[0x1FF]!=0xAA)) return;                   // No MBR signature found, so not installed
   if (strncmp(&Track0[2], "AiRBOOT", 7)!=0) return;                             // No AiR-BOOT signature found, so not installed
   // MBR and AiR-BOOT signature found...
   TotalCodeSectorsUsed = Track0[0x10];                                          // 34h/52 in v1.06
   SectorPtr = &Track0[1 * BYTES_PER_SECTOR]; // Start at sector 2
   // Calculate checksum of code-sectors
   while (TotalCodeSectorsUsed>0) {
      Checksum = GetChecksumOfSector(Checksum, SectorPtr);
      SectorPtr += BYTES_PER_SECTOR;
      TotalCodeSectorsUsed--;
    }
   if (Checksum!=*(PUSHORT)&Track0[0x11]) {
      Status_Code = STATUS_CORRUPT; return;                                      // Bad checksum for code
    }
   // Checksum fine...
   Installed_LanguageID  = Track0[0x0F];
   Installed_CodeVersion = (Track0[0x0D] << 8) | Track0[0x0E];
   if (Installed_CodeVersion<Bootcode_Version)
      Status_Code = STATUS_INSTALLEDMGU;                                         // Do upgrade
     else
      Status_Code = STATUS_INSTALLED;                                            // Same version installed
 }


void Status_CheckConfig (void) {
   PCHAR  ConfigSectorPtr = &Track0[CONFIG_OFFSET];                              // Config sector offset hard-coded !
   PCHAR  SectorPtr = NULL;
   USHORT Checksum = 0;
   USHORT ConfigChecksum = 0;
   USHORT SectorCount = 0;

   /*
   // Note that the 'AiRCFG-TABLE' string includes the invisible 0xAD char.
   */
   if (strncmp(ConfigSectorPtr, "AiRCFG-TABLE­", 13)==0) {
      // AiR-BOOT signature found...
      SectorPtr = &Track0[54 * BYTES_PER_SECTOR];                                // Start at sector 55
      ConfigChecksum = *(PUSHORT)&Track0[54 * BYTES_PER_SECTOR + 20];
      // Remove checksum
      *(PUSHORT)&Track0[54 * BYTES_PER_SECTOR + 20] = 0;                         // Config sector secnum hard-coded !

      /*
      // Rousseau: # Keep compatible with v1.07 CRC #
      // AB v1.07 had bugs in writing the wrong number of AB config sectors.
      // This is fixed in v1.0.8 but the CRC has to be calculated the "v1.07 way"
      // otherwise v1.07 SET(A)BOOT and INSTALL2.EXE will think the AB config
      // is corrupted.
      // So the CRC is calculated over 5 sectors instead of 7.
      */
      SectorCount = 5;

      while (SectorCount>0) {
         Checksum = GetChecksumOfSector(Checksum, SectorPtr);
         SectorPtr += BYTES_PER_SECTOR;
         SectorCount--;
       }
      // Restore checksum
      *(PUSHORT)&Track0[54 * BYTES_PER_SECTOR + 20] = ConfigChecksum;            // Config sector secnum hard-coded !
      if (Checksum!=ConfigChecksum) {
        Status_Config = STATUS_CORRUPT; return;
        return;
       }
      // Checksum fine
      Installed_ConfigVersion = (Track0[54 * BYTES_PER_SECTOR + 0x0D] << 8) | Track0[54 * BYTES_PER_SECTOR + 0x0E];
      if (Installed_ConfigVersion>=Bootcode_ConfigVersion) {
         Status_Config = STATUS_INSTALLED; return;
       }
      Status_Config = STATUS_INSTALLEDMGU;
      // Those upgrades will copy useful configuration data to the image config
      //  If new configuration data was added, those spaces are not overwritten
      // Sector 60 (MBR-BackUp) *MUST BE* copied, otherwise it would be lost.
      // Rousseau: Upgrade from v0.27
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
         memcpy(&Bootcode[54 * BYTES_PER_SECTOR + 16], &Track0[54 * BYTES_PER_SECTOR + 16], 69 - 16);    // CHECKEN !!
         memcpy(&Bootcode[54 * BYTES_PER_SECTOR + 466], &Track0[54 * BYTES_PER_SECTOR + 466], 46);       // CHECKEN !!
         // Sector 56-57 no changes
         memcpy(&Bootcode[55*512], &Track0[55 * BYTES_PER_SECTOR], 1024);
         // Sector 58-59
         // Changes: Offset 900 Length 30 - Logical driveletter table
         memcpy(&Bootcode[57 * BYTES_PER_SECTOR], &Track0[57 * BYTES_PER_SECTOR], 900);               // AANPASSEN 900 !!
         // Sector 60 copy unmodified
         memcpy(&Bootcode[59 * BYTES_PER_SECTOR], &Track0[59 * BYTES_PER_SECTOR], BYTES_PER_SECTOR);  // CHECKEN !!
         return;
       }
      // Rousseau: Upgrade from v0.91
      if (Installed_ConfigVersion<=0x91) {
         // UPGRADE v0.91 and prior versions
         // Sector 55-57 no changes
         memcpy(&Bootcode[54 * BYTES_PER_SECTOR + 16], &Track0[54 * BYTES_PER_SECTOR + 16], BYTES_PER_SECTOR + 1024 - 16);   // CHACKEN !!
         // Sector 58-59
         // Changes: Offset 900 Length 30 - Logical driveletter table
         memcpy(&Bootcode[57 * BYTES_PER_SECTOR], &Track0[57 * BYTES_PER_SECTOR], 900);               // AANPASSEN 900 !!
         // Sector 60 copy unmodified
         memcpy(&Bootcode[59 * BYTES_PER_SECTOR], &Track0[59 * BYTES_PER_SECTOR], BYTES_PER_SECTOR);
         return;
       }
      // UPGRADE all later versions
      //  We don't need to "upgrade" the configuration, we simply copy it over.
      //   From Sector 55, 6 sectors in total but never header/version
      // Rousseau: We copy two more sectors (8 in total) in the extended (45 partition) version.
      switch (IMAGE_SIZE) {
         case IMAGE_SIZE_60SECS: {
            memcpy(&Bootcode[54 * BYTES_PER_SECTOR + 16], &Track0[54 * BYTES_PER_SECTOR + 16], BYTES_PER_SECTOR * 6 - 16);
            break;
         }
         case IMAGE_SIZE_62SECS: {
            memcpy(&Bootcode[54 * BYTES_PER_SECTOR + 16], &Track0[54 * BYTES_PER_SECTOR + 16], BYTES_PER_SECTOR * 8 - 16);
            break;
         }
      }

      return;
    }
   // Check for prior v0.26 signature
   // not supported in C version anymore
   //  Don't have this version here for testing and I can't risk breaking
   //  configuration
 }

// Checks partition table for valid data
BOOL Virus_CheckThisMBR (PCHAR MBRptr) {                                         // Rousseau: adjusted this function
   USHORT PartitionNo;
   ////ULONG  CHSStart, CHSEnd;

   //printf("DEBUG: Virus_CheckThisMBR\n");

   if (*(PUSHORT)(MBRptr + BYTES_PER_SECTOR - 2)!=0x0AA55) return FALSE;

   //printf("DEBUG: Virus_CheckThisMBR - Checking Partitions\n");

   MBRptr += 446;
   for (PartitionNo=0; PartitionNo<4; PartitionNo++) {
      if (*(MBRptr+4) != 0) {
         /*
         // Rousseau 2011-02-04: ## Check for GPT ##
         */
         if (*(MBRptr+4) == GPT) {
            if (!Option_CID) {
               printf("ERROR: This drive is partitioned with the modern GPT layout.\n");
               printf("       AiR-BOOT is currently unable to handle GPT partitioned drives.\n");
               printf("       Installation aborted, no changes made.\n");
            }
            exit(2);
         }

         /*
         // Rousseau: 2011-05-05
         //           Last minute change to have AB install a disk with nopartitions
         //           on the bootdisk.
         //           It still checks for GPT but will skip the check below.
         */
         continue;

         //printf("DEBUG: Virus_CheckThisMBR - Partition: %d\n", PartitionNo);
         // Partition-type defined, analyse partition data
         ////CHSStart = (*(MBRptr+3) | ((*(MBRptr+2) >> 6) << 8)) << 16;             // Cylinder
         ////CHSStart |= (*(MBRptr+2) & 0x3F) | ((*(MBRptr+1) << 8));                // Sector / Head
         //printf("DEBUG: Virus_CheckThisMBR - CHSStart: %d\n", CHSStart);                               // 3F MASK CHECKEN !!

         ////CHSEnd = (*(MBRptr+7) | ((*(MBRptr+6) >> 6) << 8)) << 16;               // Cylinder
         ////CHSEnd |= (*(MBRptr+6) & 0x3F) | ((*(MBRptr+5) << 8));                  // Sector / Head
         //printf("DEBUG: Virus_CheckThisMBR - CHSEnd: %d\n", CHSEnd);


         /*
         // Rousseau 2011-02-03: ## Changed below from < to <= ##
         // When a partition is above 1024x255x63 (8GiB) the start and end of the partition
         // in the MBR is the same (1024/255/63) to indicate extended CHS-values.
         // This made the installer see this as a non-valid entry.
         // Fixme: This could use some further optimazation like checking if CHS is really 1024/255/63
         //        to exclude truly faulty partition-entries.
         */
         /*if (CHSStart<CHSEnd) {*/
         ////if (CHSStart<=CHSEnd) {
         ////   if (*(PULONG)(MBRptr+12)!=0) // Absolute length > 0?
         ////      return TRUE;
          ////}
       }
      // Go to next partition
      MBRptr += 16;
    }
   // No partitions defined/no valid partitions found
   // Rousseau: Still return TRUE (OK)
   //return FALSE;
   return TRUE;
 }

BOOL Virus_CheckCurrentMBR (void) {
   return Virus_CheckThisMBR(&Track0);
 }

BOOL Virus_CheckForBackUpMBR (void) {
   return Virus_CheckThisMBR(&Track0[59 * BYTES_PER_SECTOR]);
 }

BOOL Virus_CheckForStealth (void) {
   PCHAR  CurPtr = &Track0;
   USHORT i;

   for (i=0; i<511; i++) {                                                       // BYTES_PER_SECTOR RELATED ??
      if (*(PUSHORT)CurPtr==0x13CD) return FALSE;
      CurPtr++;
    }
   // No CD13h found? possible stealth
   return TRUE;
 }

// Copies backup MBR into current MBR on current memory copy of track 0
// Rousseau: Two sectors higher in the extended version.
void Virus_CopyBackUpMBR (void) {
   switch (IMAGE_SIZE) {
      case IMAGE_SIZE_60SECS: {
         memcpy(&Track0, &Track0[59 * BYTES_PER_SECTOR], BYTES_PER_SECTOR);      // sector 60
         break;
      }
      case IMAGE_SIZE_62SECS: {
         memcpy(&Track0, &Track0[61 * BYTES_PER_SECTOR], BYTES_PER_SECTOR);      // sector 62
         break;
      }
   }
 }

void Status_PrintF (ULONG Status, USHORT Version) {
   switch (Status) {
    case STATUS_NOTINSTALLED: {
       if (!Option_CID) {
         printf("not installed\n");
      }
       break;
     }
    case STATUS_CORRUPT: {
       if (!Option_CID) {
         printf("not intact\n");
      }
       break;
     }
    case STATUS_INSTALLED:
    case STATUS_INSTALLEDMGU:
       if (!Option_CID) {
         printf("intact (v%x.%1d.%1d)", Version>>8, (Version & 0x0F0)>>4, Version & 0x0F);

       }
       if (Status==STATUS_INSTALLEDMGU)
         if (!Option_CID) {
            printf(", but may be updated");
            printf("\n");
         }
       break;
    case STATUS_IMPOSSIBLE:
      if (!Option_CID) {
         printf(ImpossibleCause);
      }
       break;
    }
 }

void Language_PrintF(UCHAR LanguageID) {
   if (Option_CID)
      return;
   switch (LanguageID) {
     case 'E': printf("english"); break;
     case 'N': printf("dutch"); break;       // Changed from 'D' to 'N'
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
   TotalCodeSectorsUsed = Bootcode[0x10];                                        // SECTORS USED CHECKEN !! (34h / 52d in v1.06)
   SectorPtr = &Bootcode[1 * BYTES_PER_SECTOR]; // Start at sector 2
   SectorCount = TotalCodeSectorsUsed;
   while (SectorCount>0) {
      Checksum = GetChecksumOfSector(Checksum, SectorPtr);
      SectorPtr += BYTES_PER_SECTOR;
      SectorCount--;
    }
   *(PUSHORT)&Bootcode[0x11] = Checksum;

   // Copy MBR till offset 0x1B8 (Windows NT hdd signature location)
   memcpy(&Track0, &Bootcode, 0x1B8);

   // Copy over code sectors...
   memcpy(&Track0[BYTES_PER_SECTOR], &Bootcode[BYTES_PER_SECTOR], TotalCodeSectorsUsed * BYTES_PER_SECTOR);
 }

void Install_WriteConfig (void) {
   USHORT SectorCount = 0;
   USHORT Checksum = 0;
   PCHAR  SectorPtr = NULL;

   #ifdef PLATFORM_OS2
      if (AutoDriveLetter!=0) {
         // Add DriveLetter Automatic veriables, if set
         Bootcode[54 * BYTES_PER_SECTOR + 0x1AB] = AutoDriveLetter;                       // CHECKEN !
         *(PULONG)&Bootcode[54 * BYTES_PER_SECTOR + 0x1AC] = AutoDriveLetterSerial;
       }
   #endif

   // Delete current checksum
   *(PUSHORT)&Bootcode[54 * BYTES_PER_SECTOR + 20] = 0;

   SectorPtr = &Bootcode[54 * BYTES_PER_SECTOR];                                 // Start at sector 55

   /*
   // Rousseau: # Keep compatible with v1.07 CRC #
   // AB v1.07 had bugs in writing the wrong number of AB config sectors.
   // This is fixed in v1.0.8 but the CRC has to be calculated the "v1.07 way"
   // otherwise v1.07 SET(A)BOOT and INSTALL2.EXE will think the AB config
   // is corrupted.
   // So the CRC is calculated over 5 sectors instead of 7.
   */
   SectorCount = 5;

   while (SectorCount>0) {
      Checksum = GetChecksumOfSector(Checksum, SectorPtr);
      SectorPtr += BYTES_PER_SECTOR;
      SectorCount--;
    }
   *(PUSHORT)&Bootcode[54 * BYTES_PER_SECTOR + 20] = Checksum;

   // Copy configuration sectors
   // Rousseau: Two more sectors for extended version.
   switch (IMAGE_SIZE) {
      case IMAGE_SIZE_60SECS: {
         memcpy(&Track0[54 * BYTES_PER_SECTOR], &Bootcode[54 * BYTES_PER_SECTOR], 6 * BYTES_PER_SECTOR);
         break;
      }
      case IMAGE_SIZE_62SECS: {
         memcpy(&Track0[54 * BYTES_PER_SECTOR], &Bootcode[54 * BYTES_PER_SECTOR], 8 * BYTES_PER_SECTOR);
         break;
      }
   }
 }

#define MAXCMDPARMLEN 11

int main (int argc, char **argv) {
   ULONG  CurArgument = 0;
   ULONG  ArgumentLen = 0;
   PCHAR  StartPos    = 0;
   CHAR   TempSpace[MAXCMDPARMLEN+1];
   UCHAR  UserKey     = ' ';
   BOOL   ExitOnly    = FALSE;

//   printf("AiR-BOOT Installer v1.07\n");
//   printf(" - (c) Copyright 1998-2011 by Martin Kiewitz.\n");
//   printf("\n-> ...Please wait... <-\n");

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
         if (strcmp(&TempSpace, "cid")==0) Option_CID = TRUE;
       }
      CurArgument++;
    }

   if (Option_CID) {
      Option_Silent = TRUE;
   }

   #ifdef PLATFORM_WINNT
      if (CheckWindowsVersion()==FALSE) return 1;
   #endif

   if (CountHarddrives()==0) {
      if (!Option_CID) {
         printf(" - No physical drives found on this system. Install impossible.\n");
      }
      return 3;   // Rouseau: changed from 1 to 3
    }

   if (!Option_CID) {
      printf(" - Loading bootcode from file...");
   }
   if (LoadBootcodeFromFile()==FALSE) return 1;
   if (!Option_CID) {
      printf("ok\n");
   }

   if (!Option_CID) {
      printf(" - Loading MBR from harddisc...");
   }
   if (HarddriveCheckGeometry()) {
      // No EZ-SETUP check here, because we are under 32-bit OS and this
      //  wouldn't make any sense
      if (!Track0Load()) {
         if (!Option_CID) {
            printf("LOAD ERROR!\n");
         }
         return 1;
       }
    } else {
      StatusCode = STATUS_IMPOSSIBLE;
      if (!Option_CID) {
         ImpossibleCause = "unable to install\n   Your harddisc does not have at least 63 sectors per track.";
      }
    }
   if (!Option_CID) {
      printf("ok\n");
   }


   if (!Option_CID) {
      printf("\n-> ...Current Status... <-\n");
   }
   Status_CheckCode();
   if (!Option_CID) {
      printf(" - AiR-BOOT is ");
   }
   Status_PrintF(Status_Code, Installed_CodeVersion);
   if (StatusCode==STATUS_IMPOSSIBLE) return 1;
   Status_CheckConfig();
   if (!Option_CID) {
      printf(" - Configuration is ");
   }
   Status_PrintF(Status_Config, Installed_ConfigVersion);
   // Display language as well, if code installed
   if ((Status_Code==STATUS_INSTALLED) || (Status_Code==STATUS_INSTALLEDMGU)) {
      if (!Option_CID) {
         printf(" - Language is ");
      }
      Language_PrintF(Installed_LanguageID);
      if (!Option_CID) {
         printf("\n");
      }
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

   //printf("DEBUG: Status_Code: %d, Status_Config: %d\n", Status_Code, Status_Config);  // Rousseau: DEBUG

   if ((Status_Code==STATUS_NOTINSTALLED) & (Status_Config==STATUS_NOTINSTALLED)) {
      // Nothing installed, so check MBR, if squashed...
      if (!Virus_CheckCurrentMBR()) {
         if (!Option_CID) {
            printf("\n\n");
            printf("AiR-BOOT detected that the data on your harddisc got damaged.\n");
            printf("If you had AiR-BOOT installed before: the corruption killed AiR-BOOT completly!\n");
            printf("Installation halted.\n");
         }
         return 255; // Rousseau: changed from 1 to 255
       }
       //printf("DEBUG: Installing...\n");                                               // Rousseau: DEBUG
    } else {
      if ((Status_Code==STATUS_NOTINSTALLED) | (!Virus_CheckCurrentMBR())) {
         // Code not installed, but Config or MBR squashed...
         //  -> Virus proposed, check for backup (if available)
         if (!Option_CID) {
            printf("\n\n");
            printf("-> ...!ATTENTION!... <-\n");
         }
         if (Virus_CheckForStealth())
            if (!Option_CID) {
               printf("Your system GOT infected by a stealth-virus (or your MBR got trashed).\n");
            }
           else
            if (!Option_CID) {
               printf("Probably your system was infected by a virus.\n");
               printf("Repairing AiR-BOOT will normally squash the virus.\n");
               printf("But to be sure it's gone, you should check your harddisc using a virus-scanner.\n");
            }
         if (!Virus_CheckCurrentMBR()) {
            // MBR squashed, so check backup and display message
            if (!Option_CID) {
               printf("\n");
               printf("AiR-BOOT detected that the virus has broken your partition-table.\n");
            }
            if (Virus_CheckForBackUpMBR()) {
               if (!Option_CID) {
                  printf("Good news: AiR-BOOT has found a (hopefully) functional backup.\n");
                  printf("Shall I use this backup, instead of the current active one? (Y/N)\n");
               }
               // User selection, Y/N, if he wants to restore MBR
               //  *NOT* CID (silent) able
               do {
                  UserKey = getch() | 0x20;
                } while (!((UserKey=='y') | (UserKey=='n')));
               if (UserKey=='y')
                  Virus_CopyBackUpMBR();
             } else {
                if (!Option_CID) {
                  printf("Sadly the virus also broke AiR-BOOT's backup. You will have to help yourself.\n");
               }
             }
          }
       }
    }

   // =============================================================
   //  MAIN-MENU
   // =============================================================
   if (!Option_CID) {
      printf("\n-> ...Please press... <-\n");
   }

   if (!Option_CID) {
      if (Install_IsCorrupt) printf(" <R> - Repair AiR-BOOT ");
       else if (Status_Code==STATUS_NOTINSTALLED) printf(" <A> - Add AiR-BOOT ");
       else printf(" <U> - Update/Change AiR-BOOT to ");
      printf("'v%x.%1d.%1d/", Bootcode_Version>>8, (Bootcode_Version & 0x0F0)>>4, Bootcode_Version & 0x0F);
      Language_PrintF(Bootcode_LanguageID);
      printf("' on current system\n");

      printf(" <D> - Delete AiR-BOOT from current system\n");
      printf(" <Q> - Quit without any change\n");
   }

   if (Option_Silent || Option_CID) {
      // Silent operation? Always add AiR-BOOT then
      UserKey = 'a';
    } else {
      do {
         UserKey = getch() | 0x20;
       } while (!((UserKey=='a') || (UserKey=='r') || (UserKey=='u') || (UserKey=='d') || (UserKey=='q')));
    }

   if (!Option_CID) {
      printf("\n\n\n-------------------------------------------------------------------------------\n");
   }
   switch (UserKey) {
    case 'a':
    case 'r':
    case 'u': {
      if (Install_Code || Install_Config) {
         if (!Option_CID) {
            printf("Add/Repair/Update AiR-BOOT in progress...\n");
         }
         #ifdef PLATFORM_OS2
            OS2_GetBootAutoDriveLetter();
         #endif
         if (Install_Code) {
            if (!Option_CID) {
               printf(" þ Writing AiR-BOOT code...");
            }
            Install_WriteCode();
            if (!Option_CID) {
               printf("ok\n");
            }
          }
         if (Install_Config) {
            if (!Option_CID) {
               printf(" þ Writing AiR-BOOT configuration...");
            }
            Install_WriteConfig();
            if (!Option_CID) {
               printf("ok\n");
            }
          }

         if (!Track0Write()) {
            if (!Option_CID) {
               printf("SAVE ERROR!\n");
            }
            return 1;
          }
         if (!Option_CID) {
            printf("\n");
            printf("Your copy of AiR-BOOT is now fully functional.\n");
            if (!Option_Silent) {
                printf("Please hit ESC to exit AiR-BOOT installer or ENTER to reboot your system...\n");
            }
         }
         if (Option_Silent || Option_CID) {
            // Silent operation? Always reboot system (shall we do this really?)
            // No, otherwise installing from MiniLVM will reboot the system
            // which is not what the user would expect.
            //UserKey = 0x0D;
            UserKey = 0x1B;
          } else {
            do {
               UserKey = getch();             // React on ENTER or ESC
             } while (!((UserKey==0x0D) || (UserKey==0x1B)));
          }
         if (UserKey==0x0D) {              // ENTER reboots system... (if not in eCS install mode)

            /*
            // Rousseau: ## Disable Reboot when installing eComStation ##
            // In the install-environment, the MEMDRIVE env-var is defined.
            // So, only reboot if this env-var is not defined.
            */
            if (!getenv("MEMDRIVE")) {
               if (!Option_CID) {
                  printf("Now rebooting system...\n");
               }
               RebootSystem();
            }
            ExitOnly = TRUE;
          }
       } else {
         if (!Option_CID) {
            printf(" þ All components of AiR-BOOT are intact and up-to-date. Nothing to do.\n");
         }
         ExitOnly = TRUE;
        }
       break;
     }
    case 'd': {
      if (!Option_CID) {
         printf(" þ Removing AiR-BOOT automatically is not possible at this time.\n");
      }
      #ifdef PLATFORM_OS2
         if (!Option_CID) {
            printf("    You may remove AiR-BOOT manually by entering \"FDISK /MBR\" or \"LVM /NEWMBR:1\"\n");
            printf("    in commandline.\n");
         }
      #endif
      #ifdef PLATFORM_WINNT
         if (!Option_CID) {
            printf("    You may remove AiR-BOOT manually by entering \"FDISK /MBR\" in commandline.\n");
         }
      #endif
      ExitOnly = TRUE;
      break;
     }
    default:
     break;
    }

    if (ExitOnly) {
        if (!(Option_CID || Option_Silent)) {
            printf("\n");
            printf("Please hit ENTER to exit AiR-BOOT installer...\n");
            while (getch()!=0x0D);
        }
    }
   return 0;
 }
