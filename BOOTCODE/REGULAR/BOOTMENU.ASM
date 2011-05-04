
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
;                                                      AiR-BOOT / BOOT-MENU
;---------------------------------------------------------------------------

BOOTMENU_BuildBackground        Proc Near   Uses es di
   call    VideoIO_CursorOff
   ; -------------------------------------------
   mov     ax, VideoIO_Segment
   mov     es, ax
   xor     di, di
   mov     cx, 2000
   mov     ax, 0720h
   rep     stosw                         ; Clear Screen
   ret
BOOTMENU_BuildBackground        EndP

BOOTMENU_BuildMain              Proc Near   Uses es di
   ; 1st line with Copyright information...
   mov     cx, 0101h
   call    VideoIO_Locate
   mov     cx, 0F00h
   call    VideoIO_Color
   mov     si, offset Copyright
   call    VideoIO_Print                 ; Print Copyright Line...

   ; Boot-Window...
   mov     cx, 0901h
   call    VideoIO_Color
   mov     bx, 0201h
   mov     dx, 0550h
   add     dh, Menu_TotalLines
   call    VideoIO_MakeWindow
   ; The little separator line...
   mov     cx, 0402h
   call    VideoIO_Locate
   mov     al, TextChar_WinLineRight
   mov     cl, 78
   call    VideoIO_Internal_MakeWinRight 

   mov     dl, 18h
   cmp     CFG_BootMenuActive, 2
   jne     BMBM_NoDetailed1
   mov     dl, 15h
  BMBM_NoDetailed1:
   mov     Menu_AbsoluteX, dl

   ; Display Top-Infos in Boot-Window
   mov     cx, 0B01h
   call    VideoIO_Color
   mov     ch, 03h
   mov     cl, dl
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_No
   call    VideoIO_Print
   add     cl, 5
   call    VideoIO_Locate
   ; Dynamic change, if detailed view...
   mov     si, offset TXT_TopInfos_Hd
   add     cl, 5
   cmp     CFG_BootMenuActive, 2
   jne     BMBM_NoDetailed2
   mov     si, offset TXT_TopInfos_HdSize
   add     cl, 8
  BMBM_NoDetailed2:
   call    VideoIO_Print
   ; End of dynamic change
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_Label
   call    VideoIO_Print
   add     cl, 14
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_Type
   call    VideoIO_Print

   ; Now make the separating vertical lines...
   mov     cx, 0901h
   call    VideoIO_Color
   mov     ch, 03h
   mov     cl, Menu_AbsoluteX
   add     cl, 3
   mov     dx, cx
   call    VideoIO_Locate
   mov     cl, 2
   add     cl, Menu_TotalLines
   mov     al, TextChar_WinLineDown
   call    VideoIO_Internal_MakeWinDown  ; Line between "No" and "Hd"
   push    cx
      add     dl, 5
      cmp     CFG_BootMenuActive, 2
      jne     BMBM_NoDetailed3
      add     dl, 8
     BMBM_NoDetailed3:
      mov     cx, dx
      call    VideoIO_Locate
   pop     cx
   call    VideoIO_Internal_MakeWinDown  ; Line between "Hd" and "Label"
   push    cx
      add     dl, 14
      mov     cx, dx
      call    VideoIO_Locate
   pop     cx
   call    VideoIO_Internal_MakeWinDown  ; Line between "Label" and "Type"

   ; Finally the little tweaks to make it look good...
   mov     cl, Menu_AbsoluteX
   add     cl, 3
   mov     dl, 3                         ; 3 Steps in Total
  BMBM_BootWinTweakLoop:
      mov     ch, 02h
      call    VideoIO_Locate
      mov     al, TextChar_WinRep1
      call    VideoIO_PrintSingleChar
      mov     ch, 04h
      call    VideoIO_Locate
      mov     al, TextChar_WinRep2
      call    VideoIO_PrintSingleChar
      mov     ch, 05h
      add     ch, Menu_TotalLines
      call    VideoIO_Locate
      mov     al, TextChar_WinRep3
      call    VideoIO_PrintSingleChar
      dec     dl
      jz      BMBM_EndBootWinTweakLoop
      cmp     dl, 2
      jb      BMBM_3rdTweak
      add     cl, 5
      cmp     CFG_BootMenuActive, 2
      jne     BMBM_BootWinTweakLoop
      add     cl, 8
      jmp     BMBM_BootWinTweakLoop
     BMBM_3rdTweak:
      add     cl, 14
      jmp     BMBM_BootWinTweakLoop
  BMBM_EndBootWinTweakLoop:

   ; Display Boot-Information...
   xor     al, al
   mov     Menu_UpperPart, al
   call    BOOTMENU_RefreshPartitionText
   ; Boot-Window is DONE

   mov     cx, 0C04h
   call    VideoIO_Color
   mov     bx, 1401h
   mov     dx, 1950h
   call    VideoIO_MakeWindow            ; Information-Window
   ; den kleinen Strich...
   mov     cx, 1602h
   call    VideoIO_Locate
   mov     al, TextChar_WinLineRight
   mov     cl, 78
   call    VideoIO_Internal_MakeWinRight

   call    BOOTMENU_BuildTimedBootText

   mov     cx, 1703h
   call    VideoIO_Locate
   mov     cx, 0F04h
   call    VideoIO_Color
   mov     si, offset TXT_BootMenuHelpText1
   call    VideoIO_Print
   mov     cx, 1803h
   call    VideoIO_Locate
   mov     si, offset TXT_BootMenuHelpText2
   call    VideoIO_Print

   mov     cx, 0C04h
   call    VideoIO_Color

   IFDEF ReleaseCommercial
      mov     si, offset RegisteredTo
      call    GetLenOfString
      mov     dx, 144Eh
      sub     dl, cl
      mov     cx, dx
      call    VideoIO_Locate
      mov     al, TextChar_WinRep4
      call    VideoIO_PrintSingleChar
      call    VideoIO_Print
      mov     al, TextChar_WinRep5
      call    VideoIO_PrintSingleChar
   ENDIF

   ; Additional message how to enter setup
   mov     si, offset TXT_BootMenuEnterSetup
   call    GetLenOfString
   mov     dx, 194Eh
   sub     dl, cl
   mov     cx, dx
   call    VideoIO_Locate
   mov     al, TextChar_WinRep4
   call    VideoIO_PrintSingleChar
   call    VideoIO_Print
   mov     al, TextChar_WinRep5
   call    VideoIO_PrintSingleChar
   ; HelpWindow done...
   ret
