
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
;                                          AiR-BOOT SETUP / PARTITION SETUP
;---------------------------------------------------------------------------

; This here is called from Menu in AIR-BSET.asm
PARTSETUP_Main                  Proc Near   Uses
   ; Build Fixed Content...
   call    PARTSETUP_DrawMenuBase
   ; Build Dynamic Content...
   mov     dl, PartSetup_ActivePart
   mov     dh, dl                        ; DL - Current Active, DH - New Active
   call    PARTSETUP_RefreshPartitions
   ; Show Choice-Bar at DH...
   call    PARTSETUP_BuildChoiceBar

   ; Now we got everything on-the-screen
  PSM_MainLoop:
      push    dx
         mov     ah, 0
         int     16h
      pop     dx
      cmp     ah, Keys_Up
      je      PSM_KeyUp
      cmp     ah, Keys_Down
      je      PSM_KeyDown
      cmp     ah, Keys_Left
      je      PSM_KeyLeft
      cmp     ah, Keys_Right
      je      PSM_KeyRight
      cmp     ah, Keys_ESC
      je      PSM_KeyESC
      cmp     ah, Keys_F1
      je      PSM_KeyF1
      cmp     ah, Keys_Enter
      je      PSM_KeyENTER
      ; Flags-Change
      and     al, 0DFh                    ; Upper-Case Input
      cmp     al, TXT_SETUP_FlagLetterBootable
      je      PSM_KeyBootAble
      cmp     al, TXT_SETUP_FlagLetterVIBR
      je      PSM_KeyVIBRdetection
      cmp     al, TXT_SETUP_FlagLetterHide
      je      PSM_KeyHiddenSetup
      cmp     al, TXT_SETUP_FlagLetterDrvLetter
      je      PSM_KeyDriveLetterForceSetup
      cmp     al, TXT_SETUP_FlagLetterExtMShack
      je      PSM_KeyDriveLetterExtMShack
      jmp     PSM_MainLoop

  PSM_KeyESC:
   ; Simpy exit this menu...
   mov     PartSetup_ActivePart, dl
   ret

  PSM_KeyUp:
   cmp     dh, 1
   jbe     PSM_MainLoop
   sub     dh, 2
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop

  PSM_KeyDown:
   add     dh, 2
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop

  PSM_KeyLeft:
   xor     dh, 1
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop

  PSM_KeyRight:
   xor     dh, 1
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop

  PSM_KeyF1:
   mov     bx, offset TXT_SETUPHELP_InPartitionSetup
   call    SETUP_ShowHelp                ; Shows help
   jmp     PSM_MainLoop

  PSM_KeyENTER:
   call    PARTSETUP_ChangePartitionName
   ; Rebuild Menu...
   call    PARTSETUP_DrawMenuBase
   call    PARTSETUP_RefreshPartitions
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop

  PSM_KeyBootAble:
   call    PART_GetPartitionPointer      ; Gets Partition (DL) Pointer -> SI
   mov     al, cs:[si+LocIPT_Flags]
   xor     al, Flags_BootAble
   mov     cs:[si+LocIPT_Flags], al
   call    PARTSETUP_DrawPartitionInfo
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop

  PSM_KeyVIBRdetection:
   call    PART_GetPartitionPointer      ; Gets Partition (DL) Pointer -> SI
   mov     al, cs:[si+LocIPT_Flags]
   xor     al, Flags_VIBR_Detection
   mov     cs:[si+LocIPT_Flags], al
   xor     ax, ax
   mov     wptr cs:[si+LocIPT_BootRecordCRC], ax
   call    PARTSETUP_DrawPartitionInfo
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop

  PSM_KeyHiddenSetup:
   call    PARTHIDESETUP_Main
   ; Rebuild Menu...
   call    PARTSETUP_DrawMenuBase
   call    PARTSETUP_RefreshPartitions
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop

  PSM_KeyDriveLetterForceSetup:
   call    PARTSETUP_DriveLetterSetup
   ; Rebuild Menu...
   call    PARTSETUP_DrawMenuBase
   call    PARTSETUP_RefreshPartitions
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop

  PSM_KeyDriveLetterExtMShack:
   call    PART_GetPartitionPointer      ; Gets Partition (DL) Pointer -> SI
   mov     al, cs:[si+LocIPT_Flags]
   xor     al, Flags_ExtPartMShack
   mov     cs:[si+LocIPT_Flags], al
   call    PARTSETUP_DrawPartitionInfo
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop
PARTSETUP_Main                  EndP

; Draw all standard-things for Partition Setup, dynamic content not included.
PARTSETUP_DrawMenuBase          Proc Near   Uses dx
   call    SETUP_DrawMenuWindow          ; Standard Windows

   ; 1st No Hd [09] Name [15] Flags [1D] Type
   ; 2nd No Hd [31] Name [3D] Flags [45] Type

   mov     cx, 0508h
   call    VideoIO_Locate
   inc     TextPosX
   mov     al, TextChar_WinLineDown
   mov     cl, 9
   call    VideoIO_Internal_MakeWinDown  ; Line between 1st No Hd and Name
   mov     cx, 0515h
   call    VideoIO_Locate
   mov     al, TextChar_WinLineDown
   mov     cl, 9
   call    VideoIO_Internal_MakeWinDown  ; Line between 1st Name and Flags
   mov     cx, 051Dh
   call    VideoIO_Locate
   mov     al, TextChar_WinLineDown
   mov     cl, 9
   call    VideoIO_Internal_MakeWinDown  ; Line between 1st Flags and Type

   mov     cx, 0531h                     ; Line between 2nd No Hd and Name
   call    VideoIO_Locate
   mov     al, TextChar_WinLineDown
   mov     cl, 9
   call    VideoIO_Internal_MakeWinDown
   mov     cx, 053Dh                     ; Line between 2nd Name and Flags
   call    VideoIO_Locate
   mov     al, TextChar_WinLineDown
   mov     cl, 9
   call    VideoIO_Internal_MakeWinDown
   mov     cx, 0545h                     ; Line between 2nd Flags and Type
   call    VideoIO_Locate
   mov     al, TextChar_WinLineDown
   mov     cl, 9
   call    VideoIO_Internal_MakeWinDown

   mov     cx, 0B01h
   call    VideoIO_Color

   ; ------------------------------------- 1st Part
   mov     cx, 0503h
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_No    ; "No Hd"
   mov     cl, 5
   call    VideoIO_FixedPrint
   mov     cx, 050Bh
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_Label ; "Label"
   mov     cl, 5
   call    VideoIO_FixedPrint
   mov     cx, 0517h
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_Flags ; "Flags"
   mov     cl, 5
   call    VideoIO_FixedPrint
   mov     cx, 051Fh
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_Type  ; "Type"
   mov     cl, 4
   call    VideoIO_FixedPrint

   ; ------------------------------------- 2nd Part
   mov     cx, 052Bh
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_No    ; "No Hd"
   mov     cl, 5
   call    VideoIO_FixedPrint
   mov     cx, 0533h
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_Label ; "Label"
   mov     cl, 5
   call    VideoIO_FixedPrint
   mov     cx, 053Fh
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_Flags ; "Flags"
   mov     cl, 5
   call    VideoIO_FixedPrint
   mov     cx, 0547h
   call    VideoIO_Locate
   mov     si, offset TXT_TopInfos_Type  ; "Type"
   mov     cl, 4
   call    VideoIO_FixedPrint

   mov     si, offset TXT_SETUPHELP_PARTSETUP
   call    SETUP_DrawMenuHelp
   ret
