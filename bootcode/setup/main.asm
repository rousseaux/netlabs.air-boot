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
;                         AiR-BOOT SETUP / GENERIC & GENERAL SETUP ROUTINES
;---------------------------------------------------------------------------

IFDEF   MODULE_NAMES
DB 'MAIN',0
ENDIF

;~ LocMENU_RoutinePtr           equ          0
;~ LocMENU_VariablePtr          equ          2
;~ LocMENU_ItemNamePtr          equ          4
;~ LocMENU_ItemHelpPtr          equ          6
;~ LocMENU_ItemPack             equ          8 ; only if VariablePtr>0

SETUP_UpperFixString          db 'SETUP ',0 ; AddOn for "AiR-BOOT SETUP vX.XX"

include setup/menus.asm                  ; Menu structures
include setup/part_set.asm               ; Partition Setup (in extra file)

;            CH - Current Item Number
;       Out: SI - Pointer to Item Location
; Destroyed: None
SETUP_SwitchToSelectedItem      Proc Near   Uses ax cx
   cmp     ch, 7
   jne     SSTSI_ValidSize
   stc     ; Invalid Item
   ret
  SSTSI_ValidSize:
   test    ch, 1000b
   jz      SSTSI_NoRightSide
   and     ch, 111b
   add     ch, 7                         ; fix Item-number to Real-Location
  SSTSI_NoRightSide:
   inc     ch                            ; So we will get a zero at the JZ
   mov     si, bp
   add     si, 3                         ; Skip FrontHeader for Menu
  SSTSI_Loop:
      dec     ch
      jz      SSTSI_LoopEnd

      mov     ax, word ptr ds:[si+LocMENU_VariablePtr]
      or      ax, ax
      jz      SSTSI_NoItemPack
      add     si, LocMENU_LenOfItemPack  ; ItemPack bergehen
     SSTSI_NoItemPack:
      add     si, LocMENU_LenOfMenuPtrBlock ; Skip Ptr-Block (+3 deshalb, weil danach INC!)
      jmp     SSTSI_Loop

  SSTSI_LoopEnd:
   clc
   ret   ; Exit is here :)
SETUP_SwitchToSelectedItem      EndP

SETUP_CheckEnterSETUP           Proc Near

   ; Rousseau: added
   ;mov     SETUP_ExitEvent, 0
   ;xor     al, al                        ; -PARTITION SETUP PreDefines-
   ;mov     PartSetup_UpperPart, al       ; Upper-Partition == 0
   ;mov     PartSetup_ActivePart, al      ; Active-Partition == 0

   ; Setup PartitionPointers-Table...again (needed when re-entering setup)
   ;call    PART_CalculateStraightPartPointers
   ;call    VideoIO_DBG_WriteString
   ; Rousseau: end added



   test    byte ptr [CFG_AutoEnterSetup], 1
   jnz     SCES_ForceEnter
   mov     al, [SETUP_KeysOnEntry]
   test    al, Keys_Flags_EnterSetup
IFDEF ReleaseCode
   jz      SCES_NoEnterSETUP
ENDIF
  SCES_ForceEnter:
   call    SETUP_Main
  SCES_NoEnterSETUP:
   ret
SETUP_CheckEnterSETUP           EndP

SETUP_Main                      Proc Near   Uses si es bp
   mov     byte ptr [SETUP_ExitEvent], 0
   xor     al, al                        ; -PARTITION SETUP PreDefines-
   mov     [PartSetup_UpperPart], al       ; Upper-Partition == 0
   mov     [PartSetup_ActivePart], al      ; Active-Partition == 0

   ; Setup PartitionPointers-Table...again (needed when re-entering setup)
   call    PART_CalculateStraightPartPointers

    IFDEF   FX_ENABLED
        call    FX_StartScreen                 ; Start of new screen...
    ENDIF

   call    SETUP_DrawMenuBase
   mov     bp, offset SETUP_MainMenu
   call    SETUP_MenuTask                 ; calls Menu!
   ret
SETUP_Main                      EndP

;        In: BP - Pointer to Menu
;   CurMenu: Left Side 0-6, Right Side 8-14 (Bit 3!)
SETUP_MenuTask                  Proc Near   ; the main-menu routine
   cmp     byte ptr [SETUP_ExitEvent], 1
   jne     SMT_NoImmediateExit
   ret

  SMT_NoImmediateExit:
   call    SETUP_FillUpItemPacks
   call    SETUP_DrawMenuOnScreen
   mov     si, ds:[bp+1]     ; Ptr to Help-Text
   call    SETUP_DrawMenuHelp

   mov     ax, ds:[bp+1]   ; Help Pointer
   cmp     ax, offset TXT_SETUPHELP_Main ; ask only in main-menu...
   jne     SMT_NotMainMenu

    IFDEF   FX_ENABLED
        call    FX_EndScreenLeft              ; Do FX, if requested...
    ENDIF

   test    byte ptr [CFG_PasswordSetup], 1
   jz      SMT_NotMainMenu
   mov     ax, 0ABABh
   mov     si, offset TXT_ProtectedSetup ; why bother again ?
   mov     di, offset CFG_MasterPassword ; Only Access Using MASTER Pwd
   call    PASSWORD_AskSpecifiedPassword
  SMT_NotMainMenu:

   mov     dl, dh
  SMT_KeyBored:
      ; Keyboard-Process Loop
      push    dx
         mov     ah, 0
         int     16h
      pop     dx

;!
;! DEBUG_PROBE
;!
IFDEF   AUX_DEBUGx
    push    1234h
    call    DEBUG_Probe
    call    DEBUG_DumpIPT
    call    DEBUG_DumpRegisters
