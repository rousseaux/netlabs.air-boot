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
;                                     AiR-BOOT / PARTiTiON REGULAR ROUTINES
;---------------------------------------------------------------------------

IFDEF   MODULE_NAMES
DB 'PARTMAIN',0
ENDIF

PART_FixUpDefaultPartitionValues Proc Near  Uses dx si di
    ; Fix-Up Default and Last Partition - If lost, search for Bootable
    xor     bl, bl
    mov     dl, CFG_PartDefault
    call    PART_FixUpSelectionNumber
    mov     CFG_PartDefault, dl
    mov     dl, CFG_PartLast
    call    PART_FixUpSelectionNumber
    mov     CFG_PartLast, dl
    mov     dl, CFG_PartAutomatic
    call    PART_FixUpSelectionNumber
    mov     CFG_PartAutomatic, dl

; [Linux support removed since v1.02]
;   ; Fix-Up Linux Kernel Partition - If lost, search for FAT-16
;   mov     bl, 06h
;   mov     dl, CFG_LinuxKrnlPartition
;   call    PART_FixUpPartitionNumber
;   mov     CFG_LinuxKrnlPartition, dl
;
;   ; Fix-Up Linux Root Partition - If lost, search for Linux partition (83h)
;   mov     bl, 83h
;   mov     dl, CFG_LinuxRootPartition
;   call    PART_FixUpPartitionNumber
;   mov     CFG_LinuxRootPartition, dl
   ret
PART_FixUpDefaultPartitionValues EndP

; Our resync process for partition number is as specified:
;==========================================================
; - If 0FFh -> Partition Disabled, so don't do anything to it...
; - Try to use GetXref to get the new partition no via X-Ref Table
; - If failed, increase partition no, till overflow or hit on specific
;    characteristic
;    On overflow -> Resume search from partition no 0
;
; Characteristic is a partition id. If this id is 0, then a bootable partition
;  is searched for.

; Fixes a partition number, adjusting it to the new IPT after redetect
;        In: DL - Number of partition
;            BL - Requested Partition ID
;       Out: DL - New number of partition (guessed normally ;)
PART_FixUpSelectionNumber       Proc Near Uses ax cx
        cmp     dl, 080h
        je      PFUPN_SelectionDisabled
        ja      PFUPN_SpecialSelection
        call    PARTSCAN_GetXref              ; DL - PartitionNo prev IPT
        cmp     dh, 0FFh                      ; DH -> Partition No in new IPT
        je      PFUPN_SelectionGone
        mov     dl, dh
    PFUPN_SelectionDisabled:
        ret

    PFUPN_SpecialSelection:
        cmp     dl, 0FEh                      ; Resume-BIOS?
        ja      PFUPN_SpecialSelectionFloppy
        cmp     byte ptr [CFG_ResumeBIOSbootSeq], 0
        je      PFUPN_SelectionGone
        jmp     PFUPN_Found
    PFUPN_SpecialSelectionFloppy:
        cmp     byte ptr [CFG_IncludeFloppy], 0
        je      PFUPN_SelectionGone
        jmp     PFUPN_Found

    ; Partition is not referenced in New-IPT or Resume-BIOS/Floppy selected, but
    ;  actual media is disabled...so dig for requested partition
    PFUPN_SelectionGone:
        mov     cl, CFG_Partitions
        or      cl, cl
        jz      PFUPN_NothingFound            ; No partitions available -> so fail
        or      bl, bl
        jz      PFUPN_BootableSearchLoop
    ; Search for Partition ID "BL"
    PFUPN_PartIDsearchLoop:
        call    PART_GetPartitionPointer   ; Gets SI for partition DL
        cmp     bptr ds:[si+LocIPT_SystemID], bl
        je      PFUPN_Found
        dec     cl
        jz      PFUPN_NothingFound
        inc     dl                            ; Increase
        cmp     CFG_Partitions, dl
        ja      PFUPN_PartIDsearchLoop
        xor     dl, dl
        jmp     PFUPN_PartIDsearchLoop

    ; Search for Partition ID "BL"
    PFUPN_BootableSearchLoop:
        call    PART_GetPartitionPointer   ; Gets SI for partition DL
        mov     al, ds:[si+LocIPT_Flags]
        and     al, Flags_Bootable
        jnz     PFUPN_Found
        dec     cl
        jz      PFUPN_NothingFound

        inc     dl                         ; Increase
        cmp     CFG_Partitions, dl
        ja      PFUPN_PartIDsearchLoop
        xor     dl, dl
        jmp     PFUPN_PartIDsearchLoop

    PFUPN_NothingFound:
        mov     dl, 080h                      ; Now being Disabled
    PFUPN_Found:
        ret
PART_FixUpSelectionNumber       EndP

; ============================================================================
;        In: DS:SI - IPT-Entry of partition
;            DS:PartitionSector - Actual Boot-Record of partition
;       Out: *none* (BootRecordCRD updated)
PART_UpdateBootRecordCRC        Proc Near Uses bx
        mov     si, offset PartitionSector
        mov     bx, 4B4Dh            ; Magic: 'MK'
        call    MBR_GetCheckOfSector
        mov     [si+LocIPT_BootRecordCRC], bx
        ret
PART_UpdateBootRecordCRC        EndP


;
; What happens here ?
;

; Rousseau:
; ---------
; Bug:
; When ResumeBIOSbootSeq is zero, BX still gets decremented and shifted left.
; Then when used as an index into ContinueBIOSbootTable to get the address
; of the device-name, the index is two bytes too low, and SI get's loaded
; with whatever is before the ContinueBIOSbootTable.
; Then when SI is used to copy a null-terminated string, it depends on the
; bogus location SI points to where a null-byte will appear.
; Since I placed some text before the ContinueBIOSbootTable, the bogus pointer
; SI obtained pointed to an area where there was no null-byte in sight for
; more than 11 bytes, causing SI to overwrite the CD-ROM IPT entry with
; garbage. It took me a while to tackle this one because I was baffled why
; moving text around in STD_TEXT.ASM, where ContinueBIOSbootTable resides,
; mattered while the offset of ContinueBIOSbootTable did not change.
; This bug is also present in v1.06 but never surfaced because STD_TEXT.ASM
; is kinda static and luck has it that the word preceding ContinueBIOSbootTable
; presumably pointed to an area where a null byte was near.
;
; Fix:
; Test BX for zero and if so, skip the


; Copies the device-name to the Resume-BIOS IPT entry
PART_UpdateResumeBIOSName       Proc Near Uses ax bx cx si di

        ; Get BIOS resume indicator.
        ;movzx   bx, CFG_ResumeBIOSbootSeq
        mov     bl,CFG_ResumeBIOSbootSeq
        mov     bh,0

        ; Clear name of IPT-entry.
        mov     di, offset BIOScontIPTentry+LocIPT_Name
        push    di
            mov     cx, 11
            mov     al, ' '
            rep     stosb
        pop     di

        ; If no resume then exit.
        test    bx,bx
        jz      PURBN_NoResumeBootSeq

        ; Convert to index in name-table.
        dec     bx
        shl     bx, 1

        ; Put the pointer to the name in SI.
        mov     si, word ptr [ContinueBIOSbootTable+bx]

        ; Copy the name to the IPT-entry.
    PURBN_BootDeviceCopyLoop:
        lodsb
         or     al, al
        jz      PURBN_NoResumeBootSeq
        stosb
        jmp     PURBN_BootDeviceCopyLoop

        ; We're done.
    PURBN_NoResumeBootSeq:

        ret
PART_UpdateResumeBIOSName       EndP



; ============================================================================
;  Partition-Pointer Functions
; ============================================================================

; Builds Pointer-Table straight (without filtering, w/o Floppy/CD-ROM/Kernels)
PART_CalculateStraightPartPointers Proc Near
        mov     ax, offset PartitionTable
        mov     bx, offset PartitionPointers
        mov     cx, LocIPT_MaxPartitions

    PCSPP_Loop:
        mov     ds:[bx], ax                     ; Move address IPT entry to PPT
        add     bx, 2                           ; Advance pointer to PPT entry
        add     ax, LocIPT_LenOfIPT             ; Advance pointer to IPT entry
        dec     cx                              ; Decrement counter
        jnz     PCSPP_Loop                      ; Next iteration

        mov     al, ds:[CFG_Partitions]         ; Get number of partitions
        mov     ds:[PartitionPointerCount], al  ; Update number for PPT
        ret
PART_CalculateStraightPartPointers EndP

; This here does PartitionPointers in order for displaying in BootMenu
; [this means filtering and including Floppy/CD-ROM/Kernels, if wanted]
PART_CalculateMenuPartPointers Proc Near Uses si

;!
;! DEBUG_PROBE
;!
IFDEF   AUX_DEBUGx
    push    1241h
    call    DEBUG_Probe
ENDIF

        mov     si, offset PartitionTable
        mov     bx, offset PartitionPointers
        test    byte ptr [CFG_IncludeFloppy], 1
        jz      PCMPP_NoFloppyInclude
        mov     ax, offset FloppyIPTentry
        mov     ds:[bx], ax
        add     bx, 2
    PCMPP_NoFloppyInclude:

        test    byte ptr [CFG_ResumeBIOSbootSeq], 0FFh
        jz      PCMPP_NoResumeBootSeqInclude
        mov     ax, offset BIOScontIPTentry
        mov     ds:[bx], ax
        add     bx, 2
    PCMPP_NoResumeBootSeqInclude:

; [Linux support removed since v1.02]
;   ; Now include all Linux Kernels, if any available...
;   movzx   cx, LINUX_KernelNo
;   or      cx, cx
;   jz      PCMPP_NoLinuxKernels
;   mov     ax, offset LINUX_KernelEntries
;  PCMPP_KernelLoop:
;      mov     ds:[bx], ax
;      add     bx, 2
;      add     ax, LocIPT_LenOfIPT
;   dec     cx
;   jnz     PCMPP_KernelLoop
;  PCMPP_NoLinuxKernels:

        ;movzx   cx, CFG_Partitions ; LocIPT_MaxPartitions
        mov   cl,CFG_Partitions ; LocIPT_MaxPartitions
        mov   ch,0

        or      cx, cx
        jz      PCMPP_NoPartitions
    PCMPP_Loop:
        mov     al, ds:[si+LocIPT_Flags]
        and     al, Flags_Bootable
        jz      PCMPP_IsNotBootable
        mov     ds:[bx], si
        add     bx, 2
    PCMPP_IsNotBootable:
        add     si, LocIPT_LenOfIPT
        dec     cx
        jnz     PCMPP_Loop
    PCMPP_NoPartitions:
        sub     bx, offset PartitionPointers
        shr     bx, 1
        mov     ds:[PartitionPointerCount], bl
        ret
