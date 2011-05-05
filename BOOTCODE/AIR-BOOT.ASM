; AiR-BOOT (c) Copyright 1998-2008 M. Kiewitz
;
; This file is part of AiR-BOOT
;
; AiR-BOOT is free software: you can redistribute it and/or modify it under
;  the terms of the GNU General Public License as published by the Free
;  Software Foundation, either version 3 of the License, or (at your option)
;  any later version.
;
; AiR-BOOT is distributed in the hope that it will be useful, but WITHOUT ANY
;  WARRANTY: without even the implied warranty of MERCHANTABILITY or FITNESS
;  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
;  details.
;
; You should have received a copy of the GNU General Public License along with
;  AiR-BOOT. If not, see <http://www.gnu.org/licenses/>.
;

;---------------------------------------------------------------------------
;                                                      AiR-BOOT / MAIN-CODE
;---------------------------------------------------------------------------
; 

; If ReleaseCode is not defined, it will produce debug-able code...
ReleaseCode                 equ    -1

JUMPS

; All Special Equs for this project

IFDEF ReleaseCode
   StartBaseSeg             equ     00000h
   StartBasePtr             equ     07C00h ; BIOS starts our MBR at 0:7C00
  ELSE
   StartBaseSeg             equ     03A98h ; Adjust to DOS segment
   StartBasePtr             equ     00100h
ENDIF
BootBaseSeg                 equ      8000h
BootBasePtr                 equ         0h ; We put our MBR to this location
BootBaseExec                equ BootBasePtr+offset MBR_RealStart
StackSeg                    equ      7000h

VideoIO_Page0               equ     0B800h
VideoIO_Page1               equ     0B900h
VideoIO_Page2               equ     0BA00h
VideoIO_Page4               equ     0BC00h
VideoIO_FXSegment           equ     0A000h

Include ..\INCLUDE\asm.inc
;Include ..\INCLUDE\DOS\airboot.inc

TextChar_WinLineRight       equ       0C4h ; 'Ä'
TextChar_WinLineDown        equ       0B3h ; '³'
TextChar_WinRep1            equ       0D1h ; 'Ñ'
TextChar_WinRep2            equ       0C5h ; 'Å'
TextChar_WinRep3            equ       0CFh ; 'Ï'
TextChar_WinRep4            equ       0B5h ; 'µ'
TextChar_WinRep5            equ       0C6h ; 'Æ'
TextChar_WinRep6            equ       0D8h ; 'Ø'

; Offsets for Partition-Entries in MBR/EPRs
LocBRPT_LenOfEntry          equ         16
LocBRPT_Flags               equ          0
LocBRPT_BeginCHS            equ          1
LocBRPT_BeginHead           equ          1
LocBRPT_BeginSector         equ          2
LocBRPT_BeginCylinder       equ          3
LocBRPT_SystemID            equ          4
LocBRPT_EndCHS              equ          5
LocBRPT_EndHead             equ          5
LocBRPT_EndSector           equ          6
LocBRPT_EndCylinder         equ          7
LocBRPT_RelativeBegin       equ          8
LocBRPT_AbsoluteLength      equ         12

LocBR_Magic                 equ        510

; Offsets for LVM Information Sector
LocLVM_SignatureStart       equ          0
LocLVM_SignatureByte0       equ          2
LocLVM_CRC                  equ          8  ; CRC is a DWORD
LocLVM_MaxEntries           equ          4
LocLVM_StartOfEntries       equ         60  ; (contains maximum of 4 entries)
LocLVM_LenOfEntry           equ         60
LocLVM_VolumeID             equ          0  ; is DWORD
LocLVM_PartitionID          equ          4  ; is DWORD
LocLVM_PartitionSize        equ          8  ; is DWORD
LocLVM_PartitionStart       equ         12  ; is DWORD
LocLVM_VolumeLetter         equ         18  ; is BYTE (Letter C-Z or 0)
LocLVM_VolumeName           equ         20  ; 20 bytes
LocLVM_PartitionName        equ         40  ; 20 bytes

; Offsets for IPT (Internal Partition Table)
LocIPT_MaxPartitions        equ         30  ; Maximum LocIPT_MaxPartitions
LocIPT_LenOfSizeElement     equ          6  ; Size of one Size-Element
LocIPT_LenOfIPT             equ         34
LocIPT_Serial               equ          0
LocIPT_Name                 equ          4
LocIPT_Drive                equ         15  ; Drive-ID
LocIPT_SystemID             equ         16  ; Partition-Type
LocIPT_Flags                equ         17  ; AiR-BOOT Flags for partition
LocIPT_BootRecordCRC        equ         18  ; CRC of Boot-Record
LocIPT_LocationBegin        equ         20  ; Begin of Partition
LocIPT_LocationPartTable    equ         23  ; PartitionTable of Partition
LocIPT_AbsoluteBegin        equ         26  ; Absolute Sector of Begin
LocIPT_AbsolutePartTable    equ         30  ; Absolute Sector of PartTable

