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



IFDEF ModuleNames
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
DriveIO_InitLBASwitchTable      Proc Near   Uses es di                           ; Rousseau: LBA !
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

         ; huge disk 127 sec/track on <1TB using DANI
;         mov     cl, 07Fh

         ;movzx   ax, cl
         mov   al,cl
         mov   ah,0

         mov     bl, dh         ; DH -> head count                               ; Rousseau: nope, it's max head number !
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
; Rousseau: Enhanced to handle sector-numbers 127 and 255 besides 63 for LVM-info sectors.
;           Ugly, need to cleanup.
DriveIO_LVMAdjustToInfoSector   Proc Near   Uses                                 ; Rousseau: LVM stuff !



;      pusha
;      call     AuxIO_TeletypeNL

      ; LBA
;      xchg     dx,bx
;      call     AuxIO_TeletypeHexDWord
;      call     AuxIO_TeletypeNL
;      xchg     bx,dx

      ; CYL
;      mov      al,ch
;      call     AuxIO_TeletypeHexByte
;      call     AuxIO_TeletypeNL

      ; HEAD
;      mov      al,dh
;      call     AuxIO_TeletypeHexByte
;      call     AuxIO_TeletypeNL

      ; SEC
;      mov      al,cl
;      call     AuxIO_TeletypeHexByte
;      call     AuxIO_TeletypeNL

      ; DRIVE
;      mov      al,dl
;      call     AuxIO_TeletypeHexByte
;      call     AuxIO_TeletypeNL

;      popa


      ;local ts:word
      ;local ts2:word

      pusha

         ; Dump drive
         mov      si,offset drive
         call     AuxIO_Print
         xchg     al,dl
         call     AuxIO_TeletypeHexByte
         call     AuxIO_TeletypeNL
         xchg     dl,al

         ; Dump SPT
         mov      si,offset spt_used
         call     AuxIO_Print
         push     dx
         push     bx
            xor      dh,dh
            and      dl,01111111b
            shl      dx,1
            shl      dx,1
            mov      bx, offset TrueSecs
            add      bx,dx
            mov      ax,word ptr [bx]

            ;mov      [ts],ax

            call     AuxIO_TeletypeHexWord
            call     AuxIO_TeletypeNL
         pop      bx
         pop      dx

         pusha
            push     dx
               ; Location of extended position
               mov      dx,word ptr [ExtendedAbsPos+02]
               mov      ax,word ptr [ExtendedAbsPos+00]
               call     AuxIO_TeletypeHexDWord
               call     AuxIO_TeletypeNL
            pop      dx

            xor      dh,dh
            and      dl,01111111b
            shl      dx,1
            shl      dx,1
            mov      bx, offset TrueSecs
            add      bx,dx

            mov      ax, word ptr[bx]
            call     AuxIO_TeletypeHexWord
            call     AuxIO_TeletypeNL
            mov      al,[ExtendedAbsPosSet]           ; if true -> 1st sector of extpart (EBR), not logpart(BPB)
            call     AuxIO_TeletypeHexByte
            call     AuxIO_TeletypeNL
      ;      mov      si,offset PartitionSector
      ;      call     AuxIO_DumpSector
         popa

         ; LBA
         mov      si,offset before_lvm_adjust
         call     AuxIO_Print

         xchg     dx,bx
         call     AuxIO_TeletypeHexDWord
         call     AuxIO_TeletypeNL
         xchg     bx,dx
      popa


      ;or       bx,ax
      test     [ExtendedAbsPosSet],1
      jz       pri




      pusha
         mov      si,offset before_lvm_adjust_log
         call     AuxIO_Print
         ; LBA
         xchg     dx,bx
         call     AuxIO_TeletypeHexDWord
         call     AuxIO_TeletypeNL
         xchg     bx,dx
      popa


      push     dx
      push     bx
         xor      dh,dh
         and      dl,01111111b
         shl      dx,1
         shl      dx,1
         mov      bx,offset TrueSecs
         add      bx,dx
         mov      dx,[bx]
         dec      dx
         add      ax,dx
      pop      bx
      pop      dx
      adc      bx,0


      pusha
         mov      si,offset after_lvm_adjust_log
         call     AuxIO_Print
         ; LBA
         xchg     dx,bx
         call     AuxIO_TeletypeHexDWord
         call     AuxIO_TeletypeNL
         xchg     bx,dx
      popa

      jmp      done




