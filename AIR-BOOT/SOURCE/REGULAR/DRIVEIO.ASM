
; Disclaimer:
;=============
; The sourcecode is released via www.netlabs.org CVS *ONLY*.
;  You MUST NOT upload it to other servers nor republish it in any way.
;  The sourcecode is still COPYRIGHTED and NOT YET RELEASED UNDER GPL.
;  It's (c) Copyright 1998-2002 by Martin Kiewitz.
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
;                                                      AiR-BOOT / DRIVE I/O
;---------------------------------------------------------------------------

; Note: Some routines set DS/ES to CS, even if its not needed.
;        This was done for SECURITY. So DO NOT remove it. Its there to make
;        sure the correct data is loaded/written to/from harddrive.
;
;  IF YOU MODIFY ANYTHING IN HERE, YOU CAN EASILY BREAK YOUR HARDDRIVE!

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
;  The access is done via BIOS INT 13h or BIOS/Extensions.
;  Access will be done prefered by INT 13h, because it's (I wonder!) much
;   faster, than the LBA-method. I don't know, why LBA is so slow. Perhaps BIOS.
;
;  Internal access (to AiR-BOOT) is always done via INT 13h.

Comment *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Routine: Loads partition to ExecBase and checks for validity
 ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
 Calling : bx:ax - Absolute sector
           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
 Returns : Carry Set if invalid partition encountered
 Preserve: all registers
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*
DriveIO_LoadPartition           Proc Near  Uses ds si
   mov     wptr cs:[CurPartition_Location+0], ax
   mov     wptr cs:[CurPartition_Location+2], bx
   mov     wptr cs:[CurPartition_Location+4], dx
   mov     wptr cs:[CurPartition_Location+6], cx ; Saves the location
   push    ExecBaseSeg
   pop     ds
   mov     si, ExecBasePtr           ; DS:SI - ExecBase
   call    DriveIO_LoadSector
   clc
   cmp     word ptr ds:[si+LocBR_Magic], 0AA55h
   je      DIOLP_Success
   stc
  DIOLP_Success:
   ret
DriveIO_LoadPartition           EndP

Comment *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Routine: Writes a partition from ExecBase to its original sector
 ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
 Calling : none
 Returns : none
 Preserve: all registers
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*
DriveIO_SavePartition           Proc Near  Uses ax bx cx dx ds si
   mov     ax, wptr cs:[CurPartition_Location+0]
   mov     bx, wptr cs:[CurPartition_Location+2]
   mov     dx, wptr cs:[CurPartition_Location+4]
   mov     cx, wptr cs:[CurPartition_Location+6] ; Gets prev. saved location
   push    ExecBaseSeg
   pop     ds
   mov     si, ExecBasePtr               ; DS:SI - ExecBase
   call    DriveIO_SaveSector
   ret
DriveIO_SavePartition           EndP

; L„sst DS:SI fr Aufrufer
DriveIO_LoadTmpSector           Proc Near  Uses
   push    cs
   pop     ds
   mov     si, offset TmpSector
   call    DriveIO_LoadSector
   ret
DriveIO_LoadTmpSector           EndP

; L„sst DS:SI fr Aufrufer
DriveIO_SaveTmpSector           Proc Near  Uses
   push    cs
   pop     ds
   mov     si, offset TmpSector
   call    DriveIO_SaveSector
   ret
DriveIO_SaveTmpSector           EndP

; Memory-Block that holds information for LBA-access via INT 13h
DriveIO_DAP:               db       10h  ; Size of paket
                           db        0   ; Reserved
DriveIO_DAP_NumBlocks      dw        0   ; Number of blocks
DriveIO_DAP_Transfer       dd        0   ; Transfer Adress
DriveIO_DAP_Absolute       dd        0   ; Absolute Sector
                           dd        0   ; Second Part of QWORD

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
   ; LBA-boundary >16450560 (FB0400h)
   cmp     bx, 00FBh
   jb      DIOLS_UseNormal
   test    cs:[CurIO_UseExtension], 1
   jnz     DIOLS_UseExtension
  DIOLS_UseNormal:
      mov     di, 3
     DIOLS_ErrorLoop:
         push    ds
         pop     es
         mov     bx, si                      ; ES:BX - Destination
         mov     ax, 0201h                   ; Function 2 - Load Sector
         int     13h
         jnc     DIOLS_Success
      dec     di
      jnz     DIOLS_ErrorLoop
      call    MBR_LoadError

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
      mov     ah, 42h                         ; Extended Read
      int     13h
   pop     cx
   jnc     DIOLS_Success
   call    MBR_LoadError

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
   ; LBA-boundary >16450560 (FB0400h)
   cmp     bx, 00FBh
   jb      DIOSS_UseNormal
   test    cs:[CurIO_UseExtension], 1
   jnz     DIOSS_UseExtension
  DIOSS_UseNormal:
      mov     di, 3
     DIOSS_ErrorLoop:
         push    ds
         pop     es
         mov     bx, si                      ; ES:BX - Destination
         mov     ax, 0301h                   ; Function 3 - Write Sector
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
