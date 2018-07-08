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
;                                                      AiR-BOOT / BOOT-MENU
;---------------------------------------------------------------------------

IFDEF   MODULE_NAMES
DB 'BOOTMENU',0
ENDIF

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

CLR_COPYRIGHT_CLASSIC   = 0f00h
CLR_COPYRIGHT_BM  = 0700h

BOOTMENU_BuildMain              Proc Near   Uses es di
   ; 1st line with Copyright information...
   mov     cx, 0101h
   call    VideoIO_Locate
   mov     cx, CLR_COPYRIGHT_BM
   call    VideoIO_Color
   mov     si, offset Copyright
   call    VideoIO_Print                 ; Print Copyright Line...



; Boot-Window... -- background color -- still need to adjust item-bg
CLR_BOOT_WINDOW_CLASSIC = 0901h
CLR_BOOT_WINDOW_BM      = 0701h
CLR_BOOT_WINDOW_TB      = 0708h
IFDEF TESTBUILD
CLR_BOOT_WINDOW = CLR_BOOT_WINDOW_TB
ELSE
CLR_BOOT_WINDOW = CLR_BOOT_WINDOW_BM
ENDIF

   mov     cx, CLR_BOOT_WINDOW
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
   cmp     byte ptr [CFG_BootMenuActive], 2
   jne     BMBM_NoDetailed1
   mov     dl, 15h
  BMBM_NoDetailed1:
   mov     Menu_AbsoluteX, dl



; Display Top-Infos (labels) in Boot-Window
CLR_TOP_INFOS_CLASSIC = 0b01h
CLR_TOP_INFOS_BM      = 0301h
CLR_TOP_INFOS_TB      = 0308h
IFDEF TESTBUILD
CLR_TOP_INFOS = CLR_TOP_INFOS_TB
ELSE
CLR_TOP_INFOS = CLR_TOP_INFOS_BM
ENDIF

   mov     cx, CLR_TOP_INFOS
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
   cmp     byte ptr [CFG_BootMenuActive], 2
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
CLR_SEP_VERT_LINES_CLASSIC  = 0901h
CLR_SEP_VERT_LINES_BM       = 0701h
CLR_SEP_VERT_LINES_TB       = 0708h
IFDEF TESTBUILD
CLR_SEP_VERT_LINES = CLR_SEP_VERT_LINES_TB
ELSE
CLR_SEP_VERT_LINES = CLR_SEP_VERT_LINES_BM
ENDIF

   mov     cx, CLR_SEP_VERT_LINES
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
      cmp     byte ptr [CFG_BootMenuActive], 2
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
      cmp     byte ptr [CFG_BootMenuActive], 2
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



CLR_INFO_WINDOW_CLASSIC = 0c04h
CLR_INFO_WINDOW_BM      = 0701h
CLR_INFO_WINDOW_TB      = 0708h
IFDEF TESTBUILD
CLR_INFO_WINDOW = CLR_INFO_WINDOW_TB
ELSE
CLR_INFO_WINDOW = CLR_INFO_WINDOW_BM
ENDIF

   mov     cx, CLR_INFO_WINDOW
   ;mov     cx, 0C06h ; brown, main background
   call    VideoIO_Color                    ; Color info window

   mov     bx, 1401h
   mov     dx, 1950h
   call    VideoIO_MakeWindow               ; Information-Window
   ; den kleinen Strich...
   mov     cx, 1602h
   call    VideoIO_Locate
   mov     al, TextChar_WinLineRight
   mov     cl, 78
   call    VideoIO_Internal_MakeWinRight

   call    BOOTMENU_BuildTimedBootText

   mov     cx, 1703h
   call    VideoIO_Locate



CLR_INFO_TEXT_CLASSIC = 0f04h
CLR_INFO_TEXT_BM      = 0701h
CLR_INFO_TEXT_TB      = 0708h
IFDEF TESTBUILD
CLR_INFO_TEXT = CLR_INFO_TEXT_TB
ELSE
CLR_INFO_TEXT = CLR_INFO_TEXT_BM
ENDIF

   mov     cx, CLR_INFO_TEXT            ; Info text
   call    VideoIO_Color                    ; Color info text

   mov     si, offset TXT_BootMenuHelpText1
   call    VideoIO_Print
   mov     cx, 1803h
   call    VideoIO_Locate
   mov     si, offset TXT_BootMenuHelpText2
   call    VideoIO_Print



