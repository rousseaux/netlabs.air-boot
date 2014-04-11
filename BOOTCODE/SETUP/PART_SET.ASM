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
;                                          AiR-BOOT SETUP / PARTITION SETUP
;---------------------------------------------------------------------------

IFDEF ModuleNames
DB 'PART_SET',0
ENDIF

; This here is called from Menu in AIR-BSET.asm
PARTSETUP_Main                  Proc Near
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
      cmp     ah, Keys_ENTER
      je      PSM_KeyENTER
      ; Flags-Change
      and     al, 0DFh                    ; Upper-Case Input
      cmp     al, TXT_SETUP_FlagLetterBootable
      je      PSM_KeyBootAble
      cmp     al, TXT_SETUP_FlagLetterVIBR
      je      PSM_KeyVIBRdetection
      cmp     al, TXT_SETUP_FlagLetterHide

      jne   skip_x
      jmp      PSM_KeyHiddenSetup
   skip_x:
      cmp     al, TXT_SETUP_FlagLetterDrvLetter

      jne   skip_y
      jmp      PSM_KeyDriveLetterForceSetup
   skip_y:

      cmp     al, TXT_SETUP_FlagLetterExtMShack
      jne   skip_z
      jmp      PSM_KeyDriveLetterExtMShack
   skip_z:
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

    ; Disabling editing for type 0x35 is currently implemented
    ; in PARTSETUP_ChangePartitionName.
  PSM_KeyENTER:
   call    PARTSETUP_ChangePartitionName
   ; Rebuild Menu...
   call    PARTSETUP_DrawMenuBase
   call    PARTSETUP_RefreshPartitions
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop

  PSM_KeyBootAble:
   call    PART_GetPartitionPointer      ; Gets Partition (DL) Pointer -> SI
   ; See if this is an eCS LVM Volume.
   ; In that case, we don't allow it to be made bootable.
   ; We also show a popup to inform the user.
   call    PARTSETUP_IsType35
   je      PSM_KeyBootAble_istype35

  PSM_KeyBootAble_notype35:
   mov     al, [si+LocIPT_Flags]
   xor     al, Flags_Bootable
   mov     [si+LocIPT_Flags], al
   call    PARTSETUP_DrawPartitionInfo
   call    PARTSETUP_BuildChoiceBar
  PSM_KeyBootAble_istype35:
   jmp     PSM_MainLoop

  PSM_KeyVIBRdetection:
   call    PART_GetPartitionPointer      ; Gets Partition (DL) Pointer -> SI
   mov     al, [si+LocIPT_Flags]
   xor     al, Flags_VIBR_Detection
   mov     [si+LocIPT_Flags], al
   xor     ax, ax
   mov     wptr [si+LocIPT_BootRecordCRC], ax
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
   mov     al, [si+LocIPT_Flags]
   xor     al, Flags_ExtPartMShack
   mov     [si+LocIPT_Flags], al
   call    PARTSETUP_DrawPartitionInfo
   call    PARTSETUP_BuildChoiceBar
   jmp     PSM_MainLoop
PARTSETUP_Main                  EndP


; See if this is a partition of type 0x35 and display error
; when user tries to set it as bootable.
; IN:   SI = Pointer to partition
; OUT:  ZF = Set if 0x35, clear otherwise
PARTSETUP_IsType35      Proc    Near
   mov     al, [si+LocIPT_SystemID]
   cmp     al, 35h
   jne     PARTSETUP_IsType35_end
   pushf
   pusha
   ; Cannot boot LVM-Data partitions
   mov     cx, 0C04h
   mov     si, offset TXT_SETUP_NoBootType35
   call    SETUP_ShowErrorBox
   popa
   call    PARTSETUP_DrawMenuBase
   call    PARTSETUP_RefreshPartitions
   call    PARTSETUP_BuildChoiceBar
   popf
  PARTSETUP_IsType35_end:
   ret
