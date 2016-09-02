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

; Note: Some routines set DS/ES to CS or even address via CS, even if its not
;        needed. This was done for SECURITY. So DO NOT remove it.
;        Its there to make sure the correct data is loaded/written to/from
;        harddrive.
;
;  IF YOU MODIFY ANYTHING IN HERE, YOU MAY EASILY BREAK YOUR HARDDRIVE!

; Will only load base-configuration, will NOT load IPT nor Hide-Config
;  Those are originally loaded on startup and will NOT get reloaded.
DriveIO_LoadConfiguration   Proc Near   Uses ax bx cx dx es
        mov     ax, cs
        mov     es, ax
        mov     bx, offset Configuration
        mov     dx, 0080h                     ; First harddrive, Sector 55...
        mov     cx, 0037h
        mov     ax, 0201h                     ; Function 02, read 1 sector...
        int     13h
        jnc     DIOLC_NoError
        call    MBR_LoadError                 ; Will Abort BootUp
    DIOLC_NoError:
        ret
DriveIO_LoadConfiguration   EndP

DriveIO_SaveConfiguration   Proc Near   Uses ax bx cx dx ds es si
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
        mov     dx, 0080h                     ; First harddrive, Sector 55...
        mov     cx, 0037h

        ; Changed from 5 to calculated value
        ; Fixes issue: #2987 -- "air-boot doesn't remember drive letter"
        ; Size of the ab-configuration in 512 byte sectors
        mov     al, (MBR_BackUpMBR - Configuration) / 200h
        mov     ah,03h

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
        mov     dl, 80h
    DIOILUT_DriveLoop:
        push    dx
        push    di
        mov     ah, 08h
        int     13h            ; DISK - GET DRIVE PARAMETERS
        mov     ah, 0FBh       ; Assume 255 heads/63 sectors, if error
        jc      DIOILUT_Error
        and     cl, 111111b    ; Isolate lower 6 bits of CL -> sector count

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
        inc     dl
        dec     dh
        jnz     DIOILUT_DriveLoop
        ret
DriveIO_InitLBASwitchTable  EndP




;FIXME: Only LBA gets updated, need to update CHS too !!!!!!!

; Adjusts BX:AX / CX:DX to meet LVM sector location
; BX:AX / CX:DX point to MBR or EBR !
;  Destroys SI
; Rousseau: Enhanced to handle sector-numbers 127 and 255 besides 63 for LVM-info sectors.
;           Ugly, need to cleanup.
DriveIO_LVMAdjustToInfoSector   Proc Near
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
        ret


;;jmp bliep
;;        pusha

;;            push     dx
;;            push     bx
;;                xor      dh,dh
;;                and      dl,01111111b
;;                shl      dx,1
;;                shl      dx,1
;;                mov      bx, offset [TrueSecs]
;;                add      bx,dx
;;                mov      ax,word ptr [bx]
;;            pop      bx
;;            pop      dx


            ;
            ; AX now contains LVM secs
            ;


;;            pusha
;;                push    dx
;;                ; Location of extended position
;;                mov     dx,word ptr [ExtendedAbsPos+02]
;;                mov     ax,word ptr [ExtendedAbsPos+00]
;;                ;call    AuxIO_TeletypeHexDWord
;;                ;call    AuxIO_TeletypeNL
;;                pop     dx

;;                xor     dh,dh
;;                and     dl,01111111b
;;                shl     dx,1
;;                shl     dx,1
;;                mov     bx, offset [TrueSecs]
;;                add     bx,dx
;;                mov     ax, word ptr[bx]

                ;call    AuxIO_TeletypeHexWord
                ;call    AuxIO_TeletypeNL
;;                mov     al,[ExtendedAbsPosSet]           ; if true -> 1st sector of extpart (EBR), not logpart(BPB)
                ;call    AuxIO_TeletypeHexByte
                ;call    AuxIO_TeletypeNL
                ;mov     si,offset PartitionSector
                ;call    AuxIO_DumpSector