PART_CalculateMenuPartPointers EndP

; Gets a pointer to the given partition
;        In: DL - Number of partition
;       Out: SI - Pointer to it
PART_GetPartitionPointer        Proc Near   Uses bx
        cmp     dl, 0FEh
        je      PGPP_IsBIOSbootSeq            ; FEh -> Resume BIOS boot Sequence
        ja      PGPP_IsFloppy                 ; FFh -> Floppy
        ;movzx   bx, dl
        mov   bl,dl
        mov   bh,0

        shl     bx, 1
        mov     si, word ptr [PartitionPointers+bx]
        ret

    PGPP_IsBIOSbootSeq:
;!
;! DEBUG_PROBE
;!
IFDEF   AUX_DEBUGx
    push    1242h
    call    DEBUG_Probe
ENDIF

        mov     si, offset BIOScontIPTentry
        ret

    PGPP_IsFloppy:
        mov     si, offset FloppyIPTentry     ; PartitionTable-LocIPT_LenOfIPT
        ret
PART_GetPartitionPointer        EndP

; Gets the number of a partition pointer
;        In: SI - Pointer to Partition
;       Out: DL - Number of partition
PART_GetPartitionNumber         Proc Near   Uses bx
        mov     dl, ds:[PartitionPointerCount]
        mov     bx, offset PartitionPointers
    PGPN_SearchLoop:
        cmp     word ptr ds:[bx], si
        je      PGPN_Found
        add     bx, 2
        dec     dl
        jnz     PGPN_SearchLoop
        mov     dl, 0FFh
        ret

    PGPN_Found:
        sub     dl, ds:[PartitionPointerCount]
        dec     dl
        not     dl
        ret
PART_GetPartitionNumber         EndP


;
; Following functions are only usable, when Partition-Pointer-View is filtered
;

; They will convert from and to unfiltered view (used in Boot-Menu)
;        In: DL - Number of partition in filtered view
;       Out: DL - Number of partition in straight view
;
; This gets the address of the IPT-entry from the Partition Pointer Table and
; converts that to an index into the IPT; the straight view.
;
PART_ConvertToStraight          Proc Near
        ;movzx   bx, dl
        mov   bl,dl                                 ; Partition number to BX
        mov   bh,0

        shl     bx, 1                               ; Convert to word index
        mov     ax, word ptr cs:[PartitionPointers+bx]  ; Get the partition pointer
        cmp     ax, offset FloppyIPTentry           ; Check for Floppy
        jb      PCTS_IsBIOSbootSeq                  ; Nope, is BIOS-bootseq
        je      PCTS_IsFloppy                       ; Is Floppy

; [Linux support removed since v1.02]
;   cmp     ax, offset LINUX_KernelEntries
;   jae     PCTS_IsKernelEntry

        ;
        ; Is partition, AX contains pointer to IPT entry
        ;
        sub     ax, offset PartitionTable       ; Make relative
        mov     bl, LocIPT_LenOfIPT             ; Length of IPT entry
        div     bl                              ; Divide with IPTlength
        mov     dl, al                          ; Index in IPT
        ret

; [Linux support removed since v1.02]
;  PCTS_IsKernelEntry:
;   mov     dl, 0FDh
;   ret

    PCTS_IsBIOSbootSeq:
        mov     dl, 0FEh
        ret
    PCTS_IsFloppy:
        mov     dl, 0FFh
        ret
PART_ConvertToStraight          EndP



;        In: DL - Number of partition in straight view
;       Out: DL - Number of partition in filtered view
;
; This searches for the absolute offset of an IPT-entry in the
; PartitionPointers table.
; This table holds the offsets of IPT partition entries that are in the Menu ?
; If the offset/entry is found it's index, the filtered number, is returned.
;
PART_ConvertFromStraight        Proc Near    Uses es di
;!
;! DEBUG_PROBE
;!
IFDEF   AUX_DEBUGx
    push    1243h
    call    DEBUG_Probe
ENDIF

        cmp     dl, 0FEh
        jb      PCFS_IsPartition
        mov     ax, offset BIOScontIPTentry
        je      PCFS_DoSearch
        mov     ax, offset FloppyIPTentry
        jmp     PCFS_DoSearch


    PCFS_IsPartition:
        ; First we get Partition-Offset in AX
        ;movzx   ax, dl
        mov   al,dl                         ; Index in IPT to AX
        mov   ah,0
        mov     bl, LocIPT_LenOfIPT         ; Length of an IPT entry
        mul     bl                          ; Mul to get relative offset
        add     ax, offset PartitionTable   ; Add to get absolute offset

        ;
        ; AX now points to the IPT entry of the partition.
        ; This address is searched for in the Partition Pointer Table.
        ;

    PCFS_DoSearch:
        ; Now search for this offset in our filtered Partition-Pointer-Table
        push    cs
        pop     es
        mov     di, offset PartitionPointers    ; Point to table
        mov     cx, LocIPT_MaxPartitions        ; Max number of entries to search
        xor     dl, dl                          ; Reply on Not-Found = Partition==0
        repne   scasw                           ; Compare-Loop
        jne     PCFS_NotFound
        sub     di, 2                           ; One Back, so point to compared value
        mov     dx, di                          ; Offset in DX
        sub     dx, offset PartitionPointers    ; Make relative
        shr     dx, 1                           ; Convert to Index
    ; Adjust for IncludeFloppy/etc. is automatically done, due Pointer-LookUp
    PCFS_NotFound:
        ret
PART_ConvertFromStraight        EndP



;        In: AX - Pointer to IPT Entry
;       Out: SI - Pointer to corresponding Size-Element
; Destroyed: AX
PART_GetSizeElementPointer      Proc Near   Uses bx
; [Linux support removed since v1.02]
;   cmp     ax, offset LINUX_KernelEntries
;   jae     PGSEP_IsKernelEntry
        mov     si, offset PartitionSizeTable
        sub     ax, offset PartitionTable
;   jmp     PGSEP_Continue
; [Linux support removed since v1.02]
;  PGSEP_IsKernelEntry:
;   mov     si, offset LINUX_KernelSizeTable
;   sub     ax, offset LINUX_KernelEntries
;  PGSEP_Continue:
        mov     bl, LocIPT_LenOfIPT
        div     bl                            ; Divide with IPTlength
        ;movzx   bx, al
        mov   bl,al
        mov   bh,0

        shl     ax, 1
        shl     bx, 2
        add     ax, bx                        ; My way of multiplying with 6
        add     si, ax                        ; SI - Partition Size-Element
        ret
PART_GetSizeElementPointer      EndP

;        In: BX:AX - Sector Size (1=512 Bytes, 2=1024 Bytes, etc.)
;            ES:DI - Pointer to Size-Element (6 bytes)
;       Out: None, Size-Element filled out
; Destroyed: AX, BX, DI
PART_FillOutSizeElement         Proc Near   Uses cx dx
        add     di, 3                         ; ES:DI - Last Digit of Size Digits
        shr     bx, 1
        rcr     ax, 1                         ; /2 -> Sector Size is now KByte Size
        xor     cl, cl                        ; 0 - KByte, 1 - MByte, 2 - GByte
    PFOSE_MakeSmallerLoop:
        or      bx, bx
        jnz     PFOSE_MakeSmaller
        cmp     ax, 9999
        jbe     PFOSE_IsSmallEnough
    PFOSE_MakeSmaller:
        mov     dx, bx
        and     dx, 1023                   ; My crazy way of dividing a 32-bit
        shr     ax, 10                     ; value through 1024 using 16-bit
        shr     bx, 10                     ; instructions...
        shl     dx, 6
        or      ax, dx
        inc     cl                         ; Value got smaller...
        jmp     PFOSE_MakeSmallerLoop

    PFOSE_IsSmallEnough:
        ; First write the type of this Size-Element (KB/MB/GB)
        mov     bx, 'BK'
        cmp     cl, 1
        jb      PFOSE_WriteType
        je      PFOSE_IsMBtype
        mov     bx, 'BG'
        jmp     PFOSE_WriteType
    PFOSE_IsMBtype:
        mov     bx, 'BM'
    PFOSE_WriteType:
        mov     word ptr es:[di+1], bx
        mov     bx, 10                        ; Digits are 10-Based
        xor     dx, dx
    PFOSE_DigitLoop:
        xor     dx, dx
        div     bx                         ; AX - Digit, DX - Remainder
        add     dl, '0'                    ; Convert digit to ASCII digit
        mov     es:[di], dl
        or      ax, ax
        jz      PFOSE_EndOfDigitLoop
        dec     di                         ; Go to previous char
        jmp     PFOSE_DigitLoop

    PFOSE_EndOfDigitLoop:
        ret
PART_FillOutSizeElement         EndP











; This routine is called to hide a partition
;        In: DL - Partition to hide
; Destroyed: None
PART_HidePartition              Proc Near   Uses ax bx cx dx si di
        call    PART_GetPartitionPointer      ; Pointer to partition (DL) -> SI

        ; First load the partition table of that partition...
        mov     ax, wptr [si+LocIPT_AbsolutePartTable+0]
        mov     bx, wptr [si+LocIPT_AbsolutePartTable+2]
        mov     cx, wptr [si+LocIPT_LocationPartTable+1]
        mov     dh, bptr [si+LocIPT_LocationPartTable+0]
        mov     dl, [si+LocIPT_Drive]
        call    DriveIO_LoadPartition
        ; Partition-Table now LOADED
        mov     di, offset PartitionSector+446 ; ES:DI - 1st partitionentry...

        ; Put our partition's location into registers...
        mov     ax, wptr [si+LocIPT_AbsoluteBegin+0]
        mov     bx, wptr [si+LocIPT_AbsoluteBegin+2]
        sub     ax, wptr [si+LocIPT_AbsolutePartTable+0]
        sbb     bx, wptr [si+LocIPT_AbsolutePartTable+2]
        ; BX:AX - absolute position of partition relative to partition table
        ; ...and search for it...
    PHP_SearchLoop:
        cmp     ax, wptr es:[di+LocBRPT_RelativeBegin]
        jne     PHP_SearchMismatch
        cmp     bx, wptr es:[di+LocBRPT_RelativeBegin+2]
        jne     PHP_SearchMismatch
        jmp     PHP_SearchMatch
    PHP_SearchMismatch:
        add     di, LocBRPT_LenOfEntry     ; 16 Bytes per partition entry
        cmp     di, 500+offset PartitionSector
        jb      PHP_SearchLoop
        jmp     MBR_HaltSystem                ; not found, something is wrong here

    ; Found entry...
    PHP_SearchMatch:
        mov     al, bptr es:[di+LocBRPT_SystemID] ; Partition-ID into AL
        call    PART_SearchFileSysHiddenID    ; Put on =STEALTH=
        mov     bptr es:[di+LocBRPT_SystemID], al
    IFDEF ReleaseCode
        call    DriveIO_SavePartition      ; Saves Partition-Table
    ENDIF
        ret
