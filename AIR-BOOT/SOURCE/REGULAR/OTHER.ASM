
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
;                                                 AiR-BOOT / OTHER ROUTINES
;---------------------------------------------------------------------------

;        In: DS:SI - Pointer to begin of string
;            CX - Len of string
;       Out: CX - Supposed real len of string
;            Zero Flag set if nul string
; Destroyed: None
GetLenOfName                    Proc Near   Uses ax si
   add     si, cx
   dec     si
  GLON_NameLoop:
      mov     al, ds:[si]
      dec     si
      cmp     al, 32
      ja      GLON_EndLoop
      dec     cx
      jnz     GLON_NameLoop
  GLON_EndLoop:
   or      cx, cx
   ret                                   ; return supposed len
GetLenOfName                    EndP

;        In: DS:SI - Pointer to NUL-terminated string
;       Out: CX - Length of string
;            Zero Flag set if nul string
; Destroyed: None
GetLenOfString                 Proc Near   Uses ax si
   xor     cx, cx
  GLOS_StringLoop:
      lodsb
      or      al, al
      jz      GLOS_EndOfString
      inc     cx
      jmp     GLOS_StringLoop

  GLOS_EndOfString:
   or      cx, cx
   ret
GetLenOfString                 EndP

;        In: DS:SI - Pointer to NUL-terminated strings
;            CL    - Counter, how many strings to count
;       Out: CX - Length of strings
; Destroyed: None
GetLenOfStrings                Proc Near   Uses bx dx si
   mov     dh, cl
   xor     dl, dl
  GLOSS_StringsLoop:
      call    GetLenOfString
      add     dl, cl
      add     si, cx
      inc     si
   dec     dh
   jnz     GLOSS_StringsLoop
   movzx   cx, dl
   ret
GetLenOfStrings                EndP

PRECRAP_Main                    Proc Near  Uses
   ; First initialize Variable-Area (everything with NUL)
   mov     di, offset BeginOfVariables
   mov     cx, offset EndOfVariables-offset BeginOfVariables
   xor     ax, ax
   shr     cx, 1
   inc     cx
   rep     stosw

   mov     VideoIO_Segment, VideoIO_Page0

   ; Calculate Cooper-Bar Tables
   call    FX_CalculateTables

   ; Setup PartitionPointers-Table
   call    PART_CalculateStraightPartPointers

   ; Setup Cyrillic Charset, if needed
   ifdef TXT_IncludeCyrillic
      call    CHARSET_IncludeCyrillic
   endif

   call    PRECRAP_CheckFor13extensions
   IFNDEF ReleaseCode
      ret
   ENDIF
   call    PRECRAP_CheckConfiguration
   ; =======================================
   ; Checks for MBR Virii :) I love that job
   ; =======================================
   test    CFG_DetectStealth, 1
   jz      PCM_NoStealthDetection
      call    VIRUS_CheckForStealth
  PCM_NoStealthDetection:
   test    CFG_DetectVirus, 1
   jz      PCM_NoVirusDetection
      call    VIRUS_CheckForVirus
  PCM_NoVirusDetection:
   ; ============================================
   ;  Delay for some time and get Strg/Alt State
   ; ============================================
   test    CFG_CooperBars, 1
   jnz     PCM_ShortDelay
   mov     al, 27                        ; About 1.5 seconds
   test    CFG_FloppyBootGetName, 1
   jz      PCM_LongDelay
  PCM_ShortDelay:
   mov     al, 13                        ; shorten delay,if floppy gets accessed
  PCM_LongDelay:
   call    TIMER_WaitTicCount
   ; First check, if any normal key got pressed...
   mov     ah, 1
   int     16h
   jz      PCM_NoNormalKeyPressed
   ; User doesn't know what to do...or he is crazy <g> so display message
   mov     si, offset TXT_HowEnterSetup
   call    MBR_Teletype
   mov     al, 54                        ; about 3 seconds, delay again
   call    TIMER_WaitTicCount
  PCM_NoNormalKeyPressed:
   ; Now get keyboard Strg/Alt State
   mov     ah, 02h
   int     16h
   mov     SETUP_KeysOnEntry, al
   ret
PRECRAP_Main                    EndP

AFTERCRAP_Main                  Proc Near  Uses
   ; ===================================================
   ;  Now get volume label of FloppyDrive, if wanted...
   ; ===================================================
   test    CFG_FloppyBootGetName, 1
   jz      ACM_NoFloppyGetName
      call    DriveIO_UpdateFloppyName
      or      ax, ax
      jnz     ACM_NoFloppyGetName
      ; Try a second time, if it failed to detect the Floppy
      call    DriveIO_UpdateFloppyName
  ACM_NoFloppyGetName:
   ret
AFTERCRAP_Main                  EndP

PRECRAP_CheckFor13extensions    Proc Near
   mov     ah, 41h
   mov     bx, 55AAh
   mov     dl, 80h
   int     13h
   cmp     bx, 0AA55h
   je      PCCF13E_Found
  PCCF13E_NotFound:
   ret
  PCCF13E_Found:
   and     cx, 1
   jz      PCCF13E_NotFound
   mov     CurIO_UseExtension, 1
   ret
PRECRAP_CheckFor13extensions    EndP

; Checks Configuration CheckSum...Displays message, if failed.
PRECRAP_CheckConfiguration      Proc Near  Uses ds si es di
   mov     si, offset Configuration
   xor     bx, bx
   mov     cx, 5                   ; Total of 5 Sectors
   mov     dx, CFG_CheckConfig
   mov     CFG_CheckConfig, bx
  PCCC_Loop:
      call    MBR_GetCheckOfSector
   loop    PCCC_Loop
   cmp     bx, dx
   jne     PCCC_Failed
   mov     CFG_CheckConfig, dx
   ret
  PCCC_Failed:
   mov     si, offset TXT_ERROR_CheckConfig
   call    MBR_Teletype
   mov     si, offset TXT_ERROR_CheckFailed
   call    MBR_Teletype
   jmp     MBR_HaltSystem
PRECRAP_CheckConfiguration      EndP
