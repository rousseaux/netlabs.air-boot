#ifndef     __FIXCODE_H__
#define     __FIXCODE_H__

/*
// Include the version information for BLDLEVEL.
// This information is common to all built executables.
*/
#include "../../include/version.h"

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
                        "Image Embedder for the AiR-BOOT Boot Manager";

#if defined(__DOS__)
    #define PLATFORM_DOS
#elif defined(__OS2__) && !defined(OS2)
    #define PLATFORM_OS2
#elif defined(__NT__)
    #define PLATFORM_WINNT
#elif defined(__LINUX__)
    #define PLATFORM_LINUX
#else
    #error Unsupported platform
#endif


#include    <stdlib.h>
#include    <stdio.h>
#include    <string.h>


#define     IMAGE_SIZE      31744
//~ #define     MBRPROT_SIZE    1024
#define     MBRPROT_SIZE    768
#define     SECSIZE         512
#define     PAGESIZE        256

#endif
