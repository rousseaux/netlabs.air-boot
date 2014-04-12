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
;                                AiR-BOOT / EXTENDED PARTITION - M$ HACK-IN
;---------------------------------------------------------------------------

; AiR-BOOT is compatible to the pseudo standard that's is used by an OS on a
;  32-bit processor, being actually a 16-bit extension that is outperformed
;  by any 8-bit software running on a 4-bit microprocessor, written by a 2-bit
;  company that can't stand 1-bit of competition.

; Here is code to change Extended Partition to Type 05h or 0Fh depending
;  on the partition's P-flag including the overall M$hack-Enable Flag.

IFDEF ModuleNames
DB 'BILLSUXX',0
ENDIF

MSHACK_ProcessPartTables        Proc Near  Uses ax dx di
   ; Check Overall M$-Hack Enable
   test    byte ptr [CFG_ExtPartitionMShack], 1
   jz      MSHPPT_NoMShack

   ; Now check Boot-Entry's flags...
   mov     ax, 050Fh
   test    bptr [si+LocIPT_Flags], Flags_ExtPartMShack
   jz      MSHPPT_ChangeToStandard
   mov     ax, 0F05h
  MSHPPT_ChangeToStandard:

   ; Now process every Primary Partition Table (PPT) for Extended Partition
   ;  Search for ID *AL* and replace with ID *AH*
   mov     dl, 80h
   mov     dh, [TotalHarddiscs]
   or      dh, dh
   jz      MSHPPT_NoMShack
  MSHPPT_HarddriveLoop:
      push    ax
      push    bx
      push    cx
      push    dx
         xor     ax, ax
         xor     bx, bx     ; Location Absolute Sector 0
         mov     cx, 0001h
         xor     dh, dh     ; Location Cylinder 0, Head 0, Sector 1 MBR/PPT
         call    DriveIO_LoadPartition
      pop     dx
      pop     cx
      pop     bx
      pop     ax
      jc      MSHPPT_Failure

      ; Search for ID in AL and exchange with ID in AH
      mov     di, offset PartitionSector+446 ; ES:DI - 1st partition entry
     MSHPPT_ScanLoop:
         cmp     al, bptr es:[di+4]
         je      MSHPPT_GotHit
         add     di, LocBRPT_LenOfEntry  ; 16 Bytes per Partition-Entry
      cmp     di, 500+offset PartitionSector
      jb      MSHPPT_ScanLoop
      jmp     MSHPPT_Failure

     MSHPPT_GotHit:
      mov     bptr es:[di+4], ah
      IFDEF ReleaseCode
         call    DriveIO_SavePartition
      ENDIF
     MSHPPT_Failure:
   inc     dl
   dec     dh
   jnz     MSHPPT_HarddriveLoop

  MSHPPT_NoMShack:
   ret
MSHACK_ProcessPartTables        EndP