CLR_F10_SETUP_CLASSIC   = 0c04h
CLR_F10_SETUP_BM        = 0901h
CLR_F10_SETUP_TB        = 0908h
IFDEF TESTBUILD
CLR_F10_SETUP = CLR_F10_SETUP_TB
ELSE
CLR_F10_SETUP = CLR_F10_SETUP_BM
ENDIF

   mov     cx, CLR_F10_SETUP                            ; background F10 enter Setup
   call    VideoIO_Color

   ; Additional message how to power off system
   mov     si, offset TXT_BootMenuPowerOff
   call    GetLenOfString
   mov     dx, 1902h
   ;~ sub     dl, cl
   mov     cx, dx
   call    VideoIO_Locate
   mov     al, TextChar_WinRep4
   call    VideoIO_PrintSingleChar
   call    VideoIO_Print
   mov     al, TextChar_WinRep5
   call    VideoIO_PrintSingleChar


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



CLR_GOODBYE_WINDOW_CLASSIC  = 0d05h
CLR_GOODBYE_WINDOW_BM       = 0f01h
CLR_GOODBYE_WINDOW_TB       = 0f01h
IFDEF TESTBUILD
CLR_GOODBYE_WINDOW = CLR_GOODBYE_WINDOW_TB
ELSE
CLR_GOODBYE_WINDOW = CLR_GOODBYE_WINDOW_BM
ENDIF

   mov     cx, CLR_GOODBYE_WINDOW
   call    VideoIO_Color
   mov     bx, 0101h
   mov     dx, 0550h
   call    VideoIO_MakeWindow            ; Information-Window
   xor     di, di
   mov     cx, 10
   mov     ax, 0720h
   rep     stosw
   mov     di, 162
   mov     cx, 9
   mov     al, WinCharRight

   ; Little part before version in goodbye-window
   ; Does not use color-function
   ;mov     ah, 05Dh
   mov     ah, 01fh
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



CLR_GOODBYE_AB_VERSION_CLASSIC  = 0e01h
CLR_GOODBYE_AB_VERSION_BM       = 0e03h
CLR_GOODBYE_AB_VERSION_TB       = 0e03h
IFDEF TESTBUILD
CLR_GOODBYE_AB_VERSION = CLR_GOODBYE_AB_VERSION_TB
ELSE
CLR_GOODBYE_AB_VERSION = CLR_GOODBYE_AB_VERSION_BM
ENDIF

   mov     cx, CLR_GOODBYE_AB_VERSION
   call    VideoIO_Color
   mov     si, offset Copyright
   mov     cl, 11+CopyrightVersionLen
   call    VideoIO_FixedPrint

   mov     cx, CLR_GOODBYE_WINDOW_BM

   call    VideoIO_Color
   mov     al, TextChar_WinRep5
   call    VideoIO_PrintSingleChar
   mov     cx, 020Dh
   call    VideoIO_Locate



CLR_GOODBYE_WINDOW_CLASSIC_2    = 0f05h
CLR_GOODBYE_WINDOW_BM_2         = 0701h
CLR_GOODBYE_WINDOW_TB_2         = 0701h
IFDEF TESTBUILD
CLR_GOODBYE_WINDOW_2 = CLR_GOODBYE_WINDOW_TB_2
ELSE
CLR_GOODBYE_WINDOW_2 = CLR_GOODBYE_WINDOW_BM_2
ENDIF

   mov     cx,  CLR_GOODBYE_WINDOW_2
   call    VideoIO_Color
   inc     si
   call    VideoIO_Print                 ; Print Copyright to the end...
   mov     cx, 0303h
   call    VideoIO_Locate
   mov     si, offset BootEndMsg         ; Print End-Message...
   call    VideoIO_Print
   mov     cx, 0403h
   call    VideoIO_Locate
   mov     si, offset BootEndMsg2        ; Print GPL-Message...
   call    VideoIO_Print
   ; -------------------------------------------
   mov     ah, 02h
   mov     bh, 00h
   mov     dx, 0600h                     ; Sets cursor location to 7, 1
   int     10h
   call    VideoIO_CursorOn
   ret
