
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
;                                                  AiR-BOOT / LINUX SUPPORT
;---------------------------------------------------------------------------

; Here is the startup-code for Linux-Kernels. I'm sure this won't work on
; all of them, but on the latest.

; Note: This code will ONLY WORK on computers with INT 13h Extension.
;       I did not want to code silly cylinder stuff here and if you don't
;       have INT 13h Extensions, you will not need this. LINUXIMG won't work
;       without them.
;
; And another note: *Fuck* Linux usenet-users. Really. I mean *fuck them*.
;  I asked in an OS/2 newsgroup for testers -> Got 8 volunteers within some
;  days. I asked in 2 Linux newsgroups. What did happen? Some idiots discussed
;  the whole shiat with me, knew nothing about INT13h CHS/LBA mode, BIOS,
;  boot-managers in general, assembly coding and other stuff and wanted to tell
;  me that 95k GRUB is well-coded and its good to have it placed all over your
;  harddrive and that file-support and all those lousy features would waste
;  sooo much space. ROFLMAO.
;
; I could implement some more file-systems into AiR-BOOT, but instead I did
;  some nice menus, setup, text, cyrillic support, demo-coder effects, easy
;  handling, help, auto-detection and plenty of other stuff INTO AROUND 25k.
; 
; Oh, why is this code here? Because of 2 friends of mine. Otherwise I wouldnt
;  have done it as well as fat16.asm.

Linux_TranslateBase     db '/dev/hd'
Linux_KernelDirectory   db 'KERNELS    '

; Translates partition-number to Linux-device name (e.g. /dev/hda3)
;        In: DL - partition number, ES:DI - destination 9-byte buffer
;       Out: (buffer filled)
; Destroyed: None
LINUX_TranslateToDEV            Proc Near  Uses eax ebx cx dx ds si
   ; Damn Linux. Our logic is as follows: first get the drive letter.
   ;             that's easy. Now search our partition-table for new
   ;             extended partitions and fix them up. Stupid logic.
   push    cs
   pop     ds                 ; CS == DS
   mov     si, offset Linux_TranslateBase
   mov     cx, 7
   rep     movsb                         ; First write base-name (/dev/hd)...
   ; First get our partition-table
   call    PART_GetPartitionPointer      ; Partition (DL) -> CS:SI
   mov     dl, ds:[si+LocIPT_Drive]
   mov     al, dl
   sub     al, 1Fh                       ; Generate letter from drive (80h -> 61h)
   stosb                                 ; write letter

   ; Now get the linux local partition number
   ; 1. Search for partition, where TranslateDrive (DL) got used first
   mov     cx, si          ; CX - Searched partition offset
   mov     si, offset PartitionTable ; begin here
  LTTD_SearchDriveLoop:
   cmp     ds:[si+LocIPT_Drive], dl
   je      LTTD_SearchDrive_Found
   add     si, LocIPT_LenOfIPT
   jmp     LTTD_SearchDriveLoop
  LTTD_SearchDrive_Found:
   ; Now count all partitions to hit. After root partition set counter to
   ; 4 and count further.
   xor     dh, dh          ; Linux Partition Counter (Base 0)
  LTTD_SearchPart_Loop:
      inc     dh           ; Increase Linux Local Partition Number
      mov     ax, wptr ds:[si+LocIPT_AbsolutePartTable+2]
      shr     eax, 16
      mov     ax, wptr ds:[si+LocIPT_AbsolutePartTable+0] ; -> EAX
      cmp     dh, 4                      ; over root partition yet ?
      ja      LTTD_ContinueLoop ; yes, continue loop
      cmp     eax, 0                     ; not in root partition anymore?
      je      LTTD_ContinueLoop
      mov     dh, 5                      ; nope, so adjust counter
     LTTD_ContinueLoop:
   cmp     si, cx
   je      LTTD_SearchPart_Found
   add     si, LocIPT_LenOfIPT           ; Next Partition
   jmp     LTTD_SearchPart_Loop

  LTTD_SearchPart_Found:
   or      eax, eax
   jnz     LTTD_SearchPart_NotRootPartition
   ; Bullshit, it's in the MBR, so we have to look for the
   ; partition number directly (because EXTEND, EXT2: EXT2 would be
   ; partition 1, in fact it would be partition 2)
   ; All we do here is to load the MBR to memory (suck) and look in it
   ; manually. Pervertly this could be crazy, when user
   ; is in setup and changing 'Linux Root'.
   mov     ax, wptr ds:[si+LocIPT_AbsoluteBegin+2]
   shr     eax, 16
   mov     ax, wptr ds:[si+LocIPT_AbsoluteBegin+0] ; -> EAX
   push    eax
      xor     ax, ax
      xor     bx, bx
      mov     cx,  1
      xor     dh, dh
      mov     si, offset TmpSector
      call    DriveIO_LoadSector         ; Load fucking MBR
   pop     eax
   xor     dh, dh                        ; Reset again to zero
   add     si, 446
  LTTD_SearchRoot_Loop:
      cmp     bptr ds:[si+4], 0
      je      LTTD_SearchRoot_NoPart     ; if partition...
      inc     dh                                   ;  add one
     LTTD_SearchRoot_NoPart:
      mov     bx, wptr ds:[si+10]
      shr     ebx, 16
      mov     bx, wptr ds:[si+08]                  ; -> EBX (Start Sector)
      add     si, 16
      cmp     eax, ebx
      jne     LTTD_SearchRoot_Loop

  LTTD_SearchPart_NotRootPartition:
   mov     al, dh
   ; Now convert that crap (AL) to ascii and write it
   cmp     al, 10
   jb      LTTD_Smaller10
   xor     ah, ah
   mov     dl, 10
   div     dl
   add     al, 30h         ; Generate number from value 00h -> 30h)
   stosb
   mov     al, ah
  LTTD_Smaller10:
   add     al, 30h         ; Generate number from value
   stosb
   ret