PART_HidePartition              EndP





; This here is for marking the first "good" non-hidden partition as being
;  active. It requires the partition table at EXECBASE.
;  Some BIOSes have problems with no primary marked active. Actually this is
;  a buggy implementation, because the MBR-code should normally check,
;  *not* the BIOS. This one *could* cause havoc to some systems, but I can't
;  do anything else.
PART_MarkFirstGoodPrimary       Proc Near   Uses ax si di
    mov     di, offset PartitionSector+446 ; DS:SI - 1st partitionentry
    ; First action to do: Remove the active flag from every partition
    push    di
        mov     cl, 4
    PMPP_RemoveActiveFlagLoop:
        and     bptr es:[di+LocBRPT_Flags], 7Fh
        add     di, LocBRPT_LenOfEntry
        dec     cl
        jnz     PMPP_RemoveActiveFlagLoop
    pop     di
    ; First Search, will hit on any PartitionID that is:
    ; a) not 0
    ; b) not hidden
    ; c) not extended partition (05h or 0Fh)
    PMPP_Search1Loop:
        mov     al, bptr es:[di+LocBRPT_SystemID]
        or      al, al
        jz      PMPP_Search1NoHit
        cmp     al, 05h
        je      PMPP_Search1NoHit
        cmp     al, 0Fh
        je      PMPP_Search1NoHit
        mov     bl, al                     ; BL == AL == PartitionID
        push    si
        call    PART_SearchFileSysName
        pop     si                         ; AL == UnhiddenPartitionID
        cmp     al, bl                     ; if ID is unhidden...
        je      PMPP_SearchHit
        PMPP_Search1NoHit:
        add     di, LocBRPT_LenOfEntry     ; 16 Bytes per Partition-Entry
        cmp     di, 500+offset PartitionSector
        jb      PMPP_Search1Loop

        mov     di, offset PartitionSector+446 ; DS:SI - 1st Partition-Entry
    ; Second Search, hit on anything that is not an extended partition
    ;  (05 or 0Fh)
    PMPP_Search2Loop:
        mov     al, bptr es:[di+LocBRPT_SystemID]
        or      al, al
        jz      PMPP_Search2NoHit
        cmp     al, 05h
        je      PMPP_Search2NoHit
        cmp     al, 0Fh
        jne     PMPP_SearchHit
        PMPP_Search2NoHit:
        add     di, LocBRPT_LenOfEntry     ; 16 Bytes per Partition-Entry
        cmp     di, 500+offset PartitionSector
        jb      PMPP_Search2Loop
        jmp     PMPP_SearchFailed

    PMPP_SearchHit:
        or      bptr es:[di], 80h             ; SET ACTIVE PARTITION
    PMPP_SearchFailed:
        ret
PART_MarkFirstGoodPrimary       EndP

; Searches the Name and Flags to a FileSysID (PartitionID)
;        In: AL - FileSysID
;       Out: AL - Unhidden File-System-ID, AH - Flags for this File-System
;            SI - Pointer to Name (8char)
; Destroyed: *none*
PART_SearchFileSysName          Proc Near  Uses bx dx
        ;movzx   bx, al
        mov   bl,al
        mov   bh,0

        mov     si, offset FileSysIDs
    PSFSN_SearchLoop:
        lodsw                              ; AL - NormalID, AH-HiddenID
        mov     dl, ds:[si]                ; DL - File-System-Flags
        inc     si
        cmp     al, bl                     ; Check, if Unhidden-ID matches...
        je      PSFSN_Match
        cmp     ah, bl                     ; Check, if Hidden-ID matches...
        je      PSFSN_Match
        mov     al, bl                     ; So Unhidden-ID will be Original-ID
        cmp     ah, 0                      ; Unknown (last ID in table)
        je      PSFSN_Match
        inc     bh
        jmp     PSFSN_SearchLoop

    PSFSN_Match:
        ; AL is already Unhidden-ID
        mov     ah, dl
        ; AH is now the FileSystem-Flag
        ;movzx   bx, bh
        mov   bl,bh
        mov   bh,0

        shl     bx, 3   ; Offsets * 8
        mov     si, offset FileSysNames
        add     si, bx
        ret
PART_SearchFileSysName          EndP

; Searches the Hidden ID corresponding to a FileSysID (PartitionID)
;        In: AL - FileSysID
;       Out: AL - Hidden File-System-ID
PART_SearchFileSysHiddenID      Proc Near  Uses bx
        ;movzx   bx, al
        mov   bl,al
        mov   bh,0

        mov     si, offset FileSysIDs
    PSFSHI_SearchLoop:
        lodsw                              ; AL - NormalID, AH-HiddenID
        inc     si
        cmp     al, bl                     ; Check, if Unhidden-ID matches...
        je      PSFSHI_Match
        cmp     ah, bl                     ; Check, if Hidden-ID matches...
        je      PSFSHI_Match
        mov     ah, bl                     ; So Unhidden-ID will get replied...
        cmp     ah, 0                      ; Unknown (last ID in table)
        je      PSFSHI_Match
        inc     bh
        jmp     PSFSHI_SearchLoop

    PSFSHI_Match:
        mov     al, ah                        ; AL = Hidden ID
        ret
PART_SearchFileSysHiddenID      EndP

;        In: DS:SI - Partition-Name, CX - Maximum/Total Length
;       Out: Carry-Flag set, if valid Partition-Name
; Destroyed: None
PART_CheckForValidPartName      Proc Near   Uses ax cx dx si
        ; Our logic is as follows:
        ;  If all chars are U -> Invalid (due reformated signature)
        ;  If anything below 32, but 0 -> Invalid (due invalid chars)
        ;  If anything above 165 -> Invalid (due invalid chars)
        ;  If anything between 123-128 -> Invalid (due invalid chars)
        ;  DX - holds count of 'U's
        push    cx
            or      cx, cx
            jz      PCFVPN_InvalidName
            xor     dx, dx
    PCFVPN_CheckLoop:
            lodsb
            cmp     al, 0
            je      PCFVPN_ValidChar
            cmp     al, 32
            jb      PCFVPN_InvalidName
            cmp     al, 165
            ja      PCFVPN_InvalidName
            cmp     al, 123
            jb      PCFVPN_ValidChar
            cmp     al, 128
            jbe     PCFVPN_InvalidName
    PCFVPN_ValidChar:
            cmp     al, 'U'
            jne     PCFVPN_NoMagic
            inc     dx
    PCFVPN_NoMagic:
          dec     cx
          jnz     PCFVPN_CheckLoop
        pop     cx
        cmp     cx, dx
        clc
        je      PCFVPN_WasMagic
        stc
    PCFVPN_WasMagic:
        ret
    PCFVPN_InvalidName:
        pop     cx
        clc
        ret
PART_CheckForValidPartName      EndP


; Rousseau: added
; Compare a volume-label in the IPT to the install-volume
; SI holds pointer to entry in IPT
; CY set if this entry is also the install-volume
PART_IsInstallVolume            Proc Near   Uses ax cx dx si di
        cld                                    ; Advance upwards with lodsb
        mov   di, offset eCS_InstallVolume     ; Address of install-volume label (max. 11 chars)

        mov   cx, 11                           ; Maximum length of label
        xor   dl, dl                           ; Not found yet

    ; Compare next character
    PART_IsInstallVolumeNext:
        lodsb                                  ; Load byte from SI (IPT-entry)
        ;cmp      al,' '                        ; If space then use zero
        ;jne      PART_IsInstallVolume_skip1
        ;xor      al,al
    PART_IsInstallVolume_skip1:
        xchg     ah,al                         ; Save char to AH
        xchg     si,di                         ; Exchange pointers
        lodsb                                  ; Load byte from SI (install-volume label)
        ;cmp      al,' '                        ; If space then use zero
        ;jne      PART_IsInstallVolume_skip2
        ;xor      al,al
    PART_IsInstallVolume_skip2:
        xchg     si,di                         ; Reexchange pointers
        ;~ call     AuxIO_Teletype
        call     CONV_ToUpper
        ;~ call     AuxIO_Teletype
        xchg     al,ah
        ;~ call     AuxIO_Teletype
        call     CONV_ToUpper
        ;~ call     AuxIO_Teletype
        ;~ call     AuxIO_TeletypeNL

        ; Are both of them zero ?
        ; Then the names could be the same, but cx must not equal 11
        ; because that would indicate a null-string.
        mov      dh,al
        or       dh,ah
        jz       PART_IsInstallVolumeFound

        cmp      ah,al                         ; Are the the same ?
        jnz      PART_IsInstallVolumeNotFound  ; Nope, compare ended
        loop     PART_IsInstallVolumeNext      ; Yep, Compare next character

    PART_IsInstallVolumeFound:
        ; If CX is still 11 this was a zero string
        ; and thus not a valid volume-name.
        ; This should not occur as this function is only called when the first
        ; byte is non-zero.
        cmp      cx,11
        je       PART_IsInstallVolumeNotFound
        ; Found !
        mov      dl,1                          ; Found
        jmp      PART_IsInstallVolumeEnd


    PART_IsInstallVolumeNotFound:
        mov      dl,0
        jmp      PART_IsInstallVolumeEnd


    PART_IsInstallVolumeEnd:
        ; Set the status in CY
        mov      al,dl
        add      al,'0'
        ;~ call     AuxIO_TeletypeHexByte
        ;~ call     AuxIO_TeletypeNL
        rcr      dl,1                          ; Put found-flag in CY
        ret