pri:


      push     ax
      push     cx
         xor      ch, ch                           ; Zero out upper-byte

         push     dx
            xor      dh,dh
            and      dl,01111111b
            shl      dx,1
            shl      dx,1
            push     bx
               mov      bx,offset TrueSecs
               add      bx,dx
               mov      ax,[bx]
               ;mov      [ts2],ax
            pop      bx
         pop      dx



         ;mov      al, 63
         ;call VideoIO_PrintByteDynamicNumber
         ;self: jmp self



         ; DEZE WERKT SOMS NIET GOED
         ; ROMMELT MET CYLINDERS
         ; ALLEEN TOEPASSEN ALS INT13X NIET ACTIEF !

         and      cl, al                           ; Isolate lower bits, because upper
         mov      ah, 0
         mov      si, ax                           ;  ones may be used for cylinder
         sub      si, cx

      pop      cx
      pop      ax

      or       cl, al                           ; Set sector to last sector

      add      ax, si                           ; Adjust lower LBA
      adc      bx, 0                            ; Adjust LBA Sector (BX:AX)



      ;push     ax
      ;call     AuxIO_TeletypeHexWord
      ;call     AuxIO_TeletypeNL
      ;mov      ax,[ts]
      ;call     AuxIO_TeletypeHexWord
      ;call     AuxIO_TeletypeNL
      ;mov      ax,[ts2]
      ;call     AuxIO_TeletypeHexWord
      ;call     AuxIO_TeletypeNL
      ;pop      ax

      ;and      ax,[ts]

      jmp done



done:



      pusha
         mov      si,offset after_lvm_adjust
         call     AuxIO_Print
         ; LBA
         xchg     dx,bx
         call     AuxIO_TeletypeHexDWord
         call     AuxIO_TeletypeNL
         xchg     bx,dx
      popa



;      pusha
;      call     AuxIO_TeletypeNL

      ; CYL
;      mov      al,ch
;      call     AuxIO_TeletypeHexByte
;      call     AuxIO_TeletypeNL

      ; HEAD
;      mov      al,dh
;      call     AuxIO_TeletypeHexByte
;      call     AuxIO_TeletypeNL

      ; SEC
;      mov      al,cl
;      call     AuxIO_TeletypeHexByte
;      call     AuxIO_TeletypeNL

      ; DRIVE
;      mov      al,dl
;      call     AuxIO_TeletypeHexByte
;      call     AuxIO_TeletypeNL

;      popa



      ret
DriveIO_LVMAdjustToInfoSector   EndP

drive:                  db 'drive                    : ',0
before_lvm_adjust:      db 'before lvm adjust        : ',0
after_lvm_adjust:       db 'after lvm adjust         : ',0
before_lvm_adjust_log:  db 'before lvm logical adjust: ',0
after_lvm_adjust_log:   db 'after lvm logical adjust : ',0
spt_used:               db 'spt used                 : ',0



; #########################################################################
; Routine: Loads partition to ExecBase and checks for validity
; #########################################################################
; Calling : bx:ax - Absolute sector
;           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
; Returns : Carry Set if invalid partition encountered
; Preserve: all registers
; #########################################################################
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

IFDEF AuxDebug
   ; show current partition location
   pushf
   pusha
      call     AuxIO_TeletypeNL
      mov      si,offset db_curpartloc
      call     AuxIO_Print
      mov      dx,word ptr [CurPartition_Location+02]
      mov      ax,word ptr [CurPartition_Location+00]
      call     AuxIO_TeletypeHexDWord
      call     AuxIO_TeletypeNL
      mov      si,offset PartitionSector
      call     AuxIO_DumpSector
      call     AuxIO_TeletypeNL
   popa
   popf
ENDIF

   ret
  DIOLP_Failed:
   jmp     DriveIO_GotLoadError
DriveIO_LoadPartition           EndP

