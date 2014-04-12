;
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


;------------------------------------------------------------------------------
;                                                       AiR-BOOT / DEFINITIONS
;------------------------------------------------------------------------------
;

;
; Include AiR-BOOT Version Information.
;
Include VERSION.INC

;
; Include OS/2 BLDLEVEL Information.
;
Include BLDLEVEL.INC


; -------------------------
; Rousseau: JUMPS disabled
; -------------------------
; We actually don't want to use this directive because it generates extra
; NOP instructions that we can do without.
; Relative conditional jumps that are out-of-range are manually reworked by
; skipping an unconditional jump to the target on base of complementary
; condition logic and temporary labels.
; TASM also has a bug in that when the .ERR2 directive is used when
; the .386 directive is in effect, the JUMPS directive is also active
; and cannot be turned off.
; NOJUMPS seems to have no effect in this situation.
; In this case 4 NOP instructions are generated after forward referencing jump
; instructions, to allow for automatic recoding by TASM.
; This seems to be a TASM bug. (v2,v3,v4, dunno v5)
IFDEF   TASM
    ;~ JUMPS
ENDIF

;
; If defined then each module is prefixed with it's name.
; This is used for debugging purposes.
; It should be off in release code.
;
;ModuleNames             equ     1


;
; The first harddisk is BIOS coded 80h.
; This makes a total of 128 disk could be supported using this coding.
; This value is used to store disk-information and this info is allocated
; in the BSS.
;
MaxDisks                equ     64




;
; Include Debug Modules and enable COM-port debugging.
;
;~ AUX_DEBUG       EQU





;
; bits 7-5 = datarate
;  (000=110,001=150,010=300,011=600,100=1200,101=2400,110=4800,111=9600 bps)
; bits 4-3 = parity
;  (00 or 10 = none, 01 = odd, 11 = even)
; bit  2   = stop-bits
;  (set = 2 stop-bits, clear = 1 stop-bit)
; bits 1-0 = data-bits
;  (00 = 5, 01 = 6, 10 = 7, 11 = 8)
;

; 9600 bps, no parity, 1 stop-bit, 8 bits per char
AUX_INIT_PARMS          EQU     11100011b

; Com-port for debugging, 0 is disabled
BIOS_COM_PORT           EQU     1

; Default word value for BIOS_AuxParms variable
; Note that is has moved since v1.07
BIOS_AUXPARMS_DEFAULT   EQU     (AUX_INIT_PARMS SHL 8) OR BIOS_COM_PORT




;
; If ReleaseCode is not defined, it will produce debug-able code...
;
ReleaseCode             equ     -1


;
; All Special Equ's for this project
;

; Use different addresses depending on whether in pre-boot
; or debug (dos) environment.
IFDEF ReleaseCode
    StartBaseSeg    equ     00000h  ; Pre-boot, we are in low memory
    StartBasePtr    equ     07C00h  ; BIOS starts our MBR at 0:7C00
ELSE
    ; Rousseau: where does this value come from ?
    ; Should be CS.
    ; Rectified in actual code by ignoring this value.
    StartBaseSeg    equ     03A98h  ; Adjust to DOS segment
    StartBasePtr    equ     00100h  ; We are a .COM file, DOS is active
ENDIF

; Address labels after code-move
BootBaseSeg                 equ     08000h   ; Pre-boot, in the low 640K
BootBasePtr                 equ         0h   ; We put our MBR to this location
BootBaseExec                equ     BootBasePtr+offset MBR_RealStart
StackSeg                    equ     07000h   ; Put the stack below the code

; Video pages, no INT 10h is used for menu-drawing etc.
VideoIO_Page0               equ     0B800h
VideoIO_Page1               equ     0B900h
VideoIO_Page2               equ     0BA00h
VideoIO_Page4               equ     0BC00h
VideoIO_FXSegment           equ     0A000h

; Include some macro's
Include ../INCLUDE/ASM.INC

; Special line-drawing characters
TextChar_WinLineRight       equ     0C4h ; 'Ä'
TextChar_WinLineDown        equ     0B3h ; '³'
TextChar_WinRep1            equ     0D1h ; 'Ñ'
TextChar_WinRep2            equ     0C5h ; 'Å'
TextChar_WinRep3            equ     0CFh ; 'Ï'
TextChar_WinRep4            equ     0B5h ; 'µ'
TextChar_WinRep5            equ     0C6h ; 'Æ'
TextChar_WinRep6            equ     0D8h ; 'Ø'

; Offsets for Partition-Entries in MBR/EPRs
LocBRPT_LenOfEntry          equ     16  ; Length of a standard MBR or EPR entry
LocBRPT_Flags               equ     0   ; Bootable, Hidden, etc.
LocBRPT_BeginCHS            equ     1   ; Combined 10-bits cyl with 6 bits
LocBRPT_BeginHead           equ     1   ; Start head      (0<=H<255)    255 is invalid !
LocBRPT_BeginSector         equ     2   ; Start sector    (1<=S<=255)
LocBRPT_BeginCylinder       equ     3   ; Start cylinder  (0<=C<[1024,16384,65536,n])
LocBRPT_SystemID            equ     4   ; Type of system using the partition
LocBRPT_EndCHS              equ     5   ; Same for end of partition
LocBRPT_EndHead             equ     5
LocBRPT_EndSector           equ     6
LocBRPT_EndCylinder         equ     7
LocBRPT_RelativeBegin       equ     8
LocBRPT_AbsoluteLength      equ     12

LocBR_Magic                 equ     510


; Used as a quick compare in LVM.ASM
LocLVM_SignatureByte0       equ     02h

; Offsets for LVM Information Sector.
; These are relative to the start of the LVM sector.
LocLVM_SignatureStart       equ     00h ; 02h,'RMBPMFD' (8 bytes)
LocLVM_CRC                  equ     08h ; CRC is a DWORD
LocLVM_Heads                equ     1ch ; Number of heads
LocLVM_Secs                 equ     20h ; Sectors per Track
LocLVM_DiskName             equ     24h ; Name of the disk
LocLVM_StartOfEntries       equ     3ch ; (contains maximum of 4 entries)
LocLVM_LenOfEntry           equ     3ch ; Length of an LVM-entry

; An LVM info-sector can contain information on max. 4 partitions.
; All 4 entries will be used when there 4 primary partitions defined.
; For logical partitions, the LVM info-sector is located below the start
; of the logical partition and only one LVM entry is used in that logical
; LVM info-sector.
LocLVM_MaxEntries           equ     4   ; Max entries in an LVM-sector

; Offsets for LVM entry.
; These are relative to the start of the entry.
LocLVM_VolumeID             equ     00h ; is DWORD
LocLVM_PartitionID          equ     04h ; is DWORD
LocLVM_PartitionSize        equ     08h ; is DWORD
LocLVM_PartitionStart       equ     0ch ; is DWORD
LocLVM_OnBootMenu           equ     10h ; is on IBM BM Bootmenu
LocLVM_Startable            equ     11h ; is Startable (newly installed system)
LocLVM_VolumeLetter         equ     12h ; is Drive Letter for partition (C-Z or 0)
LocLVM_Unknown              equ     13h ; unknown BYTE

; Truncated to 11 chars when  displayed in menu.
; MiniLVM sets both to the same value.
; Also, MiniLVM uses a 0-byte terminator, so the maximum length is 19d.
; Same goes for LocLVM_DiskName.
; These offsets are relative to an LVM entry.
LocLVM_VolumeName           equ     14h ; 20 bytes
LocLVM_PartitionName        equ     28h ; 20 bytes (Used in menu)

; LVM constants.
LocLVM_LabelLen             equ     14h ; Length of an LVM Label (Disk/Part/Vol)
LocLVM_DiskNameLen          equ     14h ; Length of an LVM DiskName
LocLVM_VolumeNameLen        equ     14h ; Length of an LVM VolumeName
LocLVM_PartitionNameLen     equ     14h ; Length of an LVM PartitionName



