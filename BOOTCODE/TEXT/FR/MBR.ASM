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
                               db '   Veuillez red‚marrer avec la disquette AiR-BOOT afin de le restaurer.', 13, 10
                               db '   SystŠme arrˆt‚. Veuillez appuyez sur RESET.', 0
