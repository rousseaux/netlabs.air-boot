
; Disclaimer:
;=============
; The sourcecode is released via www.netlabs.org CVS *ONLY*.
;  You MUST NOT upload it to other servers nor republish it in any way.
;  The sourcecode is still COPYRIGHTED and NOT RELEASED UNDER GPL.
;  It's (c) Copyright 1998-2003 by Martin Kiewitz.
;  You may recompile the source and do *PRIVATE* modifications, but please keep
;  in mind that modifying this code needs at least *some* assembly skill. If
;  you mess up your system, because you needed to hack your way through, don't
;  blame me. Releasing a customized version of AiR-BOOT, selling it in any form
;  or reusing parts of this source is *PROHIBITED*. Ask me, if you have some
;  idea about new functionality *before* developing the code, otherwise I will
;  definitely reject it. Also please accept, that I have some basic design
;  rules on AiR-BOOT and I will maintain them at all costs, so this won't get
;  another GRUB.

;---------------------------------------------------------------------------
;                                             AiR-BOOT / PARTiTiON SCANNING
;---------------------------------------------------------------------------

; Note: This is complex code. Also some of this functions have DS != CS, so
;        make sure that you know what you are doing in here.

PARTSCAN_ScanForPartitions      Proc Near  Uses
   ; Reset X-Reference
   call    PARTSCAN_ResetXref

   push    ds si
      push    0040h
      pop     ds
      mov     si, 0075h
      mov     dh, ds:[si]                ; 40:75 -> POST: Total Harddiscs == DL
   pop     si ds
   mov     TotalHarddiscs, dh
   xor     al, al
   mov     NewPartitions, al

   mov     dl, 80h                       ; is first harddisc
  PSSFP_HarddiscLoop:
      push    dx
         call    PARTSCAN_ScanDriveForPartitions
      pop     dx
      inc     dl
   dec     dh
   jnz     PSSFP_HarddiscLoop

   ; Use X-Reference to sync NewPartitionTable with Hide-Config
   call    PARTSCAN_SyncHideConfigWithXref

   ; Now we copy the new IPT over the old one...
   mov     si, offset NewPartTable
   mov     di, offset PartitionTable
   movzx   ax, NewPartitions
   mov     CFG_Partitions, al
   mov     bl, LocIPT_LenOfIPT
   mul     bl
   mov     cx, ax
   rep     movsb

   ; and the New Logical Drive Letter table as well...
   mov     si, offset NewDriveLetters
   mov     di, offset DriveLetters
   mov     cx, LocIPT_MaxPartitions/2
   rep     movsw

   ; Search for any Linux partition and remember, if it got found...
   mov     si, offset PartitionTable
   movzx   cx, CFG_Partitions
   xor     dl, dl                        ; DL - Is Linux here ?
   or      cx, cx
   jz      PSSFP_NoPartitions
  PSSFP_LinuxLoop:
      cmp     bptr [si+LocIPT_SystemID], 083h  ; Hard-Coded
      jne     PSSFP_NoLinux
      mov     dl, 1                      ; Linux found...
     PSSFP_NoLinux:
      add     si, LocIPT_LenOfIPT
   loop    PSSFP_LinuxLoop
  PSSFP_NoPartitions:
   mov     GotLinux, dl             ; Set Flag

   ; ...and finally check, if we need to set a Drive-Letter
   mov     dl, AutoDrvLetter
   or      dl, dl
   jz      PSSFP_NoAutoDriveLetter
   movzx   cx, CFG_Partitions
   or      cx, cx
   jz      PSSFP_NoAutoDriveLetter
   mov     si, offset PartitionTable
   mov     di, offset DriveLetters
   mov     ax, wptr [AutoDrvLetterSerial]
   mov     bx, wptr [AutoDrvLetterSerial+2]
  PSSFP_AutoDrvLetterLoop:
      cmp     ax, [si+LocIPT_Serial]
      jne     PSSFP_AutoDrvLetterNoMatch
      cmp     bx, [si+LocIPT_Serial+2]
      jne     PSSFP_AutoDrvLetterNoMatch
      ; We got a match, so set Drive-Letter in DL
      or      bptr [si+LocIPT_Flags], Flags_DriveLetter
      mov     [di], dl
     PSSFP_AutoDrvLetterNoMatch:
      add     si, LocIPT_LenOfIPT
      inc     di
   loop    PSSFP_AutoDrvLetterLoop
   mov     AutoDrvLetter, 0              ; Disable after processing...
  PSSFP_NoAutoDriveLetter:
   ret
