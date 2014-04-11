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

IFDEF ModuleNames
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

PRECRAP_Main    Proc Near
        ; First initialize Variable-Area (everything with NUL)
        ; We use the start instead of the variables because they could be 'orged'
        ; to an offset. We want everything after the code to be nullified.
        mov     di, offset sobss
        mov     cx, offset EndOfVariables-offset BeginOfVariables
        xor     ax, ax
        shr     cx, 1
        inc     cx
        rep     stosw

        mov     VideoIO_Segment, VideoIO_Page0

        ; Don't use blinking attribute
        call    VideoIO_NoBlinking

        ; Get HardDriveCount
        call    DriveIO_GetHardDriveCount


        ; Rousseau: added
        call    VideoIO_ClearScreen

        ; Cursor to upper-left
        mov     TextPosX, 0
        mov     TextPosY, 0
        call    VideoIO_CursorSet

        ;~ mov     ax, VideoIO_Page1
        ;~ call    VideoIO_BackUpTo   ; Copy BIOS POST to Second Page

        ; Copyright
        mov     si, offset Copyright
        call    MBR_Teletype
        xor     si,si
        call    MBR_TeletypeNL


        ;call    SOUND_Beep

        ; Build Date
        mov     si, offset BUILD_DATE
        call    MBR_TeletypeNL

    IFDEF   AUX_DEBUG
        ; Initialize the com-port for debugging
        call     AuxIO_Init
    ENDIF

        xor     si,si
        call    MBR_TeletypeNL

        xor     cx,cx
    PRECRAP_Main_next_disk:

        mov     dl,cl
        or      dl,80h

        ;
        ; This also setup the size of the i13xbuf.
        ;
        call     DriveIO_GatherDiskInfo              ; Also used to fill the geo, should be separate function

        mov      bx,offset HugeDisk
        add      bx,cx
        mov      [bx], al

        call     DriveIO_LoadMasterLVMSector         ; returns NC if no valid LVM record found

        pushf

        ;~ mov     al,'#'
        ;~ pushf
        ;~ call    VideoIO_PrintSingleChar
        ;~ popf
        ;~ mov     al,0
        ;~ rcl     al,1
        ;~ call    VideoIO_PrintHexByte
        ;~ mov     al,'#'
        ;~ call    VideoIO_PrintSingleChar

        mov      bx, offset TrueSecs
        add      bx,cx
        add      bx,cx
        add      bx,cx
        add      bx,cx
        popf

        ; bx now contains pointer to truesecs for this drive

        jnc      NoValidMasterLVM

        ; ?? 3f bij disk 80h maar 0 bij disk 81h
        mov     si,offset LVMSector
        mov     ax,[si+LocLVM_Secs]

        ;~ pusha
        ;~ mov     dx,ax
        ;~ mov     al,'%'
        ;~ call    VideoIO_PrintSingleChar
        ;~ mov     ax,dx
        ;~ call    VideoIO_PrintHexWord
        ;~ mov     al,'%'
        ;~ call    VideoIO_PrintSingleChar
        ;~ popa

        mov      word ptr [bx],ax
        jmp      SkipUseBiosSecs


    NoValidMasterLVM:
        push    bx                   ; push truesecs pointer
        mov     bx, offset BIOS_Secs
        add     bx,cx
        add     bx,cx
        add     bx,cx
        add     bx,cx

        mov     ax,[bx]              ; get biossecs
        pop     bx
        mov     word ptr [bx],ax     ; store bios secs in truesecs


    SkipUseBiosSecs:
        inc     cx
        cmp     cl,[TotalHarddiscs]
        jb      PRECRAP_Main_next_disk



    IFDEF AUX_DEBUG
        ; Write some debug-info to the com-port
        call     DEBUG_Dump1
    ENDIF

        ;~ jz      NoValidMasterLVM
;~
        ;~ ; A valid Master LVM has been found.
        ;~ ; We use the values in here to determine the number of sectors per track,
        ;~ ; since this could be OS/2 extended geometry.
;~
        ;~ jmp     Continue1
        ;~
        ;~ mov     word ptr [LOG_Secs],63

;               mov      al,[HugeDisk]           ;; fout, moet nog index bij
;               call     AuxIO_TeletypeHexByte
;               call     AuxIO_TeletypeNL