; #########################################################################
; Routine: Writes a partition from ExecBase to its original sector
; #########################################################################
; Calling : none
; Returns : none
; Preserve: all registers
; #########################################################################
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
   call    DriveIO_LoadSector                                                    ; Uses INT13X if needed
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

   call    DriveIO_LVMAdjustToInfoSector                                         ; Rousseau: LVM stuff !

   mov     si, offset LVMSector
   call    DriveIO_LoadSector

IFDEF AuxDebug
   ; show current partition location
   pushf
   pusha
      call     AuxIO_TeletypeNL
      mov      si,offset db_curlvmsec
      call     AuxIO_Print
      mov      dx,bx
      call     AuxIO_TeletypeHexDWord
      call     AuxIO_TeletypeNL
      mov      si,offset LVMSector
      call     AuxIO_DumpSector
      call     AuxIO_TeletypeNL
   popa
   popf
ENDIF

   ; Rousseau
   ;pushf
   ;pusha
   ;mov   si, offset MyText4
   ;call  VideoIO_Print
   ;mov   si, offset LVMSector
   ;mov   al, [si+LocLVM_VolumeLetter2]
   ;call  VideoIO_PrintByteDynamicNumber
   ;mov   al, [si+LocLVM_Startable]
   ;call  VideoIO_PrintByteDynamicNumber
   ;mov   al, [si+LocLVM_OnBootMenu]
   ;call  VideoIO_PrintByteDynamicNumber
   ;;self: jmp self
   ;popa
   ;popf

   call    LVM_CheckSectorSignature                                              ; Rousseau: LVM stuff !
   jnc     DIOLLVMS_NoLVMSector
   call    LVM_CheckSectorCRC                                                    ; Rousseau: LVM stuff !
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

; #########################################################################
; Routine: Loads a specified sector to DS:DI
; #########################################################################
; Calling : bx:ax - Absolute sector
;           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
;           ds:si - Destination-Adress
; Returns : none
; Preserve: all registers
; #########################################################################
DriveIO_LoadSector              Proc Near  Uses ax bx ds si es di                ; Rousseau: Disk IO
   test     cs:[CurIO_UseExtension], 1
   jz       DIOLS_UseNormal
   ; Are we forced do use LBA via Setting?
   test     cs:[CFG_ForceLBAUsage], 1                                            ; Rousseau: LBA
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
         mov      ax, 0201h                  ; Function 2 - Load Sector          ; Rousseau: Disk IO -- legacy BIOS call
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
      mov     ah, 42h                        ; Extended Read                     ; Rousseau: Disk IO -- extended BIOS call
      int     13h
   pop     cx
   jnc     DIOLS_Success
   ; Sector load failed...
   jmp     DriveIO_GotLoadError

  DIOLS_Success:
   ret
DriveIO_LoadSector              EndP

; #########################################################################
; Routine: Writes DS:SI to a specified sector
; #########################################################################
; Calling : bx:ax - Absolute sector
;           cx:dx - Cylinder/Sector, Side/Drive (hi/lo-byte)
;           ds:si - Source-Adress
; Returns : none
; Preserve: all registers
; #########################################################################
DriveIO_SaveSector              Proc Near  Uses ax bx cx ds si es di
   test     cs:[CurIO_UseExtension], 1
   jz       DIOSS_UseNormal
   ; Are we forced do use LBA via Setting?
   test     cs:[CFG_ForceLBAUsage], 1                                            ; Rousseau: LBA
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


; See if a LVM-sector is valid.
; In  : si, pointer to sector
; Out : ZF=true, not valid; ZF=false, valid
DriveIO_LVMSectorValid           Proc  Near
      pusha

      call     LVM_CheckSectorSignature
      mov      al,0
      rcl      al,1                          ; Move CY to AL.0
      call     AuxIO_TeletypeHexByte
      call     AuxIO_TeletypeNL
      or       al,al                         ; Zero if not a valid sector
      jz       DriveIO_LVMSectorValid_End    ; Not a valid sector

      call     LVM_CheckSectorCRC
      stc
      mov      al,0
      rcl      al,1                          ; Move CY to AL.0
      call     AuxIO_TeletypeHexByte
      call     AuxIO_TeletypeNL
      or       al,al                         ; Zero if not a valid sector

   DriveIO_LVMSectorValid_End:

      popa
      ret
DriveIO_LVMSectorValid           EndP