BOOTMENU_BuildGoodBye           EndP



; Must preserve AX!
BOOTMENU_BuildTimedBootText     Proc Near   Uses ax cx si es di
   mov     cx, 1503h ;
   call    VideoIO_Locate



CLR_NON_TIMED_BAR_CLASSIC   = 0e04h
CLR_NON_TIMED_BAR_BM        = 0701h
CLR_NON_TIMED_BAR_TB        = 0708h
IFDEF TESTBUILD
CLR_NON_TIMED_BAR = CLR_NON_TIMED_BAR_TB
ELSE
CLR_NON_TIMED_BAR = CLR_NON_TIMED_BAR_BM
ENDIF

   mov     cx, CLR_NON_TIMED_BAR                      ; non-timed time bar
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



CLR_TIMED_BAR_CLASSIC   = 0e04h
CLR_TIMED_BAR_BM        = 0e04h
CLR_TIMED_BAR_TB        = 0e04h
IFDEF TESTBUILD
CLR_TIMED_BAR = CLR_TIMED_BAR_TB
ELSE
CLR_TIMED_BAR = CLR_TIMED_BAR_BM
ENDIF

   mov     cx, CLR_TIMED_BAR ; timed time bar, yellow on red
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



CLR_VOLUME_INDEX_CLASSIC    = 0f01h
CLR_VOLUME_INDEX_BM         = 0f01h
CLR_VOLUME_INDEX_TB         = 0f08h
IFDEF TESTBUILD
CLR_VOLUME_INDEX = CLR_VOLUME_INDEX_TB
ELSE
CLR_VOLUME_INDEX = CLR_VOLUME_INDEX_BM
ENDIF

; Writes Partition-Information to Screen (Boot-Menu)
;        In: CH - Line to print info
;            DL - Number of Partition (Base=0)
; Destroyed: None
BOOTMENU_BuildPartitionText     Proc Near   Uses ax cx dx si
   local PartPointer:word

   call    PART_GetPartitionPointer     ; Gets pointer to partition (DL) -> SI
   mov     [PartPointer], si            ; SI now points to the IPT-entry

   ; === Display Boot-Number ===
   mov     cl, Menu_AbsoluteX
   mov     dh, cl
   call    VideoIO_Locate
   mov     cx, CLR_VOLUME_INDEX                     ; Bwhite, blue
   call    VideoIO_Color
   mov     al, dl
   inc     al
   call    VideoIO_PrintByteNumber

   ; === Display Drive-Number and Size (Size only in detailed view) ===
   add     dh, 5
   ;movzx   cx, dh
   mov   cl,dh
   mov   ch,0

   call    VideoIO_Locate



CLR_HD_INDEX_CLASSIC    = 0d01h
CLR_HD_INDEX_BM         = 0701h
CLR_HD_INDEX_TB         = 0708h
IFDEF TESTBUILD
CLR_HD_INDEX = CLR_HD_INDEX_TB
ELSE
CLR_HD_INDEX = CLR_HD_INDEX_BM
ENDIF

   mov     cx, CLR_HD_INDEX
   call    VideoIO_Color                 ; Violet, blue
   mov     si, [PartPointer]
   mov     al, [si+LocIPT_Drive]
   sub     al, 7Fh                       ; Will only display numbers up to 99,
   call    VideoIO_PrintByteNumber       ;  so only showing harddrives...
   add     dh, 5
   cmp     byte ptr [CFG_BootMenuActive], 2
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



