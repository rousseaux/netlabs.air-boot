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

IFDEF ModuleNames
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
   cmp     CFG_ResumeBIOSbootSeq, 0
   je      PFUPN_SelectionGone
   jmp     PFUPN_Found
  PFUPN_SpecialSelectionFloppy:
   cmp     CFG_IncludeFloppy, 0
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
      and     al, Flags_BootAble
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

; Copies the device-name to the Resume-BIOS IPT entry
PART_UpdateResumeBIOSName       Proc Near Uses ax bx cx si di
   ;movzx   bx, CFG_ResumeBIOSbootSeq
   mov   bl,CFG_ResumeBIOSbootSeq
   mov   bh,0

   dec     bx
   shl     bx, 1
   mov     si, wptr [ContinueBIOSbootTable+bx]
   mov     di, offset BIOScontIPTentry+LocIPT_Name
   push    di
      mov     cx, 11
      mov     al, ' '
      rep     stosb
   pop     di
  PURBN_BootDeviceCopyLoop:
      lodsb
      or      al, al
      jz      PURBN_NoResumeBootSeq
      stosb
      jmp     PURBN_BootDeviceCopyLoop
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
      mov     ds:[bx], ax
      add     bx, 2
      add     ax, LocIPT_LenOfIPT
   dec     cx
   jnz     PCSPP_Loop
   mov     al, ds:[CFG_Partitions]
   mov     ds:[PartitionPointerCount], al
   ret
PART_CalculateStraightPartPointers EndP

; This here does PartitionPointers in order for displaying in BootMenu
; [this means filtering and including Floppy/CD-ROM/Kernels, if wanted]
PART_CalculateMenuPartPointers Proc Near Uses si
   mov     si, offset PartitionTable
   mov     bx, offset PartitionPointers
   test    CFG_IncludeFloppy, 1
   jz      PCMPP_NoFloppyInclude
   mov     ax, offset FloppyIPTentry
   mov     ds:[bx], ax
   add     bx, 2
  PCMPP_NoFloppyInclude:

   test    CFG_ResumeBIOSbootSeq, 0FFh
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
   mov     si, wptr [PartitionPointers+bx]
   ret
  PGPP_IsBIOSbootSeq:
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
      cmp     wptr ds:[bx], si
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

; Following functions are only usable, when Partition-Pointer-View is filtered
; They will convert from and to unfiltered view (used in Boot-Menu)
;        In: DL - Number of partition in filtered view
;       Out: DL - Number of partition in straight view
PART_ConvertToStraight          Proc Near   Uses
   ;movzx   bx, dl
   mov   bl,dl                                  ; partition number to bl
   mov   bh,0                                   ; zero extend to word

   shl     bx, 1                                ; convert to word index
   mov     ax, wptr cs:[PartitionPointers+bx]   ; get the partition pointer
   cmp     ax, offset FloppyIPTentry
   jb      PCTS_IsBIOSbootSeq
   je      PCTS_IsFloppy
; [Linux support removed since v1.02]
;   cmp     ax, offset LINUX_KernelEntries
;   jae     PCTS_IsKernelEntry
   sub     ax, offset PartitionTable
   mov     bl, LocIPT_LenOfIPT
   div     bl                      ; Divide with IPTlength
   mov     dl, al
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
PART_ConvertFromStraight        Proc Near    Uses es di
   cmp     dl, 0FEh
   jb      PCFS_IsPartition
   mov     ax, offset BIOScontIPTentry
   je      PCFS_DoSearch
   mov     ax, offset FloppyIPTentry
   jmp     PCFS_DoSearch
  PCFS_IsPartition:
   ; First we get Partition-Offset in AX
   ;movzx   ax, dl
   mov   al,dl
   mov   ah,0

   mov     bl, LocIPT_LenOfIPT
   mul     bl
   add     ax, offset PartitionTable
  PCFS_DoSearch:
   ; Now search for this offset in our filtered Partition-Pointer-Table
   push    cs
   pop     es
   mov     di, offset PartitionPointers
   mov     cx, LocIPT_MaxPartitions
   xor     dl, dl                        ; Reply on Not-Found = Partition==0
   repne   scasw  ; Compare-Loop
   jne     PCFS_NotFound
   sub     di, 2                         ; One Back, so point to compared value
   mov     dx, di
   sub     dx, offset PartitionPointers
   shr     dx, 1
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
   mov     wptr es:[di+1], bx
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
      call     AuxIO_Teletype
      call     CONV_ToUpper
      call     AuxIO_Teletype
      xchg     al,ah
      call     AuxIO_Teletype
      call     CONV_ToUpper
      call     AuxIO_Teletype
      call     AuxIO_TeletypeNL

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
      call     AuxIO_TeletypeHexByte
      call     AuxIO_TeletypeNL
      rcr      dl,1                          ; Put found-flag in CY
      ret