BOOTMENU_BuildMain              EndP

BOOTMENU_BuildGoodBye           Proc Near   Uses es di
   mov     ax, VideoIO_Segment
   mov     es, ax
   xor     di, di
   mov     cx, 2000
   mov     ax, 0720h
   rep     stosw
   ; -------------------------------------------
   mov     cx, 0D05h
   call    VideoIO_Color
   mov     bx, 0101h
   mov     dx, 0450h
   call    VideoIO_MakeWindow            ; Information-Window
   xor     di, di
   mov     cx, 10
   mov     ax, 0720h
   rep     stosw
   mov     di, 162
   mov     cx, 9
   mov     al, WinCharRight
   mov     ah, 05Dh
   rep     stosw
   mov     cx, 010Bh
   call    VideoIO_Locate
   mov     al, WinCharBB
   call    VideoIO_PrintSingleChar
   mov     cx, 0201h
   call    VideoIO_Locate
   mov     al, WinCharBB
   call    VideoIO_PrintSingleChar
   mov     cx, 000Bh
   call    VideoIO_Locate
   mov     al, WinCharEE
   call    VideoIO_PrintSingleChar
   ; --------------------------------------- Window done
   mov     cx, 010Ch
   call    VideoIO_Locate
   mov     al, TextChar_WinRep4
   call    VideoIO_PrintSingleChar
   mov     cx, 0E01h
   call    VideoIO_Color
   mov     si, offset Copyright
   mov     cl, 11+CopyrightVersionLen
   call    VideoIO_FixedPrint
   mov     cx, 0D05h
   call    VideoIO_Color
   mov     al, TextChar_WinRep5
   call    VideoIO_PrintSingleChar
   mov     cx, 020Dh
   call    VideoIO_Locate
   mov     cx, 0F05h
   call    VideoIO_Color
   inc     si
   call    VideoIO_Print                 ; Print Copyright to the end...
   mov     cx, 0303h
   call    VideoIO_Locate
   IFDEF ReleaseCommercial
      mov     si, offset RegisteredTo
     ELSE
      mov     si, offset BootEndMsg         ; Print End-Message...
   ENDIF
   call    VideoIO_Print
   ; -------------------------------------------
   mov     ah, 02h
   mov     bh, 00h
   mov     dx, 0500h                     ; Sets cursor location to 6, 0
   int     10h
   call    VideoIO_CursorOn
   ret