CLR_HD_SIZE_CLASSIC = 0501h
CLR_HD_SIZE_BM      = 0701h
CLR_HD_SIZE_TB      = 0708h
IFDEF TESTBUILD
CLR_HD_SIZE = CLR_HD_SIZE_TB
ELSE
CLR_HD_SIZE = CLR_HD_SIZE_BM
ENDIF

      mov     cx, CLR_HD_SIZE
      call    VideoIO_Color              ; Dark-Violet, Blue
      mov     al, '/'
      call    VideoIO_PrintSingleChar
      mov     cx, CLR_HD_SIZE
      call    VideoIO_Color              ; Violet, Blue
      mov     ax, [PartPointer]            ; Get Size-Element from PartPtr (AX)
      call    PART_GetSizeElementPointer ; DS:SI -> Size-Element...
      mov     cl, 4
      call    VideoIO_FixedPrint         ; Display 4 chars from DS:SI
      inc     TextPosX                   ; Manual-Hackin to adjust TextPos
      mov     cl, 2
      call    VideoIO_FixedPrint         ; Display 2 chars from DS:SI
  BMBPT_NoDetailed:

   ; === Display Label ===
   ;movzx   cx, dh
   mov   cl,dh
   mov   ch,0

   call    VideoIO_Locate



CLR_LABEL_CLASSIC   = 0e01h
CLR_LABEL_BM        = 0f01h
CLR_LABEL_TB        = 0f08h
IFDEF TESTBUILD
CLR_LABEL = CLR_LABEL_TB
ELSE
CLR_LABEL = CLR_LABEL_BM
ENDIF

   mov     cx, CLR_LABEL
   call    VideoIO_Color                 ; Yellow, blue
   mov     si, [PartPointer]
   add     si, LocIPT_Name
   mov     cl, 11
   call    VideoIO_FixedPrint

   ; === Display Type ===
   add     dh, 14
   ;movzx   cx, dh
   mov   cl,dh
   mov   ch,0

   call    VideoIO_Locate
   mov     si, [PartPointer]
   mov     al, [si+LocIPT_SystemID]
   call    PART_SearchFileSysName



CLR_FS_NAME_CLASSIC = 0c01h
CLR_FS_NAME_BM      = 0701h
CLR_FS_NAME_TB      = 0708h
IFDEF TESTBUILD
CLR_FS_NAME = CLR_FS_NAME_TB
ELSE
CLR_FS_NAME = CLR_FS_NAME_BM
ENDIF

   mov     cx, CLR_FS_NAME
   call    VideoIO_Color                 ; Hrot, Blau
   mov     cl, 8
   call    VideoIO_FixedPrint



; Color for drive-letter
CLR_DL_CLASSIC  = 0f01h
CLR_DL_BM       = 0f01h
CLR_DL_TB       = 0f08h
IFDEF TESTBUILD
CLR_DL = CLR_DL_TB
ELSE
CLR_DL = CLR_DL_BM
ENDIF



; Color for hidden drive-letter
CLR_DL_HIDDEN_CLASSIC   = 0701h
CLR_DL_HIDDEN_BM        = 0701h
CLR_DL_HIDDEN_TB        = 0708h
IFDEF TESTBUILD
CLR_DL_HIDDEN = CLR_DL_HIDDEN_TB
ELSE
CLR_DL_HIDDEN = CLR_DL_HIDDEN_BM
ENDIF

DRIVELETTERS_ENABLE     EQU

    IFDEF   DRIVELETTERS_ENABLE

        ;
        ; THIS IS WHERE WE CAN SHOW DRIVE-LETTERS !
        ;

        pusha

        mov     al,[CFG_MiscFlags]
        and     al,00000001b
        jz      skip_show_dl


        ; Dirty hack to pad remaining line with spaces.
        ; Should be implemented in scrolling routine.
        push    word ptr [TextPosY]             ; Quick save X,Y position
        mov     al, ' '                         ; Filler
        mov     cl, 79                          ; Index of last column
        sub     cl, byte ptr [TextPosX]         ; Calculate padding length
        call    VideoIO_PrintSingleMultiChar    ; Do the padding
        pop     word ptr [TextPosY]             ; Quick restore X,Y position

        ; Get AiR-BOOT system-ID to see if drive-letters need to be shown
        mov     si, [PartPointer]
        mov     ah, [si+LocIPT_SystemID]