PART_IsInstallVolume            EndP





; Setup Phase1
; If found CY=1, AL=partnum, else CY=0, AL=0FFH
PART_SetupPhase1    Proc    Uses bx cx dx si di

        ;
        ; Enumberate Bootable Systems by name
        ; and prepare Phase 1 if active.
        ;
        ; This can also be implemented using the
        ; Installable LVM-flag I think.
        ; But at the time I had lesser knowledge about LVM...
        ; So this algorithm may change in the future.
        ;
        mov     byte ptr [Phase1Active],0   ; Clear phase1 indicator
        mov     si, offset PartitionTable   ; Pointer to IPT
        xor     cx,cx
        mov     cl,[CFG_Partitions]         ; Partitions in IPT

    ; Process next entry in IPT
    MBR_Parts:
        add     si, 4
        ;push    si
        ;push    si
        ;call    MBR_TeletypeVolName
        ;pop     si
        call    PART_IsInstallVolume        ; Check if this is install-volume
        jnc     MBR_Parts_NI

        ;
        ; Install Volume found
        ;
        mov     byte ptr [Phase1Active],1   ; Set phase1 indicator

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

        mov     dh,al


        mov     [CFG_PartAutomatic],al  ; Setup entry for install-volume
        mov     [CFG_PartLast],al

        add     al,'1'
        mov     bl,7
        mov     ah, 0eh
        int     10h

        mov     al,')'
        mov     bl,7
        mov     ah, 0eh
        int     10h

        ;mov     bx,cx       ; ????

        mov     al,dh
        stc
        jmp     PART_SetupPhase1_found

    MBR_Parts_NI:
        ;xor     si,si
        ;call    MBR_TeletypeNL
        ;pop     si
        add     si, 30      ; Add remainder of IPT entry
        loop    MBR_Parts

        mov     al,0ffh
        clc

    PART_SetupPhase1_found:

        ret

PART_SetupPhase1    EndP




;~ PART_GetOldPartitionCount   Proc    Uses    cx dx di
                ;~ mov     di,offset [PartitionXref]
                ;~ mov     dx,LocIPT_MaxPartitions
                ;~ mov     cx,dx
                ;~ mov     al,0ffh
                ;~ cld
                ;~ repne   scasb
                ;~ inc     cx
                ;~ sub     dx,cx
                ;~ mov     ax,dx
                ;~ ret
;~ PART_GetOldPartitionCount   EndP





;~ HELEMAAL NAKIJKEN !
;~ DRIVELETTER ASIGNMENT CORRIGEREN
;~ WORDT TOCH BOOTDRIVE IN BPB GEZET ALS NON eCS SYSTEEM BOOT ?



; ###################
; # START PARTITION #
; ###################

; Starts Partition DL from Internal Partition Table.
;        In: DL - Number of partition (filtered view)
;       Out: No Return...
; Destroyed: None, due to no return ;-)
;     Logic: - Harddrive:   loads partition Table
;                           sets partition active
;                           saves partition table
;                           hides partitions, if needed
;                           Linux-Support, if needed
;               load boot sector
;               VIBR checking, if wanted
;               install MBR Protection, if wanted
;               Special Boot Support, if needed (OS/2 Extended partitions)
;               Copy boot-sector to StartBase
;               run boot sector...
PART_StartPartition             Proc Near   Uses ax dx es di
    ;
    ; Local Storage for this much too large function.
    ;
    local BootPartNo:byte
    local PhysDiskBpbIndex:word     ; Index into BPB to field of phys-disk
    local FSType:byte               ; The FS used on the loaded BPB
                                    ; Only used for FAT/HPFS/JFS
    local LVMdl:byte                ; LVM drive-letter
    local BPBdl:byte                ; BPB boot-drive-letter. (at 25h)


    ; Get Partition-Pointer (SI) to Partition-To-Boot (DL).
    ; DL is filtered partition number and thus uses the PPT.
    ; Returned is the address of the IPT entry of the partition to boot.
    call    PART_GetPartitionPointer


    ;
    ; SI now points to the IPT entry for the partition to be booted.
    ;


    ; This converts DL filered view to straight view, aka index into the IPT.
    ; Needed for later.
    ; Destroys AX,BX
    call    PART_ConvertToStraight

    ; Save for later use.
    mov     [BootPartNo], dl
    ; Straight - FFh -> Floppy boot
    ;            FEh -> BIOS continue (CD-ROM, ZIP, etc.)

    ; This converts the PPT to have pointers to all the IPT entries.
    ; We need straight pointers from now on, so calculate the table...
    ; Destroys AX,BX,CX
    call    PART_CalculateStraightPartPointers



    ; SI contains the pointer to the IPT to what partition to boot
    ;  in this whole routine...it may never get messed up.

    ; ------------------------------------------------- PRINT NAME BEING BOOTED

    push    si
        mov     dl, [si+LocIPT_Drive]       ; Disk where partition resides
        mov     dh, [si+LocIPT_SystemID]    ; AB FileSystem ID (08=NTFS, FC=JFS)
        ; Copy Partition-Name to BootingNow area for display purposes
        add     si, LocIPT_Name             ; Advance to AB partition-name
        mov     cx, 11                      ; Max. length of AB name/label
        call    GetLenOfName                ; Returns CX with length of label
        mov     di, offset TXT_BootingNowPartName
        jz      PSP_NoName                  ; Don't copy if zero length label
        rep     movsb                       ; Copy label-name to boot
    PSP_NoName:
        xor     al, al                      ; Null-terminate label-string
        stosb              ; Ending Zero

        ;
        ; Display "Booting the system using "
        ;
        mov     si, offset TXT_BootingNow1
        call    MBR_Teletype


; [Linux support removed since v1.02]
;      cmp     dh, 0FDh
;      je      PSP_IsKernel

        ;~ pusha
        ;~ call    MBR_Teletype
        ;~ mov     si,offset TXT_BootingNowPartName
        ;~ call    MBR_Teletype
        ;~ popa


        ;
        ; DL will be zero for floppy-disk or 80h+ for harddisk.
        ; Note thus that DL contains the BIOS disk numer and not the AB value
        ; for floppy or cdrom.
        ;
        or      dl, dl
        jnz     PSP_IsHarddisc

        ; When booting floppy/CD-ROM/etc., we got other text to be displayed...
        mov     si, offset TXT_BootingNowPartName
        call    MBR_TeletypeVolName
        jmp     PSP_IsFloppyCDROMetc                                                ; JUMPS BUITEN SI POP !!! AANPASSEN


; [Linux support removed since v1.02]
;    PSP_IsKernel:
;      IFDEF ReleaseCode
;         ; Save configuration on HDD boots (save CFG_LinuxLastKernel)
;         call    DriveIO_SaveConfiguration
;      ENDIF
;      call    MBR_Teletype       ; Prints out BootingNow2 including KernelName
;      mov     si, offset TXT_BootingNowKernel
;      call    MBR_Teletype
;      jmp     PSP_IsFloppyCDROMetc


    PSP_IsHarddisc:


    IFDEF ReleaseCode
        ;
        ; Save configuration on HDD boots (save CFG_PartLast)
        ;
        call    DriveIO_SaveConfiguration
    ENDIF


        ;
        ; Prints out BootingNow2 including PartitionName
        ;
        mov     si, offset TXT_BootingNowPartName
        call    MBR_TeletypeVolName
        mov     si, offset TXT_BootingNowPartition
        call    MBR_Teletype

    ; restores SI (IPT-pointer)
    pop     si



    ;
    ; Get the CHS and LBA location of sector containing
    ; the partition-table for the partition.
    ;
    mov     ax, wptr [si+LocIPT_AbsolutePartTable+0]
    mov     bx, wptr [si+LocIPT_AbsolutePartTable+2]
    mov     cx, wptr [si+LocIPT_LocationPartTable+1]
    mov     dh, bptr [si+LocIPT_LocationPartTable+0]
    mov     dl, [si+LocIPT_Drive]

IFDEF   AUX_DEBUG
    pusha
    mov     si,offset ptetb
    call    AuxIO_Print
    call    DEBUG_DumpRegisters
    call    AuxIO_TeletypeNL
    mov     ax, word ptr [FreeDriveletterMap+00h]
    mov     dx, word ptr [FreeDriveletterMap+02h]
    call    AuxIO_TeletypeBinDWord
    popa