PART_IsInstallVolume            EndP




; ###################
; # START PARTITION #
; ###################

; Starts Partition DL from Internal Partition Table.
;        In: DL - Number of partition (filtered view)
;       Out: No Return...
; Destroyed: None, due no return ;-)
;     Logic: - Harddrive: loads partition Table
;                         sets partition active
;                         saves partition table
;                         hides partitions, if needed
;                         Linux-Support, if needed
;              load boot sector
;              VIBR checking, if wanted
;              install MBR Protection, if wanted
;              Special Boot Support, if needed (OS/2 Extended partitions)
;              Copy boot-sector to StartBase
;              run boot sector...
PART_StartPartition             Proc Near   Uses ax dx es di
   local BootPartNo:byte
   ; Get Partition-Pointer (SI) to Partition-To-Boot (DL)
   call    PART_GetPartitionPointer

   call    PART_ConvertToStraight        ; ...we save straight view for later...
   mov     BootPartNo, dl
   ; Straight - FFh -> Floppy boot
   ;            FEh -> BIOS continue (CD-ROM, ZIP, etc.)

   ; We need straight pointers from now on, so calculate the table...
   call    PART_CalculateStraightPartPointers

   ; SI contains the pointer to the IPT to what partition to boot
   ;  in this whole routine...it may never get messed up.

   push    si
      mov     dl, [si+LocIPT_Drive]
      mov     dh, [si+LocIPT_SystemID]
      ; Copy Partition-Name to BootingNow area for display purposes
         add     si, LocIPT_Name
         mov     cx, 11
         call    GetLenOfName
         mov     di, offset TXT_BootingNowPartName
         jz      PSP_NoName
         rep     movsb                                                           ; Copy label-name to boot
        PSP_NoName:
         xor     al, al
         stosb              ; Ending Zero
      mov     si, offset TXT_BootingNow1                                         ; "Booting the system using "
      call    MBR_Teletype