;               mov      ax,word ptr [TrueSecs]  ;; fout, moet nog index bij
;               call     AuxIO_TeletypeHexWord
;               call     AuxIO_TeletypeNL



        ; Huge Disk indicator
        mov     si, offset HugeBootDisk
        call    MBR_Teletype
        mov     al,[HugeDisk]
        mov     si, offset No
        test    al,al
        jz      MBR_HugeDriveIndicator
        mov     si, offset Yes

    MBR_HugeDriveIndicator:
        call    MBR_Teletype
        xor     si,si
        call    MBR_TeletypeNL


        ;
        ; Phase 1 Indicator
        ;
        mov     si, offset Phase1
        call    MBR_Teletype

        mov     si, offset eCS_InstallVolume
        mov     al, [si]
        test    al,al                                 ; See if phase 1 is active
        jnz     MBR_Main_BootThrough
        mov     si, offset NotActive

    MBR_Main_BootThrough:
        call    MBR_Teletype
        xor     si,si
        call    MBR_TeletypeNL


        ; Calculate Cooper-Bar Tables
        call    FX_CalculateTables

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
        call    PRECRAP_CheckFor13extensions

    IFNDEF ReleaseCode
        ret
    ENDIF


    call    PRECRAP_CheckConfiguration


        ; =======================================
        ; Checks for MBR Virii :) I love that job
        ; =======================================
        test    CFG_DetectStealth, 1
        jz      PCM_NoStealthDetection
        call    VIRUS_CheckForStealth
    PCM_NoStealthDetection:
        test    CFG_DetectVirus, 1
        jz      PCM_NoVirusDetection
        call    VIRUS_CheckForVirus
    PCM_NoVirusDetection:


        ; ============================================
        ;  Delay for some time and get Strg/Alt State
        ; ============================================
        test    CFG_CooperBars, 1
        jnz     PCM_ShortDelay
        mov     al, 27                        ; About 1.5 seconds
        test    CFG_FloppyBootGetName, 1
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
        mov     SETUP_KeysOnEntry, al

        ; Copy device-name to the ContBIOSbootSeq-IPT entry
        ; We may not do this before PRECRAP_CheckConfiguration, because otherwise
        ; this check will fail.
        call    PART_UpdateResumeBIOSName
        ret
PRECRAP_Main    EndP

AFTERCRAP_Main  Proc Near
        ; ===================================================
        ;  Now get volume label of FloppyDrive, if wanted...
        ; ===================================================
        test    CFG_FloppyBootGetName, 1
        jz      ACM_NoFloppyGetName
        call    DriveIO_UpdateFloppyName
        or      ax, ax
        jnz     ACM_NoFloppyGetName
        ; Try a second time, if it failed to detect the Floppy
        call    DriveIO_UpdateFloppyName
    ACM_NoFloppyGetName:
        ret
AFTERCRAP_Main  EndP

PRECRAP_CheckFor13extensions    Proc Near
        mov     ah, 41h
        mov     bx, 55AAh
        mov     dl, 80h
        int     13h
        cmp     bx, 0AA55h
        je      PCCF13E_Found
    PCCF13E_NotFound:
        ret
    PCCF13E_Found:
        and     cx, 1
        jz      PCCF13E_NotFound
        mov     CurIO_UseExtension, 1
        ret
PRECRAP_CheckFor13extensions    EndP


; Checks Configuration CheckSum...Displays message, if failed.
PRECRAP_CheckConfiguration      Proc Near  Uses ds si es di
        mov     si, offset Configuration
        xor     bx, bx

        ; Changed from 5 to calculated value (not here, see compat. issue below)
        ; Fixes issue: #2987 -- "air-boot doesn't remember drive letter"
        ; Size of the ab-configuration in 512 byte sectors
        ; mov     cx, (MBR_BackUpMBR - Configuration) / 200h

        ; AB v1.07 stores a 5 sector configuration with a 5 sector checksum.
        ; AB v1.0.8 *should* stores a 7 sector configuration with a
        ; 7 sector checksum.
        ; Because 5 was hardcoded here, SET(A)BOOT v1.07 will see see an AB v1.0.8
        ; config as corrupted, while this is not the case.
        ; So, for compatibility reasons, in v1.0.8, the checksum stored is over
        ; 5 sectors, to be compatible with v1.07.
        ; This may change (be corrected) in future versions !
        mov      cx,5

        mov     dx, CFG_CheckConfig
        mov     CFG_CheckConfig, bx
    PCCC_Loop:
        call    MBR_GetCheckOfSector
        loop    PCCC_Loop
        cmp     bx, dx
        jne     PCCC_Failed
        mov     CFG_CheckConfig, dx
        ret
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
        mov     dh,[TextPosY]
        mov     dl,[TextPosX]
        int     10h
        popf
        ret
MBR_TeletypeSyncPos     EndP
