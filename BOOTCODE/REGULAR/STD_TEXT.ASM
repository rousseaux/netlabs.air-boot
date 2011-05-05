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

; If you modify this Copyright and release this under your own name,
;  I'm going to sue your cheap ass, rape your dog and blow up your house. =)

CopyrightVersionLen   equ   5
Copyright             db ' AiR-BOOT v1.06 - (c) 1998-2009 M. Kiewitz, Dedicated to Gerd Kiewitz', 0
BootEndMsg            db 'Free usage allowed, as long as you dont or have not worked for US government', 0
BootEndMsg2           db 'This is GPLv3+ software. Please visit http://AiR-BOOT.sourceforge.net', 0

CheckID_MBR           db 'AiRBOOT'
BrokenHDD             db ' (HDDx)', 0

; Colors for special words hard-coded. Keep all 0s.
TXT_SETUP_LowerMessage      db 'This software is released under ', 0, 'GPLv3+.', 0
                            db 'It may not be used by US government', 0
                            db 'For more information and source, please visit', 0
                            db 'http://AiR-BOOT.sourceforge.net', 0
                            db 'Contact via e-mail: ', 0, 'm_kiewitz [AT] users.sourceforge.net', 0

ContinueBIOSbootTable dw offset TXT_SETUP_MAGIC_CDROM
                      dw offset TXT_SETUP_MAGIC_Network
                      dw offset TXT_SETUP_MAGIC_ZIPLS
                      dw     0
