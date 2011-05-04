;------------------------------------------------------------------------------
;                                                          AiR-BOOT / MBR-TEXT
; v001 - German - by Martin Kiewitz
;------------------------------------------------------------------------------

TXT_LanguageID                equ 'G'

; Those strings are saved within MBR.
; Total Length maximum 165 chars (include 13,10 (CRs), excluding ending Zeros)

TXT_ERROR_Attention            db 'AiR-BOOT: !ACHTUNG!', 13, 10, 0
TXT_ERROR_CheckCode            db ' - AiR-BOOT''s Code', 0
TXT_ERROR_CheckFailed          db ' ist nicht mehr intakt.', 13, 10
                               db '   Booten Sie via AiR-BOOT Diskette.', 13, 10
                               db '   System angehalten. Bitte drÅcken Sie RESET.', 0