;;            popa

            ; LBA
            ;mov     si,offset before_lvm_adjust
            ;call    AuxIO_Print

            ;xchg    dx,bx
            ;call    AuxIO_TeletypeHexDWord
            ;call    AuxIO_TeletypeNL
            ;xchg    bx,dx
;;        popa


;;bliep:

      ;or       bx,ax
;;      test     byte ptr [ExtendedAbsPosSet],1
;;      jz       pri


;;        push     dx
;;        push     bx

;;            xor      dh,dh
;;            and      dl,01111111b           ; Strip high bit from disk
;;            shl      dx,1                   ; Convert to index
;;            shl      dx,1                   ; into TrueSecs table
;;            mov      bx,offset [TrueSecs]   ; Base of table
;;            add      bx,dx                  ; Point to entry for disk
;;            mov      dx,[bx]                ; Get TrueSecs (LVM)
;;            dec      dx
;;            add      ax,dx

;;        pop      bx
;;        pop      dx
;;        adc      bx,0


;;        jmp      done



;;    pri:


;;        push    ax
;;        push    cx
;;            xor     ch, ch                           ; Zero out upper-byte

;;            push    dx
;;                xor     dh,dh
;;                and     dl,01111111b
;;                shl     dx,1
;;                shl     dx,1

;;                push    bx
;;                    mov     bx,offset [TrueSecs]
;;                    add     bx,dx
;;                    mov     ax,[bx]
                    ;mov     [ts2],ax
;;                pop     bx
;;            pop     dx



            ;~ mov     al, 63
            ;~ call    VideoIO_PrintByteDynamicNumber
            ;~ self:   jmp self



            ; DEZE WERKT SOMS NIET GOED
            ; ROMMELT MET CYLINDERS
            ; ALLEEN TOEPASSEN ALS INT13X NIET ACTIEF !

;;            and     cl, al                           ; Isolate lower bits, because upper
;;            mov     ah, 0
;;            mov     si, ax                           ;  ones may be used for cylinder
;;            sub     si, cx

;;        pop     cx
;;        pop     ax

;;        or      cl, al                           ; Set sector to last sector
;;        add     ax, si                           ; Adjust lower LBA
;;        adc     bx, 0                            ; Adjust LBA Sector (BX:AX)



        ;~ push    ax
        ;~ call    AuxIO_TeletypeHexWord
        ;~ call    AuxIO_TeletypeNL
        ;~ mov     ax,[ts]
        ;~ call    AuxIO_TeletypeHexWord
        ;~ call    AuxIO_TeletypeNL
        ;~ mov     ax,[ts2]
        ;~ call    AuxIO_TeletypeHexWord
        ;~ call    AuxIO_TeletypeNL
        ;~ pop     ax

        ;~ and      ax,[ts]

;;      jmp done



;;    done:

        ;pusha
            ;mov     si,offset after_lvm_adjust
            ;~ call    AuxIO_Print
            ; LBA
            ;xchg    dx,bx
            ;~ call    AuxIO_TeletypeHexDWord
            ;~ call    AuxIO_TeletypeNL
            ;xchg    bx,dx
        ;popa

        ;~ pusha
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ ; CYL
        ;~ mov     al,ch
        ;~ call    AuxIO_TeletypeHexByte
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ ; HEAD
        ;~ mov     al,dh
        ;~ call    AuxIO_TeletypeHexByte
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ ; SEC
        ;~ mov     al,cl
        ;~ call    AuxIO_TeletypeHexByte
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ ; DRIVE
        ;~ mov     al,dl
        ;~ call    AuxIO_TeletypeHexByte
        ;~ call    AuxIO_TeletypeNL
        ;~ popa