; Offsets for IPT (Internal Partition Table)
LocIPT_MaxPartitions        equ     partition_count ; 45 in v1.07
LocIPT_LenOfSizeElement     equ     6   ; Size of one Size-Element
LocIPT_LenOfIPT             equ     34  ; Length of an IPT-entry
LocIPT_Serial               equ     0   ; Serial from MBR ?
LocIPT_Name                 equ     4   ; Name from FS or LVM  (part/vol)
LocIPT_Drive                equ     15  ; Drive-ID             (80h,81h)
LocIPT_SystemID             equ     16  ; Partition-Type       (06,07,etc)
LocIPT_Flags                equ     17  ; AiR-BOOT Flags for partition (see below)
LocIPT_BootRecordCRC        equ     18  ; CRC of Boot-Record
LocIPT_LocationBegin        equ     20  ; Begin of Partition
LocIPT_LocationPartTable    equ     23  ; PartitionTable of Partition
LocIPT_AbsoluteBegin        equ     26  ; Absolute Sector of Begin
LocIPT_AbsolutePartTable    equ     30  ; Absolute Sector of PartTable

; Hidden Partition Table
;~ LocHPT_LenOfHPT             equ     30  ; Length of an HPT-entry
; Length of an HPT-entry ((45 * 6 bits-per-part) / 8) * 45
; Packed table !
LocHPT_LenOfHPT             equ     34

; AiR-BOOT IPT-Flags
LocIPT_DefaultFlags         equ     00000011b   ; Don't know if boot-able :)
LocIPT_DefaultNonBootFlags  equ     00000010b   ; ...VIBR Detection is always on

Flags_Bootable              equ     00000001b
Flags_VIBR_Detection        equ     00000010b
Flags_HideFeature           equ     00000100b
Flags_DriveLetter           equ     00001000b   ; OS/2 FAT16/HPFS only
Flags_ExtPartMShack         equ     00010000b   ; Ext. Partition M$-Hack req ?
Flags_NoPartName            equ     01000000b
Flags_NowFound              equ     10000000b   ; temp only in OldPartTable
Flags_SpecialMarker         equ     10000000b   ; temp only for HiddenSetup

FileSysFlags_BootAble       equ     00000001b   ; Is this Partition boot-able ?
FileSysFlags_FAT32          equ     00010000b   ; FAT 32 specific name getting
FileSysFlags_NoName         equ     00100000b   ; No Name - use PartitionName
FileSysFlags_DriveLetter    equ     01000000b   ; DriveLetter Feature possible

; Navigation keys
Keys_Up                     equ     48h
Keys_Down                   equ     50h
Keys_Left                   equ     4Bh
Keys_Right                  equ     4Dh
Keys_PageUp                 equ     49h
Keys_PageDown               equ     51h
Keys_GrayPlus               equ     4Eh
Keys_GrayMinus              equ     4Ah
Keys_Plus                   equ     1Bh
Keys_Minus                  equ     35h
Keys_ENTER                  equ     1Ch
Keys_ESC                    equ     1h
Keys_F1                     equ     3Bh
Keys_F10                    equ     44h
Keys_C                      equ     2Eh     ; Add. Check auf Ctrl!
Keys_Y                      equ     2Ch
Keys_Z                      equ     15h
Keys_N                      equ     31h
Keys_TAB                    equ     0Fh
Keys_Delete                 equ     53h
Keys_Backspace              equ     0Eh
Keys_Space                  equ     20h

Keys_Flags_EnterSetup       equ     1100b   ; Strg+Alt (AL)






;------------------------------------------------------------------------------
;                                                         AiR-BOOT / MAIN-CODE
;------------------------------------------------------------------------------

; ------------------------------------------
; Rousseau: # Changed this from .386 to .286
; ------------------------------------------
; Because of the TASM-bug the processor had to be changed to turn JUMPS
; off. Existing movzx instructions were replaced with 286 equivalent code.
; Out of range relative jumps have been recoded.
; TASM still generates an extra NOP after test [mem],1
; instructions.
; JWasm produces tighter code.
; JWasm:
; With segment overrides, the address is expanded to the bit-width.
; So, .386 will generate a 32-bit address, even in a USE16 segment.
.286

; This influences the uses directive and other stuff,
; like calling-style and local variables.
; The model itself,large, has no effect because we generate
; a binairy image and not a segmented executable.

; Tasm needs a memory model for USES on PROC to work.
IFDEF   TASM
    ;~ .model large, basic
    .model  tiny,c
ENDIF

;
; This is used to switch between the original 1-segment (code_seg) and the
; 2-segment (code_seg and bss_data).
; The 2-segment layout was needed for JWasm because it does not treat
; db ? in a code segment as bss-data, even if at the end of the code segment.
; Therefore, a true BSS segment is now used.
; Both the code_seg and the bss_data are grouped to the logical airboot
; segment.
; Note that this influences the offsets in the BSS in the list-file and
; the wdis disassembly file (.WDA).
; They are now segment-relative. The true offset is resolved at link
; time.
;
SEGMENTED   EQU

IFDEF   SEGMENTED
    AIRBOOT     GROUP   LDRIMAGE,VOLATILE
ENDIF

; Our code-segment starts here.
LDRIMAGE    SEGMENT     USE16   PUBLIC  'CODE'

IFDEF   SEGMENTED
    ASSUME  CS:AIRBOOT, DS:AIRBOOT, ES:nothing, SS:nothing
ELSE
    ASSUME  CS:LDRIMAGE,DS:LDRIMAGE,ES:nothing, SS:nothing
ENDIF

;==============================================================================
                                                                    ; Sector 1

;##############################################################################
                ; We are not a .COM file at 100h but a BINARY image
                ; of which only the 1st sector gets loaded at 0000:07c00h
                ; by the BIOS. The code in this 1st sector is position
                ; independent and moves itself to a new location at 8000:0000h.
                ; Then it jumps to a new entry-point and loads the rest of
                ; the image to the new location.
                org 00000h                          ; Sector 1
;##############################################################################


;
; Start of sector 1
; This is the MBR.
; Note the AiRBOOT signature, it's date, version and language.
; Version 1.07 was intruduced in 2011, version 1.0.8 in 2012.
; These new versions fix issues with huge drives, lvm and more.
; For a detailed description see AIR-BOOT.HIS.
;

;
; ---------------------------------------------
; Rousseau: # Combined letter and jump offset #
; ---------------------------------------------
; Martin had a short jump followed by the AiRBOOT signature at first.
; Then he encountered strange behaviour by some M$ operating-systems
; if the the first insruction was not a CLI.
; But there was no room to insert the CLI and of course he did not want to
; change the location of the AiRBOOT signature.
; He solved this by inserting the M$ needed CLI at offset 0 followed by a short
; jump that uses the 'A' of the AiRBOOT signature as the jump displacement.
;


;------------------------------------------------------------------------------
AiR_BOOT:

        ; Some M$ operating systems need a CLI
        ; here otherwise they will go beserk
        ; and will do funny things during
        ; boot phase, it's laughable!
        cli

        ; JMP-Short -> MBR_Start
        ; Uses the 'A' from the signature as the displacement !
        db      0EBh

        ; ID String, Date (DD,MM,CC,YY), Version Number, Language ID
        ;~ db      'AiRBOOT', 24h, 02h, 20h, 12h, 01h, 08h, TXT_LanguageID
        InsertAirbootSignature  TXT_LanguageID

        ; Total Sectors Count.
        ; Will get overwritten by FIXCODE.
        db      1

        ; Total Sectors Count,
        ; Dynamic calculation.
        ;~ db      (code_end-$)/512


MBR_CheckCode   dw      0               ; Check-Sum for Code

