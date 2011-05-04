;------------------------------------------------------------------------------
;                                                          AiR-BOOT / MBR-TEXT
; v001 - Dutch - by Kris Steenhaut
;------------------------------------------------------------------------------

TXT_LanguageID                equ 'D'

; Those strings are saved within MBR.
; Total Length maximum 165 chars (include 13,10 (CRs), excluding ending Zeros)

TXT_ERROR_Attention            db 'AiR-BOOT: !OPGELET!', 13, 10, 0
TXT_ERROR_CheckCode            db ' - AiR-BOOT', 0
TXT_ERROR_CheckFailed          db ' is niet goed meer ge‹nstalleerd!', 13, 10
                               db '   Start opnieuw op vanaf de Airboot diskette.', 13, 10
                               db '   Afgebroken! Tik op de RESET knop .', 0
