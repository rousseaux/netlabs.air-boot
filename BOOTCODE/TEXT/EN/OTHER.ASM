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
;------------------------------------------------------------------------------
;                                                        AiR-BOOT / OTHER TEXT
; v001 - English - by Martin Kiewitz
;------------------------------------------------------------------------------

TXT_TranslationBy              db 0

; TopInfosX variables are used for Boot-Menu and Partition Setup

; Maximum 2/10/11/6 chars
;----------------------------------||---------------------------------------
TXT_TopInfos_No                db 'No', 0
TXT_TopInfos_Hd                db 'Hd', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_HdSize            db 'Hd/Size:', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_Label             db 'Label:', 0
;----------------------------------|---------|------------------------------
TXT_TopInfos_Type              db 'Type:', 0
;----------------------------------|----|-----------------------------------
TXT_TopInfos_Flags             db 'Flags:', 0      ; <-- for Partition Setup

; Will be added together to one line, maximum 76 chars
TXT_TimedBootLine              db 'Timed boot enabled. System will boot '''
TXT_TimedBootEntryName         db 12 dup (0) ; Space for Default-Entry-Name
TXT_TimedBootLine2             db      ''' in ', 0
TXT_TimedBootSeconds           db ' seconds. ', 0
TXT_TimedBootSecond            db ' second. ', 0 ; if only one is left, ELiTE :]
; Maximum 76 chars
;----------------------------------|--------------------------------------------------------------------------|
TXT_TimedBootDisabled          db 'Timed boot disabled; no timeout will occur.', 0
TXT_BootMenuHelpText1          db 'Press [Esc] to toggle timed boot, [Enter] to accept current selection.', 0
TXT_BootMenuHelpText2          db 'Select another with the arrow keys, or press [TAB] to see BIOS POST message.', 0
; Maximum 30 chars
;----------------------------------|----------------------------|
TXT_BootMenuEnterSetup         db 'F10 to enter Setup', 0
;TXT_BootMenuEnterBootLog       db 'TAB to enter Boot Log', 0

; Dynamic Length (till 80 chars)
TXT_BrokenPartitionTable       db 13, 10, ' - Your system has at least one broken partition table entry or your harddrive'
                               db 13, 10, '   contains bad sectors. System halted.', 0
TXT_TooManyPartitions          db 13, 10, ' - Too many partitions found. AiR-BOOT is supporting up to 45.', 0
TXT_NoBootAble                 db 13, 10, ' - No bootable partition defined. System halted.', 0
TXT_BIOSchanged                db 13, 10, ' - BIOS CHANGED, please check your system for any virus, just to be sure.'
                               db 13, 10, '   Press any key to continue...', 0

TXT_VirusFoundMain             db 13, 10, ' - !ATTENTION! -> A V1RU5 WAS FOUND <- !ATTENTION!', 13, 10, 0
TXT_VirusFound1ok              db '    It got squashed, but the system may not reboot correctly. If this happens,', 13, 10
                               db '    use your AiR-BOOT system disc.', 13, 10, 0
TXT_VirusFound1damn            db '    Unfortunately it destroyed AiR-BOOTs backup. You have to reboot using your', 13, 10
                               db '    AiR-BOOT system disc.', 13, 10, 0
TXT_VirusFound1any             db '    For security, you should check your harddisc against remaining virus parts.', 13, 10, 0
TXT_VirusFound2                db '    It is located in the boot-record of the partition, you wanted to boot.', 13, 10
                               db '    Use a virus-checking program. It could be false alarm either.', 13, 10
                               db '    After removal, you have to reinit the detection variables, go into ', 13, 10
                               db '    ''PARTITION SETUP'' and switch VIBR-detection two times (off/on).', 13, 10
                               db '    If this was just a false alarm, leave it in off-state.', 13, 10, 0
TXT_VirusFoundEnd              db '    System halted. Please press RESET.', 0
TXT_HowEnterSetup              db 13, 10, ' - Press and hold Strg/Ctrl or Alt to enter AiR-BOOT Setup.', 0

TXT_BootingNow1                db 'Booting the system using ', 0
; DO NOT MODIFY HERE
TXT_BootingNow2                db '''', 0
TXT_BootingNowPartName         db 12 dup (0) ; Space for BootThisPart-Name
; DO NOT MODIFY TILL HERE
TXT_BootingNowPartition        db ' partition', 0
TXT_BootingNowKernel           db ' kernel', 0
TXT_BootingHide                db '; hide active', 0
TXT_BootingWait                db '; please wait...', 13, 10, 13, 10, 0

; FIXED LENGTH - 11 chars each string
;----------------------------------|---------|------------------------------
TXT_Floppy_NoName              db 'No Name    '
TXT_Floppy_Drive               db 'FloppyDrive'
TXT_Floppy_NoDisc              db 'No Disc    '

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_PleaseEnterPassword        db ' Please Enter Password:', 0
; the following 3 strings have to equal or *longer* than PleaseEnterPassword
TXT_ProtectedSystem            db '** PASSWORD PROTECTED SYSTEM **', 0
TXT_ProtectedSetup             db '** PASSWORD PROTECTED SETUP! **', 0
TXT_ProtectedBootUp            db '** PASSWORD PROTECTED BOOTUP **', 0

; will get completed using TXT_ERROR_CheckFailed from MBR.asm
TXT_ERROR_CheckConfig          db 13, 10, ' - The configuration', 0

;----------------------------------|----------------------------------------------------------|
TXT_TooManyTries               db 'Too Many Tries, System Halted', 0
