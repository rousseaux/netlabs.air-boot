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
;                                                      AiR-BOOT / DRIVE I/O
;---------------------------------------------------------------------------



IFDEF   MODULE_NAMES
DB 'DRIVEIO',0
ENDIF

;
; Check if INT13X extensions are supported.
; AirBoot requires these extensions, and will halt if they are not available.
; Modified: [CurIO_UseExtension]
DriveIO_CheckFor13extensions    Proc Near   Uses ax bx cx dx
        mov     ah, 41h
        mov     bx, 55AAh
        mov     dl, [BIOS_BootDisk]     ; We check using the boot-disk
        int     13h

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_CheckFor13extensions:'
        PUSHRF
            call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
            mov     si, offset [Scratch]
            mov     word ptr [si], 50h
            mov     ah, 48h
            int     13h
            call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpSector
        POPRF
        ENDIF
ENDIF

        jc      PCCF13E_NotFound        ; Error occured
        cmp     bx, 0AA55h
        je      PCCF13E_Found
    PCCF13E_NotFound:
        ret
    PCCF13E_Found:
        and     cx, 1                   ; Check 42h-44h,47h,48h supported
        jz      PCCF13E_NotFound        ; Sig OK but no support, strange beast
        mov     byte ptr [CurIO_UseExtension], 1
        ret
DriveIO_CheckFor13extensions    EndP


; Note: Some routines set DS/ES to CS or even address via CS, even if its not
;        needed. This was done for SECURITY. So DO NOT remove it.
;        Its there to make sure the correct data is loaded/written to/from
;        harddrive.
;
;  IF YOU MODIFY ANYTHING IN HERE, YOU MAY EASILY BREAK YOUR HARDDRIVE!

; Will only load base-configuration, will NOT load IPT nor Hide-Config
;  Those are originally loaded on startup and will NOT get reloaded.
DriveIO_LoadConfiguration   Proc Near   Uses ax bx cx dx es

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_LoadConfiguration:'
        PUSHRF
            ;~ call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        mov     ax, cs
        mov     es, ax
        mov     bx, offset Configuration
        xor     dh, dh
        mov     dl, [BIOS_BootDisk]           ; Disk we booted from
        mov     cx, 0037h                     ; Sector 55 (CHS)
        mov     ax, 0201h                     ; Function 02, read 1 sector...
        int     13h
        jnc     DIOLC_NoError
        call    MBR_LoadError                 ; Will Abort BootUp


    DIOLC_NoError:
        ret
DriveIO_LoadConfiguration   EndP

DriveIO_SaveConfiguration   Proc Near   Uses ax bx cx dx ds es si

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_SaveConfiguration:'
        PUSHRF
            ;~ call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        mov     ax, cs
        mov     ds, ax
        mov     es, ax                        ; Safety first (CS==DS==ES)
        ; --- Overwrite Floppy-Name with "FloppyDrive"
        mov     si, offset TXT_Floppy_Drive
        mov     di, offset PartitionTable
        sub     di, 30                        ; Adjust to Floppy-Name
        mov     cx, 11
        rep     movsb
        mov     si, offset Configuration      ; Calculate new checksum
        xor     bx, bx

        ; Changed from 5 to calculated value (not here, see compat. issue below)
        ; Fixes issue: #2987 -- "air-boot doesn't remember drive letter"
        ; Size of the ab-configuration in 512 byte sectors
        ;mov     cx, (MBR_BackUpMBR - Configuration) / 200h

        ; AB v1.07 stores a 5 sector configuration with a 5 sector checksum.
        ; AB v1.0.8+ *should* stores a 7 sector configuration with a
        ; 7 sector checksum.
        ; Because 5 was hardcoded here, SET(A)BOOT v1.07 will see see an AB v1.0.8+
        ; config as corrupted, while this is not the case.
        ; So, for compatibility reasons, in v1.0.8+, the checksum stored is over
        ; 5 sectors, to be compatible with v1.07.
        ; This may change (be corrected) in future versions !
        mov     cx,5

        mov     dx, [CFG_CheckConfig]
        mov     [CFG_CheckConfig], bx
    DIOSC_Loop:
        call    MBR_GetCheckOfSector
        loop    DIOSC_Loop
        mov     [CFG_CheckConfig], bx
        ; --------------------------------------------------------------------
        ; ES == CS
        mov     bx, offset Configuration
        xor     dh, dh
        mov     dl, [BIOS_BootDisk]           ; Disk we booted from
        mov     cx, 0037h                     ; Sector 55 (CHS)

        ; Changed from 5 to calculated value
        ; Fixes issue: #2987 -- "air-boot doesn't remember drive letter"
        ; Size of the ab-configuration in 512 byte sectors
        mov     al, (MBR_BackUpMBR - Configuration) / 200h
        mov     ah,03h
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        int     13h
        jnc     DIOSC_NoError
        call    MBR_SaveError                 ; Will Abort BootUp
    DIOSC_NoError:
        ret
DriveIO_SaveConfiguration   EndP

DriveIO_UpdateFloppyName    Proc Near   Uses bx cx dx ds si es di
        mov     ax, cs
        mov     ds, ax
        mov     es, ax

        mov     ah, 00h                        ; Function 0 - Reset Drive
        xor     dl, dl
        int     13h
        xor     dx, dx                         ; Cylinder=0, Head=0
        mov     cx,  1                         ; Sector=1, Drive=0
        mov     bx, offset TmpSector           ; ES:BX - TmpSector
        mov     ax, 0201h                      ; Function 2 - Load Sector
        int     13h
        jnc     DIOUFN_AllFine

        ; --- Overwrite Floppy-Name with "No Disc"
        mov     si, offset TXT_Floppy_NoDisc
        xor     ax, ax
    DIOUFN_WriteFloppyName:
        mov     di, offset PartitionTable
        sub     di, 30                         ; Adjust to Floppy-Name
        mov     cl, 11
        rep     movsb
        ret     ; AX=-1 -> GotDisc, =0 -> NoDisc

        ; --- Floppy found and read, data in TempSector
    DIOUFN_AllFine:
        mov     ax, -1
        mov     si, offset TXT_Floppy_NoName
        cmp     wptr es:[bx+54], 'AF'
        jne     DIOUFN_WriteFloppyName
        cmp     wptr es:[bx+56], '1T'
        jne     DIOUFN_WriteFloppyName
        cmp     bptr es:[bx+58], '2'
        jne     DIOUFN_WriteFloppyName
        mov     si, bx
        add     si, 43                         ; FAT12 - Volume Label Location
        jmp     DIOUFN_WriteFloppyName
DriveIO_UpdateFloppyName    EndP

; =============================================================================
;                      HARDDRIVE / GENERAL ACCESS
; =============================================================================
;  The following routines are used for harddisc/floppy access.
;  The access is done via INT 13h/CHS or INT 13h/LBA.
;  Access will be done prefered by INT 13h/CHS, because it's (I wonder!) much
;   faster, than the LBA-method. I don't know, why LBA is so slow. Perhaps BIOS.
;
;  Internal access (to AiR-BOOT) is always done via INT 13h/CHS.

DriveIO_GetHardDriveCount   Proc Near   Uses ds si
        push    ds
        push    si
        push    0040h
        pop     ds
        mov     si, 0075h
        mov     dh, ds:[si]                ; 40:75 -> POST: Total Harddiscs == DL
        pop     si
        pop     ds
        mov     [TotalHarddiscs], dh
        ret
