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
;                                                 AiR-BOOT / OTHER ROUTINES
;---------------------------------------------------------------------------

IFDEF   MODULE_NAMES
DB 'OTHER',0
ENDIF

;        In: DS:SI - Pointer to begin of string
;            CX - Len of string
;       Out: CX - Supposed real len of string
;            Zero Flag set if nul string
; Destroyed: None
GetLenOfName        Proc Near   Uses ax si
        add     si, cx
        dec     si
    GLON_NameLoop:
        mov     al, ds:[si]
        dec     si
        cmp     al, 32
        ja      GLON_EndLoop
        dec     cx
        jnz     GLON_NameLoop
    GLON_EndLoop:
        or      cx, cx
        ret                                   ; return supposed len
GetLenOfName        EndP

;        In: DS:SI - Pointer to NUL-terminated string
;       Out: CX - Length of string
;            Zero Flag set if nul string
; Destroyed: None
GetLenOfString      Proc Near   Uses ax si
        xor     cx, cx
    GLOS_StringLoop:
        lodsb
        or      al, al
        jz      GLOS_EndOfString
        inc     cx
        jmp     GLOS_StringLoop

    GLOS_EndOfString:
        or      cx, cx
        ret
GetLenOfString      EndP

;        In: DS:SI - Pointer to NUL-terminated strings
;            CL    - Counter, how many strings to count
;       Out: CX - Length of strings
; Destroyed: None
GetLenOfStrings     Proc Near   Uses bx dx si
        mov     dh, cl
        xor     dl, dl
    GLOSS_StringsLoop:
        call    GetLenOfString
        add     dl, cl
        add     si, cx
        inc     si
        dec     dh
        jnz     GLOSS_StringsLoop
        ;movzx   cx, dl
        mov   cl,dl
        mov   ch,0
        ret
GetLenOfStrings     EndP



;
; DO PREPARING STUFF.
;
PRECRAP_Main    Proc Near

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'PRECRAP_Main:'
        PUSHRF
            ;~ call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

    ;
    ; Tasm needs .386 to handle 32-bit constants so we push the current
    ; operating state and switch temporarily to handle
    ; InitialFreeDriveletterMap.
    ;
    IFDEF   TASM
        pushstate
        .386
    ENDIF
        ; Initialize the FreeDriveletterMap.
        ; This is used by driveletter reassignment functions.
        mov     di, offset [FreeDriveletterMap]
        mov     ax, InitialFreeDriveletterMap AND 0ffffh
        cld
        stosw
        mov     ax, InitialFreeDriveletterMap SHR 16
        stosw
    ;
    ; Restore Tasm operating state.
    ;
    IFDEF   TASM
        popstate
    ENDIF


        ; Use video page 0 for screen output
        mov     word ptr [VideoIO_Segment], VideoIO_Page0

        ; Don't use blinking attribute
        call    VideoIO_NoBlinking

        ; Get HardDriveCount
        call    DriveIO_GetHardDriveCount


        ; Rousseau: added
        call    VideoIO_ClearScreen

        ; Cursor to upper-left
        mov     byte ptr [TextPosX], 0
        mov     byte ptr [TextPosY], 0
        call    VideoIO_CursorSet

        ;~ mov     ax, VideoIO_Page1
        ;~ call    VideoIO_BackUpTo   ; Copy BIOS POST to Second Page

        ; Copyright
        mov     si, [offset Copyright]
        call    VideoIO_Print
        inc     [TextPosY]
        mov     [TextPosX], 0
        call    MBR_TeletypeSyncPos

        ;call    SOUND_Beep

        ; Show build info
        call    VideoIO_PrintBuildInfo

        ; Let user know we started scanning...
IFDEF   AUX_DEBUG
        xor     si, si
        call    MBR_TeletypeNL
ENDIF
        mov     si, offset [scanning_txt]
        call    MBR_TeletypeBold