PARTSETUP_DrawMenuBase          EndP

; Displays all partitions into Partition Setup Menu
;  aka displays dynamic content.
PARTSETUP_RefreshPartitions     Proc Near   Uses cx dx
   mov     dl, PartSetup_UpperPart
   mov     dh, 12
  PSRP_Loop:
      call    PARTSETUP_DrawPartitionInfo
      inc     dl
   dec     dh
   jnz     PSRP_Loop
   ; At last calculate Scroll-Markers
   mov     cx, 0901h
   call    VideoIO_Color
   mov     cx, 0603h                     ; 6, 3
   mov     dl, PartSetup_UpperPart
   call    PARTSETUP_UpperScrollMarker
   mov     cl, 37                        ; 6, 37
   call    PARTSETUP_UpperScrollMarker
   mov     cl, 43                        ; 6, 43
   call    PARTSETUP_UpperScrollMarker
   mov     cl, 76                        ; 6, 76
   call    PARTSETUP_UpperScrollMarker
   mov     cx, 0D03h                     ; 13, 3
   add     dl, 12                        ; add 12 -> points to last partition
   mov     dh, CFG_Partitions            ; Limit
   call    PARTSETUP_LowerScrollMarker
   mov     cl, 37                        ; 6, 37
   call    PARTSETUP_LowerScrollMarker
   inc     dl                            ; add 1 -> cool way ;-)
   mov     cl, 43                        ; 6, 43
   call    PARTSETUP_LowerScrollMarker
   mov     cl, 76                        ; 6, 76
   call    PARTSETUP_LowerScrollMarker
   ret
PARTSETUP_RefreshPartitions     EndP

; Writes Partition-Information to Screen (Partition-Setup)
;        In: DL - Number of Partition (Base=0)
; Destroyed: None
PARTSETUP_DrawPartitionInfo     Proc Near   Uses ax bx cx dx si
   local NoOfPart :byte
   mov     ch, dl
   sub     ch, PartSetup_UpperPart
   mov     cl, 3                         ; 3 - first Position
   shr     ch, 1
   jnc     PSDPI_LeftPos
   mov     cl, 43                        ; 43 - second Position
  PSDPI_LeftPos:
   add     ch, 7                         ; CH - Line Location for PartInfo
   ; We got location
   mov     NoOfPart, dl
   call    VideoIO_Locate

   cmp     dl, CFG_Partitions
   jb      PSDPI_GotPartitionData
   push    cx
      mov     al, ' '
      mov     cl, 5
      call    VideoIO_PrintSingleMultiChar
   pop     cx
   add     cl, 7
   call    VideoIO_Locate
   push    cx
      mov     al, ' '
      mov     cl, 11
      call    VideoIO_PrintSingleMultiChar
   pop     cx
   add     cl, 13
   call    VideoIO_Locate
   push    cx
      mov     al, ' '
      mov     cl, 5
      call    VideoIO_PrintSingleMultiChar
   pop     cx
   add     cl, 7
   call    VideoIO_Locate
   push    cx
      mov     al, ' '
      mov     cl, 8
      call    VideoIO_PrintSingleMultiChar
   pop     cx
   ret

  PSDPI_GotPartitionData:
   call    PART_GetPartitionPointer      ; Gets Pointer to Partition (DL) -> SI
   mov     al, NoOfPart
   inc     al
   call    VideoIO_PrintByteNumber
   
   ; Display "No Hd" field aka "01/01"
   call    VideoIO_Locate
   push    cx
      mov     cx, 0F01h
      call    VideoIO_Color              ; Bright White, Blue
   pop     cx
   mov     al, NoOfPart
   inc     al
   call    VideoIO_PrintByteNumber
   mov     al, '/'
   call    VideoIO_PrintSingleChar
   mov     al, cs:[si+LocIPT_Drive]
   sub     al, 7Fh
   call    VideoIO_PrintByteNumber

   ; Display "Label" field e.g. "OS2        " (fixed 11 bytes)
   add     cl, 7
   call    VideoIO_Locate
   push    cx
      mov     cx, 0E01h
      call    VideoIO_Color              ; Yellow, Blue
      push    si
         add     si, LocIPT_Name
         mov     cl, 11
         call    VideoIO_FixedPrint
   pop     si cx

   ; Display "Flags" field aka "BVHL"
   add     cl, 13
   call    VideoIO_Locate
   ; This is using a sub-routine for each flag. Is better that way.
   mov     bl, cs:[si+LocIPT_Flags]
   mov     bh, bl
   mov     al, TXT_SETUP_FlagLetterBootable
   and     bl, Flags_BootAble
   call    PARTSETUP_DrawOneFlag
   mov     bl, bh
   mov     al, TXT_SETUP_FlagLetterVIBR
   and     bl, Flags_VIBR_Detection
   call    PARTSETUP_DrawOneFlag
   mov     bl, bh
   mov     al, TXT_SETUP_FlagLetterHide
   and     bl, Flags_HideFeature
   call    PARTSETUP_DrawOneFlag
   mov     bl, bh
   mov     al, TXT_SETUP_FlagLetterDrvLetter
   and     bl, Flags_DriveLetter
   call    PARTSETUP_DrawOneFlag
   mov     bl, bh
   mov     al, TXT_SETUP_FlagLetterExtMShack
   and     bl, Flags_ExtPartMShack
   call    PARTSETUP_DrawOneFlag

   ; Display "Type" field aka "FAT16Big"
   add     cl, 7
   call    VideoIO_Locate
   push    cx
      mov     cx, 0C01h
      call    VideoIO_Color              ; Bright Red, Blue
   pop     cx
   mov     al, cs:[si+LocIPT_SystemID]
   call    PART_SearchFileSysName
   mov     cl, 8
   call    VideoIO_FixedPrint
   ret
