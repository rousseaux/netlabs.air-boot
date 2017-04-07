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


/*
// OS/2 BLDLEVEL Information.
*/
// Vendor
//~ #define     BLDLVL_VENDOR           "KIEWITZ"
//~ #define     BLDLVL_VENDOR           "RDPe"
#define     BLDLVL_VENDOR           "*UNKNOWN*"
// Version
#define     BLDLVL_MAJOR_VERSION    "1"
#define     BLDLVL_MIDDLE_VERSION   "1"
#define     BLDLVL_MINOR_VERSION    "1"
// Build date
#define     BLDLVL_YEAR             "2017"
#define     BLDLVL_MONTH            "03"
#define     BLDLVL_DAY              "15"
// Build time
//~ #define     BLDLVL_HOURS            "01"
//~ #define     BLDLVL_MINUTES          "01"
//~ #define     BLDLVL_SECONDS          "00"
#define     BLDLVL_HOURS            "23"
#define     BLDLVL_MINUTES          "59"
#define     BLDLVL_SECONDS          "59"
// Build machine
//~ #define     BLDLVL_MACHINE          "OS2BLDBOX"
#define     BLDLVL_MACHINE          "*UNKNOWN*"
// Build language
#define     BLDLVL_LANGUAGE         "EN"

//char    bldlevel[] = "@#KIEWITZ:1.0.8#@##1## 2011/01/17 21:10:00      ecs-devbox:ASD123:L:C:8::99@@  Adapter Driver for PATA/SATA DASD";
char    bldlevel[]  =   "@#"\
                        BLDLVL_VENDOR":"\
                        BLDLVL_MAJOR_VERSION"."\
                        BLDLVL_MIDDLE_VERSION"."\
                        BLDLVL_MINOR_VERSION"#@##1## "\
                        BLDLVL_YEAR"/"\
                        BLDLVL_MONTH"/"\
                        BLDLVL_DAY" "\
                        BLDLVL_HOURS":"\
                        BLDLVL_MINUTES":"\
                        BLDLVL_SECONDS"      "\
                        BLDLVL_MACHINE"::"\
                        BLDLVL_LANGUAGE"::"\
                        BLDLVL_MINOR_VERSION"::@@"\
                        "Installer for the AiR-BOOT Boot Manager";


/*
// Platform dependent defines and includes.
*/
#if defined(__DOS__)
    // DOS platform
    #define PLATFORM_DOS
    #define PLATFORM_NAME   "DOS"
    // We use the OS/2 v1.x definitions like CHAR etc.
    #include    <os2def.h>
#elif defined(__OS2__) && !defined(OS2)
    // OS/2 platform
    #define     PLATFORM_OS2
    #define     PLATFORM_NAME   "OS/2"
    #define     INCL_NOPMAPI
    #define     INCL_BASE
    #define     INCL_DOS
    #define     INCL_DOSDEVIOCTL
    #include    <os2.h>
    #include    <malloc.h>
#elif defined(__NT__)
    // Win32 platform
    #define     PLATFORM_WINNT
    #define     PLATFORM_NAME   "Windows NT/2K/XP/Vista/7"
    #include    <windows.h>

#elif defined(__LINUX__)
    // Linux platform
    #define     PLATFORM_LINUX
    #define     PLATFORM_NAME   "Linux"
    // We use the OS/2 v2.x definitions like CHAR etc.
    #include    <os2def.h>
#else
    #error Unsupported platform
#endif


/*
// Standard header files.
*/
#include    <stdlib.h>
#include    <ctype.h>
#include    <stdio.h>
#include    <conio.h>
#include    <string.h>
#include    <i86.h>


#define     STATUS_NOTINSTALLED     0 // No ID found
#define     STATUS_CORRUPT          1 // ID found, Checksum failure
#define     STATUS_INSTALLED        2 // ID found, Checksum valid
#define     STATUS_INSTALLEDMGU     3 // ID found, Checksum valid, may get updated
#define     STATUS_IMPOSSIBLE       4 // Unable/Not willing to install

/* Rousseau: added */
#define     IMAGE_NAME              "airboot.bin"
#define     GPT                     0xEE                                // GPT Disk, AiR-BOOT will abort
#define     BYTES_PER_SECTOR        512                                 // This could be higher in the future
#define     IMAGE_SIZE_60SECS       30720                               // Normal image-size    (max. 30 partitions)
#define     IMAGE_SIZE_62SECS       31744                               // Extended image-size  (max. 45 partitions)
//#define     IMAGE_SIZE              IMAGE_SIZE_60SECS                   // Use the normal image
#define     IMAGE_SIZE              IMAGE_SIZE_62SECS                   // Use the extended image
#define     SECTOR_COUNT            IMAGE_SIZE / BYTES_PER_SECTOR       // Size of the image in sectors
#define     CONFIG_OFFSET           0x6C00                              // Byte offset of config-sector
#define     SECTORS_BEFORE_CONFIG   CONFIG_OFFSET / BYTES_PER_SECTOR    // Nr of sectors before config-sector