IFDEF   AUX_DEBUG
        IF 0
        pushf
        pusha
            mov     al, ' '
            call    VideoIO_PrintSingleChar
            mov     al, ah
            call    VideoIO_PrintHexByte
            mov     al, ' '
            call    VideoIO_PrintSingleChar
        popa
        popf
        ENDIF
ENDIF

        ; Only show drive-letters when partition is HPFS or JFS
        mov     al, ah          ; AiR-BOOT system-ID in AL
        cmp     al, 07h         ; Is HPFS ?
        je      show_dl         ; Yep, show drive-letters
        cmp     al, 0fch        ; Is JFS ?
        je      show_dl         ; Yep, show drive-letters

        jmp     skip_show_dl    ; No HPFS or JFS, skip show drive-letters

    show_dl:

        ;~ mov     al, ' '
        ;~ call    VideoIO_PrintSingleChar

        mov     dl, byte ptr [si+LocIPT_Drive]
        mov     ax, [si+LocIPT_AbsoluteBegin+00h]
        mov     bx, [si+LocIPT_AbsoluteBegin+02h]

        mov     si, offset [TmpSector]
        mov     di,ds
        call    DriveIO_ReadSectorLBA
        mov     al, [si+25h]

IFDEF   AUX_DEBUG
        IF 0
        pushf
        pusha
            call    VideoIO_PrintHexByte
        popa
        popf
        ENDIF
ENDIF

        mov     dh,al
        sub     dh,3dh

        mov     si, [PartPointer]
        call    LVM_GetDriveLetter

IF 0
                ; Print values at start of LVM-record
                pushf
                pusha
                mov     si, offset [LVMSector]
                lodsw
                call    VideoIO_PrintHexWord
                lodsw
                call    VideoIO_PrintHexWord
                popa
                popf
ENDIF
        jc      skip_show_dl

        test    al,al
        jnz     show_dl2



        mov     si, offset [dl_hidden]
        mov     cx, CLR_DL
        call    VideoIO_Color
        call    VideoIO_Print

        mov     cx, CLR_DL_HIDDEN
        call    VideoIO_Color

        mov     al, dh
        call    VideoIO_PrintSingleChar
        mov     al, ':'
        call    VideoIO_PrintSingleChar

        jmp     skip_show_dl

    show_dl2:

        mov     si, offset [dl_text]

        call    VideoIO_Print

        mov     cx, CLR_DL
        call    VideoIO_Color

        call    VideoIO_PrintSingleChar
        mov     al,':'
        call    VideoIO_PrintSingleChar

    skip_show_dl:
        popa

    ENDIF


   ret
BOOTMENU_BuildPartitionText     EndP

IF  NOT BLD_LANG_TXT EQ 'es'
; Drive-Letter indication for OS/2 partitions
dl_text     db  '   on drive ',0
dl_hidden   db  '   hidden   ',0
ENDIF

;        In: DL - Active Partition
;            DH - New Active Partition (may not be correct number)
;       Out: DX - will get returned (fixed, if needed)
BOOTMENU_BuildChoiceBar         Proc near   Uses ax es di

   ;call  SOUND_Beep

   call    VideoIO_WaitRetrace


   ;call  SOUND_Beep



; SELECTION BAR REDRAW
CLR_SELECTION_BAR_REDRAW_CLASSIC    = 10h
CLR_SELECTION_BAR_REDRAW_BM         = 10h
CLR_SELECTION_BAR_REDRAW_TB         = 80h
IFDEF TESTBUILD
CLR_SELECTION_BAR_REDRAW = CLR_SELECTION_BAR_REDRAW_TB
ELSE
CLR_SELECTION_BAR_REDRAW = CLR_SELECTION_BAR_REDRAW_BM
ENDIF

   mov     cl, CLR_SELECTION_BAR_REDRAW    ; Color BROWN, Partition DL
   call    BOOTMENU_ReColorPart

   ;call  SOUND_Beep

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
   dec     byte ptr [Menu_UpperPart]    ; Adjusted for Wasm
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
   inc     byte ptr [Menu_UpperPart]    ; Adjusted for Wasm
   cmp     dh, cl
   jae     BMBCB_ScrollingDown
   call    BOOTMENU_RefreshPartitionText