ENDIF


    ;
    ; This loads the MBR in case of PRI or the EBR in case of LOG partitions.
    ;
    call    DriveIO_LoadPartition         ; Load Table...                [LOAD]


    ; -------------------------------------------------- MODIFY PARTITION TABLE

    ; Make sure ES is correctly setup.
    push    cs
    pop     es

    ; ES:DI - First Partitionentry
    mov     di, offset PartitionSector+446

    ; Remove all active-flags for safety reasons, primary partition table will
    ; have one partition set active by ScanPartition-routine.
    push    di
        mov      cl, 4
    PSP_RemoveActiveFlagLoop:
        and      bptr es:[di+LocBRPT_Flags], 7Fh
        add      di, LocBRPT_LenOfEntry
        dec      cl
        jnz      PSP_RemoveActiveFlagLoop
    pop     di


    ;
    ; Put the partition-to-be-booted location into registers...
    ;
    mov     ax, wptr [si+LocIPT_AbsoluteBegin+0]
    mov     bx, wptr [si+LocIPT_AbsoluteBegin+2]
    sub     ax, wptr [si+LocIPT_AbsolutePartTable+0]
    sbb     bx, wptr [si+LocIPT_AbsolutePartTable+2]


    ; BX:AX - absolute position of partition relative to partition table
    ; ...and search for it...
    PSP_SearchLoop:
        cmp     ax, wptr es:[di+LocBRPT_RelativeBegin]
        jne     PSP_SearchMismatch
        cmp     bx, wptr es:[di+LocBRPT_RelativeBegin+2]
        jne     PSP_SearchMismatch
        jmp     PSP_SearchMatch
    PSP_SearchMismatch:
        add     di, LocBRPT_LenOfEntry     ; 16 Bytes per Partition-Entry
        cmp     di, 500+offset PartitionSector
        jb      PSP_SearchLoop

        ;
        ; Entry not found, Halt System.
        ;
        jmp     MBR_HaltSystem

    ; ------------------------------------------------------------- ENTRY FOUND
    PSP_SearchMatch:
        or      byte ptr es:[di+LocBRPT_Flags], 80h ; set ACTIVE partition



    IFDEF ReleaseCode
        ;
        ; Save the Partition Table.
        ;
        call    DriveIO_SavePartition     ; Saves the Partition-Table    [SAVE]
    ENDIF



    ; --------------------------------------------------------- OS/2 / eCS I13X
    ; Now check if the partition to get booted is above 8 GB.
    ;  If yes, set magic bytes 'I13X' at 3000:0 for boot-loader to recognize.
    ;  This method is (c) by IBM <g>
    ; Rousseau: Booting IBM-BM also requires the LBA address of the IBM-BM
    ; partitionafter the 'I13X' signature.
    ; Also, FS needs to be set to 3000H.
    ; This info was obtained by examining the LVM 2,x MBR-code.
    mov     ax, wptr [si+LocIPT_AbsoluteBegin+0]
    mov     bx, wptr [si+LocIPT_AbsoluteBegin+2]
    add     ax, wptr es:[di+LocBRPT_AbsoluteLength+0] ; Add length to absolute
    adc     bx, wptr es:[di+LocBRPT_AbsoluteLength+2] ; begin location
    ; BX:AX -> Absolute End-Position of Partition


    ;
    ; Always use INT13X v1.0.8.
    ;
    ;~ test    byte ptr [CFG_ForceLBAUsage], 1
    ;~ jnz     PSP_ForceI13X
    jmp     PSP_ForceI13X

    ; LBA-boundary at 16450560 (FB0400h) (16320x16x63)
    cmp     bx, 00FBh
    jb      PSP_NoI13X

    ;
    ; Setup 'I13X' signature.
    ;
    PSP_ForceI13X:
        push    es
        push    di
        push    si

            ; Setup ES and FS.
            ; FS needs to keep this address.
            mov     ax, 3000h
            mov     es, ax
            ; mov fs,ax
            db  08eh
            db  0e0h

            ; Insert signature
            xor     di, di
            mov     word ptr es:[di+00], '1I'
            mov     word ptr es:[di+02], 'X3'

            ;mov     wptr es:[di], 0
            ;mov     wptr es:[di+2], 0

            ; Insert LBA address.
            mov     ax, [si+LocIPT_AbsoluteBegin+0]
            mov     es:[di+04], ax
            mov     ax, [si+LocIPT_AbsoluteBegin+2]
            mov     es:[di+06], ax

        pop     si
        pop     di
        pop     es



    PSP_NoI13X:

        ; now check, if we need to hide any partition
        test    byte ptr [si+LocIPT_Flags], Flags_HideFeature
        jz      PSP_NoHideFeature

        ; ---------------------------------------------------- PARTITION HIDING

        ; display "hide active"
        push    si
            mov     si, offset TXT_BootingHide
            call    MBR_Teletype
        pop     si


        ; First, find Hide-Config
        mov     dl, [BootPartNo]           ; EntryNumber is straight view
        ;~ mov     ax, LocIPT_MaxPartitions
        mov     ax, LocHPT_LenOfHPT
        mul     dl
        mov     di, offset HidePartitionTable
        add     di, ax                     ; We got the pointer


        ; So process Hide-Config. Read out Bitfield-Entries,
        ; each points to a partition.
        ; 3Fh is end-marker / maximum entries = CFG_Partitions
        mov     cl, [CFG_Partitions]
        mov     ch,0        ; Index in bitfield array.
        mov     dh,6        ; Bitfield width.
        mov     bx,di       ; Pointer to entry.

    PSP_PartitionsHideLoop:
        mov     dl,ch
        call    CONV_GetBitfieldValue
        mov     dl,al

        ;~ mov     dl, es:[di]
        ;~ inc     di
        ;~ cmp     dl, 0FFh
        cmp     dl,3fh  ; Max value for 6-bits field.
        je      PSP_EndOfHideProcess    ; -> End of Hiding
        call    PART_HidePartition      ; Now hide that partition
        inc     ch      ; Next bitfield.
        dec     cl
        jnz     PSP_PartitionsHideLoop


    PSP_EndOfHideProcess:

        ; --- HIDE COMPLETED ---
        ; So something got hidden and we have to remark a primary partition,
        ;  if we are booting something non-primary from 1st hdd.
        cmp     bptr [si+LocIPT_Drive], 80h
        ja      PSP_HideAdjustPrimaryMark  ; When booting any hdd, but 1st
        mov     ax, wptr [si+LocIPT_AbsolutePartTable]
        mov     bx, wptr [si+LocIPT_AbsolutePartTable+2]
        or      ax, ax
        jnz     PSP_HideAdjustPrimaryMark  ; or booting non-primary partition
        or      bx, bx                     ;  on 1st harddrive.
        jz      PSP_NoHideAdjustPrimaryMark

    PSP_HideAdjustPrimaryMark:
        ; Load Primary Partition Table...
        xor     ax, ax
        xor     bx, bx
        mov     cx, 0001h                  ; Cylinder 0, Sector 1
        mov     dx, 0080h                  ; First HD, Head 0
                                                                     ; Load MBR
        call    DriveIO_LoadPartition      ; Load Primary Partition Table
        call    PART_MarkFirstGoodPrimary

    IFDEF ReleaseCode
        call    DriveIO_SavePartition       ; Saves the Partition-Table
    ENDIF


    PSP_NoHideAdjustPrimaryMark:


    PSP_NoHideFeature:
        ; Check, if we are supposed to ignore LVM altogether...
        test    byte ptr [CFG_IgnoreLVM], 1
        jnz     PSP_NoLVMReassignment

        ; ---------------------------------------------------- LVM REASSIGNMENT

        ; Driveletter must be set for this partition
        test    byte ptr [si+LocIPT_Flags], Flags_DriveLetter
        jz      PSP_NoLVMReassignment
        ;movzx   bx, BootPartNo              ; EntryNumber is straight view
        mov     bl,[BootPartNo]               ; EntryNumber is straight view
        mov     bh,0

        mov     al, bptr [DriveLetters+bx]
        sub     al, 3Dh                     ; Convert e.g. 80h -> 'C'
        cmp     al, bptr [PartitionVolumeLetters+bx]


        ;~ je      PSP_NoLVMReassignment   ; If driveletters match -> no change
        ; Rousseau:
        ; But there can still be other partitions with the same drive-letter.
        ; For instance if the user did an advanced installation with multiple
        ; eComStation systems using the same boot-drive-letter.
        ; So, even if the drive-letter forced is the same as the
        ; partition-volume-letter, other partitions still need to be checked
        ; and possibly hidden. So we always do the drive-letter reassignment,
        ; which is enhanced to keep data-partitions (those -not- in the Menu)
        ; visible. So the 'je' instruction above is commented-out.


        ;
        ; Give partition SI letter AL
        ;
        call    LVM_DoLetterReassignment




    PSP_NoLVMReassignment:
        push    si
        ; -------------------------------------------------- -"PLEASE WAIT..."-
    PSP_IsFloppyCDROMetc:
            mov     si, offset TXT_BootingWait
            call    MBR_Teletype               ; display "please wait"                      ; SI staat nog op stack; aanpassen !!!!
        pop     si

        ; Process Partition Tables, if M$-Hack required (changes Ext Part Type)
        call    MSHACK_ProcessPartTables

        test    byte ptr [CFG_BootMenuActive], 0FFh
        jz      PSP_NoMenuNoSound

        ; ---------------------------------------------------------- BOOT-SOUND
        call    SOUND_ExecuteBoot

    PSP_NoMenuNoSound:

        ; --------------------------------------------- SPECIAL BOOT PROCESSING
        ; Check here, if the Boot shall be done via resume to BIOS...
        mov     al, byte ptr [si+LocIPT_SystemID]
        cmp     al, 0FEh        ; Via BIOS ? (aka resume BIOS boot sequence)
        je      PSP_ResumeBIOSbootSeq

; [Linux support removed since v1.02]
;   cmp     al, 0FDh                        ; Kernel-Booting ?
;   je      PSP_KernelBooting

        jmp     PSP_StartNormal

    PSP_ResumeBIOSbootSeq:
        int     18h                         ; Give control back to BIOS
        db      0EAh                        ; if return to here -> Reboot
        dw      0FFF0h
        dw      0F000h