;
; No single instruction below should be changed, added or removed in the code
; below as this will cause the jump-link to go haywire.
;
MBR_Start:
                sti                     ;    This opcode is dedicated to:
                cld                     ;    =MICROSOFT JUMP DEPARTMENT=

                ; Setup some base stuff
                ; AX got loaded wrongly for debug, changed the instructions
                ; without modifying the number of bytes.
                ; Don't comment-out the redundant instruction below because this
                ; *will* change the number of bytes and break the jump-chain.
                mov     ax, StartBaseSeg    ; The segment we are moving ourself from (NOT USED)
                ;mov     ds, ax
                push    cs
                pop     ds
                mov     si, StartBasePtr    ; The offset we are moving ourself from
                mov     ax, BootBaseSeg     ; The target segment we are moving ourself to
                mov     es, ax
                mov     di, BootBasePtr     ; The target offset we are moving ourself to

            ; Depending on pre-boot or debug,
            ; only move first 512 bytes or the whole she-bang++ (65400 bytes)
            IFDEF ReleaseCode
                mov     cx, 256          ; Pre-boot environment
            ELSE
                mov     cx, 32700        ; Debug environment (move ~64kB)
            ENDIF

                ;
                ; LET's MOVE OURSELVES !
                ;
                rep     movsw

                ; Code an intersegment jump to the new location
                db      0EAh
                dw      BootBaseExec    ; This is MBR_RealStart + BootBasePtr
                dw      BootBaseSeg     ; This is 08000h
                ;jmp     far ptr BootBaseSeg:BootBaseExec


;
; Some MBR-functions to provide absolute minimum functionality.
;

;
; Entry-point for halting the system.
;
MBR_HaltSystem:
                mov     ax, 8600h
                xor     cx, cx
                mov     dx, 500
                int     15h         ; Wait to display the whole screen :]
MBR_HaltSys:
                cli
                jmp     MBR_HaltSys
;db 100 dup (0)



                ;
                ; Some small space for variables.
                ;
                ORIGIN  0003Ch

; Comport settings
; It had to be moved to create room for the double I13X
; signature.
; It cannot be in the config-area (sector 55)
; because that area is crc-protected and would not allow 'poking'.
BIOS_AuxParms   dw      BIOS_AUXPARMS_DEFAULT

reserved        db      6   dup('X')


                ;
                ; We arrive here after the first jump using the 'A' of the
                ; AiR-BOOT signature.
                ; So we ensure the jump is always at this offset.
                ; We jump here, because Martin needed to
                ; insert a CLI on start and did not
                ; want to change the AiR-BOOT signature
                ; because of Microsoft inventions...
                ;
                ORIGIN  00044h

                ; Jump again...
                ; This time to the setup-code.
                jmp     MBR_Start

;
; Entry-point when loading fails.
;
                db      'LOAD ERROR!', 0
MBR_LoadError   Proc Near
        mov     si, offset $-12
        push    cs
        pop     ds
        call    MBR_Teletype
    MBRLE_Halt:
        jmp     MBRLE_Halt
MBR_LoadError   EndP

;
; Entry-point when saving fails.
;
                db      'SAVE ERROR!', 0
MBR_SaveError   Proc Near
        mov     si, offset $-12
        push    cs
        pop     ds
        call    MBR_Teletype
    MBRSE_Halt:
        jmp     MBRSE_Halt
MBR_SaveError   EndP


; Put text on the screen using the BIOS tele-type function.
; No attributes like color are supported.
;        In: SI - Pointer to begin of string (EOS is 0)
; Destroyed: SI
MBR_Teletype    Proc Near   Uses ax bx cx
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
MBR_Teletype    EndP

;
; Rousseau: DO NOT ADD CODE TO THIS SECTION !
;

;        In: BX - Base Check, DS:SI - Pointer to 512-byte-area to be included
;       Out: BX - Base Check Result
; Destroyed: SI will get updated (+512)
MBR_GetCheckOfSector    Proc Near   Uses ax cx
        mov     cx, 256
    MBRGCOS_Loop:
        lodsw
        xor     ax, 0BABEh
        xor     bx, ax
        loop    MBRGCOS_Loop
        or      bx, bx
        jnz     MBRGCOS_NoFixUp
        mov     bx, 1                   ; dont allow 0, cause 0 == empty
    MBRGCOS_NoFixUp:
        ret
MBR_GetCheckOfSector    EndP






;
; This is where the rest of AiR-BOOT gets loaded.
;

;------------------------------------------------------------------------------
MBR_RealStart:
                mov     ax, StackSeg    ; 07000h, below the moved code
                mov     ss, ax
                ;mov     sp, 7FFFh      ; Odd stack-pointer ??
                mov     sp, 7FFEh       ; Even is better
                mov     ax, es          ; ES holds segment where we moved to
                mov     ds, ax          ; Set DS==ES to Code Segment


            ; If we are in debug-mode, all code is moved already,
            ; so we can directly jump to it.
            ; One difference is that in debug-mode, the whole .com image is
            ; loaded by dos while when air-boot is active from the MBR it
            ; does the loading itself.
            IFNDEF ReleaseCode
                jmp     AiR_BOOT_Start
            ENDIF


                ; Load missing parts from harddrive...
                ;mov     ax, cs          ; actually obsolete
                ;mov     es, ax          ; actually obsolete

                ; Load the configuration-sectors from disk.
                mov     bx, offset Configuration
                mov     dx, 0080h       ; First harddrive, Sector 55
                mov     cx, 0037h       ; Is 55d is config-sector

                ; Call the i/o-part
                call    MBR_LoadConfig

                jnc     MBR_ConfigCopy_NoError

                ; Some error occured
    MBR_ConfigCopy_LoadError:
                call    MBR_LoadError   ; Will Abort BootUp

                ; Load the code sectors
    MBR_ConfigCopy_NoError:
                mov     bx, offset FurtherMoreLoad
                mov     dx, 0080h       ; First harddrive
                mov     cx, 0002h       ; Second sector
                mov     ah, 02h

                ; This location is in the code-segment.
                ; When segment overrides are applied, the address is
                ; expanded to the bit-with.
                ; So the .286 or .386 directive influences the length
                ; of the instruction, even with a USE16 segment.
                mov     al, ds:[10h]    ; Number of code sectors
                int     13h
                jnc     MBR_RealStart_NoError
                jmp     MBR_ConfigCopy_LoadError


                ; [v1.05+]
                ; Signature for IBM's LVM to detect our "powerful" features ;)
                ;
                ; [v1.0.8+]
                ; Reworked MBR code to be able to create a
                ; double 'I13X' signature.
                ; MBR's created with LVM eCS v1.x have the signature at 0d5h
                ; MBR's created with LVM eCS v2.x have the signature at 0d0h
                ; See eCS bugtracker issue #3002
                ;
                ; Update: These are actually MOV EAX,'X31I' instructions
                ; in the eCS LVM MBR-code. They are at different places in
                ; the v1.x and v2.x LVM code.
                ; Let's protect their location.
                ORIGIN  000d0h
                db      'I13X',0,'I13X',0


    MBR_RealStart_NoError:
                ; Now Check Code with CheckSum
                mov     si, offset FurtherMoreLoad

                ;movzx   cx, bptr ds:[10h]
                mov     cl, ds:[10h]
                mov     ch,0

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





;------------------------------------------------------------------------------
   Include TEXT/TXTMBR.ASM                     ; All translateable Text in MBR
;------------------------------------------------------------------------------



; This is an ugly kludge function to create space for the
; double 'I13X' signature.
; It loads the configuration sectors, but bx,cx and dx are not initialized
; in this function. That's done around line 500.
; Putting this few bytes here creates just enough room.
MBR_LoadConfig  Proc Near
        ; Changed from conditional assembler to calculated value
        ; Fixes issue: #2987 -- "air-boot doesn't remember drive letter"
        ; Size of the ab-configuration in 512 byte sectors
        mov     al, (MBR_BackUpMBR - Configuration) / 200h
        mov     ah,02h
        int     13h
        ret
MBR_LoadConfig  EndP


                ; Disk Signature
                ; Note that in an LVM 2.x MBR this collides
                ; with the dummy PTE that it uses to look for IBM-BM
                ; on the second harddisk.
                ORIGIN  001B8h

                ; AiR-BOOT will merge the field from the MBR it replaces.
                db      'DSIG'

                ; Unused word at 01BCh.
                ; An LVM 2.x MBR puts 0CC33h here.
                ; AiR-BOOT will merge the field from the MBR it replaces.
                dw      '$$'


                ;
                ; Partition Table.
                ;
                ORIGIN  001BEh

                ; The 4 entries just for show.
                ; AiR-BOOT will merge them from the MBR it replaces.
                db      16  dup('0')
                db      16  dup('1')
                db      16  dup('2')
                db      16  dup('3')

                ; Boot Sigbature
                dw      0aa55h

; End of sector 1





