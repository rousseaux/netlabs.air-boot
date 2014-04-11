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
;                                                           AiR-BOOT / TEXT
;---------------------------------------------------------------------------

IFDEF ModuleNames
DB 'STD_TEXT',0
ENDIF

; If you modify this Copyright and release this under your own name,
;  I'm going to sue your cheap ass, rape your dog and blow up your house. =)

CopyrightVersionLen   equ   6
;Copyright             db ' AiR-BOOT v1.06 - (c) 1998-2009 M. Kiewitz, Dedicated to Gerd Kiewitz', 0
;Copyright             db ' AiR-BOOT v1.07 - (c) 2011 M. Kiewitz - Rousseau test-version >502G (build: #24)', 0
;Copyright             db ' AiR-BOOT v1.07 - (c) 2011 M. Kiewitz   -  Release Candidate 1  -  (build: #25)', 0
;Copyright             db ' AiR-BOOT v1.07 - (c) 1998-2011 M. Kiewitz, Dedicated to Gerd Kiewitz (rc2-b27)', 0
;Copyright             db ' AiR-BOOT v1.07 - (c) 1998-2011 M. Kiewitz, Dedicated to Gerd Kiewitz (rc3-b31)', 0
;Copyright             db ' AiR-BOOT v1.07 - (c) 1998-2011 M. Kiewitz, Dedicated to Gerd Kiewitz (rc4-b33)', 0
;Copyright             db ' AiR-BOOT v1.07 - (c) 1998-2011 M. Kiewitz, Dedicated to Gerd Kiewitz (rc5-b35)', 0
;Copyright             db ' AiR-BOOT v1.07 - (c) 1998-2011 M. Kiewitz, Dedicated to Gerd Kiewitz', 0
;Copyright             db ' AiR-BOOT v1.0.8 - (c) 1998-2011 M. Kiewitz, Dedicated to Gerd Kiewitz', 0

;Copyright             db ' AiR-BOOT v1.0.8-internal-beta - ** !! NOT FOR DISTRIBUTION !! **', 0
;Copyright             db ' AiR-BOOT v1.0.8 - (c) 2012 M. Kiewitz    <<Release Candidate>>    (build: #18)', 0
Copyright             db ' AiR-BOOT v1.0.8 - (c) 2012 M. Kiewitz  <<Release Candidate 1>> (bld: 20120124)', 0
;Copyright             db ' AiR-BOOT v1.0.8 - (c) 1998-2012 M. Kiewitz, Dedicated to Gerd Kiewitz', 0

; Rousseau: switch around
BootEndMsg           db 'This is GPLv3+ software, please visit: http://www.gnu.org/licenses/gpl.txt', 0
BootEndMsg2          db 'To obtain the sources,   please visit: http://svn.netlabs.org/air-boot', 0

AuxInitMsg           db 'Initializing Serial Communications on COM',0

CheckID_MBR          db 'AiRBOOT'
BrokenHDD            db ' (HDDx)', 0

; Colors for special words hard-coded. Keep all 0s.
TXT_SETUP_LowerMessage      db 'This software is released under ', 0, 'GPLv3+', 0
                            db 'http://www.gnu.org/licenses/gpl.txt', 0
                            db 'For more information and source, please visit:', 0
                            db 'http://svn.netlabs.org/air-boot', 0
                            db 'Contact via e-mail: ', 0, 'airboot@ecomstation.com', 0

ContinueBIOSbootTable dw offset TXT_SETUP_MAGIC_CDROM
                      dw offset TXT_SETUP_MAGIC_Network
                      dw offset TXT_SETUP_MAGIC_ZIPLS
                      dw     0