DriveIO_GetHardDriveCount   EndP


; Fills our LBA-Usage table. It holds the LBA-address, where BIOS/CHS access is
;  stopped and BIOS/LBA access is started.
;  This is calculated by Sector*Heads. Comparing will get done with Bit 25-10
;  on LBA sectors, so we actually divide sector number by 1024.
DriveIO_InitLBASwitchTable  Proc Near   Uses es di
        mov     di, offset LBASwitchTable
        mov     dh, [TotalHarddiscs]
        mov     dl, 80h        ; First disk to process
    DIOILUT_DriveLoop:
        push    dx
        push    di
        mov     ah, 08h
        int     13h            ; DISK - GET DRIVE PARAMETERS
        mov     ah, 0FBh       ; Assume 255 heads/63 sectors, if error
        jc      DIOILUT_Error
        and     cl, 111111b    ; Isolate lower 6 bits of CL -> sector count
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;movzx   ax, cl
        mov   al,cl
        mov   ah,0

        mov     bl, dh         ; DH -> max head number
        mul     bl             ; AX = Sectors*Heads
        shl     ah, 1
        shl     ah, 1          ; Shift 2 bits, so we are able to compare to
                ;  bit 16-23 of the LBA address
    DIOILUT_Error:
        pop     di
        pop     dx
        mov     bptr ds:[di], ah  ; Save that value
        inc     di                ; Go to next BYTE
        inc     dl                ; Next disk
        dec     dh                ; Decrease disks to process
        jnz     DIOILUT_DriveLoop ; Next disk if DH != 0
        ret
DriveIO_InitLBASwitchTable  EndP




;FIXME: Only LBA gets updated, need to update CHS too !!!!!!!

; Adjusts BX:AX / CX:DX to meet LVM sector location
; BX:AX / CX:DX point to MBR or EBR !
;  Destroys SI
; Rousseau: Enhanced to handle sector-numbers 127 and 255 besides 63 for LVM-info sectors.
;           Ugly, need to cleanup.
DriveIO_LVMAdjustToInfoSector   Proc Near

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_LVMAdjustToInfoSector:'
        PUSHRF
            call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        push    cx                      ; Save Cyl/Sec part
        xor     ch,ch                   ; Clear low Cyl part
        and     cl,63                   ; Clear high Cyl part
        push    bx                      ; We need BX...
        push    dx                      ; and DX temoraily
        mov     bx,offset [TrueSecs]    ; Offset of sector table
        xor     dh,dh                   ; Clear DH because we use DL as index
        and     dl,01111111b            ; Remove high bit of BIOS disk-nr
        shl     dx,2                    ; Index to DWORD table
        add     bx,dx                   ; Point to TrueSecs for this disk
        mov     si,[bx]                 ; Get SPT for this disk
        pop     dx                      ; Restore DX...
        pop     bx                      ; and BX
        ;~ sub     si,cx                   ; Adjust offset                      !! INCORRECT FOR LBA (TP CX != 0 !!)
        dec     si
        pop     cx                      ; Restore Cyl/Sec part
        add     ax,si                   ; Add offset to low part...
        adc     bx,0                    ; and high part of LBA address
        or      cl,63                   ; Adjust CHS part   !FIX ME for > 63!   !! FIX HUGE DRIVE !!

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'adjusted'
        PUSHRF
            call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        ret

DriveIO_LVMAdjustToInfoSector   EndP






; #########################################################################
; Routine: Loads partition to ExecBase and checks for validity
; #########################################################################
; Calling : bx:ax - Absolute sector
;           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
; Returns : Carry Set if invalid partition encountered
; Preserve: all registers
; #########################################################################
DriveIO_LoadPartition   Proc Near  Uses si

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_LoadPartition:'
        PUSHRF
            call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        mov     wptr cs:[CurPartition_Location+0], ax
        mov     wptr cs:[CurPartition_Location+2], bx
        mov     wptr cs:[CurPartition_Location+4], dx
        mov     wptr cs:[CurPartition_Location+6], cx ; Saves the location
        mov     si, offset PartitionSector    ; DS:SI - ExecBase


;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        call    DriveIO_LoadSector

        clc
        cmp     wptr [si+LocBR_Magic], 0AA55h
        je      DIOLP_Success
        ; We check, if we are scanning partitions. In that case, if CHS is not 0/0/1
        ;  we will display a "bad partition table" message and halt the system.
        cmp     cx, 0001h
        jne     DIOLP_Failed
        or      dh, dh
        jnz     DIOLP_Failed
        stc                                   ; Set carry, so no partition table
    DIOLP_Success:



        ret
    DIOLP_Failed:
        jmp     DriveIO_GotLoadError
DriveIO_LoadPartition   EndP

; #########################################################################
; Routine: Writes a partition from ExecBase to its original sector
; #########################################################################
; Calling : none
; Returns : none
; Preserve: all registers
; #########################################################################
DriveIO_SavePartition   Proc Near  Uses ax bx cx dx si

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_SavePartition:'
        PUSHRF
            ;~ call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        mov     ax, wptr cs:[CurPartition_Location+0]
        mov     bx, wptr cs:[CurPartition_Location+2]
        mov     dx, wptr cs:[CurPartition_Location+4]
        mov     cx, wptr cs:[CurPartition_Location+6] ; Gets prev. saved location
        mov     si, offset PartitionSector    ; DS:SI - ExecBase
        cmp     wptr [si+LocBR_Magic], 0AA55h ; Checks for signature, if not found
        jne     DIOSP_SevereError             ;  we assume a really bad error
        call    DriveIO_SaveSector
    DIOSP_SevereError:
        ret
DriveIO_SavePartition   EndP

; Keeps DS:SI for caller
DriveIO_LoadTmpSector   Proc Near
        mov     si, offset TmpSector
        call    DriveIO_LoadSector
        ret
DriveIO_LoadTmpSector   EndP

; Keeps DS:SI for caller
DriveIO_SaveTmpSector   Proc Near
        mov     si, offset TmpSector
        call    DriveIO_SaveSector
        ret
DriveIO_SaveTmpSector   EndP



; Keeps DS:SI for caller, sets carry if valid LVM sector encountered
DriveIO_LoadLVMSector   Proc Near  Uses ax bx cx dx

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_LoadLVMSector:'
        PUSHRF
            call    DEBUG_DumpRegisters
            call    AuxIO_DumpSector
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        test    byte ptr [CFG_IgnoreLVM], 1            ; We are supposed to ignore LVM, so
        jnz     DIOLLVMS_NoLVMSector          ;  don't load but declare as bad!
        mov     ax, wptr cs:[CurPartition_Location+0]
        mov     bx, wptr cs:[CurPartition_Location+2]
        mov     dx, wptr cs:[CurPartition_Location+4]
        mov     cx, wptr cs:[CurPartition_Location+6] ; Gets cur. partition location

        call    DriveIO_LVMAdjustToInfoSector

        mov     si, offset [LVMSector]
        call    DriveIO_LoadSector

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'lvm record ex'
        PUSHRF
            ;~ call    AuxIO_TeletypeHexWord
            ;~ call    AuxIO_TeletypeNL
            call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpSector
            mov     cx, 7
        @@:
            call    AuxIO_DumpParagraph
            call    AuxIO_TeletypeNL
            add     si, 16
            loop @B
        POPRF
        ENDIF