;==============================================================================
                                                                    ; Sector 2

                ;
                ; Here starts the second sector, sector 2
                ;
                ORIGIN  00200h

;
; Everything beyond this point is loaded on startup
; and is NOT existant at first
;
FurtherMoreLoad:

;
; Filesystem table correlating id with name.
;

                ; first Normal-Partition-ID, Hidden-Partition-ID
                ;  and Default-Partition-Flags.
                ; 01h -> Boot-Able
                ; 10h -> FAT32 - Name Getting Scheme
                ; 20h -> No Name To Get (use Partition Name from IPT)
                ; 40h -> 'L' flag possible
                db      'AiRSYS-TABLE'
FileSysIDs      db      01h, 11h,01h, 04h,014h,01h, 06h,016h,41h, 0Eh,00Eh,01h
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

FileSysNames    db  'FAT12   ', 'FAT16   ', 'FAT16Big', 'FAT16Big'
                db  'HPFS    ', 'NTFS    ', 'LVM-Data', 'JFS     '
                db  'FAT32   ', 'FAT32   ', 'FAT32   ', 'BeOS    '
                db  'Unix    ', 'Minix   ', 'Linux   ', 'Venix   ' ; x row ;)
                db  'BSD/386 ', 'OpenBSD ', 'LinuxSwp', 'NeXTSTEP'
                db  'GNU HURD', 'QNX     ', 'QNX     ', 'QNX     '
                db  '        ', '        ', '        ', '        '
                db  '        ', '        ', '        ', '        '
                db  '        ', '        ', '        ', '        '
                db  '        ', 'Kernel  ', '        ', '0V-Award'
;                db  'OS/2 Man', 'via BIOS', 'Floppy  ', 'Unknown '
                db  'OS2-BMGR', 'via BIOS', 'Floppy  ', 'Unknown '
                         ; -> 44 Partition-Types




;==============================================================================
                                                                    ; Sector 3
                ;
                ; Sector 3
                ;
                ORIGIN  00400h


                ; ##############################################
                ; ## ENTRY-POINT AFTER ALL THE INITIAL HASSLE ##
                ; ##############################################




AiR_BOOT_Start:



        ;
        ; Since v1.0.8, AiR-BOOT is able to chainload IBM-BM.
        ; When IBM-BM resides above the 1024-cylinder limit, the 'I13X'
        ; signature is required at 3000:0000, FS needs to contain 3000h
        ; and the 32-bit LBA address needs to follow the 'I13X' signature.
        ; For booting IBM-BM from the second disk, a copy of the MBR of the
        ; first disk is also required at 0000:7E00.
        ; This information is derived from the eCS 2.x LVM MBR.
        ;
        ; So, now is a good time to copy the MBR of the first disk to
        ; 0000:7E00 in case the partition that will be started is IBM-BM.
        ; This copy is located at 8000:0000 and DS already points to this
        ; segment.
        ;
        pusha                           ; Save all the general purpose regs
        push    es                      ; We need ES too, so save its value
        xor     ax,ax                   ; Segment 0000h
        mov     es,ax                   ; Make ES point to it
        mov     si,offset BootBasePtr   ; Start of AiR-BOOT which has the MBR
        mov     di,7e00h                ; Destination for the MBR for IBM-BM
        mov     cx,100h                 ; 256 words = 512 bytes
        cld                             ; Direction from low to high
        rep     movsw                   ; Copy the 256 words of the MBR
        pop     es                      ; Restore previous value of ES
        popa                            ; Restore all the general purpose regs


                ;~ nop
                ;~ mov     ax, offset sobss
                ;~ mov     ax,offset BeginOfVariables
                ;~ mov     ax,offset [TrueSecs]
                ;~ lea     ax, [TrueSecs]  ; Tasm generates mov here
                ;~ mov     ax,word ptr [TrueSecs]
                ;~ mov     ax,offset EndOfVariables
                ;~ mov     ax, offset eobss
                ;~ nop



                ;jmp skip

                ; Rousseau:
                ; I should cleanup my garbage here...

                ; Initialize Variable-Tables, Detections, etc.
                call    PRECRAP_Main

                ; Number of harddisks is now known

                call    PARTSCAN_ScanForPartitions


                ; Number of disks found
                mov     si, offset DisksFound
                call    MBR_Teletype

                mov     al, [TotalHarddiscs]
                call    VideoIO_SyncPos
                call    VideoIO_PrintByteDynamicNumber
                xor     si,si
                call    MBR_TeletypeNL

                ; Number of bootable systems indicator
                mov     si, offset PartitionsFound
                call    MBR_Teletype

                mov     al, [CFG_Partitions]
                call    VideoIO_SyncPos
                call    VideoIO_PrintByteDynamicNumber

                xor     si,si
                call    MBR_TeletypeNL
                call    MBR_TeletypeNL

                call    VideoIO_SyncPos

                mov     dl,80h
                call    VideoIO_DumpDiskInfo

                ;
                ; Enumberate Bootable Systems by name
                ; and prepare Phase 1 if active.
                ;
                ; This can also be implemented using the
                ; Installable LVM-flag I think.
                ; But at the time I had lesser knowledge about LVM...
                ; So this algorithm may change in the future.
                ;
                mov     si, offset PartitionTable
                xor     cx,cx
                mov     cl,[CFG_Partitions]
    MBR_Parts:
                add     si, 4
                push    si
                push    si
                ;call    MBR_TeletypeVolName
                pop     si
                call    PART_IsInstallVolume
                jnc     MBR_Parts_NI

                ; Install Volume
                mov     al,' '
                mov     bl,7
                mov     ah, 0eh
                int     10h

                mov     al,'('
                mov     bl,7
                mov     ah, 0eh
                int     10h

                mov     al,[CFG_Partitions]
                sub     al,cl
                ;inc     al
                ;mov     [Menu_EntryAutomatic],al
                mov     [CFG_PartAutomatic],al  ; Setup entry for install-volume
                mov     [CFG_PartLast],al
                mov     ah, [eCS_InstallVolume] ; 1st byte is 0 if no phase 1 active
                test    ah,ah                   ; test the byte, ZF is 0 if phase 1 active
                lahf                            ; flags in ah
                xor     ah, 40h                 ; complement ZF
                and     ah, 40h                 ; mask ZF
                shr     ah, 6                   ; move ZF to LSB
                mov     [CFG_AutomaticBoot], ah ; automatic boot if phase 1 is active


                add     al,'1'
                mov     bl,7
                mov     ah, 0eh
                int     10h

                mov     al,')'
                mov     bl,7
                mov     ah, 0eh
                int     10h

                mov     bx,cx

    MBR_Parts_NI:
                xor     si,si
                ;call    MBR_TeletypeNL
                pop     si
                add     si, 30      ; Add remainder of IPT entry
                loop    MBR_Parts




                ; Index of automatic start partition
                ;mov     si, offset AutoStartPart
                ;call    MBR_Teletype

                ;mov     al, [CFG_PartAutomatic]
                ;add     al, 31h
                ;mov     ah, 09h
                ;mov     bx, 15
                ;mov     cx, 1
                ;int     10h

                ;mov     al, [CFG_PartAutomatic]
                ;add     al, 31h
                ;mov     ah, 0eh
                ;mov     bx, 15
                ;mov     cx, 1
                ;int     10h

                xor     si,si
                call    MBR_TeletypeNL
                xor     si,si
                call    MBR_TeletypeNL

                ;mov    ax,[BIOS_AuxParms]
                ;call   VideoIO_SyncPos
                ;push   ax
                ;add    al,'0'
                ;mov     bl,7
                ;mov     ah, 0eh
                ;int     10h
                ;pop    ax
                ;xchg   al,ah
                ;sub    al,0a2h
                ;mov     bl,7
                ;mov     ah, 0eh
                ;int     10h


                call    MBR_TeletypeSyncPos

                xor     si,si
                call    MBR_TeletypeNL
                call    MBR_TeletypeNL



                mov     si, offset ShowMenu
                call    MBR_TeletypeBold


    skip:



                ;
                ; ####################### WAIT FOR KEY ########################
                ;


                ; Rousseau:
                ; Wait for key so we can see debug log if ab-menu hangs.
                ;;xor     ax, ax
                ;;int     16h

                ;call     SOUND_Beep

                ; Rousseau: delayed save of video-page

                mov     ax, VideoIO_Page1
                call    VideoIO_BackUpTo    ; Copy BIOS POST to Second Page

                ;call     SOUND_Beep


                ;
                ; COM-PORT DEBUG
                ;
                ;call    AuxIO_TeletypeNL
                ;mov     si, offset PartitionTable
                ;call    AuxIO_DumpSector
                ;call    AuxIO_TeletypeNL


                ; Save configuration so phase1 boot-through is disabled
                ; on next boot.
                ; Moved here to fix that Esc out of SETUP would also save.
                ; So moved above the MBR_Main_ReEnterSetup label.
                mov     byte ptr [eCS_InstallVolume], 0  ; disable phase 1 for next boot
                call    DriveIO_SaveConfiguration



                ;
                ; RE-ENTER SETUP
                ;
    MBR_Main_ReEnterSetup:
                call    SETUP_CheckEnterSETUP

                ;call    SOUND_Beep

                ; Rousseau: Every time I see "AfterCrap" I have to laugh :-)
                call    AFTERCRAP_Main

                ; [Linux support removed since v1.02]
                ; Now get FAT16-Linux Kernel Partition, If requested
                ;cmp     [CFG_LinuxKrnlPartition], 0FFh
                ;je      MBR_Main_NoLinuxKrnlPartition
                ;call    LINUX_InitFAT16access
    ;MBR_Main_NoLinuxKrnlPartition:



    MBR_Main_ReEnterBootMenuPre:

                ; SetUp PartitionPointers for BootMenu (filter non-bootable)
                call    PART_CalculateMenuPartPointers

                ; ...and count that one...
                cmp     byte ptr [PartitionPointerCount], 0
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
                test    byte ptr [CFG_AutomaticBoot], 1
                jz      MBR_Main_NoAutomaticBooting
                ; ------------------------------------------ AUTOMATIC BOOTING
                ; Select automatic partition, disable automatic booting for
                ;  next time and boot system...
                mov     byte ptr [CFG_AutomaticBoot], 0
                call    PASSWORD_AskSystemPwd
                mov     al, Menu_EntryAutomatic

                ;mov     al, 2

                mov     Menu_EntrySelected, al      ; zero based
                jmp     MBR_Main_NoBootMenu

                MBR_Main_NoAutomaticBooting:

                ;call   SOUND_Beep

                test    byte ptr [CFG_BootMenuActive], 0FFh
                jnz     MBR_Main_GotBootMenu
                ; ----------------------------------------------- NO BOOT-MENU
                ; Select default partition and boot system...
                call    PASSWORD_AskSystemPwd

                ;call    VideoIO_DBG_WriteString2

                mov     al, Menu_EntryDefault
                ;mov     al,0                         ; zero based
                mov     Menu_EntrySelected, al
                jmp     MBR_Main_NoBootMenu

    MBR_Main_GotBootMenu:
                ; ------------------------------------------ BOOT-MENU VISUALS
                call    FX_StartScreen

                ;call    SOUND_Beep

                call    BOOTMENU_BuildBackground
                call    BOOTMENU_BuildMain
                call    FX_EndScreenRight
                call    PASSWORD_AskSystemPwd
                call    BOOTMENU_ResetTimedBoot

                ;call    SOUND_Beep

                call    BOOTMENU_Execute

                ;call    SOUND_Beep

                jc      MBR_Main_ReEnterSetup
                call    BOOTMENU_SetVarsAfterMenu

                ;call    SOUND_Beep

                ; ---------------------------------------------------- BOOTING
    MBR_Main_NoBootMenu:
                call    FX_StartScreen
                call    BOOTMENU_BuildGoodBye
                call    FX_EndScreenRight
                call    PASSWORD_AskChangeBootPwd

            IFNDEF ReleaseCode
                ; Debug Code to terminate DOS .COM program - used for
                ;  testing AiR-BOOT
                int     3
                mov     ax, 6200h
                int     21h
                mov     es, bx
                mov     ax, 4C00h    ; Quit program
                int     21h
            ENDIF
                call    ANTIVIR_SaveBackUpMBR
                mov     dl, Menu_EntrySelected

                ; -------------------------------------------- START PARTITION
                call    PART_StartPartition