ENDIF



      cmp     ah, Keys_Up
      je      SMT_KeyUp
      cmp     ah, Keys_Down
      je      SMT_KeyDown
      cmp     ah, Keys_Left
      je      SMT_KeyLeftRight
      cmp     ah, Keys_Right
      je      SMT_KeyLeftRight
      cmp     ah, Keys_ENTER
      je      SMT_KeyENTER
      cmp     ah, Keys_Plus
      je      SMT_KeyPlus
      cmp     ah, Keys_Minus
      je      SMT_KeyMinus
      cmp     ah, Keys_GrayPlus
      je      SMT_KeyPlus
      cmp     ah, Keys_GrayMinus
      je      SMT_KeyMinus
      cmp     ah, Keys_PageDown
      je      SMT_KeyPlus
      cmp     ah, Keys_PageUp
      je      SMT_KeyMinus
      cmp     ah, Keys_ESC
      je      SMT_KeyEsc
      cmp     ah, Keys_F1
      jne   skip_xx
      jmp      SMT_KeyHelp
   skip_xx:
      cmp     ah, Keys_F10
      jne   skip_yy
      jmp      SMT_SaveAndExitNOW
   skip_yy:
      ; ASCII values...
      cmp     al, Keys_Space
      je      SMT_KeyPlus
   jmp     SMT_KeyBored

  SMT_KeyUp:
   dec     dh                            ; Current Item -1
   mov     bx, offset SMT_KeyUp
   jmp     SMT_FixUpModify

  SMT_KeyDown:
   inc     dh                            ; Current Item +1
   mov     bx, offset SMT_KeyDown
   jmp     SMT_FixUpModify

  SMT_KeyLeftRight:
   xor     dh, 1000b                     ; Little Trick Flip-Flop Left/Right
   mov     bx, offset SMT_KeyLeftRight
   jmp     SMT_FixUpModify

  SMT_KeyENTER:                          ; Enters Menu, if no ItemPack available
   mov     ch, dh
   call    SETUP_SwitchToSelectedItem    ; Calculates SI for Item-No (CH)
   mov     ax, ds:[si+LocMENU_RoutinePtr]
   mov     bx, ds:[si+LocMENU_VariablePtr]
   or      bx, bx                        ; VarPtr ?
   jnz     SMT_DoNotExecute
  SMT_DirectExecute:
      mov     ds:[bp+0], dh              ; Saves current menu
      call    ax                         ; Call to CodePtr
      call    SETUP_DrawMenuOnScreen     ; Redraw after return
      cmp     byte ptr [SETUP_ExitEvent], 1
      je      SMT_ExitEvent
  SMT_DoNotExecute:
   jmp     SMT_KeyBored

  SMT_ExitEvent:
   ret                                   ; just return, to easy uh ?

  SMT_KeyPlus:                           ; Changes ItemPack
   mov     cl, 1
   jmp     SMT_KeyChangeEvent
  SMT_KeyMinus:
   xor     cl, cl
  SMT_KeyChangeEvent:
   mov     ch, dh
   call    SETUP_SwitchToSelectedItem    ; Calculates SI for Item-No (CH)
   mov     ax, ds:[si+LocMENU_RoutinePtr]
   mov     bx, ds:[si+LocMENU_VariablePtr]
   or      bx, bx                        ; VarPtr ? =0 No ItemPack
   jnz     SMT_DoItemPack
   jmp     SMT_KeyBored
  SMT_DoItemPack:
      clc                                ; Modify this Item !
      call    ax                         ; Call to Item-Code-Ptr
   jmp     SMT_OkayReDisplay

  SMT_KeyEsc:
   mov     ax, ds:[bp+1]                 ; Help Pointer
   cmp     ax, offset TXT_SETUPHELP_Main ; embarassing? ;-)
   jne     SMT_ReturnPrev
   jmp     SMT_ExitWithoutSaving
  SMT_ReturnPrev:
   mov     ds:[bp+0], dh                 ; Saves current menu
   ret                                   ; just return to go to prev menu...

  SMT_FixUpModify:
   cmp     dh, 0FFh                      ; = 255 ?
   jne     SMT_NoAdjustMin
   mov     dh, 14                        ; Overflow -> 14!
  SMT_NoAdjustMin:
   cmp     dh, 14                        ; bigger as 14 ?
   jbe     SMT_NoAdjustMax
   xor     dh, dh                        ; Reset to 0
  SMT_NoAdjustMax:
   mov     ch, dh
   call    SETUP_SwitchToSelectedItem    ; Calculates SI for Item-No (CH)
   jnc     SMT_ValidItem
   jmp     bx
  SMT_ValidItem:
   mov     ax, word ptr ds:[si]
   or      ax, ax
   jnz     SMT_OkayReDisplay
   jmp     bx                            ; Do it again... :)
  SMT_OkayReDisplay:
   call    SETUP_DrawDeSelectItem
   call    SETUP_DrawSelectItem
   mov     dl, dh
   jmp     SMT_KeyBored

  SMT_KeyHelp:                           ; Shows help for selected Item...
   mov     ch, dh
   call    SETUP_SwitchToSelectedItem    ; Calculates SI for Item-No (CH)
   mov     bx, ds:[si+LocMENU_ItemHelpPtr]
   or      bx, bx                        ; Help-Ptr available ?
   jz      SMT_NoHelpAvailable
   call    SETUP_ShowHelp                ; Shows help...
  SMT_NoHelpAvailable:
   jmp     SMT_KeyBored

  SMT_SaveAndExitNOW:                    ; Direct HackIn

;!
;! DEBUG_PROBE
;!
IFDEF   AUX_DEBUGx
    push    1235h
    call    DEBUG_Probe
ENDIF

   mov     ax, offset SETUP_EnterMenu_SaveAndExitSetup
   jmp     SMT_DirectExecute

  SMT_ExitWithoutSaving:                 ; Direct HackIn
;!
;! DEBUG_PROBE
;!
IFDEF   AUX_DEBUGx
    push    1236h
    call    DEBUG_Probe
ENDIF

   mov     ax, offset SETUP_EnterMenu_ExitWithoutSaving
   jmp     SMT_DirectExecute
SETUP_MenuTask                  EndP


; Initial bg-colors on setup-items -- revert to item-bg when cursor moved
CLR_MENU_WINDOW_CLASSIC = 0e01h
CLR_MENU_WINDOW_BM      = 0e01h
CLR_MENU_WINDOW_TB      = 0e08h
IFDEF TESTBUILD
CLR_MENU_WINDOW = CLR_MENU_WINDOW_TB
ELSE
CLR_MENU_WINDOW = CLR_MENU_WINDOW_BM
ENDIF

;        In: BP - Pointer to Menu
;       Out: DH - Active Item on Screen
SETUP_DrawMenuOnScreen          Proc Near
   call    SETUP_DrawMenuWindow
   mov     cx, CLR_MENU_WINDOW
   call    VideoIO_Color
   xor     ch, ch
  SDMOS_Loop:
      call    SETUP_DrawItemOnScreen
      inc     ch                         ; Total of 14 items to display
      cmp     ch, 14
      jbe     SDMOS_Loop
   mov     dh, ds:[bp+0]
   mov     dl, dh                        ; Active = Last
   call    SETUP_DrawSelectItem          ; Marks active Item
   mov     si, ds:[bp+1]                 ; Ptr to Item-Help-Text
   call    SETUP_DrawMenuHelp
   ret
SETUP_DrawMenuOnScreen          EndP

SETUP_FillUpItemPacks           Proc Near Uses cx
   xor     ch, ch
  SFUIP_Loop:
      call    SETUP_FillUpItemPack_Now
      inc     ch                         ; Total of 14 items to display
   cmp     ch, 14
   jbe     SFUIP_Loop
   ret
SETUP_FillUpItemPacks           EndP


CLR_SELECTED_ITEM_CLASSIC  = 0f04h
CLR_SELECTED_ITEM_BM       = 0f04h
CLR_SELECTED_ITEM_TB       = 0f04h
IFDEF TESTBUILD
CLR_SELECTED_ITEM = CLR_SELECTED_ITEM_TB
ELSE
CLR_SELECTED_ITEM = CLR_SELECTED_ITEM_BM
ENDIF

; Displays selected Item on screen
;        In: DH - Active Item
; Destroyed: None
SETUP_DrawSelectItem            Proc Near Uses cx
   mov     cx, CLR_SELECTED_ITEM
   call    VideoIO_Color
   mov     ch, dh
   call    SETUP_DrawItemOnScreen
   ret
SETUP_DrawSelectItem            EndP


CLR_DESELECTED_ITEM_CLASSIC   = 0e01h
CLR_DESELECTED_ITEM_BM        = 0e01h
CLR_DESELECTED_ITEM_TB        = 0e08h
IFDEF TESTBUILD
CLR_DESELECTED_ITEM = CLR_DESELECTED_ITEM_TB
ELSE
CLR_DESELECTED_ITEM = CLR_DESELECTED_ITEM_BM
ENDIF

; Display last-selected Item on screen (De-Select)
;        In: DL - Active Item
; Destroyed: None
SETUP_DrawDeSelectItem          Proc Near Uses cx
   mov     cx, CLR_DESELECTED_ITEM
   call    VideoIO_Color
   mov     ch, dl
   call    SETUP_DrawItemOnScreen
   ret
SETUP_DrawDeSelectItem          EndP

; Actually displays Item on screen, Out of bounce checking included
;        In: CH - CurItemNo
; Destroyed: None
SETUP_DrawItemOnScreen          Proc Near   Uses ax cx dx si es
   call    SETUP_SwitchToSelectedItem    ; Calculates SI for Item-No (CH)
   jnc     SDIOS_ValidItem
   ret     ; Ignore all Invalid Items

  SDIOS_ValidItem:
   mov     dx, word ptr TextColorFore    ; BackUps TextColor for later
   mov     cl, 3                         ; Left side: 3
   test    ch, 1000b
   jz      SDIOS_NoRightSide
   and     ch, 111b
   mov     cl, 42                        ; Right side: 42
  SDIOS_NoRightSide:
   mov     ax, ds:[si+LocMENU_VariablePtr] ; if available, we got ItemPack
   or      ax, ax
   jnz     SDIOS_ItemPackDraw
   ; ------------------------------------------------------ Draw NAME
   mov     ax, ds:[si+LocMENU_RoutinePtr] ; no Item-Code-Ptr? -> no name
   or      ax, ax
   jnz     SDIOS_Name_CodePtrAvailable
   mov     TextColorFore, 0Fh            ; display in white letters
   sub     cl, 2                         ; not optimized, i know :]
  SDIOS_Name_CodePtrAvailable:
   add     cl, 2                         ; Fix X-coordinate (for name)
   add     ch, 6                         ; Fix Y-coordinate
   cmp     cl, 40
   jb      SDIOS_Name_NoFixUpName
   inc     cl
  SDIOS_Name_NoFixUpName:
   call    VideoIO_Locate
   mov     si, ds:[si+LocMENU_ItemNamePtr] ; SI - Name of Item
   or      si, si
   jz      SDIOS_Name_NoItemName
   call    VideoIO_Print                 ; ...and print it.
  SDIOS_Name_NoItemName:
   mov     word ptr [TextColorFore], dx
   ret

   ; ------------------------------------------------------ Draw ITEMPACK
  SDIOS_ItemPackDraw:
   add     ch, 6                         ; Fix coordinate...
   ; Display the Name and a double-point first
   ; BackUp Coordinates and ItemPackPtr
   push    cx
   push    si
      push    cx
         cmp     cl, 40
         jb      SDIOS_ItemPack_NoFixUpItemPack
         inc     cl
        SDIOS_ItemPack_NoFixUpItemPack:
         call    VideoIO_Locate