PARTSETUP_DrawPartitionInfo     EndP

;        In: AL - Flag-Letter
;            BL - ==0 -> Flag not set, =!0 -> Flag set
; Destroyed: None
PARTSETUP_DrawOneFlag           Proc Near   Uses cx
   mov     cx, 0A01h                     ; Bright Green
   or      bl, bl
   jnz     PSDOF_FlagSet
   mov     ch, 09h                       ; Bright Blue
  PSDOF_FlagSet:
   call    VideoIO_Color
   call    VideoIO_PrintSingleChar
   ret
PARTSETUP_DrawOneFlag           EndP

;        In: DL - Current Active (to be inactivated)
;            DH - New Active (to be activated)
; Destroyed: None
PARTSETUP_BuildChoiceBar        Proc Near   Uses
   cmp     dl, dh
   je      PSBCB_SkipRetrace
   call    VideoIO_WaitRetrace
  PSBCB_SkipRetrace:

   ; Deactivate current active bar
   mov     cl, 10h
   call    PARTSETUP_ReColorPart

   ; Running Fixing 
   cmp     dh, 0FFh
   jne     PSBCB_NoUnderflow
   xor     dh, dh
  PSBCB_NoUnderflow:
   cmp     dh, CFG_Partitions
   jb      PSBCB_NoOverflow
   mov     dh, CFG_Partitions
   dec     dh
  PSBCB_NoOverflow:
   mov     dl, dh

   ; Do we need to scroll ?
   mov     al, PartSetup_UpperPart
   cmp     dl, al
   jb      PSBCB_YesScrolling
   add     al, 12
   cmp     dl, al
   jb      PSBCB_NoScrolling
   mov     al, dl
   and     al, 0FEh                      ; UpperPart is never 1/3/5/7/etc.
   sub     al, 10
   mov     PartSetup_UpperPart, al
   call    PARTSETUP_RefreshPartitions
   jmp     PSBCB_NoScrolling
  PSBCB_YesScrolling:
   mov     al, dl
   and     al, 0FEh                      ; UpperPart is never 1/3/5/7/etc.
   mov     PartSetup_UpperPart, al
   call    PARTSETUP_RefreshPartitions
  PSBCB_NoScrolling:

   ; Activate fresh active bar
   mov     cl, 40h
   call    PARTSETUP_ReColorPart
   ; Now DL==DH
   ret
PARTSETUP_BuildChoiceBar        EndP

;        In: CL - Color, DL - Partition
; Destroyed: None, but Locate-Pointer
PARTSETUP_ReColorPart           Proc Near   Uses bx cx es di
   mov     bh, cl     ; Color to BH
   ; First calculate location of bar
   cmp     dl, PartSetup_UpperPart
   jb      PSRCP_NotInWindowView
   mov     ch, dl
   sub     ch, PartSetup_UpperPart       ; CH - Position relative to UpperPart
   cmp     ch, 12                        ; 12 - Maximum Total in Window
   jae     PSRCP_NotInWindowView
   mov     cl, 2                         ; 2 - first Position
   mov     bl, 39                        ; Length of Bar is 39
   shr     ch, 1
   jnc     PSRCP_LeftPos
   mov     cl, 42                        ; 42 - second Position
   dec     bl                            ; Length of Bar is 38
  PSRCP_LeftPos:
   add     ch, 7      ; Y-Position add-on fixed 7
   call    VideoIO_Locate                ; geht zu CX
   call    VideoIO_Internal_SetRegs
   inc     di         ; DI - Destination+1 -> Color-Byte
   mov     cl, bl     ; Length of Bar is always 39
  PSRCP_ClearLoop:
      mov     al, es:[di]
      and     al, 0Fh
      or      al, bh     ; setzt den Hintergrund (BH)
      mov     es:[di], al
      add     di, 2
   dec     cl
   jnz     PSRCP_ClearLoop
  PSRCP_NotInWindowView:
   ret
PARTSETUP_ReColorPart           EndP

;        In: CX - Location, DL - UpperPartNo
; Destroyed: None, but Locate-Pointer
PARTSETUP_UpperScrollMarker     Proc Near   Uses ax cx
   call    VideoIO_Locate
   mov     al, ' '
   or      dl, dl
   jz      PSUSM_NoMarker
   mov     al, 1Eh
  PSUSM_NoMarker:
   mov     cl, 3
   call    VideoIO_PrintSingleMultiChar
   ret
PARTSETUP_UpperScrollMarker     EndP

;        In: CX - Location, DL - UpperPartNo, DH - Limit
; Destroyed: None, cx dx
PARTSETUP_LowerScrollMarker     Proc Near   Uses ax cx
   call    VideoIO_Locate
   mov     al, ' '
   cmp     dl, dh
   jae     PSLSM_NoMarker
   mov     al, 1Fh
  PSLSM_NoMarker:
   mov     cl, 3
   call    VideoIO_PrintSingleMultiChar
   ret