; [Linux support removed since v1.02]
;      cmp     dh, 0FDh
;      je      PSP_IsKernel
      or      dl, dl
      jnz     PSP_IsHarddisc
      ; When booting floppy/CD-ROM/etc., we got other text to be displayed...
      mov     si, offset TXT_BootingNowPartName
      call    MBR_Teletype
      jmp     PSP_IsFloppyCDROMetc

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
         ; Save configuration on HDD boots (save CFG_PartLast)
         call    DriveIO_SaveConfiguration                                       ; Rouaaseu: SAVE CONFIGURATION !
      ENDIF
      call    MBR_Teletype     ; Prints out BootingNow2 including PartitionName
      mov     si, offset TXT_BootingNowPartition
      call    MBR_Teletype
   pop     si                            ; restores SI (IPT-pointer)

   mov     ax, wptr [si+LocIPT_AbsolutePartTable+0]
   mov     bx, wptr [si+LocIPT_AbsolutePartTable+2]
   mov     cx, wptr [si+LocIPT_LocationPartTable+1]
   mov     dh, bptr [si+LocIPT_LocationPartTable+0]
   mov     dl, [si+LocIPT_Drive]

   call    DriveIO_LoadPartition         ; Load Table...                [LOAD]

   ; --------------------------------------------------- MODIFY PARTITION TABLE
   push    cs
   pop     es
   mov     di, offset PartitionSector+446 ; ES:DI - First Partitionentry

   ; Remove all active-flags for safety reasons, primary partition table will
   ;  have one partition set active by ScanPartition-routine.
   push    di
      mov      cl, 4
     PSP_RemoveActiveFlagLoop:
         and      bptr es:[di+LocBRPT_Flags], 7Fh
         add      di, LocBRPT_LenOfEntry
      dec      cl
      jnz      PSP_RemoveActiveFlagLoop
   pop     di

   ; Put the partition-to-be-booted location into registers...
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
   jmp     MBR_HaltSystem

   ; -------------------------------------------------------------- ENTRY FOUND
  PSP_SearchMatch:
   or      byte ptr es:[di+LocBRPT_Flags], 80h ; set ACTIVE partition
   IFDEF ReleaseCode
      call    DriveIO_SavePartition      ; Saves the Partition-Table    [SAVE]
   ENDIF

   ; ---------------------------------------------------------- OS/2 / eCS I13X
   ; Now check if the partition to get booted is above 8 GB.
   ;  If yes, set magic bytes 'I13X' at 3000:0 for boot-loader to recognize.
   ;  This method is (c) by IBM <g>
   mov     ax, wptr [si+LocIPT_AbsoluteBegin+0]
   mov     bx, wptr [si+LocIPT_AbsoluteBegin+2]
   add     ax, wptr es:[di+LocBRPT_AbsoluteLength+0] ; Add length to absolute
   adc     bx, wptr es:[di+LocBRPT_AbsoluteLength+2] ;  begin location
   ; BX:AX -> Absolute End-Position of Partition

   test    CFG_ForceLBAUsage, 1
   jnz     PSP_ForceI13X
   ; LBA-boundary at 16450560 (FB0400h) (16320x16x63)
   cmp     bx, 00FBh
   jb      PSP_NoI13X
  PSP_ForceI13X:
   push    es di si
      mov     ax, 3000h
      mov     es, ax
      xor     di, di
      ; Blokkeert starten van IBM BM !!
      mov     wptr es:[di], '1I'
      mov     wptr es:[di+2], 'X3'

      ;mov      si,3000h
      ;call     AuxIO_DumpSector

   pop     si di es
  PSP_NoI13X:

   ; now check, if we need to hide any partition
   test    byte ptr [si+LocIPT_Flags], Flags_HideFeature
   jz      PSP_NoHideFeature
   ; --------------------------------------------------------- PARTITION HIDING
      push    si
         mov     si, offset TXT_BootingHide
         call    MBR_Teletype            ; display "hide active"
      pop     si
      ; First, find Hide-Config
      mov     dl, BootPartNo             ; EntryNumber is straight view
      mov     ax, LocIPT_MaxPartitions
      mul     dl
      mov     di, offset HidePartitionTable
      add     di, ax                        ; We got the pointer
      ; So process Hide-Config. Read out Byte-Entries, each points to a partition
      ;  0FFh is end-marker / maximum entries = CFG_Partitions
      mov     cl, CFG_Partitions
     PSP_PartitionsHideLoop:
         mov     dl, es:[di]
         inc     di
         cmp     dl, 0FFh
         je      PSP_EndOfHideProcess    ; -> End of Hiding
         call    PART_HidePartition      ; Now hide that partition
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
                                                                     ; Save MBR
         call    DriveIO_SavePartition   ; Saves the Partition-Table
      ENDIF
     PSP_NoHideAdjustPrimaryMark:

  PSP_NoHideFeature:
   ; Check, if we are supposed to ignore LVM altogether...
   test    [CFG_IgnoreLVM], 1
   jnz     PSP_NoLVMReassignment
   ; --------------------------------------------------------- LVM REASSIGNMENT
      ; Driveletter must be set for this partition
      test    byte ptr [si+LocIPT_Flags], Flags_DriveLetter
      jz      PSP_NoLVMReassignment
      ;movzx   bx, BootPartNo             ; EntryNumber is straight view
      mov   bl,BootPartNo             ; EntryNumber is straight view
      mov   bh,0

      mov     al, bptr [DriveLetters+bx]
      sub     al, 3Dh                    ; Convert e.g. 80h -> 'C'
      cmp     al, bptr [PartitionVolumeLetters+bx]
      je      PSP_NoLVMReassignment      ; If driveletters match -> no change
      call    LVM_DoLetterReassignment   ; Give partition SI letter AL
  PSP_NoLVMReassignment:
   push    si
   ; ------------------------------------------------------- -"PLEASE WAIT..."-
  PSP_IsFloppyCDROMetc:
      mov     si, offset TXT_BootingWait
      call    MBR_Teletype               ; display "please wait"
   pop     si

   ; Process Partition Tables, if M$-Hack required (changes Ext Part Type)
   call    MSHACK_ProcessPartTables

   test    CFG_BootMenuActive, 0FFh
   jz      PSP_NoMenuNoSound

   ; --------------------------------------------------------------- BOOT-SOUND
      call    SOUND_ExecuteBoot
  PSP_NoMenuNoSound:

   ; -------------------------------------------------- SPECIAL BOOT PROCESSING
   ; Check here, if the Boot shall be done via resume to BIOS...
   mov     al, bptr [si+LocIPT_SystemID]
   cmp     al, 0FEh                      ; Via BIOS ? (aka resume BIOS boot sequence)
   je      PSP_ResumeBIOSbootSeq
