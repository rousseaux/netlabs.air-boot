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
;                                                            AiR-BOOT / F/X
;---------------------------------------------------------------------------

IFDEF   MODULE_NAMES
DB 'FX',0
ENDIF

; There you go. Some nice old-school demo coder effects :)
;  If you rip this code, I will ./ your ass. =]

Include SPECIAL/FXTABLES.ASM

FX_MaxScanLine                equ 384
FX_TotalCooperBars            equ   7

FX_CalculateTables              Proc Near
   ; Calculate the Cooper-Bar Color-Table -> FX_CooperColors
   mov    di, offset FX_CooperColors
   mov    ax, 000Fh                      ; Red
   call   FX_MakeCooperBarColors
   mov    ax, 0FF0h                      ; Pink
   call   FX_MakeCooperBarColors
   mov    ax, 0F0Fh                      ; Bright Blue
   call   FX_MakeCooperBarColors
   mov    ax, 0F00h                      ; Blue
   call   FX_MakeCooperBarColors
   mov    ax, 00FFh                      ; Yellow
   call   FX_MakeCooperBarColors
   mov    ax, 00F0h                      ; Green
   call   FX_MakeCooperBarColors
   mov    ax, 0FFFh                      ; White
   call   FX_MakeCooperBarColors
   ret
FX_CalculateTables              EndP

; This routine will dump a color-table to ES:es:[DI]. Total of 96 bytes.
;        In: AX - Color-Separator (RGB, per value 4 bit)
;            DI - Pointer to Buffer for Color-Table
;       Out: *none*
; Destroyed: DI - updated, +96
FX_MakeCooperBarColors          Proc Near
   mov    bh, ah
   shl    bh, 4
   or     bh, ah                         ; BH - Blue-Value, now 00h or FFh
   mov    dh, al
   mov    bl, al
   shr    dh, 4
   and    bl, 0F0h
   or     dh, bl                         ; DH - Green-Value, now 00h or FFh
   mov    dl, al
   and    al, 00Fh
   shl    dl, 4
   or     dl, al                         ; DL - Red-Value, now 00h or FFh
   mov    ax, 1111h
   mov    bl, 11h                        ; Start-Values
   mov    cx, 15
  FX_MCBC_BuildColorLoop1:
      add    ax, 0303h
      add    bl, 03h
      and    ax, dx
      and    bl, bh
      mov    es:[di], ax
      mov    es:[di+2], bl
      add    di, 3
   loop   FX_MCBC_BuildColorLoop1
   push   ax
   push   bx
      add    ax, 0101h
      add    bl, 01h
      and    ax, dx
      and    bl, bh
      mov    es:[di], ax
      mov    es:[di+2], bl
      mov    es:[di+3], ax
      mov    es:[di+5], bl
      add    di, 6
   pop    bx
   pop    ax
   mov    cx, 15
  FX_MCBC_BuildColorLoop2:
      and    ax, dx
      and    bl, bh
      mov    es:[di], ax
      mov    es:[di+2], bl
      add    di, 3
      sub    ax, 0303h
      sub    bl, 03h
   loop   FX_MCBC_BuildColorLoop2
   ret
FX_MakeCooperBarColors          EndP

; This is called just before a new screen is generated
;  If FX is active, we will modify the base segment for videoio to page 2,
;  so the screen will be generated there instead of the current page.
FX_StartScreen                  Proc Near
   test    byte ptr [CFG_CooperBars], 1
   jz      FXSS_NoFX
   mov     word ptr [VideoIO_Segment], VideoIO_Page2
  FXSS_NoFX:
   ret
FX_StartScreen                  EndP

; This is called, when a new screen was done
;  If FX is active, we will copy the new screen to scroll area, do the FX,
;  copy the new screen to Page 0 and activate it.
FX_EndScreenLeft                Proc Near
   test    byte ptr [CFG_CooperBars], 1
   jnz     FXESL_Go
   ret
  FXESL_Go:
   pusha
      mov     ax, VideoIO_Page2
      mov     bx, VideoIO_Page0
      mov     dx, 160
      xor     di, di
      call    FX_InterleaveCopy
      call    FX_ScrollScreenLeft

      mov     ax, VideoIO_Page2
      call    VideoIO_RestoreFrom
      mov     word ptr [VideoIO_Segment], VideoIO_Page0
      call    FX_EndScreenInternalCleanUp
   popa
   ret
