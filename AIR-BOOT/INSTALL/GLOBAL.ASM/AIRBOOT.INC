TotalSectorsUsedPtr            equ  16   ; offset in MBR
; TotalSectorsUsed means the Code-sectors count beginning from Sector 2 (!!)

AiR_BOOT_MaxInstallDiscLocation   equ   0907h
; jedesmal bis 08h, dann wieder bei 1 anfangen
; Install Image -> 16 Sektoren