PARTSETUP_IsType35      EndP


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

   mov     si, offset TXT_SETUPHELP_PartSetup
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
   mov     al, [si+LocIPT_Drive]
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
   pop     si
   pop     cx

   ; Display "Flags" field aka "BVHL"
   add     cl, 13
   call    VideoIO_Locate
   ; This is using a sub-routine for each flag. Is better that way.
   mov     bl, [si+LocIPT_Flags]
   mov     bh, bl
   mov     al, TXT_SETUP_FlagLetterBootable
   and     bl, Flags_Bootable
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
   mov     al, [si+LocIPT_SystemID]
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
PARTSETUP_BuildChoiceBar        Proc Near
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
; Destroyed: ax bx cx
PARTSETUP_ChangePartitionName   Proc Near   Uses dx ds si di
   push    ds
   pop     es                            ; we need DS==ES in here for MOVSB etc.
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

   mov     ChangePartNameSave, 0         ; Don't save to BR / LVM Sector

   ; We compare, if our IPT contains the same partition name as in BR or LVM
   ;  This is done for security purposes, because if they match, we will update
   ;  the name in both - IPT and BR/LVM.

   ;movzx   bx, dl
   mov   bl,dl
   mov   bh,0

   cmp     [PartitionVolumeLetters+bx], 0 ; ==0 means not supported by LVM
   je      PSCPN_NotLVMSupported

   ; ------------------------------------------------------------[LVM CHECK]---
   ; Load LVM-Sector here and seek to PartitionName
   ; Set CurPartition_Location information of destination partition
   mov     ax, wptr [si+LocIPT_AbsolutePartTable]
   mov     wptr [CurPartition_Location+0], ax
   mov     ax, wptr [si+LocIPT_AbsolutePartTable+2]
   mov     wptr [CurPartition_Location+2], ax
   mov     ah, bptr [si+LocIPT_LocationPartTable+0]
   mov     al, [si+LocIPT_Drive]
   mov     wptr [CurPartition_Location+4], ax
   mov     ax, wptr [si+LocIPT_LocationPartTable+1]
   mov     wptr [CurPartition_Location+6], ax
   mov     di, si                        ; Put SI into DI
   call    DriveIO_LoadLVMSector
   jnc     PSCPN_LVMGotError             ; Security again, if problem -> halt
   push    dx
      mov     ax, wptr [di+LocIPT_AbsoluteBegin]
      mov     dx, wptr [di+LocIPT_AbsoluteBegin+2]
      call    LVM_SearchForPartition
   pop     dx
   jnc     PSCPN_LVMGotError             ; Not Found? -> display error and halt

    ;
    ; While AiR-BOOT v1.0.8+ displays the LVM VolumeName, the LVM PartitionName
    ; is used here to compare to the IPT.
    ; The IPT has the LVM VolumeName, so if they differ the compare will fail
    ; and the user-entry will noy be written to the LVM-info sector.
    ;
   add     si, LocLVM_PartitionName


   xchg    si, di                        ; SI-IPTEntry, DI-LVM PartName
   jmp     PSCPN_CheckPartName           ; Check, if match...

  PSCPN_LVMGotError:
   jmp     MBR_LoadError



