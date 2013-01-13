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
;                                                            AiR-BOOT / LVM
;---------------------------------------------------------------------------

IFDEF ModuleNames
DB 'LVM',0
ENDIF

LVM_InitCRCTable                Proc Near   Uses
   ; Initializes our LVM-CRC-Table
   xor    cl, cl
   mov    di, offset LVM_CRCTable
  LVM_ICRCT_Loop:
      ;movzx  ax, cl
      mov   al,cl
      mov   ah,0

      xor    dx, dx                      ; DX:AX - CRC-Value
      mov    ch, 8
     LVM_ICRCT_Loop2:
         shr    dx, 1
         rcr    ax, 1                    ; Shift value 1 to the right
         jnc    LVM_ICRCT_NoXOR
         xor    dx, 0EDB8h
         xor    ax, 8320h
        LVM_ICRCT_NoXOR:
      dec    ch
      jnz    LVM_ICRCT_Loop2
      mov    wptr [di+0], ax
      mov    wptr [di+2], dx
      add    di, 4
   add    cl, 1
   jnc    LVM_ICRCT_Loop
   ret
LVM_InitCRCTable                EndP

; Calculates an LVM-Sector CRC of a given sector
;        In: DS:SI - Points to Sector...
;       Out: DX:AX - LVM CRC
; Destroyed: None
LVM_GetSectorCRC                Proc Near   Uses bx cx
   push   wptr [si+LocLVM_CRC]
   push   wptr [si+LocLVM_CRC+2]
   push   si
      mov    wptr [si+LocLVM_CRC], 0
      mov    wptr [si+LocLVM_CRC+2], 0
      mov    ax, -1
      mov    dx, -1
      mov    cx, 512
     LVM_GSCRC_Loop:
         xor    bh, bh
         mov    bl, al                      ; Save last byte to BL
         mov    al, ah
         mov    ah, dl
         mov    dl, dh
         xor    dh, dh                      ; SHR DX:AX, 8
         xor    bl, [si]
         inc    si                          ; XOR last byte with [data]
         shl    bx, 1
         shl    bx, 1
         xor    ax, wptr [LVM_CRCTable+bx+0]
         xor    dx, wptr [LVM_CRCTable+bx+2] ; XOR with CRC-Table
      loop   LVM_GSCRC_Loop
   pop    si
   pop    wptr [si+LocLVM_CRC+2]
   pop    wptr [si+LocLVM_CRC]
   ret
LVM_GetSectorCRC                EndP

; Checks DS:[SI], if a valid LVM Signature is found (sets carry in that case)
;  This does not check for valid LVM CRC (which also needs to be done)
;        In: DS:SI - Sector that needs to get checked...
;       Out: Carry set, if valid LVM signature found
; Destroyed: None
LVM_CheckSectorSignature        Proc Near   Uses
   test    [CFG_IgnoreLVM], 1            ; We are supposed to ignore LVM, so
   jnz     LVMCSS_InvalidSignature       ;  any sector is bad!
   cmp     wptr [si+LocLVM_SignatureStart], 5202h                                ; Rousseau: identify LVM sector
   jne     LVMCSS_InvalidSignature
   cmp     wptr [si+LocLVM_SignatureStart+2], 'BM'
   jne     LVMCSS_InvalidSignature
   cmp     wptr [si+LocLVM_SignatureStart+4], 'MP'
   jne     LVMCSS_InvalidSignature
   cmp     wptr [si+LocLVM_SignatureStart+6], 'DF'
   jne     LVMCSS_InvalidSignature
   stc
   ret
  LVMCSS_InvalidSignature:
   clc
   ret
LVM_CheckSectorSignature        EndP

; Checks Sector for a valid LVM CRC is encountered
;  First one should check for a valid signature and call this later.
;        In: DS:SI - Sector that needs to get checked...
;       Out: Carry set, if LVM CRC valid
; Destroyed: None
LVM_CheckSectorCRC              Proc Near   Uses ax dx
   call    LVM_GetSectorCRC
   cmp     ax, wptr [si+LocLVM_CRC]
   jne     LVMCSCRC_BadCRC
   cmp     dx, wptr [si+LocLVM_CRC+2]
   jne     LVMCSCRC_BadCRC
   stc
   ret
  LVMCSCRC_BadCRC:
   clc
   ret
LVM_CheckSectorCRC              EndP

; Updates Sector with valid LVM CRC
;  This one doesn't check, if it's really an LVM sector, so check before!
;        In: DS:SI - Sector that needs to get checked...
;       Out: None, CRC updated
; Destroyed: None
LVM_UpdateSectorCRC            Proc Near   Uses ax dx
   call    LVM_GetSectorCRC
   mov     wptr [si+LocLVM_CRC], ax
   mov     wptr [si+LocLVM_CRC+2], dx
   ret
LVM_UpdateSectorCRC            EndP

