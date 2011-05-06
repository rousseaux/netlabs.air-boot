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
;                                             AiR-BOOT / PARTiTiON SCANNING
;---------------------------------------------------------------------------


IFDEF ModuleNames
DB 'PARTSCAN',0
ENDIF

; Note: This is complex code. So make sure that you know what you are doing in
;        here.

PARTSCAN_ScanForPartitions      Proc Near  Uses
   ; Reset X-Reference
   call    PARTSCAN_ResetXref

   mov     dh, TotalHarddiscs
   xor     al, al
   mov     NewPartitions, al

   mov     CurIO_Scanning, 1             ; Set flag due scanning partitions
   mov     dl, 80h                       ; is first harddisc
  PSSFP_HarddiscLoop:
      push    dx
         call    PARTSCAN_ScanDriveForPartitions
      pop     dx
      inc     dl
   dec     dh
   jnz     PSSFP_HarddiscLoop
   mov     CurIO_Scanning, 0             ; Reset flag due scanning complete

   ; Use X-Reference to sync NewPartitionTable with Hide-Config
   call    PARTSCAN_SyncHideConfigWithXref

   ; Now we copy the new IPT over the old one...
   mov     si, offset NewPartTable
   mov     di, offset PartitionTable
   ;movzx   ax, NewPartitions
   mov   al,NewPartitions
   mov   ah,0

   mov     CFG_Partitions, al
   mov     bl, LocIPT_LenOfIPT
   mul     bl
   mov     cx, ax
   rep     movsb

   ; and the New Logical Drive Letter table as well...
   mov     si, offset NewDriveLetters
   mov     di, offset DriveLetters
   mov     cx, LocIPT_MaxPartitions
   rep     movsb

; [Linux support removed since v1.02]
;   ; Search for any Linux partition and remember, if it got found...
;   mov     si, offset PartitionTable
;   movzx   cx, CFG_Partitions
;   xor     dl, dl                        ; DL - Is Linux here ?
;   or      cx, cx
;   jz      PSSFP_NoPartitions
;  PSSFP_LinuxLoop:
;      cmp     bptr [si+LocIPT_SystemID], 083h  ; Hard-Coded
;      jne     PSSFP_NoLinux
;      mov     dl, 1                      ; Linux found...
;     PSSFP_NoLinux:
;      add     si, LocIPT_LenOfIPT
;   loop    PSSFP_LinuxLoop
;  PSSFP_NoPartitions:
;   mov     GotLinux, dl                  ; Set Flag

   ; ...and finally check, if we need to set a Drive-Letter
   mov     dl, AutoDrvLetter
   or      dl, dl
   jz      PSSFP_NoAutoDriveLetter
   ;movzx   cx, CFG_Partitions
   mov   cl,CFG_Partitions
   mov   ch,0

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

   call    DriveIO_LoadPartition                                                 ; Rousseau: load a partition record

   jc      PSSDFP_InvalidPartition

   ; LVM Support - Reads LVM Information Sector
   call    DriveIO_LoadLVMSector                                                 ; Rousseau: load LVM sector

   call    PARTSCAN_ScanPartition
   IFDEF ReleaseCode
      call    DriveIO_SavePartition
   ENDIF
   call    PARTSCAN_ScanPartitionForExtended
   jc      PSSDFP_LoadThisPartition
  PSSDFP_InvalidPartition:
   ret
PARTSCAN_ScanDriveForPartitions EndP

