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
PART_ConvertToStraight          Proc Near
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
;      call     AuxIO_Teletype
      call     CONV_ToUpper
;      call     AuxIO_Teletype
      xchg     al,ah
;      call     AuxIO_Teletype
      call     CONV_ToUpper
;      call     AuxIO_Teletype
;      call     AuxIO_TeletypeNL

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
;      call     AuxIO_TeletypeHexByte
;      call     AuxIO_TeletypeNL
      rcr      dl,1                          ; Put found-flag in CY
      ret
PART_IsInstallVolume            EndP






; ###################
; # START PARTITION #
; ###################

; Starts Partition DL from Internal Partition Table.
;        In: DL - Number of partition (filtered view)
;       Out: No Return...
; Destroyed: None, due to no return ;-)
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
   local PhysDiskBpbIndex:word    ; Index into BPB to field of phys-disk
   local FSType:byte                ; The FS used on the loaded BPB
                                    ; Only used for FAT/HPFS/JFS

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


;pusha
;call    MBR_Teletype
;mov     si,offset TXT_BootingNowPartName
;call    MBR_Teletype
;popa

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

;pusha
;call    MBR_Teletype
;mov     si,offset TXT_BootingNowPartName
;call    MBR_Teletype
;popa


      or      dl, dl
      jnz     PSP_IsHarddisc
      ; When booting floppy/CD-ROM/etc., we got other text to be displayed...
      mov     si, offset TXT_BootingNowPartName
      call    MBR_TeletypeVolName
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
         call    DriveIO_SaveConfiguration                                       ; Rousseau: SAVE CONFIGURATION !
      ENDIF
      ;call    MBR_Teletype     ; Prints out BootingNow2 including PartitionName
      mov     si, offset TXT_BootingNowPartName
      call    MBR_TeletypeVolName
      mov     si, offset TXT_BootingNowPartition
      call    MBR_Teletype
   pop     si                            ; restores SI (IPT-pointer)

   mov     ax, wptr [si+LocIPT_AbsolutePartTable+0]
   mov     bx, wptr [si+LocIPT_AbsolutePartTable+2]
   mov     cx, wptr [si+LocIPT_LocationPartTable+1]
   mov     dh, bptr [si+LocIPT_LocationPartTable+0]
   mov     dl, [si+LocIPT_Drive]



   ; This loads the MBR in case of PRI or the EBR in case of LOG partitions.
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
   ; Rousseau: Booting IBM-BM also requires the LBA address of the IBM-BM
   ; partitionafter the 'I13X' signature.
   ; Also, FS needs to be set to 3000H.
   ; This info was obtained by examining the LVM 2,x MBR-code.
   mov     ax, wptr [si+LocIPT_AbsoluteBegin+0]
   mov     bx, wptr [si+LocIPT_AbsoluteBegin+2]
   add     ax, wptr es:[di+LocBRPT_AbsoluteLength+0] ; Add length to absolute
   adc     bx, wptr es:[di+LocBRPT_AbsoluteLength+2] ;  begin location
   ; BX:AX -> Absolute End-Position of Partition

   test    byte ptr [CFG_ForceLBAUsage], 1
   jnz     PSP_ForceI13X
   ; LBA-boundary at 16450560 (FB0400h) (16320x16x63)
   cmp     bx, 00FBh
   jb      PSP_NoI13X


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
   ; --------------------------------------------------------- PARTITION HIDING
      push    si
         mov     si, offset TXT_BootingHide
         call    MBR_Teletype            ; display "hide active"
      pop     si
      ; First, find Hide-Config
      mov     dl, BootPartNo             ; EntryNumber is straight view
      ;~ mov     ax, LocIPT_MaxPartitions
      mov     ax, LocHPT_LenOfHPT
      mul     dl
      mov     di, offset HidePartitionTable
      add     di, ax                        ; We got the pointer


        ; So process Hide-Config. Read out Bitfield-Entries,
        ; each points to a partition.
        ; 3Fh is end-marker / maximum entries = CFG_Partitions
        mov     cl, CFG_Partitions
        mov     ch,0    ; Index in bitfield array.
        mov     dh,6    ; Bitfield width.
        mov     bx,di   ; Pointer to entry.
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
                                                                     ; Save MBR
         call    DriveIO_SavePartition   ; Saves the Partition-Table
      ENDIF
     PSP_NoHideAdjustPrimaryMark:

  PSP_NoHideFeature:
   ; Check, if we are supposed to ignore LVM altogether...
   test    byte ptr [CFG_IgnoreLVM], 1
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

   test    byte ptr [CFG_BootMenuActive], 0FFh
   jz      PSP_NoMenuNoSound

   ; --------------------------------------------------------------- BOOT-SOUND
      call    SOUND_ExecuteBoot
  PSP_NoMenuNoSound:

   ; -------------------------------------------------- SPECIAL BOOT PROCESSING
   ; Check here, if the Boot shall be done via resume to BIOS...
   mov     al, byte ptr [si+LocIPT_SystemID]
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

   ; This loads the PBR of the partition.
   call    DriveIO_LoadPartition         ; Loads boot-sector...   [PARTBOOTSEC]

    ;
    ; The JFS PBR-code does not use the passed BPB in memory but uses the BPB
    ; on disk. This breaks the drive-letter feature on JFS.
    ; So we make a copy of the PBR in memory, and if the partition is JFS
    ; we later adjust the physical-disk and boot-drive-letter in this
    ; copy and write it back to disk.
    ; Then the JFS PBR-code will see the correct boot-drive-letter.
    ;
    pusha
    mov     si,offset PartitionSector
    mov     di,offset JfsPBR
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
   test    byte ptr [CFG_ProtectMBR], 1
   jz      PSP_NoMBRprotect
   ; -------------------------------------------------- INSTALLS MBR-PROTECTION
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
        mov     PhysDiskBpbIndex,ax
        mov     bx,ax

        ; Locate cursor for output of debug-info
        pusha
        mov     ch,7
        mov     cl,0
        call    VideoIO_Color
        mov     ch,6
        mov     cl,1
        call    VideoIO_Locate
        popa

        ; Debug display physdisk, ptype and physdisk offset in BPB
        pusha
        mov     ah,[si+LocIPT_Drive]
        mov     al,[si+LocIPT_SystemID]
        call    VideoIO_PrintHexWord
        mov     ax,bx
        call    VideoIO_PrintHexWord
        mov     ax,[si+LocIPT_AbsolutePartTable+02]
        call    VideoIO_PrintHexWord
        mov     ax,[si+LocIPT_AbsolutePartTable+00]
        call    VideoIO_PrintHexWord
        mov     al,[ExtendedAbsPosSet]
        call    VideoIO_PrintHexByte
        popa


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
        mov     al,byte ptr [si+LocIPT_Drive]
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

        ; Low word of 32-bits "hidden sectors"
        mov     ax,[si+LocIPT_AbsoluteBegin]
        mov     es:[di+1ch], ax
        ; High word of 32-bits "hidden sectors"
        mov     ax,[si+LocIPT_AbsoluteBegin+2]
        mov     es:[di+1eh], ax





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
        ;
        test    al,al
        jz      bdl_ok



        ; Check if the boot-drive-letter is non-zero.
        mov     bx,PhysDiskBpbIndex
        inc     bx
        mov     al,es:[di+bx]
        test    al,al
        ; Non-zero, so no fixing needed.
        ;jnz     bdl_ok     ;; Why not always fix ? (so, jnz disabled)


        ;
        ; Always fix boot-drive-letter on FAT12/FAT16/HPFS/JFS
        ;

        ; Get the drive-letter for the partition from the LVM-info.
        mov     dl,byte ptr [si+LocIPT_Drive]
        mov     cx,[si+LocIPT_AbsoluteBegin+00h]
        mov     bx,[si+LocIPT_AbsoluteBegin+02h]
        call    LVM_GetDriveLetter

        ; Save the status for later use
        pushf

        ; See if the drive-letter feature is active.
        ; If active, we force the drive-letter from the user.
        test    byte ptr [si+LocIPT_Flags], Flags_DriveLetter

        ; Nope, it's not so we don't force the boot-drive-letter
        ; using field 25h.
        jz      PSP_NoLogicalSupport

        ; Partition index in BX
        mov     bl,BootPartNo               ; EntryNumber is straight view
        mov     bh,0

        ; Pointer to the user specified boot-drive
        ; Get it and convert to ASCII letter
        mov     al, bptr [DriveLetters+bx]
        sub     al,3dh      ; Convert BIOS notation to ASCII drive-letter



    PSP_NoLogicalSupport:

        ; Drive letter is LVM obtained or user-forced.
        ; Save it in AH.
        mov     ah,al


        ; Restore the status whether an LVM drive-letter could be obtained
        popf


        ;
        ; No valid LVM-info if no info found or drive-letter is zero.
        ;
        jnc     no_valid_lvm_info
        test    al,al
        jz      no_valid_lvm_info


        ;
        ; We have found a valid drive-letter in the LVM-info.
        ;

        ; Convert to BIOS notation ('C'+3dh=80h, 'D'->81h, etc.)
        add     al,3dh


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


        ; Fix the boot-drive-letter field in the BPB
        mov     bx,PhysDiskBpbIndex
        ; Advance to field for drive-letter in BIOS notation (OS/2 - eCS)
        inc     bx
        mov     es:[di+bx],al


        jmp     bdl_ok


    no_valid_lvm_info:
        ; HERE SHOULD COME AN ERROR POP-UP ABOUT NO BOOT-DRIVE OR NO LVM-INFO.
        ; WE CONTINUE BOOTING BUT OS/2 - eCS WILL MOST PROBABLY FAIL TO BOOT.

        ;mov     ah,07h
        ;mov     si,offset CheckID_MBR
        ;call    VideoIO_Print

    hang:
        ;jmp     hang


    ;
    ; Boot DriveLetter OK.
    ;
    bdl_ok:


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
        jnz     no_jfs_pbr

        ; Save IPT pointer
        push    si

        ; Copy the boot-drive and boot-drive-letter fields.
        mov     si,offset PartitionSector
        mov     di,offset JfsPBR
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
        mov     si, offset JfsPBR
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