; Searches for a partition in LVM Information Sector and sets SI to point to
;  the LVM-entry. It will also set CARRY then.
;        In: DX:AX - LBA starting sector of partition to be searched
;            DS:SI - Valid (previously checked) LVM-Information-Sector
;       Out: Carry set, if partition found
;            DS:SI - points to LVM information entry
; Destroyed: None
LVM_SearchForPartition          Proc Near   Uses cx
   cmp     bptr [si+LocLVM_SignatureStart], LocLVM_SignatureByte0
   jne     LVMSFP_NotFound               ; Quick Check, if LVM sector there
   add     si, LocLVM_StartOfEntries
   mov     cl, LocLVM_MaxEntries
  LVMSFP_Loop:
      cmp     ax, [si+LocLVM_PartitionStart]
      jne     LVMSFP_NextEntry
      cmp     dx, [si+LocLVM_PartitionStart+2]
      je      LVMSFP_FoundIt
     LVMSFP_NextEntry:
      add     si, LocLVM_LenOfEntry
   dec     cl
   jnz     LVMSFP_Loop
  LVMSFP_NotFound:
   clc
   ret
  LVMSFP_FoundIt:
   stc
   ret
LVM_SearchForPartition          EndP


; Gets a drive-letter from the LVM-info of a partition. (if it exists)
;        In: BX:CX - LBA starting sector of partition to be searched
;            DL = Physical Disk in BIOS notation. (80h+)
;       Out: Carry set, if LVM-info found
;            AL - drive-letter from LVM-info

LVM_GetDriveLetter      Proc Near   Uses bx cx dx si di ds es
        ; For primary partitions this information is stored in the last
        ; sector of track0; for all four partition entries should they
        ; all be primary ones.
        ;
        ; LVM DLAT info for logical partitions is stored in the sector
        ; preceding the start of the partition.
        ;
        ; Because the LVM info of a logical partition is the easiest to find,
        ; we do that first. The LVM info for primary partitions is located
        ; dependent on the geometry in use, so we use a special locater
        ; call for that. Also, since the LVM info for primaries contains
        ; info on all 4 entries, we need the partition index to obtain the
        ; correct drive-letter.
        ;

        ; See if this is a primary partition
        ; CY will be set if it is and AL will contain the 0-based
        ; index in the P-table.
        ; If it's a logical partition, CY will be clear and AL
        ; will be set to 0ffh indicating an invalid index.
        call    PART_IsPrimaryPartition
        mov     al,0
        rcl     al,1        ; CY if primary
        mov     dh,al       ; Save PRI or LOG

        ; Save PRI/LOG indicator for later use
        push    dx

        ; Load *possible* LVM sector
        ; This load is only valid if the partition is logical, in which case
        ; the LVM sector is below the start of the partition.
        ; If primary, the LVM sector is at a location that
        ; DriveIO_LoadMasterLVMSector will find out.

        ; Push LBA address
        push    bx
        push    cx

        ; Adjust for logical LVM-sector
        sub     cx,1
        sbb     bx,0

        ; Load the LVM sector
        push    si
        push    di
        mov     si,offset [LVMSector]
        mov     di,ds
        call    DriveIO_LoadSectorLBA
        pop     di
        pop     si

        ; Restore LBA address
        pop     cx
        pop     bx

        ; Restore PRI/LOG partition indicator in DH
        pop     dx

        ; Test PRI or not
        test    dh,dh
        ; It's not a PRI so we can use the previously loaded LVM sector
        jz      LVM_GetDriveLetter_is_not_pri

        ; It's a PRI so we use the special locator function.
        ; This locator takes care of extended eCS geometry should that be used
        call    DriveIO_LoadMasterLVMSector

    LVM_GetDriveLetter_is_not_pri:


        ;
        ; At this stage the LVM-info sector has been loaded at [LVMSector].
        ; From here we look for an LVM entry for the partition.
        ; If one is found, based on it's LBA-start, it's driveletter is used
        ; in case byte 25h is zero.
        ;


        ; Search for the partition in the LVM info.
        ; If found, CY is set and SI points to LVM entry.
        push    si
        mov     ax,cx
        mov     dx,bx
        mov     si,offset [LVMSector]
        call    LVM_SearchForPartition
        mov     bx,si   ; BX now points to LVM entry
        mov     dx,0    ; Setup null driveletter
        pop     si

        mov     al,0
        ; Oops, no valid LVM record was used so we have a null driveletter.
        jnc     LVM_GetDriveLetter_null_lvm_dl

        ;
        ; At this point BX points to the LVM-entry related to the
        ; partition, whether it was a logical or a primary one.
        ;
        mov     al,[bx+LocLVM_VolumeLetter]
        ; Clear CY if 0
        test    al,al
        clc
        jz      LVM_GetDriveLetter_null_lvm_dl
        stc

    LVM_GetDriveLetter_null_lvm_dl:
        ret