; Scans Current Partition for Extended Partitions, if found, AX,BX,CX,DX will
; be set to this location and Carry will be set
PARTSCAN_ScanPartitionForExtended Proc Near  Uses si
   mov     si, offset PartitionSector+446 ; DS:SI - 1st partition entry
   xor     ax, ax
  PSSPFE_ScanLoop:
      mov     al, [si+LocBRPT_SystemID]
      cmp     al, 5                      ; Is Partition EXTENDED ?
      je      PSSPFE_ExtendedPartition
      cmp     al, 0Fh                    ; Is Partition EXTENDED (M$) ?
      je      PSSPFE_ExtendedPartition
      jmp     PSSPFE_IgnorePartition
     PSSPFE_ExtendedPartition:
      mov     ax, wptr [si+LocBRPT_RelativeBegin]
      mov     bx, wptr [si+LocBRPT_RelativeBegin+2]
      add     ax, wptr [ExtendedAbsPos+0] ; Adjust...
      adc     bx, wptr [ExtendedAbsPos+2] ; (Shit Design!)
      test    [ExtendedAbsPosSet], 1
      jnz     PSSPFE_ExtendedMainKnown
      mov     wptr [ExtendedAbsPos+0], ax
      mov     wptr [ExtendedAbsPos+2], bx
      mov     [ExtendedAbsPosSet], 1
     PSSPFE_ExtendedMainKnown:
      mov     cx, wptr [si+LocBRPT_BeginSector] ; Cylinder/Sector
      mov     dh, bptr [si+LocBRPT_BeginHead]   ; Head
      mov     dl, bptr [CurPartition_Location+4] ; Drive
      stc
      jmp     PSSPFE_EndOfSearch
     PSSPFE_IgnorePartition:
      add     si, LocBRPT_LenOfEntry
   cmp     si, 500+offset PartitionSector
   jb      PSSPFE_ScanLoop
   clc
  PSSPFE_EndOfSearch:
   ret
PARTSCAN_ScanPartitionForExtended EndP