LocIPT_DefaultFlags         equ   00000011b ; Don't know if boot-able :)
LocIPT_DefaultNonBootFlags  equ   00000010b ; ...VIBR Detection is always on

Flags_BootAble              equ   00000001b
Flags_VIBR_Detection        equ   00000010b
Flags_HideFeature           equ   00000100b
Flags_DriveLetter           equ   00001000b ; OS/2 FAT16/HPFS only
Flags_ExtPartMShack         equ   00010000b ; Extended Partition M$-Hack req ?
Flags_NoPartName            equ   01000000b
Flags_NowFound              equ   10000000b ; temp only in OldPartTable
Flags_SpecialMarker         equ   10000000b ; temp only for HiddenSetup

FileSysFlags_BootAble       equ   00000001b ; Is this Partition boot-able ?
FileSysFlags_FAT32          equ   00010000b ; FAT 32 specific name getting
FileSysFlags_NoName         equ   00100000b ; No Name - use PartitionName
FileSysFlags_DriveLetter    equ   01000000b ; DriveLetter Feature possible

Keys_Up                     equ         48h
Keys_Down                   equ         50h
Keys_Left                   equ         4Bh
Keys_Right                  equ         4Dh
Keys_PageUp                 equ         49h
Keys_PageDown               equ         51h
Keys_GrayPlus               equ         4Eh
Keys_GrayMinus              equ         4Ah
Keys_Plus                   equ         1Bh
Keys_Minus                  equ         35h
Keys_Enter                  equ         1Ch
Keys_ESC                    equ          1h
Keys_F1                     equ         3Bh
Keys_F10                    equ         44h
Keys_C                      equ         2Eh ; Add. Check auf Ctrl!
Keys_Y                      equ         2Ch
Keys_Z                      equ         15h
Keys_N                      equ         31h
Keys_TAB                    equ         0Fh
Keys_Delete                 equ         53h
Keys_Backspace              equ         0Eh
Keys_Space                  equ         20h

Keys_Flags_EnterSetup       equ       1100b ; Strg+Alt (AL)

		.386p
                model large, basic

code_seg        segment public use16
                assume  cs:code_seg, ds:code_seg, es:nothing, ss:nothing

                            org 00000h                          ; Sector 1
;---------------------------------------------------------------------------
AiR_BOOT:     cli                        ; Some M$ operating systems need a CLI
                                         ;  here otherwise they will go beserk
                                         ;  and will do funny things during
                                         ;  boot phase, it's laughable!
              db      0EBh               ; JMP-Short -> MBR_Start
              db      'AiRBOOT', 13h, 03h, 20h, 06h, 01h, 06h, TXT_LanguageID
              ; ID String, Date and Version Number, U for US version
              db      1                  ; Total Sectors Count,
                                         ;  Will get overwritten by FIXBSET.exe
MBR_CheckCode dw      0                  ; Check-Sum for Code

MBR_Start:    sti                        ;    This opcode is dedicated to:
              cld                        ;    =MICROSOFT JUMP DEPARTMENT=
              mov     ax, StartBaseSeg
              mov     ds, ax
              mov     si, StartBasePtr
              mov     ax, BootBaseSeg
              mov     es, ax
              mov     di, BootBasePtr
              IFDEF ReleaseCode
                 mov     cx, 256
                ELSE
                 mov     cx, 32700
              ENDIF
              rep     movsw
              db      0EAh
              dw      BootBaseExec
              dw      BootBaseSeg
              ; jmp     far ptr BootBaseSeg:BootBaseExec

MBR_HaltSystem:
              mov     ax, 8600h
              xor     cx, cx
              mov     dx, 500
              int     15h                ; Wait to display the whole screen :]
MBR_HaltSys:  cli
              jmp     MBR_HaltSys

              db      'FUCKMS:>'
              jmp     MBR_Start          ; We jump here, because I needed to
                                         ;  insert a CLI on start and did not
                                         ;  want to change AiR-BOOT detection
                                         ;  because of Microsoft inventions...

              db      'LOAD ERROR!', 0
MBR_LoadError                   Proc Near  Uses
   mov     si, offset $-12
   push    cs
   pop     ds
   call    MBR_Teletype
  MBRLE_Halt:
   jmp     MBRLE_Halt
