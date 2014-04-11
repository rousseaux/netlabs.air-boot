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
; v001 - French - by Michel Goyette
;------------------------------------------------------------------------------

TXT_LanguageID                equ 'F'

; Those strings are saved within MBR.
; Total Length maximum 165 chars (include 13,10 (CRs), excluding ending Zeros)

TXT_ERROR_Attention            db 'AiR-BOOT: !ATTENTION!', 13, 10, 0
TXT_ERROR_CheckCode            db ' - Le code', 0
TXT_ERROR_CheckFailed          db ' de AiR-BOOT a ‚t‚ alt‚r‚.', 13, 10
                               ;~ db '   Veuillez red‚marrer avec la disquette AiR-BOOT afin de le restaurer.', 13, 10
                               ;~ db '   SystŠme arrˆt‚. Veuillez appuyez sur RESET.', 0

                                ; Had to shorten this to prevent overlap with double 'I13X' signature in MBR.
                                ; Hope it still makes sense...
                                db '   Veuillez red‚marrer avec la disq AiR-BOOT pour restaurer.', 13, 10
                                db '   SystŠme arrˆt‚. Veuillez appuyez RESET.', 0