ENDIF


        call    LVM_CheckSectorSignature
        jnc     DIOLLVMS_NoLVMSector
        call    LVM_CheckSectorCRC
        jnc     DIOLLVMS_NoLVMSector
        ret

        ; This here is called, if an invalid (or no) LVM information sector is found
        ;  It will truncate the first byte of the sector, so all other routines
        ;  will notice it easily by just comparing the first byte.
    DIOLLVMS_NoLVMSector:
        mov     bptr [si+LocLVM_SignatureStart], 0
        ret
DriveIO_LoadLVMSector   EndP



; Keeps DS:SI for caller, saves at anytime w/o checks (!)
DriveIO_SaveLVMSector   Proc Near  Uses ax bx cx dx

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_SaveLVMSector:'
        PUSHRF
            ;~ call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        test    byte ptr [CFG_IgnoreLVM], 1            ; We are supposed to ignore LVM, so
        jnz     DIOSLVMS_SevereError          ;  don't save at anytime (security!)
        mov     ax, wptr cs:[CurPartition_Location+0]
        mov     bx, wptr cs:[CurPartition_Location+2]
        mov     dx, wptr cs:[CurPartition_Location+4]
        mov     cx, wptr cs:[CurPartition_Location+6] ; Gets cur. partition location
        call    LVM_CheckSectorSignature
        jnc     DIOSLVMS_SevereError                  ; LVM Signature must be there

IFDEF   AUX_DEBUG
        IF 0
        pushf
        pusha
            ;~ dioatlvm    db 'DriveIO_LVMAdjustToInfoSector',10,0
            ;~ pushf
            ;~ pusha
            ;~ mov     si,offset dioatlvm
            ;~ call    AuxIO_Print
            ;~ popa
            ;~ popf
            call    DEBUG_DumpRegisters
            call    DEBUG_DumpCHS
        popa
        popf
        ENDIF
ENDIF

        call    DriveIO_LVMAdjustToInfoSector

IFDEF   AUX_DEBUG
        IF 0
        pushf
        pusha
            call    DEBUG_DumpRegisters
            call    DEBUG_DumpCHS
        popa
        popf
        ENDIF
ENDIF

        mov     si, offset LVMSector
        call    DriveIO_SaveSector
    DIOSLVMS_SevereError:
        ret
DriveIO_SaveLVMSector   EndP



; Special error message instead of "LOAD ERROR" during partition scanning,
;  so users will notice that something is bad with their partition table(s)
DriveIO_GotLoadError    Proc Near
        test    byte ptr cs:[CurIO_Scanning], 1          ; Must be CS:, cause DS!=CS maybe here
        jnz     InScanMode
        jmp     MBR_LoadError
    InScanMode:
        mov     si, offset TXT_BrokenPartitionTable
        push    cs
        pop     ds
        call    MBR_Teletype
        mov     si, offset BrokenHDD
        sub     dl, 50h                       ; 80h -> '0'
        cmp     dl, 39h
        jbe     DIOGLE_BelowA
        add     dl, 7                         ; 3Ah -> 'A'
    DIOGLE_BelowA:
        mov     bptr [si+5], dl
        call    MBR_Teletype

        ; JWasm: cannot jump to local label in other procedure.
        ; Changed to halt here.
        ;jmp     MBRLE_Halt
    DriveIO_GotLoadError_halt:
        jmp     DriveIO_GotLoadError_halt
DriveIO_GotLoadError    EndP

; #########################################################################
; Routine: Loads a specified sector to DS:DI
; #########################################################################
; Calling : bx:ax - Absolute sector
;           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
;           ds:si - Destination-Adress
; Returns : none
; Preserve: all registers
; #########################################################################
DriveIO_LoadSector      Proc Near  Uses ax bx cx dx ds si es di

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_LoadSector:'
        PUSHRF
            call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        ; Is the drive not a harddrive?
        cmp     dl, 80h
        jb      DIOLS_UseNormal

        test    byte ptr cs:[CurIO_UseExtension], 1
        jz      DIOLS_UseNormal
        ; Are we forced do use LBA via Setting?
        jnz     DIOLS_UseExtension

        ; Upper 8 bits of LBA-address set?
        ; Then use LBA (maximum boundary is 16320x16x63 = FB0400h)
        or      bh, bh
        jnz     DIOLS_UseExtension
        ; Compare Switch-Table value to bit 16-23 of LBA-address
        mov     di, dx
        and     di, 007Fh
        cmp     bptr cs:[LBASwitchTable+di], bl
        jbe     DIOLS_UseExtension

    DIOLS_UseNormal:

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_ReadSectorCHS:'
        PUSHRF
            call    DEBUG_DumpRegisters
            call    AuxIO_DumpParagraph
            call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        mov     di, 3                      ; retry count
    DIOLS_ErrorLoop:
        push    ds
        pop     es
        mov     bx, si                     ; ES:BX - Destination
        mov     ax, 0201h                  ; Function 2 - Load Sector
        int     13h
        jnc     DIOLS_Success
        dec     di                         ; decrement retry count
        jnz     DIOLS_ErrorLoop

        ; Sector load failed...
        jmp     DriveIO_GotLoadError

    DIOLS_UseExtension:

        mov     di, ds                  ; segment for transfer address
        call    DriveIO_ReadSectorLBA   ; extended read
        jc      DriveIO_GotLoadError    ; halt on error

        ;~ push    cx
        ;~ mov     cs:[INT13X_DAP_NumBlocks], 1         ; Copy ONE sector
        ;~ mov     wptr cs:[INT13X_DAP_Transfer+0], si
        ;~ mov     cx, ds
        ;~ mov     wptr cs:[INT13X_DAP_Transfer+2], cx  ; Fill out Transfer Adress
        ;~ mov     wptr cs:[INT13X_DAP_Absolute+0], ax
        ;~ mov     wptr cs:[INT13X_DAP_Absolute+2], bx  ; Fill out Absolute Sector
        ;~ push    cs
        ;~ pop     ds
        ;~ mov     si, offset [INT13X_DAP]
        ;~ mov     ah, 42h                              ; Extended Read
        ;~ int     13h
        ;~ pop     cx
        ;~ jnc     DIOLS_Success

        ; Sector load failed...
        ;~ jmp     DriveIO_GotLoadError

    DIOLS_Success:

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'sector loaded'
        PUSHRF
            ;~ call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpSector
            mov     cx, 32
        @@:
            call    AuxIO_DumpParagraph
            call    AuxIO_TeletypeNL
            add     si, 16
            loop @B
        POPRF
        ENDIF
ENDIF
        ret
DriveIO_LoadSector      EndP