PARTSCAN_ScanForPartitions      EndP

; Scannt die Festplatte auf jegliche Partitionstabellen...
; Falls eine fehlerhafte Partition gefunden wird, wird abgebrochen.
; falls eine Extended Partition (DOS) gefunden wird, wird erneut gescannt.
PARTSCAN_ScanDriveForPartitions Proc Near  Uses
   xor     ax, ax
   xor     bx, bx     ; Location Absoluter Sektor 0
   mov     cx, 0001h
   xor     dh, dh     ; Location Zylinder 0, Side 0, Sektor 1 MBR
   mov     [ExtendedAbsPosSet], al
   mov     wptr [ExtendedAbsPos+0], ax
   mov     wptr [ExtendedAbsPos+2], ax
  PSSDFP_LoadThisPartition:
   call    DriveIO_LoadPartition
   jc      PSSDFP_InvalidPartition
   call    PARTSCAN_ScanPartition
   IFDEF ReleaseCode
      call    DriveIO_SavePartition
   ENDIF
   call    PARTSCAN_ScanPartitionForExtended
   jc      PSSDFP_LoadThisPartition
  PSSDFP_InvalidPartition:
   ret
PARTSCAN_ScanDriveForPartitions EndP

; The following routines have NOT *DS* set to CS, so we must address via ES
PARTSCAN_ScanPartition          Proc Near  Uses ax ds si
   push    ExecBaseSeg
   pop     ds
   mov     si, ExecBasePtr
   add     si, 446                       ; DS:SI - First Partition-Entry
  PSSP_ScanLoop:
      mov     al, bptr ds:[si+LocBRPT_SystemID]
      cmp     al, 5                      ; Is Partition EXTENDED ?
      je      PSSP_IgnorePartition
      cmp     al, 0Fh                    ; Is Partition EXTENDED (M$-DOS7) ?
      je      PSSP_IgnorePartition
      cmp     al, 0                      ; Is Partition EMPTY ?
      je      PSSP_IgnorePartition
      ; Ignore this Partitions, because there are no real Partitions
      call    PARTSCAN_CheckThisPartition
     PSSP_IgnorePartition:
      ; L”scht das Boot-Able Flag...
      and     byte ptr ds:[si+LocBRPT_Flags], 7Fh ; Reset the Active-Flag
      add     si, LocBRPT_LenOfEntry     ; 16 Bytes per partition entry
   cmp     si, 500+ExecBasePtr
   jb      PSSP_ScanLoop
   ; If we are on first HDD and in primary partition table -> mark primary
   cmp     bptr es:[CurPartition_Location+4], 80h ; Drive
   jne     PSSP_NoMarkPrimary
   cmp     wptr es:[CurPartition_Location+0], 0
   jne     PSSP_NoMarkPrimary
   cmp     wptr es:[CurPartition_Location+2], 0 ; Absolute Location
   jne     PSSP_NoMarkPrimary
   call    PART_MarkFirstGoodPrimary
  PSSP_NoMarkPrimary:
   ret
PARTSCAN_ScanPartition          EndP

MBR_NoName_Patched           db  15 dup (0)

