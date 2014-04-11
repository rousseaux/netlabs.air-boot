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
;                                                          AiR-BOOT / MBR-TEXT
; v001 - Dutch - by Kris Steenhaut
;------------------------------------------------------------------------------

TXT_LanguageID                equ 'N'

; Those strings are saved within MBR.
; Total Length maximum 165 chars (include 13,10 (CRs), excluding ending Zeros)

TXT_ERROR_Attention            db 'AiR-BOOT: !OPGELET!', 13, 10, 0
TXT_ERROR_CheckCode            db ' - AiR-BOOT', 0
TXT_ERROR_CheckFailed          db ' is niet goed meer ge‹nstalleerd!', 13, 10
                               db '   Start opnieuw op vanaf de Airboot diskette.', 13, 10
                               db '   Afgebroken! Tik op de RESET knop .', 0