;##############################################################################
;# ACTION   : Loads the Master Boot Record from the specified drive into buffer
;# ----------------------------------------------------------------------------
;# EFFECTS  : Modifies DAP structure and fills or clears transfer buffer
;# ----------------------------------------------------------------------------
;# IN       : DL     - BIOS disk number (80h,81h,etc)
;#          : SI     - Pointer to transfer buffer
;# ----------------------------------------------------------------------------
;# OUT      : CF=1   - failure
;#          : AL.0   - MBR signature present
;#          : AL.1   - Primary partitions present
;#          : AL.2   - Extended partitions present
;#          : AL.3   - AiR-BOOT signature present
;#          : AL.4:7 - Reserved, returned as 0
;#          : AH.0:7 - Reserved, returned as 0
;##############################################################################
DriveIO_LoadMBR     Proc Near uses bx cx dx si di

        ; Always clear the transfer buffer first
        call    ClearSectorBuffer

        ; Assume an invalid MBR
        xor     ax, ax

        ; Accept only valid harddisks
        call    DriveIO_IsValidHarddisk
        jc      DriveIO_LoadMBR_exit

        ; Save the address of the transfer buffer
        mov     di, si

        ; Read the MBR from disk
        xor     ax, ax                  ; LBA low
        xor     bx, bx                  ; LBA high
        xor     dh, dh                  ; Head 0
        mov     cx, 1                   ; Sector 1
        call    DriveIO_LoadSector      ; Read the sector from disk

        ; Check the loaded MBR for a signature
        xor     ax, ax                  ; Assume an invalid MBR
        mov     dx, [si+LocBR_Magic]    ; Get word from MBR signature location
        cmp     dx, 0aa55h              ; Is it the magic value ?
        jne     DriveIO_LoadMBR_exit    ; Nope, no need to test anything else

        ; Indicate we have a MBR signature
        or      al, 01h

        ; Advance to the partition table
        add     si, 01beh

        ; Total of 4 entries to check
        mov     cx, 4

    DriveIO_LoadMBR_next_entry:
        mov     dl, [si+LocBRPT_SystemID]   ; Get partition-type / system-id
        add     si, 10h                     ; Point to next entry
        test    dl, dl                      ; Nothing in this one ?
        loopz   DriveIO_LoadMBR_next_entry  ; Then check next entry

        ; All entries checked and last one was also empty, we're done
        jz      DriveIO_LoadMBR_check_ab

        ; Found a non-empty entry, set bits according to its type
        cmp     dl, 05h                     ; Old style extended container ?
        jne     @F                          ; Nope...
        or      al, 04h                     ; Yep, mark ext. container present
    @@: cmp     dl, 0fh                     ; New style extended container ?
        jne     @F                          ; Nope...
        or      al, 04h                     ; Yep, mark ext. container present
    @@: or      al, 02h                     ; Then is must be a primary
        jcxz    DriveIO_LoadMBR_check_ab    ; CX=0? Then all entries processed,
        jmp     DriveIO_LoadMBR_next_entry  ; otherwise check next entry

        ; Check if an AiR-BOOT signature is present
    DriveIO_LoadMBR_check_ab:
        mov     si, offset [MBR_ABSig]      ; Offset of AiR-BOOT signature
        inc     di                          ; Advance buffer pointer
        inc     di                          ; to AiR-BOOT signature location
        mov     cx, 7                       ; Length of AiR-BOOT signature
        cld                                 ; Direction upwards
        repe    cmpsb                       ; Compare 7 bytes
        jne     DriveIO_LoadMBR_exit        ; Nope, no AiR-BOOT on this disk
        or      al, 08h                     ; Yep, AiR-BOOT is on this disk
        ;~ jmp     DriveIO_LoadMBR_exit

    DriveIO_LoadMBR_exit:
        ret
DriveIO_LoadMBR     EndP


;##############################################################################
;# ACTION   : Reads a sector from disk using INT13 extensions
;# ----------------------------------------------------------------------------
;# EFFECTS  : Modifies DAP structure and fills transfer buffer
;# ----------------------------------------------------------------------------
;# IN       : BX:AX - LBA address of sector
;#          : DI:SI - SEG:OFF of transfer buffer
;# ----------------------------------------------------------------------------
;# OUT      : CF=1  - failure
;##############################################################################
DriveIO_ReadSectorLBA       Proc Near

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_ReadSectorLBA:'
        PUSHRF
            call    DEBUG_DumpRegisters
            call    AuxIO_DumpParagraph
            call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        ; Push all registers
        pusha
        push    ds
        push    es

        ; One sector to read
        mov     cs:[INT13X_DAP_NumBlocks], 1

        ; Setup transfer address
        mov     wptr cs:[INT13X_DAP_Transfer+0], si     ; offset
        mov     wptr cs:[INT13X_DAP_Transfer+2], di     ; segment

        ; Setup LBA64 address of requested sector
        mov     wptr cs:[INT13X_DAP_Absolute+0], ax     ; low word lower part
        mov     wptr cs:[INT13X_DAP_Absolute+2], bx     ; high word lower part
        mov     wptr cs:[INT13X_DAP_Absolute+4], 0      ; low word upper part
        mov     wptr cs:[INT13X_DAP_Absolute+6], 0      ; high word upper part

        ; Address of packet
        mov     si, offset [INT13X_DAP]                 ; disk address packet

        ; Do the extended read
        mov     ah, 42h                                 ; read function
        int     13h                                     ; transfer to bios

        ; Error occured
        jc      DriveIO_ReadSectorLBA_exit

        ; AH should also be zero
        test    ah, ah
        stc
        jnz     DriveIO_ReadSectorLBA_exit

        ; Disk read succeeded, clear CF
        clc

    DriveIO_ReadSectorLBA_exit:

        ; Pop all registers
        pop     es
        pop     ds
        popa

        ret
DriveIO_ReadSectorLBA       EndP



;##############################################################################
;# ACTION   : Writes a sector to disk using INT13 extensions
;# ----------------------------------------------------------------------------
;# EFFECTS  : Modifies DAP structure and mofifies the disk
;# ----------------------------------------------------------------------------
;# IN       : BX:AX - LBA address of sector
;#          : DI:SI - SEG:OFF of transfer buffer
;# ----------------------------------------------------------------------------
;# OUT      : CF=1  - failure
;##############################################################################
DriveIO_WriteSectorLBA      Proc Near

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_WriteSectorLBA:'
        PUSHRF
            call    DEBUG_DumpRegisters
            call    AuxIO_DumpParagraph
            call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        ; Push all registers
        pusha
        push    ds
        push    es

        ; One sector to read
        mov     cs:[INT13X_DAP_NumBlocks], 1

        ; Setup transfer address
        mov     wptr cs:[INT13X_DAP_Transfer+0], si     ; offset
        mov     wptr cs:[INT13X_DAP_Transfer+2], di     ; segment

        ; Setup LBA64 address of requested sector
        mov     wptr cs:[INT13X_DAP_Absolute+0], ax     ; low word lower part
        mov     wptr cs:[INT13X_DAP_Absolute+2], bx     ; high word lower part
        mov     wptr cs:[INT13X_DAP_Absolute+4], 0      ; low word upper part
        mov     wptr cs:[INT13X_DAP_Absolute+6], 0      ; high word upper part

        ; Address of packet
        mov     si, offset [INT13X_DAP]                 ; disk address packet

        ; Do the extended write
        xor     al, al                                  ; no write verify
        mov     ah, 43h                                 ; write function
        int     13h                                     ; transfer to bios

        ; Error occured
        jc      DriveIO_WriteSectorLBA_exit

        ; AH should also be zero
        test    ah, ah
        stc
        jnz     DriveIO_WriteSectorLBA_exit

        ; Disk write succeeded, clear CF
        clc

    DriveIO_WriteSectorLBA_exit:

        ; Pop all registers
        pop     es
        pop     ds
        popa

        ret
DriveIO_WriteSectorLBA      EndP




