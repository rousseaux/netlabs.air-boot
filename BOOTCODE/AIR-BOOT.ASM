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







;##############################################################################
;                                                       AiR-BOOT / DEFINITIONS
;##############################################################################

;
; Include AiR-BOOT Version Information.
; This version-info is defined using simpel EQU's so it can serve as a
; single source for other formats. The AiR-BOOT signature and the
; OS/2 BLDLEVEL use this basic version information.
;
Include VERSION.INC

;
; Include OS/2 BLDLEVEL Information.
; It uses the version-information in VERSION.INC to build it's signature.
;
Include BLDLEVEL.INC

;
; Include some macro's.
; This file contains the ORIGIN macro that is used to detect overlaps.
;
Include ../INCLUDE/ASM.INC


; We actually don't want to use this directive because it generates extra
; NOP instructions that we can do without.
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
; This is used for debugging purposes but it also increases code space.
; It should be off in release code.
;
;~ MODULE_NAMES    EQU



; -----------------------------------------------------------------------------
;                                                                        DEBUG
; -----------------------------------------------------------------------------

;
; Enable this to include Debug Modules and enable COM-port debugging.
; To have room for the debug-code, the FX-code can only be enabled
; when AUX_DEBUG is not defined.
;
;~ AUX_DEBUG       EQU

;
; To have FX enabled, make sure FX_ENABLE is defined.
; There is no need (for now) to remove Cooper Bars from the setup-menu
; because AiR-BOOT does not crash when enabling Cooper Bars while FX
; is not compiled in. Only TAB to post-screen does not work.
; Way to go Martin !
;
IFNDEF  AUX_DEBUG
FX_ENABLED      EQU
ENDIF

;
; If ReleaseCode is not defined, it will produce debug-able code...
; Rousseau: This is currently *not* functional so don't use it !
;           It was used to debug AiR-BOOT as a .COM file.
;
ReleaseCode             equ     -1


; -----------------------------------------------------------------------------
;                                                                          AUX
; -----------------------------------------------------------------------------
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




; -----------------------------------------------------------------------------
;                                                                       LABELS
; -----------------------------------------------------------------------------
; Address labels after code-move
BootBaseSeg                 equ     08000h   ; Pre-boot, in the low 640K
BootBasePtr                 equ         0h   ; We put our MBR to this location
BootBaseExec                equ     BootBasePtr+offset MBR_RealStart
StackSeg                    equ     07000h   ; Put the stack below the code

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



; -----------------------------------------------------------------------------
;                                                                        VIDEO
; -----------------------------------------------------------------------------
; Video pages, no INT 10h is used for menu-drawing etc.
VideoIO_Page0               equ     0B800h
VideoIO_Page1               equ     0B900h
VideoIO_Page2               equ     0BA00h
VideoIO_Page4               equ     0BC00h
VideoIO_FXSegment           equ     0A000h

; Special line-drawing characters
TextChar_WinLineRight       equ     0C4h ; 'Ä'
TextChar_WinLineDown        equ     0B3h ; '³'
TextChar_WinRep1            equ     0D1h ; 'Ñ'
TextChar_WinRep2            equ     0C5h ; 'Å'
TextChar_WinRep3            equ     0CFh ; 'Ï'
TextChar_WinRep4            equ     0B5h ; 'µ'
TextChar_WinRep5            equ     0C6h ; 'Æ'
TextChar_WinRep6            equ     0D8h ; 'Ø'



; -----------------------------------------------------------------------------
;                                                              PARTITION TABLE
; -----------------------------------------------------------------------------
; Offsets for Partition-Entries in MBR/EBRs
LocBRPT_LenOfEntry          equ     16  ; Length of a standard MBR or EPR entry
LocBRPT_Flags               equ     0   ; Bootable, Hidden, etc.
LocBRPT_BeginCHS            equ     1   ; Packed CHS value
LocBRPT_BeginHead           equ     1   ; Start head, usually < 16
LocBRPT_BeginSector         equ     2   ; Start sector, max 63 + cyl high bits
LocBRPT_BeginCylinder       equ     3   ; Start cylinder 8+2 bits, max 1023
LocBRPT_SystemID            equ     4   ; Type of system using the partition
LocBRPT_EndCHS              equ     5   ; Packed CHS value
LocBRPT_EndHead             equ     5   ; End head, usually < 16
LocBRPT_EndSector           equ     6   ; End sector, max 63 + cyl high bits
LocBRPT_EndCylinder         equ     7   ; End cylinder 8+2 bits, max 1023
LocBRPT_RelativeBegin       equ     8   ; LBA32 address of partition
LocBRPT_AbsoluteLength      equ     12  ; 32-bit length of partition

; Signature relative to start of MBR/EBR
LocBR_Magic                 equ     510 ; Offset of 0AA55h signature

; -----------------------------------------------------------------------------
;                                                                   LVM RECORD
; -----------------------------------------------------------------------------
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


; -----------------------------------------------------------------------------
;                                                                    LVM ENTRY
; -----------------------------------------------------------------------------
; Offsets for LVM entry.
; These are relative to the start of the entry.
LocLVM_VolumeID             equ     00h ; DWORD
LocLVM_PartitionID          equ     04h ; DWORD
LocLVM_PartitionSize        equ     08h ; DWORD
LocLVM_PartitionStart       equ     0ch ; DWORD
LocLVM_OnBootMenu           equ     10h ; is on IBM BM Bootmenu
LocLVM_Startable            equ     11h ; is Startable (newly installed system)
LocLVM_VolumeLetter         equ     12h ; Drive Letter for partition (C-Z or 0)
LocLVM_Unknown              equ     13h ; unknown BYTE (can be used ?)
LocLVM_InstallLetter        equ     13h ; unknown BYTE (can be used ?)

; Truncated to 11 chars when  displayed in menu.
; MiniLVM sets both to the same value.
; Also, MiniLVM uses a 0-byte terminator, so the maximum length is 19d.
; Same goes for LocLVM_DiskName.
; These offsets are relative to an LVM entry.
LocLVM_VolumeName           equ     14h ; 20 bytes
LocLVM_PartitionName        equ     28h ; 20 bytes (Used in menu)

; LVM constants.
LocLVM_LabelLen             equ     14h ; Length of LVM Label (Disk/Part/Vol)
LocLVM_DiskNameLen          equ     14h ; Length of LVM DiskName
LocLVM_VolumeNameLen        equ     14h ; Length of LVM VolumeName
LocLVM_PartitionNameLen     equ     14h ; Length of LVM PartitionName