; ------------------------------------------------------
; Rousseau: # Load the master LVM-sector is one exists #
; ------------------------------------------------------
; Load the master LVM-sector to get the number of sectors per track as eCS views the drive.
; If no master LVM-sector is found it is assumed eCS is not installed.
; The master LVM-sector can be located at three different places according to drive size
; and partitioning scheme and driver used.
; When DANIS506.ADD is used, the eCS extended geometry will be 255/127 for drives >502GiB but <1TiB.
; Then the location will be sector 127 which is LBA 126 (7Eh).
; IBM1S506.ADD will always use 255/255 for the extended eCS geometry.
; DANIS506.ADD will use 255/255 for drives >1TiB.
; Then the location of the master LVM-sector will be 255 which is LBA 254 (FEh).
; When eCS is installed on a huge drive that alread had a system on it, eCS will be confined to the
; lower 502GiB of the drive. In this case the normal geometry from Int13X will be used.
; This is also the case when no valid master LVM-sector can be found.
;
; Return ZF=true if not found, ZF=false when valid master LVM-sector found.
DriveIO_LoadMasterLVMSector      Proc  Near
      pusha

      mov      si,offset db_lmlvm
      ;call     AuxIO_Print

      mov      al,dl
      ;call     AuxIO_TeletypeHexByte
      ;call     AuxIO_TeletypeNL


      ; Loop over the sector-translation table,
      ; process the first three values from high (255) to low (bios spt, most likely 63)
      mov      cx,3
DriveIO_LoadMasterLVMSector_NextTry:
      mov      bx,offset secs_per_track_table         ; sector translation table that corresponds with IsHugeDrive
      mov      si, offset LVMSector                   ; space to load the master LVM-sector
      mov      [DriveIO_DAP_NumBlocks],1              ; number of sectors to read
      mov      wptr [DriveIO_DAP_Transfer+0],si       ; low part of transfer address
      mov      ax, ds
      mov      wptr [DriveIO_DAP_Transfer+2],ax       ; high part of transfer address
      mov      ax,cx                                  ; use the counter...
      dec      ax                                     ; as an index into the table
      xlatb                                           ; translate to number of sectors
      dec      al                                     ; LBA is zero-based, so adjust

IFDEF AuxDebug
      ; Dump the value
      ;call     AuxIO_TeletypeHexByte
      ;call     AuxIO_TeletypeNL
ENDIF

      mov      wptr [DriveIO_DAP_Absolute+0],ax       ; LBA low      ;
      mov      wptr [DriveIO_DAP_Absolute+2],00h      ; LBA high
      mov      si, offset DriveIO_DAP                 ; address request packet
      mov      ah, 42h
      int      13h                                    ; do the i/o
      jc       DriveIO_LoadMasterLVMSector_NotFound   ; oops, there was an error

IFDEF AuxDebug
      ; Dump title
      mov      si,offset db_masterlvm
      ;call     AuxIO_Print

      ; Dum sector
      mov      si, offset LVMSector
      ;call     AuxIO_DumpSector
      ;call     AuxIO_TeletypeNL
ENDIF
      ; See is this is a valid LVM-sector
      call     DriveIO_LVMSectorValid

IFDEF AuxDebug
      pushf
      ;call     AuxIO_TeletypeNL
      popf
ENDIF
      ; Yep, we found the master LVM-sector
      jnz      DriveIO_LoadMasterLVMSector_Found
      ; Try next location
      loop     DriveIO_LoadMasterLVMSector_NextTry

   ; No master LVM-sector found, set ZF=true
   DriveIO_LoadMasterLVMSector_NotFound:
      xor      ax,ax

   ; Jump here with ZF=false if found
   DriveIO_LoadMasterLVMSector_Found:

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
; Even with a small partition, like <502GiB, OS/2 will use extended geometry on an
; empty huge disk.
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
;   This is the current OS/2 limit using this geometry because OS/2 can currently
;   not address more than 65536 cylinders.
;   DANI will address space above with 255/127 extended geometry up until the DANI 1TiB boundary (code 2)

; (code 0)
; Everything below 65536*255*63 will be addressed using standard geometry.


;
; This function will return the following values:
;

