
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
;                                                          AiR-BOOT / TIMER
;---------------------------------------------------------------------------

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
   movzx   bx, al
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
   movzx   ax, bh
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
   movzx   ax, ah
   mov     dl, 18
   div     dl                            ; Remainder : 18
   xor     ah, ah                        ; We dont need that remainder
   xchg    dh, al
   mov     bl, 5
   mul     bl                            ; Result * 5
   movzx   dx, dh
   add     ax, dx                        ; Add both together...
   ret
  TTTTS_Overflow:
   xor     ax, ax
   ret
TIMER_TranslateTicToSec         EndP