; Show message if com-port debugging is active
IFDEF   AUX_DEBUG
        ; Don't show message if com-port debugging is not active
        mov     dx, [BIOS_AuxParms]
        test    dl, dl
        jz      @F

        ; Show initialization message
        mov     ah, [TextPosY]
        mov     [TextPosY], 2
        mov     si, offset AuxInitMsg
        ;~ call    MBR_Teletype
        call    VideoIO_Print

        ; Sync output position
        ;~ call    VideoIO_SyncPos

        ; Show port number
        mov     al, dl
        call    VideoIO_PrintByteDynamicNumber
        mov     [TextPosY], ah
    @@:
ENDIF

        ; Calculate Cooper-Bar Tables
    IFDEF   FX_ENABLED
        call    FX_CalculateTables
    ENDIF

        ; Calculate LVM-CRC-Table
        call    LVM_InitCRCTable

        ; Get HardDriveCount
        call    DriveIO_GetHardDriveCount

        ; Calculate CHS/LBA Switch Table
        call    DriveIO_InitLBASwitchTable

        ; Setup PartitionPointers-Table
        call    PART_CalculateStraightPartPointers

        ; Setup Cyrillic Charset, if needed
    IFDEF TXT_IncludeCyrillic
        call    CHARSET_IncludeCyrillic
    ENDIF


        ; This sets [CurIO_UseExtension] flag.
        call    DriveIO_CheckFor13extensions
        mov     al,[CurIO_UseExtension]
        test    al,al
        jnz     INT13X_Supported

        ;
        ; Show Message that BIOS INT13X is not supported
        ; and Halt the System.
        ;
        mov     cx, 0C04h
        mov     si, offset TXT_NoINT13XSupport
        call    SETUP_ShowErrorBox

        ; Halt the system.
        jmp     HaltSystem


    ;
    ; INT13X Supported so continue.
    ;
    INT13X_Supported:


        ;
        ; Setup the size of the INT13X Disk Address Packet
        ;
        mov     [INT13X_DAP], INT13X_DAP_Size

        ;
        ; Check valididy of the AiR-BOOT Configuration.
        ;
        call    PRECRAP_CheckConfiguration


        ; =======================================
        ; Checks for MBR Virii :) I love that job
        ; =======================================
        test    byte ptr [CFG_DetectStealth], 1
        jz      PCM_NoStealthDetection
        call    VIRUS_CheckForStealth
    PCM_NoStealthDetection:
        test    byte ptr [CFG_DetectVirus], 1
        jz      PCM_NoVirusDetection
        call    VIRUS_CheckForVirus
    PCM_NoVirusDetection:


        ; ============================================
        ;  Delay for some time and get Strg/Alt State
        ; ============================================
        test    byte ptr [CFG_CooperBars], 1
        jnz     PCM_ShortDelay
        mov     al, 27                        ; About 1.5 seconds
        test    byte ptr [CFG_FloppyBootGetName], 1
        jz      PCM_LongDelay
    PCM_ShortDelay:

        mov     al, 13                        ; shorten delay,if floppy gets accessed
    PCM_LongDelay:

        call    TIMER_WaitTicCount

        ; First check, if any normal key got pressed...
        mov     ah, 1
        int     16h
        jz      PCM_NoNormalKeyPressed
        ; User doesn't know what to do...or he is crazy <g> so display message
        mov     si, offset TXT_HowEnterSetup
        call    MBR_Teletype
        mov     al, 54                        ; about 3 seconds, delay again

        call    TIMER_WaitTicCount

    PCM_NoNormalKeyPressed:
        ; Now get keyboard Strg/Alt State
        mov     ah, 02h
        int     16h
        mov     [SETUP_KeysOnEntry], al

        ; Copy device-name to the ContBIOSbootSeq-IPT entry
        ; We may not do this before PRECRAP_CheckConfiguration, because otherwise
        ; this check will fail.
        call    PART_UpdateResumeBIOSName
        ret
PRECRAP_Main    EndP




AFTERCRAP_Main  Proc Near

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'AFTERCRAP_Main:'
        PUSHRF
            ;~ call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        ; ===================================================
        ;  Now get volume label of FloppyDrive, if wanted...
        ; ===================================================
        test    byte ptr [CFG_FloppyBootGetName], 1
        jz      ACM_NoFloppyGetName
        call    DriveIO_UpdateFloppyName
        or      ax, ax
        jnz     ACM_NoFloppyGetName
        ; Try a second time, if it failed to detect the Floppy
        call    DriveIO_UpdateFloppyName
    ACM_NoFloppyGetName:
        ret