; Will insert this partition into NewPartTable and compare it to our "old"
; LocIPT-table. If the same partition is found there, Flags&CRC are taken from
; the old table, otherwise they are generated freshly.
; Will also fill out PartitionXref to sync HideConfig later
;        In: DS:SI - Partition-Entry (16-Bytes)
;            ES    - is CS
;             (DS is *NOT* CS here)
PARTSCAN_CheckThisPartition     Proc Near  Uses di ds si
   local   PartSystemID:byte, PartTypeFlags:byte
   local   PartCRC:word, PartPtr:dword

   mov     ax, ds
   mov     wptr [PartPtr+2], ax          ; ...
   mov     wptr [PartPtr+0], si          ; Save Pointer to PartitionEntry

   mov     al, bptr ds:[si+LocBRPT_SystemID]
   mov     PartSystemID, al

   mov     cx, wptr ds:[si+LocBRPT_BeginSector] ; Cylinder/Sector
   mov     dh, bptr ds:[si+LocBRPT_BeginHead] ; Head
   mov     dl, bptr es:[CurPartition_Location+4] ; Drive
   mov     ax, wptr ds:[si+LocBRPT_RelativeBegin] ; Absolute Sector
   mov     bx, wptr ds:[si+LocBRPT_RelativeBegin+2]
   add     ax, wptr es:[CurPartition_Location+0] ; +Partition-Absolute
   adc     bx, wptr es:[CurPartition_Location+2] ;  sectors
   call    DriveIO_LoadTmpSector         ; Loads Boot record
   ; Sets up DS:SI - TmpSector

   push    si
      mov     bx, 4B4Dh                  ; Magic 'MK' :)
      call    MBR_GetCheckOfSector
      mov     PartCRC, bx                ; Save Partition's-CRC

      ; ------------------------------ Gets internal infos of partition type
      mov     al, PartSystemID
      call    PART_SearchFileSysName
      ; Replies AH - FileSysFlags, AL - UnhiddenID, SI - FileSystemNamePtr
      mov     di, si
      mov     PartTypeFlags, ah
      mov     PartSystemID, al           ; Use Unhidden-ID
   pop     si

   ;================================
   ; AL - File System ID (Unhidden)
   ; AH - File System Flags
   ; SI - Boot-Record of Partition
   ; DI - File System Name
   ; DS==CS here
   ;================================

   test    ah, FileSysFlags_NoName       ; No-Name-Flag ? -> No Partition Name
   jnz     PCCTP_ThereIsNoName           ;                    available
      cmp     PartSystemID, 07h          ; We got IFS here?
      jne     PCCTP_NotNTFS
      ; Check, if 'HPFS' is at DWORD offset 36h
      cmp     wptr ds:[si+36h], 'PH'
      jne     PCCTP_SeemsNTFS
      cmp     wptr ds:[si+38h], 'SF'
      je      PCCTP_NotNTFS
     PCCTP_SeemsNTFS:
      inc     PartSystemID
      jmp     PCCTP_ThereIsNoName
     PCCTP_NotNTFS:
      test    ah, FileSysFlags_FAT32     ; FAT32 specific name getting ?
      jz      PCCTP_ResumeNormal
      add     si, 1Ch                    ; Fix for FAT 32, shiat
     PCCTP_ResumeNormal:
      add     si, 2Bh                    ; DS:SI - Partition-Name
      mov     cx, 11                     ;         11 bytes length
      call    PART_CheckForValidPartName
      jnc     PCCTP_ThereIsNoName
;      jnc     PCCTP_SetNameToNoName
      sub     si, 4                      ; DS:SI -> Serial&Name (15-Bytes)
      xor     ah, ah                     ; no Flags_NoPartName
      jmp     PCCTP_NameSearchInIPT