; [Linux support removed since v1.02]
;  PSP_KernelBooting:
;   call    LINUX_LoadKernel              ; DS:SI - Entry Pointer to Kernel
;   db      0EAh                          ; if return to here -> Reboot
;   dw      0FFF0h
;   dw      0F000h



    ; =======================================================================
    ;  FROM THIS POINT ON, ONLY DS and SI REGISTER IS NEEDED TO BE PRESERVED
    ; =======================================================================

    PSP_StartNormal:
        mov     ax, wptr [si+LocIPT_AbsoluteBegin+0]
        mov     bx, wptr [si+LocIPT_AbsoluteBegin+2]
        mov     cx, [si+LocIPT_LocationBegin+1]
        mov     dh, [si+LocIPT_LocationBegin+0]
        mov     dl, [si+LocIPT_Drive]

        ; This loads the PBR of the partition.
        call    DriveIO_LoadPartition   ; Loads boot-sector...   [PARTBOOTSEC]

        ;
        ; The JFS PBR-code does not use the passed BPB in memory but uses the BPB
        ; on disk. This breaks the drive-letter feature on JFS.
        ; So we make a copy of the PBR in memory, and if the partition is JFS
        ; we later adjust the physical-disk and boot-drive-letter in this
        ; copy and write it back to disk.
        ; Then the JFS PBR-code will see the correct boot-drive-letter.
        ;
        pusha
            mov     si,offset [PartitionSector]
            mov     di,offset [PBRSector]
            mov     cx,100h
            cld
            rep     movsw
        popa



        ; Check if the disk is a harddisk or a floppy.
        mov     dl,[si+LocIPT_Drive]
        cmp      dl, 80h
        jae      is_harddisk

        ;
        ; This is a dirty hack to fix booting from a floppy.
        ; With all the modifications made since v1.06 this feature was broken
        ; because Int13X is used implicitly now, and that does not work
        ; for diskette access.
        ; This jumps to the code that loads and starts the pbr-code.
        ; Note that it also skips virus checking !
        ; This will be fixed at a later date.
        jmp     boot_from_floppy

    ;
    ; The disk is a harddisk so we need to do various checks and fixes.
    ;
    is_harddisk:

        test    byte ptr [CFG_DetectVIBR], 1
        jz      PSP_NoVIBR
        test    byte ptr [si+LocIPT_Flags], Flags_VIBR_Detection
        jz      PSP_NoVIBR

        ; ----------------------------------------------------- CHECKS FOR VIBR
        push    si
            mov     si, offset PartitionSector
            mov     bx, 4B4Dh               ; Magic: 'MK'
            call    MBR_GetCheckOfSector
        pop     si

        cmp     [si+LocIPT_BootRecordCRC], bx
        je      PSP_NoVIBR
        mov     bx, [si+LocIPT_BootRecordCRC]
        or      bx, bx
        jz      PSP_NoVIBR
        ; Oh Oh, got a virus :(
        mov     si, offset TXT_VirusFoundMain
        call    MBR_Teletype
        mov     si, offset TXT_VirusFound2 ; VIBR-Virus
        call    MBR_Teletype
        mov     si, offset TXT_VirusFoundEnd
        call    MBR_Teletype
        jmp     MBR_HaltSystem

    PSP_NoVIBR:
       test    byte ptr [CFG_ProtectMBR], 1
       jz      PSP_NoMBRprotect
        ; --------------------------------------------- INSTALLS MBR-PROTECTION
        ; We need DS:SI later...
        push    ds
        push    si

            ; First subtract 1024 bytes from Base-Memory...
            push    ds
                mov     ax, 40h
                mov     ds, ax
                mov     dx, word ptr ds:[13h]
                dec     dx                      ; 1 == 1kbyte
                mov     word ptr ds:[13h], dx
            pop     ds
            shl     dx, 6                      ; trick, now DX is a segment

            ; Now copy in our code (to DX:0)...

            mov     si, offset MBR_Protection  ; DS:SI - Source Image
            mov     es, dx
            xor     di, di                     ; ES:DI - Destination
            ;~ mov     cx, 512
            mov     cx, 384
            rep     movsw                      ; Move 768 bytes...

            ; Now fill in variables...

            xor     ax, ax
            mov     ds, ax
            mov     si, 10h*4
            xor     di, di                     ; INT 10h Vector to MBR Protection
            ;movsd
            movsw
            movsw

            mov     si, 13h*4                  ; INT 13h Vector to MBR Protection
            ;movsd
            movsw
            movsw

            mov     al, CFG_IgnoreWriteToMBR   ; Option to MBR Protection
            stosb

            ; Now switch INT 13h vector to MBR Protection

            sub     si, 4
            mov     ax, 9
            mov     ds:[si], ax
            mov     ds:[si+2], dx              ; Vector hardcoded at DS:0009
            ; MBR-Protection now active :)

        ; Restore DS:SI
        pop     si
        pop     ds



    PSP_NoMBRprotect:

        ; Display volume-name in bold
        ; Just before booting the selected partition
        ;pushf
        ;pusha
        ;push    si
        ;add     si, LocIPT_Name
        ;call    MBR_TeletypeVolName
        ;xor     si,si
        ;call    MBR_TeletypeNL
        ;pop     si
        ;popa
        ;popf





   ; ------------------------------------------------ SPECIAL PARTITION SUPPORT
   ; needed by OS/2 Warp / eComStation


        ;cmp     byte ptr [si+LocIPT_SystemID],08    ; I hate Microsuck NTFS check
        mov     di, offset PartitionSector ; ES:DI - Actual Boot-Record

        ; Special Support Detection
        ;mov     ax, word ptr es:[di+18h]
        ;cmp     ax, 003Fh                  ; Physical Layout-Sectors... Safety check



        ;
        ; At this point, SI points to IPT and DI points to the PBR from disk.
        ; Depending on the type of BPB used, the physical disk field is at
        ; different locations: 24h for old-style (OS/2) BPB's and 40h for
        ; FAT32 BPB's.
        ; The OS/2 boot-drive-letter is located at 25h in an old-style BPB,
        ; while the corresponding field in a FAT32 BPB is located at 41h but
        ; used for different purposes.
        ; In case of HPFS, using old-style BPB's, the boot-drive-letter needs
        ; to be adjusted if it is zero.
        ; In that case we trace the LVM-info for that partition and use the
        ; drive-letter defined there.
        ; This fixes issues #3067 and #3119.
        ; Adjusting the physical disk is always done but at different locations
        ; depending on the BPB used.
        ; Also, the "hidden sectors" field is adjusted to contain the absolute
        ; offset from the start of the disk instead of the relative offset to
        ; the start of the partition.
        ; http://homepage.ntlworld.com./jonathan.deboynepollard/FGA/bios-parameter-block.html
        ;


        ; Get index of phys-disk field in BX
        call    PART_GetFieldIndex
        mov     [PhysDiskBpbIndex],ax
        mov     bx,ax

        ; Locate cursor for output of debug-info
        ;~ pusha
        ;~ mov     ch,7
        ;~ mov     cl,0
        ;~ call    VideoIO_Color
        ;~ mov     ch,6
        ;~ mov     cl,1
        ;~ call    VideoIO_Locate
        ;~ popa


        ; Debug display physdisk, ptype and physdisk offset in BPB
        ;~ pusha
        ;~ mov     ah,[si+LocIPT_Drive]
        ;~ mov     al,[si+LocIPT_SystemID]
        ;~ call    VideoIO_PrintHexWord
        ;~ mov     ax,bx
        ;~ call    VideoIO_PrintHexWord
        ;~ mov     ax,[si+LocIPT_AbsolutePartTable+02]
        ;~ call    VideoIO_PrintHexWord
        ;~ mov     ax,[si+LocIPT_AbsolutePartTable+00]
        ;~ call    VideoIO_PrintHexWord
        ;~ mov     al,[ExtendedAbsPosSet]
        ;~ call    VideoIO_PrintHexByte
        ;~ mov     al,'-'
        ;~ call    VideoIO_PrintSingleChar
        ;~ mov     al,byte ptr [Menu_EntrySelected]
        ;~ call    VideoIO_PrintHexByte
        ;~ mov     al,byte ptr [CFG_PartAutomatic]
        ;~ call    VideoIO_PrintHexByte
        ;~ mov     al,byte ptr [Phase1Active]
        ;~ call    VideoIO_PrintHexByte
        ;~ mov     al,byte ptr [NewPartitions]
        ;~ call    VideoIO_PrintHexByte
        ;~ mov     al, byte ptr [OldPartitionCount]
        ;~ call    VideoIO_PrintHexByte
        ;~ popa


        ;
        ; If the partition is IBM-BM we skip all the BPB adjustments.
        ; IBM-BM does no need them.
        ;
        cmp     byte ptr [si+LocIPT_SystemID], 0ah
        jnz     no_os2_bm
        jmp     chainload_ibm_bm


    no_os2_bm:

        ;
        ; Update the phys-disk field
        ; DI points to PartitionSector
        ; BX holds index to phys-disk field
        ;
        mov     al,byte ptr [si+LocIPT_Drive]                                       ; Moet dit niet later gebeuren ??? (NT/WIN LDR hangs)
        mov     es:[di+bx],al


        ;
        ; Legacy systems do not put the correct values in the "hidden sectors"
        ; field. Also, this field will be incorrect if a partition is moved on
        ; disk by a disktool not accounting for this field.
        ; Linux does not have a BPB at all, and does not use this field.
        ; So we set the correct value here obtained by the partition scanner.
        ; This fixing is done by OS/2 BM as well, according to Martin.
        ;

        ;
        ; Fix hidden sectors field
        ;
        mov     ax,[si+LocIPT_AbsoluteBegin]
        mov     es:[di+1ch], ax     ; Low word of 32-bits "hidden sectors"

        mov     ax,[si+LocIPT_AbsoluteBegin+2]
        mov     es:[di+1eh], ax     ; High word of 32-bits "hidden sectors"

        ;
        ; Check partitions to see if boot-drive-letter fixing is needed.
        ; FAT12/FAT16/HPFS/JFS will have the value at 25h fixed
        ; to the LVM-info drive-letter. (+3dh to convert to BIOS notation)
        ;


        ; Setup partition disk and LBA address
        mov     dl,byte ptr [si+LocIPT_Drive]
        mov     cx,[si+LocIPT_AbsoluteBegin+00h]
        mov     bx,[si+LocIPT_AbsoluteBegin+02h]

        ; AL is gonna be used to shift-in CY status.
        ; If the type of file-system is one of FAT12/FAT16/HPFS/JFS then
        ; AL will be <> 0 and the boot-drive-letter can be tested / fixed.
        mov     al,0


        ; FIXME:
        ; The PBR is already loaded, no need to load it again in the
        ; calls below.
        ;
        ; Better use the already done discovery to determine the system.
        ;

        ; When FAT12/FAT16/HPFS/JFS then boot-drive-letter can be tested
        ; or adjusted.
        call    PART_IsJFS
        rcl     al,1
        call    PART_IsHPFS
        rcl     al,1
        call    PART_IsFAT
        rcl     al,1
        mov     ah,al

        ; Store for later reference.
        mov     [FSType],al


        ;
        ; When the phys-disk byte (80h) is put in this BPB in RAM,
        ; Windows will not find it's loader if Windows itself
        ; is installed in a logical partition but the loader is on FAT
        ; in a primary.
        ; This goes for all NT-based versions ?
        ;


        ;
        ; See if phys-disk / boot-drive-letter fix is needed
        ; depending on FS used.
        ; AL will be 0 for any file-system other than FAT12/FAT16/HPFS/JFS.
        ; In that case no fixing of boot-drive-letters is needed.
        ;
        test    al,al
        jz      bdl_ok


        ;
        ; We have a partition that potentially can have incorrect values
        ; for the boot-drive-letter or incorrect LVM drive-letters.
        ;
        ; The boot-drive-letter can be zero as the result of copying / moving
        ; partitions or restoring a HPFS system from archive.
        ; In that case the LVM drive-letter is used if present.
        ;
        ; Incorrect LVM drive-letters are the result of the drive-letter
        ; reassign function when two or more eComStation installations use the
        ; same boot-drive-letter.
        ; In that case the boot-drive-letter is assigned to the
        ; LVM drive-letter.
        ;
        ; If both are zero there is no way to obtain the correct
        ; boot-drive-letter value. The user needs to examine CONFIG.SYS and
        ; force that letter for the partition.
        ;





        ;
        ; Get the drive-letter for the partition from the LVM-info.
        ; Returns CY=1 if AL contains drive-letter, CY=0 and AL=0 if
        ; no letter assigned (hidden) or no LVM info found.
        ;
        mov     dl,byte ptr [si+LocIPT_Drive]
        mov     cx,[si+LocIPT_AbsoluteBegin+00h]
        mov     bx,[si+LocIPT_AbsoluteBegin+02h]
        call    LVM_GetDriveLetter


        ; Save for later use.
        mov     byte ptr [LVMdl], al

        ; See if the drive-letter feature is active.
        ; If active, we force the drive-letter from the user.
        test    byte ptr [si+LocIPT_Flags], Flags_DriveLetter

        ; Nope, it's not so we don't force the boot-drive-letter.
        jz      PSP_NoLogicalSupport

        ; Partition index in BX
        mov     bl,[BootPartNo]     ; EntryNumber is straight view
        mov     bh,0

        ; Get the user specified boot-drive-letter.
        ; 80h notation.
        mov     al, bptr [DriveLetters+bx]

        ; Safety check for zero value.
        test    al,al
        jz      PSP_NoValidUserDriveLetter

        ; Convert 80h notation to ASCII.
        sub     al,3dh              ; 80h - 3dh = 43h = 'C', etc.

    PSP_NoValidUserDriveLetter:
        ; Here we misuse the LVM-dl storage to store the user forced
        ; or zero drive-letter.
        mov     byte ptr [LVMdl], al


    PSP_NoLogicalSupport:

        ; A possibly valid drive-letter has been obtained from either
        ; LVM-info or the drive-letter feature.
        ; It's in [LDMdl] local storage.



        ;
        ; Get the boot-drive-letter from the BPB of the partition.
        ;
        mov     bx, [PhysDiskBpbIndex]
        inc     bx
        mov     al,es:[di+bx]       ; 80h=C:,81h=D:, etc.
        ; Store it for later use
        mov     byte ptr [BPBdl], al


        ; See if both the LVM drive-letter and the BPB drive-letter are zero.
        ; If so, then we have a problem.
        ; No valid drive-letter can be obtained and the user has to examine
        ; CONFIG.SYS and set that letter in the drive-letter feature
        ; for the partition.
        mov     ah,al
        mov     al, byte ptr [LVMdl]
        or      al,ah
        jz      no_valid_boot_drive_letter_found


        ; See if both the LVM drive-letter and the BPB drive-letter are
        ; the same. In that case we should have a valid situation and no
        ; adjustments need to be made.
        cmp     al,ah
        jz      PSP_valid_boot_drive


        ;
        ; Ok, at least one of them is valid.
        ;

        ; See if the BPB boot-drive-letter is valid
        ; This one is supposed not to change since eCS cannot be booted
        ; from another drive then it was installed on.
        test    ah,ah
        jnz     BPB_boot_drive_valid

        ; Nope it's not.
        ; So we use the LVM drive-letter for the BPB boot-drive-letter.
        ; Convert to BIOS notation ('C'+3dh=80h, 'D'->81h, etc.)
        ; This is where the user can fix this issue by using the
        ; drive-letter feature.
        add     al,3dh
        mov     bx,[PhysDiskBpbIndex]
        ; Advance to field for drive-letter in BIOS notation (OS/2 - eCS)
        inc     bx
        ; Fix the boot-drive-letter field in the BPB
        mov     es:[di+bx],al

        jmp     PSP_valid_boot_drive

        ;
        ; OS/2 uses this field to indicate the boot-drive-letter for the system.
        ; It is in BIOS notation where 80h='C', 81h='D' ... 97h='Z'.
        ; This is the field that get's forced to a specific value when the
        ; drive-letter feature of AiR-BOOT is used.
        ; Also, this field is the culprit of AiR-BOOT v1.07 not handling it
        ; correctly when the system uses HPFS and this byte is zero.
        ; This mostly involved booting older eCS versions on HPFS.
        ; See issues #3067 and #3119 on http://bugs.ecomstation.nl
        ;


    ;
    ; Here we enter when the LVM drive-letter is zero or not the same
    ; as the BPB boot-drive-letter.
    ; This can be the case when booting a hidden partition, LVM-dl = zero,
    ; or the LVM-dl was reassigned because another system with the same
    ; drive-letter was booted previously.
    ; In any case, we set the LVM drive-letter to the BPB boot-drive-letter
    ; so the system can be booted.
    ; Driveletters on other partitions have already been reassigned by the
    ; reassignement-procedure earlier.
    ;
    BPB_boot_drive_valid:




        ;
        ; ALWAYS SET LVM to BPB
        ;
        ;~ mov     dl,byte ptr [si+LocIPT_Drive]
        ;~ mov     cx,[si+LocIPT_AbsoluteBegin+00h]
        ;~ mov     bx,[si+LocIPT_AbsoluteBegin+02h]
        ;~ mov     al,[BPBdl]
        ;~ sub     al,3dh
        ;~ call    LVM_SetDriveLetter                                                                  ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!


        ;
        ; ALWAYS SET BPB to LVM
        ;
        mov     dl,byte ptr [si+LocIPT_Drive]
        mov     cx,[si+LocIPT_AbsoluteBegin+00h]
        mov     bx,[si+LocIPT_AbsoluteBegin+02h]
        call    LVM_GetDriveLetter                                                                  ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        add     al,3dh
        mov     bx,[PhysDiskBpbIndex]
        inc     bx
        mov     es:[di+bx],al


    update_PBR:



    ;
    ; Here both the boot-drive-letter and the LVM drive-letter are zero.
    ; So the only way to determine the drive-letter is to examine CONFIG.SYS.
    ; Then force that drive-letter in the drive-letter feature.
    no_valid_boot_drive_letter_found:
        ; HERE SHOULD COME AN ERROR POP-UP ABOUT NO BOOT-DRIVE OR NO LVM-INFO.
        ; WE CONTINUE BOOTING BUT OS/2 - eCS WILL MOST PROBABLY FAIL TO BOOT.

        ; FIXME:
        ; ISSUE SOME KIND OF WARNING...

        ;mov     ah,07h
        ;mov     si,offset CheckID_MBR
        ;call    VideoIO_Print

    hang:
        ;jmp     hang




    PSP_valid_boot_drive:




    ;
    ; Boot DriveLetter OK.
    ;
    bdl_ok:


