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
// FIXCODE.C -- Fix the AiR-BOOT image; include the code-size and MBR prot-img.
//  This reads AIR-BOOT.COM, merges MBR-PROT.BIN and writes AIRBOOT.BIN.
//  It is a quick-and-dirty translation of the original DOS-only ASM file.
//  Of course it's not as small but it's much easier to maintain across
//  multiple platforms.
*/


#include    "FIXCODE.H"


#ifdef PLATFORM_DOS
    char    welcome[] = "FIXCODE: Hello from DOS !";
#endif

#ifdef PLATFORM_OS2
    char    welcome[] = "FIXCODE: Hello from OS/2 !";
#endif

#ifdef PLATFORM_WINNT
    char    welcome[] = "FIXCODE: Hello from Windows NT !";
#endif

#ifdef PLATFORM_LINUX
    char    welcome[] = "FIXCODE: Hello from Linux !";
#endif


/* File names */
#define     IN_FILE     "AIR-BOOT.COM"              // Target from assembly.
#ifdef      PLATFORM_LINUX
#define     MERGE_FILE  "MBR-PROT/MBR-PROT.BIN"     // MBR protection TSR.
#else
#define     MERGE_FILE  "MBR-PROT\\MBR-PROT.BIN"    // MBR protection TSR.
#endif
#define     OUT_FILE    "AIRBOOT.BIN"               // Generated loader image.


/* Copyright message */
char    Copyright[] = "AiR-BOOT Bootcode Image Fix\n"
                        " - (c) Copyright 2009-2012 by M. Kiewitz\n";
/* Progress messages */
char    LoadCode[]  = " - Loading bootcode from file...";
char    LoadMBR[]   = " - Loading MBR-protection from file...";
char    MergeMBR[]  = " - Merging MBR-protection into bootcode...";
char    CountCode[] = " - Count code in bootcode-image...";
char    WriteCode[] = " - Saving bootcode to file...";
char    Okay[]      = "ok\n";
char    Failed[]    = "failed\n";

/* Error messages */
char    FailedOpenCode[]    = IN_FILE" not found\n";
char    FailedReadCode[]    = "Read "IN_FILE" failed\n";
char    FailedInvalidCode[] = "Invalid "IN_FILE"\n";
char    FailedOpenMBR[]     = MERGE_FILE" not found\n";
char    FailedReadMBR[]     = "Read "MERGE_FILE" failed\n";
char    FailedInvalidMBR[]  = "Invalid "MERGE_FILE"\n";
char    FailedWriteCode[]   = "Write "OUT_FILE" failed\n";

/* The signature we search for in the AIR-BOOT.COM image */
char    MBRProtectionSignature[]    = "AiR-BOOT MBR-Protection Image";

/* File buffers */
char    BootCode[IMAGE_SIZE];   // Buffer for boot-image
char    MBRProtection[1024];    // Buffer for protection-image




/*
// Main Entrypoint.
*/
int     main(int argc, char* argv[]) {
    FILE*       ifile   = NULL;
    FILE*       mfile   = NULL;
    FILE*       ofile   = NULL;
    size_t      ibytes  = 0;
    size_t      mbytes  = 0;
    size_t      obytes  = 0;
    unsigned    i       = 0;
    unsigned    found   = 0;


#if DEBUG_LEVEL > 0
    printf("\n%s\n", welcome);
    printf("Debug level is: %d\n\n", DEBUG_LEVEL);
#endif

    /*
    // Show copyright message.
    */
    printf("%s",Copyright);

    /*
    // Load AIR-BOOT.COM
    */
    printf("%s",LoadCode);
    ifile = fopen(IN_FILE, "rb");
    if (!ifile) {
        printf("%s",FailedOpenCode);
        exit(1);
    }
    ibytes = fread(BootCode, 1, IMAGE_SIZE, ifile);
    if (ferror(ifile)) {
        printf("%s",FailedReadCode);
        exit(1);
    }
    //printf("ibytes: %d\n", ibytes);
    fread(BootCode, 1, 1, ifile);
    if (ibytes != IMAGE_SIZE || !feof(ifile)) {
        printf("%s", FailedInvalidCode);
        exit(1);
    }
    printf("%s", Okay);


    /*
    // Load MBR-PROT.BIN
    */
    printf("%s",LoadMBR);
    mfile = fopen(MERGE_FILE, "rb");
    if (!mfile) {
        printf("%s",FailedOpenMBR);
        exit(1);
    }
    mbytes = fread(MBRProtection, 1, MBRPROT_SIZE, mfile);
    if (ferror(mfile)) {
        printf("%s",FailedReadMBR);
        exit(1);
    }
    fread(MBRProtection, 1, 1, mfile);
    if (mbytes != MBRPROT_SIZE || !feof(mfile)) {
        printf("%s", FailedInvalidMBR);
        exit(1);
    }
    printf("%s", Okay);


    /*
    // Find Protection Image Signature.
    // Note that this signature must reside on a sector boundary.
    */
    for (i=0; i<55; i++) {
        if (!memcmp(MBRProtectionSignature, &BootCode[i*SECSIZE], strlen(MBRProtectionSignature))) {
            found = 1;
            break;
        }
    }

    /*
    // Merge Protection Image.
    */
    printf("%s",MergeMBR);
    if (!found) {
        printf("%s",Failed);
        exit(2);
    }
    memcpy(&BootCode[i*SECSIZE], MBRProtection, MBRPROT_SIZE);
    printf("%s", Okay);


    /*
    // Count Code Sectors.
    // Obsolete now since the Protection Image has moved just below the
    // Configuration and the code is always max. size.
    // Overlap checking is done while assembling AIR-BOOT.ASM.
    */
    printf("%s", CountCode);
    BootCode[16] = 53;
    printf("%s", Okay);

    /*
    // Write AIRBOOT.BIN
    */
    printf("%s", WriteCode);
    ofile = fopen(OUT_FILE, "wb");
    if (!ofile) {
        printf("%s", FailedWriteCode);
        exit(3);
    }
    obytes = fwrite(BootCode, 1, IMAGE_SIZE, ofile);
    if (obytes != IMAGE_SIZE || ferror(ofile)) {
        printf("%s", FailedWriteCode);
        exit(3);
    }
    printf("%s", Okay);


    /*
    // Close files.
    */
    if (ifile)
        fclose(ifile);
    if (mfile)
        fclose(mfile);
    if (ofile)
        fclose(ofile);


    return 0L;
}