AFTERCRAP_Main  EndP


; Checks Configuration CheckSum...Displays message, if failed.
PRECRAP_CheckConfiguration      Proc Near  Uses ds si es di

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'PRECRAP_CheckConfiguration:'
        PUSHRF
            ;~ call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        mov     si, offset Configuration
        xor     bx, bx

        ; Changed from 5 to calculated value (not here, see compat. issue below)
        ; Fixes issue: #2987 -- "air-boot doesn't remember drive letter"
        ; Size of the ab-configuration in 512 byte sectors
        ; mov     cx, (MBR_BackUpMBR - Configuration) / 200h

        ; AB v1.07 stores a 5 sector configuration with a 5 sector checksum.
        ; AB v1.0.8+ *should* stores a 7 sector configuration with a
        ; 7 sector checksum.
        ; Because 5 was hardcoded here, SET(A)BOOT v1.07 will see see an AB v1.0.8+
        ; config as corrupted, while this is not the case.
        ; So, for compatibility reasons, in v1.0.8+, the checksum stored is over
        ; 5 sectors, to be compatible with v1.07.
        ; This may change (be corrected) in future versions !
        mov      cx,5

        mov     dx, [CFG_CheckConfig]       ; Get current CRC for configuration
        mov     [CFG_CheckConfig], bx       ; Mark it as invalid
    PCCC_Loop:
        call    MBR_GetCheckOfSector        ; Calculate CRC
        loop    PCCC_Loop
        cmp     bx, dx                      ; Validate CRC

        ;
        ; The CRC is calculated and inserted in the loader image when
        ; AiR-BOOT is installed. Ignoring the CRC enables manually
        ; merging the loader without using the installer. This is used
        ; for debugging in virtual machines, where it is easy to
        ; merge the loader to the disk image of the VM.
        ;
IFNDEF  CRC_IGNORE
        jne     PCCC_Failed                 ; Validation failed, halt AiR-BOOT
ENDIF

        mov     CFG_CheckConfig, dx         ; Restore the valid CRC
        ret

        ;
        ; CRC validation for the configuration failed.
        ; Inform the user of this and halt the system.
        ;
    PCCC_Failed:
        mov     si, offset TXT_ERROR_CheckConfig
        call    MBR_Teletype
        mov     si, offset TXT_ERROR_CheckFailed
        call    MBR_Teletype
        jmp     MBR_HaltSystem
PRECRAP_CheckConfiguration      EndP


; Rousseau: added
;        In: SI - Pointer to begin of string (EOS is 0)
; Destroyed: SI
; Fixme: Uses double writes to use attribute with teletype-function.
MBR_TeletypeBold    Proc Near   Uses ax bx cx
    MBRT_LoopBold:
        lodsb
        or      al, al
        jz      MBRT_EndBold
        push    ax
        mov     ah,09h
        mov     bx,15
        mov     cx,1
        int     10h
        pop     ax
        mov     ah,0eh
        mov     bx,7            ; Does not do anything in text-modus
        mov     cx,1
        int     10h
        jmp     MBRT_LoopBold
    MBRT_EndBold:
        ret
MBR_TeletypeBold    EndP


;        In: SI - Pointer to begin of string (EOS is 0)
; Destroyed: SI
; Fixme: Uses double writes to use attribute with teletype-function.
MBR_TeletypeVolName     Proc Near   Uses ax bx cx
        mov     cx, 11
    MBRT_LoopVolName:
        mov     dx,cx           ; Backup counter
        lodsb
        or      al, al
        jz      MBRT_EndVolName
        push    ax
        mov     ah,09h
        mov     bx,15
        mov     cx,1
        int     10h             ; DX is preserved
        pop     ax
        mov     ah,0eh
        mov     bx,7            ; Does not do anything in text-modus
        mov     cx,1
        int     10h             ; DX is preserved
        mov     cx,dx           ; Restore counter
        loop    MBRT_LoopVolName
    MBRT_EndVolName:
        ret