PARTSETUP_LowerScrollMarker     EndP

; =============================================================================

; This is called from MBRS_Routines_PartitionSetup
;        In: DL - Partition to ChangeName
; Destroyed: ax
PARTSETUP_ChangePartitionName   Proc Near   Uses dx ds si es di
   call    PART_GetPartitionPointer      ; Gets the PartitionPointer for DL in SI

   ; First deactivate current active bar
   mov     cl, 10h
   call    PARTSETUP_ReColorPart

   ; Calculate where the Partition-Name is located...
   mov     ch, dl
   sub     ch, PartSetup_UpperPart ; CH - Position relative to UpperPart
   mov     cl, 10                        ; 10 - first Position
   shr     ch, 1
   jnc     PSCPN_LeftPos
   mov     cl, 50                        ; 50 - second Position
  PSCPN_LeftPos:
   add     ch, 7      ; Y-Position add-on fixed 7
   call    VideoIO_Locate                ; Goes to CX

   mov     al, cs:[si+LocIPT_Flags]
   xor     dx, dx                        ; Remove "Magic" from DX...
   test    al, Flags_NoPartName
   jnz     PSCPN_ChangeButNoBRsave       ; -> No Boot-Record Changing/Saving

   ; Load Boot-Record...
   mov     ax, wptr cs:[si+LocIPT_AbsoluteBegin+0]
   mov     bx, wptr cs:[si+LocIPT_AbsoluteBegin+2]
   mov     cx, cs:[si+LocIPT_LocationBegin+1]
   mov     dh, cs:[si+LocIPT_LocationBegin+0]
   mov     dl, cs:[si+LocIPT_Drive]
   call    DriveIO_LoadPartition

   ; Now check again, if IPT-Label is MATCHING the name in boot-record
   ; If not simply don't save to boot-record, just security here...
   push    ExecBaseSeg
   pop     es
   mov     di, ExecBasePtr
   push    si
      mov     al, cs:[si+LocIPT_SystemID]
      call    PART_SearchFileSysName
      ; Replies AH - FileSysFlags, AL - UnhiddenID, SI - FileSysNamePtr
   pop     si
   test    ah, FileSysFlags_FAT32        ; FAT32 specific name getting
   jz      PSCPN_ResumeNormal
   add     di, 1Ch                       ; Fix fr FAT 32, shit
  PSCPN_ResumeNormal:
   add     di, 2Bh                       ; ES:DI - Name der Partition
   mov     cx, 11                        ; Partition-Name-Length = 11 Bytes
   xor     dx, dx                        ; Remove "Magic" from DX...
   push    si di
      add     si, LocIPT_Name            ; DS:SI -> Partition-Name
      repz    cmpsb
   pop     di si
   jne     PSCPN_ChangeButNoBRsave       ; -> No Boot-Record Changing/Saving
   mov     dx, 0BABEh                    ; Magic - So Boot-Record will get saved
   ; Let user change the name...
  PSCPN_ChangeButNoBRsave:
   mov     cx, 11
   add     si, LocIPT_Name               ; DS:SI -> Partition-Name
   call    VideoIO_LetUserEditString     ; -> does actual editing
   jnc     PSCPN_UserAbort               ; Did user abort ?
   ; ENTERd...
   cmp     dx, 0BABEh                    ; Do we have Magic in CX ?
   jne     PSCPN_UserAbort               ; Just jump over Boot-Record SAVE

   ; Save it as well in Partition's Boot Record...
   mov     cx, 11
   push    si
      rep     movsb                      ; Copy IPT-name to Boot-Record
   pop     si
   IFDEF ReleaseCode
      call    DriveIO_SavePartition      ; Saves Boot-Record
   ENDIF

   ; And reset VIBR-CRC, otherwise virus-warning and system-halt
   sub     si, LocIPT_Name               ; Now pointer points to base again...
   call    PART_UpdateBootRecordCRC

  PSCPN_UserAbort:
   ret
PARTSETUP_ChangePartitionName   EndP




; =============================================================================

; This is called from MBRS_Routines_PartitionSetup
;        In: DL - Partition to HiddenSetup
; Destroyed: ax
PARTHIDESETUP_Main              Proc Near   Uses dx
   ; Spread Special-Marker from Hide-Config
   call    PARTHIDESETUP_GetHideConfigAndSpread
   ; Calculate Position of Window.
   ; If Partition Selected Left-Side -> go Right-Sided Window
   ;                                     otherwise Left-Sided.
   mov     PartSetup_ActivePart, dl
   mov     ax, 0102h
   and     dl, 1
   jnz     PHSM_FirstStep
   mov     ax, 002Ah
  PHSM_FirstStep:
   mov     PartSetup_HiddenX, al
   mov     PartSetup_HiddenAdd, ah

   ; Draw Menu...
   xor     dx, dx
   mov     PartSetup_HiddenUpper, dl
   call    PARTHIDESETUP_DrawMenuBase
   call    PARTHIDESETUP_RefreshPartitions
   ; Show Choice-Bar at DH...
   call    PARTHIDESETUP_BuildChoiceBar

   ; Now we got everything on-the-screen
  PHSM_MainLoop:
      mov     ah, 0
      int     16h
      cmp     ah, Keys_Up
      je      PHSM_KeyUp
      cmp     ah, Keys_Down
      je      PHSM_KeyDown
      cmp     ah, Keys_ESC
      je      PHSM_KeyESC
      cmp     ah, Keys_F1
      je      PHSM_KeyF1
      cmp     ah, Keys_Enter
      je      PHSM_KeyToogle
      cmp     ah, Keys_Plus
      je      PHSM_KeyToogle
      cmp     ah, Keys_Minus
      je      PHSM_KeyToogle
      cmp     ah, Keys_GrayPlus
      je      PHSM_KeyToogle
      cmp     ah, Keys_GrayMinus
      je      PHSM_KeyToogle
      cmp     ah, Keys_PageDown
      je      PHSM_KeyToogle
      cmp     ah, Keys_PageUp
      je      PHSM_KeyToogle
      ; ASCII values...
      cmp     al, Keys_Space
      je      PHSM_KeyToogle
      jmp     PHSM_MainLoop

  PHSM_KeyESC:
   ; Collect Hide-Partition-Config and put it into Hide-Table
   mov     dl, PartSetup_ActivePart
   call    PARTHIDESETUP_CollectHideConfigAndPutToTable
   ; Simply return to Partition Setup
   ret

  PHSM_KeyUp:
   dec     dh
   call    PARTHIDESETUP_BuildChoiceBar
   jmp     PHSM_MainLoop

  PHSM_KeyDown:
   inc     dh
   call    PARTHIDESETUP_BuildChoiceBar
   jmp     PHSM_MainLoop

  PHSM_KeyToogle:
   call    PART_GetPartitionPointer      ; Holt den Pointer der Partition (DL) nach SI
   mov     al, cs:[si+LocIPT_Flags]
   xor     al, Flags_SpecialMarker
   mov     cs:[si+LocIPT_Flags], al
   call    PARTHIDESETUP_DrawPartitionInfo
   call    PARTHIDESETUP_BuildChoiceBar
   jmp     PHSM_MainLoop

  PHSM_KeyF1:
   mov     bx, offset TXT_SETUPHELP_HideSetup
   call    SETUP_ShowHelp        ; Shows help
   jmp     PHSM_MainLoop