;##############################################################################
;# The Master LVM sector is *not* necessarily located at the end of the BIOS
;# view of TRACK0. Its location depends on the *OS/2 geometry* active when the
;# disk was partitioned. For disks < 502MiB this will most likely be LBA sector
;# 62, but for disks >502MiB, *extended* OS/2 geometry was used and DANIS506
;# uses SPT=127 for disks < 1TiB while IBMS506 uses  SPT=255.
;# When a huge disk < 1TiB was partitioned with IBMS506, thus using SPT=255,
;# and the driver was later changed to DANIS506, DANI uses SPT=255, eventhough
;# the disk < 1TiB. Whether it is DANI that is LVM aware or something else
;# (maybe LVM itself) that makes DANI use the correct geometry has yet to be
;# investigated.
;#
;# Related geometry issues are also present with USB sticks, which can get
;# assigned a geometry by OS/2, which can depend if the stick was partitioned
;# on foreign systems or not, or even OS/2 manufacturing a geometry that is not
;# the same as the BIOS reports to us here. In both cases, fixed disks and
;# removable disks, the geometry recorded in the BPB of a partition can also
;# influence the geometry that OS/2 assigns. This is the case when 'preparing'
;# disks for LVM use, in which case BPB values could be incorporated.
;#
;# What this all boils down to, is that the geometry reported by the BIOS is
;# of no practical use, especially not when taking BIOS USB MSD emulation into
;# account. These are among the reasons why AirBoot needs to use LBA addressing
;# when handling LVM stuff and why LBA use cannot be disabled in the SETUP
;# anymore.
;#
;# So, a Master LVM sector can be present on any sector from LBA 254 downwards
;# and the only way to locate the correct one is to scan all the way down and,
;# if one is found, do proper validation on its values, because it may also be
;# a 'phantom' LVM sector left over from previous partition layouts.
;# Most of such 'phantoms' can be filtered out by verifying the location of
;# the found sector against the OS/2 geometry it specifies itself, which means
;# it must be located at the LBA of the SPT-1 it specifies.
;##############################################################################
;# ACTION   : Locates the Master LVM sector on the specified disk
;# ----------------------------------------------------------------------------
;# EFFECTS  : Leaves [Scratch] with last sector read or cleared
;# ----------------------------------------------------------------------------
;# IN       : DL    - BIOS disk number of drive to search
;# ----------------------------------------------------------------------------
;# OUT      : CF=1  - found
;#          : BX:AX - LBA address of LVM sector if found, 0 otherwise
;##############################################################################
DriveIO_LocateMasterLVMSector   Proc    Near    uses cx dx si di ds es

IFDEF   AUX_DEBUG
        IF 1
        DBG_TEXT_OUT_AUX    'DriveIO_LocateMasterLVMSector:'
        PUSHRF
            call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpSector
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        ; LBA address to start scanning down from
        mov     cx, 255

        ; Make sure ES==DS
        push    ds
        pop     es

        ; Because JCXZ is used, LBA sector 0 is never loaded and checked.
        ; This is of course no problem since it is the MBR.
    DriveIO_LocateMasterLVMSector_next:
        mov     si, offset [Scratch]    ; Use scratch area to load sectors
        call    ClearSectorBuffer       ; Clear the scratch area
        clc                             ; Indicate Master LVM sector not found
        jcxz    DriveIO_LocateMasterLVMSector_done

        ; Read the LBA sector specified in CX
        mov     ax, cx                  ; LBA low
        xor     bx, bx                  ; LBA high
        mov     di, ds                  ; Segment of scratch buffer
        mov     si, offset [Scratch]    ; Offset of scratch buffer
        call    DriveIO_ReadSectorLBA   ; Read the sector
        lahf                            ; Save CF
        dec     cx                      ; Prepare LBA of next sector to read
        sahf                            ; Restore CF
        ; No need to do any LVM sector validation when read error, read next
        jc      DriveIO_LocateMasterLVMSector_next

        ; See if the read sector has a valid signature and checksum
        call    LVM_ValidateSector

        ; NC indicates invalid or none-LVM sector, read next
        jnc     DriveIO_LocateMasterLVMSector_next

        ; We have found a valid LVM sector !
        ; So it contains the OS/2 geometry for the disk.
        ; That means this LVM sector itself must be located on the last sector
        ; of the SPT value its OS/2 geometery specifies, which, in LBA terms
        ; is LVM SPT-1 -- let's check that...
        mov     bx, offset [Scratch]            ; Offset of the loaded LVM sector
        mov     al, [bx+LocLVM_Secs]            ; Get the LVM SPT value (<=255)
        dec     al                              ; Adjust to LVM LBA
        mov     ah, cl                          ; Get next LVM LBA to search
        inc     ah                              ; This one was found here
        cmp     al, ah                          ; If same, LVM LBA location OK
        jne     DriveIO_LocateMasterLVMSector_next

        ; The LVM sector we found is at the location it should be on disk,
        ; so it's almost 99% sure this is the correct one.
        ; Now we should compare the start and sizes of the partitions in the
        ; MBR with the partitions specified in this LVM record.
        ; We'll implement that later after some more research.
        ; For now we assume this is the correct Master LVM sector for the disk.
        inc     cx      ; CX was prepared to read next, correct that
        stc             ; Indicate we have found the Master LVM sector

    DriveIO_LocateMasterLVMSector_done:
        mov     bx, 0   ; A Master LVM sector always has high LBA=0
        mov     ax, cx  ; Low LBA of Master LVM sector

        ; We leave it up to the caller to store the value in a proper place
        ret
DriveIO_LocateMasterLVMSector   EndP



;
; ############################################################
; # Check for a valid MBR-sector to be written to disk       #
; ############################################################
;
; In
; --
; DL     = Physical Disk
; BX:CX  = LBA sector
; DI:SI  = Source buffer
;
; Out
; ---
; CY     = 1 if invalid MBR in source buffer, 0 if valid
;
; This routine is called when DriveIO_SaveSector attempts to write to the MBR.
; It checks if the sector to be written has some sensible values in certain
; places. In fact, if the sector is written to the boot-disk, the AiR-BOOT
; signature should be present and the partition table should be the same
; as the one at the start of the AiR-BOOT code in memory, except maybe for the
; active flags.
; For other disks, only the active flags are checked to be 00h or 80h and
; the AA55h MBR signature.
;
DriveIO_ProtectMBR  Proc Near
        pusha           ; Push all registers
        push    es      ; Push ES because we need it for string instructions
        push    cs      ; Make ES point...
        pop     es      ; to CS

        ; Save the pointer to the sector to write in BX
        mov     bx,si

        ;
        ; If the sector to be written is not the boot-disk, then skip
        ; checking the AiR-BOOT MBR.
        ;
        cmp     dl, [BIOS_BootDisk]
        jne     DriveIO_ProtectMBR_is_not_bootdisk

        ;
        ; The boot-disk is accessed so the sector to be written must be
        ; the AiR-BOOT MBR. This is the same as the first 512 bytes
        ; relocated to 8000:0000 and this the start of the AB-code.
        ;
        mov     si,bx                       ; Get pointer to sector to write
        xor     di,di                       ; Point DI to start of AB-code (MBR)
        mov     cx, offset [MBR_PartTable]  ; Bytes upto P-table must be same
        cld                                 ; Compare upwards
        repe    cmpsb                       ; Compare upto P-table

        ; If not the same this is not the an AiR-BOOT boot-disk MBR !
        jne     DriveIO_ProtectMBR_not_valid_MBR            ; SEVERE ERROR !

        ; Continue with signature check
        jmp     DriveIO_ProtectMBR_check_signature


    ;
    ; The disk is not the boot-disk so we don't know what kind of MBR is on it.
    ; Some sanity checks should be here.
    ;
    DriveIO_ProtectMBR_is_not_bootdisk:

        ;
        ; sanity checks...
        ;

        ; Continue with signature check
        jmp     DriveIO_ProtectMBR_check_signature


    DriveIO_ProtectMBR_check_signature:
        ; See if the sector to write contains a valid signature
        mov     si,bx                   ; Get pointer to sector to write
        mov     di, offset [MBR_Sig]    ; Offset to MBR signature
        add     si,di                   ; Make SI point to it in sec to write
        lodsw                           ; Load it
        cmp     ax,0aa55h               ; See if it is valid

        ; If no signature this cannot be a valid MBR !
        jne     DriveIO_ProtectMBR_not_valid_MBR            ; SEVERE ERROR !


    ;
    ; The sector to be written seems to be valid.
    ; Set CY=0 to indicate a valid MBR.
    ;
    DriveIO_ProtectMBR_is_valid_MBR:
        clc
        jmp     DriveIO_ProtectMBR_end

    ;
    ; Something is terribly wrong; a non-MBR sector seems about to be written.
    ; Set CY=1 and let the calling code handle this situation.
    ;
    DriveIO_ProtectMBR_not_valid_MBR:
        stc
        jmp     DriveIO_ProtectMBR_end

    ;
    ; Return to the caller with no registers modyfied except FLAGS.
    ;
    DriveIO_ProtectMBR_end:
        pop     es
        popa
        ret