; [Linux support removed since v1.02]
;   cmp     al, 0FDh                      ; Kernel-Booting ?
;   je      PSP_KernelBooting
   jmp     PSP_StartNormal

  PSP_ResumeBIOSbootSeq:
   int     18h                           ; Give control back to BIOS
   db      0EAh                          ; if return to here -> Reboot
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
   call    DriveIO_LoadPartition         ; Loads boot-sector...   [PARTBOOTSEC]

   test    CFG_DetectVIBR, 1
   jz      PSP_NoVIBR
   test    byte ptr [si+LocIPT_Flags], Flags_VIBR_Detection
   jz      PSP_NoVIBR
   ; ---------------------------------------------------------- CHECKS FOR VIBR
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
   test    CFG_ProtectMBR, 1
   jz      PSP_NoMBRprotect
   ; -------------------------------------------------- INSTALLS MBR-PROTECTION
   push    ds si                         ; We need DS:SI later...
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
      mov     cx, 512
      rep     movsw                      ; Move 1024 bytes...

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
   pop     si ds                         ; Restore DS:SI

   ; ------------------------------------------------ SPECIAL PARTITION SUPPORT
   ; needed by OS/2 Warp / eComStation
  PSP_NoMBRprotect:
   cmp     bptr [si+LocIPT_SystemID], 08 ; I hate Microsuck NTFS check

   ;je      PSP_NoSpecialSupport

      mov     di, offset PartitionSector ; ES:DI - Actual Boot-Record
      ; Special Support Detection
      mov     ax, wptr es:[di+24]
      cmp     ax, 003Fh                  ; Physical Layout-Sectors... Safety check


      ; Rousseau: # Boot Logical Partitions)
      ; FreeDOS and eCS on extpart on non-huge needs special support.
      ; (old ja jump)
      ; PC-DOS7 on huge pri fat16 2G works with both (XP too) when at start of disk.
      ; (also when offset at 20MiB)
      ; PCD7 bonkt vast als in 2GiB log at start of space.
      ; "Starting PC DOS..." verschijnt. PCD Loader probleem.
      ; Offset van start-of-disk bij PCD7 niet meer dan 2GiB maken.
      ; Special is needed to boot ECS-CXXVAC (log-part) on Douwskie Box with 40G disk.
      ; FreeDOS 20G PRI SOD op 400G start niet met special.
      ; Heeft drive-id op 26h (36d) van 0dh !
      ; WinXP werkt met special en not-special op 400G normal geo.
      ; eCS op PRI op 2G met os2 ext geo werkt ook met beide.
      ; eCS LOG werkt niet zonder special op 400G.
      ; (hidden secs op 3F en moet 3F00 zijn; BM staat ervoor, 3F00=255*63+63)
      ; Laatste 63 is MBR.
      ;
      ; It seems PRI's already get special treatment in that they get their
      ; hidden secs updated.
      ; (100MB HD, moved 50MB PRI-DOS part UP, DFSee complains about wrong hidden,
      ; but AiR-BOOT corrects it before booting)

      ; FreeDOS zet 63 in SPT in BPB op 255/255 geo !!!!

      ; PC-DOS7 wil vaak niet starten als er meerdere pri's actief zijn.
      ; Logo verschijnt wel maar start niet door.


      ; Display volume-name
      ; Just before booting the selected partition
      pushf
      pusha
      push     si
      add      si, LocIPT_Name
      call     MBR_TeletypeVolName
      xor      si,si
      call     MBR_TeletypeNL
      pop      si
      popa
      popf






      ;
      ; This section will be sanitized in the JWasm version.
      ;

      jmp     special
      ;jmp     PSP_NoSpecialSupport

      ;ja      PSP_NoSpecialSupport
      ;jbe     PSP_NoSpecialSupport


      mov     ax, wptr es:[di+26]
      cmp     ax, 00FFh                  ; Physical Layout-Heads... Safety check
      ja      PSP_NoSpecialSupport
      mov     al, bptr es:[di+36]
      cmp     al, 80h                    ; Drive Letter (ID)
      jne     PSP_NoSpecialSupport

      ; Special Support needed