; SELECTION BAR
CLR_SELECTION_BAR_CLASSIC   = 50h
CLR_SELECTION_BAR_BM        = 90h
CLR_SELECTION_BAR_WARNING   = 40h
CLR_SELECTION_BAR_TB        = 60h
IFDEF TESTBUILD
CLR_SELECTION_BAR = CLR_SELECTION_BAR_TB
ELSE
CLR_SELECTION_BAR = CLR_SELECTION_BAR_BM
ENDIF


  BMBCB_AfterScrolling:
   mov     cl, CLR_SELECTION_BAR
   test     byte ptr [TooManyPartitions],0ffh ; Check for too many partitions.
   jz       BOOTMENU_BuildChoiceBar_normal
   mov     cl, CLR_SELECTION_BAR_WARNING    ; Set red bar if so.
   BOOTMENU_BuildChoiceBar_normal:
   call    BOOTMENU_ReColorPart
   ret
BOOTMENU_BuildChoiceBar         EndP

;        In: CL - Color, DL - Partition
; Destroyed: None, but Locate-Pointer gets set
BOOTMENU_ReColorPart    Proc Near   Uses bx cx es di

        ; call  SOUND_Beep

        mov     bh, cl     ; Color to BH
        ; First calculate location of bar
        cmp     Menu_UpperPart, dl
        ja      BMRCP_NotInWindowView
        mov     ch, dl
        sub     ch, Menu_UpperPart          ; CH - Position relative to UpperPart
        cmp     ch, 14                      ; 14 - Maximum Total in Window
        ja      BMRCP_NotInWindowView
        add     ch, 5                       ; Y-Position add-on fixed 5
        mov     cl, 2                       ; X-Position is always 2
        call    VideoIO_Locate              ; geht zu CX
        call    VideoIO_Internal_SetRegs
        inc     di                          ; DI - Destination+1 -> Color-Byte
        mov     cl, 78                      ; Length of Bar is always 78
    BMRCP_ClearLoop:
        mov     al, es:[di]
        and     al, 0Fh
        or      al, bh                      ; Adds background color (from BH)

        ;mov      al,97h

        mov     es:[di], al
        add     di, 2
        dec     cl
        jnz     BMRCP_ClearLoop
    BMRCP_NotInWindowView:
        ret
BOOTMENU_ReColorPart    EndP


; Calculate Menu-Variables for Boot-Menu, these use the filtered Part-Pointers
BOOTMENU_ResetMenuVars      Proc Near   Uses dx
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

        ; Copy device-name to the ContBIOSbootSeq-IPT entry
        ;  Normally this does not need to get done here, but is done for safety
        ;  reasons if e.g. IPT got changed by SETUP, but that setup was discarded.
        call    PART_UpdateResumeBIOSName

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

        ; restlichen Variablen berechnen...
        mov     dl, Menu_TotalParts
        cmp     byte ptr [Menu_TotalParts], 14
        jbe     BMRMV_NotMoreThan14
        mov     dl, 14
    BMRMV_NotMoreThan14:
        mov     Menu_TotalLines, dl

        ; Now copy the name of the Timed-Booted Partition to TimedBoot-Field
        mov     dl, Menu_EntryDefault
        test    byte ptr [CFG_TimedBootLast], 1
        jz      BMRMV_TimedBootDefault
        mov     dl, Menu_EntryLast
    BMRMV_TimedBootDefault:
        call    PART_GetPartitionPointer      ; Hold SI for Partition DL
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
BOOTMENU_ResetMenuVars      EndP

