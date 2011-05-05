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

; Note: Some routines set DS/ES to CS or even address via CS, even if its not
;        needed. This was done for SECURITY. So DO NOT remove it.
;        Its there to make sure the correct data is loaded/written to/from
;        harddrive.
;
;  IF YOU MODIFY ANYTHING IN HERE, YOU MAY EASILY BREAK YOUR HARDDRIVE!

; Will only load base-configuration, will NOT load IPT nor Hide-Config
;  Those are originally loaded on startup and will NOT get reloaded.
DriveIO_LoadConfiguration       Proc Near   Uses ax bx cx dx es
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
DriveIO_LoadConfiguration       EndP

DriveIO_SaveConfiguration       Proc Near   Uses ax bx cx dx ds es si
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
   mov     cx, 5                         ; Total of 5 Config-Sectors
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
   mov     ax, 0305h                     ; Function 03, 5 sectors to write
   int     13h
   jnc     DIOSC_NoError
   call    MBR_SaveError                 ; Will Abort BootUp
  DIOSC_NoError:
   ret
DriveIO_SaveConfiguration       EndP

DriveIO_UpdateFloppyName        Proc Near   Uses bx cx dx ds si es di
   mov     ax, cs
   mov     ds, ax
   mov     es, ax

   mov     ah, 00h                        ; Function 2 - Reset Drive
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
DriveIO_UpdateFloppyName        EndP

; =============================================================================
;                      HARDDRIVE / GENERAL ACCESS
; =============================================================================
;  The following routines are used for harddisc/floppy access.
;  The access is done via INT 13h/CHS or INT 13h/LBA.
;  Access will be done prefered by INT 13h/CHS, because it's (I wonder!) much
;   faster, than the LBA-method. I don't know, why LBA is so slow. Perhaps BIOS.
;
;  Internal access (to AiR-BOOT) is always done via INT 13h/CHS.

DriveIO_GetHardDriveCount       Proc Near   Uses ds si
   push    ds si
      push    0040h
      pop     ds
      mov     si, 0075h
      mov     dh, ds:[si]                ; 40:75 -> POST: Total Harddiscs == DL
   pop     si ds
   mov     TotalHarddiscs, dh
   ret
DriveIO_GetHardDriveCount       EndP


; Fills our LBA-Usage table. It holds the LBA-address, where BIOS/CHS access is
;  stopped and BIOS/LBA access is started.
;  This is calculated by Sector*Heads. Comparing will get done with Bit 25-10
;  on LBA sectors, so we actually divide sector number by 1024.
DriveIO_InitLBASwitchTable      Proc Near   Uses es di
   mov     di, offset LBASwitchTable
   mov     dh, TotalHarddiscs
   mov     dl, 80h
  DIOILUT_DriveLoop:
      push    dx di
         mov     ah, 08h
         int     13h            ; DISK - GET DRIVE PARAMETERS
         mov     ah, 0FBh       ; Assume 255 heads/63 sectors, if error
         jc      DIOILUT_Error
         and     cl, 111111b    ; Isolate lower 6 bits of CL -> sector count
         movzx   ax, cl
         mov     bl, dh         ; DH -> head count
         mul     bl             ; AX = Sectors*Heads
         shl     ah, 1
         shl     ah, 1          ; Shift 2 bits, so we are able to compare to
                                ;  bit 16-23 of the LBA address
        DIOILUT_Error:
      pop     di dx
      mov     bptr ds:[di], ah  ; Save that value
      inc     di                ; Go to next BYTE
      inc     dl
   dec     dh
   jnz     DIOILUT_DriveLoop
   ret
DriveIO_InitLBASwitchTable      EndP

; Adjusts BX:AX / CX:DX to meet LVM sector location
;  Destroys SI
DriveIO_LVMAdjustToInfoSector   Proc Near   Uses
   push    cx
      xor     ch, ch
      and     cl, 63                     ; Isolate lower bits, because upper
      mov     si, 63                     ;  ones may be used for cylinder
      sub     si, cx
   pop     cx
   add     ax, si
   adc     bx, 0                         ; Adjust LBA Sector (BX:AX)
   or      cl, 63                        ; Set Sector to 63
   ret
DriveIO_LVMAdjustToInfoSector   EndP

Comment *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Routine: Loads partition to ExecBase and checks for validity
 ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
 Calling : bx:ax - Absolute sector
           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
 Returns : Carry Set if invalid partition encountered
 Preserve: all registers
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*
DriveIO_LoadPartition           Proc Near  Uses si
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
   ret
  DIOLP_Failed:
   jmp     DriveIO_GotLoadError
DriveIO_LoadPartition           EndP

Comment *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Routine: Writes a partition from ExecBase to its original sector
 ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
 Calling : none
 Returns : none
 Preserve: all registers
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*
DriveIO_SavePartition           Proc Near  Uses ax bx cx dx si
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
DriveIO_SavePartition           EndP

; Keeps DS:SI for caller
DriveIO_LoadTmpSector           Proc Near  Uses
   mov     si, offset TmpSector
   call    DriveIO_LoadSector
   ret
DriveIO_LoadTmpSector           EndP

; Keeps DS:SI for caller
DriveIO_SaveTmpSector           Proc Near  Uses
   mov     si, offset TmpSector
   call    DriveIO_SaveSector
   ret
DriveIO_SaveTmpSector           EndP