CLR_ITEM_PACK_CLASSIC   = 0f01h
CLR_ITEM_PACK_BM        = 0f01h
CLR_ITEM_PACK_TB        = 0f08h
IFDEF TESTBUILD
CLR_ITEM_PACK = CLR_ITEM_PACK_TB
ELSE
CLR_ITEM_PACK = CLR_ITEM_PACK_BM
ENDIF

         mov     cx, CLR_ITEM_PACK
         call    VideoIO_Color           ; White on blue background
         mov     si, ds:[si+LocMENU_ItemNamePtr] ; SI - Name of Item
         or      si, si
         jz      SDIOS_ItemPack_NoItemName
         call    VideoIO_Print
        SDIOS_ItemPack_NoItemName:
      pop     cx
      add     cl, 24
      call    VideoIO_Locate
      mov     al, 3Ah
      call    VideoIO_PrintSingleChar    ; Write double-point
      mov     word ptr TextColorFore, dx
   pop     si
   pop     cx
   add     cl, 26                        ; Fix X-coordinate (for ItemPack)
   call    VideoIO_Locate

   add     si, LocMENU_ItemPack          ; Where ItemPack is located...
   ; Filler berechnen
  SDIOS_ItemPack_RetryGetLen:
   mov     cx, 11
   call    GetLenOfName
   cmp     cx, 11
   je      SDIOS_ItemPack_NoFiller
   mov     al, cl
   mov     cl, 11
   sub     cl, al
   mov     al, 20h                       ; Fill up with spaces
   call    VideoIO_Internal_MakeWinRight ; and write...
  SDIOS_ItemPack_NoFiller:
   call    VideoIO_PrintLikeLenOfName    ; Write ItemPack
   ret
SETUP_DrawItemOnScreen          EndP

SETUP_FillUpItemPack_Now        Proc Near Uses ax bx si
   call    SETUP_SwitchToSelectedItem    ; Calculates SI for Item-No (CH)
   jnc     SFUIPN_ValidItem
  SFUIPN_Ignore:
   ret                                   ; Ignore all Invalid Items

  SFUIPN_ValidItem:
   mov     bx, ds:[si+LocMENU_VariablePtr]
   or      bx, bx
   jz      SFUIPN_Ignore
   mov     ax, ds:[si+LocMENU_RoutinePtr]
   mov     cl, 1                         ; Add, if anything fails
   stc                                   ; Just FillUp Call
   call    ax                            ; CH-ItemNo, CL-Add/Sub, BX-PtrToVar
   ret
SETUP_FillUpItemPack_Now        EndP

CLR_SETUP_WINDOW_CLASSIC   = 0f01h
CLR_SETUP_WINDOW_BM        = 0901h
CLR_SETUP_WINDOW_TB        = 0908h
IFDEF TESTBUILD
CLR_SETUP_WINDOW = CLR_SETUP_WINDOW_TB
ELSE
CLR_SETUP_WINDOW = CLR_SETUP_WINDOW_BM
ENDIF

SETUP_DrawMenuWindow            Proc Near   Uses es
   mov     cx, CLR_SETUP_WINDOW
   call    VideoIO_Color
   mov     bx, 0401h
   mov     dx, 0E50h
   call    VideoIO_MakeWindow
   mov     bx, 0E01h
   mov     dx, 1150h
   call    VideoIO_MakeWindow
   mov     cx, 0529h
   call    VideoIO_Locate
   mov     al, TextChar_WinLineDown
   mov     cl, 12
   call    VideoIO_Internal_MakeWinDown
   ; the little fixups for better looking windows...
   mov     cx, 0429h
   call    VideoIO_Locate
   mov     al, TextChar_WinRep1
   call    VideoIO_PrintSingleChar
   mov     cx, 0E29h
   call    VideoIO_Locate
   mov     al, TextChar_WinRep6
   call    VideoIO_PrintSingleChar
   mov     cx, 1129h
   call    VideoIO_Locate
   mov     al, TextChar_WinRep3
   call    VideoIO_PrintSingleChar
   mov     cx, 0E01h
   call    VideoIO_Locate
   mov     al, TextChar_WinRep5
   call    VideoIO_PrintSingleChar
   mov     cx, 0E50h
   call    VideoIO_Locate
   mov     al, TextChar_WinRep4
   call    VideoIO_PrintSingleChar
   ret
SETUP_DrawMenuWindow            EndP

SETUP_DrawMenuBase              Proc Near
   call    BOOTMENU_BuildBackground
   ; -------------------------------------------- Upper Copyright...
   mov     cx, 0F00h
   call    VideoIO_Color
   mov     cx, 011Eh
   call    VideoIO_Locate
   mov     si, offset Copyright
   inc     si
   mov     cl, 9
   call    VideoIO_FixedPrint            ; Put 'AiR-BOOT' to 1st line...
   push    si
      mov     si, offset SETUP_UpperFixString
      call    VideoIO_Print              ; and 'SETUP'...
   pop     si
   mov     cl, CopyrightVersionLen
   call    VideoIO_FixedPrint            ; and 'vX.XX'.

   ; Rousseau:
   ; Strange, had to adjust this value.
   ; Somewhere some offset changed...
   ; Possibly happened with the movzx change to 286 instructions because some
   ; offsets are hard coded.
   ;add     si, 3
   add     si, 2

   call    GetLenOfString                ; CX - Len of "Copyright" string
   mov     dx, cx
   mov     cx, 0228h
   call    VideoIO_LocateToCenter        ; LocateToCenter 2, 40 using TotalLen
   call    VideoIO_Print                 ; 'Copyright' to 2nd line...

   mov     si, offset TXT_TranslationBy
   call    GetLenOfString                ; CX - Len of "Translated by" string
   mov     dx, cx
   mov     cx, 0328h
   call    VideoIO_LocateToCenter        ; LocateToCenter 3, 40 using TotalLen
   call    VideoIO_Print                 ; 'Translated By' as well...
   ; -------------------------------------------- Lower 1st Line
   mov     si, offset TXT_SETUP_LowerMessage
   mov     cl, 2
   call    GetLenOfStrings               ; CX - Len of 5 Strings at [si]
   mov     dx, cx
   mov     cx, 1329h
   call    VideoIO_LocateToCenter        ; LocateToCenter 21, 40 using TotalLen
   call    VideoIO_Print                 ; Begin using WHITE again...
   mov     cx, 0C00h
   call    VideoIO_Color
   call    VideoIO_Print                 ; contine red - 'GPLv3+'
   ; -------------------------------------------- Lower 2nd Line
   mov     cl, 1
   call    GetLenOfStrings               ; CX - Len of 3 Strings at [si]
   mov     dx, cx
   mov     cx, 1429h
   call    VideoIO_LocateToCenter        ; LocateToCenter 19, 40 using TotalLen
   mov     cx, 0F00h
   call    VideoIO_Color                 ; White...
   call    VideoIO_Print                 ; Begin using WHITE...
   ; -------------------------------------------- Lower 3rd Line
   mov     cl, 1
   call    GetLenOfString                ; CX - Len of String at [si]
   mov     dx, cx
   mov     cx, 1629h
   call    VideoIO_LocateToCenter        ; LocateToCenter 22, 40 using TotalLen
   mov     cx, 0F00h
   call    VideoIO_Color                 ; White...
   call    VideoIO_Print                 ; For more information...
   ; -------------------------------------------- Lower 4th Line
   mov     cl, 1
   call    GetLenOfStrings               ; CX - Len of 5 Strings at [si]
   mov     dx, cx
   mov     cx, 1729h
   call    VideoIO_LocateToCenter        ; LocateToCenter 24, 40 using TotalLen
   mov     cx, 0B00h
   call    VideoIO_Color
   call    VideoIO_Print                 ; homepage
   ; -------------------------------------------- Lower 5th Line
   mov     cl, 2
   call    GetLenOfStrings               ; CX - Len of 4 Strings at [si]
   mov     dx, cx
   mov     cx, 1929h
   call    VideoIO_LocateToCenter        ; LocateToCenter 25, 40 using TotalLen
   mov     cx, 0700h
   call    VideoIO_Color
   call    VideoIO_Print                 ; white - 'contact via e-mail'...
   mov     cx, 0700h
   call    VideoIO_Color
   call    VideoIO_Print                 ; and finally the e-mail adress
   ret