DriveIO_ProtectMBR  Endp



; #########################################################################
; Routine: Checks if the MBR is addressed by either CHS or LBA
; #########################################################################
; Calling : bx:ax - Absolute sector
;           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
; Returns : ZF=1 if MBR is addressed, else ZF=0
; Preserve: all registers
; #########################################################################
DriveIO_MBR_Addressed   Proc
        push    ax
        push    bx

        or      bx,ax   ; Results in 0 in BX if MBR is addressed by LBA
        jz      DriveIO_MBR_Addressed_done

        mov     ax,cx   ; Results in 1 in AX if CYL 0, SEC 1 is addressed
        add     al,dh   ; Results in 1 in AX if HEAD 0 is addressed
        dec     ax      ; Results in 0 in AX if MBR is addressed by CHS

    DriveIO_MBR_Addressed_done:
        pop     bx
        pop     ax
        ret
DriveIO_MBR_Addressed   EndP




; #########################################################################
; Routine: Writes DS:SI to a specified sector
; #########################################################################
; Calling : bx:ax - Absolute sector
;           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
;           ds:si - Source-Adress
; Returns : none
; Preserve: all registers
; #########################################################################
DriveIO_SaveSector              Proc Near  Uses ax bx cx dx ds si es di

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_SaveSector:'
        PUSHRF
            ;~ call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF


;!
;! DEBUG_BLOCK
;! Force write to LBA0 to test interception routine.
;! Do *NOT* enable unless you are debugging, will overwrite MBR !
;!
IFDEF   AUX_DEBUG
    IF 0
    pushf
    pusha
        xor ax,ax
        xor bx,bx
        xor cx,cx
        inc cx
        xor dh,dh
    popa
    popf
    ENDIF
ENDIF

        ;
        ; Check if the MBR is the destination for the write.
        ; ZF=1 if so.
        ;
        call    DriveIO_MBR_Addressed
        jnz     DriveIO_SaveSector_continue_write


        ; MBR is addressed, check the sector that is requested to be written.
        ; For the bootdisk it should contain the AiR-BOOT signature, valid
        ; partition-table entries and the AA55h signature.
        ; If not, something is terribly wrong in some piece of the AB code.
        ; For any other disk (80h+) at least a valid partition table should
        ; be present together with the AA55h signature.
        call    DriveIO_ProtectMBR
        jnc     DriveIO_SaveSector_continue_write


        ;
        ; WE HAVE A SEVERE ERROR CONDITION !
        ; SOME AB CODE TRIES TO WRITE A NON-MBR TO THE DISK !
        ; ASK THE USER TO REPORT THIS !
        ; HALT THE SYSTEM !
        ;

        ; Show error-box
        mov     cx, 0C04h
        mov     si, offset NonMBRwrite
        call    SETUP_ShowErrorBox
        mov     cx, 0C04h
        mov     si, offset NonMBRwrite_rep
        call    SETUP_ShowErrorBox


IFDEF   AUX_DEBUG
    IF 0
    pushf
    pusha
        mov     si, offset [NonMBRwrite]
        call    AuxIO_TeletypeNL
        call    AuxIO_Print
        call    AuxIO_TeletypeNL
    popa
    popf
    ENDIF
ENDIF

        ; Show popup and halt the system.
        jmp    HaltSystem



    ;
    ; Continue the write if not MBR sector or MBR to write is validated.
    ;
    DriveIO_SaveSector_continue_write:
        test    byte ptr cs:[CurIO_UseExtension], 1
        jz      DIOSS_UseNormal
        ; Are we forced do use LBA via Setting?
        ; Always use INT13X on v1.0.8+.
        ;~ test    byte ptr cs:[CFG_ForceLBAUsage], 1
        ;~ jnz     DIOSS_UseExtension
        jmp     DIOSS_UseExtension
        ; Is the drive not a harddrive?
        cmp     dl, 80h
        jb      DIOSS_UseNormal
        ; Upper 8 bits of LBA-address set? -> Use LBA (maximum boundary is FB0400h)
        or      bh, bh
        jnz     DIOSS_UseExtension
        ; Compare Switch-Table value to bit 16-23 of LBA-address
        mov     di, dx
        and     di, 007Fh
        cmp     bptr cs:[LBASwitchTable+di], bl
        jbe     DIOSS_UseExtension

    DIOSS_UseNormal:

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_WriteSectorCHS:'
        PUSHRF
            call    DEBUG_DumpRegisters
            call    AuxIO_DumpParagraph
            call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        mov     di, 3                      ; retry count
    DIOSS_ErrorLoop:
        push    ds
        pop     es
        mov     bx, si                     ; ES:BX - Destination
        mov     ax, 0301h                  ; Function 3 - Write Sector
        int     13h
        jnc     DIOSS_Success
        dec     di                         ; decrement retry count
        jnz     DIOSS_ErrorLoop
        call    MBR_SaveError

    DIOSS_UseExtension:

        mov     di, ds                  ; segment for transfer address
        call    DriveIO_WriteSectorLBA  ; extended write
        jc      MBR_SaveError           ; halt on error

        ;~ push    cx
        ;~ mov     cs:[INT13X_DAP_NumBlocks], 1         ; Copy ONE sector
        ;~ mov     wptr cs:[INT13X_DAP_Transfer+0], si
        ;~ mov     cx, ds
        ;~ mov     wptr cs:[INT13X_DAP_Transfer+2], cx  ; Fill out Transfer Adress
        ;~ mov     wptr cs:[INT13X_DAP_Absolute+0], ax
        ;~ mov     wptr cs:[INT13X_DAP_Absolute+2], bx  ; Fill out Absolute Sector
        ;~ push    cs
        ;~ pop     ds
        ;~ mov     si, offset [INT13X_DAP]
        ;~ mov     ax, 4300h                            ; Extended Write (No Verify)
        ;~ int     13h
        ;~ pop     cx
        ;~ jnc     DIOSS_Success
        ;~ call    MBR_SaveError

    DIOSS_Success:
        ret