LINUX_TranslateToDEV            EndP

LINUX_InitFAT16access           Proc Near  Uses es
   mov     dl, ds:[CFG_LinuxKrnlPartition]
   call    PART_GetPartitionPointer      ; Partition DL -> SI
   call    FAT16_InitAccess

   call    FAT16_ReadRoot

   mov     cx, FAT16_NumOfRootEntries
   mov     si, offset Linux_KernelDirectory
   call    FAT16_SearchEntry            ; Fills up DX as Cluster-No
   or      dx, dx
   jz      LIFAT16A_NoDirectory

      mov    ax, 9000h
      mov    es, ax
      xor    di, di                      ; Read Cluster DX to 9000:0 (ES:DI)
      call   FAT16_ReadCluster
      mov    ax, cs
      mov    es, ax                      ; DS == ES == CS
      call   FAT16_ProcessKrnlDirectory

  LIFAT16A_NoDirectory:
   ret
LINUX_InitFAT16access           EndP

; Initialize FAT-16 access on specified partition (required for following xs)
;        In: DS:SI - 11-Byte Kernel Name to search
;       Out: DL    - FFh - if not found, otherwise the entry no is replied
; Destroyed: None
LINUX_SearchKernelName          Proc Near  Uses cx di
   mov     dl, 0FFh                      ; Nothing found is default...
   mov     cl, LINUX_KernelNo
   or      cl, cl
   jz      LSKN_NotFound
   mov     di, offset LINUX_KernelEntries
   add     di, LocIPT_Name
  LSKN_SearchLoop:
      push    cx si di
         mov     cx, 11
         repe    cmpsb                   ; Compare total 11-bytes
      pop     di si cx
      je      LSKN_Found
      add     di, LocIPT_LenOfIPT
   dec     cl
   jnz     LSKN_SearchLoop
   jmp     LSKN_NotFound

  LSKN_Found:
   mov     si, di
   sub     si, LocIPT_Name               ; Back to Base-Pointer
   call    PART_GetPartitionNumber       ; Get Number of Entry at [SI]
  LSKN_NotFound:
   ret
LINUX_SearchKernelName          EndP

Linux_FuzzyString       db 'Linux Boot - Alpha', 13, 10, 0
Linux_GotBadKernel      db ' - Bad Kernel/Bad FAT-16 partition', 0
Linux_INT15error        db ' - INT 15 error', 0
Linux_RootDefine        db 'root='