MBR_TeletypeVolName     EndP

; Rousseau: added
; Move cursor to next line
; Just do a new-line if SI==0
MBR_TeletypeNL      Proc Near   Uses ax bx cx
        test    si,si
        jz      MBR_TeletypeNL_NL
        call    MBR_Teletype
    MBR_TeletypeNL_NL:
        push    si
        mov     si, offset NL
        call    MBR_Teletype
        pop     si
        ret
MBR_TeletypeNL      EndP

; Sync teletype position to VideoIO
MBR_TeletypeSyncPos     Proc Near   Uses ax bx cx dx
        pushf
        mov     bh, 0
        mov     ah, 02h
        mov     dh,byte ptr [TextPosY]
        mov     dl,byte ptr [TextPosX]
        int     10h
        popf
        ret
MBR_TeletypeSyncPos     EndP

;------------------------------------------------------------------------------
; Check if a memory block is all zeros
;------------------------------------------------------------------------------
; IN    : BX pointer to memblock
;       : CX length to check, zero length is interpreted as block is zero
; OUT   : ZF=1 block if all zeros
; NOTE  : Segment used is DS, which should be the same as ES
;------------------------------------------------------------------------------
IsMemBlockZero  Proc    Near    Uses ax di es
        push    ds          ; Segment to use
        pop     es          ; Pop in ES because ES is required for scasb
        mov     di, bx      ; Pointer to memblock
        xor     al, al      ; Compare to zero
        cld                 ; Direction upwards
        repe    scasb       ; Scan the block, will leave ZF=1 if all zeros
        ret
IsMemBlockZero  EndP

;------------------------------------------------------------------------------
; Check if a loaded sector is all zeros
;------------------------------------------------------------------------------
; IN    : SI pointer to sector buffer
; OUT   : ZF=1 block if all zeros
; NOTE  : Segment used is DS
;------------------------------------------------------------------------------
IsSectorBufferZero  Proc    Near    Uses bx cx
        mov     bx, si          ; Address of sector buffer
        mov     cx, sector_size ; Normal size of a sector (512 bytes)
        call    IsMemBlockZero  ; Check the memory block
        ret
IsSectorBufferZero  EndP

;------------------------------------------------------------------------------
; Fill a memory block with a specific value
;------------------------------------------------------------------------------
; IN    : AL value to fill block with
;       : BX pointer to memblock
;       : CX length to fill, 0 fills nothing
; OUT   : ZF=1 if fill value was 0
; NOTE  : Segment used is DS
;------------------------------------------------------------------------------
FillMemBlock    Proc    Near    Uses cx di es
        push    ds          ; Segment to use
        pop     es          ; Pop in ES because ES is required for scasb
        mov     di, bx      ; Pointer to memblock
        cld                 ; Direction upwards
        rep     stosb       ; Fill the memory block with value in AL
        test    al, al      ; Set ZR if fill value used is 0
        ret
FillMemBlock    EndP

;------------------------------------------------------------------------------
; Fill a memory block with zeros
;------------------------------------------------------------------------------
; IN    : BX pointer to memblock
;       : CX length to fill, 0 fills nothing
; OUT   : Nothing
; NOTE  : Segment used is DS
;------------------------------------------------------------------------------
ClearMemBlock   Proc    Near    Uses ax
        xor     al, al          ; Fill value
        call    FillMemBlock    ; Fill the memory block
        ret
ClearMemBlock   EndP

;------------------------------------------------------------------------------
; Clears a sector buffer
;------------------------------------------------------------------------------
; IN    : SI pointer to sector buffer
; OUT   : Nothing
; NOTE  : Segment used is DS
;------------------------------------------------------------------------------
ClearSectorBuffer   Proc    Near    Uses bx cx
        mov     bx, si              ; Address of sector buffer
        mov     cx, sector_size     ; Normal size of a sector (512 bytes)
        call    ClearMemBlock       ; Clear the sector buffer
        ret
ClearSectorBuffer   EndP