;   mov     si, di                        ; Restore SI and bootrecord fall-back
  PSCPN_NotLVMSupported:
   ; ----------------------------------------------------[BOOT-RECORD CHECK]---
   ; Load Boot-Record...
   push    dx
      mov     ax, wptr [si+LocIPT_AbsoluteBegin+0]
      mov     bx, wptr [si+LocIPT_AbsoluteBegin+2]
      mov     cx, [si+LocIPT_LocationBegin+1]
      mov     dh, [si+LocIPT_LocationBegin+0]
      mov     dl, [si+LocIPT_Drive]
      call    DriveIO_LoadPartition
   pop     dx

   ; We seek to Partition Label within boot-record here
   mov     di, offset PartitionSector

   push    si
      mov     al, [si+LocIPT_SystemID]
      call    PART_SearchFileSysName
      ; Replies AH - FileSysFlags, AL - UnhiddenID, SI - FileSysNamePtr
   pop     si

   test    ah, FileSysFlags_NoName       ; If NoName by FileSysFlag
   jnz     PSCPN_LetUserEditPartName     ;  -> don't put it into BR at anytime
   test    ah, FileSysFlags_FAT32        ; FAT32 specific name getting
   jz      PSCPN_ResumeNormal
   add     di, 1Ch                       ; Fix for FAT 32, shit
  PSCPN_ResumeNormal:
   add     di, 2Bh                       ; ES:DI - Name of Partition





   ; This code is used for BR and LVM checking
   ; Rousseau: Because AiR-BOOT v1.0.8 uses the LVM_VolumeName, which is copied
   ; to the IPT, this compare fails when the LVM_PartitionName is not
   ; the same as the LVM_VolumeName.
   ; This is a protection against editing the Label when these names differ.
   ; MiniLVM assigns the same value to both, so partitions created with MiniLVM
   ; can be edited.
  PSCPN_CheckPartName:

  ; SI = IPT_Enty

        ; If the partition is an LVM partition then disable editing completely.
        cmp     byte ptr [si+LocIPT_SystemID], 035h
        jnz     no_type_35h

   ; Cannot boot LVM-Data partitions
   pusha
   mov     cx, 0C04h
   mov     si, offset TXT_SETUP_NoEditType35
   call    SETUP_ShowErrorBox
   popa


        jmp     PSCPN_AllDone
    no_type_35h:

   mov     cx, 11                        ; Partition-Name-Length = 11 Bytes
   push    si
   push    di
      add     si, LocIPT_Name            ; DS:SI -> Partition-Name
      repz    cmpsb
   pop     di
   pop     si
   jne     PSCPN_LetUserEditPartName     ; -> No BR/LVM Changing/Saving

   mov     ChangePartNameSave, 1         ; Remember, so we will save to BR

  PSCPN_LetUserEditPartName:
   ; User will now edit the volume label...
   mov     cx, 11
   add     si, LocIPT_Name               ; DS:SI -> Partition-Name
   call    VideoIO_LetUserEditString     ; -> does actual editing
   jnc     PSCPN_AllDone                 ; Did user abort ?

   test    ChangePartNameSave, 1
   jz      PSCPN_AllDone                 ; Actually we just skip BR/LVM-Save

   ; Check, where to save 2nd destination to...

   ;movzx   bx, dl
   mov   bl,dl
   mov   bh,0

   cmp     [PartitionVolumeLetters+bx], 0 ; ==0 means not supported by LVM
   je      PSCPN_SaveBootRecord


   ; Make DI point to LVM VolumeName in LVM-entry
   sub     di,20

   ; -------------------------------------------------[LVM SAVE VOLUME NAME]---
   ; Copy 11 bytes from IPT into LVM VolumeName, back-padd with zero's
   mov     cx, 11
   push    si
      rep     movsb
   pop     si
   xor     al, al
   mov     cx, 9
   rep     stosb


        ;
        ; The AiR-BOOT Label Editor inserts spaces when a label is edited
        ; and characters are backspaced.
        ; This is fine for filesystem labels, which are space padded,
        ; but the LVM VolumeName and PartitionName need to be zero padded.
        ; So, below we replace all trailing spaces with zero's.
        ;
        ; Correct LVM VolumeName
        ;
        push    di
        mov     cx,20
    vn_padd_next:
        jcxz    vn_padded
        dec     di
        dec     cx
        mov     al,[di]
        test    al,al
        jz      vn_padd_next
        cmp     al,' '
        jnz     vn_padded
        mov     byte ptr [di],0
        jmp     vn_padd_next
    vn_padded:
        pop     di




   ; ----------------------------------------------[LVM SAVE PARTITION NAME]---
   ; Copy 11 bytes from IPT into LVM PartitionName, back-padd with zero's
   mov     cx, 11
   push    si
      rep     movsb
   pop     si
   xor     al, al
   mov     cx, 9
   rep     stosb


        ;
        ; The AiR-BOOT Label Editor inserts spaces when a label is edited
        ; and characters are backspaced.
        ; This is fine for filesystem labels, which are space padded,
        ; but the LVM VolumeName and PartitionName need to be zero padded.
        ; So, below we replace all trailing spaces with zero's.
        ;
        ; Correct LVM PartitionName
        ;
        push    di
        mov     cx,20
    pn_padd_next:
        jcxz    pn_padded
        dec     di
        dec     cx
        mov     al,[di]
        test    al,al
        jz      pn_padd_next
        cmp     al,' '
        jnz     pn_padded
        mov     byte ptr [di],0
        jmp     pn_padd_next
    pn_padded:
        pop     di


   ; Update LVM-CRC now...
   mov     si, offset LVMSector
   call    LVM_UpdateSectorCRC
   IFDEF ReleaseCode
      call    DriveIO_SaveLVMSector      ; Save sector
   ENDIF
   jmp     PSCPN_AllDone

   ; -----------------------------------------------------[BOOT-RECORD SAVE]---
  PSCPN_SaveBootRecord:
   ; Copy 11 bytes from IPT to Boot-Record
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

  PSCPN_AllDone:
   ; This here is done for safety, because we misused CurPartition_Location
   xor     ax, ax
   mov     di, offset CurPartition_Location
   mov     cx, 4
   rep     stosw                         ; NUL out CurPartition_Location
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
      cmp     ah, Keys_ENTER
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
   mov     al, [si+LocIPT_Flags]
   xor     al, Flags_SpecialMarker
   mov     [si+LocIPT_Flags], al
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

