
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
;                                                  AiR-BOOT / SOUND SUPPORT
;---------------------------------------------------------------------------

; Here is some sound code. Requested by Hex1753.

SOUND_PreBootMenu              Proc Near  Uses ax
   test    CFG_MakeSound, 1
   jz      SOUND_PreBootMenu_SkipSound
   test    StartSoundPlayed, 1
   jnz     SOUND_PreBootMenu_SkipSound
   mov     ax, 1500
   call    SOUND_MakeSound
   mov     ax, 100
   call    SOUND_WaitToSilence
   mov     ax, 2000
   call    SOUND_MakeSound
   mov     ax, 200
   call    SOUND_WaitToSilence
   mov     StartSoundPlayed, 1
  SOUND_PreBootMenu_SkipSound:
   ret
SOUND_PreBootMenu              EndP

SOUND_ExecuteBoot              Proc Near  Uses ax
   test    CFG_MakeSound, 1
   jz      SOUND_ExecuteBoot_SkipSound
   mov     ax, 2000
   call    SOUND_MakeSound
   mov     ax, 10
   call    SOUND_WaitToSilence
   mov     ax, 1000
   call    SOUND_MakeSound
   mov     ax, 20
   call    SOUND_WaitToSilence
   mov     ax, 1500
   call    SOUND_MakeSound
   mov     ax, 10
   call    SOUND_WaitToSilence
   mov     ax, 1900
   call    SOUND_MakeSound
   mov     ax, 20
   call    SOUND_WaitToSilence
   mov     ax, 1000
   call    SOUND_MakeSound
   mov     ax, 10
   call    SOUND_WaitToSilence
   mov     ax, 1500
   call    SOUND_MakeSound
   mov     ax, 30
   call    SOUND_WaitToSilence
  SOUND_ExecuteBoot_SkipSound:
   ret
SOUND_ExecuteBoot              EndP

SOUND_MakeSound                Proc Near  Uses bx dx
   mov    bx, ax
   mov    ax, 34DDh
   mov    dx, 0012h
   cmp    dx, bx                         ; Too small frequency
   jnb    SOUND_MakeSound_J1
   div    bx
   mov    bx, ax
   in     al, 61h
   test   al, 03h                        ; Already playing (?)
   jnz    SOUND_MakeSound_J2
   or     al, 03h
   out    61h, al
   mov    al, -4Ah
   out    43h, al
  SOUND_MakeSound_J2:
   mov    al, bl
   out    42h, al
   mov    al, bh
   out    42h, al
  SOUND_MakeSound_J1:
   ret
SOUND_MakeSound                EndP

SOUND_WaitToSilence            Proc Near  Uses bx cx dx
   ; AX = MilliSeconds
   mov    bx, 03E8h
   mul    bx
   mov    cx, dx
   mov    dx, ax
   mov    ax, 8600h
   int    15h
   in     al, 61h
   and    al, 0FCh
   out    61h, al
   ret
SOUND_WaitToSilence            EndP