;
; Include other code-modules here.
; Because TASM is a multiple pass assembler, forward references
; are possible.
;
b_std_txt:
Include REGULAR/STD_TEXT.ASM    ; Standard (non-translateable text)
size_std_txt = $-b_std_txt

b_driveio:
Include REGULAR/DRIVEIO.ASM     ; Drive I/O, Config Load/Save
size_driveio = $-b_driveio

b_lvm:
Include SPECIAL/LVM.ASM         ; LVM-specific code
size_lvm = $-b_lvm

b_videoio:
Include REGULAR/VIDEOIO.ASM     ; Video I/O
size_videoio = $-b_videoio

b_timer:
Include REGULAR/TIMER.ASM       ; Timer
size_timer = $-b_timer

b_partmain:
Include REGULAR/PARTMAIN.ASM    ; Regular Partition Routines
size_partmain = $-b_partmain

b_partscan:
Include REGULAR/PARTSCAN.ASM    ; Partition Scanning
size_partscan = $-b_partscan

b_bootmenu:
Include REGULAR/BOOTMENU.ASM    ; Boot-Menu
size_bootmenu = $-b_bootmenu

b_password:
Include REGULAR/PASSWORD.ASM    ; Password related
size_password = $-b_password

b_other:
Include REGULAR/OTHER.ASM       ; Other Routines
size_other = $-b_other

b_main:
Include SETUP/MAIN.ASM          ; The whole AiR-BOOT SETUP
size_main = $-b_main



IFDEF TXT_IncludeCyrillic
b_ccharset:
   Include SPECIAL/CHARSET.ASM  ; Charset Support (e.g. Cyrillic)
size_ccharset = $-b_ccharset
ENDIF


b_math:
Include REGULAR/MATH.ASM        ; Math functions (like 32-bit multiply)
size_math = $-b_math




; Various debugging routines, uses AUXIO and CONV
IFDEF AUX_DEBUG
b_debug:
Include REGULAR/DEBUG.ASM       ; Debug module
size_debug = $-b_debug
b_auxio:
Include REGULAR/AUXIO.ASM       ; Com-port support for debugging
size_auxio = $-b_auxio
ENDIF




;==============================================================================

                ;
                ; Moved up.
                ;

                ;
                ; This is the AiR-BOOT MBR-Protection Image.
                ; 04600 / 200h = 23h = 35d sectors are before this point.
                ; The stuff generated here gets overwritten when the
                ; MBR_PROT.ASM module, which is assembled separately,
                ; gets merged.
                ; So you won't find the string below in the generated binary.
                ;
                ; MOVED TO 6800h to create space and have a continuous
                ; code block.
                ; This makes the RU version buildable again with Tasm.
                ;
                ;org     04600h                                  ; Sector 36-37


                ; Rousseau: It needed a sector alignment, so moved it up to
                ;           have as much space as possible for the modules
                ;           included here.


;==============================================================================
                                                                 ; Sector 38-x
                ;
                ; This section contains translatable texts.
                ;
                ;org     04A00h


b_txtother:
Include TEXT/TXTOTHER.ASM       ; All translateable Text-Strings
size_txtother = $-b_txtother

b_txtmenus:
Include TEXT/TXTMENUS.ASM       ; All translateable Menu-text
size_txtmenus = $-b_txtmenus

b_charset:
Include TEXT/CHARSET.ASM        ; Special Video Charsets (if needed)
size_charset = $-b_charset

b_conv:
Include REGULAR/CONV.ASM        ; Various conversion routines
size_conv = $-b_conv

b_virus:
Include SPECIAL/VIRUS.ASM       ; Virus Detection / Anti-Virus
size_virus = $-b_virus
; [Linux support removed since v1.02]
;Include SPECIAL/FAT16.ASM       ; FAT-16 Support
;Include SPECIAL/LINUX.ASM       ; Linux Kernel Support
b_billsuxx:
Include SPECIAL/F00K/BILLSUXX.ASM   ; Extended Partition - Microsoft-Hack
size_billsuxx = $-b_billsuxx



                ;
                ; Critical end of code marker.
                ; Should always be in the image, otherwise something
                ; is very wrong.
                ;
                db      'DEAD'
                db      'FACE'