;;      ret
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
        mov     wptr cs:[CurPartition_Location+0], ax
        mov     wptr cs:[CurPartition_Location+2], bx
        mov     wptr cs:[CurPartition_Location+4], dx
        mov     wptr cs:[CurPartition_Location+6], cx ; Saves the location
        mov     si, offset PartitionSector    ; DS:SI - ExecBase
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

    IFDEF   AUX_DEBUG
        ; show current partition location
        ;~ pushf
        ;~ pusha
        ;~ call     AuxIO_TeletypeNL
        ;~ mov      si,offset db_curpartloc
        ;~ call     AuxIO_Print
        ;~ mov      dx,word ptr [CurPartition_Location+02]
        ;~ mov      ax,word ptr [CurPartition_Location+00]
        ;~ call     AuxIO_TeletypeHexDWord
        ;~ call     AuxIO_TeletypeNL
        ;~ mov      si,offset PartitionSector
        ;~ call     AuxIO_DumpSector
        ;~ call     AuxIO_TeletypeNL
        ;~ popa
        ;~ popf
    ENDIF

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
        test    byte ptr [CFG_IgnoreLVM], 1            ; We are supposed to ignore LVM, so
        jnz     DIOLLVMS_NoLVMSector          ;  don't load but declare as bad!
        mov     ax, wptr cs:[CurPartition_Location+0]
        mov     bx, wptr cs:[CurPartition_Location+2]
        mov     dx, wptr cs:[CurPartition_Location+4]
        mov     cx, wptr cs:[CurPartition_Location+6] ; Gets cur. partition location

        call    DriveIO_LVMAdjustToInfoSector

        mov     si, offset LVMSector
        call    DriveIO_LoadSector

    IFDEF   AUX_DEBUG
        ; show current partition location
        ;~ pushf
        ;~ pusha
        ;~ call    AuxIO_TeletypeNL
        ;~ mov     si,offset db_curlvmsec
        ;~ call    AuxIO_Print
        ;~ mov     dx,bx
        ;~ call    AuxIO_TeletypeHexDWord
        ;~ call    AuxIO_TeletypeNL
        ;~ mov     si,offset LVMSector
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
        ;~ popa
        ;~ popf
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
        test    byte ptr [CFG_IgnoreLVM], 1            ; We are supposed to ignore LVM, so
        jnz     DIOSLVMS_SevereError          ;  don't save at anytime (security!)
        mov     ax, wptr cs:[CurPartition_Location+0]
        mov     bx, wptr cs:[CurPartition_Location+2]
        mov     dx, wptr cs:[CurPartition_Location+4]
        mov     cx, wptr cs:[CurPartition_Location+6] ; Gets cur. partition location
        call    LVM_CheckSectorSignature
        jnc     DIOSLVMS_SevereError                  ; LVM Signature must be there

    IFDEF   AUX_DEBUG
;~ dioatlvm    db 'DriveIO_LVMAdjustToInfoSector',10,0
        ;~ pushf
        ;~ pusha
        ;~ mov     si,offset dioatlvm
        ;~ call    AuxIO_Print
        ;~ popa
        ;~ popf
        call    DEBUG_DumpRegisters
        call    DEBUG_DumpCHS
    ENDIF

        call    DriveIO_LVMAdjustToInfoSector

    IFDEF   AUX_DEBUG
        call    DEBUG_DumpRegisters
        call    DEBUG_DumpCHS
    ENDIF

        mov     si, offset LVMSector
        call    DriveIO_SaveSector
    DIOSLVMS_SevereError:
        ret
DriveIO_SaveLVMSector   EndP

; Rousseau: Move this to BSS and merge with int13xbuf there.

; Memory-Block that holds information for LBA-access via INT 13h
DriveIO_DAP                 db      10h ; Size of paket
                            db      0   ; Reserved
DriveIO_DAP_NumBlocks       dw      0   ; Number of blocks
DriveIO_DAP_Transfer        dd      0   ; Transfer Adress
DriveIO_DAP_Absolute        dd      0   ; Absolute Sector
                            dd      0   ; Second Part of QWORD

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
        mov     di, 3
    DIOLS_ErrorLoop:
        push    ds
        pop     es
        mov     bx, si                     ; ES:BX - Destination
        mov     ax, 0201h                  ; Function 2 - Load Sector
        int     13h
        jnc     DIOLS_Success
        dec     di
        jnz     DIOLS_ErrorLoop
        ; Sector load failed...
        jmp     DriveIO_GotLoadError

    DIOLS_UseExtension:
        push    cx
        mov     cs:[DriveIO_DAP_NumBlocks], 1         ; Copy ONE sector
        mov     wptr cs:[DriveIO_DAP_Transfer+0], si
        mov     cx, ds
        mov     wptr cs:[DriveIO_DAP_Transfer+2], cx ; Fill out Transfer Adress
        mov     wptr cs:[DriveIO_DAP_Absolute+0], ax
        mov     wptr cs:[DriveIO_DAP_Absolute+2], bx ; Fill out Absolute Sector
        push    cs
        pop     ds
        mov     si, offset DriveIO_DAP
        mov     ah, 42h                        ; Extended Read
        int     13h
        pop     cx
        jnc     DIOLS_Success
        ; Sector load failed...
        jmp     DriveIO_GotLoadError

    DIOLS_Success:
        ret