MBR_LoadError                   EndP

              db      'SAVE ERROR!', 0
MBR_SaveError                   Proc Near  Uses
   mov     si, offset $-12
   push    cs
   pop     ds
   call    MBR_Teletype
  MBRSE_Halt:
   jmp     MBRSE_Halt
MBR_SaveError                   EndP

;        In: SI - Pointer to begin of string (EOS is 0)
; Destroyed: SI
MBR_Teletype                    Proc Near   Uses ax bx cx
   mov     ah, 0Eh
   mov     bx, 7
  MBRT_Loop:
   lodsb
   or      al, al
   jz      MBRT_End
   int     10h
   jmp     MBRT_Loop
  MBRT_End:
   ret
MBR_Teletype                    EndP

;        In: BX - Base Check, DS:SI - Pointer to 512-byte-area to be included
;       Out: BX - Base Check Result
; Destroyed: SI will get updated (+512)
MBR_GetCheckOfSector            Proc Near   Uses ax cx
   mov    cx, 256
  MBRGCOS_Loop:
       lodsw
       xor    ax, 0BABEh
       xor    bx, ax
   loop   MBRGCOS_Loop
   or     bx, bx
   jnz    MBRGCOS_NoFixUp
   mov    bx, 1                          ; dont allow 0, cause 0 == empty
  MBRGCOS_NoFixUp:
   ret
MBR_GetCheckOfSector            EndP

;---------------------------------------------------------------------------
MBR_RealStart:
              mov     ax, StackSeg
              mov     ss, ax
              mov     sp, 7FFFh
              mov     ax, es
              mov     ds, ax             ; Set DS==ES to Code Segment
              IFNDEF ReleaseCode
                 jmp     AiR_BOOT_Start
              ENDIF
              ; Load missing parts from harddrive...
              mov     ax, cs
              mov     es, ax
              mov     bx, offset Configuration
              mov     dx, 0080h          ; First harddrive, Sector 55
              mov     cx, 0037h
              mov     ax, 0205h          ; Read 5 sectors
              int     13h
              jnc     MBR_ConfigCopy_NoError
             MBR_ConfigCopy_LoadError:
              call    MBR_LoadError      ; Will Abort BootUp
             MBR_ConfigCopy_NoError:
              mov     bx, offset FurtherMoreLoad
              mov     dx, 0080h          ; First harddrive, Sector 2
              mov     cx, 0002h
              mov     ah, 02h
              mov     al, ds:[10h]
              int     13h
              jnc     MBR_RealStart_NoError
              jmp     MBR_ConfigCopy_LoadError
              ; [v1.05+]
              ; Signature for IBM's LVM to detect our "powerful" features ;)
              db      'I13X'
             MBR_RealStart_NoError:
              ; Now Check Code with CheckSum
              mov     si, offset FurtherMoreLoad
              movzx   cx, bptr ds:[10h]
              xor     bx, bx
             MBR_RealStart_CheckCodeLoop:
                 call    MBR_GetCheckOfSector
              loop    MBR_RealStart_CheckCodeLoop
              cmp     MBR_CheckCode, bx
              je      MBR_RealStart_CheckSuccess
              mov     si, offset TXT_ERROR_Attention
              call    MBR_Teletype
              mov     si, offset TXT_ERROR_CheckCode
              call    MBR_Teletype
              mov     si, offset TXT_ERROR_CheckFailed
              call    MBR_Teletype
              jmp     MBR_HaltSystem
             MBR_RealStart_CheckSuccess:
              jmp     AiR_BOOT_Start

;---------------------------------------------------------------------------
   Include TEXT\TXTMBR.asm               ; All translateable Text in MBR
;---------------------------------------------------------------------------
                            org 00200h                          ; Sector 2
; Everything beyond this point is loaded on startup and is NOT existant at first
FurtherMoreLoad:
                        ; first Normal-Partition-ID, Hidden-Partition-ID
                        ;  and Default-Partition-Flags.
                        ; 01h -> Boot-Able
                        ; 10h -> FAT32 - Name Getting Scheme
                        ; 20h -> No Name To Get (use Partition Name)
                        ; 40h -> 'L' flag possible
                db      'AiRSYS-TABLE'