FX_EndScreenLeft                EndP

FX_ScrollScreenLeft             Proc Near
   mov     word ptr [FX_WideScrollerCurPos], 640
   mov     byte ptr [FX_WideScrollerDirection], 0
   mov     byte ptr [FX_WideScrollerAbsDirection], 0
   call    FX_EndScreenInternalGo
   ret
FX_ScrollScreenLeft             EndP

FX_EndScreenRight               Proc Near
   test    byte ptr [CFG_CooperBars], 1
   jnz     FXESR_Go
   ret
  FXESR_Go:
   pusha
      mov     ax, VideoIO_Page0
      mov     bx, VideoIO_Page2
      mov     dx, 160
      xor     di, di
      call    FX_InterleaveCopy
      call    FX_ScrollScreenRight

      mov     ax, VideoIO_Page2
      call    VideoIO_RestoreFrom
      mov     word ptr [VideoIO_Segment], VideoIO_Page0
      call    FX_EndScreenInternalCleanUp
   popa
   ret
FX_EndScreenRight               EndP

FX_ScrollScreenRight            Proc Near
   mov     word ptr [FX_WideScrollerCurPos], 0
   mov     byte ptr [FX_WideScrollerDirection], 1
   mov     byte ptr [FX_WideScrollerAbsDirection], 1
   call    FX_EndScreenInternalGo
   ret
FX_ScrollScreenRight            EndP

FX_EndScreenInternalGo          Proc Near
   mov     byte ptr [FX_WideScrollerSpeed], 1
   mov     byte ptr [FX_WideScrollerSpeedState], 1
   mov     byte ptr [FX_WideScrollerBounceSpeed], 25
   ; Check, if this is 1st time call...
   inc     word ptr [FX_UseCount]
   cmp     word ptr [FX_UseCount], 1
   jne     FX_ES_NotFirstTime
   mov     word ptr [FX_OverallTimer], 220
   mov     word ptr [FX_WideScrollerTimer], 93
   mov     word ptr [FX_CooperBarsTimer], 1
   jmp     FX_ES_NowGoMagic
  FX_ES_NotFirstTime:
   mov     word ptr [FX_OverallTimer], 127
   mov     word ptr [FX_WideScrollerTimer], 1
   mov     word ptr [FX_CooperBarsTimer], -1  ; Disable coopers on further goes
  FX_ES_NowGoMagic:
   call    FX_MakeMagicalStuff
   ret
FX_EndScreenInternalGo          EndP

FX_EndScreenInternalCleanUp     Proc Near
   mov     ax, -1
   call    FX_SetVideoStart
   call    FX_WaitRetrace
   mov     ax, 80
   call    FX_SetWideLength
   ret
FX_EndScreenInternalCleanUp     EndP

;        In: AX - 1st Page Segment
;            BX - 2nd Page Segment
;            DX - Space to interleave
;            DI - Destination offset for Page 4
;       Out: Both pages interleaved to Page 4
; Destroyed: AX, CX, SI, DI
FX_InterleaveCopy               Proc Near
   push    di
      call    FX_InterleaveCopyPage
   pop     di
   add     di, dx
   mov     ax, bx
   call    FX_InterleaveCopyPage
   ret
FX_InterleaveCopy               EndP

FX_InterleaveCopyPage           Proc Near   Uses ds es
   mov     ds, ax
   mov     ax, VideoIO_Page4
   mov     es, ax
   xor     si, si
  FXIC_CopyLoop:
      mov     cx, 80
      rep     movsw
      add     di, dx
   cmp     si, 1000h
   jb      FXIC_CopyLoop
   ret
FX_InterleaveCopyPage           EndP