BOOTMENU_BuildGoodBye           EndP

; Must preserve AX!
BOOTMENU_BuildTimedBootText     Proc Near   Uses ax cx si es di
   mov     cx, 1503h
   call    VideoIO_Locate
   mov     cx, 0E04h
   call    VideoIO_Color
   call    VideoIO_Internal_SetRegs
   mov     cx, 76
   mov     al, 20h                       ; Space
   rep     stosw                         ; delete all at first
   mov     al, TimedBootEnable
   or      al, al
   jz      BMBTBT_NoTimed
   jmp     BMBTBT_TimedBoot
  BMBTBT_NoTimed:
   mov     si, offset TXT_TimedBootDisabled
   call    VideoIO_Print
   ret

  BMBTBT_TimedBoot:
   mov     cx, 1503h
   call    VideoIO_Locate
   mov     cx, 0E04h
   call    VideoIO_Color
   mov     si, offset TXT_TimedBootLine  ; will print TimedBootEntryName too
   call    VideoIO_Print
   mov     si, offset TXT_TimedBootLine2
   call    VideoIO_Print
   mov     al, TimedSecondLeft
   call    VideoIO_PrintByteDynamicNumber
   mov     si, offset TXT_TimedBootSecond ; 'Second.'
   cmp     al, 1
   je      BMBTBT_JustOneLeft
   mov     si, offset TXT_TimedBootSeconds ; 'Seconds.'
  BMBTBT_JustOneLeft:
   call    VideoIO_Print
   ret
BOOTMENU_BuildTimedBootText     EndP

BOOTMENU_RefreshPartitionText   Proc Near Uses cx dx
   mov     dl, Menu_UpperPart  ; Current Partition to Display
   mov     ch, 5               ; Line On Screen
   mov     cl, Menu_TotalLines ; Total Lines to Display
  BMRPT_Loop:
      ; Write Partition-Info (partition DL) to Screen at CH
      call    BOOTMENU_BuildPartitionText
      inc     ch
      inc     dl
   dec     cl
   jnz     BMRPT_Loop
   ret
BOOTMENU_RefreshPartitionText   EndP