; WAS: NTFS/HPFS detection problem
;     PCCTP_SetNameToNoName:
;      cmp     PartSystemID, 07h          ; We got HPFS that failed ?
;      jne     PCCTP_NotHPFS              ; -> is NTFS (internal type 08h)
;      inc     PartSystemID               ; All that fails is Microsoft <bg>
;     PCCTP_NotHPFS:
;      jmp     PCCTP_ThereIsNoName

      ;=======================================================
      ; NAME SEARCH in IPT-Table
      ; DS:SI - Serial&Name of Current Partition (15-Bytes)
      ;    AH - NoPartName-Flag (!MUST! be merged with Flags)
      ;=======================================================
     PCCTP_NameSearchInIPT:
      xor     ah, ah                     ; no Flags_NoPartName cause PartName valid
      mov     di, offset PartitionTable  ; ES:DI - IPT-Start
      mov     dl, es:CFG_Partitions
      or      dl, dl
      jz      PCCTP_NameCompFailed
     PCCTP_SerialNameCompLoop:
         mov     al, es:[di+LocIPT_Flags]
         test    al, Flags_NowFound
         jnz     PCCTP_SerialNameAlreadyFound
         ; Now compare IPT with current Partition
         mov     cx, 15                  ; Serial&Name (15-Bytes)
         push    si di
            repz    cmpsb
         pop     di si
         je      PCCTP_Match
        PCCTP_SerialNameAlreadyFound:
         add     di, LocIPT_LenOfIPT
      dec     dl
      jnz     PCCTP_SerialNameCompLoop

      ; if we didn't find Serial&Name, let's try Name-only without Serial
      mov     di, offset PartitionTable  ; ES:DI - IPT-Start
      mov     dl, CFG_Partitions
     PCCTP_NameCompLoop:
         mov     al, es:[di+LocIPT_Flags]
         test    al, Flags_NowFound
         jnz     PCCTP_NameAlreadyFound
         ; Now compare IPT with current Partition
         mov     cx, 11                  ; Name only (11-Bytes)
         push    si di
            add     si, 4
            add     di, 4                ; Skip over Serial-Field
            repz    cmpsb
         pop     di si
         jne     PCCTP_NameNoMatch
         mov     cx, ds:[si+0]           ; Get Serial
         mov     es:[di+0], cx
         mov     cx, ds:[si+2]
         mov     es:[di+2], cx           ; ...and put it into IPT
         jmp     PCCTP_Match
        PCCTP_NameNoMatch:
        PCCTP_NameAlreadyFound:
         add     di, LocIPT_LenOfIPT
      dec     dl
      jnz     PCCTP_NameCompLoop
     PCCTP_NameCompFailed:
      jmp     PCCTP_CompareFailed

  PCCTP_ThereIsNoName:
      ; First, try to find this partition by comparing location and PartitionID
      ;  aka LocIPT_AbsoluteBegin:dword and LocIPT_SystemID
      ; If found, simply go to the normal match-routine, otherwise use the
      ;  File-System-Name to build the Volume-Label for the New IPT Entry.
      mov     dh, PartSystemID
      push    ds
         lds     si, dptr PartPtr        ; DS:SI - Cur Partition Entry
         ; Relative Sector to MBR/EPR
         mov     cx, wptr ds:[si+LocBRPT_RelativeBegin]
         mov     bx, wptr ds:[si+LocBRPT_RelativeBegin+2]
         add     cx, cs:[CurPartition_Location+0]
         add     bx, cs:[CurPartition_Location+2]
         ; BX:CX - Absolute First Sector of Partition on HDD
      pop     ds
      ; Build a standard-Volume Label from FileSystemNamePtr
      ;  We have to call SearchFileSysName again because of NTFS
      push    ax cx
         mov     al, dh
         call    PART_SearchFileSysName   ; We want SI here <- FileSystemNamePtr
         mov     di, offset MBR_NoName_Patched
         add     di, 4                   ; Skip Serial-Field
         mov     cx, 8
         rep     movsb                   ; Copy FileSystemName to Temp Space
         mov     si, offset MBR_NoName_Patched
      pop     cx ax
      ;=======================================================
      ; LOCATION SEARCH in IPT-Table
      ;    DH - PartitionID of Current Partition
      ; BX:CX - AbsoluteBegin of Current Partition
      ;    AH - NoPartName-Flag (!MUST! be merged with Flags)
      ; DS:SI - Serial&Name of Current Partition (15-Bytes)
      ;=======================================================
     PCCTP_LocSearchInIPT:
      mov     ah, Flags_NoPartName       ;set Flags_NoPartName, PartName invalid
      mov     di, offset PartitionTable  ; ES:DI - IPT-Start
      mov     dl, es:CFG_Partitions
      or      dl, dl
      jz      PCCTP_LocCompFailed
     PCCTP_LocCompLoop:
         mov     al, es:[di+LocIPT_Flags]
         test    al, Flags_NowFound
         jnz     PCCTP_LocAlreadyFound
         ; Now compare IPT with current Partition
         cmp     dh, es:[di+LocIPT_SystemID]
         jne     PCCTP_LocMismatch
         cmp     cx, es:[di+LocIPT_AbsoluteBegin]
         jne     PCCTP_LocMismatch
         cmp     bx, es:[di+LocIPT_AbsoluteBegin+2]
         jne     PCCTP_LocMismatch
         jmp     PCCTP_Match
        PCCTP_LocMismatch:
        PCCTP_LocAlreadyFound:
         add     di, LocIPT_LenOfIPT
      dec     dl
      jnz     PCCTP_LocCompLoop
     PCCTP_LocCompFailed:
      jmp     PCCTP_CompareFailed
      
   ; ==================================
   ; =MATCH=, found partition in IPT...
   ;    AH - NoPartName-Flag (!MUST! be merged with Flags)
   ;    DL - IPT Partition Number from Loop (inverted)
   ; ES:DI - LocIPT-Pointer to found IPT-entry
   ; ==================================
  PCCTP_Match:
   mov     ch, ah
   ; Save the new location of this partition in the Xref-Table
   ;  for converting HideConfig.
   mov     dh, dl
   mov     dl, es:CFG_Partitions
   sub     dl, dh
   mov     dh, NewPartitions             ; is actually a counter
   call    PARTSCAN_DefXref              ; DL-IPT-Partition, DH-NewPartition

   ; Get Saved-Flags...
   mov     cl, byte ptr es:[di+LocIPT_Flags]     ; Use saved Flags

   ; ...and Saved-CRC if available...
   mov     ax, wptr es:[di+LocIPT_BootRecordCRC]
   or      ax, ax
   jz      PCCTP_UseNewComputedCRC
   mov     PartCRC, ax                   ; Use saved IPT-CRC
  PCCTP_UseNewComputedCRC:
   ; ...and mark partition in IPT as already found
   or      byte ptr es:[di+LocIPT_Flags], Flags_NowFound
   ; ...get Serial&Name from IPT-table...
   mov     si, di
   add     si, LocIPT_Serial             ; DS:SI - LocIPT-Serial&Name
   jmp     PCCTP_AddToNew

   ; =================================
   ; =FAILED= search, not found in IPT
   ;    AH - NoPartName-Flag (!MUST! be merged with Flags)
   ; DS:SI - Serial&Name of Current Partition (15-Bytes)
   ; =================================
  PCCTP_CompareFailed:
   mov     ch, ah
   ; Default Flags hinzufgen...
   mov     cl, LocIPT_DefaultFlags

   mov     al, PartTypeFlags
   ; May I auto-add partitions ?
   test    es:CFG_PartitionsDetect, 1
   jz      PCCTP_MayNotAddAny ; add, but non-bootable
   test    al, FileSysFlags_BootAble     ; AH kam von SearchFileSysName
   jnz     PCCTP_PerhapsBootAble
  PCCTP_MayNotAddAny:
   mov     cl, LocIPT_DefaultNonBootFlags
  PCCTP_PerhapsBootAble:

   ; On FAT32-partitions, default to P-Flag (which means using M$-hack)
   ;  Anyway, this hack has to be globaly activated by the user manually...
   cmp     PartSystemID, 09h             ; Hardcoded: FAT32
   je      PCCTP_NeedsExtMShack
   cmp     PartSystemID, 0Bh
   je      PCCTP_NeedsExtMShack
   cmp     PartSystemID, 0Ch
   je      PCCTP_NeedsExtMShack
   cmp     PartSystemID, 0Eh             ; FAT16 above 8 GB
   jne     PCCTP_NoExtMShack
   ; We only get here, when the SystemID seems to be an M$ "invention"...
     PCCTP_NeedsExtMShack:
      or      cl, Flags_ExtPartMShack
  PCCTP_NoExtMShack:

   ;================================================
   ; CL - IPT-Partition-Flags, CH - NoPartName-Flag
   ; DS:SI - PartSerial&Name (15-Bytes)
   ;================================================
  PCCTP_AddToNew:
   mov     al, Flags_NoPartName          ; Unset NoPartName
   not     al
   and     cl, al
   or      cl, ch                        ; CL = Both CL and CH merged

   ; Calculate Pointer to IPT
   mov     di, offset NewPartTable       ; ES:DI - NewPartTable
   movzx   ax, es:NewPartitions
   mov     bl, LocIPT_LenOfIPT
   mul     bl
   add     di, ax                        ; ES:DI - Last+1 Entry of NewPartTable

   ; Now finally write this partition to our IPT
   ;=============================================
   push    cx
      mov     cx, 15                     ; Copy Serial&Name...
      rep     movsb
   pop     cx

   lds     si, dptr PartPtr              ; DS:SI - Cur Partition Entry
   mov     al, bptr es:[CurPartition_Location+4] ; Drive
   stosb
   mov     al, PartSystemID              ; Unhidden SystemID
   stosb
   mov     al, cl                        ; Partition-Flags from register...
   stosb 
   mov     ax, PartCRC                   ; BootRecordCRC...
   stosw
   mov     al, bptr ds:[si+LocBRPT_BeginHead]
   stosb
   mov     ax, wptr ds:[si+LocBRPT_BeginSector] ; Cylinder/Sector
   stosw
   mov     al, bptr es:[CurPartition_Location+5] ; Head of Part-Table
   stosb
   mov     ax, wptr es:[CurPartition_Location+6] ; Cylinder/Sector
   stosw
   mov     ax, wptr ds:[si+LocBRPT_RelativeBegin]
   mov     bx, wptr ds:[si+LocBRPT_RelativeBegin+2]
   mov     cx, wptr es:[CurPartition_Location+0] ; +Partition-Absolute
   mov     dx, wptr es:[CurPartition_Location+2] ;  sectors
   add     ax, cx
   adc     bx, dx
   stosw
   mov     ax, bx
   stosw
   mov     ax, cx                        ; Absolute sector of partition table
   stosw
   mov     ax, dx
   stosw
   inc     es:NewPartitions              ; NEW IPT Entry DONE

   cmp     es:NewPartitions, LocIPT_MaxPartitions
   jbe     PCCTP_NotTooManyPartitions
   mov     ax, cs
   mov     ds, ax
   mov     si, offset TXT_TooManyPartitions
   call    MBR_Teletype
   jmp     MBR_HaltSystem

  PCCTP_NotTooManyPartitions:
   ; UNHIDE PARTITION, if it was hidden previously
   mov     al, PartSystemID
   cmp     al, 08h                       ; internally NTFS ?
   jne     PCCTP_NoInternalNTFS
   dec     al
  PCCTP_NoInternalNTFS:
   mov     bptr ds:[si+LocBRPT_SystemID], al

   ; Calculate Size of this partition...
   movzx   ax, es:NewPartitions
   dec     ax
   mov     bx, ax
   shl     ax, 1
   shl     bx, 2
   add     ax, bx                        ; My way [tm] of multiplying with 6
   mov     di, offset PartitionSizeTable
   add     di, ax                        ; DI - Partition Size-Element
   mov     ax, wptr ds:[si+LocBRPT_AbsoluteLength] ; Sector-Size
   mov     bx, wptr ds:[si+LocBRPT_AbsoluteLength+2]
   call    PART_FillOutSizeElement
   ret