SETUP_DrawMenuBase              EndP


; F10-SETUP Help Directions
CLR_SETUP_HELP_CLASSIC   = 0f01h
CLR_SETUP_HELP_BM        = 0f01h
CLR_SETUP_HELP_TB        = 0f08h
IFDEF TESTBUILD
CLR_SETUP_HELP = CLR_SETUP_HELP_TB
ELSE
CLR_SETUP_HELP = CLR_SETUP_HELP_BM
ENDIF

; Zeichnet die Men Hilfe aufn Bildschirm
;        In: SI - Pointer to 4 HelpStrings...
; Destroyed: None
SETUP_DrawMenuHelp              Proc Near   Uses cx si
   mov     cx, CLR_SETUP_HELP
   call    VideoIO_Color
   mov     cx, 0F05h
   call    VideoIO_Locate
   call    VideoIO_Print
   mov     cx, 1005h
   call    VideoIO_Locate
   call    VideoIO_Print
   mov     cx, 0F2Dh
   call    VideoIO_Locate
   call    VideoIO_Print
   mov     cx, 102Dh
   call    VideoIO_Locate
   call    VideoIO_Print
   ret
SETUP_DrawMenuHelp              EndP

;        In: bx - HelpPtr
; Destroyed: None
SETUP_ShowHelp                  Proc Near   Uses cx dx ds si es di bp
   mov     ax, VideoIO_Page2
   call    VideoIO_BackUpTo

   push    bx                            ; Push HelpPtr
      mov     cx, 0B03h
      call    VideoIO_Color
      mov     bx, 0F33h
      mov     dx, 174Eh
      call    VideoIO_MakeWindow
      ; Print at lower-right frame of window
      mov     si, offset TXT_SETUPHELP_Enter
      call    GetLenOfString             ; CX - Len of String
      mov     dl, cl
      mov     cx, 174Eh
      sub     cl, dl
      call    VideoIO_Locate             ; Locate 23, (78-LenOfString)
      call    VideoIO_Print
      mov     cx, 0F03h
      call    VideoIO_Color
      ; Center at upper frame of window
      mov     si, offset TXT_SETUPHELP_Base
      call    GetLenOfString
      mov     dx, cx
      mov     cx, 0F41h
      call    VideoIO_LocateToCenter     ; LocateToCenter 15, 65 using LenOfStr
      call    VideoIO_Print
      ; beim R

      mov     cx, 0E03h
      call    VideoIO_Color
   pop     si                            ; and restore HelpPtr to SI
   mov     cx, 1136h

  SSH_Loop:
      call    VideoIO_Locate
      call    VideoIO_Print
      inc     ch                         ; TextPosY + 1
   cmp     TextPosX, 36h
   ja      SSH_Loop

  SSH_KeyLoop:
      mov     ah, 0
      int     16h
      cmp     ah, Keys_ENTER
      je      SSH_EndOfHelp
      cmp     ah, Keys_ESC
      je      SSH_EndOfHelp
   jmp     SSH_KeyLoop

  SSH_EndOfHelp:
   mov     ax, VideoIO_Page2
   call    VideoIO_RestoreFrom
   ret
SETUP_ShowHelp                  EndP

SETUP_EnterMenu_PartitionSetup  Proc Near   Uses dx bp
   ; Extra-Full Featured Partition Setup
   call    PARTSETUP_Main
   ret
SETUP_EnterMenu_PartitionSetup  EndP

SETUP_EnterMenu_BasicOptions    Proc Near   Uses dx bp
   mov     bp, offset SETUP_BasicOptions
   call    SETUP_MenuTask                ; calls Menu!
   ret
SETUP_EnterMenu_BasicOptions    EndP

SETUP_EnterMenu_AdvancedOptions Proc Near   Uses dx bp
   mov     bp, offset SETUP_AdvancedOptions
   call    SETUP_MenuTask                ; calls Menu!
   ret
SETUP_EnterMenu_AdvancedOptions EndP

SETUP_EnterMenu_ExtendedOptions Proc Near   Uses dx bp
   mov     bp, offset SETUP_ExtendedBootOptions
   call    SETUP_MenuTask                ; calls Menu!
   ret
SETUP_EnterMenu_ExtendedOptions EndP

; [Linux support removed since v1.02]
;SETUP_EnterMenu_LinuxCommandLine Proc Near  Uses dx bp
;   test    GotLinux, 1
;   jz      SEMLCL_NoLinux
;   call    SETUP_EnterMenu_EnterLinuxCmdLine
;   ret
;  SEMLCL_NoLinux:
;   mov     cx, 0C04h
;   mov     si, offset TXT_SETUP_NoLinuxInstalled
;   call    SETUP_ShowErrorBox
;   ret
;SETUP_EnterMenu_LinuxCommandLine EndP

SETUP_EnterMenu_DefineMasterPassword Proc Near
   mov     di, offset CFG_MasterPassword
   call    SETUP_EnterMenu_DefinePassword
   ret
SETUP_EnterMenu_DefineMasterPassword EndP

SETUP_EnterMenu_DefineBootPassword Proc Near
   mov     di, offset CFG_BootPassword
   call    SETUP_EnterMenu_DefinePassword
   ret
SETUP_EnterMenu_DefineBootPassword EndP

; ============================================================================

; [Linux support removed since v1.02]
;SETUP_EnterMenu_EnterLinuxCmdLine Proc Near
;   mov     cx, 0D05h
;   call    VideoIO_Color
;   mov     bx, 0C02h
;   mov     dx, 0F4Fh
;   call    VideoIO_MakeWindow
;   mov     cx, 0F05h
;   call    VideoIO_Color
;
;   mov     si, offset TXT_SETUP_EnterLinuxCmdLine
;   call    GetLenOfString                ; CX - Len of Error Message
;   mov     dx, cx
;   mov     cx, 0D28h
;   call    VideoIO_LocateToCenter        ; LocateToCenter 13, 40 using LenOfStr
;   call    VideoIO_Print                 ; Writes 'Please enter Linux-CmdLine'
;
;   mov     cx, 0E05h
;   call    VideoIO_Color
;   mov     cx, 0E04h
;   call    VideoIO_Locate
;   mov     al, ' '
;   mov     cl, 74
;   call    VideoIO_PrintSingleMultiChar
;   mov     cx, 0E04h
;   call    VideoIO_Locate
;   mov     si, offset CFG_LinuxCommandLine
;   push    si
;      call    VideoIO_Print              ; Writes Linux Command-Line
;   pop     si
;   mov     cx, 0E04h
;   call    VideoIO_Locate
;
;   push    cs
;   pop     es                            ; ES == CS
;   mov     di, offset TmpSector
;   mov     cx, 37
;   rep     movsw                         ; Copy LinuxCmdLine -> TmpSectorSpace
;
;   mov     si, offset TmpSector
;   mov     cx, 74
;   call    VideoIO_LetUserEditString     ; -> does actual editing
;   jnc     SEMELCL_UserAbort             ; Did user abort ?
;
;   ; Otherwise copy TmpSectorSpace to LinuxCmdLine
;   mov     di, offset CFG_LinuxCommandLine
;   mov     cx, 74
;   call    GetLenOfName                  ; Get real length of Cmd-Line into CX
;   jz      SEMELCL_NulLine
;   rep     movsb
;  SEMELCL_NulLine:
;   mov     ax, 75
;   sub     ax, cx
;   mov     cx, ax
;   xor     al, al
;   rep     stosb                         ; Fill up with NULs
;
;  SEMELCL_UserAbort:
;   ret
;SETUP_EnterMenu_EnterLinuxCmdLine EndP