PARTHIDESETUP_Main              EndP

; Draw all standard-things for HiddenSetup, dynamic content not included.
PARTHIDESETUP_DrawMenuBase      Proc Near   Uses dx
   ; PartSetup_HiddenX1
   mov     cx, 0D05h                     ; Lila on lila
   call    VideoIO_Color
   mov     bh, 05h
   mov     bl, PartSetup_HiddenX
   mov     dh, 10h
   mov     dl, bl
   add     dl, 25h
   add     dl, PartSetup_HiddenAdd
   push    bx
      call    VideoIO_MakeWindow
   pop     bx
   ; --- Make Window-Header - "Hide Feature" at top frame-line
   inc     bl
   mov     cx, bx
   call    VideoIO_Locate
   mov     al, 'µ'
   call    VideoIO_PrintSingleChar
   mov     cx, 0E05h                     ; Yellow on Lila
   call    VideoIO_Color
   mov     si, offset TXT_SETUP_HideFeature
   call    VideoIO_Print
   mov     cx, 0D05h                     ; Lila on lila
   call    VideoIO_Color
   mov     al, 'Æ'
   call    VideoIO_PrintSingleChar
   ; --- Make Window-Footer - "State when booting..." at bottom right frame-line
   mov     dh, 10h
   mov     dl, PartSetup_HiddenX
   add     dl, 25h
   add     dl, PartSetup_HiddenAdd       ; Location 16, HiddenX->right aligned
   mov     si, offset TXT_SETUP_HideFeature2
   call    GetLenOfString                ; CX - Length of HideFeature2
   sub     dl, cl                        ; Adjust Position
   push    dx
      mov     dl, PartSetup_ActivePart
      call    PART_GetPartitionPointer   ; Holt den Pointer der Partition (DL) nach SI
   pop     dx
   ; Display "Label" field without ending NULs/Spaces
   add     si, LocIPT_Name
   mov     cx, 11
   call    GetLenOfName
   sub     dl, cl                        ; Adjust position
   sub     dl, 2
   push    cx si                         ; SI == Label Field
      mov     cx, dx
      call    VideoIO_Locate
      mov     al, '<'
      call    VideoIO_PrintSingleChar
      mov     si, offset TXT_SETUP_HideFeature2
      call    VideoIO_Print
   pop     si cx
   call    VideoIO_FixedPrint
   mov     al, '>'
   call    VideoIO_PrintSingleChar

;   inc     cl
;   call    MBR_Locate                    ; Location 16, HiddenX
;   mov     al, 'µ'
;   call    MBR_PrintSingleChar
;   mov     cx, 0E05h                     ; Yellow on Lila
;   call    MBR_Color
;   mov     si, offset TXT_SETUP_HideFeature2
;   call    MBR_Print
;   mov     dl, PartSetup_ActivePart
;   call    MBR_Part_GetPartitionPointer ; Holt den Pointer der Partition (DL) nach SI
;  ; Display "Label" field without ending NULs/Spaces
;   add     si, LocIPT_Name
;   mov     cx, 11
;   call    MBR_GetLenOfName
;   call    MBR_FixedPrint
;   mov     cx, 0D05h                     ; Lila on lila
;   call    MBR_Color
;   mov     al, 'Æ'
;   call    MBR_PrintSingleChar

   ; --- Make ':' Line down
   mov     cx, 0F05h                     ; Yellow on Lila
   call    VideoIO_Color
   mov     ch, 07h
   mov     cl, PartSetup_HiddenX
   add     cl, 24
   add     cl, PartSetup_HiddenAdd
   call    VideoIO_Locate
   mov     al, ':'
   mov     cl, 8
   call    VideoIO_Internal_MakeWinDown
   ret
PARTHIDESETUP_DrawMenuBase      EndP

; Draw all partitions to Hidden-Setup aka Dynamic Content-Draw
PARTHIDESETUP_RefreshPartitions Proc Near   Uses dx
   mov     dl, PartSetup_HiddenUpper
   mov     dh, 8
  PHSRP_Loop:
      call    PARTHIDESETUP_DrawPartitionInfo
      inc     dl
   dec     dh
   jnz     PHSRP_Loop
   ; At last calculate Scroll-Markers
   mov     cx, 0D05h                     ; Lila on lila
   call    VideoIO_Color
   mov     cx, 0603h                     ; 6, +3
   add     cl, PartSetup_HiddenX
   mov     dl, PartSetup_HiddenUpper
   call    PARTSETUP_UpperScrollMarker
   add     cl, 29
   add     cl, PartSetup_HiddenAdd       ; 6, +29
   call    PARTSETUP_UpperScrollMarker
   mov     cx, 0F03h                     ; 15, +3
   add     cl, PartSetup_HiddenX
   add     dl, 8                         ; add 8 -> points to last partition
   mov     dh, CFG_Partitions            ; Limit
   call    PARTSETUP_LowerScrollMarker
   add     cl, 29
   add     cl, PartSetup_HiddenAdd       ; 6, +29
   call    PARTSETUP_LowerScrollMarker
   ret