PARTSCAN_CheckThisPartition     EndP

; Scans Current Partition for Extended Partitions, if found, AX,BX,CX,DX will
; be set to this location and Carry will be set
PARTSCAN_ScanPartitionForExtended Proc Near  Uses ds si
   mov     ax, ExecBaseSeg
   mov     ds, ax
   mov     si, ExecBasePtr
   add     si, 446                       ; DS:SI - First Partition Entry
   xor     ax, ax
  PSSPFE_ScanLoop:
      mov     al, ds:[si+LocBRPT_SystemID]
      cmp     al, 5                      ; Is Partition EXTENDED ?
      je      PSSPFE_ExtendedPartition
      cmp     al, 0Fh                    ; Is Partition EXTENDED (M$) ?
      je      PSSPFE_ExtendedPartition
      jmp     PSSPFE_IgnorePartition
     PSSPFE_ExtendedPartition:
      mov     ax, wptr ds:[si+LocBRPT_RelativeBegin]
      mov     bx, wptr ds:[si+LocBRPT_RelativeBegin+2]
      add     ax, wptr es:[ExtendedAbsPos+0] ; Adjust...
      adc     bx, wptr es:[ExtendedAbsPos+2] ; (Shit Design!)
      test    es:[ExtendedAbsPosSet], 1
      jnz     PSSPFE_ExtendedMainKnown
      mov     wptr es:[ExtendedAbsPos+0], ax
      mov     wptr es:[ExtendedAbsPos+2], bx
      mov     cs:[ExtendedAbsPosSet], 1
     PSSPFE_ExtendedMainKnown:
      mov     cx, wptr ds:[si+LocBRPT_BeginSector] ; Cylinder/Sector
      mov     dh, bptr ds:[si+LocBRPT_BeginHead]   ; Head
      mov     dl, bptr es:[CurPartition_Location+4] ; Drive
      stc
      jmp     PSSPFE_EndOfSearch
     PSSPFE_IgnorePartition:
      add     si, LocBRPT_LenOfEntry
   cmp     si, 500+ExecBasePtr
   jb      PSSPFE_ScanLoop
   clc
  PSSPFE_EndOfSearch:
   ret
