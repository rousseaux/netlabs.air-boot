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
; v046 - Swedish - by Bj”rn S”derstr”m
;------------------------------------------------------------------------------

TXT_LanguageID                equ 'S'

; Those strings are saved within MBR.
; Total Length maximum 165 chars (include 13,10 (CRs), excluding ending Zeros)

TXT_ERROR_Attention            db 'AiR-BOOT: !VARNING!', 13, 10, 0
TXT_ERROR_CheckCode            db ' - Kod', 0
TXT_ERROR_CheckFailed          db ' hos AiR-BOOT inte intakt l„ngre.', 13, 10
                               db '   Boota via AiR-BOOTs disk f”r att †terskapa AiR-BOOT.', 13, 10
                               db '   System haltat. Tryck RESET.', 0