DriveIO_LoadSector      EndP



;
; ############################################################
; # Load a specified sector from a disk using LBA addressing #
; ############################################################
;
; In
; --
; DL     = Physical Disk
; BX:CX  = LBA sector
; DI:SI  = Target buffer
;
; Out
; ---
; AX     = Error code
;
DriveIO_LoadSectorLBA       Proc Near  Uses bx cx dx si di ds es
        ; Get one sector
        mov     cs:[DriveIO_DAP_NumBlocks], 1

        ; Setup buffer address
        mov     wptr cs:[DriveIO_DAP_Transfer+0], si
        mov     wptr cs:[DriveIO_DAP_Transfer+2], di

        ; Setup LBA address of requested sector
        mov     wptr cs:[DriveIO_DAP_Absolute+0], cx
        mov     wptr cs:[DriveIO_DAP_Absolute+2], bx
        mov     wptr cs:[DriveIO_DAP_Absolute+4], 0
        mov     wptr cs:[DriveIO_DAP_Absolute+6], 0

        ; Address of packet
        mov     si, offset DriveIO_DAP

        ; Do the extended read
        mov     ah, 42h
        int     13h

        ; Looking good so far
        jnc     DriveIO_LoadSectorLBA_succes1

        ; AH should not be zero, if it is then set to undefined and set carry
        test    ah,ah
        jnz     DriveIO_LoadSectorLBA_error1
        mov     ah, 0bbh        ; Undefined error
    DriveIO_LoadSectorLBA_error1:
        stc
        jmp     DriveIO_LoadSectorLBA_exit

        ; AL should be zero, if not then set to undefined and set carry
    DriveIO_LoadSectorLBA_succes1:
        test    ah,ah
        jz      DriveIO_LoadSectorLBA_exit
        stc
        jmp     DriveIO_LoadSectorLBA_exit

        ; Return to caller
    DriveIO_LoadSectorLBA_exit:
        ret
DriveIO_LoadSectorLBA       EndP



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
        cmp     dl,80h
        ja      DriveIO_ProtectMBR_is_not_bootdisk

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


    ;!
    ;! DEBUG_BLOCK
    ;! Force write to LBA0 to test interception routine.
    ;! Do *NOT* enable unless you are debugging, will overwrite MBR !
    ;!
    ;~ __DIO_FORCE_LBA0_WRITE__    EQU
    IFDEF   AUX_DEBUG
        IFDEF   __DIO_FORCE_LBA0_WRITE__
        xor ax,ax
        xor bx,bx
        xor cx,cx
        inc cx
        xor dh,dh
        ENDIF
    ENDIF


    ;!
    ;! DEBUG_BLOCK
    ;! Check what is being written to disk.
    ;! Uncomment below to activate.
    ;!
    __DIO_SS_DMP__  EQU
    IFDEF   AUX_DEBUG
        IFDEF   __DIO_SS_DMP__
        pusha
        push    si
        mov     si,offset dioss
        call    AuxIO_Print
        pop     si
        call    DEBUG_DumpRegisters
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL
        popa
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
        pusha
        mov     si, offset NonMBRwrite
        call    AuxIO_TeletypeNL
        call    AuxIO_Print
        call    AuxIO_TeletypeNL
        popa
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
        mov     di, 3
    DIOSS_ErrorLoop:
        push    ds
        pop     es
        mov     bx, si                     ; ES:BX - Destination
        mov     ax, 0301h                  ; Function 3 - Write Sector
        int     13h
        jnc     DIOSS_Success
        dec     di
        jnz     DIOSS_ErrorLoop
        call    MBR_SaveError

    DIOSS_UseExtension:
        push    cx
        mov     cs:[DriveIO_DAP_NumBlocks], 1        ; Copy ONE sector
        mov     wptr cs:[DriveIO_DAP_Transfer+0], si
        mov     cx, ds
        mov     wptr cs:[DriveIO_DAP_Transfer+2], cx ; Fill out Transfer Adress
        mov     wptr cs:[DriveIO_DAP_Absolute+0], ax
        mov     wptr cs:[DriveIO_DAP_Absolute+2], bx ; Fill out Absolute Sector
        push    cs
        pop     ds
        mov     si, offset DriveIO_DAP
        mov     ax, 4300h                  ; Extended Write (No Verify)
        int     13h
        pop     cx
        jnc     DIOSS_Success
        call    MBR_SaveError

    DIOSS_Success:
        ret