IFDEF   AUX_DEBUG
    pusha
    call    AuxIO_TeletypeNL
    mov     bx, [PhysDiskBpbIndex]
    inc     bx
    mov     al, [di+bx]
    call    AuxIO_TeletypeHexByte
    mov     bl,[BootPartNo]
    mov     al, [DriveLetters+bx]
    call    AuxIO_TeletypeHexByte
    mov     al, [PartitionVolumeLetters+bx]
    add     al, 3dh
    call    AuxIO_TeletypeHexByte
    mov     al, [LVMdl]
    add     al, 3dh
    call    AuxIO_TeletypeHexByte
    mov     al, [si+LocIPT_SystemID]
    call    AuxIO_TeletypeHexByte
    mov     al,[FSType]
    call    AuxIO_TeletypeHexByte
    popa
ENDIF

        ;
        ; If the partition getting booted is a JFS partition then write-back
        ; the modified PBR to the disk.
        ; Note that it's not the in-memory PBR that get's written back, but
        ; a copy of the original where only the phys-disk and boot-drive-letter
        ; are adjusted.
        ;
        pusha
        mov     al,[FSType]
        cmp     al,04h      ; JFS
        je      write_back_pbr
        cmp     al,02h      ; HPFS
        je      write_back_pbr

        jmp     no_jfs_pbr


    write_back_pbr:

        ; Save IPT pointer
        push    si

        ; Copy the boot-drive and boot-drive-letter fields.
        mov     si,offset [PartitionSector]
        mov     di,offset [PBRSector]
        mov     al,[si+24h]
        mov     [di+24h],al
        mov     al,[si+25h]
        mov     [di+25h],al

        ; Restore IPT pointer
        pop     si

        ; Setup the registers for the partition location.
        mov     ax, wptr [si+LocIPT_AbsoluteBegin+0]
        mov     bx, wptr [si+LocIPT_AbsoluteBegin+2]
        mov     cx, [si+LocIPT_LocationBegin+1]
        mov     dh, [si+LocIPT_LocationBegin+0]
        mov     dl, [si+LocIPT_Drive]

        ; Write the adjusted JFS PBR to disk.
        mov     si, offset [PBRSector]
        call    DriveIO_SaveSector

    no_jfs_pbr:
        popa


        ;xor     ax,ax
        ;int     16h





    ; ----------------------------------------------- LOGICAL PARTITION SUPPORT



    ; AiR-BOOT now works around it by using the LVM-info (DLAT) of
    ; the partiton if present.
    ; Note however that if the drive-letter feature is active,
    ; this will override AB's automatic fixing.
    ;
    ; Test if the drive-letter feature is active for this partition.
    ; If so, then the drive that the user defined will be placed at
    ; byte 25h (37d) of the in-ram PartitionSector (BPB).
    ; (BIOS 80h notation: 80h=C, 81h=D, etc.)
    ; This is a remedy for when the corresponding field (25h) in the BPB on
    ; disk is zero.
    ;



    ;
    ; Control is transferred to this point if we are booting IBM-BM.
    ; IBM-BM does not need the BPB fixes.
    ; It does require a other special stuff, which is already taken care of.
    ;
    chainload_ibm_bm:

    ;
    ; Control is transferred to this point if we are booting a floppy.
    ; Booting from floppy skips all the harddisk related stuff.
    ; This is a dirty hack to fix the boot from floppy feature.
    ;
    boot_from_floppy:

        ;
        ; Here we copy the prepared partition boot-record to 0000:7C00h
        ; to give it control later on.
        ;
        push    es
        push    si
        mov     ax, StartBaseSeg
        mov     es, ax
        mov     cx, 256
        mov     si, offset PartitionSector
        mov     di, StartBasePtr
        cld
        rep     movsw
        pop     si
        pop     es

    ; --------------------------------------------------- NOW START BOOT-RECORD




    IFDEF   AUX_DEBUG
        pusha
        call    DEBUG_Dump2
        ;~ call    DEBUG_DumpBSSSectors
        call    DEBUG_DumpDriveLetters
        call    DEBUG_DumpVolumeLetters
        call    AuxIO_TeletypeNL
        popa
    ENDIF