;
; Keep these modules here at the end of the code section.
; When debugging, extra code space is used and code will move up towards
; the protection image that is 'orged' and will thus overlay.
; The effects are turned off in debug mode, so it does not matter much that
; this code get's lost.
;
b_sound:
Include SPECIAL/SOUND.ASM       ; Sound
size_sound = $-b_sound

b_apm:
Include SPECIAL/APM.ASM         ; Power Managment Support
size_apm = $-b_apm

b_fx:
Include SPECIAL/FX.ASM          ; l33t Cooper-Bars/Scrolling <bg>
size_fx = $-b_fx


; If we are debugging, we overwrite the FX code.
; As long as FX is disabled this will do no harm.
IFDEF   AUX_DEBUG
                ORG     06780h
ENDIF


bld_level:
                ;
                ; Here we insert the OS/2 BLDLEVEL Information.
                ; It is composed of the AiR-BOOT version-info and other
                ; information.
                ; It is unique for each release of AiR-BOOT.
                ;
                ; ?? When AUX_DEBUG is enabled and the above org is active,
                ; the BLDLEVEL gets corrupted eventhough it gets inserted here
                ; explicitly. The effect is almost like an 'OR' or a merge
                ; with the already generated FX code.
                ; Tasm and JWasm produce different results.
                ; ??
                ;
                InsertBuildLevel

                ;bliep <>

                ;
                ; End of code marker.
                ; If this one vanishes in the image, the FX code will not
                ; be operational.
                ; Will happen with debugging enabled.
                ;
                db      'BABE'
                db      'FACE'

code_end:


                ;
                ; AiR-BOOT Protection Image.
                ; Moved from below to have it not break the included modules
                ; with it's sector alignment requirement.
                ;
                ORIGIN  06800h

zzz_code_space = $ - code_end
                ;
                ; This is the AiR-BOOT MBR-Protection Image.
                ; 06800 / 200h = 34h = 52d sectors are before this point.
                ; The stuff generated here gets overwritten when the
                ; MBR_PROT.ASM module, which is assembled separately,
                ; gets merged.
                ; So you won't find the string below in the generated binary.
                ;

                ; 06800-068FF
                ; 06900-069FF
                ; 06A00-06AFF
                ; 06B00-06BFF

;
; Hardcoded to 1k (1024 bytes) (MBR_PROT.ASM)
; The string below is searched for by the FIXCODE helper and *must* be
; sector (512-bytes) aligned.
;
MBR_Protection  db 'AiR-BOOT MBR-Protection Image'

                ; Just fill.
                db  1024-($-MBR_Protection)  dup('M')


;==============================================================================
                                                                   ; Sector 55

                ;
                ; This section contains the AiR-BOOT configuration.
                ; Note that it has a version that should be updated
                ; when stuff is added.
                ; Also add stuff to the end so that offsets of other
                ; variables remain vaild.
                ;
                ORIGIN  06C00h

Configuration:
                ; THERE IS A NON-ASCII CHAR HERE !!
                ; Your editor may not display this non-ASCII
                ; character at the end if the 'AiRCFG-TABLE'
                ; string. When this character get's deleted,
                ; AiR-BOOT will not function because it cannot
                ; find the config-signature which includes this
                ; invisible character. The code of the char is: 0x0ad.
                db  'AiRCFG-TABLE­'
                db  01h, 08h, 'U' ; "Compressed" ID String
                ; Version 1.02 was for code 1.06, 1.03 was internal
                ; and 1.04,1.05 and 1.06 do not exist.
                ;
                ; 1.07 was used with AB v1.07 and introduced the phase1
                ; system-name. For the rest it is compatible with v1.02.
                ;
                ; 1.0.8 is introduced with AB v1.0.8 and indicates the movement
                ; of several components and the packing of the hideparttable.
                ; The core configuration has not changed but the generated
                ; configuration has. The v1.0.8 installer handles upgrading.
                ;
                ; It is not required for the config to have the
                ; same version as the code, so in the future
                ; the code version might be higher than the
                ; config version if there are no changes to the latter.
                ;

CFG_LastTimeEditLow     dw  0   ; Last Time Edited Stamp (will incr every setup)
CFG_LastTimeEditHi      dw  0   ; second 16 bit part...

CFG_CheckConfig         dw  0   ; Check-Sum for Configuration

CFG_Partitions          db  0   ; Count of partitions in IPT
                        db  0   ; Was BootParts - Removed since v0.28b
CFG_PartDefault         db  0   ; Default-Partition (Base=0)

CFG_PartLast            db  0   ; Which Partition was booted last time ? (Base=0)
CFG_TimedBoot           db  0   ; Timed Boot Enable (for REAL Enable look TimedBootEnable)
CFG_TimedSecs           db  15  ; Timed Boot - How Many Seconds Till Boot
CFG_TimedDelay          dw  123 ; Timed Boot - Delay
CFG_TimedBootLast       db  1   ; Timed Boot - Boot From Last Drive Booted From
CFG_RememberBoot        db  1   ; Remember Manual Boot Choice
CFG_RememberTimed       db  0   ; Remember if Timed Boot (if both disabled: Boot Default)
CFG_IncludeFloppy       db  1   ; Include Floppy Drives in Boot-Menu
CFG_BootMenuActive      db  1   ; Display Boot-Menu (if Disabled: Boot Default)
                                         ; v0.29+ -> 2 - Detailed Bootmenu
CFG_PartitionsDetect    db  1   ; Autodetect New Partitions (Auto-Add!)
CFG_PasswordSetup       db  0   ; Ask Password when entering Setup
CFG_PasswordSystem      db  0   ; Ask Password when booting System
CFG_PasswordChangeBoot  db  0   ; Ask Password when changing boot partition
CFG_ProtectMBR          db  0   ; Protect MBR via TSR ?
CFG_IgnoreWriteToMBR    db  0   ; Just ignore writes to MBR, otherwise crash
CFG_FloppyBootGetName   db  0   ; Gets floppy name for display purposes
CFG_DetectVirus         db  0   ; Detect Virus ?
CFG_DetectStealth       db  0   ; Detect Stealth-Virus ?
CFG_DetectVIBR          db  0   ; Detect BootRecord-Virus ?
CFG_AutoEnterSetup      db  0   ; Automatic Enter Setup (first install!)
CFG_MasterPassword      dw  0101Fh  ; Encoded Password (this is just CR)
                        dw  07A53h
                        dw  0E797h
                        dw  0A896h
CFG_BootPassword        dw  0101Fh  ; Another CR... ;-)
                        dw  07A53h
                        dw  0E797h
                        dw  0A896h
                        db  0   ; Rude-Protection - Removed since v0.28b
CFG_LinuxRootPartition  db  0   ; Linux Root Partition (Base=0)
CFG_TimedKeyHandling    db  0   ; Timed Key Handling (for Timed Boot)
                                    ; 0 - Do Nothing
                                    ; 1 - Reset Time
                                    ; 2 - Stop Time
CFG_MakeSound           db  0   ; Should be clear ;)
CFG_FloppyBootGetTimer  db  0   ; Floppy Name will get updated every 2 secs
CFG_ResumeBIOSbootSeq   db  0   ; If BIOS Boot Sequence should be resumed
                                    ; 0 - Disabled
                                    ; 1 - CD-ROM
                                    ; 2 - Network
                                    ; 3 - ZIP/LS120
CFG_CooperBars          db  0   ; If Cooper Bars should be shown
CFG_LinuxCommandLine    db  75 dup (0)  ; Linux Command Line
CFG_LinuxKrnlPartition  db  0FFh    ; FAT-16 Linux Kernel Partition (Base=0)
                                        ;  FFh -> Disabled