;        In: di - Place for Password to be defined
; Destroyed: None
SETUP_EnterMenu_DefinePassword  Proc Near   Uses dx es bp
   push    di                            ; DI - Place of Password
      mov     ax, cs
      mov     es, ax                     ; ES == CS & Magic (AX) destroyed
      mov     si, offset TXT_SETUP_PasswordOld
      ;       di - Place of Password to Check (0 to check both passwords)
      call    PASSWORD_AskSpecifiedPassword
      mov     si, offset TXT_SETUP_PasswordDefine
      mov     di, offset SETUP_NewPwd
      call    SETUP_LetEnterPassword
      xor     ax, ax                     ; Magic (AX) destroyed
      mov     si, offset TXT_SETUP_PasswordVerify
      mov     di, offset SETUP_VerifyPwd
      call    SETUP_LetEnterPassword

      mov     si, offset SETUP_NewPwd
      mov     di, offset SETUP_VerifyPwd
      mov     cx, 8
      repe    cmpsb
      jne     SEMDP_NoMatch

      mov     si, offset SETUP_NewPwd
      call    PASSWORD_Encode
      mov     si, offset PasswordSpace
   pop     di    ; DI = Place for Password
   mov     cx, 4
   rep     movsw     ; neues Passwort...

   mov     di, offset SETUP_NewPwd
   mov     al, 32
   mov     cx, 8
   repe    scasb
   je      SEMDP_Disabled
   mov     cx, 0A02h
   mov     si, offset TXT_SETUP_PasswordMatched
   call    SETUP_ShowErrorBox
   jmp     SEMDP_ExitSub
  SEMDP_Disabled:
   mov     cx, 0A02h
   mov     si, offset TXT_SETUP_PasswordDisabled
   call    SETUP_ShowErrorBox
   jmp     SEMDP_ExitSub

     SEMDP_NoMatch:
   pop     di                            ; DI = Place for Password <BUG>
   mov     cx, 0C04h
   mov     si, offset TXT_SETUP_PasswordMismatch
   call    SETUP_ShowErrorBox
   jmp     SEMDP_ExitSub

  SEMDP_ExitSub:
   ret
SETUP_EnterMenu_DefinePassword  EndP

;        In: DS:SI - Text-Line for Display
;            ES:DI - Location for new password (must be 17 bytes)
;            AX    - Magic, if set to ABAB, it will use a different layout and
;                     will write 'Please Enter Password:'
SETUP_LetEnterPassword          Proc Near   Uses bx cx dx si es di
   local   EnterPwd_Location:word, EnterPwd_DefinePwd:word

   mov     ax, VideoIO_Page2
   call    VideoIO_BackUpTo
   push    ax
   push    di
      mov     ax, 20h                    ; Space
      mov     cx, 16
      rep     stosb                      ; Kill new password
      mov     es:[di], ah                ; ending NUL
   pop     di
   pop     ax
   cmp     ax, 0ABABh                    ; Magic Processing...
   je      SLEP_MagicLayOut
   mov     cx, 0D05h                     ; Password Dialog
   call    VideoIO_Color

   call    GetLenOfString                ; CX - Len of Error Message
   add     cl, 6                         ; Adjust to include 2 Spaces and Frame
   push    cx
      mov     bx, 0C28h
      shr     cl, 1
      sub     bl, cl
   pop     cx
   mov     dh, 0Fh
   mov     dl, bl
   add     dl, cl
   dec     dl                            ; Size window to match given string...
   call    VideoIO_MakeWindow
   mov     cx, 0F05h                     ; Password EntryField Label
   call    VideoIO_Color

   mov     ch, 0Dh
   mov     cl, bl
   add     cl, 3
   call    VideoIO_Locate
   call    VideoIO_Print                 ; Uses given string 'Define or Verify'
   mov     cx, 0E05h                     ; Password EntryField
   call    VideoIO_Color
   mov     word ptr [EnterPwd_Location], 0E26h
   mov     word ptr [EnterPwd_DefinePwd], 1
   jmp     SLEP_JumpToInputProcess

  SLEP_MagicLayOut:
   mov     cx, 0C04h                      ; Only used for different (unused) layout (ABAB)
   call    VideoIO_Color

   call    GetLenOfString                 ; CX - Len of Error Message
   add     cl, 4                          ; Adjust to include Space and Frame
   push    cx
      mov     bx, 0C28h
      shr     cl, 1
      sub     bl, cl
   pop     cx
   mov     dh, 10h
   mov     dl, bl
   add     dl, cl
   dec     dl                            ; Size window to match given string...
   call    VideoIO_MakeWindow
   mov     cx, 0F04h
   call    VideoIO_Color
   mov     ch, 0Dh
   mov     cl, bl
   add     cl, 2
   call    VideoIO_Locate
   call    VideoIO_Print                 ; Uses given string...

   mov     si, offset TXT_PleaseEnterPassword
   call    GetLenOfString                ; CX - Len of Error Message
   mov     dx, cx
   mov     cx, 0E28h
   call    VideoIO_LocateToCenter        ; LocateToCenter 14, 40 using LenOfStr
   call    VideoIO_Print                 ; Writes 'Please Enter Password:'
   mov     cx, 0E04h
   call    VideoIO_Color
   mov     EnterPwd_Location, 0F25h
   mov     EnterPwd_DefinePwd, 0
  SLEP_JumpToInputProcess:
   call    SOUND_PreBootMenu
   mov     si, di                        ; DS:SI - Current Password
   xor     dl, dl
   ; DL - location of cursor (first=0)
  SLEP_Loop:
   mov     cx, [EnterPwd_Location]
   call    VideoIO_Locate
   push    si
      add     si, 8
      call    VideoIO_Print              ; Prints current Password
   pop     si
   mov     ah, 0
   int     16h
   cmp     al, 61h
   jb      SLEP_SkipFixLower
   cmp     al, 7Ah
   ja      SLEP_SkipFixLower
   xor     al, 20h                       ; Convert to UpperCase (ELiTE)
   jmp     SLEP_CorrectPwdChar
  SLEP_SkipFixLower:
   cmp     al, 41h
   jb      SLEP_NonChar
   cmp     al, 5Ah
   ja      SLEP_NonChar
   jmp     SLEP_CorrectPwdChar
  SLEP_NonChar:
   cmp     al, 30h
   jb      SLEP_NonNum
   cmp     al, 39h
   ja      SLEP_NonNum
   jmp     SLEP_CorrectPwdChar
  SLEP_NonNum:
   cmp     al, 0Dh
   je      SLEP_Enter
   cmp     al, 08h
   je      SLEP_OneBack
  SLEP_SkipThiz:
   jmp     SLEP_Loop

  SLEP_CorrectPwdChar:
   cmp     dl, 8
   je      SLEP_SkipThiz

   ;movzx   bx, dl
   mov   bl,dl
   mov   bh,0

   mov     ds:[si+bx], al
   mov     al, 42                        ; fixed star :]
   mov     ds:[si+bx+8], al
   inc     dl
   jmp     SLEP_Loop
  SLEP_OneBack:
   cmp     dl, 0
   je      SLEP_SkipThiz
   dec     dl

   ;movzx   bx, dl
   mov   bl,dl
   mov   bh,0

   mov     al, 32
   mov     ds:[si+bx], al
   mov     ds:[si+bx+8], al
   jmp     SLEP_Loop
  SLEP_Enter:
   or      dl, dl
   jnz     SLEP_GotSomePassword
   cmp     word ptr [EnterPwd_DefinePwd], 1
   je      SLEP_GotSomePassword
   mov     cx, 8
   mov     al, 1                         ; Fill empty password with [01]
   rep     stosb                         ; ...only when Asking Password.
  SLEP_GotSomePassword:
   mov     ax, VideoIO_Page2
   call    VideoIO_RestoreFrom
   ret
SETUP_LetEnterPassword          EndP

; ============================================================================

; CX = Color of Box, SI = String in Box
; If AX = ABABh -> Thingie will not wait...
SETUP_ShowErrorBox              Proc Near   Uses ax bx cx
   push    ax
      push    cx
         call    VideoIO_Color
         call    GetLenOfString          ; CX - Len of Error Message
         add     cl, 4                   ; Adjust to include Space and Frame
         push    cx
            mov     bx, 0D28h
            shr     cl, 1
            sub     bl, cl
         pop     cx
         mov     dh, 0Fh
         mov     dl, bl
         add     dl, cl
         dec     dl
         call    VideoIO_MakeWindow
      pop     cx
      mov     ch, 0Fh
      call    VideoIO_Color
      mov     ch, 0Eh
      mov     cl, bl
      add     cl, 2
      call    VideoIO_Locate
      call    VideoIO_Print
   pop     ax
   cmp     ax, 0ABABh
   je      SSEB_NoWait
   mov     ah, 0
   int     16h     ; Waits for key stroke
  SSEB_NoWait:
   ret