; -----------------------------------------------------------------------------
;                                                                 AiR-BOOT IPT
; -----------------------------------------------------------------------------
; Offsets for IPT (Internal Partition Table)
LocIPT_MaxPartitions        equ     max_partitions  ; 45 in v1.07+
LocIPT_LenOfSizeElement     equ     6   ; Size of one Size-Element
LocIPT_LenOfIPT             equ     34  ; Length of an IPT-entry
LocIPT_Serial               equ     0   ; Serial from MBR ?
LocIPT_Name                 equ     4   ; Name from FS or LVM  (part/vol)
LocIPT_Drive                equ     15  ; Drive-ID             (80h,81h)
LocIPT_SystemID             equ     16  ; Partition-Type       (06,07,etc)
LocIPT_Flags                equ     17  ; AiR-BOOT Flags for part (see below)
LocIPT_BootRecordCRC        equ     18  ; CRC of Boot-Record
LocIPT_LocationBegin        equ     20  ; Begin of Partition
LocIPT_LocationPartTable    equ     23  ; PartitionTable of Partition
LocIPT_AbsoluteBegin        equ     26  ; Absolute Sector of Begin
LocIPT_AbsolutePartTable    equ     30  ; Absolute Sector of PartTable


; AiR-BOOT IPT-Flags
LocIPT_DefaultFlags         equ     00000011b   ; Don't know if boot-able :)
LocIPT_DefaultNonBootFlags  equ     00000010b   ; VIBR Detection is always on

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


; -----------------------------------------------------------------------------
;                                                                 AiR-BOOT HPT
; -----------------------------------------------------------------------------
; Hidden Partition Table
; Length of an HPT-entry ((45 * 6 bits-per-part) / 8) * 45
; 33.75 = 34 bytes for HPT-entry, coincidently same as length of IPT-entry.
; Packed table !
LocHPT_LenOfHPT             equ     34


; -----------------------------------------------------------------------------
;                                                              NAVIGATION KEYS
; -----------------------------------------------------------------------------
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
Keys_C                      equ     2Eh     ; Add. Check for Ctrl!
Keys_Y                      equ     2Ch
Keys_Z                      equ     15h
Keys_N                      equ     31h
Keys_TAB                    equ     0Fh
Keys_Delete                 equ     53h
Keys_Backspace              equ     0Eh
Keys_Space                  equ     20h

Keys_Flags_EnterSetup       equ     1100b   ; Strg+Alt (AL)


; -----------------------------------------------------------------------------
;                                                                         MISC
; -----------------------------------------------------------------------------
; Initial value for the FreeDriveletterMap
; Meaning A,B not free; C-Z free, rest unused. (right to left)
; Each partition with an assigned drive-letter clears a bit in this map.
; (Not implemented yet)
InitialFreeDriveletterMap   equ     00000011111111111111111111111100b

;
; The first harddisk is BIOS coded 80h.
; This makes a total of 128 disks that could be supported using this coding.
; This value is used to store disk-information and this info is allocated
; in the BSS. 64 disks ought to be enough for everybody :-)
;
MaxDisks                    equ     64






;##############################################################################
;                                                         AiR-BOOT / MAIN-CODE
;##############################################################################

;
; Because of the TASM-bug the processor had to be changed to turn JUMPS
; off. Existing movzx instructions were replaced with 286 equivalent code.
; Out of range relative jumps have been recoded.
;
; Since version 1.0.8, JWasm is the preferred assembler and Tasm will be
; dropped. Also, the chances of AiR-BOOT being used on a 286-machine are
; very slim, so a future version will revert back to .386 and also incorporate
; 32-bit code. This will enable some enhanced constructs such as scaled
; indexing, bit-instructions, 32-bit registers and what not.
;
.286

;
; For Tasm, MODEL is needed for the USES directive to work.
; So always use a model when assembling with Tasm otherwise registers on
; function calls that use USES are not saved and restored.
; The model itself, has no real effect because we generate a binary image
; and not a segmented executable.
; For the other assemblers we define no model to get rid of the default C/C++
; segments for future object-linked versions of AiR-BOOT.
;
IFDEF   TASM
    ;~ .model large, basic
    .model  tiny,c
ENDIF

;
; The below is used to switch between the original 1-segment (code_seg) layout
; and the new 2-segment (code_seg and bss_data) layout.
; It will be removed in future versions.
; The 2-segment layout was needed for JWasm because it does not treat
; db ? at the end of a code segment as bss-data.
; Therefore, a true BSS segment is now used.
; Both the code_seg and the bss_data are grouped to the logical AIRBOOT
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
;                                                                     Sector 1
;==============================================================================

;------------------------------------------------------------------------------
                ; We are not a .COM file at 100h but a BINARY image
                ; of which only the 1st sector gets loaded at 0000:07c00h
                ; by the BIOS. The code in this 1st sector is position
                ; independent and moves itself to a new location at 8000:0000h.
                ; Then it jumps to a new entry-point and loads the rest of
                ; the image to the new location.
                org 00000h
;------------------------------------------------------------------------------


;
; Since AiR-BOOT is a boot-loader residing in track0, the first 512 bytes
; have the layout of a Master Boot Record (MBR). When AiR-BOOT get's installed,
; the first 512 bytes of this code get's merged with the Partition Table.
; The rest is installed in the remaining sectors with sector 62 (LBA 61)
; being the last sector used by AiR-BOOT. Sector 63 is reserved for IBM LVM.
; The last sector used by AiR-BOOT is a copy of the MBR that AiR-BOOT makes
; every time a system gets booted.
;

;
; Due to the addition of an extra 'I13X' sugnature and code to preserve the
; values of the registers on entry, the MBR-code has become a bit messy.
; This will be cleaned-up in future versions.
;

;
; Martin had a short jump followed by the AiRBOOT signature at first.
; Then he encountered strange behaviour by some M$ operating-systems
; if the the first insruction was not a CLI.
; But there was no room to insert the CLI and of course he did not want to
; change the location of the AiR-BOOT signature.
; He solved this by inserting the M$ needed CLI at offset 0 followed by a short
; jump that uses the 'A' of the AiR-BOOT signature as the jump displacement.
;