LVM_GetDriveLetter      EndP


; Removes a given drive-letter from the whole LVM information sector
;        In: CH    - drive-letter (ascii)
;            DS:SI - LVM-Information-Sector
;       Out: LVM-Information-Sector updated (including LVM CRC)
; Destroyed: None
LVM_RemoveVolLetterFromSector   Proc Near   Uses cx
   cmp     bptr [si+LocLVM_SignatureStart], LocLVM_SignatureByte0
   jne     LVMRVLFS_Done                 ; Quick Check, if LVM sector there
   push    si
      add     si, LocLVM_StartOfEntries
      mov     cl, LocLVM_MaxEntries
     LVMRVLFS_Loop:
         cmp     ch, [si+LocLVM_VolumeLetter]
         jne     LVMRVLFS_NextEntry
         ; Reset drive-letter, if matched
         mov     bptr [si+LocLVM_VolumeLetter], 0
        LVMRVLFS_NextEntry:
         add     si, LocLVM_LenOfEntry
      dec     cl
      jnz     LVMRVLFS_Loop
   pop     si
   call    LVM_UpdateSectorCRC
  LVMRVLFS_Done:
   ret
LVM_RemoveVolLetterFromSector   EndP

; Reassigns LVM volume driveletter
;  Will remove the drive-letter from any volume that got it currently
;   and finally change the drive-letter of the given partition
;        In: AL    - drive-letter
;            DS:SI - points to partition, that needs that driveletter
;       Out: None
; Destroyed: AX
LVM_DoLetterReassignment        Proc Near   Uses bx cx dx si di
   mov     di, si                        ; Save SI in DI (Partition-pointer)
   mov     ch, al                        ; and AL in CH (drive-letter)
   xor     bx, bx
   mov     cl, CFG_Partitions
   or      cl, cl
   jz      LVMDLR_SkipRemove
  LVMDLR_RemoveLoop:
      cmp     bptr [PartitionVolumeLetters+bx], ch
      jne     LVMDLR_NextPartition
      ; One volume that has our wanted drive-letter, so remove it!
      mov     dl, bl
      call    PART_GetPartitionPointer   ; DL - partition -> SI
      ; Now set CurPartition_Location for the DriveIO-functions to work
      mov     ax, wptr [si+LocIPT_AbsolutePartTable]
      mov     wptr [CurPartition_Location+0], ax
      mov     ax, wptr [si+LocIPT_AbsolutePartTable+2]
      mov     wptr [CurPartition_Location+2], ax
      mov     ax, wptr [si+LocIPT_LocationPartTable+1]
      mov     wptr [CurPartition_Location+6], ax
      mov     ah, bptr [si+LocIPT_LocationPartTable+0]
      mov     al, [si+LocIPT_Drive]
      mov     wptr [CurPartition_Location+4], ax
      call    DriveIO_LoadLVMSector      ; SI points now to LVM-Sector
      call    LVM_RemoveVolLetterFromSector
      IFDEF ReleaseCode
         call    DriveIO_SaveLVMSector   ; Save sector
      ENDIF
     LVMDLR_NextPartition:
      inc     bx
   dec     cl
   jnz     LVMDLR_RemoveLoop
  LVMDLR_SkipRemove:
   ; Set CurPartition_Location information of destination partition
   mov     ax, wptr [di+LocIPT_AbsolutePartTable]
   mov     wptr [CurPartition_Location+0], ax
   mov     ax, wptr [di+LocIPT_AbsolutePartTable+2]
   mov     wptr [CurPartition_Location+2], ax
   mov     ah, bptr [di+LocIPT_LocationPartTable+0]
   mov     al, [di+LocIPT_Drive]
   mov     wptr [CurPartition_Location+4], ax
   mov     ax, wptr [di+LocIPT_LocationPartTable+1]
   mov     wptr [CurPartition_Location+6], ax
   call    DriveIO_LoadLVMSector         ; SI points now to LVM-Sector
   mov     ax, wptr [di+LocIPT_AbsoluteBegin]
   mov     dx, wptr [di+LocIPT_AbsoluteBegin+2]
   mov     di, si                        ; Save SI in DI
   call    LVM_SearchForPartition
   jnc     LVMDLR_DestPartNotFound
   ; Set new volume letter
   mov     bptr [si+LocLVM_VolumeLetter], ch
   mov     si, di                        ; SI - LVM Sector again
   call    LVM_UpdateSectorCRC           ; Update LVM-CRC now
   IFDEF ReleaseCode
      call    DriveIO_SaveLVMSector      ; Save sector
   ENDIF
  LVMDLR_DestPartNotFound:
   ; This here is done for safety, because we misuse CurPartition_Location
   xor     ax, ax
   mov     di, offset CurPartition_Location
   mov     cx, 4
   rep     stosw                         ; NUL out CurPartition_Location
   ret
LVM_DoLetterReassignment        EndP