SETUP_ShowErrorBox              EndP

SETUP_EnterMenu_SaveAndExitSetup Proc Near   Uses dx bp
   mov     si, offset TXT_SETUP_SaveAndExitNow
   call    SETUP_Warning_AreYouSure
   jnz     SEMSAES_UserAbort
  SEMSAES_DoThis:
   xor     al, al
   mov     byte ptr [CFG_AutoEnterSetup], al
   add     word ptr [CFG_LastTimeEditLow], 1
   adc     word ptr [CFG_LastTimeEditHi], 0         ; Update Time-Stamp
   IFDEF ReleaseCode
      call    DriveIO_SaveConfiguration
   ENDIF
   mov     byte ptr [SETUP_ExitEvent], 1            ; Exit and continue boot process
  SEMSAES_UserAbort:
   ret
SETUP_EnterMenu_SaveAndExitSetup EndP

SETUP_EnterMenu_ExitWithoutSaving Proc Near   Uses dx bp
   mov     si, offset TXT_SETUP_QuitWithoutSaveNow
   call    SETUP_Warning_AreYouSure
   jnz     SEMEWS_UserAbort
   ; If we were forced to enter Setup, save configuration anyway...
   test    byte ptr [CFG_AutoEnterSetup], 1
   jz      SEMEWS_DoThis
   jmp     SEMEWS_DoThis                 ; Cross-Jump to SaveAndExitSetup!

  SEMEWS_DoThis:
   IFDEF ReleaseCode                     ; Loads basic configuration...
      call    DriveIO_LoadConfiguration  ; This is *NOT* IPT nor HideConfig
   ENDIF
   mov     byte ptr [SETUP_ExitEvent], 1            ; Exit and continue boot process
  SEMEWS_UserAbort:
   ret
SETUP_EnterMenu_ExitWithoutSaving EndP

; Displays and asks user, if he is sure
;        In: SI - Sure about what (string, NUL-terminated)
;       Out: Non-Zero Flag set -> User is sure
; Destroyed: None
SETUP_Warning_AreYouSure        Proc Near
   mov     cx, 0C04h
   call    VideoIO_Color
   call    GetLenOfString                ; CX - Len of Given String
   add     cl, 2+6                       ; Adjust to include Spaces and Frame
   push    cx
      mov     bx, 0B28h
      shr     cl, 1
      sub     bl, cl
   pop     cx
   mov     dh, 0Fh
   mov     dl, bl
   add     dl, cl
   dec     dl
   call    VideoIO_MakeWindow
   mov     cx, 0F04h
   call    VideoIO_Color

   ; Display what the user has to be sure at...
   call    GetLenOfString                ; CX - Len of Given String
   mov     dx, cx
   mov     cx, 0C28h
   call    VideoIO_LocateToCenter        ; LocateToCenter 12, 40 using LenOfStr
   call    VideoIO_Print                 ; Use given string...

   mov     si, offset TXT_SETUP_AreYouSure2
   call    GetLenOfString
   mov     dx, cx
   mov     cx, 0E28h
   call    VideoIO_LocateToCenter        ; LocateToCenter 14, 40 using LenOfStr
   call    VideoIO_Print
   ; Now the 1st Warning sentence, because it should get yellow...
   mov     cx, 0E04h
   call    VideoIO_Color                 ; Yellow on Red
   mov     si, offset TXT_SETUP_AreYouSure1
   call    GetLenOfString
   mov     dx, cx
   mov     cx, 0D28h
   call    VideoIO_LocateToCenter        ; LocateToCenter 13, 40 using LenOfStr
   call    VideoIO_Print

   ; Waits for user-response...
  SWAYS_Loop:
      mov     ah, 0
      int     16h
      and     al, 0DFh
      cmp     al, TXT_SETUP_LetterYes
      je      SWAYS_YES
      cmp     al, TXT_SETUP_LetterYes2
      je      SWAYS_YES
      cmp     al, TXT_SETUP_LetterNo
      je      SWAYS_NO
      jmp     SWAYS_Loop

  SWAYS_YES:
   and     al, 0                         ; Sets Zero-Flag
   ret

  SWAYS_NO:
   or      al, 1                         ; Resets Zero-Flag
   ret
SETUP_Warning_AreYouSure        EndP


;Calling Conventions for Magics:
;================================
; BX - VarPtr
; CH - ItemNo
; CL - 1, add, 0 means subtract
; SI - Pointer to current Item
; Carry Flag - Refresh Item, do not modify

SETUPMAGIC_InternalCopyTillNUL  Proc Near Uses ax cx
  SMICTN_Loop:

    ;!
    ;! DEBUG_PROBE
    ;!
    IFDEF   AUX_DEBUGx
        push    1239h
        call    DEBUG_Probe
        call    DEBUG_DumpRegisters
        call    DEBUG_DumpIPT
    ENDIF

      lodsb
      stosb
      inc     cl
   or      al, al
   jnz     SMICTN_Loop                   ; Copies the string...
   mov     al, 13
   sub     al, cl
   jz      SMICTN_NoFiller
   dec     al

   ;movzx   cx, al
   mov   cl,al
   mov   ch,0

   xor     al, al
   rep     stosb                         ; and fill up with NULs, if required
  SMICTN_NoFiller:
   ret
SETUPMAGIC_InternalCopyTillNUL  EndP

; Cur Value in DL, Maximum Value in DH. Add/Sub in CL
SETUPMAGIC_InternalCheckUp      Proc Near
;!
;! DEBUG_PROBE
;!
IFDEF   AUX_DEBUGx
    push    1238h
    call    DEBUG_Probe
    call    DEBUG_DumpRegisters
ENDIF

   or      cl, cl                        ; CL==0?    -> Decrease
   jz      SMICU_Substract               ; otherwise -> Increase
   inc     dl
   jmp     SMICU_CheckNow
  SMICU_Substract:
   dec     dl
  SMICU_CheckNow:
   cmp     dl, 0FFh
   jne     SMICU_DoNotModifyMin
   mov     dl, dh                        ; -1? -> set to maximum
  SMICU_DoNotModifyMin:
   cmp     dl, dh
   jbe     SMICU_DoNotModifyMax
   xor     dl, dl                        ; Maximum exceeded? -> set 0
  SMICU_DoNotModifyMax:
   ret
SETUPMAGIC_InternalCheckUp      EndP

SETUPMAGIC_EnableDisable        Proc Near   Uses ax si es di
   mov     al, ds:[bx]
   jc      SMED_DoNotModify
   xor     al, 1                         ; Do Flip-Flop :)
  SMED_DoNotModify:
   mov     ds:[bx], al
   mov     di, si
   mov     si, offset TXT_SETUP_MAGIC_Enabled
   or      al, al
   jnz     SMED_Enabled
   mov     si, offset TXT_SETUP_MAGIC_Disabled
  SMED_Enabled:
   push    cs
   pop     es
   add     di, LocMENU_ItemPack          ; DI points to ItemPack...
   call    SETUPMAGIC_InternalCopyTillNUL
   ret
SETUPMAGIC_EnableDisable        EndP

SETUPMAGIC_ChangeBootDelay      Proc Near   Uses ax cx dx ds si es di
   mov     dl, ds:[bx]                   ; Current Partition Number
   jc      SMCBD_DoNotModify
   mov     dh, 0FFh
   call    SETUPMAGIC_InternalCheckUp    ; CheckUp DL (max. 255)
  SMCBD_DoNotModify:
   mov     ds:[bx], dl
   mov     cx, 1A01h
   call    VideoIO_Locate
   mov     ax, VideoIO_Segment
   mov     es, ax
   mov     di, 4000
   mov     cx, 8
   xor     al, al
   rep     stosb                         ; Writes 8x NUL
   mov     al, dl
   call    VideoIO_PrintByteDynamicNumber
   ; Pseudo-(XCHG DS, ES)
   push    ds
   push    es
   pop     ds
   pop     es

   mov     di, si
   add     di, LocMENU_ItemPack          ; ES:DI - ItemPack
   mov     si, 4000                      ; DS:SI - Screen Page 1
   push    es
   push    di
      mov     cx, 4
     SMCBD_Loop:
         lodsw
         stosb
      loop    SMCBD_Loop                 ; okay we got it...trick!
   ; DS:SI - ItemPack
   pop     si
   pop     ds
   mov     cx, 12
   call    GetLenOfName                  ; Gets the length of the number
   add     si, cx
   mov     al, 0FFh
   mov     ds:[si], al                   ; and a Filler as last char (looks better)
   ret