FileSysIDs:     db      01h, 11h,01h, 04h,014h,01h, 06h,016h,41h, 0Eh,00Eh,01h
                db      07h, 17h,41h, 08h,017h,21h, 35h,035h,20h,0FCh,017h,41h
                db      09h, 19h,11h, 0Bh,01Bh,11h, 0Ch,01Ch,11h,0EBh,0EBh,01h
                db      63h, 63h,21h, 81h,081h,21h, 83h,083h,21h, 40h,040h,21h
                db     0A5h,0A5h,21h,0A6h,0A6h,21h, 82h,082h,20h,0A7h,0A7h,21h
                db      63h, 63h,21h, 4Dh,04Dh,21h, 4Eh,04Eh,21h, 4Fh,04Fh,21h
                db      01h, 01h,01h, 01h,001h,01h, 01h,001h,01h, 01h,001h,01h
                db      01h, 01h,01h, 01h,001h,01h, 01h,001h,01h, 01h,001h,01h
                db      01h, 01h,01h, 01h,001h,01h, 01h,001h,01h, 01h,001h,01h
                db      01h, 01h,01h,0FDh,0FDh,20h, 84h,084h,20h,0A0h,0A0h,20h
                db      0Ah, 0Ah,20h,0FEh,0FEh,21h,0FFh,0FFh,21h, 00h,000h,21h
                db      16 dup (0)

FileSysNames:   db      'FAT12   ', 'FAT16   ', 'FAT16Big', 'FAT16Big'
                db      'HPFS    ', 'NTFS    ', 'LVM-Data', 'JFS     '
                db      'FAT32   ', 'FAT32   ', 'FAT32   ', 'BeOS    '
                db      'Unix    ', 'Minix   ', 'Linux   ', 'Venix   ' ; x row ;)
                db      'BSD/386 ', 'OpenBSD ', 'LinuxSwp', 'NeXTSTEP'
                db      'GNU HURD', 'QNX     ', 'QNX     ', 'QNX     '
                db      '        ', '        ', '        ', '        '
                db      '        ', '        ', '        ', '        '
                db      '        ', '        ', '        ', '        '
                db      '        ', 'Kernel  ', '        ', '0V-Award'
                db      'OS/2 Man', 'via BIOS', 'Floppy  ', 'Unknown '
                         ; -> 44 Partition-Types

;---------------------------------------------------------------------------
                            org 00400h                          ; Sector 3
AiR_BOOT_Start:  mov     ax, VideoIO_Page1
                 call    VideoIO_BackUpTo   ; Copy BIOS POST to Second Page
                 mov     si, offset Copyright
                 call    MBR_Teletype
                 ; Initialize Variable-Tables, Detections, etc.
                 call    PRECRAP_Main
                 call    PARTSCAN_ScanForPartitions
                MBR_Main_ReEnterSetup:
                 call    SETUP_CheckEnterSETUP
                 call    AFTERCRAP_Main

; [Linux support removed since v1.02]
;                 ; Now get FAT16-Linux Kernel Partition, If requested
;                 cmp     [CFG_LinuxKrnlPartition], 0FFh
;                 je      MBR_Main_NoLinuxKrnlPartition
;                 call    LINUX_InitFAT16access
;                MBR_Main_NoLinuxKrnlPartition:

                 ; SetUp PartitionPointers for BootMenu (filter non-bootable)
                 call    PART_CalculateMenuPartPointers

                 ; ...and count that one...
                 cmp     PartitionPointerCount, 0
                 jne     MBR_Main_SomethingBootAble
                 mov     si, offset TXT_NoBootAble
                 call    MBR_Teletype
                 jmp     MBR_HaltSystem
                
                MBR_Main_SomethingBootAble:
                 ; FixUp Values, define Timed Setup booting, etc.
                 call    PART_FixUpDefaultPartitionValues

                 ; -------------------------------------------------- BOOT-MENU
                MBR_Main_ReEnterBootMenu:
                 call    BOOTMENU_ResetMenuVars ; reset has to be done
                 test    CFG_AutomaticBoot, 1
                 jz      MBR_Main_NoAutomaticBooting
                 ; ------------------------------------------ AUTOMATIC BOOTING
                 ; Select automatic partition, disable automatic booting for
                 ;  next time and boot system...
                 mov     CFG_AutomaticBoot, 0
                 call    PASSWORD_AskSystemPwd
                 mov     al, Menu_EntryAutomatic
                 mov     Menu_EntrySelected, al
                 jmp     MBR_Main_NoBootMenu

                MBR_Main_NoAutomaticBooting:
                 test    CFG_BootMenuActive, 0FFh
                 jnz     MBR_Main_GotBootMenu
                 ; ----------------------------------------------- NO BOOT-MENU
                 ; Select default partition and boot system...
                 call    PASSWORD_AskSystemPwd
                 mov     al, Menu_EntryDefault
                 mov     Menu_EntrySelected, al
                 jmp     MBR_Main_NoBootMenu

                MBR_Main_GotBootMenu:
                 ; ------------------------------------------ BOOT-MENU VISUALS
                 call    FX_StartScreen
                 call    BOOTMENU_BuildBackground
                 call    BOOTMENU_BuildMain
                 call    FX_EndScreenRight
                 call    PASSWORD_AskSystemPwd
                 call    BOOTMENU_ResetTimedBoot
                 call    BOOTMENU_Execute
                 jc      MBR_Main_ReEnterSetup
                 call    BOOTMENU_SetVarsAfterMenu
                 ; ------------------------------------------------- BOOTING...
                MBR_Main_NoBootMenu:
                 call    FX_StartScreen
                 call    BOOTMENU_BuildGoodBye
                 call    FX_EndScreenRight
                 call    PASSWORD_AskChangeBootPwd

                 IFNDEF ReleaseCode
                    ; Debug Code to terminate DOS .COM program - used for
                    ;  testing AiR-BOOT
                    int 3
                    mov     ax, 6200h
                    int     21h
                    mov     es, bx
                    mov     ax, 4C00h    ; Quit program
                    int     21h
                 ENDIF
                 call    ANTIVIR_SaveBackUpMBR
                 mov     dl, Menu_EntrySelected
                 call    PART_StartPartition

