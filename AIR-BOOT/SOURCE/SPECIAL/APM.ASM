
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
;                                                    AiR-BOOT / APM SUPPORT
;---------------------------------------------------------------------------

; Here is APM Code to turn off the computer

APM_TurnOffComputer            Proc Near  Uses ax bx cx
   mov     ax, 5301h
   xor     bx, bx
   int     15h
   mov     ax, 530Eh
   xor     bx, bx
   mov     cx, 102h
   int     15h
   mov     ax, 5307h
   mov     bx, 1
   mov     cx, 3
   int     15h
   ret                                   ; We should never return here <g>
APM_TurnOffComputer            EndP