IFDEF AUX_DEBUG
   call     DEBUG_Dump2
   ;~ call     DEBUG_DumpBSSSectors
ENDIF



;
; ################################## BYE BYE ##################################
;

    ; Skip wait-for-key
    jmp start_pbr

        ;
        ; Wait for keypress
        ;
        xor     ax, ax
        int     16h

        ; Is escape-key ?
        cmp     al, 1bh

        ; Nope, Go activate PBR loader
        jne      start_pbr

        ;push    ds
        ;pop     es

        ; Yep, Reenter bootmenu
        jmp      MBR_Main_ReEnterBootMenuPre



;
; Transfer control to the PBR
;
start_pbr:

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
        ; Show "wait dots"
        ;
        pusha
        ; Color white on black
        mov     ch,7
        mov     cl,0
        call    VideoIO_Color
        ; Locate cursor for output of debug-info
        mov     ch,8
        mov     cl,1
        call    VideoIO_Locate

        ; Print dots with interval.
        mov     cx,10
    print_next_dot:
        mov     al,'.'
        call    VideoIO_PrintSingleChar
        ; Value 30 is about 1.5 seconds
        mov     al,1
        call    TIMER_WaitTicCount
        loop    print_next_dot
        popa

    ;
    ; Enter here to skip delay.
    ;
    skip_delay:



        ;
        ; BYE BYE
        ;
        xor     ax, ax
        xor     bx, bx
        xor     cx, cx
        mov     ds, ax
        mov     es, ax
        xor     dh, dh
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



