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
