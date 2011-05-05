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