Include REGULAR\STD_TEXT.asm             ; Standard (non-translateable text)
Include REGULAR\DRIVEIO.asm              ; Drive I/O, Config Load/Save
Include REGULAR\ViDEOIO.asm              ; Video I/O
Include REGULAR\TIMER.asm                ; Timer
Include REGULAR\PARTMAIN.asm             ; Regular Partition Routines
Include REGULAR\PARTSCAN.asm             ; Partition Scanning
Include REGULAR\BOOTMENU.asm             ; Boot-Menu
Include REGULAR\PASSWORD.asm             ; Password related
Include REGULAR\OTHER.asm                ; Other Routines

Include SETUP\MAiN.ASM                   ; The whole AiR-BOOT SETUP
Include SPECiAL\ViRUS.asm                ; Virus Detection / Anti-Virus
; [Linux support removed since v1.02]
;Include SPECiAL\FAT16.asm                ; FAT-16 Support
;Include SPECiAL\LINUX.asm                ; Linux Kernel Support
Include SPECiAL\F00K\BILLSUXX.asm        ; Extended Partition - Microsoft-Hack
Include SPECiAL\SOUND.asm                ; Sound
Include SPECiAL\APM.asm                  ; Power Managment Support
Include SPECiAL\FX.asm                   ; l33t Cooper-Bars/Scrolling <bg>
Include SPECiAL\LVM.asm                  ; LVM-specific code
IFDEF TXT_IncludeCyrillic
   Include SPECiAL\CHARSET.asm           ; Charset Support (e.g. Cyrillic)
ENDIF

;---------------------------------------------------------------------------
                            org 04600h                          ; Sector 36-37
MBR_Protection:              db 'AiR-BOOT MBR-Protection Image'
; Hardcoded to 1k (1024 bytes)

;---------------------------------------------------------------------------
                            org 04A00h                          ; Sector 38-x
Include TEXT\TXTOTHER.asm                ; All translateable Text-Strings
Include TEXT\TXTMENUS.asm                ; All translateable Menu-text
Include TEXT\CHARSET.asm                 ; Special Video Charsets (if needed)

;---------------------------------------------------------------------------
                            org 06C00h                          ; Sector 55
Configuration:
                             db 'AiRCFG-TABLE­'
                             db 01h, 02h, 'U' ; "Compressed" ID String
                             ; This is still version 1.02, because nothing got
                             ;  changed...

CFG_LastTimeEditLow          dw     0    ; Last Time Edited Stamp (will incr every setup)
CFG_LastTimeEditHi           dw     0    ; second 16 bit part...

CFG_CheckConfig              dw     0    ; Check-Sum for Configuration

CFG_Partitions               db     0    ; Count of partitions in IPT
                             db     0    ; Was BootParts - Removed since v0.28b
CFG_PartDefault              db     0    ; Default-Partition (Base=0)

CFG_PartLast                 db     0    ; Which Partition was booted last time ? (Base=0)
CFG_TimedBoot                db     1    ; Timed Boot Enable (for REAL Enable look TimedBootEnable)
CFG_TimedSecs                db    15    ; Timed Boot - How Many Seconds Till Boot
CFG_TimedDelay               dw   123    ; Timed Boot - Delay
CFG_TimedBootLast            db     0    ; Timed Boot - Boot From Last Drive Booted From
CFG_RememberBoot             db     1    ; Remember Manual Boot Choice
CFG_RememberTimed            db     0    ; Remember if Timed Boot (if both disabled: Boot Default)
CFG_IncludeFloppy            db     1    ; Include Floppy Drives in Boot-Menu
CFG_BootMenuActive           db     1    ; Display Boot-Menu (if Disabled: Boot Default)
                                         ; v0.29+ -> 2 - Detailed Bootmenu