special:
      ; Write actual drive-letter to partition boot-record in memory.
      mov     al, bptr [si+LocIPT_Drive]

      ; Also an influence with FreeDOS !
      ; Generates JFS ERROR when not set correctly !!!
      mov     bptr es:[di+36], al              ; Write Actual Drive-Letter to
                                                ; PBR in RAM. (BIOS notation)

      ;
      ; Display drive info (debug)
      ;
      push     ax
      mov      al,' '
      call     VideoIO_PrintSingleChar
      pop      ax
      call     VideoIO_PrintHexByte
      mov      al,'-'
      call     VideoIO_PrintSingleChar

      ;
      ; Absolute offset of volume
      ;
      mov      ax, [si+LocIPT_AbsoluteBegin+2]
      call     VideoIO_PrintHexWord
      mov      ax, [si+LocIPT_AbsoluteBegin]
      call     VideoIO_PrintHexWord
      mov      al,'-'
      call     VideoIO_PrintSingleChar

      ;
      ; Relative offset (3fh/63 with logicals)
      ;
      mov      ax,es:[di+30]
      call     VideoIO_PrintHexWord
      mov      ax,es:[di+28]
      call     VideoIO_PrintHexWord

      ; This could be incorrect when a partition is moved,
      ; or the system installer puts the wrong value here.
      ; FreeDOS (log-part) i.e. puts 03fH (63d) here, eventhough it is not
      ; at the start of the disk.
      ; This fixing is done by OS/2 BM as well, according to Martin.
      mov     ax, [si+LocIPT_AbsoluteBegin]
      mov     wptr es:[di+28], ax               ; low word of hidden sectors
      mov     ax, [si+LocIPT_AbsoluteBegin+2]
      mov     wptr es:[di+30], ax               ; high word of hidden sectors

   ; ------------------------------------------------ LOGICAL PARTITION SUPPORT
  PSP_NoSpecialSupport:

;jmp   PSP_NoLogicalSupport


   ;
   ; Test if the drive-letter feature is active for this partition.
   ; If so, then the drive that the user defined will be placed at
   ; byte 25h (37d) of the in-ram PartitionSector (BPB).
   ; (BIOS 80h notation: 80h=C, 81h=D, etc.)
   ; This is a remedy for when the corresponding field (25h) in the BPB on
   ; disk is zero.
   ;
   test    byte ptr [si+LocIPT_Flags], Flags_DriveLetter
   jz      PSP_NoLogicalSupport

      ;movzx   bx, BootPartNo             ; EntryNumber is straight view
      mov   bl,BootPartNo             ; EntryNumber is straight view
      mov   bh,0

      mov     al, bptr [DriveLetters+bx]
      mov     bptr es:[di+37], al        ; Write Drive Letter (OS/2 only)

      ; Display dl-feature drive if active
      push     ax
      mov      al,'-'
      call     VideoIO_PrintSingleChar
      pop      ax
      call     VideoIO_PrintHexByte

   ; -------------------------------------------- COPY BOOT-RECORD TO STARTBASE
  PSP_NoLogicalSupport:


      mov      al,'-'
      call     VideoIO_PrintSingleChar
      mov      al,[ExtendedAbsPosSet]
      call     VideoIO_PrintHexByte


   push    si
      mov     ax, StartBaseSeg
      mov     es, ax
      mov     cx, 256
      mov     si, offset PartitionSector
      mov     di, StartBasePtr
      rep     movsw
   pop     si
   ; ---------------------------------------------------- NOW START BOOT-RECORD




IFDEF AuxDebug
;   call     DEBUG_Dump2
ENDIF




;
; ################################## BYE BYE ##################################
;

   ;
   ; Wait for keypress
   ;
   xor     ax, ax
   int     16h

   ; Is escape-key ?
   cmp     al, 1bh

   ; Nope, Go activate PBR loader
   jne      start_pbr

   ; Yep, Reenter bootmenu
   jmp      MBR_Main_ReEnterBootMenuPre



;
; Transfer control to the PBR
;
start_pbr:

   ;
   ; BYE BYE
   ;
   xor     ax, ax
   xor     bx, bx
   xor     cx, cx
   mov     ds, ax
   mov     es, ax                        ; DS == ES == 0
   xor     dh, dh                        ; Drive supported by BIOS
   mov     dl, cs:[si+LocIPT_Drive]      ; Drive Physical No

   ;
   ; JUMP TO PBR loader
   ;
   IFDEF ReleaseCode
      db      0EAh
      dw      StartBasePtr
      dw      StartBaseSeg
   ENDIF


PART_StartPartition             EndP