; Will Set some Vars after user selected entry to boot...
;  ...don't select Straight View !
BOOTMENU_SetVarsAfterMenu   Proc Near
        ; No Straight View in here...we got filtered view since BootMenu-Startup...
        mov     al, CFG_RememberTimed
        test    byte ptr [TimedBootUsed], 1
        jnz     BMSVAM_TimedBootUsed
        mov     al, CFG_RememberBoot
    BMSVAM_TimedBootUsed:
        or      al, al
        jz      BMSVAM_DontRememberBoot
        mov     dl, Menu_EntrySelected
        call    PART_ConvertToStraight        ; CFG_PartLast is non-filtered
        ;~ mov     di, offset CFG_LinuxLastKernel
        ;~ mov     cx, 11
        cmp     dl, 0FDh                      ; Dont Remember on Floppy/CD-ROM/etc.
        ja      BMSVAM_DontRememberBoot
        ;   je      BMSVAM_RememberKernelBoot     ; but remember Kernel-Bootings...
        mov     CFG_PartLast, dl              ; Remember partition in CFG_PartLast
        ;~ mov     al, ' '
        ;~ rep     stosb                         ; SPACE out CFG_LinuxLastKernel
    BMSVAM_DontRememberBoot:
        ret

    ;~ BMSVAM_RememberKernelBoot:
        ;~ mov     dl, Menu_EntrySelected
        ;~ call    PART_GetPartitionPointer      ; SI - Pointer to Kernel Entry...
        ;~ add     si, LocIPT_Name
        ;~ rep     movsb                         ; Copy KernelName 2 CFG_LinuxLastKernel
        ;~ ret
BOOTMENU_SetVarsAfterMenu   EndP




; Actually does the Boot-Menu Interaction
; Sets Carry-flag, if Setup is to be entered, otherwise system shall get booted
; On boot: Fills out some variables (like Menu_EntrySelected), when Booting
BOOTMENU_Execute    Proc Near   Uses es di
        ; Finds out, where to place the bar at first...
        mov     dl, Menu_EntryDefault
        test    byte ptr [CFG_RememberBoot], 1
        jnz     BME_RememberMode
        test    byte ptr [CFG_RememberTimed], 1
        jz      BME_ForgetMode
    BME_RememberMode:
        mov     dl, Menu_EntryLast
    BME_ForgetMode:
        ; Got it, so display bar...
        mov     dh, dl

        ;~ call    SOUND_Beep

        call    BOOTMENU_BuildChoiceBar       ; DH - Active, DL - Last Active

        ;~ call    SOUND_Beep

        call    SOUND_PreBootMenu


    BME_MainLoop:

        test    byte ptr [TimedBootEnable], 1
        jz      BME_NoTimedBoot
        ; ------------------------------------------------ TIMED BOOT
        push    ax
        push    dx
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
        pop     dx
        pop     ax
        mov     dl, Menu_EntryDefault
        and     byte ptr [CFG_TimedBootLast], 1
        jz      BME_TimedBootDefault
        mov     dl, Menu_EntryLast
    BME_TimedBootDefault:
        mov     Menu_EntrySelected, dl        ; Just boot default partition
        mov     byte ptr [TimedBootUsed], 1           ; set flag...
        clc                                ; Boot-Now!
        ret

    BME_NoTimeOut:
        pop     dx
        pop     ax
    BME_NoTimedBoot:
        ; ------------------------------------------------ FLOPPY-NAME TIMER
        test    byte ptr [CFG_FloppyBootGetTimer], 1
        jz      BME_NoFloppyNameTimer
        ; Wait 2 Seconds everytime
        push    ax
        push    dx
        call    TIMER_GetTicCount
        cmp     dx, word ptr [FloppyGetNameTimer+2]
        ja      BME_ExpiredGetFloppy
        cmp     ax, word ptr [FloppyGetNameTimer+0]
        jb      BME_NoFloppyNameExpired
    BME_ExpiredGetFloppy:
        call    BOOTMENU_ResetGetFloppy
        pop     dx
        pop     ax
        jmp     BME_RefreshFloppyName
    BME_NoFloppyNameExpired:
        pop     dx
        pop     ax
    BME_NoFloppyNameTimer:
        ; ------------------------------------------------ KEYBOARD
        push    dx
        mov     ah, 1
        int     16h
        pop     dx
        jnz     BME_KeyAvailable
        jmp     BME_MainLoop

    BME_RefreshFloppyName:
        test    byte ptr [CFG_IncludeFloppy], 1
        jz      BME_NoRefreshFloppyName
        test    byte ptr [CFG_FloppyBootGetName], 1
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

    ;!
    ;! DEBUG_BLOCK
    ;! Handle keys to activate debugging routines.
    ;!
    IFDEF   AUX_DEBUG
        call    DEBUG_HandleKeypress
    ENDIF

      cmp     ah, Keys_ENTER
        je      BME_KeyEnter
        cmp     ah, Keys_F10
        je      BME_KeyF10
        cmp     ah, Keys_Delete
        je      BME_KeyDelete
        cmp     ah, Keys_ESC
        je      BME_KeyESC
        ; Upper Keys do not fall under Timed Boot Key Handling
        test    byte ptr [TimedBootEnable], 1
        je      BME_NoTimedKeyHandling
        cmp     byte ptr [CFG_TimedKeyHandling], 1
        jb      BME_NoTimedKeyHandling     ; = 0
        je      BME_ResetTimedBoot         ; = 1
        mov     al, TimedBootEnable        ; = 2
        xor     al, 1                      ; Flip Flop Switch :]
        mov     [TimedBootEnable], al
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
        mov     byte ptr [TimedBootUsed], 0              ; reset flag...
        clc                                   ; Boot-Now!
        ret

    BME_KeyF10:
        mov     al, Keys_Flags_EnterSetup
        mov     byte ptr [SETUP_KeysOnEntry], al         ; Simulate user wants to enter setup
        stc                                   ; Go Re-Enter Setup
        ret

    BME_KeyDelete:
        call    SOUND_ExecuteBoot
        call    APM_TurnOffComputer
        jmp     BME_MainLoop

    BME_KeyESC:
        mov     al, [TimedBootEnable]
        xor     al, 1                         ; Flip Flop Switch :]
        mov     [TimedBootEnable], al
        push    dx
        call    BOOTMENU_ResetTimedBoot     ; Reset Timer
        call    BOOTMENU_BuildTimedBootText ; Refresh TimedBootText
        pop     dx
        jmp     BME_MainLoop

    BME_KeyTAB:
        push    dx