LINUX_LoadKernel                Proc Near  Uses ; Direct Jump, No Preserves
   ; TranslateToDev needs UNFILTERED Partition Pointers...
   call    PART_CalculateStraightPartPointers
   push    si
      mov     si, offset Linux_FuzzyString
      call    MBR_Teletype
   pop     si
   ; DX - Starting-Cluster of Linux Kernel File
   mov     dx, ds:[si+LocIPT_LocationBegin]
   ; from now on, we don't need si anymore
   
   ; Linux has 1 'BR' (which is crap) and some setup sectors
   ; we load them at 9000:0, what a luck, we are at 8000:0 :-))
   push    ds es
      mov     ax, 9000h
      mov     es, ax
      xor     di, di
      call    FAT16_ReadCluster          ; Load First Cluster (DX) to 9000:0
      mov     cl, bptr es:[01F1h]        ; Setup sectors to load
      inc     cl                         ; Total sectors to load to 9000:0
      jmp     LLL_CheckLeft

     LLL_LoadSetupCodeLoop:
      call    FAT16_ReadCluster
     LLL_CheckLeft:
      sub     cl, FAT16_SecsPerCluster
      jz      LLL_GotAllClusterDone
      jc      LLL_GotAllClusterNotEmpty
      jmp     LLL_LoadSetupCodeLoop

     LLL_GotAllClusterDone:
      xor     cx, cx
      jmp     LLL_GotAll
     LLL_GotAllClusterNotEmpty:
      ; Damn, Cluster didn't got empty. So we have to copy the rest out...
      xor     ch, ch
      not     cl
      inc     cl                         ; 0FFh -> 1 sector to get...
      ; Now copy rest to 6000:0 location for later processing...
      ; ES:DI - Ending location of Setup Code
      mov     ax, 9000h
      mov     ds, ax
      mov     ax, 6000h
      mov     es, ax
      push    cx si                      ; Push Kernel-Entry-Pointer
         mov     si, di
         shl     cx, 9                   ; Sectors to Byte Count
         sub     si, cx                  ; DS:SI - Begin of Kernel Data
         xor     di, di
         shr     cx, 1
         rep     movsw                   ; Copy Data...
      pop     si cx                      ; Get Kernel-Entry-Pointer back
     LLL_GotAll:
   pop     es ds

   push    cx dx                          ; Push Missing-Sectors, StartCluster
      mov     ax, 9000h
      mov     ds, ax

      ; Check Signatures for security...
      cmp     wptr ds:[1FEh], 0AA55h
      jne     LLL_BadKernel
      cmp     wptr ds:[202h], 'dH'
      jne     LLL_BadKernel
      cmp     wptr ds:[204h], 'Sr'
      je      LLL_GoodKernel
     LLL_BadKernel:
      push    es
      pop     ds
      mov     si, offset Linux_GotBadKernel
      call    MBR_Teletype
      jmp     MBR_HaltSystem
     LLL_GoodKernel:

      ; Now we have at least some of the required sectors loaded
      mov     ax, 9000h
      mov     dx, ax
      mov     al, bptr ds:[01F1h]         ; Setup Sectors to load
      ;   -> to 9020:0

      ; Just append parameters to end of Linux boot-block...
      xor     ah, ah
      mov     bl, 20h
      mul     bl           ; AX * 20
      add     dx, ax       ; add to segment    -> Segment of Parameters

      mov     wptr ds:[0020h], 0A33Fh
      mov     ax, dx
      and     ax, 0FFFh                   ; 9100h -> 0100h
      shl     ax, 4                       ; 0100h -> 1000h
      mov     wptr ds:[0022h], ax         ; offset of parameter relative 9000:0

      ; fill out Linux-Loader byte, so SETUP will do its job
      mov     bptr ds:[0210h], 0A0h       ; AiR-BOOT (unknown ID for Linux btw)
      mov     cx, wptr ds:[01F4h]         ; Linux Kernel Length in 16-byte blocks
      shr     cx, 5
      inc     cx                          ; Convert to Sector-Count
      push    cx
         push    cs
         pop     ds                       ; CS == DS
         mov     es, dx                   ; ES = Segment for parameters
         xor     di, di                   ; ES:0 - Parameter Ptr
         mov     dl, cs:[CFG_LinuxRootPartition]
         cmp     dl, 0FFh
         je      LLL_NoRootPartitionFound
         mov     cx, 5
         mov     si, offset Linux_RootDefine
         rep     movsb                    ; root=
         call    LINUX_TranslateToDEV     ; Writes DEV (dl) at ES:DI (/dev/hda9)

        LLL_NoRootPartitionFound:
         ; Root-Define complete, now for the user Kernel Command-Line...
         mov     si, offset CFG_LinuxCommandLine
         mov     al, ds:[si]
         or      al, al
         jz      LLL_CommandLineLoop
         mov     al, ' '
         stosb                            ; If any command-line, insert space
        LLL_CommandLineLoop:
            lodsb
            stosb                         ; Copy string till and including NUL
         or      al, al
         jnz     LLL_CommandLineLoop
         stosb                            ; Write another NUL
      pop     cx
   pop     dx bx                          ; Pop StartCluster, Missing-Sectors
   ; CX - Sector-Count of Kernel Image, DX - Starting Cluster of Kernel Image
   ; BX - Sector-Count left over in 6000:0 area from Setup Code loading
   ; DS == CS

   ; Now comes some tricky part. Hopefully we have a tiny kernel.
   ; If we have a big kernel, we have to 'upload' it to PM-memory space.
   test    bptr ds:[0211h], 01h
   jz      LLL_LoadNormalKernel
   jmp     LLL_LoadBigKernel
         
  LLL_LoadNormalKernel:
   ; NORMAL KERNEL

   ; Still UNSUPPORTED. This suxxs

  LLL_LoadBigKernel:
   ; BIG KERNEL - Oh no, we have to load all data to extended memory...
   mov     ax, 6000h
   mov     es, ax
   shr     ax, 4
   ; Set Source to 06:0000
   mov     bptr cs:[MBR_Linux_GDT_Src+0], al
   mov     wptr cs:[MBR_Linux_GDT_Src+1], ax
   xor     si, si
   or      bx, bx                        ; No unfinished Cluster ?
   jz      LLL_LoadBigKernelLoop
   push    cx
      mov     cx, bx
      shl     cx, 8                      ; Sectors to WORD Count
      call    LINUX_MoveKernelPart       ; Copy Data to Extended Memory
   pop     cx
  LLL_LoadBigKernelLoop:
   push    cx
      ; DX - Current Cluster
      ; CX - Total WORDs that need to be loaded
      ; ES - Segment
      mov     cx, 8000h
      call    LINUX_LoadDataToMemory
      ; CX - Total WORDs that were loaded...
      ; Got 6000:0 filled...
      call    LINUX_MoveKernelPart
      shr     cx, 8                      ; WORDs to SEGMENTs
      add     si, cx
   pop     cx
   cmp     si, cx
   jb      LLL_LoadBigKernelLoop

  LLL_FinishedLoadKernel:
   ; either way, we give execution to setup at 9020:0
   mov     ax, 09020h
   mov     ss, ax
   mov     sp, 4000h-12h   ; Linux wants it this way...
   mov     ds, ax
   mov     es, ax
   db      0EAh
   dw      0
   dw      09020h