DriveIO_SaveSector              EndP




;##############################################################################
;# When a disk has a Master LVM sector, it means it has been prepared for use
;# by OS/2 and contains important information about how OS/2 views its geometry
;# and other disk related properties. This function assumes the LBA address
;# of the Master LVM sector has already been located and simply loads the
;# sector into [LVMSector].
;#
;# Note that because this is an operation similar to the regular loading of
;# sectors, the disk I/O semantics are used here. This means CF=0 when an LVM
;# sector is successfully loaded and CF=1 otherwise.
;##############################################################################
;# ACTION   : Loads the Master LVM sector if one exists
;# ----------------------------------------------------------------------------
;# EFFECTS  : Modifies DAP structure and [LVMSector]
;# ----------------------------------------------------------------------------
;# IN       : DL     - BIOS disk number (80h,81h,etc)
;# ----------------------------------------------------------------------------
;# OUT      : CF=0   - Valid Master LVM sector found and loaded
;##############################################################################
DriveIO_LoadMasterLVMSector     Proc  Near

IFDEF   AUX_DEBUG
        IF 0
        DBG_TEXT_OUT_AUX    'DriveIO_LoadMasterLVMSector:'
        PUSHRF
            ;~ call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        ; Save all registers
        pusha

        ; Check if BIOS disk number is valid
        call    DriveIO_IsValidHarddisk
        jc      DriveIO_LoadMasterLVMSector_error

        ; Calculate the entry in the DISKINFO array for this disk
        call    DriveIO_CalcDiskInfoPointer

        ; Save the entry for later recalls
        mov     bp, bx

        ; Get the LBA address of the Master LVM sector
        mov     ax, [bx+LocDISKINFO_LVM_MasterLBA+00h]
        mov     bx, [bx+LocDISKINFO_LVM_MasterLBA+02h]

        ; LBA of Master LVM sector cannot be 0, so none was found during
        ; the gathering of disk information.
        mov     cx, ax
        or      cx, bx
        jz      DriveIO_LoadMasterLVMSector_error

        ; Load it into [LVMSector]
        mov     di, ds
        mov     si, offset [LVMSector]
        call    DriveIO_ReadSectorLBA
        jc      DriveIO_LoadMasterLVMSector_error

        ; Validate the Master LVM sector
        call    LVM_ValidateSector

        ; Complement success indicator to conform to semantics of this function
        cmc

        ; Master LVM sector was valid and is now loaded in [LVMSector]
        jnc     DriveIO_LoadMasterLVMSector_ret

    DriveIO_LoadMasterLVMSector_error:

        ; Clear the sector buffer for safety reasons
        mov     si, offset [LVMSector]
        call    ClearSectorBuffer

        ; Indicate no Master LVM sector loaded
        stc

    DriveIO_LoadMasterLVMSector_ret:

        ; Restore all registers
        popa

        ret
DriveIO_LoadMasterLVMSector     Endp




;##############################################################################
;# There is much information to know about the connected disks.
;# We also want this information clustered per disk and available before
;# further disk and partition scanning takes place.
;# This function gathers such information like INT13, INT13X, MBR, LVM, more.
;# Especially important is the LVM information, because that contains the
;# geometry OS/2 uses to access the disk. Other important information is the
;# presence of valid MBRs, logical partitions and whatnot.
;# This function gathers such information and stores it in a DISKINFO structure
;# for which an instance exists for every disk found.
;##############################################################################
;# ACTION   : Gather disk information and store this in the BSS
;# ----------------------------------------------------------------------------
;# EFFECTS  : Modifies DAP structure and the buffers it uses, fills DISKINFO[n]
;# ----------------------------------------------------------------------------
;# IN       : DL     - BIOS disk number (80h,81h,etc)
;# ----------------------------------------------------------------------------
;# OUT      : CF=1   - failure
;##############################################################################
DriveIO_GatherDiskInfo  Proc Near

IFDEF   AUX_DEBUG
        IF 1
        DBG_TEXT_OUT_AUX    'DriveIO_GatherDiskInfo:'
        PUSHRF
            call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
        POPRF
        ENDIF
ENDIF

        ; Push all registers we use
        pusha
        push    ds
        push    es

        ; Make sure ES=DS
        push    ds
        pop     es

        ; Check if BIOS disk number is valid
        call    DriveIO_IsValidHarddisk
        jc      DriveIO_GatherDiskInfo_error

        ; Calculate the entry in the DISKINFO array for this disk
        call    DriveIO_CalcDiskInfoPointer

        ; Save the entry for later recalls
        mov     bp, bx

        ; Store the BIOS disk number in the structure
        mov     [bx+LocDISKINFO_DiskNum], dl

; ------------------------------------------------------------------- [ INT13 ]

        ; Get BIOS Disk Parameters (legacy method)
        mov     ah, 08h                         ; Get Disk Parameters
        int     13h                             ; Call BIOS

        ; CF=1 or AH!=0 indicates error
        jc      DriveIO_GatherDiskInfo_error
        test    ah, ah
        jnz     DriveIO_GatherDiskInfo_error

        ; Recall DISKINFO entry
        mov     bx, bp

        ; Store SPT (WORD)
        xor     ah, ah                          ; Zero extend SPT to 16 bits
        mov     al, cl                          ; Hi 2 bits max cyl and max sec
        and     al, 3fh                         ; Mask max sec (1-based)
        mov     [bx+LocDISKINFO_I13_Secs], ax   ; Store SPT

        ; Store HEADS (WORD)
        xor     dl, dl                          ; Zero extend HEADS to 16 bits
        xchg    dl, dh                          ; Get max head (0-based)
        inc     dx                              ; Head count
        mov     [bx+LocDISKINFO_I13_Heads], dx  ; Store HEADS

        ; Store CYLS (WORD)
        shr     cl, 6                           ; Hi 2 bits of max cyl to 1:0
        xchg    cl, ch                          ; Max cyl (0-based)
        inc     cx                              ; Cyl count
        mov     [bx+LocDISKINFO_I13_Cyls], cx   ; Store CYLS

        ; Recall BIOS disk number
        mov     dl, [bx+LocDISKINFO_DiskNum]

