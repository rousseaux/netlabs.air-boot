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
;                                                 AiR-BOOT / FAT-16 SUPPORT
;---------------------------------------------------------------------------

IFDEF   MODULE_NAMES
DB 'FAT16',0
ENDIF

; Here is access code for accessing FAT-16 partitions. It's not a complete
;  File-API and only for simple readonly-access.
; It's currently only used by SPECIAL\LINUX.ASM for Linux Kernel Loading.
;
; Note: This code will ONLY WORK on computers with INT 13h Extension.
;        I did not want to code silly cylinder stuff here. I have also used
;        i386 code in here, because Linux requires so as well. Please note that
;        I don't use i386 code anywhere (!) else in AiR-BOOT.                    ; Rousseau: yes you did, movezx is 386-only :-)
;                                                                                ; Replaced by 286 instructions.
; Initialize FAT-16 access on specified partition (required for following xs)
;        In: DS:SI - IPT-Entry that contains a FAT-16 partition
;       Out: None
; Destroyed: None
FAT16_InitAccess                Proc Near  Uses eax bx edx
   mov    al, bptr ds:[si+LocIPT_Drive]
   mov    FAT16_Drive, al
   mov    edx, dptr ds:[si+LocIPT_AbsoluteBegin]
   mov    FAT16_AbsPartitionBegin, edx
   mov    INT13X_DAP_Absolute, edx       ; Read in Boot-Record of partition
   mov    INT13X_DAP_NumBlocks, 1        ; 1 Sector to load
   mov    FAT16_FATCacheSector, 255      ; Sector 255 - So nothing cached
   mov    ax, ds
   shl    eax, 16
   mov    ax, offset FAT16_FATCache
   mov    INT13X_DAP_Transfer, eax       ; Transfer to FAT-Cache Area
   call   FAT16_LoadSectors
   mov    al, bptr [FAT16_FATCache+13]
   mov    FAT16_SecsPerCluster, al
   movzx  eax, wptr [FAT16_FATCache+14]  ; +14 -> ReservedSectors
   add    edx, eax                       ; EDX = AbsPartitionPos+ReservedSectors
   mov    FAT16_AbsFATBegin, edx         ; Is Absolute-FAT-Begin
   movzx  ax, bptr [FAT16_FATCache+16]   ; +16 -> FAT-Copies Count
   mov    bx, wptr [FAT16_FATCache+22]   ; +22 -> Sectors Per FAT
   mov    FAT16_SecsPerFAT, bx
   push   dx
      mul    bx
   pop    dx
   movzx  eax, ax
   add    edx, eax
   mov    FAT16_AbsRootBegin, edx        ; Is Absolute-Root-Begin
   movzx  eax, wptr [FAT16_FATCache+17]  ; +17 -> Number of Root Entries
   mov    FAT16_NumOfRootEntries, ax
   shr    eax, 4                         ; NumOfRootEntries/16
   add    edx, eax
   mov    FAT16_AbsClusterBegin, edx     ; Is Absolute-Cluster-Begin
   ret
FAT16_InitAccess                EndP

; Reads Root-Entries to 9000:0 for further processing...
;        In: None
;       Out: None
; Destroyed: None
FAT16_ReadRoot                  Proc Near  Uses eax
   mov    ax, 9000h
   shl    eax, 16                        ; 9000:0 -> Space for Root
   mov    INT13X_DAP_Transfer, eax       ; Transfer to that segment
   mov    eax, FAT16_AbsRootBegin
   mov    INT13X_DAP_Absolute, eax       ; Read in Root-Entries...
   mov    ax, FAT16_NumOfRootEntries
   shr    ax, 4                          ; NumOfRootEntries/16
   mov    INT13X_DAP_NumBlocks, ax       ;  -> Sectors of Root-Entries
   call   FAT16_LoadSectors              ; DONE.
   ret
FAT16_ReadRoot                  EndP

; Searches a FAT16-File-Entry in specified memory block
;        In: CX - Total Count of File-Entries to search
;            SI - Offset, what to search for Segment CS (11-Byte block)
;       Out: DX - Cluster, where the data starts...
; Destroyed: None
FAT16_SearchEntry               Proc Near  Uses ax bx es di
   xor    dx, dx                         ; No Result as default
   or     cx, cx
   jz     FAT16SE_NoEntries
   mov    bx, cx
   mov    ax, 9000h
   mov    es, ax
   xor    di, di
  FAT16SE_SearchLoop:
      push   si
      push   di
         mov    cx, 11
         repe   cmpsb                    ; Compare total 11-bytes
      pop    di
      pop    si
      je     FAT16SE_EntryFound
      add    di, 32                      ; Skip 1 FAT16-Entry now :)
   dec    bx
   jnz    FAT16SE_SearchLoop
  FAT16SE_NoEntries:
   ret

  FAT16SE_EntryFound:
   mov    dx, wptr es:[di+26]            ; Starting Cluster of Entry
   ret