CLR_PART_HIDE_WINDOW_BASE_CLASSIC   = 0d05h
CLR_PART_HIDE_WINDOW_BASE_BM   = 0a02h

   mov     cx, CLR_PART_HIDE_WINDOW_BASE_BM                    ; Lila on lila
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

CLR_PART_HIDE_WINDOW_LABEL_CLASSIC = 0e05h
CLR_PART_HIDE_WINDOW_LABEL_BM = 0e02h

   mov     cx, CLR_PART_HIDE_WINDOW_LABEL_BM                     ; Yellow on Lila
   call    VideoIO_Color
   mov     si, offset TXT_SETUP_HideFeature
   call    VideoIO_Print

CLR_PART_HIDE_WINDOW_BORDER_CLASSIC = 0d05h
CLR_PART_HIDE_WINDOW_BORDER_BM = 0d02h


   mov     cx, CLR_PART_HIDE_WINDOW_BORDER_BM                     ; Lila on lila
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
   push    cx
   push    si                         ; SI == Label Field
      mov     cx, dx
      call    VideoIO_Locate
      mov     al, '<'
      call    VideoIO_PrintSingleChar
      mov     si, offset TXT_SETUP_HideFeature2
      call    VideoIO_Print
   pop     si
   pop     cx
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

CLR_PART_HIDE_MENU_BASE_CLASSIC  = 0f05h
CLR_PART_HIDE_MENU_BASE_BM  = 0f02h

   mov     cx, CLR_PART_HIDE_MENU_BASE_BM                     ; Yellow on Lila
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

CLR_PART_HIDE_MENU_MARKERS_CLASSIC = 0d05h
CLR_PART_HIDE_MENU_MARKERS_BM = 0a02h

   ; At last calculate Scroll-Markers
   mov     cx, CLR_PART_HIDE_MENU_MARKERS_BM                     ; Lila on lila                          ; Hide Feature Markers
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