; -----------------------------------------------------------------------------
;                                                            FIRST ENTRY-POINT
; -----------------------------------------------------------------------------
; BOOKMARK: FIRST ENTRY-POINT (Invoked by BIOS)
; ######################################################
; # ENTRY-POINT WHERE THE BIOS TRANSFERS CONTROL TO US #
; ######################################################
AiR_BOOT:
                ; Some M$ operating systems need a CLI
                ; here otherwise they will go beserk
                ; and will do funny things during
                ; boot phase, it's laughable!
    MBR_1stOpc: cli

                ; JMP-Short -> MBR_Start
                ; Uses the 'A' from the signature as the displacement !
    MBR_JmpOpc  db      0EBh

                ; ID String, Date (DD,MM,CC,YY), Version Number, Language ID
                ;~ db      'AiRBOOT',24h,02h,20h,12h,01h,08h,TXT_LanguageID
    MBR_ABSig:  InsertAirbootSignature  TXT_LanguageID

                    ; Total Code Sectors Count.
                    ; Actual value will be inserted by FIXCODE.
    MBR_CodeSecs    db      1

                    ; Total Code Sectors Count, dynamically calculated.
                    ;~ db      (code_end-$)/512

                    ; Check-Sum for Code
    MBR_CheckCode   dw      0



; -----------------------------------------------------------------------------
;                                                            THIRD ENTRY-POINT
; -----------------------------------------------------------------------------
; BOOKMARK: THIRD ENTRY-POINT (Relocate code)
;
; No single instruction below should be changed, added or removed in the code
; below as this will cause the jump-link to go haywire.
;
MBR_Start:
                ;
                ; When we arrive here, no registers have been used yet.
                ; So, they still contain the values the BIOS left in them.
                ; We want to preserve those value's for later inspection
                ; by putting them on the stack.
                ;

                ; No space for this instruction here.
                ; We'll enable interrupts later.
                ;sti            ; This opcode is dedicated to:
                                ; =MICROSOFT JUMP DEPARTMENT=


                ; Push all registers with values provided by the BIOS
                ; on the stack.
                pusha
                ; Temporary save SS and SP so we still have access to this
                ; stack after we have setup our own.
                mov     dx,ss
                mov     bx,sp

                ;
                ; Setup some base stuff
                ; AX got loaded wrongly for debug, changed the instructions
                ; without modifying the number of bytes.
                ; Don't comment-out the redundant instruction below because it
                ; *will* change the number of bytes and break the jump-chain.
                ;

                ; The segment we are moving ourself from (NOT USED)
                ;mov     ax, StartBaseSeg
                ;mov     ds, ax

                ; Make sure DS points to CS.
                push    cs
                pop     ds

                ; Setup the source and destination for the code move.
                mov     si, StartBasePtr    ; The offset we move ourself from
                mov     ax, BootBaseSeg     ; The target segment we move to
                mov     es, ax
                ;mov     di, BootBasePtr    ; The target offset we move to
                ; Changed the instruction to make room.
                ; So, BootBasePtr is not used !
                ; The offset in the target segment is assumed to be 0000
                ; anyway.
                xor     di,di
                ;sti

            ; Depending on pre-boot or debug.
            ; Note that ReleaseCode is obsolete, so we will always move
            ; 256 words; aka this sector, the MBR.
            IFDEF ReleaseCode
                mov     cx, 256          ; Pre-boot environment
            ELSE
                mov     cx, 32700        ; Old Debug environment (move ~64kB)
            ENDIF

                ;
                ; This moves this 512-byte sector, loaded by the BIOS at
                ; 0000:7c00 to 8000:0000.
                ;
                cld
                rep     movsw

                ; Code an intersegment jump to the new location.
                ; jmp    BootBaseSeg:BootBaseExec
                ; Note that DX:BX containts the old SS:SP.
                db      0EAh
                dw      BootBaseExec    ; This is MBR_RealStart + BootBasePtr
                dw      BootBaseSeg     ; This is 08000h




; -----------------------------------------------------------------------------
;                                                         SIMPLE MBR FUNCTIONS
; -----------------------------------------------------------------------------
;
; Some MBR-functions to provide absolute minimum functionality.
;

;
; BOOKMARK: Halt System
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


                ;
                ; Some small space for variables.
                ;
                ORIGIN  0003Ch

; Comport settings.
; It had to be moved to create room for the double I13X signature.
; It cannot be in the config-area (sector 55)
; because that area is crc-protected and would not allow 'poking'.
BIOS_AuxParms   dw      BIOS_AUXPARMS_DEFAULT


IFDEF   AUX_DEBUG
reserved        db      6   dup('X')
ELSE
reserved        db      6   dup(0)
ENDIF




; -----------------------------------------------------------------------------
;                                                           SECOND ENTRY-POINT
; -----------------------------------------------------------------------------
                ;
                ; We arrive here after the first jump using the 'A' of the
                ; AiR-BOOT signature. So we ensure the jump is always at
                ; this offset. We jump here, because Martin needed to
                ; insert a CLI on start and did not want to change the
                ; AiR-BOOT signature because of Microsoft inventions...
                ;
                ORIGIN  00044h

                ; Jump again...
                ; This time to the code that relocates to 8000:0000.
                ; BOOKMARK: SECOND ENTRY_POINT (Skipped over AB signature)
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

;        In: BX     - Base Check
;            DS:SI  - Pointer to 512-byte-area to be included
;       Out: BX     - Base Check Result
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






; -----------------------------------------------------------------------------
;                                                    ENTRY-POINT OF MOVED CODE
; -----------------------------------------------------------------------------

;
; When we arrive here we are running at 8000:0000.
; DX:BX contains the SS:SP of the old stack.
;