PARTSCAN_ScanPartitionForExtended EndP

; ===================
;  X-REFERENCE STUFF -> PartitionXref
; ===================

; The following routines have DS==CS again

; Reset X-Reference
PARTSCAN_ResetXref              Proc Near   Uses ax cx es di
   push    cs
   pop     es
   mov     di, offset PartitionXref      ; X-Reference for later syncing
   mov     cx, LocIPT_MaxPartitions
   mov     ax, 0FFFFh                    ; Fill up with FFh
   rep     stosb
   mov     di, offset NewHidePartTable   ; Temporary Hide-Config Table
   mov     cx, 450                       ; Size is 900
   rep     stosw                         ; Fill up with FFFFh
   mov     di, offset NewDriveLetters
   mov     cx, 15                        ; Temporary Logical-Drive Letter Table
   xor     ax, ax                        ; Size is 30
   rep     stosw                         ; Fill up with 0000h
   ret
PARTSCAN_ResetXref              EndP

;        In: DL - Partition Number in IPT
;            DH - Partition Number in NewPartitionTable
; Destroyed: None
PARTSCAN_DefXref                Proc Near   Uses ax bx cx dx si di
   movzx   bx, dl
   mov     bptr [PartitionXref+bx], dh      ; X-Reference
   ; Copy Hide-Config of IPT partition to new location in new table
   mov     si, offset HidePartitionTable
   mov     di, offset NewHidePartTable
   mov     bl, LocIPT_MaxPartitions
   mov     al, dl
   mul     bl
   add     si, ax
   mov     al, dh
   mul     bl
   add     di, ax
   mov     cx, LocIPT_MaxPartitions
   rep     movsb                            ; Copy Hide-Config to NewHideTable
   ; Process Logical-Drive-Letter table as well...
   movzx   bx, dl
   mov     al, bptr [DriveLetters+bx]       ; Get Drv-Letter from org. pos
   movzx   bx, dh
   mov     bptr [NewDriveLetters+bx], al    ; Put Drv-Letter to new pos
   ret