; The following routines have NOT *DS* set to CS, so we must address via ES
PARTSCAN_ScanPartition          Proc Near  Uses ax si
   mov     si, offset PartitionSector+446 ; DS:SI - 1st Partition-Entry
  PSSP_ScanLoop:
      mov     al, bptr [si+LocBRPT_SystemID]
      cmp     al, 5                      ; Is Partition EXTENDED ?
      je      PSSP_IgnorePartition
      cmp     al, 0Fh                    ; Is Partition EXTENDED (M$-DOS7) ?
      je      PSSP_IgnorePartition
      cmp     al, 0                      ; Is Partition EMPTY ?
      je      PSSP_IgnorePartition
      ; Ignore these partitions, because there are no real Partitions
      call    PARTSCAN_CheckThisPartition
     PSSP_IgnorePartition:
      ; L”scht das Boot-Able Flag...
      and     byte ptr [si+LocBRPT_Flags], 7Fh ; Reset the Active-Flag
      add     si, LocBRPT_LenOfEntry     ; 16 Bytes per partition entry
   cmp     si, 500+offset PartitionSector
   jb      PSSP_ScanLoop
   ; If we are on first HDD and in primary partition table -> mark primary
   cmp     bptr [CurPartition_Location+4], 80h ; Drive
   jne     PSSP_NoMarkPrimary
   cmp     wptr [CurPartition_Location+0], 0
   jne     PSSP_NoMarkPrimary
   cmp     wptr [CurPartition_Location+2], 0 ; Absolute Location
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
;        In: SI - Points to Partition-Entry (16-Bytes)
PARTSCAN_CheckThisPartition     Proc Near  Uses di si
   local   PartSystemID:byte, PartTypeFlags:byte
   local   PartCRC:word, PartPtr:word

   mov     wptr [PartPtr], si          ; Save Pointer to PartitionEntry

   mov     al, bptr [si+LocBRPT_SystemID]
   mov     PartSystemID, al

   mov     cx, wptr [si+LocBRPT_BeginSector] ; Cylinder/Sector
   mov     dh, bptr [si+LocBRPT_BeginHead] ; Head
   mov     dl, bptr [CurPartition_Location+4] ; Drive
   mov     ax, wptr [si+LocBRPT_RelativeBegin] ; Absolute Sector
   mov     bx, wptr [si+LocBRPT_RelativeBegin+2]
   add     ax, wptr [CurPartition_Location+0] ; +Partition-Absolute
   adc     bx, wptr [CurPartition_Location+2] ;  sectors
   call    DriveIO_LoadTmpSector         ; Loads Boot record                     ; Rousseau: LOAD PARTITION BOOT RECORD !!
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
   ;================================

   cmp     PartSystemID, 07h          ; We got IFS here?
   jne     PCCTP_IFSdone
   ; Check, if 'JFS ' is at DWORD offset 36h                                     ; Rousseau: JFS check (LVM / IPT?)
   cmp     wptr [si+36h], 'FJ'
   jne     PCCTP_IFSnoJFS
   cmp     wptr [si+38h], ' S'
   jne     PCCTP_IFSnoJFS
   mov     PartSystemID, 0FCh         ; FC is JFS internally
   jmp     PCCTP_IFSdone
  PCCTP_IFSnoJFS:
   ; Check, if 'HPFS' is at DWORD offset 36h
   cmp     wptr [si+36h], 'PH'
   jne     PCCTP_ProbablyNTFS
   cmp     wptr [si+38h], 'SF'
   je      PCCTP_IFSdone              ; 07 is HPFS internally
  PCCTP_ProbablyNTFS:
   inc     PartSystemID               ; 08 is NTFS instead of 07
  PCCTP_IFSdone:

   ; First check, if LVM Information Sector is available and this partition
   ;  is supported.
   push    ax dx si di
      mov     si, wptr [PartPtr]
      mov     ax, wptr [si+LocBRPT_RelativeBegin] ; Absolute Sector
      mov     dx, wptr [si+LocBRPT_RelativeBegin+2]
      add     ax, wptr [CurPartition_Location+0] ; +Partition-Absolute
      adc     dx, wptr [CurPartition_Location+2] ;  sectors
      mov     si, offset LVMSector
      call    LVM_SearchForPartition     ; Search for DX:AX partition
      jnc     PCCTP_CheckBootRecord
      ; Check, if volume has driveletter assigned and remember it for later
      mov     al, [si+LocLVM_VolumeLetter]
      or      al, al
      jnz     PCCTP_HasVolumeLetter
      mov     al, 1                      ; 0 would mean "not LVM supported"
     PCCTP_HasVolumeLetter:
      ; Save VolumeLetter in separate table
      ;movzx   bx, NewPartitions          ; NewPartitions is one behind here, so
      mov   bl,NewPartitions          ; NewPartitions is one behind here, so
      mov   bh,0

      mov     [PartitionVolumeLetters+bx], al ; it's already a zero-based offset
      ; Now copy VolumeID and VolumeName to temporary space
      mov     di, offset MBR_NoName_Patched
      mov     ax, [si+LocLVM_PartitionID]
      stosw
      mov     ax, [si+LocLVM_PartitionID+2]
      stosw
                              ; Set Serial-Field to LVM-VolumeID
      push     di
      add     si, LocLVM_PartitionName

      mov     cx, 5
      rep     movsw                      ; Copy LVM-PartitionName to Temp Space
      movsb                               ;  (11 bytes in total)

      pop   di
      cmp   PartSystemID, 0ah

      jne   PCCTP_NoIbmBm
      mov   si, offset ibm_bm_name
      mov   cx,5
      rep   movsw
      movsb



   PCCTP_NoIbmBm:


   pop     di si dx ax
   mov     si, offset MBR_NoName_Patched
   xor     ah, ah                        ; no Flags_NoPartName
   jmp     PCCTP_NameSearchInIPT

     PCCTP_CheckBootRecord:
   pop     di si dx ax
   test    ah, FileSysFlags_NoName       ; No-Name-Flag ? -> No Partition Name

   jz      PCCTP_ThereIsAName
   jmp     PCCTP_ThereIsNoName           ;                    available

   PCCTP_ThereIsAName:

      ; We check for NTFS (got detected a little bit earlier in this routine)
      cmp     PartSystemID, 08h          ; We got IFS/NTFS here?
      jne     PCCTP_IsNoNTFS
      jmp     PCCTP_ThereIsNoName        ; NTFS has no volume label
     PCCTP_IsNoNTFS:
      add     si, 2Bh                    ; DS:SI - Partition-Name
      test    ah, FileSysFlags_FAT32     ; FAT32 specific name getting ?

      jz      PCCTP_ResumeNormal

      add     si, 1Ch                    ; Fix for FAT 32, shiat
     PCCTP_ResumeNormal:
      mov     cx, 11                     ;         11 bytes length
      call    PART_CheckForValidPartName
      jc    PCCTP_ThereIsAName2

      jmp     PCCTP_ThereIsNoName

   PCCTP_ThereIsAName2:

      sub     si, 4                      ; DS:SI -> Serial&Name (15-Bytes)
      xor     ah, ah                     ; no Flags_NoPartName