DriveIO_SaveSector              EndP


; See if a LVM-sector is valid.
; In  : si, pointer to sector
; Out : CY if valid LVM sector, NC if not
DriveIO_LVMSectorValid           Proc  Near
        pusha

        call    LVM_CheckSectorSignature
        ; NC if no signature found
        jnc     DriveIO_LVMSectorValid_End

        call    LVM_CheckSectorCRC
        ; Force valid !!!
        stc

    DriveIO_LVMSectorValid_End:
        popa
        ret
DriveIO_LVMSectorValid           EndP

; ------------------------------------------------------
; Rousseau: # Load the master LVM-sector if one exists #
; ------------------------------------------------------
; Load the master LVM-sector to get the number of sectors per track as
; eCS views the drive. If no master LVM-sector is found it is assumed eCS
; is not installed. The master LVM-sector can be located at three different
; places depending on drive size and partitioning scheme and driver used.
; When DANIS506.ADD is used, the eCS extended geometry will be 255/127 for
; drives >502GiB but <1TiB. Then the location will be sector 127 which
; is LBA 126 (7Eh).
; IBM1S506.ADD will always use 255/255 for the extended eCS geometry.
; DANIS506.ADD will use 255/255 for drives >1TiB.
; Then the location of the master LVM-sector will be 255 which is LBA 254 (FEh).
; When eCS is installed on a huge drive that alread had a system on it, eCS
; will be confined to the lower 502GiB of the drive.
; In this case the normal geometry from Int13X will be used.
; This is also the case when no valid master LVM-sector can be found.
;
; Return CF when valid master LVM sector found, NC if not.
; Loads sector at [LVMSector] !
DriveIO_LoadMasterLVMSector     Proc  Near
        pusha

        ;~ mov      si,offset db_lmlvm
        ;~ call     AuxIO_Print

        ;~ ; Physical disk
        ;~ mov     al,'<'
        ;~ call    VideoIO_PrintSingleChar
        ;~ mov     al,dl
        ;~ call    VideoIO_PrintHexByte
        ;~ mov     al,'>'
        ;~ call    VideoIO_PrintSingleChar