LINUX_LoadKernel                EndP

; Loads Data from Cluster(s) to memory...
;        In: DX - First cluster to read from...
;            CX - Total WORDs that need to be loaded at least
;            ES - Segment, where to load to (Starting Offset is zero)
;       Out: CX - Total WORDs that got loaded
;            DX - Cluster following last loaded cluster
;            (buffer filled)
; Destroyed: None
; MUST BE USING CS for addressing Code Segment, DS =! CS
LINUX_LoadDataToMemory          Proc Near  Uses di
   shl     cx, 1                         ; Convert WORDs to BYTEs
   dec     cx                            ; 0000h -> FFFFh
   xor     di, di
  LLDTM_LoadLoop:
      call    FAT16_ReadCluster          ; Load Cluster DX to ES:DI
      ; DX and DI were updated by ReadCluster, so don't modify them...
   or      di, di
   jz      LLDTM_Overflow
   cmp     di, cx
   jbe     LLDTM_LoadLoop
   mov     cx, di
   shr     cx, 1
   inc     cx                            ; 3FFFh -> 4000h
   ret
  LLDTM_Overflow:
   mov     cx, 08000h
   ret
LINUX_LoadDataToMemory          EndP

; Copies Extended-Memory (clobbered from Linux setup)
;        In: CX    - Total WORDs to copy
;       Out: (buffer copied)
; Destroyed: None
; MUST BE USING CS for addressing Code Segment, DS =! CS
LINUX_MoveKernelPart            Proc Near  Uses ax cx es si
   mov     ax, cs
   mov     es, ax
   mov     si, offset MBR_Linux_GDT
   push    cx
      mov     ax, 08700h
;      IFDEF ReleaseCode
         int     15h
         jc      LMKP_Error
;      ENDIF
   pop     cx
   ; now adjust Destination by copied word-count
   add     wptr cs:[MBR_Linux_GDT_Dst], cx
   adc     bptr cs:[MBR_Linux_GDT_Dst+2], 0
   add     wptr cs:[MBR_Linux_GDT_Dst], cx
   adc     bptr cs:[MBR_Linux_GDT_Dst+2], 0
   ret
  LMKP_Error:
   mov     ax, cs
   mov     ds, ax
   mov     si, offset Linux_INT15error
   call    MBR_Teletype
   jmp     MBR_HaltSystem
LINUX_MoveKernelPart            EndP

MBR_Linux_GDT:          dw          0, 0, 0, 0
                        dw          0, 0, 0, 0
                        dw          0FFFFh
MBR_Linux_GDT_Src       db          0, 0, 06h    ; Source is 6000:0
                        db          093h
                        dw          0
                        dw          0FFFFh
MBR_Linux_GDT_Dst       db          0, 0, 10h    ; Dest is "10000:0" 
                        db          093h
                        dw          0
                        dw          0, 0, 0, 0
                        dw          0, 0, 0, 0
                        dw          0

;
; Example of boot setup command under lilo prompt:
;
; lilo: linux root=/dev/sda2 sym53c8xx=tags:4,sync:10,debug:0x200
;