CLR_PART_HIDE_LABEL_CLASSIC   = 0f05h
CLR_PART_HIDE_LABEL_BM = 0f02h

      mov     cx, CLR_PART_HIDE_LABEL_BM
      call    VideoIO_Color              ; Bright White on Lila
      push    si
         add     si, LocIPT_Name
         mov     cx, 11
         call    GetLenOfName
         call    VideoIO_FixedPrint
      pop     si

CLR_PART_HIDE_WINDOW_FS_CLASSIC   = 0d05h
CLR_PART_HIDE_WINDOW_FS_BM = 0a02h

      mov     cx, CLR_PART_HIDE_WINDOW_FS_BM
      call    VideoIO_Color              ; Bright Lila on Lila
      mov     al, ' '
      call    VideoIO_PrintSingleChar
      mov     al, '['
      call    VideoIO_PrintSingleChar
      ; Display "Type" field aka "HPFS" without ending NULs/Spaces
      push    si
         mov     al, [si+LocIPT_SystemID]
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

CLR_PART_HIDE_WINDOW_CHOISES_CLASSIC   = 0e05h
CLR_PART_HIDE_WINDOW_CHOISES_BM   = 0e02h

      mov     cx, CLR_PART_HIDE_WINDOW_CHOISES_BM
      call    VideoIO_Color              ; Yellow on Lila
      mov     al, ' '
      mov     cl, 10
      call    VideoIO_PrintSingleMultiChar ; Fill up area with spaces
      ; Finally draw Hidden/Unhidden
      mov     bl, [si+LocIPT_Flags]
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
PARTHIDESETUP_BuildChoiceBar    Proc Near
   cmp     dl, dh
   je      PHSBCB_SkipRetrace
   call    VideoIO_WaitRetrace
  PHSBCB_SkipRetrace:

CLR_PART_HIDE_WINDOW_MENU_BAR_CLASSIC  = 5eh
CLR_PART_HIDE_WINDOW_MENU_BAR_BM = 2eh

   ; Deactivate current active bar
   mov     cl, CLR_PART_HIDE_WINDOW_MENU_BAR_BM                       ; Yellow on Lila
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

CLR_PART_HIDE_WINDOW_MENU_ACTIVE_BAR_CLASSIC = 1fh
CLR_PART_HIDE_WINDOW_MENU_ACTIVE_BAR_BM   = 1fh

   mov     cl, CLR_PART_HIDE_WINDOW_MENU_ACTIVE_BAR_BM                       ; Bright White on Blue
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
   mov     al, [si+LocIPT_Flags]
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
      mov     dl, [di]
      inc     di
      cmp     dl, 0FFh
      je      PHSGHCAS_EndOfEntries
      call    PART_GetPartitionPointer   ; Pointer for partition DL to SI
      mov     al, [si+LocIPT_Flags]
      or      al, Flags_SpecialMarker    ; Set marker
      mov     [si+LocIPT_Flags], al
   dec     cl
   jnz     PHSGHCAS_SpreadLoop
  PHSGHCAS_EndOfEntries:
   ret
PARTHIDESETUP_GetHideConfigAndSpread EndP

; This is called by MBRS_PS_HiddenSetup
;        In: DL - Partition, where to save Hide-Config
; Destroyed: None, but Locate-Pointer
PARTHIDESETUP_CollectHideConfigAndPutToTable Proc Near Uses ax si es di         ; checken !
   ; First calculate, where to put Hide-Config
   mov     ax, LocIPT_MaxPartitions
   mul     dl
   push    cs
   pop     es
   mov     di, offset HidePartitionTable
   add     di, ax                        ; We got the pointer
   push    di
   push    di
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
         mov     bl, [si+LocIPT_Flags]
         test    bl, Flags_SpecialMarker
         jz      PHSCHCAPTT_NoMarker
         mov     ds:[di], ch             ; Write byte-Entry
         inc     di
         xor     bl, Flags_SpecialMarker ; Reset Flag
         mov     [si+LocIPT_Flags], bl
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
   mov     al, [si+LocIPT_Flags]
   mov     ah, Flags_HideFeature
   not     ah
   and     al, ah
   mov     [si+LocIPT_Flags], al
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
   mov     al, [si+LocIPT_Flags]
   or      al, Flags_HideFeature
   mov     [si+LocIPT_Flags], al
   ret
