
Public iStatus_Code,                iStatus_Config
Public Installed_CodeVersion,       Installed_ConfigVersion
Public Installed_LanguageID
Public Image_CodeVersion,           Image_LanguageID
Public Image_ConfigVersion
Public Install_Code,                Install_Config
Public Install_IsCorrupt
Public Impossible_Cause

Public MBR_AiRBOOTCodeSig
Public MBR_EZSETUPCodeSig
Public MBR_CurrentSectors
Public AutoDriveLetter,             AutoDriveLetterSerial
Public AiRBOOT_ImageSectorsPtr

; -----------------------------------------------------------------------------

iStatus_Code                    dd  0    ; Status of each component
iStatus_Config                  dd  0

Installed_CodeVersion           dw  0    ; Version of each installed component
Installed_ConfigVersion         dw  0
Installed_LanguageID            db  0    ; Language ID of installed AiR-BOOT

Image_CodeVersion               dw  0    ; Version of the Code-Image contained
Image_LanguageID                db  0    ; Language ID of Code-Image contained
Image_ConfigVersion             dw  0    ; Version of the Config-Image contained

Install_Code                    dd  0    ; What installation has to be done...
Install_Config                  dd  0    ; Set to 1, if component not available
Install_IsCorrupt               dd  0    ; Is anything defect? (Add/Repair-Switch)

Impossible_Cause                dd  0    ; Offset to text-message, why Impossible Status

IFDEF Flat
   ; Realmode has each Image in a specific Segment
   AiRBOOT_ImageSectorsPtr      dd  0
   MBR_CurrentSectors           db 31744 dup (0) ; Room for current MBR

   AutoDriveLetter              db  0    ;  which drive-letter to set (80h-C:)
   AutoDriveLetterSerial        dd  0    ; to identify the partition...

   OS2_CIDmode                  dd  0
ENDIF

Status_NotInstalled            equ  0    ; No ID found
Status_Corrupt                 equ  1    ; ID found, Checksum failure
Status_Installed               equ  2    ; ID found, Checksum valid
Status_InstalledMGU            equ  3    ; ID, Checksum, may get updated
Status_Impossible              equ  4    ; Unable/Not willing to install