CFG_LinuxDefaultKernel  db  'DEFAULT', 4 dup (32), 0    ; Default Kernel Name
CFG_LinuxLastKernel     db  11 dup (32), 0  ; Last-Booted Kernel Name
CFG_ExtPartitionMShack  db  0   ; Extended Partition M$-Hack Global Enable
CFG_AutomaticBoot       db  0   ; Automatic Booting (only one bootup)
CFG_PartAutomatic       db  0   ; Partition-No for automatic booting
CFG_ForceLBAUsage       db  1   ; LBA-BIOS-API forced on any HDD I/O
CFG_IgnoreLVM           db  0   ; Ignores any LVM-Information


;
; THERE IS ROOM RESERVED HERE FOR MORE VARIABLES
;

                ;
                ; Drive Letters.
                ;
                ORIGIN  06CB0h


;
; Moved here to make room for packed hiddenparttable.
;
DriveLetters            db  LocIPT_MaxPartitions dup (0)
                        ; Format is:
                        ;============
                        ; Drive-Letter : BYTE (80h-C:, 81h-D:)
                        ; --------------------> 1 Byte * 45

                ;
                ; Allways have the name of the installation volume
                ; at this offset.
                ; So future config changes will not break auto-install.
                ;
                ORIGIN  06D00h

; SET(A)BOOT stores the volume name of the eCS system being installed here.
; It is truncated to 11 chars because AiR-BOOT currently does not support
; longer labelnames. The name is also capitalized.
;eCS_InstallVolume       db  12 dup (0)
;eCS_InstallVolume       db  'HIGHLOG' ,0
eCS_InstallVolume       db  0,'NOPHASEONE' ,0
;eCS_InstallVolume       db  'ECS-MIDDLE',0,0
;eCS_InstallVolume       db  'ECS-HIGH',0,0,0,0
;eCS_InstallVolume       db  'ECS-HIGH',0,'NO',0


;
; THERE IS ROOM RESERVED HERE FOR MORE VARIABLES
;

                ;
                ; 06DABh - 06C00h = 01ABh = 427 bytes.
                ; Entries allocated down from 06E00 boundary.
                ;
                ORIGIN  06DABh                                  ; 427 Boundry

; (432 - 5 = 427)
AutoDrvLetter           db  0
AutoDrvLetterSerial     dd  0

; This entry is also 34 bytes long (466 - 34 = 432)
BIOScontIPTentry:
                        db  0, 0, 0, 0, '           '
                        db  0, 0FEh, Flags_Bootable
                        dw  0     ; No Checksum :)
                        db  0, 1, 0
                        db  0, 1, 0 ; Location of Partition/Boot Record
                        dd  0, 0

; VIR variables are for the AiR-BOOT Anti Virus Code
; Most of them are backups of Interrupt Points, so we can check, if a
; stealth virus is on-line, we can intercept its call.
; Normal (non stealth) virus are trapped simply by rereading the MBR sector.
; If a virus is found, we will restore MBR from Sektor 60/62 and stop the
; system from working, so the user has to press reset.
; That's saver than a Reboot.
;
; If a virus is found on the partition to boot, the system will ONLY halt,
; nothing more, because we can not remove it. The user shall do it :)
; Those viruses are detected via a real nasty method...Checksum-Checking of the
; boot-record, which is to be executed. If it does not match the one in our
; internal partition table, we will stop. You may however switch this detection
; off or just reset it by switching 'VIBR Detection'.

; 478 - 12 = 466                                                ; 466 Sub-Part
CFG_VIR_INT08           dd  0    ; pointer to saved 08h entry point
CFG_VIR_INT13           dd  0    ; pointer to saved 13h entry point
CFG_VIR_INT1C           dd  0    ; pointer to saved 1Ch entry point

; 478 Boundry (512-34)
; This entry is also 34 bytes long
FloppyIPTentry          db  0, 0, 0, 0, 'FloppyDrive'
                        db  0, 0FFh, Flags_Bootable
                        dw  0           ; No Checksum :)
                        db  0, 1, 0
                        db  0, 1, 0     ; Location of Partition/Boot Record
                        dd  0, 0
;------------------------------------------------------------------------------

                ;org 06E00h                                     ; Sector 56-57

                ;
                ; AiR-BOOT Internal Partition Table (IPT)
                ;
                ORIGIN  % (image_size - 0a00h - (image_size - image_size_60secs))


;
; Rousseau: This is the start of the AiR-BOOT IPT
;


PartitionTable  db  (LocIPT_MaxPartitions * LocIPT_LenOfIPT) dup (0)
; no-partitions detected... :]
;                             db    1, 0, 0, 0, 'Harddisc  1'
;                             db    0, 0FFh, Flags_BootAble
;                             dw    0    ; No Checksum :)
;                             db    0, 0, 1
;                             db    0, 0, 1 ; Location of Partition/Boot Record
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
    ; --------------------> 34 Bytes (total maximum partition-entries = 30)



                ; No need to check overlap here because this string will
                ; be overwritten if the maximum partition count is reached.
                ; So this is not a critical boundary.
                ORG     (image_size - 600h - (image_size - image_size_60secs) / 2 - 10)

                db 'AiRBOOTPAR' ; 1K internal partition table


;------------------------------------------------------------------------------
                            ;org 07400h                            ; Sector 58


                ;
                ; Hidden Partition Table (6-bit packed as of v1.0.8)
                ;
                ORIGIN  % (image_size - 600h - (image_size - image_size_60secs) / 2)

HidePartitionTable      db  (LocIPT_MaxPartitions * LocHPT_LenOfHPT) dup (0FFh)
                        ; Format is:
                        ;============
                        ; PartitionPtr : BYTE * 30
                        ; --------------------> 30 Bytes * 45

;
; Driveletters were here.
; Moved down to make room for packed hideparttable.
;


                ;
                ; End of hidden partition table.
                ; Check overlap here for security reasons.
                ;
                ORIGIN  % (image_size - 200h - 5)

; 79fa - end of packed hide table
                        db  'ABHID'    ; 1K internal Hide-partition table




;------------------------------------------------------------------------------
                ;org 07A00h
                                                                ; Sector 60

                ;
                ; AiR-BOOT MBR Backup.
                ;
                ORIGIN  % (image_size - 200h)


MBR_BackUpMBR           db  'AiR-BOOT MBR-BackUp',\
                            ' - Just to fill this sector with something',0
AirBootRocks            db  'AiR-BOOT Rocks!',0

                        db  (512 - ($-MBR_BackUpMBR) - 2)  dup('M')

                ; End of Image signature.
                ;
                ORIGIN  % (image_size - 2)
                        dw      0BABEh


                ;
                ; End of Image.
                ;
                ORIGIN  % (image_size)


IFDEF   SEGMENTED
;
; End of AiR-BOOT code and data.
;

LDRIMAGE    ENDS

;DATA_SEG    ENDS

;
; Uninitialized Data (BSS)
;
VOLATILE        SEGMENT     USE16   PUBLIC  'BSS'

ENDIF



sobss:
;------------------------------------------------------------------------------

                            ;
                            ; Removed ORG for BSS data to be more compatible
                            ; with segment-concatenated layout.
                            ;
                            ; What happens before this space ??
                            ; If org 0 corruption occurs.
                            ;

                            ;
                            ; Filling hiddenparttable goes out-of-bounds !
                            ; Fixed with 6-bit packing.
                            ;

;
; If segmented, offsets are relative to the BSS segment.
; They are resolved at link-time.
; If not segmented, offsets are relative to the CODE segment.
;
IFDEF   SEGMENTED
                            ORG 02400h
ELSE
                            ORG 0A000h
ENDIF


; This space actually gets initialized in PreCrap to NUL (till EndOfVariables)
BeginOfVariables:
PartitionSector     db  512 dup (?) ; Temporary Sector for Partition
JfsPBR              db  512 dup (?) ; Temporary Sector for JFS PBR writeback
LVMSector           db  512 dup (?) ; Temporary Sector for LVM
TmpSector           db  512 dup (?) ; Temporary Sector
Scratch             db  256 dup (?) ; Scratch buffer

; Everything used to build a new IPT and reference it to the old one
; IETS OVERSCHRIJFT DIT !!
NewPartTable                db  1536 dup (?)    ; New Partition Table

; New Hide-Partition Table
NewHidePartTable            db  partition_count * LocHPT_LenOfHPT dup (?)

; Logical Drive-Letters
NewDriveLetters             db  partition_count dup (?)

