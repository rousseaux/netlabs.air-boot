/* CONST.asm */

/* GlobalData.asm */
extern ULONG    iStatus_Code;
extern ULONG    iStatus_Config;
extern USHORT   Installed_CodeVersion;
extern USHORT   Installed_ConfigVersion;
extern UCHAR    Installed_LanguageID;
extern USHORT   Image_CodeVersion;
extern UCHAR    Image_LanguageID;
extern USHORT   Image_ConfigVersion;
extern BOOL     Install_Code;
extern BOOL     Install_Config;
extern BOOL     Install_IsCorrupt;
extern MSGID    Impossible_Cause;
extern PUCHAR   AiRBOOT_ImageSectorsPtr;
extern UCHAR    AiRBOOT_ImageSectors[31744];
extern UCHAR    MBR_CurrentSectors[31744];
extern BOOL     OS2_CIDmode;
extern UCHAR    AutoDriveLetter;
extern ULONG    AutoDriveLetterSerial;

#define Status_NotInstalled     0        // No ID found
#define Status_Corrupt          1        // ID found, Checksum failure
#define Status_Installed        2        // ID found, Checksum valid
#define Status_InstalledMGU     3        // ID, Checksum, may get updated
#define Status_Impossible       4        // Unable/Not willing to install

/* Status.asm */
extern VOID     INST_Status_CheckImage (void);
extern VOID     INST_Status_CheckCode (void);
extern VOID     INST_Status_CheckConfig (void);
extern MSGID    INST_Status_GetLanguageName (char LanguageID);

/* Virus.asm */
extern BOOL     INST_Virus_CheckCurrentMBR (void);
extern BOOL     INST_Virus_CheckForBackUpMBR (void);
extern BOOL     INST_Virus_CheckForStealth (void);
extern VOID     INST_Virus_CopyBackUpMBR (void);

/* Proc_Add.asm */
extern VOID     INST_Add_IncludeCode(void);
extern VOID     INST_Add_IncludeConfig(void);