FX_MakeMagicalStuff             Proc Near   Uses es
   ; Initiate Cooper-Variables...
   push    ds
   pop     es
   mov     di, offset FX_CooperState
   mov     cx, 7
   xor     al, al
   rep     stosb                         ; Initiates FX_CooperState
   mov     cx, 7
   dec     al                            ; AX = 255
   rep     stosb                         ; Initiates FX_SinusPos
   mov     si, offset FX_StartCooperPos
   mov     cx, 7
   rep     movsw                         ; Initiates FX_CooperPos

   call   FX_WaitRetrace
  FX_MMS_RetraceLoop:
      mov     dx, 3C8h
      xor     al, al
      out     dx, al
      inc     dx
      out     dx, al
      out     dx, al
      call    FX_WaitRetrace
      mov     dx, 3C9h
      xor     al, al
      out     dx, al                     ; Really set background color now

      xor     di, di                     ; DI - Cur Scan-Line Counter
     FX_MCS_VerticalLoop:
         call    FX_ColorUpVLine
      inc     di
      cmp     di, FX_MaxScanLine
      jb      FX_MCS_VerticalLoop

      mov     ax, [FX_CooperBarsTimer]
      dec     ax
      jnz     FX_MMS_CooperBarsPending
         ; Here we need to calculate the movements of the Coopers...at last
         call    FX_CalculateCoopers
      mov     ax, 1
     FX_MMS_CooperBarsPending:
      mov     [FX_CooperBarsTimer], ax

      mov     ax, [FX_WideScrollerTimer]
      dec     ax
      jnz     FX_MMS_WideScrollerPending
         call    FX_CalculateWideScroller
      mov     ax, 1
     FX_MMS_WideScrollerPending:
      mov     [FX_WideScrollerTimer], ax

   dec     word ptr [FX_OverallTimer]
   jnz     FX_MMS_RetraceLoop
   ret
FX_MakeMagicalStuff             EndP

; This routine is called per VRetrace, it will look for a CooperBar to display
; and color the Vertical Screen Line in the specified color
;        In: DI - Vertical Line Counter
;       Out: *none*
; Destroyed: all, but DI
FX_ColorUpVLine                 Proc Near   Uses di
   add    di, 256                        ; Real-Scanlines begin at 256 here
   mov    si, offset FX_CooperPos
   xor    cx, cx
  FX_CUVL_SearchCooperLoop:
      lodsw
      mov    dx, ax                      ; AX - First VRLine used by Cooper
      add    dx, 32                      ; DX - Last VRLine used by Cooper
      cmp    di, ax
      jb     FX_CUVL_CooperNoHit
      cmp    di, dx
      jb     FX_CUVL_CooperGotHit
     FX_CUVL_CooperNoHit:
   inc    cx
   cmp    cx, FX_TotalCooperBars
   jb     FX_CUVL_SearchCooperLoop
  FX_CUVL_CooperNotVisible:
   xor    bx, bx
   xor    cl, cl                         ; No Cooper -> So use Color [0/0/0]
   jmp    FX_CUVL_ColorLine

   ; Okay, we got a cooper...now calculate color and done...
  FX_CUVL_CooperGotHit:
   mov    dx, di
   sub    dx, ax                         ; DX - Relative Pos within cooper
   mov    bx, cx
   shl    bx, 5                          ; * 32
   mov    ax, bx
   add    bx, bx
   add    bx, ax                         ; BX = CurCooper*96
   add    bx, dx
   add    bx, dx
   add    bx, dx                         ; Plus RelativePos * 3
   mov    cl, bptr ds:[FX_CooperColors+bx+2]
   mov    bx, wptr ds:[FX_CooperColors+bx]

  FX_CUVL_ColorLine:
   mov    dx, 3C8h
   xor    al, al
   out    dx, al
   inc    dx
   mov    al, bl
   out    dx, al
   mov    al, bh
   out    dx, al
   call   FX_WaitVRetrace
   mov    dx, 3C9h
   mov    al, cl
   out    dx, al                         ; Colord on VRetrace...
   ret
FX_ColorUpVLine                 EndP