SETUPMAGIC_ChangeBootDelay      EndP

; Used by : Default Selection
; Value   : Partition Number (Base=0, None=80h, ContinueBIOS=FEh, Floppy=FFh)
; Method  : Changes to another bootable partition
; Logic   : if no bootable selections are found -> will set 80h
;           if already set to 80h -> will search through all selections
SETUPMAGIC_ChangeDefaultSelection Proc Near   Uses ax cx dx si es di
   mov     di, si
   mov     dl, ds:[bx]                   ; Cur Selection No.
   push    bx
      pushf
         cmp     dl, 080h
         jne     SMCP_AlreadyGotSelection
         ; Start at partition 0. So Continue-BIOS and Floppy will go last
         xor     dl, dl
        SMCP_AlreadyGotSelection:
         ; We use BL in here for tracking how many selections left
         mov     bl, [CFG_Partitions]
         cmp     dl, 0FEh
         jb      SMCP_DoneAdjust
         je      SMCP_AdjustContinueBIOS
         cmp     byte ptr [CFG_IncludeFloppy], 0
         jne     SMCP_DoneAdjust
         dec     dl                      ; No Floppy? -> Try Resume-BIOS
        SMCP_AdjustContinueBIOS:
         cmp     byte ptr [CFG_ResumeBIOSbootSeq], 0
         jne     SMCP_DoneAdjust
         xor     dl, dl                  ; No Resume-BIOS? -> Start partition 0
        SMCP_DoneAdjust:
         mov     dh, bl
         inc     bl
         dec     dh
         or      cl, cl                        ; CL==0?    -> Decrease
         jz      SMCP_SubstractSelection       ; otherwise -> Increase
      popf
      jc      SMCP_Dec_ModifyDone
     SMCP_Inc_RejectPartition:
      inc     dl                         ; Increase Selection No
      cmp     dl, [CFG_Partitions]
      jb      SMCP_Inc_ModifyDone
      cmp     dl, 0FFh
      je      SMCP_Inc_TryFloppy
      mov     dl, 0FEh                   ; Try Resume-BIOS
      cmp     byte ptr [CFG_ResumeBIOSbootSeq], 0
      jne     SMCP_Inc_ModifyDone
      inc     dl                         ; Try Floppy
     SMCP_Inc_TryFloppy:
      cmp     byte ptr [CFG_IncludeFloppy], 0
      jne     SMCP_Inc_ModifyDone
      cmp     byte ptr [CFG_Partitions], 0
      je      SMCP_NoBootable
      inc     dl                         ; Now start at partition 0 again
     SMCP_Inc_ModifyDone:
      dec     bl
      jz      SMCP_NoBootable
      ; Get Partition-Pointer (SI) from Partition-Number (DL)
      call    PART_GetPartitionPointer
      mov     ax, ds:[si+LocIPT_Flags]
      test    ax, Flags_Bootable
      jz      SMCP_Inc_RejectPartition
      jmp     SMCP_GotSelection

     SMCP_SubstractSelection:
      popf
      jc      SMCP_Dec_ModifyDone
     SMCP_Dec_RejectPartition:
      dec     dl                         ; Decrease Selection No
      cmp     dl, 0FDh
      jb      SMCP_Dec_ModifyDone        ; <FDh -> We are done
      je      SMCP_Dec_TryPartition
      cmp     dl, 0FFh
      jb      SMCP_Dec_TryResumeBIOS
      cmp     byte ptr [CFG_IncludeFloppy], 0
      jne     SMCP_Dec_ModifyDone
      dec     dl
     SMCP_Dec_TryResumeBIOS:
      cmp     byte ptr [CFG_ResumeBIOSbootSeq], 0
      jne     SMCP_Dec_ModifyDone
     SMCP_Dec_TryPartition:
      mov     dl, [CFG_Partitions]
      or      dl, dl
      jz      SMCP_NoBootable
      dec     dl                         ; Now start at last partition again
     SMCP_Dec_ModifyDone:
      dec     bl
      jz      SMCP_NoBootable
      ; Get Partition-Pointer (SI) from Partition-Number (DL)
      call    PART_GetPartitionPointer
      mov     ax, ds:[si+LocIPT_Flags]
      test    ax, Flags_Bootable
      jz      SMCP_Dec_RejectPartition

     SMCP_GotSelection:
   pop     bx
   mov     ds:[bx], dl                   ; Set new partition
   add     si, LocIPT_Name               ; Location of Name
   push    cs
   pop     es
   add     di, LocMENU_ItemPack          ; DI points to ItemPack...
   mov     cx, 11
   rep     movsb                         ; Copy cur PartitionName to ItemPack
   xor     al, al
   stosb                                 ; Ending Zero :)
   ret

     SMCP_NoBootable:
   pop     bx
   mov     dl, 080h                      ; "No Bootable"
   mov     ds:[bx], dl                   ; set that one
   mov     si, offset TXT_SETUP_MAGIC_NoBootable
   push    cs
   pop     es
   add     di, LocMENU_ItemPack
   call    SETUPMAGIC_InternalCopyTillNUL
   ret
SETUPMAGIC_ChangeDefaultSelection EndP

; [Linux support removed since v1.02]
;SETUPMAGIC_ChangeLinuxKernelPart Proc Near   Uses ax cx dx si es di
;   mov     di, si
;   mov     dl, ds:[bx]                   ; Cur Partition No.
;   push    bx
;      jc      SMCLKP_DoNotModify
;     SMCLKP_NowGoOn:
;      mov     dh, CFG_Partitions         ; CFG_Partitions is Base==1
;      inc     dl                         ; +1 -> 00h instead FFh -> Disabled
;     SMCLKP_RejectPartition:
;      call    SETUPMAGIC_InternalCheckUp ; CheckUp DL (max. CFG_Partitions)
;     SMCLKP_DoNotModify:
;      or      dl, dl
;      jz      SMCLKP_FunctionDisabled
;      ; Get Partition-Pointer (SI) to Partition-To-Boot (DL)
;      dec     dl
;      call    PART_GetPartitionPointer
;      inc     dl
;      cmp     bptr ds:[si+LocIPT_SystemID], 06h ; FAT-16 required
;      jne     SMCLKP_RejectPartition
;   pop     bx
;   add     si, LocIPT_Name               ; Location of Name
;   push    cs
;   pop     es
;   add     di, LocMENU_ItemPack          ; DI points to ItemPack
;   mov     cx, 11
;   rep     movsb                         ; Copy cur PartitionName to ItemPack
;   xor     al, al
;   stosb                                 ; Ending Zero
;  SMCLKP_WriteNewValue:
;   dec     dl
;   mov     ds:[bx], dl                   ; Set new partition number
;   ret
;
;     SMCLKP_FunctionDisabled:
;   pop     bx
;   mov     si, offset TXT_SETUP_MAGIC_Disabled
;   push    cs
;   pop     es
;   add     di, LocMENU_ItemPack          ; DI points to ItemPack...
;   call    SETUPMAGIC_InternalCopyTillNUL
;   jmp     SMCLKP_WriteNewValue
;SETUPMAGIC_ChangeLinuxKernelPart EndP