; Size-Table (6 bytes per partition)
PartitionSizeTable          db  partition_count * 6 dup (?)

; Maximum is 52 entries till now
PartitionPointers           dw  52 dup (?)

; Count of total Partition Pointers
PartitionPointerCount       db  ?

; X-Reference Table (holds new partnr, index is old part nr)
PartitionXref               db  partition_count dup (?)

; Volume-Letters
; 0 - no LVM support
; 1 - LVM support, but no letter
; 'C'-'Z' - assigned drive letter
PartitionVolumeLetters      db  partition_count dup (?)




TotalHarddiscs          db  ?           ; Total harddrives (by POST)
LBASwitchTable          db  128 dup (?) ; Bit 25-18 for CHS/LBA Switching
NewPartitions           db  ?           ; Freshly found partitions
                                            ; Independent of SaveConfiguration
TooManyPartitions       db  ?           ; Non-zero if too many partitions found

VideoIO_Segment         dw  ?           ; Segment for Video I/O

ExtendedAbsPos          dd  ?           ; Extended Partition Absolute Position
ExtendedAbsPosSet       db  ?           ; If Absolute Position set

CurPartition_Location   dw  4 dup (?)   ; Where did current partition come from?
CurIO_UseExtension      db  ?           ; 1-Use INT 13h EXTENSIONS
                                        ; (filled out by PreCrap)
CurIO_Scanning          db  ?           ; 1-AiR-BOOT is scanning partitions
                                            ; (for detailed error message)

; [Linux support removed since v1.02]
;GotLinux                     db     ?    ; 1-Linux found

Menu_EntrySelected  db  ?   ; Which partition we boot this time...
Menu_UpperPart      db  ?   ; Which number (Base=0) is the partition upper pos
Menu_AbsoluteX      db  ?   ; Pos where Menu stuff starts
Menu_TotalParts     db  ?   ; Copy of CFG_BootParts
Menu_TotalLines     db  ?   ; Total Lines on Screen used for BootMenu
Menu_EntryDefault   db  ?   ; Default Entry in filtered View
Menu_EntryLast      db  ?   ; LastBooted Entry in filtered View
Menu_EntryAutomatic db  ?   ; Automatic Entry in filtered View
                                         ;  - All adjusted to menu locations

PartSetup_UpperPart     db  ?   ; Partition-Setup (like Menu_UpperPart)
PartSetup_ActivePart    db  ?   ; Active Partition
PartSetup_HiddenUpper   db  ?   ; (like Menu_UpperPart)
PartSetup_HiddenX       db  ?   ; Pos for Hidden-Setup
PartSetup_HiddenAdd     db  ?   ; Adjust for Hidden-Setup

TimedBootEnable     db  ?   ; Local Enable/Disable for timed boot
TimedTimeOut        dd  ?   ; TimeOut Timer for TimedBoot (too much time here;)
TimedSecondLeft     db  ?   ; How many seconds are left till boom ?
TimedSecondBack     db  ?   ; To get a modification noticed
TimedBootUsed       db  ?   ; Timed Boot used for bootup ?
FloppyGetNameTimer  dd  ?   ; Timer for Floppy-Get-Name
SETUP_KeysOnEntry   db  ?   ; which Shift Status was there, when booting ?
SETUP_ExitEvent     db  ?   ; Exit Event to end SETUP
TempPasswordEntry   db  17 dup (?)
SETUP_OldPwd        db  17 dup (?)
SETUP_NewPwd        db  17 dup (?)
SETUP_VerifyPwd     db  17 dup (?)
StartSoundPlayed    db  ?
ChangePartNameSave  db  ?   ; Save label after user-edit ?
SyncLvmLabels       db  ?   ; Sync LVM labels after user-edit ?

FX_UseCount                 dw  ?
FX_OverallTimer             dw  ?
FX_WideScrollerTimer        dw  ?
FX_WideScrollerCurPos       dw  ?
FX_WideScrollerSpeed        db  ?
FX_WideScrollerSpeedState   db  ?
FX_WideScrollerDirection    db  ?
FX_WideScrollerAbsDirection db  ?
FX_WideScrollerBounceSpeed  db  ?
FX_CooperBarsTimer          dw  ?

;~ ; [Linux support removed since v1.02]
;~ FAT16_Drive             db     ?    ; FAT-16: Drive of FAT16-partition
;~ FAT16_AbsPartitionBegin dd     ?    ; FAT-16: LBA Begin of Partition
;~ FAT16_SecsPerCluster    db     ?    ; FAT-16: Sectors Per Cluster
;~ FAT16_NumOfRootEntries  dw     ?    ; FAT-16: Number of Root Entries
;~ FAT16_SecsPerFAT        dw     ?    ; FAT-16: Sectors Per FAT
;~ FAT16_AbsFATBegin       dd     ?    ; FAT-16: LBA Begin of FAT
;~ FAT16_AbsRootBegin      dd     ?    ; FAT-16: LBA Begin of Root
;~ FAT16_AbsClusterBegin   dd     ?    ; FAT-16: LBA Begin of Clusters
;~ FAT16_FATCacheSector    db     ?    ; FAT-16: FAT-Sector No in Cache
;~ FAT16_FATCache          db   512 dup (?) ; FAT-16: FAT-Area Cache
;~ LINUX_KernelEntries     db   680 dup (?) ; 34*20 -> Space for Kernel-Entries
;~ LINUX_KernelNo          db     ?         ; Total of Kernels in KernelEntries
;~ LINUX_KernelSizeTable   db   120 dup (?) ; Size-Table (6 bytes per kernel)

; Dynamically Generated Tables - do not need to get initialized with NUL
FX_CooperColors     db   672 dup (?) ; 7 cooper bars*96 - runtime calculated
FX_CooperState      db     7 dup (?)
FX_SinusPos         db     7 dup (?)
FX_CooperPos        dw     7 dup (?)
CharsetTempBuffer   db  4096 dup (?) ; Uninitialized Charset buffer
LVM_CRCTable        dd   256 dup (?) ; LVM-CRC (->SPECiAL\LVM.asm)




;
; Rousseau: added some stuff.
;


                              ;EVEN
HugeDisk                    db      MaxDisks  dup(?)
TrueSecs                    dd      MaxDisks  dup(?)

; BIOS geometry of the boot-drive
; Note that heads cannot be 256 due to legacy DOS/BIOS bug
; If Int13X is supported those values are used, otherwise the legacy values.
BIOS_Cyls                   dd      MaxDisks  dup(?)
BIOS_Heads                  dd      MaxDisks  dup(?)
BIOS_Secs                   dd      MaxDisks  dup(?)
BIOS_Bytes                  dw      MaxDisks  dup(?)
BIOS_TotalSecs              dq      MaxDisks  dup(?)

; LBA geometry of the boot-drive
; Note that these values are taken from the BPB of a partition boot-record
LVM_Cyls                    dd      MaxDisks  dup(?)
LVM_Heads                   dd      MaxDisks  dup(?)
LVM_Secs                    dd      MaxDisks  dup(?)
LVM_Bytes                   dw      MaxDisks  dup(?)
LVM_TotalSecs               dq      MaxDisks  dup(?)

; OS/2 geometry of the boot-drive
; Note that these values are taken from the BPB of a partition boot-record
LOG_Cyls                    dd      MaxDisks  dup(?)
LOG_Heads                   dd      MaxDisks  dup(?)
LOG_Secs                    dd      MaxDisks  dup(?)
LOG_Bytes                   dw      MaxDisks  dup(?)
LOG_TotalSecs               dq      MaxDisks  dup(?)

; End of transient variables.
EndOfVariables:


;
; Temporary buffer for 48h INT13X bios call.
;

            ; Size of the buffer.
            ; this param *must* be filled in.
            ; Code inserts it.
i13xbuf     dw  1   dup (?)

            ; The buffer itself.
            db  126 dup(?)

            ; Size of buffer calculated.
            ; (excluding the size word at the start).
            i13xbuf_size = $-offset i13xbuf-2

            ; Some debug area.
ott         db  512 dup(?)

eobss:

IFDEF   SEGMENTED
    VOLATILE    ENDS
ELSE
    LDRIMAGE    ENDS
ENDIF

            END     AiR_BOOT