FAT16_SearchEntry               EndP

; Reads a Cluster and gets Next-Cluster as well...
;        In: DX - Cluster-Number to load, DAP_Transfer-Offset filled out
;            ES - Segment, where to read Cluster to
;            DI - Offset, where to read Cluster to
;       Out: DX - Cluster that follows this one, es:[DI] filled out
;            DI - Offset, adjusted
; Destroyed: None
FAT16_ReadCluster               Proc Near  Uses eax bx
   push   dx
      ; First read Cluster into buffer...
      mov    ax, es
      shl    eax, 16
      mov    ax, di
      mov    INT13X_DAP_Transfer, eax    ; Read to 9000:DI
      mov    ax, dx
      sub    ax, 2                       ; Everything starts at Cluster 2
      ;movzx  bx, FAT16_SecsPerCluster
      mov   bl,FAT16_SecsPerCluster
      mov   bh,0

      mul    bx
      shl    edx, 16
      mov    dx, ax                      ; EDX - Relative to Cluster-Start
      add    edx, FAT16_AbsClusterBegin  ; EDX - Absolute Sector Count
      mov    INT13X_DAP_Absolute, edx
      mov    INT13X_DAP_NumBlocks, bx    ; Get a whole cluster
      call   FAT16_LoadSectors           ; DONE.
   pop    dx
   ; Update DI to next position...
   mov    al, FAT16_SecsPerCluster
   shl    ax, 9
   add    di, ax
   ; Finally, look for next Cluster following to this one...
   ;movzx  bx, dl
   mov   bl,dl
   mov   bh,0

   shl    bx, 1                          ; BX - Offset within FAT-Table
   shr    dx, 8                          ; DX - FAT-Sector
   cmp    dl, FAT16_FATCacheSector
   je     FAT16RC_GotFATsectorAlready
   ; Load FAT-Sector, because the required one is not in Cache
   mov    FAT16_FATCacheSector, dl
   mov    ax, cs
   shl    eax, 16
   mov    ax, offset FAT16_FATCache
   mov    INT13X_DAP_Transfer, eax       ; Transfer to FAT-Cache Area
   movzx  edx, dx
   mov    eax, FAT16_AbsFATBegin
   add    eax, edx
   mov    INT13X_DAP_Absolute, eax       ; Read in Boot-Record of partition
   mov    INT13X_DAP_NumBlocks, 1        ; 1 Sector to load
   call   FAT16_LoadSectors              ; DONE.
  FAT16RC_GotFATsectorAlready:
   mov    dx, wptr cs:[FAT16_FATCache+bx] ; Get Next-Cluster Pointer
   ret
FAT16_ReadCluster               EndP

; Preserves all registers, help routine for LoadKernel
; supports more than 1 sector read (unlike MBR_IO_LoadSector)
FAT16_LoadSectors               Proc Near  Uses eax dx ds si
   push   cs
   pop    ds
   mov    si, offset INT13X_DAP
   mov    dl, ds:[FAT16_Drive]
   mov    ah, 42h                        ; Extended Read
   int    13h
   jnc    FAT16LS_Success
   call   MBR_LoadError

  FAT16LS_Success:
   movzx  eax, wptr ds:[INT13X_DAP_NumBlocks]
   add    dptr ds:[INT13X_DAP_Absolute+0], eax  ; Adjust Absolute Offset
   ret
FAT16_LoadSectors               EndP