; ------------------------------------------------------------------ [ INT13X ]

        ; Get BIOS Disk Parameters (extended method)
        mov     si, offset [Scratch]            ; Buffer to return disk info
        mov     ax, 80h                         ; Size of buffer
        mov     [si], ax                        ; Store it in first word
        mov     ah, 48h                         ; Get Extended Disk Parameters
        int     13h                             ; Call BIOS

        ; CF=1 or AH!=0 indicates error
        jc      DriveIO_GatherDiskInfo_error
        test    ah, ah
        jnz     DriveIO_GatherDiskInfo_error

        ; Store flags (WORD)
        cld                                         ; Direction up
        lodsw                                       ; Buffersize, discard
        lodsw                                       ; Flags (CHS valid etc)
        mov     [bx+LocDISKINFO_I13X_Flags], ax     ; Store them

        ; Store CYLS (DWORD)
        lodsw                                       ; Cyl count low
        mov     [bx+LocDISKINFO_I13X_Cyls+00h], ax  ; Store CYLS low
        lodsw                                       ; Cyl count high
        mov     [bx+LocDISKINFO_I13X_Cyls+02h], ax  ; Store CYLS high

        ; Store HEADS (DWORD)
        lodsw                                       ; Head count low
        mov     [bx+LocDISKINFO_I13X_Heads+00h], ax ; Store HEADS low
        lodsw                                       ; Head count high
        mov     [bx+LocDISKINFO_I13X_Heads+02h], ax ; Store HEADS high

        ; Store SPT (DWORD)
        lodsw                                       ; Secs per track low
        mov     [bx+LocDISKINFO_I13X_Secs+00h], ax  ; Store SPT low
        lodsw                                       ; Secs per track high
        mov     [bx+LocDISKINFO_I13X_Secs+02h], ax  ; Store SPT high

        ; Store total LBA sectors (QWORD)
        lea     di, [bx+LocDISKINFO_I13X_SecsLBA]
        mov     cx, 4
        rep     movsw

        ; Store sector size (WORD)
        lodsw
        mov     [bx+LocDISKINFO_I13X_SecSize], ax

        ; Store bus name (4 bytes, space padded, v3.0+)
        lea     si, [Scratch+24h]
        lea     di, [bx+LocDISKINFO_I13X_HostBus]
        movsw
        movsw

        ; Store interface name (8 bytes, space padded, v3.0+)
        lea     di, [bx+LocDISKINFO_I13X_Interface]
        mov     cx, 4
        rep     movsw

        ; Should gather some more INT13X info here,
        ; like maybe Advanced Format stuff or so.
        ; We'll investigate that at a later time.

; --------------------------------------------------------------------- [ MBR ]

        ; Load the MBR
        mov     si, offset [TmpSector]
        call    DriveIO_LoadMBR

        ; Store MBR flags (valid sig, partitions present, airboot installed)
        mov     [bx+LocDISKINFO_MbrFlags], al

        ; Recall BIOS disk number
        mov     dl, [bx+LocDISKINFO_DiskNum]

; --------------------------------------------------------------------- [ LVM ]

        ; Locate the Master LVM sector, if any
        call    DriveIO_LocateMasterLVMSector

        ; Save Master LVM sector LBA high
        mov     cx, bx

        ; Recall DISKINFO entry
        mov     bx, bp

        ; Store Master LVM sector LBA
        mov     [bx+LocDISKINFO_LVM_MasterLBA+00h], ax
        mov     [bx+LocDISKINFO_LVM_MasterLBA+02h], cx

        ; No Master LVM sector found, so skip storing LVM info for this disk
        jnc     DriveIO_GatherDiskInfo_no_master_lvm

        ; Load the Master LVM sector into [LVMSector]
        call    DriveIO_LoadMasterLVMSector

        ; No valid Master LVM sector, so skip storing LVM info for this disk
        jc      DriveIO_GatherDiskInfo_no_master_lvm

        ; A valid Master LVM sector has been loaded into [LVMSector]
        mov     si, offset [LVMSector]

        ; Get the number of sectors per track (OS/2 geometry)
        mov     ax, [si+LocLVM_Secs+00h]
        mov     cx, [si+LocLVM_Secs+02h]

        ; Store it
        mov     [bx+LocDISKINFO_LVM_Secs+00h], ax
        mov     [bx+LocDISKINFO_LVM_Secs+02h], cx

        ; Get the number of heads (OS/2 geometry)
        mov     ax, [si+LocLVM_Heads+00h]
        mov     cx, [si+LocLVM_Heads+02h]

        ; Store it
        mov     [bx+LocDISKINFO_LVM_Heads+00h], ax
        mov     [bx+LocDISKINFO_LVM_Heads+02h], cx

        ; Should gather some more LVM info here,
        ; like OS/2 extended geometry and other flags.
        ; We'll implement that at a later time.

    DriveIO_GatherDiskInfo_no_master_lvm:

        ; When no Master LVM sector was found,
        ; the LVM info in the DISKINFO structure for the disk
        ; will be ZERO because the area was cleared in PRECRAP.

        ; Indicate success
        clc

        jmp     DriveIO_GatherDiskInfo_ret

    DriveIO_GatherDiskInfo_error:
        stc
    DriveIO_GatherDiskInfo_ret:


IFDEF   AUX_DEBUG
        IF 1
        DBG_TEXT_OUT_AUX    '[DISKINFO]'
        PUSHRF
            call    DEBUG_DumpRegisters
            ;~ call    AuxIO_DumpParagraph
            ;~ call    AuxIO_TeletypeNL
            mov     si, bp
            mov     cx, 4
        @@:
            call    AuxIO_DumpParagraph
            call    AuxIO_TeletypeNL
            add     si, 16
            loop @B
            mov     si, offset [Scratch]
            mov     cx, 4
        @@:
            call    AuxIO_DumpParagraph
            call    AuxIO_TeletypeNL
            add     si, 16
            loop @B
            mov     si, offset [LVMSector]
            mov     cx, 7
        @@:
            call    AuxIO_DumpParagraph
            call    AuxIO_TeletypeNL
            add     si, 16
            loop @B
        POPRF
        ENDIF
ENDIF

        ; Restore registers
        pop     es
        pop     ds
        popa

        ret
DriveIO_GatherDiskInfo  EndP

;------------------------------------------------------------------------------
; Calculate pointer to entry in DISKINFO structure
;------------------------------------------------------------------------------
; IN    : DL BIOS disk number (80h etc)
; OUT   : BX Pointer to entry
; NOTE  : BIOS disk number must be valid
;------------------------------------------------------------------------------
DriveIO_CalcDiskInfoPointer Proc    Near
        xchg    bx, ax                          ; AX is used for calculation
        mov     al, DISKINFO_Size               ; Size of DISKINFO structure
        mov     ah, dl                          ; BIOS disk number
        sub     ah, 80h                         ; Now 0-based index
        mul     ah                              ; Now offset into DISKINFO array
        add     ax, offset [DiskInformation]    ; Base of DISKINFO array
        xchg    bx, ax                          ; BX now points to entry for disk
        ret
DriveIO_CalcDiskInfoPointer EndP

;------------------------------------------------------------------------------
; Check if the BIOS disk number in DL is a harddisk and in range
;------------------------------------------------------------------------------
; IN    : DL BIOS disk number (80h etc)
; OUT   : CF=1 if invalid disk number or out of range
; NOTE  : Only modifies flags
;------------------------------------------------------------------------------
DriveIO_IsValidHarddisk     Proc    Near    Uses dx
        cmp     dl, 80h                 ; BIOS disk number must be at least 80h
        jb      @F                      ; Not a harddisk, exit with CY
        mov     dh, dl                  ; Save to do compare
        sub     dh, 80h                 ; Now 0 based disk number
        inc     dh                      ; Now 1 based disk number
        cmp     [TotalHarddiscs], dh    ; Out of range, exit with CY
    @@: ret
DriveIO_IsValidHarddisk     EndP


; Values for sectors per track table corresponding to DriveIO_IsHugeDrive return value.
;~ secs_per_track_table    db    63,127,255,255,255,255

;~ db_lmlvm    db 'Load Master LVM -- disk: ',0