;~
        ;~ call    AuxIO_TeletypeHexByte
        ;~ call    AuxIO_TeletypeNL


        ; Loop over the sector-translation table,
        ; process the first three values from high (255) to low.
        ; (bios spt, most likely 63)
        mov     cx,3
    DriveIO_LoadMasterLVMSector_NextTry:
        ; Number of sectors to read
        mov     [DriveIO_DAP_NumBlocks],1

        ; Setup destination address
        mov     si, offset [LVMSector]
        mov     word ptr [DriveIO_DAP_Transfer+0],si
        mov     ax, ds
        mov     word ptr [DriveIO_DAP_Transfer+2],ax

        ; Get the sector-number of the next possible LVM sector (255,127,63)
        ; using the translation table and the counter as the index
        mov     bx,offset secs_per_track_table
        mov     ax,cx
        dec     ax
        xlatb
        dec     al

        ;
        ; AX now contains the LBA address of the sector
        ; that could be an LVM sector.
        ; This is all in track0 so the address will not exceed 64kiB sectors.
        ;

        ;~ push    ax
        ;~ push    ax
        ;~ mov     al,'$'
        ;~ call    VideoIO_PrintSingleChar
        ;~ pop     ax
        ;~ call    VideoIO_PrintHexByte
        ;~ mov     al,'$'
        ;~ call    VideoIO_PrintSingleChar
        ;~ pop     ax

    IFDEF   AUX_DEBUG
        ; Dump the value
        ;~ call     AuxIO_TeletypeHexByte
        ;~ call     AuxIO_TeletypeNL
    ENDIF

        ; Setup the requested LBA sector number
        mov     word ptr [DriveIO_DAP_Absolute+0],ax    ; LBA low                   NORMAL I/O GEBRUIKEN !
        mov     word ptr [DriveIO_DAP_Absolute+2],00h   ; LBA high
        mov     si, offset DriveIO_DAP                  ; address request packet
        mov     ah, 42h
        int     13h                                     ; do the i/o
        cmc     ; Complement carry so we can exit imm. on error
        jnc     DriveIO_LoadMasterLVMSector_End  ; oops, return with NC


        mov     si,offset [LVMSector]

        ; See if this is a valid LVM-sector
        ; CY=1 if valid
        call    DriveIO_LVMSectorValid

;        pushf
;        mov     ah,0
;        rcl     ah,1
;        mov     al,'|'
;        call    VideoIO_PrintSingleChar
;        mov     al,ah
;        call    VideoIO_PrintHexByte
;        mov     al,'|'
;        call    VideoIO_PrintSingleChar
;        popf


        ; Yep, we found the master LVM-sector
        jc      DriveIO_LoadMasterLVMSector_Found
        ; Try next location
        loop    DriveIO_LoadMasterLVMSector_NextTry

        ; No master LVM-sector found, set CF=false
        clc

    DriveIO_LoadMasterLVMSector_Found:
        ; Store the address for later use.
        mov     ax, word ptr [DriveIO_DAP_Absolute]
        mov     word ptr [MasterLVMLBA], ax

    DriveIO_LoadMasterLVMSector_End:
        popa
        ret
DriveIO_LoadMasterLVMSector     Endp




; ---------------------------------------------------
; Rousseau ## Large drives, (eCS) geometry and LBA ##
; ---------------------------------------------------
; A sector size of 512 bytes is assumed in the below calculations.
; Note that this scheme changes when the sector size will be 4096 or larger,
; like with modern drives that do not translate to 512 bytes per sector anymore.
; These drives will have a capacity above the 2TiB LBA32 boundary.
; For now, we assume drives <=2TiB with a sector size of 512 bytes.

; There are a few boundaries that are of importance.
; Note that these are disk-boundaries and not partition boundaries.
; Even with a small partition, like <502GiB, OS/2 will use extended geometry on
; an empty huge disk.
; These boundaries are (from high to low):

; (code 5)
; 2^32 = 4294967296 = 100000000 sectors = 2048 GiB
;   This is the LBA32 2TiB boundary.
;   Everything above it must be addressed using LBA48.
;   OS/2 can currently not address this space above.

; (code4)
; 65536*255*255 = 4261478400 = FE010000 sectors ~ 2032 GiB
;   This is the max OS/2 boundary using 255/255 extended geometry.
;   OS/2 can currently not address this space above.

; (code 3)
; 2^31 = 2147483648 = 80000000 sectors = 1024 GiB
;   This is the LBA32 1TiB boundary.
;   OS/2 can address this space and will use 255/255 extended geometry.

; (code 2)
; 65536*255*127 = 2122383360 = 7E810000 sectors ~ 1012 GiB
;   This is the DANI 1TiB boundary.
;   OS/2 can address this space and will use 255/255 extended geometry.
;   Below this DANI will use 255/127 extended geometry.
;   This matters on where the LVM-sectors are located !

; (code 1)
; 65536*255*63  = 1052835840 = 3EC10000 sectors ~ 502 GiB
;   This is the current OS/2 limit using this geometry because OS/2 can
;   currently not address more than 65536 cylinders.
;   DANI will address space above with 255/127 extended geometry up until
;   the DANI 1TiB boundary (code 2)