; Will Pre-Process Directory loaded to 9000:0, remove directory and VFAT
;  entries for display purpose in window
;        In: DI - Ending-Offset of Directory
;            ES == CS
;       Out: None
; Destroyed: None
FAT16_ProcessKrnlDirectory      Proc Near  Uses ds si es di
   mov    dx, di                         ; DX - Ending-Offset of Directory
   mov    ax, 9000h
   mov    ds, ax                         ; DS == 9000h
   xor    si, si                         ; SI - Current Pos in Directory
   mov    di, offset LINUX_KernelEntries ; DI - Array of Kernel-Entries
   mov    cs:[LINUX_KernelNo], 0
  FAT16PPD_DirectoryLoop:
      mov    al, ds:[si]                 ; +0  -> First char of Basename
      or     al, al
      jz     FAT16PPD_IgnoreEntry        ; == 0, empty
      cmp    al, 0E5h
      je     FAT16PPD_IgnoreEntry        ; == E5, deleted
      mov    al, ds:[si+11]              ; +11 -> Flags of Entry
      cmp    al, 0Fh                     ; 0F as flags -> VFAT Entry
      je     FAT16PPD_IgnoreEntry
      test   al, 18h                     ; Bit 4 -> Directory
      jnz    FAT16PPD_IgnoreEntry        ; Bit 3 -> Volume

      ; Set Size-Entry in KernelSizeTable
      push   ds
      push   si
      push   di
         mov    bx, ds:[si+30]
         mov    ax, ds:[si+28]           ; BX:AX - Size of file in Bytes

         mov    dx, bx
         and    dx, 511                  ; My crazy way of dividing a 32-bit
         shr    ax, 9                    ; value through 512 using 16-bit
         shr    bx, 9                    ; instructions... :)
         shl    dx, 7                    ; (dont ever ever use a DIV)
         or     ax, dx                   ; BX:AX - Size of file in 512-blocks

         push   cs
         pop    ds                       ; DS==CS for GetSizeElementPtr
         push   ax
            mov    ax, di
            call   PART_GetSizeElementPointer ; SI - Pointer to Size Element
         pop    ax
         mov    di, si
         call   PART_FillOutSizeElement  ; BX:AX -> ES:DI (Size Element)
      pop    di
      pop    si
      pop    ds

      ; Copy entry and make append extension to basename
      ; "TEST    TMP" -> "TESTTMP    "
      mov    bx, 7
     FAT16PPD_GetLenOfBasename:
         cmp    bptr ds:[si+bx], ' '
         jne    FAT16PPD_EndOfBasename
      dec    bx
      jnz    FAT16PPD_GetLenOfBasename
     FAT16PPD_EndOfBasename:
      mov    ah, bl
      inc    ah                          ; AH - Count of Basename Chars (max 8)
      mov    bx, 10
     FAT16PPD_GetLenOfExtension:
         cmp    bptr ds:[si+bx], ' '
         jne    FAT16PPD_EndOfExtension
         dec    bl
      cmp    bl, 7
      ja     FAT16PPD_GetLenOfExtension
     FAT16PPD_EndOfExtension:
      sub    bl, 7                       ; BL - Count of Extension Chars (max 3)
      ; Now we will copy&fill out 11 characters (Basename&Extension)
      push   dx
         push      ax
            xor    eax, eax
            stosd                        ; +0 [DWORD] Empty Serial
         pop       ax
         mov    dx, si
         ;movzx  cx, ah
         mov   cl,ah
         mov   ch,0

         rep    movsb
         mov    si, dx                   ; Restore SI
         add    si, 8
         or     bl, bl
         jz     FAT16PPD_NoExtensionCopy
         mov    cl, bl
         rep    movsb
        FAT16PPD_NoExtensionCopy:
         add    ah, bl                   ; AH - Total Bytes of BaseName
         mov    cl, 11
         mov    al, ' '
         sub    cl, ah
         jz     FAT16PPD_NoFillUpName
         rep    stosb                    ; +4 [STR*11] Label
        FAT16PPD_NoFillUpName:
         mov    si, dx                   ; Restore SI

         mov    al, FAT16_Drive
         mov    ah, 0FDh
         stosw                           ; +15 [BYTE/BYTE] Drive, SystemID
         xor    ax, ax
         stosb                           ; +17 [BYTE] Flags
         stosw                           ; +18 [WORD] CRC
         mov    ax, wptr ds:[si+26]      ; Starting Cluster of File
         stosw
         xor    ax, ax
         stosb                           ; +20 [BYTE/BYTE/BYTE] Location Begin
         stosw
         stosb                           ; +23 [BYTE/BYTE/BYTE] Location Part
         mov    cx, 4
         rep    stosw                    ; +26 [DWORD/DWORD] Abs Locations
      pop    dx
      inc    cs:[LINUX_KernelNo]
     FAT16PPD_IgnoreEntry:
   add    si, 32
   cmp    si, dx                         ; We are at Ending-Offset ?
   jb     FAT16PPD_DirectoryLoop
   ; Done, now we got a maximum of 20 kernels in LINUX_KernelEntries-Array.
   ret
FAT16_ProcessKrnlDirectory      EndP