; Writes Partition-Information to Screen (Boot-Menu)
;        In: CH - Line to print info
;            DL - Number of Partition (Base=0)
; Destroyed: None
BOOTMENU_BuildPartitionText     Proc Near   Uses ax cx dx si
   local PartPointer:word

   call    PART_GetPartitionPointer      ; Gets pointer to partition (DL) -> SI
   mov     PartPointer, si

   ; === Display Boot-Number ===
   mov     cl, Menu_AbsoluteX
   mov     dh, cl
   call    VideoIO_Locate
   mov     cx, 0F01h                     ; Bwhite, blue
   call    VideoIO_Color
   mov     al, dl
   inc     al
   call    VideoIO_PrintByteNumber

   ; === Display Drive-Number and Size (Size only in detailed view) ===
   add     dh, 5
   movzx   cx, dh
   call    VideoIO_Locate
   mov     cx, 0D01h
   call    VideoIO_Color                 ; Violet, blue
   mov     si, PartPointer
   mov     al, cs:[si+LocIPT_Drive]
   sub     al, 7Fh                       ; Will only display numbers up to 99,
   call    VideoIO_PrintByteNumber       ;  so only showing harddrives...
   add     dh, 5
   cmp     CFG_BootMenuActive, 2
   jne     BMBPT_NoDetailed
      add     dh, 8
      cmp     al, 99
      jbe     BMBPT_IsHarddrive
      mov     al, ' '
      mov     cl, 7
      call    VideoIO_PrintSingleMultiChar ; Fill up Size-Space with spaces
      jmp     BMBPT_NoDetailed
     BMBPT_IsHarddrive:
      ; Now display Size-Element...
      mov     cx, 0501h
      call    VideoIO_Color              ; Dark-Violet, Blue
      mov     al, '/'
      call    VideoIO_PrintSingleChar
      mov     cx, 0D01h
      call    VideoIO_Color              ; Violet, Blue
      mov     ax, PartPointer            ; Get Size-Element from PartPtr (AX)
      call    PART_GetSizeElementPointer ; DS:SI -> Size-Element...
      mov     cl, 4
      call    VideoIO_FixedPrint         ; Display 4 chars from DS:SI
      inc     TextPosX                   ; Manual-Hackin to adjust TextPos
      mov     cl, 2
      call    VideoIO_FixedPrint         ; Display 2 chars from DS:SI
  BMBPT_NoDetailed:

   ; === Display Label ===
   movzx   cx, dh
   call    VideoIO_Locate
   mov     cx, 0E01h
   call    VideoIO_Color                 ; Yellow, blue
   mov     si, PartPointer
   add     si, LocIPT_Name
   mov     cl, 11
   call    VideoIO_FixedPrint

   ; === Display Type ===
   add     dh, 14
   movzx   cx, dh
   call    VideoIO_Locate
   mov     si, PartPointer
   mov     al, cs:[si+LocIPT_SystemID]
   call    PART_SearchFileSysName
   mov     cx, 0C01h
   call    VideoIO_Color                 ; Hrot, Blau
   mov     cl, 8
   call    VideoIO_FixedPrint
   ret
BOOTMENU_BuildPartitionText     EndP

;        In: DL - Active Partition
;            DH - New Active Partition (may not be correct number)
;       Out: DX - will get returned (fixed, if needed)
BOOTMENU_BuildChoiceBar         Proc near   Uses ax es di
   call    VideoIO_WaitRetrace
   mov     cl, 10h    ; Color BLUE, Partition DL
   call    BOOTMENU_ReColorPart

   ; Check, if clipping needed...
   cmp     dh, 0ffh
   jne     BMBCB_RightMin
   xor     dh, dh
  BMBCB_RightMin:
   cmp     dh, Menu_TotalParts           ; DH is base 0, TotalParts is counter
   jb      BMBCB_AfterClipping           ; That's why JB and not JBE
   mov     dh, Menu_TotalParts
   dec     dh                            ; Now base 0
  BMBCB_AfterClipping:
   ; After Clipping
   mov     dl, dh
   mov     cl, Menu_UpperPart
   ; Now check, if we need to Scroll
   cmp     dh, cl
   jae     BMBCB_NoScrollUp
  BMBCB_ScrollingUp:
   dec     Menu_UpperPart
   cmp     dh, Menu_UpperPart
   jb      BMBCB_ScrollingUp
   call    BOOTMENU_RefreshPartitionText
   jmp     BMBCB_AfterScrolling

  BMBCB_NoScrollUp:
   add     cl, Menu_TotalLines
   cmp     dh, cl
   jb      BMBCB_AfterScrolling
  BMBCB_ScrollingDown:
   inc     cl
   inc     Menu_UpperPart
   cmp     dh, cl
   jae     BMBCB_ScrollingDown
   call    BOOTMENU_RefreshPartitionText

  BMBCB_AfterScrolling:
   mov     cl, 50h    ; Color PINK, Partition DL
   call    BOOTMENU_ReColorPart
   ret