;
; This is where the rest of AiR-BOOT gets loaded from track0.
;
; BOOKMARK: Running at relocated position (Load additional sectors)
;------------------------------------------------------------------------------
MBR_RealStart:
                ;
                ; Setup new stack and other segment registers.
                ;
                mov     ax, StackSeg    ; 07000h, below the moved code
                mov     ss, ax
                mov     sp, 7FFEh       ; Even is better
                push    es              ; ES holds segment where we moved to
                pop     ds              ; Set DS=ES to Code Segment

                ;
                ; Push the old SS:SP which was saved in DX:BX on the new stack.
                ;
                push    dx      ; Old SS
                push    bx      ; Old SP


            ; If we are in debug-mode, all code is moved already,
            ; so we can directly jump to it.
            ; One difference is that in debug-mode, the whole .com image is
            ; loaded by dos while when air-boot is active from the MBR it
            ; does the loading itself.
            ; (This debug environment is obsolete and dis-fuctional)
            IFNDEF ReleaseCode
                jmp     AiR_BOOT_Start
            ENDIF

                ; Load the configuration-sectors from disk.
                ; These are the main configuration sector and the various
                ; tables that follow it upto but not including the MBR backup.
                mov     bx, offset Configuration
                mov     dx, 0080h       ; First harddrive
                mov     cx, 0037h       ; Config sector is at 55d (CHS)

                ; Call the i/o-part
                call    MBR_LoadConfig
                jnc     MBR_ConfigCopy_NoError

                ; Some error occured
    MBR_ConfigCopy_LoadError:
                call    MBR_LoadError               ; Will Abort BootUp

                ; Load the code sectors
    MBR_ConfigCopy_NoError:
                mov     bx, offset FurtherMoreLoad  ; Directly after MBR in mem
                mov     dx, 0080h                   ; First harddrive
                mov     cx, 0002h                   ; Start at second sector
                mov     ah, 02h                     ; Read sectors

                ; This location is in the MBR.
                ; It is filled in by the FIXCODE helper that post processes
                ; the AIRBOOT loader image after it has been built.
                ; FIXCODE also embeds the MBR protection-image.
                mov     al, ds:[10h]                ; Number of code sectors
                int     13h                         ; Call BIOS service
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
                ; the v1.x and v2.x LVM MBR-code. Other code might depend on
                ; their presence. Let's protect their location.
                ORIGIN  000d0h
                db      'I13X',0,'I13X',0


    MBR_RealStart_NoError:
                ; Now Check Code with CheckSum
                mov     si, offset FurtherMoreLoad

                ;movzx   cx, bptr ds:[10h]
                mov     cl, ds:[10h]
                mov     ch,0

                ; Claculate checksum
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


                ;
                ; OK, all loading went fine so the rest of the code
                ; is present now, so we jump to it.
                ; The old SS:SP is still on the stack.
                ;
    MBR_RealStart_CheckSuccess:
                jmp     AiR_BOOT_Start





;------------------------------------------------------------------------------
Include TEXT/TXTMBR.ASM                        ; All translateable Text in MBR
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

                ; AiR-BOOT installer will merge the field
                ; from the MBR it replaces.
    MBR_DrvSig  db      'DSIG'

                ; Unused word at 01BCh.
                ; An LVM 2.x MBR puts 0CC33h here.
                ; AiR-BOOT installer will merge the field
                ; from the MBR it replaces.
    MBR_Spare   dw      '$$'


                ;
                ; Partition Table.
                ;
                ORIGIN  001BEh

                ; The 4 entries just for show.
                ; AiR-BOOT installer will merge them from the MBR it replaces.
    MBR_PartTable:
                db      16  dup('0')
                db      16  dup('1')
                db      16  dup('2')
                db      16  dup('3')

                ; Boot Sigbature
    MBR_Sig     dw      0aa55h







;==============================================================================
;                                                                     Sector 2
;==============================================================================

; -----------------------------------------------------------------------------
;                                                           FILE-SYSTEM TABLES
; -----------------------------------------------------------------------------


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
                ; and Default-Partition-Flags.
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
;                                                                     Sector 3
;==============================================================================

; -----------------------------------------------------------------------------
;                               ENTRY-POINT AFTER LOADING THE REST OF THE CODE
; -----------------------------------------------------------------------------

                ORIGIN  00400h


; ############################################
; # ENTRY-POINT AFTER ALL THE INITIAL HASSLE #
; ############################################
; BOOKMARK: AiR_BOOT_Start (AiR-BOOT now completely loaded)
AiR_BOOT_Start:


        ;
        ; Enable interrupts.
        ;
        sti

        ;
        ; Pop the old SS:SP from the stack and save it in the BSS.
        ; Note that this is outside the normal variable area that gets cleared.
        ; This allows AiR-BOOT to restart itself when debugging and come-up
        ; with access to the original values of registers the BIOS passed.
        ;
        pop     [OldSP]
        pop     [OldSS]


; -----------------------------------------------------------------------------
;                                                      IBM-BM BOOT PREPARATION
; -----------------------------------------------------------------------------
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
        ; segment. The 'I13X' signature and FS will be setup later.
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


; -----------------------------------------------------------------------------
;                                                                      PRECRAP
; -----------------------------------------------------------------------------

                ;
                ; First it clears the BSS area.
                ; Note that the old SS:SP is stored outside this area so this
                ; does not get lost.
                ; Then initialize various runtime variables and structures.
                ;
                ; BOOKMARK: Pre Crap
                call    PRECRAP_Main
                ; Number of harddisks and other system-info is now known.

            ;!
            ;! DEBUG_BLOCK
            ;! Let's see what the BIOS supplied us with...
            ;! Uncomment below to activate.
            ;!
            __DUMP_BIOS_REGS__  EQU
            IFDEF   AUX_DEBUG
                IFDEF   __DUMP_BIOS_REGS__
                    pushf
                    pusha
                    ; Print title.
                    mov     si,offset [bios_reg]
                    call    AuxIO_Print
                    ; Save the current stack (SS:SP).
                    mov     ax,ss
                    mov     [CurrentSS],ax
                    mov     [CurrentSP],sp

                    ; Restore the old stack.
                    mov     ss,[OldSS]
                    mov     sp,[OldSP]

                    ; Pop the registers with the BIOS values.
                    popa
                    ; Push them back for AiR-BOOT restart (debug mode).
                    pusha
                    ; Dump them to the serial-port.
                    call    DEBUG_DumpRegisters
                    ; Restore the current stack.
                    mov     ax,[CurrentSS]
                    mov     ss,ax
                    mov     sp,[CurrentSP]

                    ; Restore registers.
                    popa
                    popf
                ENDIF
            ENDIF




            ;!
            ;! DEBUG_BLOCK
            ;! Dump the registers at this point.
            ;! Uncomment below to activate.
            ;!
            IFDEF   AUX_DEBUG
                ;~ call    DEBUG_DumpRegisters
                ; Dump drive-letters of dl-feature before partitions are
                ; scanned and processed.
                call    DEBUG_DumpDriveLetters
                call    DEBUG_DumpVolumeLetters
                call    DEBUG_DumpPartitionXref
            ENDIF

; -----------------------------------------------------------------------------
;                                                               PARTITION SCAN
; -----------------------------------------------------------------------------
                ;
                ; BOOKMARK: Scan all partitions
                ;
                call    PARTSCAN_ScanForPartitions
                ; Internal Partition Table is now populated.

            ;!
            ;! DEBUG_BLOCK
            ;! Dump various tables.
            ;! Uncomment below to activate.
            ;!
            IFDEF   AUX_DEBUG
                ;~ call    DEBUG_DumpIPT
                ;~ call    DEBUG_DumpPartitionPointers
                ;~ call    DEBUG_DumpNewPartTable
                ;~ call    DEBUG_DumpDriveLetters
                call    DEBUG_DumpDriveLetters
                call    DEBUG_DumpVolumeLetters
                call    DEBUG_DumpPartitionXref
            ENDIF