; (code 0)
; Everything below 65536*255*63 will be addressed using standard geometry.


;
; This function will return the following values:
;

; 5 = This drive is above the 2^32 LBA32 (2TB) boundary and has more
;     than 4294967296 sectors.
;     LBA48 addressing is needed to access the complete capacity of the drive.
;     OS/2 is currently unable to do so.

; 4 = This drive is above the 65536*255*255 (4261478400) boundary but below 2^32.
;     This is an OS/2 boundary and OS/2 is not able to access the drive above
;     this boundary.

; 3 = This drive is above the 2^31 (1TB) boundary and has more than
;     2147483648 sectors.
;     OS/2 is able to access the drive using it's extended geometry.
;     Both DANIS506 and IBM1S506 will use the 255/255 scheme.

; 2 = This drive is above the 65536*255*127 (2122383360) boundary but below 2^31.
;     OS/2 is able to access the drive using it's extended geometry.
;     Both DANIS506 and IBM1S506 will use the 255/255 scheme.

; 1 = This drive is above the 65536*255*63 (1052835840) boundary but
;     below 65536*255*127.
;     OS/2 is able to access the drive using it's extended geometry.
;     Note that DANIS506 will use 255/127 and IBM1S506 will use 255/255 geometry !
;     Using DANI or IBM influences the location of the LVM info-sectors !

; 0 = This drive is below the 65536*255*63 (1052835840) boundary.
;     OS/2 is able to access this drive using the standard 255/63 geometry.

; So, any return value >0 means OS/2 extended geometry will be used.
; Value 1 will use 255/127 with DANIS506 but 255/255 with IBM1S506.
; Values 2 and 3 will use 255/255 on both drivers.
; You can or with 0x01 and check for 3 in this case.
; Any value above 3 will be a drive who's capacity cannot be fully used by OS/2
; The upper limit of 65536*255*255 will be in effect here.

; Note this function currently handles the boot-drive only !
; It should be extended and use dl for the drive-number as a parameter.
; Because we use this function to get this info in a number of places,
; all regs and flags except AX are saved and restored.

