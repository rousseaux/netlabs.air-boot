#ifdef  __cplusplus
extern  "C" {
#endif


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
                        "SETBOOT Replacement to manage the AiR-BOOT Boot Manager";


#ifdef  __cplusplus
};
#endif
