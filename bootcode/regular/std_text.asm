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

IFDEF   MODULE_NAMES
DB 'STD_TEXT',0
ENDIF

; If you modify this Copyright and release this under your own name,
; I'm going to sue your cheap ass, rape your dog and blow up your house. =)


;
; Copyright header on top of screen
;
Copyright:
IFDEF   RELEASE
            ;
            ; Copyright header as displayed on RELEASE version
            ;
            db ' AiR-BOOT v'
            db BLDLVL_MAJOR_VERSION,'.'
            db BLDLVL_MIDDLE_VERSION,'.'
            db BLDLVL_MINOR_VERSION,' - (c) 1998-'
            db BLDLVL_YEAR
            db ' Martin Kiewitz, Dedicated to Gerd Kiewitz'
            db 0
ELSE
            ;
            ; Copyright header as displayed on TESTBUILD version
            ;
            db ' AiR-BOOT v'
            db BLDLVL_MAJOR_VERSION,'.'
            db BLDLVL_MIDDLE_VERSION,'.'
            db BLDLVL_MINOR_VERSION,' - (c) 1998-'
            db BLDLVL_YEAR
            db ' M. Kiewitz   << Test Build >>   (bld:'
            db BLDLVL_YEAR
            db BLDLVL_MONTH
            db BLDLVL_DAY,')'
            db 0
ENDIF

; Length of version string to copy when displayed in menu and just before
; booting the selected system.
CopyrightVersionLen   equ   6

; License and source info.
BootEndMsg      db 'This is GPLv3+ software, please visit: http://www.gnu.org/licenses/gpl.txt', 0
BootEndMsg2     db 'To obtain the sources,   please visit: http://svn.netlabs.org/air-boot', 0

; Bugger...
CheckID_MBR     db 'AiRBOOT'
BrokenHDD       db ' (HDDx)', 0

; Colors for special words hard-coded. Keep all 0s.
TXT_SETUP_LowerMessage      db 'This software is released under ', 0, 'GPLv3+', 0
                            db 'http://www.gnu.org/licenses/gpl.txt', 0
                            db 'For more information and source, please visit:', 0
                            db 'http://svn.netlabs.org/air-boot', 0
                            db 'Contact via e-mail: ', 0, 'rousseau.os2dev@gmx.com', 0

; Table that points to BIOS device names.
ContinueBIOSbootTable   dw offset TXT_SETUP_MAGIC_CDROM
                        dw offset TXT_SETUP_MAGIC_Network
                        dw offset TXT_SETUP_MAGIC_ZIPLS
                        dw     0

; LVM protection messages; should be translated and moved to lang-files.
TXT_SETUP_NoEditType35      db 'Labels of LVM-Data partitions cannot be changed', 0
TXT_SETUP_NoBootType35      db 'LVM-Data partitions cannot be set bootable', 0
TXT_BootMenuPowerOff        db 'DEL to Power Off', 0
TXT_NoINT13XSupport         db  'This BIOS does not support Extended INT13h Functions', 0
;~ TXT_ERROR_TooManyPartitions db 'Too many partitions! -- Proper operation not guaranteed!', 0

; MBR protection; should also be translated and moved.
NonMBRwrite     db  'AiR-BOOT TRIED TO WRITE A non-MBR TO DISK !!',0
NonMBRwrite_rep db  'Please report this at rousseau.os2dev@gmx.com',0
SystemHalted    db  'System Halted',0

; Build Information string.
build_date      db  'Build Date: ',0
scanning_txt    db  'Scanning...',0