BOOTMENU_BuildChoiceBar         EndP

;        In: CL - Color, DL - Partition
; Destroyed: None, but Locate-Pointer gets set
BOOTMENU_ReColorPart            Proc Near   Uses bx cx es di
   mov     bh, cl     ; Color to BH
   ; First calculate location of bar
   cmp     Menu_UpperPart, dl
   ja      BMRCP_NotInWindowView
   mov     ch, dl
   sub     ch, Menu_UpperPart            ; CH - Position relative to UpperPart
   cmp     ch, 14                        ; 14 - Maximum Total in Window
   ja      BMRCP_NotInWindowView
   add     ch, 5                         ; Y-Position add-on fixed 5
   mov     cl, 2                         ; X-Position is always 2
   call    VideoIO_Locate                ; geht zu CX
   call    VideoIO_Internal_SetRegs
   inc     di                            ; DI - Destination+1 -> Color-Byte
   mov     cl, 78                        ; Length of Bar is always 78
  BMRCP_ClearLoop:
      mov     al, es:[di]
      and     al, 0Fh
      or      al, bh                     ; Adds background color (from BH)
      mov     es:[di], al
      add     di, 2
   dec     cl
   jnz     BMRCP_ClearLoop
  BMRCP_NotInWindowView:
   ret
BOOTMENU_ReColorPart            EndP



; Calculate Menu-Variables for Boot-Menu, these use the filtered Part-Pointers
BOOTMENU_ResetMenuVars          Proc Near   Uses dx
   xor     dl, dl                        ; Partition at Pos 0 == 1st
   mov     Menu_UpperPart, dl

   ; = TIMED BOOTING =
   mov     dl, CFG_TimedBoot
   mov     TimedBootEnable, dl
   mov     al, CFG_TimedSecs
   mov     TimedSecondLeft, al
   call    TIMER_TranslateSecToTic
   add     ax, 16                        ; So that the required ammount will
   mov     CFG_TimedDelay, ax            ; be shown and not Timer-1.
   call    BOOTMENU_ResetTimedBoot
   ; = FLOPPY-GET-NAME TIMER =
   call    BOOTMENU_ResetGetFloppy

   ; Resettet die Base-Variablen...
   mov     dl, PartitionPointerCount
   mov     Menu_TotalParts, dl

   ; Now copy the device-name to the ContBIOSbootSeq-IPT entry
   movzx   bx, CFG_ResumeBIOSbootSeq
   dec     bx
   shl     bx, 1
   mov     si, wptr [ContinueBIOSbootTable+bx]
   mov     di, offset BIOScontIPTentry+LocIPT_Name
   push    di
      mov     cx, 11
      mov     al, ' '
      rep     stosb
   pop     di
  BMRMV_BootDeviceCopyLoop:
      lodsb
      or      al, al
      jz      BMRMV_NoResumeBootSeq
      stosb
      jmp     BMRMV_BootDeviceCopyLoop
  BMRMV_NoResumeBootSeq:

   ; Default-Partition -> Filtered View -> Menu_EntryDefault
   mov     dl, CFG_PartDefault
   call    PART_ConvertFromStraight
   mov     Menu_EntryDefault, dl

   ; Last-Booted-Partition -> Filtered View -> Menu_EntryLast
   mov     dl, CFG_PartLast
   call    PART_ConvertFromStraight
   mov     Menu_EntryLast, dl

   ; Automatic-Partition -> Filtered View -> Menu_EntryAutomatic
   mov     dl, CFG_PartAutomatic
   call    PART_ConvertFromStraight
   mov     Menu_EntryAutomatic, dl

   ; Okay, now we check if Default/Last Kernel Partition Name is available...
   ;  if so, simply set Menu_EntryDefault/Menu_EntryLast.
   mov     si, offset CFG_LinuxDefaultKernel
   call    LINUX_SearchKernelName        ; DL - Filtered Entry No
   cmp     dl, 0FFh
   je      BMRMV_DefaultKernelNF
   mov     Menu_EntryDefault, dl
  BMRMV_DefaultKernelNF:
   mov     si, offset CFG_LinuxLastKernel
   call    LINUX_SearchKernelName        ; DL - Filtered Entry No
   cmp     dl, 0FFh
   je      BMRMV_LastKernelNF
   mov     Menu_EntryLast, dl
  BMRMV_LastKernelNF:

   ; restlichen Variablen berechnen...
   mov     dl, Menu_TotalParts
   cmp     Menu_TotalParts, 14
   jbe     BMRMV_NotMoreThan14
   mov     dl, 14
  BMRMV_NotMoreThan14:
   mov     Menu_TotalLines, dl

   ; Now copy the name of the Timed-Booted Partition to TimedBoot-Field
   mov     dl, Menu_EntryDefault
   test    CFG_TimedBootLast, 1
   jz      BMRMV_TimedBootDefault
   mov     dl, Menu_EntryLast
  BMRMV_TimedBootDefault:
   call    PART_GetPartitionPointer      ; Holt SI fr Partition DL
   add     si, LocIPT_Name
   mov     cx, 11
   call    GetLenOfName
   mov     di, offset TXT_TimedBootEntryName
   jz      BMRMV_NoName
   rep     movsb
  BMRMV_NoName:
   xor     al, al
   stosb              ; Ending Zero
   ret