;
; ################################## BYE BYE ##################################
;

    IFNDEF  AUX_DEBUG
        ; Skip wait-for-key
        jmp StartPBR
    ENDIF

        ;
        ; Wait for keypress
        ;
        xor     ax, ax
        int     16h

        ; Is escape-key ?
        cmp     al, 1bh

        ; Nope, Go activate PBR loader
        jne      StartPBR

        ;push    ds
        ;pop     es

        ; Yep, restart AiR-BOOT so simulate load DX:BX with old BIOS SS:SP
        jmp     AirbootRestart

        ; Yep, Reenter bootmenu
        ;~ jmp     MBR_Main_ReEnterBootMenuPre



;
; Transfer control to the PBR
;
StartPBR:

        ; Debug display index
        ;pusha
        ;mov     al, cs:[si+LocIPT_Drive]        ; Drive Physical No
        ;mov     ah, cs:[si+LocIPT_SystemID]     ; SystemID
        ;call    VideoIO_PrintHexWord
        ;xor     ax, ax
        ;int     16h
        ;popa

        ;~ jmp     skip_delay


        ;
        ; Show dot's to indicate something is happening...
        ;
        call    VideoIO_ShowWaitDots

    ;
    ; Enter here to skip delay.
    ;
    skip_delay:




        ;
        ; BYE BYE   (prepare some registers? look at other MBR-code)
        ;
        xor     ax, ax
        xor     bx, bx
        xor     cx, cx
        mov     ds, ax
        mov     es, ax
        xor     dh, dh
        mov     dl, cs:[si+LocIPT_Drive]      ; Drive Physical No



        ; ###############################
        ; # JUMP TO THE PBR LOADER CODE #
        ; ###############################
        IFDEF ReleaseCode
            db      0EAh
            dw      StartBasePtr
            dw      StartBaseSeg
        ENDIF


PART_StartPartition             EndP








;
; ######################################
; # Is this a primary partition or not #
; ######################################
;
; In
; --
; DL    = Physical Disk
; BX:CX = LBA sector
;
; Out
; ---
; AX    = Index in PT if found, otherwise -1
; CY    = Set if Primary, clear if not
;
PART_IsPrimaryPartition Proc Near  Uses bx cx dx si di ds es
        ; Push LBA address of partition
        push     bx
        push     cx

        ; Load LBA sector 0 from the disk specified in DL
        xor      bx,bx
        xor      cx,cx
        mov      di,ds
        mov      si,offset [TmpSector]
        call     DriveIO_LoadSectorLBA

        ; Restore partitions LBA address to DI:SI
        pop      si
        pop      di

        ; Return with index -1 and CY clear if there was an
        ; error loading the sector.
        mov      ax,-1
        cmc
        jnc      PART_IsPrimaryPartition_exit

        ; Compare the partition address with each entry in the P-table
        mov      cx,4                    ; Nr. of PT-entries
        mov      dx,offset [TmpSector]
        add      dx,01beh+08h            ; Point DX to 1st partition address

    next_pe:
        ; Computer pointer to PE
        mov      bx,dx          ; Point BX to 1st partition address
        mov      ax,cx          ; Get PE-index
        dec      ax             ; Index is zero based so adjust it
        shl      ax,4           ; PE's are 16 bytes in size
        add      bx,ax          ; Make BX point to the PE

        ; Compare LBA address
        push     si
        push     di
        xor      si,[bx+00h]    ; Will put 0 in SI if the same
        xor      di,[bx+02h]    ; Will put 0 in DI if the same
        or       si,di          ; Wil set ZF if both zero
        pop      di
        pop      si
        loopnz   next_pe        ; Try next entry if non-zero

        ; Partition found or counter exhausted
        mov      ax,-1
        clc
        ; Not found, so exit with NC and invalid index
        jnz      PART_IsPrimaryPartition_exit

        ; Partition is Primary, set CY and return index
        mov      ax,cx
        stc

    PART_IsPrimaryPartition_exit:
        ret
PART_IsPrimaryPartition Endp



;
; #############################
; # Is this an HPFS partition #
; #############################
;
; In
; --
; SI    = Pointer to IPT entry
;
; Out
; ---
; CY    = Set if HPFS partition, clear if not
;
PART_IsHPFS     Proc Near  Uses ax
        mov     al, [si+LocIPT_SystemID]    ; Get SystemID
        cmp     al, 07h                     ; Compare with AiR-BOOT ID for HPFS
        stc                                 ; Assume HPFS
        je      PART_IsHPFS_exit            ; Yep
        clc                                 ; Nope, clear CY
    PART_IsHPFS_exit:
        ret
PART_IsHPFS     Endp


;
; ###########################
; # Is this a JFS partition #
; ###########################
;
; In
; --
; SI    = Pointer to IPT entry
;
; Out
; ---
; CY    = Set if JFS partition, clear if not
;
PART_IsJFS      Proc Near  Uses ax
        mov     al, [si+LocIPT_SystemID]    ; Get SystemID
        cmp     al, 0fch                    ; Compare with AiR-BOOT ID for JFS
        stc                                 ; Assume JFS
        je      PART_IsJFS_exit             ; Yep
        clc                                 ; Nope, clear CY
    PART_IsJFS_exit:
        ret
PART_IsJFS      Endp



;
; #############################
; # Is this an NTFS partition #
; #############################
;
; In
; --
; SI    = Pointer to IPT entry
;
; Out
; ---
; CY    = Set if NTFS partition, clear if not
;
PART_IsNTFS     Proc Near  Uses ax
        mov     al, [si+LocIPT_SystemID]    ; Get SystemID
        cmp     al, 08h                     ; Compare with AiR-BOOT ID for NTFS
        stc                                 ; Assume NTFS
        je      PART_IsNTFS_exit            ; Yep
        clc                                 ; Nope, clear CY
    PART_IsNTFS_exit:
        ret
PART_IsNTFS     Endp


;
; ######################################
; # Is this a FAT12 or FAT16 partition #
; ######################################
;
; In
; --
; SI    = Pointer to IPT entry
;
; Out
; ---
; CY    = Set if FAT12 or FAT16 partition, clear if not
;
PART_IsFAT    Proc Near  Uses ax
        mov     al, [si+LocIPT_SystemID]    ; Get SystemID
        cmp     al, 04h                     ; Is FAT12 ?
        stc
        je      PART_IsFAT_exit             ; Yep
        cmp     al, 06h                     ; Is FAT16 CHS ?
        stc
        je      PART_IsFAT_exit             ; Yep
        cmp     al, 0eh                     ; Is FAT16 LBA ?
        stc
        je      PART_IsFAT_exit             ; Yep
        clc                                 ; Nope
    PART_IsFAT_exit:
        ret
PART_IsFAT      Endp


;
; #############################
; # Is this a FAT32 partition #
; #############################
;
; In
; --
; SI    = Pointer to IPT entry
;
; Out
; ---
; CY    = Set if FAT32 partition, clear if not
;
PART_IsFAT32    Proc Near  Uses ax
        mov     al, [si+LocIPT_SystemID]    ; Get SystemID
        cmp     al, 0bh                     ; Is FAT32 CHS ?
        stc
        je      PART_IsFAT32_exit           ; Yep
        cmp     al, 0ch                     ; Is FAT32 LBA ?
        stc
        je      PART_IsFAT32_exit           ; Yep
        clc                                 ; Nope
    PART_IsFAT32_exit:
        ret
PART_IsFAT32    Endp



;
; ##############################################################
; # Does this partition have the Windows BootManager installed #
; ##############################################################
;
; In
; --
; DL    = Physical Disk
; BX:CX = LBA sector
;
; Out
; ---
; CY    = Set if BOOTMGR found, clear if not
;
;PART_IsWinBMGR  Proc Near  Uses ax bx cx dx si di ds es
;
;        ; Load specified LBA sector (BX:CX) from the disk in DL
;        mov     di,ds
;        mov     si,offset [TmpSector]
;        call    DriveIO_LoadSectorLBA

;        ; Point to location of 'BOOTMGR' signature.
;        add     si,169h

;        ; DL holds equality status
;        xor     dl,dl
;        cld

;        ; Load letter into AL, xor with letter will result 0 if the same.
;        ; Then or to DL.
;        ; If at the end of the sequence DL is zero, the signature is present.
;        lodsb
;        xor     al,'B'
;        or      dl,al
;        lodsb
;        xor     al,'O'
;        or      dl,al
;        lodsb
;        xor     al,'O'
;        or      dl,al
;        lodsb
;        xor     al,'T'
;        or      dl,al
;        lodsb
;        xor     al,'M'
;        or      dl,al
;        lodsb
;        xor     al,'G'
;        or      dl,al
;        lodsb
;        xor     al,'R'
;        or      dl,al

;        ; Assume not present
;        clc
;        jnz     PART_IsWinBMGR_exit

;        ; BOOTMGR signature found
;        stc

;    PART_IsWinBMGR_exit:
;        ret
;PART_IsWinBMGR  Endp


;
; ##########################################################
; # Get the offset of the phys-disk field in the PBR (BPB) #
; ##########################################################
;
; In
; --
; DS:SI = IPT
;
; Out
; ---
; AX    = Index in PBR for phys-disk field
;
PART_GetFieldIndex  Proc Near   uses bx cx dx
        ; Check for FAT32 partition
        mov     dl,bptr [si+LocIPT_Drive]
        mov     cx,[si+LocIPT_AbsoluteBegin+00h]
        mov     bx,[si+LocIPT_AbsoluteBegin+02h]
        call    PART_IsFAT32
        mov     ax,24h                              ; Offset in old-style BPB
        jnc     PART_GetFieldIndex_exit
        mov     ax,40h                              ; Offset in FAT32 BPB
    PART_GetFieldIndex_exit:
        ret
PART_GetFieldIndex  EndP