; -----------------------------------------------------------------------------
;                                 RESTORE FORCED DRIVELETTER CORRELATION [LVM]
; -----------------------------------------------------------------------------

                ;
                ; Reconnect forced drive-letters to their corresponding
                ; partitions.
                ;
                ; BOOKMARK: Update Driveletters so they are in-sync again
                call    PARTSCAN_UpdateDriveLetters
                ; Driveletter <-> Partition correlation is now restored.



            ;!
            ;! DEBUG_BLOCK
            ;! Dump various tables.
            ;! Uncomment below to activate.
            ;!
            IFDEF   AUX_DEBUG
                ;~ call    DEBUG_DumpIPT
                ;~ call    DEBUG_DumpPartitionPointers
                ;~ call    DEBUG_DumpNewPartTable
                ;~ call    DEBUG_DumpDriveLetters
                call    DEBUG_DumpDriveLetters
                call    DEBUG_DumpVolumeLetters
                call    DEBUG_DumpPartitionXref
            ENDIF


; -----------------------------------------------------------------------------
;                                                            SHOW WE ARE ALIVE
; -----------------------------------------------------------------------------

                ;
                ; Put some info about AiR-BOOT and the system on the screen.
                ;

                ; Display number of physical disks found
                mov     si, offset DisksFound
                call    MBR_Teletype
                mov     al, [TotalHarddiscs]
                call    VideoIO_SyncPos
                call    VideoIO_PrintByteDynamicNumber
                xor     si,si
                call    MBR_TeletypeNL

                ; Display number of partitions found
                mov     si, offset PartitionsFound
                call    MBR_Teletype
                mov     al, [CFG_Partitions]
                call    VideoIO_SyncPos
                call    VideoIO_PrintByteDynamicNumber

                ; Dump summier disk-info for disks found
                xor     si,si
                call    MBR_TeletypeNL
                call    MBR_TeletypeNL
                call    VideoIO_SyncPos
                mov     dl,80h
                call    VideoIO_DumpDiskInfo





; -----------------------------------------------------------------------------
;                                                     eComStation PHASE1 CHECK
; -----------------------------------------------------------------------------

                ;
                ; BOOKMARK: Check for eCS being installed
                ; Here we check if eComStation v2.1+ is being installed.
                ; If so, we forgo the menu and directly boot it.
                ;

                ; If the first byte of the name of the Install Volume is not 0
                ; then we potentially have a phase1 boot.
                test    byte ptr [eCS_InstallVolume],0ffh
                ; Nope, so continue normally.
                jz      MBR_Main_ContinueBoot

                ; Setup phase1.
                ; It is still possible that a name was set for the
                ; Install Volume that does not exist.
                ; In that case CY will be clear and AL=0FFh.
                call    PART_SetupPhase1
                ; Oops, Install Volume not found, continue normally.
                jnc     MBR_Main_ContinueBoot


                ;
                ; == Install Volume Found ==
                ;


            ;!
            ;! DEBUG_BLOCK
            ;! Dump various tables.
            ;! Uncomment below to activate.
            ;!
            IFDEF   AUX_DEBUG
                ;~ call    DEBUG_DumpIPT
                ;~ call    DEBUG_DumpPartitionPointers
                ;~ call    DEBUG_DumpPartitionXref
                ;~ call    DEBUG_DumpNewPartTable
                ;~ call    DEBUG_DumpDriveLetters
            ENDIF


                ; BOOKMARK: Scan for Partitions (Only if eCS install going on)
                ; Because one or more partitions are possibly added, the
                ; PartitionXref table is not 'in sync' and could cause the
                ; wrong system to be automatically booted.
                ; So we rescan all partitions causing the PartitionXref
                ; table to be filled with correct values so the auto-boot
                ; from the new partition will work correctly.
                call    PARTSCAN_ScanForPartitions


            ;!
            ;! DEBUG_BLOCK
            ;! Dump various tables.
            ;! Uncomment below to activate.
            ;!
            IFDEF   AUX_DEBUG
                ;~ call    DEBUG_DumpIPT
                ;~ call    DEBUG_DumpPartitionPointers
                ;~ call    DEBUG_DumpPartitionXref
                ;~ call    DEBUG_DumpNewPartTable
                ;~ call    DEBUG_DumpDriveLetters
            ENDIF

                ; Setup automatic boot to forgo the Menu.
                ; PART_SetupPhase1 has filled in the other variables.
                mov     byte ptr [CFG_AutomaticBoot],1

                ;
                ; At this point the AiR-BOOT configuration has been altered
                ; to automatically boot the newly installed system without
                ; displaying the menu.
                ; Code further down the road will take care of that.
                ;
                jmp     MBR_Main_ContinueBoot




    ;
    ; Wether a new system is being installed or not,
    ; booting continues here.
    ;
    MBR_Main_ContinueBoot:

                ;
                ; Inform user how to switch between post-screen and menu
                ; by putting this info on the screen.
                ;
                xor     si,si
                call    MBR_TeletypeNL
                xor     si,si
                call    MBR_TeletypeNL
                call    MBR_TeletypeSyncPos
                xor     si,si
                call    MBR_TeletypeNL
                call    MBR_TeletypeNL
                mov     si, offset ShowMenu
                call    MBR_TeletypeBold


                ;
                ; Debug stop.
                ;

                ;
                ; ####################### WAIT FOR KEY ########################
                ;

                ; Wait for key so we can see debug log if ab-menu hangs.
                ;~ xor     ax, ax
                ;~ int     16h
                ;call     SOUND_Beep


                ; Copy BIOS POST to Second Page
                mov     ax, VideoIO_Page1
                call    VideoIO_BackUpTo

                ;call     SOUND_Beep


                ; BOOKMARK: Save Configuration
                ; Save configuration so phase1 boot-through is disabled
                ; on next boot.
                mov     byte ptr [eCS_InstallVolume], 0
                call    DriveIO_SaveConfiguration



                ;
                ; See if setup needs to be entered.
                ;
    MBR_Main_ReEnterSetup:
                call    SETUP_CheckEnterSETUP

                ;
                ; Do some post processing.
                ;
                ; BOOKMARK: After Crap
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


            IFDEF   FX_ENABLED
                call    FX_StartScreen
            ENDIF

                ; BOOKMARK: Build Main Menu
                call    BOOTMENU_BuildBackground
                call    BOOTMENU_BuildMain

            IFDEF   FX_ENABLED
                call    FX_EndScreenRight
            ENDIF

                call    PASSWORD_AskSystemPwd
                call    BOOTMENU_ResetTimedBoot

                ; BOOKMARK: Display Main Menu
                call    BOOTMENU_Execute

                jc      MBR_Main_ReEnterSetup
                call    BOOTMENU_SetVarsAfterMenu

                ; ---------------------------------------------------- BOOTING
    MBR_Main_NoBootMenu:

            IFDEF   FX_ENABLED
                call    FX_StartScreen
            ENDIF

                ; BOOKMARK: Display bye-screen and start selected partition
                call    BOOTMENU_BuildGoodBye

            IFDEF   FX_ENABLED
                call    FX_EndScreenRight
            ENDIF

                call    PASSWORD_AskChangeBootPwd

            IFNDEF ReleaseCode
                ; Debug Code to terminate DOS .COM program - used for
                ;  testing AiR-BOOT
                ; Obsolete.
                int     3
                mov     ax, 6200h
                int     21h
                mov     es, bx
                mov     ax, 4C00h    ; Quit program
                int     21h
            ENDIF
                call    ANTIVIR_SaveBackUpMBR

                ; Preload the selected menu-entry
                ; However, this value will be wrong if eCS phase1 is
                ; active and the installation partition is newly created.
                ; See below for the adjustment.
                mov     dl, byte ptr [Menu_EntrySelected]


                ;
                ; Prepare to start the partition.
                ;
                jmp     MBR_Main_StartPartition