; [Linux support removed since v1.02]
;SETUPMAGIC_ChangeLinuxRootPart  Proc Near   Uses ax cx dx si es di
;   mov     di, si
;   pushf                                 ; lame, but it's not working other ways
;      test    ds:[GotLinux], 1
;      jnz     SMCLRP_GotLinux
;   popf
;   add     di, LocMENU_ItemPack          ; DI points to ItemPack
;   mov     si, offset TXT_SETUP_MAGIC_NoLinux
;   push    cs
;   pop     es
;   call    SETUPMAGIC_InternalCopyTillNUL
;   ret
;     SMCLRP_GotLinux:
;      mov     dl, ds:[bx]                ; Cur Partition No.
;      mov     dh, CFG_Partitions
;      dec     dh
;   popf
;   push    bx
;      jc      SMCLRP_DoNotModify         ; Thou shall not modify :)
;     SMCLRP_RejectPartition:
;      call    SETUPMAGIC_InternalCheckUp ; CheckUp DL (max. CFG_Partitions-1)
;     SMCLRP_DoNotModify:
;      ; Get Partition-Pointer (SI) to Partition-To-Boot (DL)
;      call    PART_GetPartitionPointer
;      cmp     bptr ds:[si+LocIPT_SystemID], 083h
;      jne     SMCLRP_RejectPartition
;   pop     bx
;   mov     ds:[bx], dl
;   push    cs
;   pop     es
;   add     di, LocMENU_ItemPack          ; DI points to ItemPack...
;   push    di
;      mov     cx, 12
;      xor     al, al
;      rep     stosb                      ; Fill with NULs
;   pop     di
;   call    LINUX_TranslateToDEV          ; now translate thingie (DL)
;   ret
;SETUPMAGIC_ChangeLinuxRootPart  EndP

; [Linux support removed since v1.02]
; CH-ItemNo, CL-Add/Sub, BX-PtrToVariable, SI-ItemPack
;SETUPMAGIC_ChangeLinuxDefaultKernel Proc Near   Uses ax cx dx si es di
;   mov     di, si
;   jc      SMCLDK_DoNotEdit
;
;   ; --- Edit Linux Default Kernel Name ---
;   mov     cl, 29                        ; Left side: 29
;   test    ch, 1000b
;   jz      SMCLDK_NoRightSide
;   and     ch, 111b
;   mov     cl, 68                        ; Right side: 68
;  SMCLDK_NoRightSide:
;   add     ch, 6                         ; Koordinate umberechnen
;   push    cx
;      call    VideoIO_Locate
;      mov     cx, 0E01h
;      call    VideoIO_Color              ; Yellow on Blue
;      mov     cl, 12
;      mov     si, offset CFG_LinuxDefaultKernel
;      call    VideoIO_FixedPrint         ; Print out [SI] (Length = CL)
;   pop     cx
;   call    VideoIO_Locate
;   mov     cl, 11
;   mov     si, offset CFG_LinuxDefaultKernel
;   call    VideoIO_LetUserEditString
;
;   ; Final-Process string (which means upper-case it)
;   mov     cl, 11
;  SMCLDK_FinalProcessLoop:
;      mov     al, bptr ds:[si]
;      cmp     al, 'a'
;      jb      SMCLDK_FinalProcessSkip
;      cmp     al, 'z'
;      ja      SMCLDK_FinalProcessSkip
;      sub     al, 20h
;     SMCLDK_FinalProcessSkip:
;      mov     bptr ds:[si], al
;      inc     si
;   dec     cl
;   jnz     SMCLDK_FinalProcessLoop
;   ; --- End of Edit Linux Default Kernel Name ---
;
;  SMCLDK_DoNotEdit:
;   push    cs
;   pop     es
;   add     di, LocMENU_ItemPack          ; DI points to ItemPack...
;   mov     si, offset CFG_LinuxDefaultKernel
;   mov     cx, 6                         ; Copy from CFG-Space to ItemPack
;   rep     movsw
;   ret
;SETUPMAGIC_ChangeLinuxDefaultKernel EndP

SETUPMAGIC_ChangeTimedKeyHandling Proc Near   Uses ax cx dx ds si es di
   mov     di, si
   mov     dl, ds:[bx]                   ; Cur Timed-Key-Handling
   jc      SMCTKH_DoNotModify
   mov     dh, 02h
   call    SETUPMAGIC_InternalCheckUp    ; CheckUp DL (max. 2)
  SMCTKH_DoNotModify:
   mov     ds:[bx], dl
   cmp     dl, 1
   jb      SMCTKH_Is0
   je      SMCTKH_Is1
   ; ist 2 vermutlich ;)
   mov     si, offset TXT_SETUP_MAGIC_StopTime
   jmp     SMCTKH_CopyThiz
  SMCTKH_Is0:
   mov     si, offset TXT_SETUP_MAGIC_DoNothing
   jmp     SMCTKH_CopyThiz
  SMCTKH_Is1:
   mov     si, offset TXT_SETUP_MAGIC_ResetTime
  SMCTKH_CopyThiz:
   add     di, LocMENU_ItemPack          ; DI points to ItemPack...
   push    cs
   pop     es
   call    SETUPMAGIC_InternalCopyTillNUL
   ret
SETUPMAGIC_ChangeTimedKeyHandling EndP

SETUPMAGIC_ChangeBootMenu       Proc Near   Uses ax cx dx ds si es di
   mov     di, si
   mov     dl, ds:[bx]                   ; Cur Boot-Menu state
   jc      SMCBM_DoNotModify
   mov     dh, 02h
   call    SETUPMAGIC_InternalCheckUp    ; CheckUp DL (max. 2)
  SMCBM_DoNotModify:
   mov     ds:[bx], dl
   cmp     dl, 1
   jb      SMCBM_Is0
   je      SMCBM_Is1
   ; ist 2 vermutlich ;)
   mov     si, offset TXT_SETUP_MAGIC_Detailed
   jmp     SMCBM_CopyThiz
  SMCBM_Is0:
   mov     si, offset TXT_SETUP_MAGIC_Disabled
   jmp     SMCBM_CopyThiz
  SMCBM_Is1:
   mov     si, offset TXT_SETUP_MAGIC_Enabled
  SMCBM_CopyThiz:
   add     di, LocMENU_ItemPack          ; DI points to ItemPack...
   push    cs
   pop     es
   call    SETUPMAGIC_InternalCopyTillNUL
   ret
SETUPMAGIC_ChangeBootMenu       EndP

SETUPMAGIC_ChangeFloppyDisplay  Proc Near   Uses cx dx si es di
   call    SETUPMAGIC_EnableDisable      ; forward call
   cmp     byte ptr [CFG_PartDefault], 0FFh         ; Default-Selection is us?
   jne     SMCFD_Done
   xor     ch, ch
   mov     CFG_PartDefault, ch           ; Reset Default-Selection to 1st part
   ; We need to fill up Item 0 (Default-Selection)...
   call    SETUP_FillUpItemPack_Now
   ; ...and display it on screen (so the user thinks that we are not dumb)
   ; This is hardcoded, but there is no other way.
   xor     dl, dl
   call    SETUP_DrawDeSelectItem        ; Redraw Item 0
  SMCFD_Done:
   ret
SETUPMAGIC_ChangeFloppyDisplay  EndP

SETUPMAGIC_ChangeBIOSbootSeq    Proc Near   Uses ax bx cx dx si di
;!
;! DEBUG_PROBE
;!
IFDEF   AUX_DEBUGx
    push    1237h
    call    DEBUG_Probe
    call    DEBUG_DumpRegisters
ENDIF

   mov     di, si
   mov     dl, ds:[bx]                   ; Cur Timed-Key-Handling
   jc      SMCBBS_DoNotModify
   mov     dh, 3
   call    SETUPMAGIC_InternalCheckUp    ; CheckUp DL (max. 3)
  SMCBBS_DoNotModify:
   mov     ds:[bx], dl
   ; DL - Current value
   or      dl, dl
   jnz     SMCBBS_Enabled
   mov     si, offset TXT_SETUP_MAGIC_Disabled
   cmp     byte ptr [CFG_PartDefault], 0FEh         ; Default-Selection is us?
   jne     SMCBBS_CopyThiz
   mov     CFG_PartDefault, dl           ; Reset Default-Selection to 1st part
   jmp     SMCBBS_CopyThiz
  SMCBBS_Enabled:
   dec     dl

   ;movzx   bx, dl
   mov   bl,dl
   mov   bh,0

   shl     bx, 1
   mov     si, word ptr [ContinueBIOSbootTable+bx]
  SMCBBS_CopyThiz:
   add     di, LocMENU_ItemPack          ; DI points to ItemPack...
   push    cs
   pop     es
   call    SETUPMAGIC_InternalCopyTillNUL
   ; Copy device-name to the ContBIOSbootSeq-IPT entry
   call    PART_UpdateResumeBIOSName
   ret
SETUPMAGIC_ChangeBIOSbootSeq    EndP