; Keeps DS:SI for caller, sets carry if valid LVM sector encountered
DriveIO_LoadLVMSector           Proc Near  Uses ax bx cx dx
   test    [CFG_IgnoreLVM], 1            ; We are supposed to ignore LVM, so
   jnz     DIOLLVMS_NoLVMSector          ;  don't load but declare as bad!
   mov     ax, wptr cs:[CurPartition_Location+0]
   mov     bx, wptr cs:[CurPartition_Location+2]
   mov     dx, wptr cs:[CurPartition_Location+4]
   mov     cx, wptr cs:[CurPartition_Location+6] ; Gets cur. partition location
   call    DriveIO_LVMAdjustToInfoSector
   mov     si, offset LVMSector
   call    DriveIO_LoadSector
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
DriveIO_LoadLVMSector           EndP

; Keeps DS:SI for caller, saves at anytime w/o checks (!)
DriveIO_SaveLVMSector           Proc Near  Uses ax bx cx dx
   test    [CFG_IgnoreLVM], 1            ; We are supposed to ignore LVM, so
   jnz     DIOSLVMS_SevereError          ;  don't save at anytime (security!)
   mov     ax, wptr cs:[CurPartition_Location+0]
   mov     bx, wptr cs:[CurPartition_Location+2]
   mov     dx, wptr cs:[CurPartition_Location+4]
   mov     cx, wptr cs:[CurPartition_Location+6] ; Gets cur. partition location
   call    LVM_CheckSectorSignature
   jnc     DIOSLVMS_SevereError                  ; LVM Signature must be there
   call    DriveIO_LVMAdjustToInfoSector
   mov     si, offset LVMSector
   call    DriveIO_SaveSector
  DIOSLVMS_SevereError:
   ret
DriveIO_SaveLVMSector           EndP

; Memory-Block that holds information for LBA-access via INT 13h
DriveIO_DAP:               db       10h  ; Size of paket
                           db        0   ; Reserved
DriveIO_DAP_NumBlocks      dw        0   ; Number of blocks
DriveIO_DAP_Transfer       dd        0   ; Transfer Adress
DriveIO_DAP_Absolute       dd        0   ; Absolute Sector
                           dd        0   ; Second Part of QWORD

; Special error message instead of "LOAD ERROR" during partition scanning,
;  so users will notice that something is bad with their partition table(s)
DriveIO_GotLoadError            Proc Near
   test    cs:CurIO_Scanning, 1          ; Must be CS:, cause DS!=CS maybe here
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
   jmp     MBRLE_Halt
DriveIO_GotLoadError            EndP

Comment *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Routine: Loads a specified sector to DS:DI
 ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
 Calling : bx:ax - Absolute sector
           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
           ds:si - Destination-Adress
 Returns : none
 Preserve: all registers
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*
DriveIO_LoadSector              Proc Near  Uses ax bx ds si es di
   test     cs:[CurIO_UseExtension], 1
   jz       DIOLS_UseNormal
   ; Are we forced do use LBA via Setting?
   test     cs:[CFG_ForceLBAUsage], 1
   jnz      DIOLS_UseExtension
   ; Is the drive not a harddrive?
   cmp      dl, 80h
   jb       DIOLS_UseNormal
   ; Upper 8 bits of LBA-address set? -> Use LBA (maximum boundary is FB0400h)
   or       bh, bh
   jnz      DIOLS_UseExtension
   ; Compare Switch-Table value to bit 16-23 of LBA-address
   mov      di, dx
   and      di, 007Fh
   cmp      bptr cs:[LBASwitchTable+di], bl
   jbe      DIOLS_UseExtension
  DIOLS_UseNormal:
      mov      di, 3
     DIOLS_ErrorLoop:
         push     ds
         pop      es
         mov      bx, si                     ; ES:BX - Destination
         mov      ax, 0201h                  ; Function 2 - Load Sector
         int      13h
         jnc      DIOLS_Success
      dec      di
      jnz      DIOLS_ErrorLoop
      ; Sector load failed...
      jmp      DriveIO_GotLoadError

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
DriveIO_LoadSector              EndP

Comment *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Routine: Writes DS:SI to a specified sector
 ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
 Calling : bx:ax - Absolute sector
           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
           ds:si - Source-Adress
 Returns : none
 Preserve: all registers
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*
DriveIO_SaveSector              Proc Near  Uses ax bx cx ds si es di
   test     cs:[CurIO_UseExtension], 1
   jz       DIOSS_UseNormal
   ; Are we forced do use LBA via Setting?
   test     cs:[CFG_ForceLBAUsage], 1
   jnz      DIOSS_UseExtension
   ; Is the drive not a harddrive?
   cmp      dl, 80h
   jb       DIOSS_UseNormal
   ; Upper 8 bits of LBA-address set? -> Use LBA (maximum boundary is FB0400h)
   or       bh, bh
   jnz      DIOSS_UseExtension
   ; Compare Switch-Table value to bit 16-23 of LBA-address
   mov      di, dx
   and      di, 007Fh
   cmp      bptr cs:[LBASwitchTable+di], bl
   jbe      DIOSS_UseExtension
  DIOSS_UseNormal:
      mov      di, 3
     DIOSS_ErrorLoop:
         push     ds
         pop      es
         mov      bx, si                     ; ES:BX - Destination
         mov      ax, 0301h                  ; Function 3 - Write Sector
         int      13h
         jnc      DIOSS_Success
      dec      di
      jnz      DIOSS_ErrorLoop
      call     MBR_SaveError

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