PARTHIDESETUP_RefreshPartitions EndP

PARTHIDESETUP_DrawPartitionInfo Proc Near   Uses dx
   local NoOfPart :byte
   mov     ch, dl
   sub     ch, PartSetup_HiddenUpper
   add     ch, 7
   mov     cl, 2
   add     cl, PartSetup_HiddenX
   ; We got location
   mov     NoOfPart, dl
   call    VideoIO_Locate

   ; Clean data-area...
   push    cx
      mov     al, ' '
      mov     cl, 22
      call    VideoIO_PrintSingleMultiChar
   pop     cx

   cmp     dl, CFG_Partitions
   jae     PHSDPI_NoData

   call    PART_GetPartitionPointer      ; Holt den Pointer der Partition (DL) nach SI
   call    VideoIO_Locate
   push    cx
      ; Display "Label" field aka "OS2" without ending NULs/Spaces
      mov     cx, 0F05h
      call    VideoIO_Color              ; Bright White on Lila
      push    si
         add     si, LocIPT_Name
         mov     cx, 11
         call    GetLenOfName
         call    VideoIO_FixedPrint
      pop     si
      mov     cx, 0D05h
      call    VideoIO_Color              ; Bright Lila on Lila
      mov     al, ' '
      call    VideoIO_PrintSingleChar
      mov     al, '['
      call    VideoIO_PrintSingleChar
      ; Display "Type" field aka "HPFS" without ending NULs/Spaces
      push    si
         mov     al, cs:[si+LocIPT_SystemID]
         call    PART_SearchFileSysName
         mov     cx, 8
         call    GetLenOfName
         call    VideoIO_FixedPrint
      pop     si
      mov     al, ']'
      call    VideoIO_PrintSingleChar
   pop     cx
   add     cl, 24
   add     cl, PartSetup_HiddenAdd
   call    VideoIO_Locate
   push    cx
      mov     cx, 0E05h
      call    VideoIO_Color              ; Yellow on Lila
      mov     al, ' '
      mov     cl, 10
      call    VideoIO_PrintSingleMultiChar ; Fill up area with spaces
      ; Finally draw Hidden/Unhidden
      mov     bl, cs:[si+LocIPT_Flags]
      mov     si, offset TXT_SETUP_MAGIC_Unhidden
      and     bl, Flags_SpecialMarker
      jz      PHSDPI_IsNotHidden
      mov     si, offset TXT_SETUP_MAGIC_Hidden
     PHSDPI_IsNotHidden:
      call    GetLenOfString
      mov     dx, cx
   pop     cx
   add     cx, 10
   sub     cx, dx
   call    VideoIO_Locate
   call    VideoIO_Print
  PHSDPI_NoData:
   ret
PARTHIDESETUP_DrawPartitionInfo EndP

;        In: DL - Current Active (to be inactivated)
;            DH - New Active (to be activated)
; Destroyed: None
PARTHIDESETUP_BuildChoiceBar    Proc Near   Uses
   cmp     dl, dh
   je      PHSBCB_SkipRetrace
   call    VideoIO_WaitRetrace
  PHSBCB_SkipRetrace:

   ; Deactivate current active bar
   mov     cl, 5Eh                       ; Yellow on Lila
   call    PARTHIDESETUP_ReColorPart

   ; Running Fixing 
   cmp     dh, 0FFh
   jne     PHSBCB_NoUnderflow
   xor     dh, dh
  PHSBCB_NoUnderflow:
   cmp     dh, CFG_Partitions
   jb      PHSBCB_NoOverflow
   mov     dh, CFG_Partitions
   dec     dh
  PHSBCB_NoOverflow:
   mov     dl, dh

   ; Do we need to scroll ?
   mov     al, PartSetup_HiddenUpper
   cmp     dl, al
   jb      PHSBCB_YesScrolling
   add     al, 8
   cmp     dl, al
   jb      PHSBCB_NoScrolling
   mov     al, dl
   sub     al, 7
   mov     PartSetup_HiddenUpper, al
   call    PARTHIDESETUP_RefreshPartitions
   jmp     PHSBCB_NoScrolling
  PHSBCB_YesScrolling:
   mov     al, dl
   mov     PartSetup_HiddenUpper, al
   call    PARTHIDESETUP_RefreshPartitions
  PHSBCB_NoScrolling:

   ; Activate fresh active bar
   mov     cl, 1Fh                       ; Bright White on Blue
   call    PARTHIDESETUP_ReColorPart
   ; Now DL==DH
   ret
PARTHIDESETUP_BuildChoiceBar    EndP

;        In: CL - Color, DL - Partition
; Destroyed: None, but Locate-Pointer
PARTHIDESETUP_ReColorPart       Proc Near   Uses bx cx es di
   mov     bh, cl     ; Color to BH
   ; First calculate location of bar
   cmp     dl, PartSetup_HiddenUpper
   jb      PHSRCP_NotInWindowView
   mov     ch, dl
   sub     ch, PartSetup_HiddenUpper     ; CH - Position relative to HiddenUpper
   cmp     ch, 8                         ; 8 - Maximum Total in Window
   jae     PHSRCP_NotInWindowView
   add     ch, 7
   mov     cl, 26
   add     cl, PartSetup_HiddenX
   add     cl, PartSetup_HiddenAdd

   mov     bl, 10                        ; Length of Bar is 10
   call    VideoIO_Locate                ; geht zu CX
   call    VideoIO_Internal_SetRegs
   inc     di         ; DI - Destination+1 -> Color-Byte
   mov     cl, bl     ; Length of Bar is always 39
  PHSRCP_ClearLoop:
      mov     es:[di], bh
      add     di, 2
   dec     cl
   jnz     PHSRCP_ClearLoop
  PHSRCP_NotInWindowView:
   ret
PARTHIDESETUP_ReColorPart       EndP