; -----------------------------------------------------------------------------
;                                                              START PARTITION
; -----------------------------------------------------------------------------

    MBR_Main_StartPartition:

            IFDEF   AUX_DEBUG
                ;~ call    DEBUG_DumpIPT
                ;~ call    DEBUG_DumpPartitionPointers
                ;~ call    DEBUG_DumpPartitionXref
                ;~ call    DEBUG_DumpNewPartTable
            ENDIF


                ; -------------------------------------------- START PARTITION
                ; THIS DOES NOT RETURN !
                call    PART_StartPartition




;
; This entry-point restarts AiR-BOOT almost from scratch.
; It skips the movement of the MBR but otherwise it is a functional restart.
; The old BIOS SS:SP where the registers on entry are stored is passed along.
; This entry-point is used for debugging purposes.
;
; BOOKMARK: AiR-BOOT Restart (used for debugging)
AirbootRestart:
        mov     bx, [OldSP]     ; Old SP when BIOS transferred control to AB
        mov     dx, [OldSS]     ; Old SS when BIOS transferred control to AB
        jmp     MBR_RealStart


;
; This entry-point displays a popup that the system is halted
; and then halts the system.
; It is entered on severe error conditions.
;
; BOOKMARK: Halt System
HaltSystem:
        call    VideoIO_ClearScreen
        mov     ax,0ababh
        mov     cx, 0C04h
        mov     si, offset SystemHalted
        call    SETUP_ShowErrorBox
        ; Halt the system.
        jmp     MBR_HaltSystem






                ;
                ; The following section includes various assembler modules
                ; at the source level. These contain functionality for a
                ; multitude of categories like disk-access, video-io, lvm,
                ; debugging, etc. Later versions of AiR-BOOT will use such
                ; modules at the object-file level so they can be shared
                ; more easily.
                ;


; -----------------------------------------------------------------------------
;                                                        INCLUDED FILE SECTION
; -----------------------------------------------------------------------------

; BOOKMARK: Include Section

;
; Include other code-modules here.
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

b_math:
Include REGULAR/MATH.ASM        ; Math functions (like 32-bit multiply)
size_math = $-b_math

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

b_sound:
Include SPECIAL/SOUND.ASM       ; Sound
size_sound = $-b_sound

b_apm:
Include SPECIAL/APM.ASM         ; Power Managment Support
size_apm = $-b_apm



;
; Cyrillic support.
;
IFDEF   TXT_IncludeCyrillic
b_ccharset:
   Include SPECIAL/CHARSET.ASM  ; Charset Support (e.g. Cyrillic)
size_ccharset = $-b_ccharset
ENDIF

; Various debugging routines, uses AUXIO and CONV
IFDEF   AUX_DEBUG
b_debug:
Include REGULAR/DEBUG.ASM       ; Debug module
size_debug = $-b_debug
b_auxio:
Include REGULAR/AUXIO.ASM       ; Com-port support for debugging
size_auxio = $-b_auxio
ENDIF

;
; We only include this if FX_ENABLED is defined.
; FX is disabled when debugging to have more room for debug-code.
; The module compiles to 50eh = 1294 bytes, so that is a lot.
;
IFDEF   FX_ENABLED
b_fx:
Include SPECIAL/FX.ASM          ; l33t Cooper-Bars/Scrolling <bg>
size_fx = $-b_fx
ENDIF


                ;
                ; End of code marker.
                ;
                ; BOOKMARK: END OF CODE
                db      'BABE'
                db      'FACE'


; -----------------------------------------------------------------------------
;                                                                  END OF CODE
; -----------------------------------------------------------------------------
code_end:










; -----------------------------------------------------------------------------
;                                                         BLDLEVEL INFORMATION
; -----------------------------------------------------------------------------

                ; BOOKMARK: BLDLEVEL Information
                ORIGIN  068A0h

;
; The space between this offset and code_end is the space
; available for code.
;
zzz_code_space = $ - code_end


bld_level:
                ;
                ; Here we insert the OS/2 BLDLEVEL Information.
                ; It is composed of the AiR-BOOT version-info and other
                ; information. It is unique for each release of AiR-BOOT.
                ;

                ;
                ; ?? When AUX_DEBUG is enabled and the above org is active,
                ; the BLDLEVEL gets corrupted eventhough it gets inserted here
                ; explicitly. The effect is almost like an 'OR' or a merge
                ; with the already generated FX code.
                ; Tasm and JWasm produce different results.
                ; ??
                ;
                InsertBuildLevel





;==============================================================================
;                                                                    Sector 53
;==============================================================================

                ;
                ; From here on, the layout of the image consists of:
                ; - AiR-BOOT Protection Image
                ; - AiR-BOOT Configuration
                ; - DriveLetters
                ; - Install Volume
                ; - Floppy/CDROM/BIOS BOOT ENTRIES
                ; - Internal Partition Table (IPT)
                ; - Hidden Partition Table (HPT)
                ; - MBR Backup
                ;

                ;
                ; After that, the BSS follows with several runtime
                ; variables and structures.
                ; The BSS is not part of the image on disk of course.
                ;

