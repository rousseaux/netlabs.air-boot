;------------------------------------------------------------------------------
;                                                          AiR-BOOT / MBR-TEXT
; v001 - Russian - by Denis Tazetdinov
;------------------------------------------------------------------------------

TXT_LanguageID                equ 'R'
TXT_IncludeCyrillic           equ ON

; Those strings are saved within MBR.
; Total Length maximum 165 chars (include 13,10 (CRs), excluding ending Zeros)

TXT_ERROR_Attention            db 'AiR-BOOT: !ATTENTION!', 13, 10, 0
TXT_ERROR_CheckCode            db ' - The code', 0
TXT_ERROR_CheckFailed          db ' of AiR-BOOT is not intact anymore.', 13, 10
                               db '   Please boot via AiR-BOOT disc to restore AiR-BOOT.', 13, 10
                               db '   System halted. Please press RESET.', 0
