
; Disclaimer:
;=============
; The sourcecode is released via www.netlabs.org CVS *ONLY*.
;  You MUST NOT upload it to other servers nor republish it in any way.
;  The sourcecode is still COPYRIGHTED and NOT YET RELEASED UNDER GPL.
;  It's (c) Copyright 1998-2002 by Martin Kiewitz.
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
;                                                           AiR-BOOT / TEXT
;---------------------------------------------------------------------------

; If you modify this Copyright and release this shiat under your own name,
;  I'm going to sue your cheap ass, rape your dog and blow up your house. =)

CopyrightVersionLen         equ   5
Copyright                    db ' AiR-BOOT v1.00 - (c) ''98-2003 Martin Kiewitz, Dedicated to Gerd Kiewitz', 0
BootEndMsg                   db 'Distribute/copy freely. Only meant for private usage.', 0

CheckID_MBR                  db 'AiRBOOT'

ContinueBIOSbootTable        dw offset TXT_SETUP_MAGIC_CDROM
                             dw offset TXT_SETUP_MAGIC_Network
                             dw offset TXT_SETUP_MAGIC_ZIPLS
                             dw     0