; This routine is called to move the cooper bars on screen... It's called on
;  every Retrace.
;        In: *none*
;       Out: *none*
; Destroyed: all
FX_CalculateCoopers             Proc Near
   ; Logic: When Intro-State: Increase CooperPos by 1 till 256 -> then active
   ;             Active-State: Use SinusTable, till SinusPos=7Fh -> then Extro
   ;             Extro-State: Decrease CooperPos by 1 till 0

   xor     si, si
  FX_CC_CalcLoop:
      cmp     bptr ds:[FX_CooperState+si], 1
      jb      FX_CC_IntroState
      je      FX_CC_ActiveState
      ja      FX_CC_ExtroState
      jmp     FX_CC_CalcLoopEnd
     FX_CC_IntroState:
      mov     bx, si
      shl     bx, 1
      mov     ax, wptr ds:[FX_CooperPos+bx]
      inc     ax
      mov     wptr ds:[FX_CooperPos+bx], ax
      cmp     ax, 256                       ; Got into Active-State ?
      jb      FX_CC_CalcLoopEnd
      inc     bptr ds:[FX_CooperState+si]
      jmp     FX_CC_CalcLoopEnd
     FX_CC_ExtroState:
      mov     bx, si
      shl     bx, 1
      mov     ax, wptr ds:[FX_CooperPos+bx]
      dec     ax
      jz      FX_CC_CalcLoopEnd
      mov     wptr ds:[FX_CooperPos+bx], ax
      jmp     FX_CC_CalcLoopEnd

     FX_CC_ActiveState:
      ; increment SinusPos by 1
      ;movzx   bx, bptr ds:[FX_SinusPos+si]
      mov   bl,bptr ds:[FX_SinusPos+si]
      mov   bh,0

      inc     bx
      mov     bptr ds:[FX_SinusPos+si], bl
      cmp     bl, 7Fh
      jne     FX_CC_ActiveNoStateChange
      inc     bptr ds:[FX_CooperState+si]
     FX_CC_ActiveNoStateChange:
      ; Get SinusTab-Value for [BX] and put it to CooperPos-Table for easy xs
      and     bx, 7Fh
      shl     bx, 1
      mov     ax, wptr es:[FX_SinusTab+bx]
      mov     bx, si
      shl     bx, 1
      mov     wptr ds:[FX_CooperPos+bx], ax
  FX_CC_CalcLoopEnd:
   inc     si
   cmp     si, FX_TotalCooperBars
   jb      FX_CC_CalcLoop
   ret
FX_CalculateCoopers             EndP