; While the FX-module is excluded from newer versions, we want to retain
; the option of enabling it.
IFDEF   FX_ENABLED
        test    byte ptr [CFG_CooperBars], 1
        jnz     BME_KeyTAB_ShowFX
ENDIF

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

    IFDEF   FX_ENABLED
        call    FX_InterleaveCopy
        call    FX_ScrollScreenLeft
    ENDIF

        mov     ah, 0
        int     16h                        ; Wait for any key
        call    BOOTMENU_ResetTimedBoot     ; Reset Timer
        call    BOOTMENU_BuildTimedBootText ; Refresh TimedBootText

    IFDEF   FX_ENABLED
        call    FX_ScrollScreenRight
        call    FX_EndScreenInternalCleanUp
    ENDIF

        call    BOOTMENU_ResetTimedBoot    ; Reset Timer again...
        popa
        pop     dx
        jmp     BME_MainLoop
BOOTMENU_Execute                EndP

; Resettet den TimedBoot Timer...
BOOTMENU_ResetTimedBoot     Proc Near   Uses ax
        call    TIMER_GetTicCount
        add     ax, CFG_TimedDelay
        adc     dx, 0
        mov     word ptr [TimedTimeOut], ax
        mov     word ptr [TimedTimeOut+2], dx
        ret
BOOTMENU_ResetTimedBoot     EndP

; Resettet den Floppy-Get-Name Timer...
BOOTMENU_ResetGetFloppy     Proc Near   Uses ax
        call    TIMER_GetTicCount
        add     ax, 36                      ; 18*2 -> 2 seconds
        adc     dx, 0
        mov     word ptr [FloppyGetNameTimer], ax
        mov     word ptr [FloppyGetNameTimer+2], dx
        ret
BOOTMENU_ResetGetFloppy     EndP