CFG_PartitionsDetect         db     1    ; Autodetect New Partitions (Auto-Add!)
CFG_PasswordSetup            db     0    ; Ask Password when entering Setup
CFG_PasswordSystem           db     0    ; Ask Password when booting System
CFG_PasswordChangeBoot       db     0    ; Ask Password when changing boot partition
CFG_ProtectMBR               db     0    ; Protect MBR via TSR ?
CFG_IgnoreWriteToMBR         db     0    ; Just ignore writes to MBR, otherwise crash
CFG_FloppyBootGetName        db     0    ; Gets floppy name for display purposes
CFG_DetectVirus              db     1    ; Detect Virus ?
CFG_DetectStealth            db     1    ; Detect Stealth-Virus ?
CFG_DetectVIBR               db     1    ; Detect BootRecord-Virus ?
CFG_AutoEnterSetup           db     1    ; Automatic Enter Setup (first install!)
CFG_MasterPassword           dw 0101Fh   ; Encoded Password (this is just CR)
                             dw 07A53h
                             dw 0E797h
                             dw 0A896h
CFG_BootPassword             dw 0101Fh   ; Another CR... ;-)
                             dw 07A53h
                             dw 0E797h
                             dw 0A896h
                             db     0    ; Rude-Protection - Removed since v0.28b
CFG_LinuxRootPartition       db     0    ; Linux Root Partition (Base=0)
CFG_TimedKeyHandling         db     0    ; Timed Key Handling (for Timed Boot)
                                         ; 0 - Do Nothing
                                         ; 1 - Reset Time
                                         ; 2 - Stop Time
CFG_MakeSound                db     0    ; Should be clear ;)
CFG_FloppyBootGetTimer       db     0    ; Floppy Name will get updated every 2 secs
CFG_ResumeBIOSbootSeq        db     0    ; If BIOS Boot Sequence should be resumed
                                         ; 0 - Disabled
                                         ; 1 - CD-ROM
                                         ; 2 - Network
                                         ; 3 - ZIP/LS120
CFG_CooperBars               db     0    ; If Cooper Bars should be shown
CFG_LinuxCommandLine         db    75 dup (0) ; Linux Command Line
CFG_LinuxKrnlPartition       db   0FFh   ; FAT-16 Linux Kernel Partition (Base=0)
                                         ;  FFh -> Disabled
CFG_LinuxDefaultKernel       db 'DEFAULT', 4 dup (32), 0 ; Default Kernel Name
CFG_LinuxLastKernel          db    11 dup (32), 0 ; Last-Booted Kernel Name
CFG_ExtPartitionMShack       db     0    ; Extended Partition M$-Hack Global Enable
CFG_AutomaticBoot            db     0    ; Automatic Booting (only one bootup)
CFG_PartAutomatic            db     0    ; Partition-No for automatic booting
CFG_ForceLBAUsage            db     0    ; LBA-BIOS-API forced on any HDD I/O
CFG_IgnoreLVM                db     0    ; Ignores any LVM-Information

; VIR variables are for the AiR-BOOT Anti Virus Code
; Most of them are backups of Interrupt Points, so we can check, if a
; stealth virus is on-line, we can intercept its call.
; Normal (non stealth) virus are trapped simply by rereading the MBR sector.
; If a virus is found, we will restore MBR from Sektor 60 and stop the system
; from working, so the user has to press reset. That's saver than a Reboot.
;
; If a virus is found on the partition to boot, the system will ONLY halt,
; nothing more, because we can not remove it. The user shall do it :)
; Those viruses are detected via a real nasty method...Checksum-Checking of the
; boot-record, which is to be executed. If it does not match the one in our
; internal partition table, we will stop. You may however switch this detection
; off or just reset it by switching 'VIBR Detection'.

                            org 06DABh                          ; 427 Boundry
AutoDrvLetter                db     0
AutoDrvLetterSerial          dd     0

BIOScontIPTentry:
                             db     0, 0, 0, 0, '           '
                             db     0, 0FEh, Flags_BootAble
                             dw     0     ; No Checksum :)
                             db     0, 1, 0
                             db     0, 1, 0 ; Location of Partition/Boot Record
                             dd     0, 0

                                                                ; 466 Sub-Part