;      jmp     PCCTP_NameSearchInIPT

      ;=======================================================
      ; NAME SEARCH in IPT-Table
      ; DS:SI - Serial&Name of Current Partition (15-Bytes)
      ;    AH - NoPartName-Flag (!MUST! be merged with Flags)
      ;=======================================================
     PCCTP_NameSearchInIPT:
      xor     ah, ah                     ; no Flags_NoPartName cause PartName valid
      mov     di, offset PartitionTable  ; ES:DI - IPT-Start
      mov     dl, CFG_Partitions
      or      dl, dl
      jnz     PCCTP_SerialNameCompLoop
      jmp     PCCTP_CompareFailed
     PCCTP_SerialNameCompLoop:
         mov     al, [di+LocIPT_Flags]
         test    al, Flags_NowFound
         jnz     PCCTP_SerialNameAlreadyFound
         ; Now compare IPT with current Partition
         mov     cx, 15                  ; Serial&Name (15-Bytes)
         push    si di
            repz    cmpsb
         pop     di si

         jne   PCCTP_NoMatchYet

         jmp      PCCTP_Match

      PCCTP_NoMatchYet:

        PCCTP_SerialNameAlreadyFound:
         add     di, LocIPT_LenOfIPT
      dec     dl
      jnz     PCCTP_SerialNameCompLoop

      ; if we didn't find Serial&Name, let's try Name-only without Serial
      mov     di, offset PartitionTable  ; ES:DI - IPT-Start
      mov     dl, CFG_Partitions
     PCCTP_NameCompLoop:
         mov     al, [di+LocIPT_Flags]
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
         mov     cx, [si+0]           ; Get Serial
         mov     [di+0], cx
         mov     cx, [si+2]
         mov     [di+2], cx           ; ...and put it into IPT
         jmp     PCCTP_Match
        PCCTP_NameNoMatch:
        PCCTP_NameAlreadyFound:
         add     di, LocIPT_LenOfIPT
      dec     dl
      jnz     PCCTP_NameCompLoop
     PCCTP_NameCompFailed:

      ; So finally we search for Location and PartitionID
      push    si
         ; Initialize some stuff for Location-Search
         mov     dh, PartSystemID
         mov     si, [PartPtr]           ; DS:SI - Cur Partition Table
         ; Relative Sector to MBR/EPR
         mov     cx, wptr [si+LocBRPT_RelativeBegin]
         mov     bx, wptr [si+LocBRPT_RelativeBegin+2]
         add     cx, [CurPartition_Location+0]
         add     bx, [CurPartition_Location+2]
         ; BX:CX - Absolute First Sector of Partition on HDD
      pop     si
      mov     di, offset PartitionTable  ; ES:DI - IPT-Start
      mov     dl, CFG_Partitions
     PCCTP_NameLocCompLoop:
         mov     al, [di+LocIPT_Flags]
         test    al, Flags_NowFound
         jnz     PCCTP_NameLocAlreadyFound
         ; Now compare IPT with current Partition
         cmp     dh, [di+LocIPT_SystemID]
         jne     PCCTP_NameLocMismatch
         cmp     cx, [di+LocIPT_AbsoluteBegin]
         jne     PCCTP_NameLocMismatch
         cmp     bx, [di+LocIPT_AbsoluteBegin+2]
         jne     PCCTP_NameLocMismatch
         ; We matched location, now copy the current PartitionID and Name to
         ;  the old IPT.
         push    di
            add     di, LocIPT_Serial    ; DS:SI - LocIPT-Serial&Name
            mov     cx, 15
            rep     movsb                ; Copy 15 bytes
         pop     di
         jmp     PCCTP_Match
        PCCTP_NameLocMismatch:
        PCCTP_NameLocAlreadyFound:
         add     di, LocIPT_LenOfIPT
      dec     dl
      jnz     PCCTP_NameLocCompLoop
      ; None of the searches worked, so forget it...
      jmp     PCCTP_CompareFailed

  PCCTP_ThereIsNoName:
      ; Try to find this partition by comparing location and PartitionID
      ;  aka LocIPT_AbsoluteBegin:dword and LocIPT_SystemID
      ; If found, simply go to the normal match-routine, otherwise use the
      ;  File-System-Name to build the Volume-Label for the New IPT Entry.
      mov     dh, PartSystemID
      mov     si, [PartPtr]           ; DS:SI - Cur Partition Table
      ; Relative Sector to MBR/EPR
      mov     cx, wptr [si+LocBRPT_RelativeBegin]
      mov     bx, wptr [si+LocBRPT_RelativeBegin+2]
      add     cx, [CurPartition_Location+0]
      add     bx, [CurPartition_Location+2]
      ; Build a standard-Volume Label from FileSystemNamePtr
      ;  We have to call SearchFileSysName again because of NTFS
      push    ax cx
         mov     al, dh
         call    PART_SearchFileSysName   ; We want SI here <- FileSystemNamePtr
         mov     di, offset MBR_NoName_Patched
         xor     ax, ax
         stosw
         stosw                           ; Set Serial-Field to "NUL"
         mov     cx, 4
         rep     movsw                   ; Copy FileSystemName to Temp Space
         xor     ax, ax
         stosw
         stosb                           ; Fill last 3 bytes with "NUL"
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
      mov     dl, CFG_Partitions
      or      dl, dl
      jz      PCCTP_LocCompFailed
     PCCTP_LocCompLoop:
         mov     al, [di+LocIPT_Flags]
         test    al, Flags_NowFound
         jnz     PCCTP_LocAlreadyFound
         ; Now compare IPT with current Partition
         cmp     dh, [di+LocIPT_SystemID]
         jne     PCCTP_LocMismatch
         cmp     cx, [di+LocIPT_AbsoluteBegin]
         jne     PCCTP_LocMismatch
         cmp     bx, [di+LocIPT_AbsoluteBegin+2]
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
   mov     dl, CFG_Partitions
   sub     dl, dh
   mov     dh, NewPartitions             ; is actually a counter
   call    PARTSCAN_DefXref              ; DL-IPT-Partition, DH-NewPartition

   ; Get Saved-Flags...
   mov     cl, bptr [di+LocIPT_Flags]    ; Use saved Flags

   ; ...and Saved-CRC if available...
   mov     ax, wptr [di+LocIPT_BootRecordCRC]
   or      ax, ax
   jz      PCCTP_UseNewComputedCRC
   mov     PartCRC, ax                   ; Use saved IPT-CRC
  PCCTP_UseNewComputedCRC:
   ; ...and mark partition in IPT as already found
   or      bptr [di+LocIPT_Flags], Flags_NowFound
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
   test    CFG_PartitionsDetect, 1
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
   ;movzx   ax, NewPartitions
   mov   al,NewPartitions
   mov   ah,0

   mov     bl, LocIPT_LenOfIPT
   mul     bl
   add     di, ax                        ; ES:DI - Last+1 Entry of NewPartTable

   ; Now finally write this partition to our IPT
   ;=============================================
   push    cx
      mov     cx, 15                     ; Copy Serial&Name...
      rep     movsb
   pop     cx

   mov     si, [PartPtr]                 ; DS:SI - Cur Partition Entry
   mov     al, bptr [CurPartition_Location+4] ; Drive
   stosb
   mov     al, PartSystemID              ; Unhidden SystemID
   stosb
   mov     al, cl                        ; Partition-Flags from register...
   stosb
   mov     ax, PartCRC                   ; BootRecordCRC...
   stosw
   mov     al, bptr [si+LocBRPT_BeginHead]
   stosb
   mov     ax, wptr [si+LocBRPT_BeginSector] ; Cylinder/Sector
   stosw
   mov     al, bptr [CurPartition_Location+5] ; Head of Part-Table
   stosb
   mov     ax, wptr [CurPartition_Location+6] ; Cylinder/Sector
   stosw
   mov     ax, wptr [si+LocBRPT_RelativeBegin]
   mov     bx, wptr [si+LocBRPT_RelativeBegin+2]
   mov     cx, wptr [CurPartition_Location+0] ; +Partition-Absolute
   mov     dx, wptr [CurPartition_Location+2] ;  sectors
   add     ax, cx
   adc     bx, dx
   stosw
   mov     ax, bx
   stosw
   mov     ax, cx                        ; Absolute sector of partition table
   stosw
   mov     ax, dx
   stosw
   inc     NewPartitions                 ; NEW IPT Entry DONE

   cmp     NewPartitions, LocIPT_MaxPartitions
   jbe     PCCTP_NotTooManyPartitions
   mov     si, offset TXT_TooManyPartitions
   call    MBR_Teletype
   jmp     MBR_HaltSystem

  PCCTP_NotTooManyPartitions:
   ; UNHIDE PARTITION, if it was hidden previously
   mov     al, PartSystemID
   cmp     al, 08h                       ; internally IFS/NTFS?
   je      PCCTP_GotInternalIFS
   cmp     al, 0FCh                      ; internally IFS/JFS?
   jne     PCCTP_NoInternalIFS
  PCCTP_GotInternalIFS:
   mov     al, 07h
  PCCTP_NoInternalIFS:
   mov     bptr [si+LocBRPT_SystemID], al

   ; Calculate Size of this partition and put it into separate table...
   ;movzx   ax, NewPartitions
   mov   al,NewPartitions
   mov   ah,0

   dec     ax
   mov     bx, ax
   shl     ax, 1
   shl     bx, 2
   add     ax, bx                        ; My way [tm] of multiplying with 6
   mov     di, offset PartitionSizeTable
   add     di, ax                        ; DI - Partition Size-Element
   mov     ax, wptr [si+LocBRPT_AbsoluteLength] ; Sector-Size
   mov     bx, wptr [si+LocBRPT_AbsoluteLength+2]
   call    PART_FillOutSizeElement
   ret
PARTSCAN_CheckThisPartition     EndP

; ===================
;  X-REFERENCE STUFF -> PartitionXref
; ===================

; Reset X-Reference
PARTSCAN_ResetXref              Proc Near   Uses ax cx di
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
   ;movzx   bx, dl
   mov   bl,dl
   mov   bh,0

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
   ;movzx   bx, dl
   mov   bl,dl
   mov   bh,0

   mov     al, bptr [DriveLetters+bx]       ; Get Drv-Letter from org. pos
   ;movzx   bx, dh
   mov   bl,dl
   mov   bh,0

   mov     bptr [NewDriveLetters+bx], al    ; Put Drv-Letter to new pos
   ret
PARTSCAN_DefXref                EndP

;        In: DL - Partition Number in previous IPT
;       Out: DH - Partition Number in NewPartitionTable
; Destroyed: None
PARTSCAN_GetXref                Proc Near   Uses bx
   ;movzx   bx, dl
   mov   bl,dl
   mov   bh,0

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
         ;movzx   bx, al
         mov   bl,al
         mov   bh,0

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

ibm_bm_name:   db 'IBM BootMan',0