;
; THE FUNCTIONS HERE BELOW WERE INTRODUCED TO ENHANCE THE PBR PROCESSING,
; BUT THEY ARE ACTUALLY OBSOLETE BECAUSE THE INFORMATION THEY PROVIDE CAN
; ALSO BE OBTAINED FROM THE IPT. HOWEVER, THE IPT USES DIFFERENT IDENTIFIERS
; FOR PARTICULAR FILE-SYSTEMS / PBR TYPES, LIKE JFS BEING REPRESENTED AS 0FCh.
; POSSIBLY THE INFO IN THE IPT NEEDS TO BE EXPANDED TO DISTINGUISH BETWEEN
; OTHER BOOT-RECORDS AND FILE-SYSTEMS TOO, LIKE VISTA/WIN7 BMGR AND GRUB, ETC.
; THIS WOULD NEED TO BE DONE IN THE PARTSCAN ROUTINES.
; SO, FOR NOW WE KEEP USING THE STUFF BELOW.
;


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
; DL    = Physical Disk
; BX:CX = LBA sector
;
; Out
; ---
; CY    = Set if HPFS partition, clear if not
;
PART_IsHPFS     Proc Near  Uses ax bx cx dx si di ds es

        ; Load specified LBA sector (BX:CX) from the disk in DL
        mov     di,ds
        mov     si,offset [TmpSector]
        call    DriveIO_LoadSectorLBA

        ; Point to location of 'HPFS    ' identifier.
        add     si,36h

        ; DL holds equality status
        xor     dl,dl
        cld

        ; Load letter into AL, xor with letter will result 0 if the same.
        ; Then or to DL.
        ; If at the end of the sequence DL is zero, the signature is present.
        lodsb
        xor     al,'H'
        or      dl,al
        lodsb
        xor     al,'P'
        or      dl,al
        lodsb
        xor     al,'F'
        or      dl,al
        lodsb
        xor     al,'S'
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al

        ; Assume not present
        clc
        jnz     PART_IsHPFS_exit

        ; JFS signature found
        stc

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
; DL    = Physical Disk
; BX:CX = LBA sector
;
; Out
; ---
; CY    = Set if JFS partition, clear if not
;
PART_IsJFS      Proc Near  Uses ax bx cx dx si di ds es

        ; Load specified LBA sector (BX:CX) from the disk in DL
        mov     di,ds
        mov     si,offset [TmpSector]
        call    DriveIO_LoadSectorLBA

        ; Point to location of 'JFS     ' identifier.
        add     si,36h

        ; DL holds equality status
        xor     dl,dl
        cld

        ; Load letter into AL, xor with letter will result 0 if the same.
        ; Then or to DL.
        ; If at the end of the sequence DL is zero, the signature is present.
        lodsb
        xor     al,'J'
        or      dl,al
        lodsb
        xor     al,'F'
        or      dl,al
        lodsb
        xor     al,'S'
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al

        ; Assume not present
        clc
        jnz     PART_IsJFS_exit

        ; JFS signature found
        stc

    PART_IsJFS_exit:
        ret