CFG_VIR_INT08                dd     0    ; pointer to saved 08h entry point
CFG_VIR_INT13                dd     0    ; pointer to saved 13h entry point
CFG_VIR_INT1C                dd     0    ; pointer to saved 1Ch entry point

                                                                ; 478 Boundry
FloppyIPTentry:              db     0, 0, 0, 0, 'FloppyDrive'
                             db     0, 0FFh, Flags_BootAble
                             dw     0     ; No Checksum :)
                             db     0, 1, 0
                             db     0, 1, 0 ; Location of Partition/Boot Record
                             dd     0, 0
;---------------------------------------------------------------------------
                            org 06E00h                          ; Sector 56-57
PartitionTable: ; no-partitions detected... :]
;                             db    1, 0, 0, 0, 'Harddisc  1'
;                             db    0, 0FFh, Flags_BootAble
;                             dw    0    ; No Checksum :)
;                             db    0, 0, 1
;                             db    0, 0, 1  ; Location of Partition/Boot Record
;                             dd    0, 0

                ; Format is:
                ;============
                ; SerialNumber    * 4
                ; PartitionName   * 11
                ; Drive           * 1
                ; SystemID        * 1 (means the partition type)
                ; Flags           * 1
                ; Checksum        * 2 (for virus checking)
                ; LocationBegin   * 3 (where the partition begins)
                ; LocationPartTab * 3 (where the partition table is)
                ; AbsoluteBegin   * 4 (where the partition begins, in absolute sectors)
                ; AbsolutePartTab * 4 (where the partition table is, in absolute sectors)
                ; --------------------> 34 Bytes (total maximum = 30)

                            org 071F6h
                             db 'AiRBOOTPAR' ; 1K internal partition table
;---------------------------------------------------------------------------
                            org 07200h                          ; Sector 58
HidePartitionTable:          db   900 dup (0FFh)
                                         ; Format is:
                                         ;============
                                         ; PartitionPtr : BYTE * 30
                                         ; --------------------> 30 Bytes * 30

DriveLetters:                db    30 dup (0)
                                         ; Format is:
                                         ;============
                                         ; Drive-Letter : BYTE (80h-C:, 81h-D:)
                                         ; --------------------> 1 Byte * 30

                            org 075F6h
                             db 'AiRBOOTHID' ; 1K internal Hide-partition table
;---------------------------------------------------------------------------
                            org 07600h                          ; Sector 60
MBR_BackUpMBR                db 'AiR-BOOT MBR-BackUp - Just to fill this sector with something'

                            org 077FFh
                             db     0
;---------------------------------------------------------------------------
                            org 0A000h                          ; Uninitialized
; This space actually gets initialized in PreCrap to NUL (till EndOfVariables)
BeginOfVariables:
PartitionSector              db   512 dup (?) ; Temporary Sector for Partition
LVMSector:                   db   512 dup (?) ; Temporary Sector for LVM
TmpSector:                   db   512 dup (?) ; Temporary Sector
TmpSector2:
; Everything used to build a new IPT and reference it to the old one
NewPartTable:                db  1024 dup (?) ; New Partition Table
NewHidePartTable:            db   900 dup (?) ; New Hide-Partition Table
NewDriveLetters:             db    30 dup (?) ; Logical Drive-Letters

PartitionSizeTable:          db   180 dup (?) ; Size-Table (6 bytes per partition)
PartitionPointers            dw    52 dup (?) ; Maximum is 52 entries till now
PartitionPointerCount        db     ?         ; Count of total Partition Pointers
PartitionXref                db    30 dup (?) ; X-Reference Table
PartitionVolumeLetters       db    30 dup (?) ; Volume-Letters
                                              ;  0 - no LVM support
                                              ;  1 - LVM support, but no letter
                                              ;  'C'-'Z' - assigned drive letter

TotalHarddiscs               db     ?         ; Total harddrives (by POST)
LBASwitchTable               db   128 dup (?) ; Bit 25-18 for CHS/LBA Switching
NewPartitions                db     ?         ; Freshly found partitions

VideoIO_Segment              dw     ?    ; Segment for Video I/O

ExtendedAbsPos               dd     ?    ; Extended Partition Absolute Position
ExtendedAbsPosSet            db     ?    ; If Absolute Position set

CurPartition_Location        dw     4 dup (?)  ; Where did current partition came from?
CurIO_UseExtension           db     ?    ; 1-Use INT 13h EXTENSIONS
                                         ;    (filled out by PreCrap)
CurIO_Scanning               db     ?    ; 1-AiR-BOOT is scanning partitions
                                         ;    (for detailed error message)