; 5 = This drive is above the 2^32 LBA32 (2TB) boundary and has more than 4294967296 sectors.
;     LBA48 addressing is needed to access the complete capacity of the drive.
;     OS/2 is currently unable to do so.

; 4 = This drive is above the 65536*255*255 (4261478400) boundary but below 2^32.
;     This is an OS/2 boundary and OS/2 is not able to access the drive above this boundary.

; 3 = This drive is above the 2^31 (1TB) boundary and has more than 2147483648 sectors.
;     OS/2 is able to access the drive using it's extended geometry.
;     Both DANIS506 and IBM1S506 will use the 255/255 scheme.

; 2 = This drive is above the 65536*255*127 (2122383360) boundary but below 2^31.
;     OS/2 is able to access the drive using it's extended geometry.
;     Both DANIS506 and IBM1S506 will use the 255/255 scheme.

; 1 = This drive is above the 65536*255*63 (1052835840) boundary but below 65536*255*127.
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
      ; Don't overwrite the word of the buffersize at index 0 !
      ; Old Phoenix BIOSses require word (flags) at 02 to be zero,
      ; so we clear the whole buffer to be sure.
      mov     cx, i13xbuf_size
      mov     di, offset i13xbuf
      mov     [di],cx
      inc     di
      inc     di
      xor     ah,ah
      cld
      rep stosb

      ; Get the drive parameters
      mov     ah, 48h                                 ; Get Drive Parameters (extended version)
      ;mov     dl, 80h                                ; Drive number
      mov     si, offset i13xbuf                      ; Buffer for result-info
      push    dx
      int     13h                                     ; Call the BIOS-function
      pop     dx

      ; Do some error-checking
      or      ah,ah                                   ; AH is zero if no error (ZF=1 if no error)
      mov     ax,0                                    ; Setup code for non-huge drive (does not influence ZF)
      jz      DriveIO_GatherDiskInfo_ok               ; Return if error (AL<>0 thus ZF=0) but CY not set, assuming non-huge drive
      jnc     DriveIO_GatherDiskInfo_ok               ; Return if error (CY=1), assuming non-huge drive
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
      mov     ax,5                                    ; Drive code (5)
      mov     bx, [si+14h]                            ; Low word of high dword of sector-count
      or      bx, [si+16h]                            ; High word of high dword of sector-count
      jnz     DriveIO_GatherDiskInfo_ret              ; If non-zero we have a drive with >2^32 sectors and thus LBA48 addressing

      ; Drive is larger than max OS/2 capacity
      dec     ax                                      ; Drive code (4)
      mov     bx, [si+12h]                            ; High word of low dword of sector-count
      cmp     bx, 0fe01h                              ; Boundary
      jae     DriveIO_GatherDiskInfo_ret              ; If above or equal to boundary,
                                                      ; we have a drive larger than to 65536*255*255 = FE010000 sectors

      ; Drive can be completely utilized by OS/2
      dec     ax                                      ; Drive code (3)
      cmp     bx, 8000h                               ; Boundary
      jae     DriveIO_GatherDiskInfo_ret              ; If above or equal to boundary,
                                                      ; we have a drive larger than 2^31 sectors but smaller than 65536*255*255

      ; This is the small area between DANI 1TiB and LBA 1TiB
      dec     ax                                      ; Drive code (2)
      cmp     bx, 7e81h                               ; Boundary
      jae     DriveIO_GatherDiskInfo_ret              ; If above or equal to boundary,
                                                      ; we have a drive larger than 65536*255*127 but <65536*255*255
                                                      ; DANIS506.ADD will use 255/255 extended geometry

      ; DANI will use 255/127 in this area, this could impact the location of LVM-sectors ! (last sec on track)
      dec     ax                                      ; Drive code (1)
      cmp     bx, 3ec1h                               ; Boundary
      jae     DriveIO_GatherDiskInfo_ret              ; If above or equal to boundary,
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

      mov      [CurIO_UseExtension],1

      popf
      ret
DriveIO_GatherDiskInfo  EndP



; Values for sectors per track table corresponding to DriveIO_IsHugeDrive return value.
secs_per_track_table:   db    63,127,255,255,255,255

db_lmlvm:   db 'Load Master LVM -- disk: ',0