FX_CalculateWideScroller        Proc Near
   mov     bx, [FX_WideScrollerCurPos]
   ;movzx   cx, FX_WideScrollerSpeed
   mov   cl, [FX_WideScrollerSpeed]
   mov   ch,0

   test    byte ptr [FX_WideScrollerAbsDirection], 1
   jnz     FXCWS_RIGHT
   jmp     FXCWS_LEFT

   ; ================================================== WideScroll: LEFT CALC
  FXCWS_LEFT:
   test    byte ptr [FX_WideScrollerSpeedState], 1
   jz      FXCWS_LEFT_Bouncing
   or      bx, bx
   jz      FXCWS_LEFT_BounceNOW
   jmp     FXCWS_DoSpeedThing

  FXCWS_LEFT_Bouncing:
   or      cx, cx
   jnz     FXCWS_DoSpeedThing
   mov     byte ptr [FX_WideScrollerSpeedState], 1
   mov     byte ptr [FX_WideScrollerDirection], 0
   mov     dl, [FX_WideScrollerBounceSpeed]
   shr     dl,1
   mov     [FX_WideScrollerBounceSpeed], dl
   jmp     FXCWS_DoSpeedThing

  FXCWS_LEFT_BounceNOW:
   mov     cl, [FX_WideScrollerBounceSpeed]
   mov     byte ptr [FX_WideScrollerSpeedState], 0
   mov     byte ptr [FX_WideScrollerDirection], 1
   jmp     FXCWS_DoSpeedThing

   ; ================================================= WideScroll: RIGHT CALC
  FXCWS_RIGHT:
   test    byte ptr [FX_WideScrollerSpeedState], 1
   jz      FXCWS_RIGHT_Bouncing
   cmp     bx, 640 ; 1280
   jae     FXCWS_RIGHT_BounceNOW
   jmp     FXCWS_DoSpeedThing

  FXCWS_RIGHT_Bouncing:
   or      cl, cl
   jnz     FXCWS_DoSpeedThing
   mov     byte ptr [FX_WideScrollerSpeedState], 1
   mov     byte ptr [FX_WideScrollerDirection], 1
   mov     dl, [FX_WideScrollerBounceSpeed]
   shr     dl, 1
   mov     [FX_WideScrollerBounceSpeed], dl
   jmp     FXCWS_DoSpeedThing

  FXCWS_RIGHT_BounceNOW:
   mov     cl, [FX_WideScrollerBounceSpeed]
   mov     byte ptr [FX_WideScrollerSpeedState], 0
   mov     byte ptr [FX_WideScrollerDirection], 0
   jmp     FXCWS_DoSpeedThing

   ; ================================================= WideScroll: SPEED CALC
  FXCWS_DoSpeedThing:
   test    byte ptr [FX_WideScrollerSpeedState], 1
   jnz     FXCWS_SpeedUp
  FXCWS_SpeedDown:
   or      cl, cl
   jz      FXCWS_WideScrollNOW
   dec     cl
   jmp     FXCWS_WideScrollNOW

  FXCWS_SpeedUp:
   cmp     cl, 25
   jge     FXCWS_WideScrollNOW
   inc     cl
   jmp     FXCWS_WideScrollNOW

   ; ================================================== WideScroll: DO SCROLL
  FXCWS_WideScrollNOW:
   xor     ch, ch
   test    byte ptr [FX_WideScrollerDirection], 1
   jnz     FXCWS_ScrollRIGHT
   sub     bx, cx
   jmp     FXCWS_Continue
  FXCWS_ScrollRIGHT:
   add     bx, cx
  FXCWS_Continue:
   cmp     bx, 5555h  ; Zu gross <g>
   jb      FXCWS_NotToSmall
   mov     bx, 0
  FXCWS_NotToSmall:
   cmp     bx, 640 ; 1280
   jb      FXCWS_NotToBig
   mov     bx, 640 ; 1280
  FXCWS_NotToBig:
   mov     [FX_WideScrollerCurPos], bx
   mov     [FX_WideScrollerSpeed], cl
   mov     ax, 160
   call    FX_SetWideLength
   mov     ax, bx
   call    FX_SetVideoStart
   ret
FX_CalculateWideScroller        EndP

FX_WaitRetrace                  Proc Near
   mov    dx, 3DAh
  FX_WR1:
   in     al,dx
   test   al,8
   jnz    FX_WR1
  FX_WR2:
   in     al,dx
   test   al,8
   jz     FX_WR2
   ret
FX_WaitRetrace                  EndP

FX_WaitVRetrace                 Proc Near
   mov    dx, 3DAh
  FX_WVR1:
   in     al,dx
   test   al,1
   jnz    FX_WVR1
  FX_WVR2:
   in     al,dx
   test   al,1
   jz     FX_WVR2
   ret
FX_WaitVRetrace                 EndP

FX_SetVideoStart                Proc Near   Uses bx cx dx
   cmp     ax, -1
   je      FXSVS_Reset
   mov     bx, ax
   mov     cl, al
   shr     bx, 3
   and     cl, 7
   add     bx, 2000h                     ; Start at BC00h (Offset 4000h)
   or      cl, cl
   jnz     FXSVS_SetValues
   mov     cl, 31                        ; BX - StartAddr, CL - ShiftReg
   jmp     FXSVS_SetValues
  FXSVS_Reset:
   xor     bx, bx                        ; StartAddr==0, ShiftReg==31
   mov     cl, 31
  FXSVS_SetValues:
   mov     dx, 3D4h
   mov     al, 0Ch
   mov     ah, bh
   out     dx, ax                        ; Set Start-Address
   inc     al
   mov     ah, bl
   out     dx, ax

   mov     dx, 3C0h
   mov     al, 33h
   out     dx, al
   mov     al, cl
   out     dx, al                        ; Set Shift-Register
   ret
FX_SetVideoStart                EndP

FX_SetWideLength                Proc Near   Uses dx
   shr     ax, 1                         ; Divide by 2
   mov     ah, al
   mov     dx, 3D4h
   mov     al, 13h
   out     dx, ax
   ret
FX_SetWideLength                EndP