; [Linux support removed since v1.02]
;GotLinux                     db     ?    ; 1-Linux found

Menu_EntrySelected           db     ?    ; Which partition we boot this time...
Menu_UpperPart               db     ?    ; Which number (Base=0) is the partition upper pos
Menu_AbsoluteX               db     ?    ; Pos where Menu stuff starts
Menu_TotalParts              db     ?    ; Copy of CFG_BootParts
Menu_TotalLines              db     ?    ; Total Lines on Screen used for BootMenu
Menu_EntryDefault            db     ?    ; Default Entry in filtered View
Menu_EntryLast               db     ?    ; LastBooted Entry in filtered View
Menu_EntryAutomatic          db     ?    ; Automatic Entry in filtered View
                                         ;  - All adjusted to menu locations

PartSetup_UpperPart          db     ?    ; Partition-Setup (like Menu_UpperPart)
PartSetup_ActivePart         db     ?    ; Active Partition
PartSetup_HiddenUpper        db     ?    ; (like Menu_UpperPart)
PartSetup_HiddenX            db     ?    ; Pos for Hidden-Setup
PartSetup_HiddenAdd          db     ?    ; Adjust for Hidden-Setup

TimedBootEnable              db     ?    ; Local Enable/Disable for timed boot
TimedTimeOut                 dd     ?    ; TimeOut Timer for TimedBoot (too much time here ;)
TimedSecondLeft              db     ?    ; How many seconds are left till boom ?
TimedSecondBack              db     ?    ; To get a modification noticed
TimedBootUsed                db     ?    ; Timed Boot used for bootup ?
FloppyGetNameTimer           dd     ?    ; Timer for Floppy-Get-Name
SETUP_KeysOnEntry            db     ?    ; which Shift Status was there, when booting ?
SETUP_ExitEvent              db     ?    ; Exit Event to end SETUP
TempPasswordEntry            db    17 dup (?)
SETUP_OldPwd                 db    17 dup (?)
SETUP_NewPwd                 db    17 dup (?)
SETUP_VerifyPwd              db    17 dup (?)
StartSoundPlayed             db     ?
ChangePartNameSave           db     ?

FX_UseCount                  dw     ?
FX_OverallTimer              dw     ?
FX_WideScrollerTimer         dw     ?
FX_WideScrollerCurPos        dw     ?
FX_WideScrollerSpeed         db     ?
FX_WideScrollerSpeedState    db     ?
FX_WideScrollerDirection     db     ?
FX_WideScrollerAbsDirection  db     ?
FX_WideScrollerBounceSpeed   db     ?
FX_CooperBarsTimer           dw     ?

; [Linux support removed since v1.02]
;FAT16_Drive                  db     ?    ; FAT-16: Drive of FAT16-partition
;FAT16_AbsPartitionBegin      dd     ?    ; FAT-16: LBA Begin of Partition
;FAT16_SecsPerCluster         db     ?    ; FAT-16: Sectors Per Cluster
;FAT16_NumOfRootEntries       dw     ?    ; FAT-16: Number of Root Entries
;FAT16_SecsPerFAT             dw     ?    ; FAT-16: Sectors Per FAT
;FAT16_AbsFATBegin            dd     ?    ; FAT-16: LBA Begin of FAT
;FAT16_AbsRootBegin           dd     ?    ; FAT-16: LBA Begin of Root
;FAT16_AbsClusterBegin        dd     ?    ; FAT-16: LBA Begin of Clusters
;FAT16_FATCacheSector         db     ?    ; FAT-16: FAT-Sector No in Cache
;FAT16_FATCache               db   512 dup (?) ; FAT-16: FAT-Area Cache
;
;LINUX_KernelEntries          db   680 dup (?) ; 34*20 -> Space for Kernel-Entries
;LINUX_KernelNo               db     ?         ; Total of Kernels in KernelEntries
;LINUX_KernelSizeTable        db   120 dup (?) ; Size-Table (6 bytes per kernel)
EndOfVariables:

; Dynamically Generated Tables - do not need to get initialized with NUL
FX_CooperColors              db   672 dup (?) ; 7 cooper bars*96 - runtime calculated
FX_CooperState:              db     7 dup (?)
FX_SinusPos:                 db     7 dup (?)
FX_CooperPos:                dw     7 dup (?)
CharsetTempBuffer            db  4096 dup (?) ; Uninitialized Charset buffer
LVM_CRCTable:                dd   256 dup (?) ; LVM-CRC (->SPECiAL\LVM.asm)

code_seg	ends
		end	air_boot
