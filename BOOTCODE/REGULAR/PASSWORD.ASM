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
;                                                       AiR-BOOT / PASSWORD
;---------------------------------------------------------------------------

; Don't ask me, what I'm doing in here to encode the passwords. I don't even
;  know by myself anymore. It's some kind of hash and I hope that it isn't weak
;  and some mad uber-hacker-god will laugh about it - but i bet so ;-)

PASSWORD_AskSystemPwd           Proc Near   Uses ax bx si di
   ; Asks System Password, if set...
   test    CFG_PasswordSystem, 1
   jz      PASP_NoPassword
      mov     ax, 0ABABh
      mov     si, offset TXT_ProtectedSystem
      xor     di, di                     ; May Access With ANY correct password
      call    PASSWORD_AskSpecifiedPassword
  PASP_NoPassword:
   ret
PASSWORD_AskSystemPwd           EndP

PASSWORD_AskChangeBootPwd       Proc Near   Uses ax bx si di
   ; Asks System Password, if set...
   test    CFG_PasswordChangeBoot, 1
   jz      PACBP_NoPassword
   test    TimedBootUsed, 1
   jnz     PACBP_NoPassword
      mov     ax, 0ABABh
      mov     si, offset TXT_ProtectedBootUp
      xor     di, di                     ; May Access With ANY correct password
      call    PASSWORD_AskSpecifiedPassword
  PACBP_NoPassword:
   ret
PASSWORD_AskChangeBootPwd       EndP

;CFG_MasterPassword           dw 0101Fh   ; Encoded Password (this is just CR)
;                             dw 07A53h
;                             dw 0E797h
;                             dw 0A896h
; BUGBUG - If unspecified password to ask, check if one of our two are CR
;          And if that's the case, we need to skip over checking that one.
;          If both are CR, return to caller


;        In: ax - Magic for AskPassword Subroutine
;            si - Text to show, when asking for password
;            di - which password to check, use 0 to check any of both
; Destroyed: None
PASSWORD_AskSpecifiedPassword   Proc Near   Uses cx dx ds si es di bp
   local AskPasswordMiss:byte, AskPasswordText:word, AskPasswordMagic:word, AskPasswordWhich:word
   mov     AskPasswordMagic, ax
   mov     AskPasswordText, si
   mov     AskPasswordWhich, di
   mov     ax, cs
   mov     ds, ax
   mov     es, ax
   mov     di, offset TempPasswordEntry
   mov     al, 32
   mov     cx, 8
   rep     stosb                         ; Generates empty password
   mov     AskPasswordMiss, 0
   mov     ax, AskPasswordWhich
   or      ax, ax
   jnz     PASP_BadBoyRetry              ; Only check one
   ; Encode empty Password...
   mov     si, offset TempPasswordEntry
   call    PASSWORD_Encode
   mov     di, offset CFG_MasterPassword
   mov     si, offset PasswordSpace      ; Check Thiz Out
   mov     cx, 8
   repe    cmpsb
   je      PASP_DualCorrect1
   jmp     PASP_LetUserGuessPassword
  PASP_DualCorrect1:
   mov     si, offset PasswordSpace      ; Check Thiz Out
   mov     cx, 8
   repe    cmpsb
   je      PASP_CorrectPass
   jmp     PASP_LetUserGuessPassword

  PASP_BadBoyRetry:
      ; Encode given Password...
      mov     si, offset TempPasswordEntry
      call    PASSWORD_Encode

      ; ...and compare it to the specified on-board one
      mov     di, AskPasswordWhich
      or      di, di
      jnz     PASP_OnlyCheckSpecified
      mov     di, offset CFG_MasterPassword
      mov     si, offset PasswordSpace   ; Check Thiz Out
      mov     cx, 8
      repe    cmpsb
      je      PASP_CorrectPass
      mov     di, offset CFG_BootPassword
     PASP_OnlyCheckSpecified:
      mov     si, offset PasswordSpace   ; Check Thiz Other Thingie Out
      mov     cx, 8
      repe    cmpsb
      je      PASP_CorrectPass

     PASP_LetUserGuessPassword:          ; ;-)))
      mov     ax, AskPasswordMagic
      mov     si, AskPasswordText
      mov     di, offset TempPasswordEntry
      call    SETUP_LetEnterPassword
   inc     AskPasswordMiss
   cmp     AskPasswordMiss, 10
   jae     PASP_BadBoyAlert
   jmp     PASP_BadBoyRetry

  PASP_BadBoyAlert:                      ; Whaddayawant ;)
   mov     ax, 0ABABh
   mov     cx, 0B03h
   mov     si, offset TXT_TooManyTries
   call    SETUP_ShowErrorBox
   jmp     MBR_HaltSystem

  PASP_CorrectPass:
   ret
PASSWORD_AskSpecifiedPassword   EndP

PasswordSpace:               db 16 dup (0) ; Space for Password-Encoding...
                             dw 0BABEh     ; All of these 8 bytes are insider
                             dw 0FC77h     ;  jokes. I bet no one will solve
                             dw 0632Fh     ;  all of them =) they are used by
                             dw 0CD09h     ;  the algo, so don't remove them.

;        In: SI - Pointer to Password, fixed len (8 bytes)
;       Out: Password-Space filled with encoded password
; Destroyed: None
PASSWORD_Encode                 Proc Near   Uses ax cx ds si es di
   mov     ax, cs
   mov     es, ax
   mov     di, offset PasswordSpace
   mov     cx, 8
  PE_HashLoop:
      lodsb
      mov     es:[di], al
      xor     al, 0ABh
      and     al, 7
      mov     es:[di+8], al              ; Init Hash Table
      inc     di
   loop    PE_HashLoop

   mov     si, offset PasswordSpace
   mov     cx, 8
  PE_ContinueLoop:
      mov     al, ds:[si]
      movzx   bx, ds:[si+8]
      add     bl, 16
      mov     ah, ds:[si+bx]

      xor     al, ds:[si-1]
      xor     al, ah
      mov     ds:[si], al

      inc    si
   loop    PE_ContinueLoop
   ret
PASSWORD_Encode                 EndP