; -----------------------------------------------------------------------------
;                                                             PROTECTION IMAGE
; -----------------------------------------------------------------------------

                ;
                ; This is the AiR-BOOT MBR Protection Image.
                ; The stuff generated here gets overwritten when the
                ; MBR_PROT module, which is assembled separately,
                ; gets binary merged.
                ; So you won't find the string below in the generated binary.
                ;
                ; BOOKMARK: AiR-BOOT MBR Protection Image
                ORIGIN  06900h




;
; Hardcoded to 768 bytes (MBR_PROT.ASM)
; The string below is searched for by the FIXCODE helper and *must* be
; page (256 bytes) aligned.
;
; It seems to be possible to shrink the protection-image to 768 bytes.
; That gives us an additional 256 bytes of code-space.
; MBR-PROT.ASM,FIXCODE.C,PARTMAIN.ASM and AIR-BOOT.ASM need to be adjusted for that.
; Also the granularity needs to change from 512 bytes to 256 bytes since
; 6900h is not a 512-byte boundary.
;
; 20120908 - Done.
;
MBR_Protection  db 'AiR-BOOT MBR-Protection Image'

                ; Just fill.
                ;~ db  1024-($-MBR_Protection)  dup('M')
                db  768-($-MBR_Protection)  dup('M')







;==============================================================================
;                                                                    Sector 55
;==============================================================================
; -----------------------------------------------------------------------------
;                                                       AiR-BOOT CONFIGURATION
; -----------------------------------------------------------------------------

                ;
                ; This section contains the AiR-BOOT configuration.
                ; Note that it has a version that should be updated
                ; when stuff is added.
                ; Also add stuff to the end so that offsets of other
                ; variables remain vaild.
                ;
                ; BOOKMARK: AiR-BOOT Configuration Sector
                ORIGIN  06C00h

Configuration:
                ; THERE IS A NON-ASCII CHAR HERE !!
                ; Your editor may not display this non-ASCII
                ; character at the end if the 'AiRCFG-TABLE'
                ; string. When this character get's deleted,
                ; AiR-BOOT will not function because it cannot
                ; find the config-signature which includes this
                ; invisible character. The code of the char is: 0adh.
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
CFG_MiscFlags           db  1   ; Miscellaneous Flags (See EQUates)
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
CFG_ResumeBIOSbootSeq   db  1   ; If BIOS Boot Sequence should be resumed
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
                ; BOOKMARK: Stored Drive Letters
                ORIGIN  06CB0h


; -----------------------------------------------------------------------------
;                                                                DRIVE LETTERS
; -----------------------------------------------------------------------------

;
; Moved here to make room for packed hiddenparttable.
; This gets filled when drive-letters that are assigned using the dl-feature.
;
DriveLetters            db  LocIPT_MaxPartitions dup (0)
                        ; Format is:
                        ;============
                        ; Drive-Letter : BYTE (80h-C:, 81h-D:)
                        ; --------------------> 1 Byte * 45



; -----------------------------------------------------------------------------
;                                                               INSTALL VOLUME
; -----------------------------------------------------------------------------

                ;
                ; Allways have the name of the installation volume
                ; at this offset.
                ; So future config changes will not break auto-install.
                ;
                ; BOOKMARK: Name of eCS Installation Volume
                ORIGIN  06D00h

; SET(A)BOOT stores the volume name of the eCS system being installed here.
; It is truncated to 11 chars because AiR-BOOT currently does not support
; longer labelnames. The name is also capitalized.
;eCS_InstallVolume       db  12 dup (0)
;eCS_InstallVolume       db  'HIGHLOG' ,0
;eCS_InstallVolume       db  'ECS-MIDDLE',0,0
;eCS_InstallVolume       db  'ECS-HIGH',0,0,0,0
;eCS_InstallVolume       db  'ECS-HIGH',0,'NO',0
;eCS_InstallVolume       db  'KANWEG2',0
eCS_InstallVolume       db  0,'NOPHASEONE' ,0

;
; THERE IS ROOM RESERVED HERE FOR MORE VARIABLES
;


; -----------------------------------------------------------------------------
;                                               FLOPPY/CDROM/BIOS BOOT ENTRIES
; -----------------------------------------------------------------------------

                ;
                ; 06DABh - 06C00h = 01ABh = 427 bytes.
                ; Entries allocated down from 06E00 boundary.
                ;
                ; BOOKMARK: Floppy/CD-ROM/BIOS Boot Entries
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



; -----------------------------------------------------------------------------
;                                               INTERNAL PARTITION TABLE (IPT)
; -----------------------------------------------------------------------------

                ;
                ; AiR-BOOT Internal Partition Table (IPT)
                ;
                ; BOOKMARK: Internal Partition Table
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



; -----------------------------------------------------------------------------
;                                                 HIDDEN PARTITION TABLE (HPT)
; -----------------------------------------------------------------------------

                ;
                ; Hidden Partition Table (6-bit packed as of v1.0.8)
                ;
                ; BOOKMARK: Hidden Partition Table (packed)
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




;==============================================================================
;                                                                    Sector 62
;==============================================================================
; -----------------------------------------------------------------------------
;                                                                   MBR BACKUP
; -----------------------------------------------------------------------------

                ;
                ; AiR-BOOT MBR Backup.
                ;
                ; BOOKMARK: MBR Backup
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



;
; Terminate LDRIMAGE segment.
;
IFDEF   SEGMENTED
LDRIMAGE    ENDS
ENDIF







;##############################################################################
;                                                                  BSS SEGMENT
;##############################################################################

; BOOKMARK: BSS Segment

;
; Open BSS segment.
;
IFDEF   SEGMENTED
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


; -----------------------------------------------------------------------------
;                                                            START OF BSS DATA
; -----------------------------------------------------------------------------

; This space actually gets initialized in PreCrap to NUL (till EndOfVariables)
BeginOfVariables:


; -----------------------------------------------------------------------------
;                                                               SECTOR BUFFERS
; -----------------------------------------------------------------------------
; BOOKMARK: Sector Buffers
PartitionSector     db  512 dup (?) ; Temporary Sector for Partition
PBRSector           db  512 dup (?) ; Temporary Sector for JFS/HPFS writeback
LVMSector           db  512 dup (?) ; Temporary Sector for LVM
TmpSector           db  512 dup (?) ; Temporary Sector
Scratch             db  256 dup (?) ; Scratch buffer

; -----------------------------------------------------------------------------
;                                                          NEW PARTITION TABLE
; -----------------------------------------------------------------------------
; Everything used to build a new IPT and reference it to the old one
; BOOKMARK: New Partition Table
NewPartTable                db  1536 dup (?)    ; New Partition Table


