;------------------------------------------------------------------------------
;                                                          AiR-BOOT / MBR-TEXT
; v001 - Italiano - by Stefano Gualtieri
;------------------------------------------------------------------------------

TXT_LanguageID                equ 'I'

; Those strings are saved within MBR.
; Total Length maximum 165 chars (include 13,10 (CRs), excluding ending Zeros)

TXT_ERROR_Attention            db 'AiR-BOOT: !ATTENZIONE!', 13, 10, 0
TXT_ERROR_CheckCode            db ' - Il codice', 0
TXT_ERROR_CheckFailed          db ' di AiR-BOOT e'' danneggiato.', 13, 10
                               db '   Riavviare con il floppy di AiR-BOOT per ripristinarlo.', 13, 10
                               db '   Sistema bloccato. Premere RESET.', 0