BOOTMENU_ResetMenuVars          EndP

; Will Set some Vars after user selected entry to boot...
;  ...don't select Straight View !
BOOTMENU_SetVarsAfterMenu Proc Near  Uses
   ; No Straight View in here...we got filtered view since BootMenu-Startup...
   mov     al, CFG_RememberTimed
   test    TimedBootUsed, 1
   jnz     BMSVAM_TimedBootUsed
   mov     al, CFG_RememberBoot
  BMSVAM_TimedBootUsed:
   or      al, al
   jz      BMSVAM_DontRememberBoot
   mov     dl, Menu_EntrySelected
   call    PART_ConvertToStraight        ; CFG_PartLast is non-filtered
   mov     di, offset CFG_LinuxLastKernel
   mov     cx, 11
   cmp     dl, 0FDh                      ; Dont Remember on Floppy/CD-ROM/etc.
   ja      BMSVAM_DontRememberBoot
   je      BMSVAM_RememberKernelBoot     ; but remember Kernel-Bootings...
   mov     CFG_PartLast, dl              ; Remember partition in CFG_PartLast
   mov     al, ' '
   rep     stosb                         ; SPACE out CFG_LinuxLastKernel
  BMSVAM_DontRememberBoot:
   ret

  BMSVAM_RememberKernelBoot:
   mov     dl, Menu_EntrySelected
   call    PART_GetPartitionPointer      ; SI - Pointer to Kernel Entry...
   add     si, LocIPT_Name
   rep     movsb                         ; Copy KernelName 2 CFG_LinuxLastKernel
   ret
BOOTMENU_SetVarsAfterMenu       EndP