; DL contains BIOS disk-number; 80h for first, 81h for second, etc.
DriveIO_GatherDiskInfo  Proc Near
        pushf
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    es

        ; Set ES to CS for buffer clearing
        push    cs
        pop     es

        ; Clear the buffer
        ; Also setup the buffer size.
        ; Old Phoenix BIOSses require word (flags) at 02 to be zero,
        ; so we clear the whole buffer to be sure.
        mov     cx, i13xbuf_size        ; Dynamically calculated by assembler.
        mov     di, offset i13xbuf      ; Points to size field.
        mov     [di],cx                 ; Setup buffer-size.
        inc     di
        inc     di                      ; Now pointing at actual buffer.
        xor     ah,ah                   ; Fill value.
        cld                             ; Direction up.
        rep stosb                       ; Clear buffer.

        ; Get the drive parameters
        mov     ah, 48h                 ; Get Drive Parameters (extended version)
        ;mov     dl, 80h                ; Drive number
        mov     si, offset i13xbuf      ; Buffer for result-info
        push    dx
        int     13h                     ; Call the BIOS-function
        pop     dx

        ; Do some error-checking
        or      ah,ah                       ; AH is zero if no error (ZF=1 if no error)
        mov     ax,0                        ; Setup code for non-huge drive (does not influence ZF)
        jz      DriveIO_GatherDiskInfo_ok   ; Return if error (AL<>0 thus ZF=0) but CY not set, assuming non-huge drive
        jnc     DriveIO_GatherDiskInfo_ok   ; Return if error (CY=1), assuming non-huge drive
        jmp     DriveIO_GatherDiskInfo_ret


    DriveIO_GatherDiskInfo_ok:

        ;
        ; Store the drive geometry
        ;

        mov      si, offset i13xbuf

        xor      dh,dh
        and      dl,01111111b
        shl      dx,1
        shl      dx,1

        ; Store number of cylinders on disk
        mov      bx, offset BIOS_Cyls
        add      bx,dx
        mov      ax,[si+04h]

        mov      word ptr [bx+00],ax
        mov      ax,[si+06]
        mov      word ptr [bx+02],ax

        ; Store number of heads per cylinder
        mov      bx, offset BIOS_Heads
        add      bx,dx
        mov      ax,[si+08h]
        mov      word ptr [bx+00],ax
        mov      ax,[si+0ah]
        mov      word ptr [bx+02],ax

        ; Store number of sectors per track
        mov      bx, offset BIOS_Secs
        add      bx,dx
        mov      ax,[si+0ch]
        mov      word ptr [bx+00],ax

        ; Update first byte of translation-table to conform to BIOS SPT
        mov      byte ptr [secs_per_track_table], al

        mov      ax,[si+0eh]
        mov      word ptr [bx+02],ax

        ; Store total secs
        mov      bx, offset BIOS_TotalSecs
        add      bx,dx
        add      bx,dx
        mov      ax,[si+10h]

        mov      word ptr [bx+00],ax
        mov      ax,[si+12h]
        mov      word ptr [bx+02],ax
        mov      ax,[si+14h]
        mov      word ptr [bx+04],ax
        mov      ax,[si+18h]
        mov      word ptr [bx+06],ax

        ; Store number of bytes per sector
        mov      bx, offset BIOS_Bytes
        add      bx,dx
        mov      ax,[si+18h]
        mov      [bx],ax


        ;
        ; See of it's a huge drive of not
        ;

        ; Drive is larger than 2TiB
        mov     ax,5                        ; Drive code (5)
        mov     bx, [si+14h]                ; Low word of high dword of sector-count
        or      bx, [si+16h]                ; High word of high dword of sector-count
        jnz     DriveIO_GatherDiskInfo_ret  ; If non-zero we have a drive with >2^32 sectors and thus LBA48 addressing

        ; Drive is larger than max OS/2 capacity
        dec     ax                          ; Drive code (4)
        mov     bx, [si+12h]                ; High word of low dword of sector-count
        cmp     bx, 0fe01h                  ; Boundary
        jae     DriveIO_GatherDiskInfo_ret  ; If above or equal to boundary,
                                            ; we have a drive larger than to 65536*255*255 = FE010000 sectors

        ; Drive can be completely utilized by OS/2
        dec     ax                          ; Drive code (3)
        cmp     bx, 8000h                   ; Boundary
        jae     DriveIO_GatherDiskInfo_ret  ; If above or equal to boundary,
                                            ; we have a drive larger than 2^31 sectors but smaller than 65536*255*255

        ; This is the small area between DANI 1TiB and LBA 1TiB
        dec     ax                          ; Drive code (2)
        cmp     bx, 7e81h                   ; Boundary
        jae     DriveIO_GatherDiskInfo_ret  ; If above or equal to boundary,
                                            ; we have a drive larger than 65536*255*127 but <65536*255*255
                                            ; DANIS506.ADD will use 255/255 extended geometry

        ; DANI will use 255/127 in this area, this could impact the location of LVM-sectors ! (last sec on track)
        dec     ax                          ; Drive code (1)
        cmp     bx, 3ec1h                   ; Boundary
        jae     DriveIO_GatherDiskInfo_ret  ; If above or equal to boundary,
                                            ; we have a drive larger than 65536*255*63 sectors (OS/2 502GiB Limit!)
                                            ; DANIS506.ADD will use 255/127 extended geometry !
                                            ; IBM1S506.ADD will use 255/255 extended geometry !

        ; We have a drive that can be addressed using standard 255/63 geometry
        dec     ax                                      ; Drive code (0)
                                            ; We have a drive smaller than 65536*255*63 = 3EC10000 sectors

    DriveIO_GatherDiskInfo_ret:
        pop     es
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx

        mov      byte ptr [CurIO_UseExtension],1

        popf
        ret
DriveIO_GatherDiskInfo  EndP



; Values for sectors per track table corresponding to DriveIO_IsHugeDrive return value.
secs_per_track_table    db    63,127,255,255,255,255

;db_lmlvm:   db 'Load Master LVM -- disk: ',0