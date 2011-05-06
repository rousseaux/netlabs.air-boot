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
;                                                          AiR-BOOT / TIMER
;---------------------------------------------------------------------------

IFDEF ModuleNames
DB 'TIMER',0
ENDIF

; This here is one of the rare cases that I'm using DIV and MUL opcodes. I
;  could have coded around them in here as well, but I was too lazy. Most of
;  the time, I'm not using them. If you want to look at something "leet", look
;  at SPECIAL\FX.asm =)

;        In: Nothing
;       Out: DX:AX - Current TimerTicCount
TIMER_GetTicCount               Proc Near   Uses ds si
   push    0040h
   pop     ds
   mov     si, 006Ch
   mov     ax, word ptr ds:[si]
   mov     dx, word ptr ds:[si+2]
   ret
TIMER_GetTicCount               EndP

;        In: AL - Timer-Tics to wait
;       Out: Nothing
TIMER_WaitTicCount              Proc Near   Uses ax bx dx
   ;movzx   bx, al
   mov   bl,al
   mov   bh,0

   call    TIMER_GetTicCount
   add     bx, ax                        ; BX - Required lower Tic
  TWTC_Loop:
      call    TIMER_GetTicCount
      cmp     ax, bx
      jb      TWTC_Loop
   ret
TIMER_WaitTicCount              EndP

;        In: AL - Seconds
;       Out: AX - Tics
TIMER_TranslateSecToTic         Proc Near   Uses bx dx
   or      al, al
   jz      TTSTT_Zerod
   xor     ah, ah
   mov     dl, 5
   div     dl                            ; Seconds : 5
   mov     bh, ah
   xor     ah, ah
   mov     bl, 91
   mul     bl                            ; Result * 91
   mov     dx, ax
   ;movzx   ax, bh
   mov   al,bh
   mov   ah,0

   mov     bl, 18
   mul     bl                            ; Remainder * 18
   add     ax, dx                        ; Add both together...
  TTSTT_Zerod:
   ret
TIMER_TranslateSecToTic         EndP

;        In: AX - Tics
;       Out: AL - Seconds
TIMER_TranslateTicToSec         Proc Near   Uses bx dx
   or      ax, ax
   jz      TTTTS_Overflow
   cmp     ax, 23295
   ja      TTTTS_Overflow
   mov     dl, 91
   div     dl                            ; Tics : 91
   mov     dh, al
   ;movzx   ax, ah
   mov   al,ah
   mov   ah,0

   mov     dl, 18
   div     dl                            ; Remainder : 18
   xor     ah, ah                        ; We dont need that remainder
   xchg    dh, al
   mov     bl, 5
   mul     bl                            ; Result * 5
   ;movzx   dx, dh
   mov   dl,dh
   mov   dh,0

   add     ax, dx                        ; Add both together...
   ret
  TTTTS_Overflow:
   xor     ax, ax
   ret
TIMER_TranslateTicToSec         EndP