; Actually does the Boot-Menu Interaction
; Sets Carry-flag, if Setup is to be entered, otherwise system shall get booted
; On boot: Fills out some variables (like Menu_EntrySelected), when Booting
BOOTMENU_Execute                Proc Near   Uses es di
   ; Finds out, where to place the bar at first...
   mov     dl, Menu_EntryDefault
   test    CFG_RememberBoot, 1
   jnz     BME_RememberMode
   test    CFG_RememberTimed, 1
   jz      BME_ForgetMode
  BME_RememberMode:
   mov     dl, Menu_EntryLast
  BME_ForgetMode:
   ; Got it, so display bar...
   mov     dh, dl
   call    BOOTMENU_BuildChoiceBar       ; DH - Active, DL - Last Active
   call    SOUND_PreBootMenu

  BME_MainLoop:
   test    TimedBootEnable, 1
   jz      BME_NoTimedBoot
      ; ------------------------------------------------ TIMED BOOT
      push    ax dx
         call    TIMER_GetTicCount
         mov     dx, word ptr [TimedTimeOut]
         sub     dx, ax
         mov     ax, dx
         call    TIMER_TranslateTicToSec ; DX - Timertics till ByeBye
         cmp     al, TimedSecondLeft     ; -> AL - Seconds till ByeBye
         je      BME_NoFixSecond
         mov     TimedSecondLeft, al
         call    BOOTMENU_BuildTimedBootText ; Display Timed-Boot-Text
        BME_NoFixSecond:
         cmp     al, 0
         jne     BME_NoTimeOut
      pop     dx ax
      mov     dl, Menu_EntryDefault
      and     CFG_TimedBootLast, 1
      jz      BME_TimedBootDefault
      mov     dl, Menu_EntryLast
     BME_TimedBootDefault:
      mov     Menu_EntrySelected, dl        ; Just boot default partition
      mov     TimedBootUsed, 1           ; set flag...
      clc                                ; Boot-Now!
      ret

     BME_NoTimeOut:
      pop     dx ax
  BME_NoTimedBoot:
   ; ------------------------------------------------ FLOPPY-NAME TIMER
   test    CFG_FloppyBootGetTimer, 1
   jz      BME_NoFloppyNameTimer
      ; Wait 2 Seconds everytime
      push    ax dx
         call    TIMER_GetTicCount
         cmp     dx, wptr cs:[FloppyGetNameTimer+2]
         ja      BME_ExpiredGetFloppy
         cmp     ax, wptr cs:[FloppyGetNameTimer+0]
         jb      BME_NoFloppyNameExpired
        BME_ExpiredGetFloppy:
         call    BOOTMENU_ResetGetFloppy
      pop     dx ax
      jmp     BME_RefreshFloppyName
        BME_NoFloppyNameExpired:
      pop     dx ax
  BME_NoFloppyNameTimer:
   ; ------------------------------------------------ KEYBOARD
   push    dx
      mov     ah, 1
      int     16h
   pop     dx
   jnz     BME_KeyAvailable
   jmp     BME_MainLoop

  BME_RefreshFloppyName:
   test    CFG_IncludeFloppy, 1
   jz      BME_NoRefreshFloppyName
      test    CFG_FloppyBootGetName, 1
      jz      BME_NoRefreshFloppyName
         call    DriveIO_UpdateFloppyName
         call    BOOTMENU_RefreshPartitionText
         call    BOOTMENU_BuildChoiceBar ; Redisplay the selection-bar
  BME_NoRefreshFloppyName:
   jmp     BME_MainLoop

  BME_KeyAvailable:
   push    dx
      mov     ah, 0
      int     16h
   pop     dx
   cmp     ah, Keys_Enter
   je      BME_KeyEnter
   cmp     ah, Keys_F10
   je      BME_KeyF10
   cmp     ah, Keys_Delete
   je      BME_KeyDelete
   cmp     ah, Keys_ESC
   je      BME_KeyESC
   ; Upper Keys do not fall under Timed Boot Key Handling
   test    TimedBootEnable, 1
   je      BME_NoTimedKeyHandling
      cmp     CFG_TimedKeyHandling, 1
      jb      BME_NoTimedKeyHandling     ; = 0
      je      BME_ResetTimedBoot         ; = 1
      mov     al, TimedBootEnable        ; = 2
      xor     al, 1                      ; Flip Flop Switch :]
      mov     TimedBootEnable, al
     BME_ResetTimedBoot:
      push    dx
         call    BOOTMENU_ResetTimedBoot     ; Reset Timer
         call    BOOTMENU_BuildTimedBootText ; Refresh TimedBootText
      pop     dx
  BME_NoTimedKeyHandling:
   cmp     ah, Keys_TAB
   je      BME_KeyTAB
   cmp     ah, Keys_Up
   je      BME_KeyUp
   cmp     ah, Keys_Down
   je      BME_KeyDown
   jmp     BME_MainLoop

  BME_KeyUp:
   dec     dh
   call    BOOTMENU_BuildChoiceBar       ; DH - Active, DL - Last Active
   jmp     BME_MainLoop

  BME_KeyDown:
   inc     dh
   call    BOOTMENU_BuildChoiceBar       ; DH - Active, DL - Last Active
   jmp     BME_MainLoop

  BME_KeyEnter:
   mov     Menu_EntrySelected, dl
   mov     TimedBootUsed, 0              ; reset flag...
   clc                                   ; Boot-Now!
   ret

  BME_KeyF10:
   mov     al, Keys_Flags_EnterSetup
   mov     SETUP_KeysOnEntry, al         ; Simulate user wants to enter setup
   stc                                   ; Go Re-Enter Setup
   ret

  BME_KeyDelete:
   call    SOUND_ExecuteBoot
   call    APM_TurnOffComputer
   jmp     BME_MainLoop

  BME_KeyESC:
   mov     al, TimedBootEnable
   xor     al, 1                         ; Flip Flop Switch :]
   mov     TimedBootEnable, al
   push    dx
      call    BOOTMENU_ResetTimedBoot     ; Reset Timer
      call    BOOTMENU_BuildTimedBootText ; Refresh TimedBootText
   pop     dx
   jmp     BME_MainLoop

  BME_KeyTAB:
   push    dx
      test    CFG_CooperBars, 1
      jnz     BME_KeyTAB_ShowFX
      mov     ax, 0501h                  ; Go To Page 1 -> BIOS POST crap
      int     10h
      mov     ah, 0
      int     16h                        ; Wait for any key
      call    BOOTMENU_ResetTimedBoot     ; Reset Timer
      call    BOOTMENU_BuildTimedBootText ; Refresh TimedBootText
      mov     ax, 0500h                  ; Go Back to Page 0
      int     10h
   pop     dx
   jmp     BME_MainLoop
     BME_KeyTAB_ShowFX:
      pusha
         mov     ax, VideoIO_Page1
         mov     bx, VideoIO_Page0
         mov     dx, 160
         xor     di, di
         call    FX_InterleaveCopy
         call    FX_ScrollScreenLeft
         mov     ah, 0
         int     16h                        ; Wait for any key
         call    BOOTMENU_ResetTimedBoot     ; Reset Timer
         call    BOOTMENU_BuildTimedBootText ; Refresh TimedBootText
         call    FX_ScrollScreenRight
         call    FX_EndScreenInternalCleanUp
         call    BOOTMENU_ResetTimedBoot    ; Reset Timer again...
      popa
   pop     dx
   jmp     BME_MainLoop
BOOTMENU_Execute                EndP

; Resettet den TimedBoot Timer...
BOOTMENU_ResetTimedBoot         Proc Near   Uses ax
   call    TIMER_GetTicCount
   add     ax, CFG_TimedDelay
   adc     dx, 0
   mov     word ptr cs:[TimedTimeOut], ax
   mov     word ptr cs:[TimedTimeOut+2], dx
   ret
BOOTMENU_ResetTimedBoot         EndP

; Resettet den Floppy-Get-Name Timer...
BOOTMENU_ResetGetFloppy         Proc Near   Uses ax
   call    TIMER_GetTicCount
   add     ax, 36                      ; 18*2 -> 2 seconds
   adc     dx, 0
   mov     word ptr cs:[FloppyGetNameTimer], ax
   mov     word ptr cs:[FloppyGetNameTimer+2], dx
   ret
BOOTMENU_ResetGetFloppy         EndP
