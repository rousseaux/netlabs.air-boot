
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
;                                AiR-BOOT / EXTENDED PARTITION - M$ HACK-IN
;---------------------------------------------------------------------------

; At least is AiR-BOOT compatible to the pseudo standard that's is used by an
;  OS on a 32-bit processor, being actually a 16-bit extension that is
;  outperformed by any 8-bit software running on a 4-bit microprocessor,
;  written by a 2-bit company that can't stand 1-bit of competition.

; Here is code to change Extended Partition to Type 05h or 0Fh depending
;  on the partition's P-flag including the overall M$hack-Enable Flag.
MSHACK_ProcessPartTables        Proc Near  Uses ax dx es di
   ; Check Overall M$-Hack Enable
   test    [CFG_ExtPartitionMShack], 1
   jz      MSHPPT_NoMShack

   ; Now check Boot-Entry's flags...
   mov     ax, 050Fh
   test    bptr ds:[si+LocIPT_Flags], Flags_ExtPartMShack
   jz      MSHPPT_ChangeToStandard
   mov     ax, 0F05h
  MSHPPT_ChangeToStandard:

   ; Now process every Primary Partition Table (PPT) for Extended Partition
   ;  Search for ID *AL* and replace with ID *AH*
   mov     dl, 80h
   mov     dh, [TotalHarddiscs]
   or      dh, dh
   jz      MSHPPT_NoMShack
   push    ExecBaseSeg
   pop     es
  MSHPPT_HarddriveLoop:
      push    ax bx cx dx
         xor     ax, ax
         xor     bx, bx     ; Location Absolute Sector 0
         mov     cx, 0001h
         xor     dh, dh     ; Location Cylinder 0, Head 0, Sector 1 MBR/PPT
         call    DriveIO_LoadPartition
      pop     dx cx bx ax
      jc      MSHPPT_Failure

      ; Search for ID in AL and exchange with ID in AH
      mov     di, ExecBasePtr+446        ; ES:DI - First Partition Entry
     MSHPPT_ScanLoop:
         cmp     al, bptr es:[di+4]
         je      MSHPPT_GotHit
         add     di, LocBRPT_LenOfEntry  ; 16 Bytes per Partition-Entry
      cmp     di, 500+ExecBasePtr
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