; =============================================================================

; This is called by MBRS_PS_HiddenSetup
;        In: DL - Partition, where to save Hide-Config
; Destroyed: None, but Locate-Pointer
PARTHIDESETUP_GetHideConfigAndSpread Proc Near Uses ax dx si di
   ; First check HideFeature-Flag on selected partition.
   ;  if it's not set, don't do anything...
   call    PART_GetPartitionPointer      ; Holt den Pointer der Partition (DL) nach SI
   mov     al, cs:[si+LocIPT_Flags]
   test    al, Flags_HideFeature
   jz      PHSGHCAS_EndOfEntries
  PHSGHCAS_SomethingHidden:
   ; Calculate, where to get Hide-Config
   mov     ax, LocIPT_MaxPartitions
   mul     dl
   mov     di, offset HidePartitionTable
   add     di, ax                        ; We got the pointer
   ; So process Hide-Config. Read out Byte-Entries, each points to a partition
   ;  0FFh is end-marker / maximum entries = CFG_Partitions
   mov     cl, CFG_Partitions
  PHSGHCAS_SpreadLoop:
      mov     dl, cs:[di]
      inc     di
      cmp     dl, 0FFh
      je      PHSGHCAS_EndOfEntries
      call    PART_GetPartitionPointer   ; Pointer for partition DL to SI
      mov     al, cs:[si+LocIPT_Flags]
      or      al, Flags_SpecialMarker    ; Set marker
      mov     cs:[si+LocIPT_Flags], al
   dec     cl
   jnz     PHSGHCAS_SpreadLoop
  PHSGHCAS_EndOfEntries:
   ret
PARTHIDESETUP_GetHideConfigAndSpread EndP

; This is called by MBRS_PS_HiddenSetup
;        In: DL - Partition, where to save Hide-Config
; Destroyed: None, but Locate-Pointer
PARTHIDESETUP_CollectHideConfigAndPutToTable Proc Near Uses ax si es di
   ; First calculate, where to put Hide-Config
   mov     ax, LocIPT_MaxPartitions
   mul     dl
   push    cs
   pop     es
   mov     di, offset HidePartitionTable
   add     di, ax                        ; We got the pointer
   push    di di
      mov     cx, LocIPT_MaxPartitions
      mov     al, 0FFh
      rep     stosb                      ; Fill up with FFh
   pop     di
      ; Now walk through the IPT collecting all SpecialMarkers
      ;  For each do a byte-entry containing the number of the partition
      mov     si, offset PartitionTable
      xor     ch, ch
      mov     cl, CFG_Partitions
     PHSCHCAPTT_CollectLoop:
         mov     bl, cs:[si+LocIPT_Flags]
         test    bl, Flags_SpecialMarker
         jz      PHSCHCAPTT_NoMarker
         mov     ds:[di], ch             ; Write byte-Entry
         inc     di
         xor     bl, Flags_SpecialMarker ; Reset Flag
         mov     cs:[si+LocIPT_Flags], bl
        PHSCHCAPTT_NoMarker:
         add     si, LocIPT_LenOfIPT
      inc     ch
      dec     cl
      jnz     PHSCHCAPTT_CollectLoop
   pop     si                            ; Original Hide-Config Pointer -> SI
   ; Now check, if we have written anything
   cmp     si, di
   jne     PHSCHCAPTT_SomethingToHide
   ; Nothing to hide...so UNSET the Hidden-Feature Flag
   call    PART_GetPartitionPointer      ; Holt den Pointer der Partition (DL) nach SI
   mov     al, cs:[si+LocIPT_Flags]
   mov     ah, Flags_HideFeature
   not     ah
   and     al, ah
   mov     cs:[si+LocIPT_Flags], al
   ret

  PHSCHCAPTT_SomethingToHide:
   mov     ax, si
   add     ax, LocIPT_MaxPartitions
   cmp     di, ax
   jae     PHSCHCAPTT_AllUsed
   ; Set END-marker
   mov     al, 0FFh
   stosb                                 ; Write byte-Entry
  PHSCHCAPTT_AllUsed:

   ; Something to hide...so SET the Hidden-Feature Flag
   call    PART_GetPartitionPointer      ; Holt den Pointer der Partition (DL) nach SI
   mov     al, cs:[si+LocIPT_Flags]
   or      al, Flags_HideFeature
   mov     cs:[si+LocIPT_Flags], al
   ret
PARTHIDESETUP_CollectHideConfigAndPutToTable EndP

; =============================================================================