PART_IsJFS      Endp



;
; ######################################
; # Is this a FAT12 or FAT16 partition #
; ######################################
;
; In
; --
; DL    = Physical Disk
; BX:CX = LBA sector
;
; Out
; ---
; CY    = Set if FAT12 or FAT16 partition, clear if not
;
; This can be a FAT12 or FAT16 partition.
; When OS/2 formats volume with FAT it does not use the FAT16 identifier,
; but uses the FAT identifier.
;
PART_IsFAT    Proc Near  Uses ax bx cx dx si di ds es

        ; First see if this is a FAT32 partition.
        ; If it is, exit with NC indicating not FAT12 or FAT16.
        call    PART_IsFAT32
        cmc
        jnc     PART_IsFAT_exit

        ; Load specified LBA sector (BX:CX) from the disk in DL
        mov     di,ds
        mov     si,offset [TmpSector]
        call    DriveIO_LoadSectorLBA

        ; Point to location of 'FAT     ' identifier.
        add     si,36h

        ; DL holds equality status
        xor     dl,dl
        cld

        ; Load letter into AL, xor with letter will result 0 if the same.
        ; Then or to DL.
        ; If at the end of the sequence DL is zero, the signature is present.
        lodsb
        xor     al,'F'
        or      dl,al
        lodsb
        xor     al,'A'
        or      dl,al
        lodsb
        xor     al,'T'
        or      dl,al
        lodsb

        ; Since OS/2 formats FAT volumes with an identifier of 'FAT     ',
        ; and others with 'FAT16   ', we skip two bytes for comparison.
        ; The rest must be spaces however.
;        xor     al,' '
;        or      dl,al
        lodsb
;        xor     al,' '
;        or      dl,al

        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al

        ; Assume not present
        clc
        jnz     PART_IsFAT_exit

        ; FAT signature found
        stc

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
; DL    = Physical Disk
; BX:CX = LBA sector
;
; Out
; ---
; CY    = Set if FAT32 partition, clear if not
;
PART_IsFAT32    Proc Near  Uses ax bx cx dx si di ds es

        ; Load specified LBA sector (BX:CX) from the disk in DL
        mov     di,ds
        mov     si,offset [TmpSector]
        call    DriveIO_LoadSectorLBA

        ; Point to location of 'FAT32   ' identifier.
        add     si,52h

        ; DL holds equality status
        xor     dl,dl
        cld

        ; Load letter into AL, xor with letter will result 0 if the same.
        ; Then or to DL.
        ; If at the end of the sequence DL is zero, the signature is present.
        lodsb
        xor     al,'F'
        or      dl,al
        lodsb
        xor     al,'A'
        or      dl,al
        lodsb
        xor     al,'T'
        or      dl,al
        lodsb
        xor     al,'3'
        or      dl,al
        lodsb
        xor     al,'2'
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al
        lodsb
        xor     al,' '
        or      dl,al

        ; Assume not present
        clc
        jnz     PART_IsFAT32_exit

        ; FAT32 signature found
        stc

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