PARTHIDESETUP_CollectHideConfigAndPutToTable EndP

; =============================================================================

; This is called from MBRS_Routines_PartitionSetup
;        In: DL - Partition to LogicalDriveLetter-Setup
; Destroyed: ax
PARTSETUP_DriveLetterSetup      Proc Near  Uses dx si es di
   call    PART_GetPartitionPointer      ; Gets the PartitionPointer for DL in SI
   ; SystemID must support DriveLetter feature (FAT16, HPFS, JFS)
   mov     al, bptr [si+LocIPT_SystemID]
   push    si
      call    PART_SearchFileSysName
   pop     si
   test    ah, FileSysFlags_DriveLetter
   jnz     PSDLS_GotLDLP

   ; Drive-Letter feature only possible on HPFS/FAT16 (OS/2) systems
   mov     cx, 0C04h
   mov     si, offset TXT_SETUP_NoLDLpartition
   call    SETUP_ShowErrorBox
   ret

  PSDLS_GotLDLP:
   ; First build up menu and display current setting...
   call    PARTSETUPDL_DrawMenuBase      ; DL - partition-no

   ; Now get the Logical-Drive-Letter for that partition...
   ;movzx   bx, dl
   mov   bl,dl
   mov   bh,0

   mov     dl, bptr [DriveLetters+bx]

   push    bx
      ; DS:SI - IPT Entry of Partition, DL - LogicalDriveLetter
      call    PARTSETUPDL_DrawDriveLetter

      ; Now we got everything on-the-screen
     PSDLS_MainLoop:
         mov     ah, 0
         int     16h
         cmp     ah, Keys_Backspace
         je      PSDLS_BackSpace
         cmp     ah, Keys_Up
         je      PSDLS_KeyUp
         cmp     ah, Keys_Down
         je      PSDLS_KeyDown
         cmp     ah, Keys_ESC
         je      PSDLS_KeyDONE
         cmp     ah, Keys_ENTER
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


   ; Clear drive-letter with backspace
   PSDLS_BackSpace:
      xor   dl,dl
      call  PARTSETUPDL_DrawDriveLetter
      jmp   PSDLS_MainLoop

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

CLR_PART_DL_XX_CLASSIC = 0d05h
CLR_PART_DL_XX_BM = 0a02h

   mov     cx, CLR_PART_DL_XX_BM                     ; Lila on lila
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

CLR_PART_DL_WINDOW_TITLE_CLASSIC  = 0e05h
CLR_PART_DL_WINDOW_TITLE_BM  = 0e02h

      mov     cx, CLR_PART_DL_WINDOW_TITLE_BM                  ; Yellow on Lila
      call    VideoIO_Color
      mov     si, offset TXT_SETUP_DriveLetter
      call    VideoIO_Print

CLR_PART_DL_WINDOW_BORDER2_CLASSIC  = 0d05h
CLR_PART_DL_WINDOW_BORDER2_BM  = 0a02h

      mov     cx, CLR_PART_DL_WINDOW_BORDER2_BM                 ; Lila on lila
      call    VideoIO_Color
      mov     al, 'Æ'
      call    VideoIO_PrintSingleChar
   pop     bx
   ; Display help-information
   mov     si, offset TXT_SETUPHELP_DriveLetter

CLR_PART_DL_SETUP_HELP_CLASSIC = 0d05h
CLR_PART_DL_SETUP_HELP_BM = 0a02h


   mov     cx, CLR_PART_DL_SETUP_HELP_BM                     ; Lila on lila
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