PARTSCAN_DefXref                EndP

;        In: DL - Partition Number in previous IPT
;       Out: DH - Partition Number in NewPartitionTable
; Destroyed: None
PARTSCAN_GetXref                Proc Near   Uses bx
   movzx   bx, dl
   mov     dh, bptr [PartitionXref+bx]      ; X-Reference
   ret
PARTSCAN_GetXref                EndP

; This here updates the contents of the Hide-Configuration to the current IPT
;  table.
PARTSCAN_SyncHideConfigWithXref Proc Near Uses ax bx cx dx si di
   mov     si, offset NewHidePartTable
   mov     di, offset HidePartitionTable
   mov     ch, LocIPT_MaxPartitions
  PSSHCWX_SyncPartLoop:
      mov     cl, LocIPT_MaxPartitions
      xor     dl, dl                        ; Partition Lost Counter
     PSSHCWX_SyncLoop:
         lodsb                              ; Get Part-Pointer from Hide-Cfg
         cmp     al, 0FFh
         je      PSSHCWX_SyncEmpty
         movzx   bx, al
         mov     al, [PartitionXref+bx]     ; Translate it
         cmp     al, 0FFh
         je      PSSHCWX_PartLost
        PSSHCWX_SyncEmpty:
         stosb                              ; Put translated pointer to new table
      dec     cl
      jnz     PSSHCWX_SyncLoop
      jmp     PSSHCWX_SyncLoopEnd
        PSSHCWX_PartLost:
         inc     dl                         ; One partition got lost...
      dec     cl
      jnz     PSSHCWX_SyncLoop

     PSSHCWX_SyncLoopEnd:
      or      dl, dl
      jz      PSSHCWX_NothingLost
      mov     al, 0FFh
     PSSHCWX_LostFillLoop:
         stosb
      dec     cl
      jnz     PSSHCWX_LostFillLoop
     PSSHCWX_NothingLost:
   dec     ch
   jnz     PSSHCWX_SyncPartLoop
   ret
PARTSCAN_SyncHideConfigWithXref EndP