; -----------------------------------------------------------------------------
;                                                     NEW HIDE PARTITION TABLE
; -----------------------------------------------------------------------------
; BOOKMARK: New Hide-Partition Table
NewHidePartTable            db  LocIPT_MaxPartitions * LocHPT_LenOfHPT dup (?)

    ;~ even

; -----------------------------------------------------------------------------
;                                                            NEW DRIVE LETTERS
; -----------------------------------------------------------------------------
; BOOKMARK: Logical Drive-Letters
NewDriveLetters             db  LocIPT_MaxPartitions dup (?)

    ;~ even

; -----------------------------------------------------------------------------
;                                                         PARTITION SIZE TABLE
; -----------------------------------------------------------------------------
; Size-Table (6 bytes per partition)
; BOOKMARK: Partition Size Table
PartitionSizeTable          db  LocIPT_MaxPartitions * 6 dup (?)


; -----------------------------------------------------------------------------
;                                                           PARTITION POINTERS
; -----------------------------------------------------------------------------
; Maximum is 52 word entries till now
; BOOKMARK: Partition Pointers
PartitionPointers           dw  52 dup (?)

; Count of total Partition Pointers
PartitionPointerCount       db  ?

; -----------------------------------------------------------------------------
;                                                                   XREF TABLE
; -----------------------------------------------------------------------------

; X-Reference Table (holds new partnr, index is old part nr)
; BOOKMARK: Xref Table
PartitionXref               db  LocIPT_MaxPartitions dup (?)

; -----------------------------------------------------------------------------
;                                                               VOLUME LETTERS
; -----------------------------------------------------------------------------

; Volume-Letters
; 0 - no LVM support
; 1 - LVM support, but no letter
; 'C'-'Z' - assigned drive letter
; BOOKMARK: Volume Drive Letters
PartitionVolumeLetters      db  LocIPT_MaxPartitions dup (?)



; -----------------------------------------------------------------------------
;                                                          MISC VARS AND FLAGS
; -----------------------------------------------------------------------------
; BOOKMARK: Misc Vars and Flags
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


; -----------------------------------------------------------------------------
;                                                            MENU RELATED VARS
; -----------------------------------------------------------------------------
Menu_EntrySelected  db  ?   ; Which partition we boot this time...
Menu_UpperPart      db  ?   ; Which number (Base=0) is the partition upper pos
Menu_AbsoluteX      db  ?   ; Pos where Menu stuff starts
Menu_TotalParts     db  ?   ; Copy of CFG_BootParts
Menu_TotalLines     db  ?   ; Total Lines on Screen used for BootMenu
Menu_EntryDefault   db  ?   ; Default Entry in filtered View
Menu_EntryLast      db  ?   ; LastBooted Entry in filtered View
Menu_EntryAutomatic db  ?   ; Automatic Entry in filtered View
                                         ;  - All adjusted to menu locations

; -----------------------------------------------------------------------------
;                                                       PARTITION RELATED VARS
; -----------------------------------------------------------------------------
PartSetup_UpperPart     db  ?   ; Partition-Setup (like Menu_UpperPart)
PartSetup_ActivePart    db  ?   ; Active Partition
PartSetup_HiddenUpper   db  ?   ; (like Menu_UpperPart)
PartSetup_HiddenX       db  ?   ; Pos for Hidden-Setup
PartSetup_HiddenAdd     db  ?   ; Adjust for Hidden-Setup

; -----------------------------------------------------------------------------
;                                                   TIMER / SETUP RELATED VARS
; -----------------------------------------------------------------------------
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


; -----------------------------------------------------------------------------
;                                                              FX RELATED VARS
; -----------------------------------------------------------------------------
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

; Dynamically Generated Tables - do not need to get initialized with NUL
FX_CooperColors     db   672 dup (?) ; 7 cooper bars*96 - runtime calculated
FX_CooperState      db     7 dup (?)
FX_SinusPos         db     7 dup (?)
FX_CooperPos        dw     7 dup (?)


; -----------------------------------------------------------------------------
;                                                               CHARSET BUFFER
; -----------------------------------------------------------------------------
CharsetTempBuffer   db  4096 dup (?) ; Uninitialized Charset buffer

; -----------------------------------------------------------------------------
;                                                                LVM CRC TABLE
; -----------------------------------------------------------------------------
LVM_CRCTable        dd   256 dup (?) ; LVM-CRC (->SPECiAL\LVM.asm)

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


;
; Rousseau: added some stuff.
;
; -----------------------------------------------------------------------------
;                                                           ECS PHASE1 RELATED
; -----------------------------------------------------------------------------
Phase1Active                db      ?
OldPartitionCount           db      ?


; -----------------------------------------------------------------------------
;                                                              DISK PARAMETERS
; -----------------------------------------------------------------------------
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

; Get's initialized at startup to: 00000011111111111111111111111100b
; Meaning A,B not free; C-Z free, rest unused. (right to left)
; Each partition with an assigned drive-letter clears a bit in this map.
FreeDriveletterMap          dd      ?

; LBA address of master LVM sector, zero if non-existant
MasterLVMLBA                dd      ?


; -----------------------------------------------------------------------------
;                                                                  I13X BUFFER
; -----------------------------------------------------------------------------
;
; BOOKMARK: Temporary buffer for 48h INT13X bios call.
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


; End of transient variables.
EndOfVariables:




; -----------------------------------------------------------------------------
;                                                           OLD AND NEW STACKS
; -----------------------------------------------------------------------------
; BOOKMARK: Storage for Old and New Stack Pointers
;
; These need to be outside the variable section because AiR-BOOT can restart
; itself in debug-mode. If the OldSP and OldSS would be in the variable area,
; they would be cleared on AiR-BOOT restart.
;

; The variable section is cleared word-wise, so it could clear one byte extra
; depending on the alignment and size. This DD prevents the OldSP and OldSS
; to be partly overwritten by the clearing routine.
                            dd      ?

; SS:SP from before our relocation.
; The registers values when the BIOS transferred control to us were pushed
; on this stack.

OldSP                       dw      ?
OldSS                       dw      ?

; SS:SP currently in use.
; They are temporarily dumped here so we can pop the resgisters from
; the old stack to display them in debug mode.
CurrentSP                   dw      ?
CurrentSS                   dw      ?



;
; End of BSS segment.
;
eobss:

;
; Close BSS segment.
;
IFDEF   SEGMENTED
    VOLATILE    ENDS
ELSE
    LDRIMAGE    ENDS
ENDIF

            ; BOOKMARK: End of Module
            END     AiR_BOOT