; This is called from MBRS_Routines_PartitionSetup
;        In: DL - Partition to LogicalDriveLetter-Setup
; Destroyed: ax
PARTSETUP_DriveLetterSetup      Proc Near  Uses dx si es di
   call    PART_GetPartitionPointer      ; Gets the PartitionPointer for DL in SI
   cmp     bptr cs:[si+LocIPT_SystemID], 06h ; Hardcoded FAT16
   je      PSDLS_GotLDLP
   cmp     bptr cs:[si+LocIPT_SystemID], 07h ; Hardcoded HPFS
   je      PSDLS_GotLDLP

   ; Drive-Letter feature only possible on HPFS/FAT16 (OS/2) systems
   mov     cx, 0C04h
   mov     si, offset TXT_SETUP_NoLDLpartition
   call    SETUP_ShowErrorBox
   ret

  PSDLS_GotLDLP:
   ; First build up menu and display current setting...
   call    PARTSETUPDL_DrawMenuBase      ; DL - partition-no

   ; Now get the Logical-Drive-Letter for that partition...
   movzx   bx, dl
   mov     dl, bptr [DriveLetters+bx]

   push    bx
      ; DS:SI - IPT Entry of Partition, DL - LogicalDriveLetter
      call    PARTSETUPDL_DrawDriveLetter

      ; Now we got everything on-the-screen
     PSDLS_MainLoop:
         mov     ah, 0
         int     16h
         cmp     ah, Keys_Up
         je      PSDLS_KeyUp
         cmp     ah, Keys_Down
         je      PSDLS_KeyDown
         cmp     ah, Keys_ESC
         je      PSDLS_KeyDONE
         cmp     ah, Keys_Enter
         je      PSDLS_KeyDONE
         ; Direct-Letter-Input
         or      al, 20h                 ; Lower-Case Input
         cmp     al, 'c'
         jb      PSDLS_MainLoop
         cmp     al, 'z'
         ja      PSDLS_MainLoop
         mov     dl, al
         add     dl, 1Dh                 ; -> Convert to used logic
         call    PARTSETUPDL_DrawDriveLetter
         jmp     PSDLS_MainLoop

     PSDLS_KeyUp:
      dec     dl
      cmp     dl, 7Fh
      jne     PSDLS_KeyUpFix1
      xor     dl, dl
     PSDLS_KeyUpFix1:
      cmp     dl, 97h
      jbe     PSDLS_KeyUpFix2
      mov     dl, 97h
     PSDLS_KeyUpFix2:
      call    PARTSETUPDL_DrawDriveLetter
      jmp     PSDLS_MainLoop

     PSDLS_KeyDown:
      inc     dl
      cmp     dl, 97h
      jbe     PSDLS_KeyDownFix1
      xor     dl, dl
     PSDLS_KeyDownFix1:
      cmp     dl, 01h
      jne     PSDLS_KeyDownFix2
      mov     dl, 80h
     PSDLS_KeyDownFix2:
      call    PARTSETUPDL_DrawDriveLetter
      jmp     PSDLS_MainLoop

  PSDLS_KeyDONE:
   ; Write Drive-Letter into DriveLetter-Table
   pop     bx
   mov     bptr [DriveLetters+bx], dl
   mov     al, ds:[si+LocIPT_Flags]
   mov     ah, Flags_DriveLetter
   not     ah
   and     al, ah
   or      dl, dl
   jz      PSDLS_NoFlag
   or      al, Flags_DriveLetter
  PSDLS_NoFlag:
   mov     ds:[si+LocIPT_Flags], al
   ret
PARTSETUP_DriveLetterSetup      EndP

; Draw all standard-things for DriveLetterSetup, dynamic content not included.
PARTSETUPDL_DrawMenuBase        Proc Near   Uses dx si
   ; Calculate Position of Window.
   ; If Partition Selected Left-Side -> go Right-Sided Window
   ;                                     otherwise Left-Sided.
   mov     PartSetup_ActivePart, dl
   mov     al, 8                         ; X-Pos =  8
   and     dl, 1
   jnz     PSDLDMB_FirstStep
   mov     al, 30h                       ; X-Pos = 48
  PSDLDMB_FirstStep:
   mov     PartSetup_HiddenX, al

   ; Draw base-window
   mov     cx, 0D05h                     ; Lila on lila
   call    VideoIO_Color
   mov     bh, 06h
   mov     bl, PartSetup_HiddenX
   mov     dh, 0Ah
   mov     dl, bl
   add     dl, 16h
   push    bx
      call    VideoIO_MakeWindow
   pop     bx
   ; Make Window-Header
   inc     bl
   push    bx
      mov     cx, bx
      call    VideoIO_Locate
      mov     al, 'µ'
      call    VideoIO_PrintSingleChar
      mov     cx, 0E05h                  ; Yellow on Lila
      call    VideoIO_Color
      mov     si, offset TXT_SETUP_DriveLetter
      call    VideoIO_Print
      mov     cx, 0D05h                  ; Lila on lila
      call    VideoIO_Color
      mov     al, 'Æ'
      call    VideoIO_PrintSingleChar
   pop     bx
   ; Display help-information
   mov     si, offset TXT_SETUPHELP_DriveLetter
   mov     cx, 0D05h                     ; Lila on lila
   call    VideoIO_Color

   call    GetLenOfString                ; CX - Len of string
   mov     dx, cx
   mov     cx, bx
   add     cx, 0413h
   sub     cl, dl
   call    VideoIO_Locate
   mov     al, '<'
   call    VideoIO_PrintSingleChar
   call    VideoIO_Print
   mov     al, '>'
   call    VideoIO_PrintSingleChar
   ; 
   mov     cx, 0F01h                     ; Bright White on Blue
   call    VideoIO_Color
   mov     cx, 0805h                     ; Position 8, 5
   add     cl, PartSetup_HiddenX
   call    VideoIO_Locate
   mov     al, ' '
   mov     cl, 12
   call    VideoIO_PrintSingleMultiChar
   ret
PARTSETUPDL_DrawMenuBase        EndP

; Writes Logical Drive-Letter to Screen (Logical-Drive-Letter-Setup)
;        In: DL - Logical Drive-Letter Byte
; Destroyed: None
PARTSETUPDL_DrawDriveLetter     Proc Near   Uses si
   ; 00h -> standard drive letter
   ; 80h -> use C: as drive letter
   ; 97h -> use Z: as drive letter
   push    dx
      mov     cx, 0805h                  ; Position 8, 5
      add     cl, PartSetup_HiddenX
      call    VideoIO_Locate
      add     cl, 6                      ; Everything centered (12/2)
      push    cx
         mov     al, ' '
         mov     cl, 12
         call    VideoIO_PrintSingleMultiChar ; Fill up area with spaces

         or      dl, dl
         jnz     PSDLDDL_Letter
         mov     si, offset TXT_SETUP_MAGIC_Disabled
         call    GetLenOfString
         mov     dx, cx
      pop     cx
      call    VideoIO_LocateToCenter     ; LocateToCenter using TotalLen
      call    VideoIO_Print
   pop     dx
   ret

        PSDLDDL_Letter:
         mov     si, offset TXT_SETUP_MAGIC_Set
         call    GetLenOfString
         mov     dx, cx
         add     dx, 2
      pop     cx
      call    VideoIO_LocateToCenter     ; LocateToCenter using TotalLen
      call    VideoIO_Print
   pop     dx
   mov     al, dl
   sub     al, 3Dh
   call    VideoIO_PrintSingleChar
   mov     al, ':'
   call    VideoIO_PrintSingleChar
   ret
PARTSETUPDL_DrawDriveLetter     EndP
