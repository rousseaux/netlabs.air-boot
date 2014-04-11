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


#define     IN_FILE     "AIR-BOOT.COM"  // Target from assembly.
#define     MERGE_FILE  "MBR_PROT.BIN"  // MBR protection TSR.
#define     OUT_FILE    "AIRBOOT.BIN"   // Generated loader image.



int     main(int argc, char* argv[]) {
    FILE*   ifile   = NULL;
    FILE*   mfile   = NULL;
    FILE*   ofile   = NULL;

    ifile = fopen(IN_FILE, "rb");
    mfile = fopen(MERGE_FILE, "rb");
    ofile = fopen(OUT_FILE, "wb");


    printf("\n%s\n", welcome);

#if DEBUG_LEVEL > 0
    printf("Debug level is: %d", DEBUG_LEVEL);
#endif




    return 0L;
}

