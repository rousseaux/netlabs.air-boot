;------------------------------------------------------------------------------
;                                                        AiR-BOOT / OTHER TEXT
; v001 - Dutch - by Kris Steenhaut
;------------------------------------------------------------------------------

TXT_TranslationBy              db 'Dutch by Kris Steenhaut', 0

; TopInfosX variables are used for Boot-Menu and Partition Setup

; Maximum 2/10/11/6 chars
;----------------------------------||---------------------------------------
TXT_TopInfos_No:               db 'Nr', 0
TXT_TopInfos_Hd:               db 'Hd', 0
;----------------------------------|----------|-----------------------------
TXT_TopInfos_HdSize:           db 'Hd/Grootte:', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_Label:            db 'Benamimg:', 0
;----------------------------------|---------|------------------------------
TXT_TopInfos_Type:             db 'Type:', 0
;----------------------------------|----|-----------------------------------
TXT_TopInfos_Flags:            db 'Flags:', 0      ; <-- for Partition Setup

; Will be added together to one line, maximum 76 chars
TXT_TimedBootLine:             db 'Tijd over: er wordt opgestart van '''
TXT_TimedBootEntryName         db 12 dup (0) ; Space for Default-Entry-Name
TXT_TimedBootLine2:            db      ''' de partitie na ', 0
TXT_TimedBootSeconds:          db ' seconden. ', 0
TXT_TimedBootSecond:           db ' second. ', 0 ; if only one is left, ELiTE :]
; Maximum 76 chars
;----------------------------------|--------------------------------------------------------------------------|
TXT_TimedBootDisabled:         db 'Het opstarten werd onderbroken. Tik op [Esc] om verder te gaan.', 0
TXT_BootMenuHelpText1:         db '[Esc] om te onderbreken/vervolgen.[Enter] om de keuze te starten.', 0
TXT_BootMenuHelpText2:         db 'Andere keuze met de pijltjestoetsen, tik [TAB] om de bios uitvoer te zien.', 0
; Maximum 30 chars
;----------------------------------|----------------------------|
TXT_BootMenuEnterSetup         db 'Druk F10 voor setup', 0

; Dynamic Length (till 80 chars)
TXT_BrokenPartitionTable:      db 13, 10, ' - U hard disk bevat minstens 1 beschadigde paritietabel element of u hard disk'
                               db 13, 10, '   bevat bad sector. Systeem is gestopt.', 0
TXT_TooManyPartitions:         db 13, 10, ' - Er zijn teveel partities aanwezig. Het maximum is 30.', 0
TXT_NoBootAble:                db 13, 10, ' - Geen opstartpartitie beschikbaar. Systeem is gestopt.', 0
TXT_BIOSchanged:               db 13, 10, ' - Het BIOS werd gewijzigd! Controleer eerst op virussen.'
                               db 13, 10, '   Tik op een toets om verder te gaan...', 0
;----------------------------------|--------------------------------------------------------------------------|
TXT_VirusFoundMain:            db 13, 10, ' - !OPGELET! -> Virusje gevonden! <- !OPGELET!', 13, 10, 0
TXT_VirusFound1ok:             db '    verwijderd, maar er kan misschien niet meer juist worden opgestart. Is,', 13, 10
                               db '    dit het geval, herstart vanaf de AiR-BOOT systeem diskette.', 13, 10, 0
TXT_VirusFound1damn:           db '    Ook uw AiR-BOOT backup werd vernietigd. U moet dus terug opstarten', 13, 10
                               db '    vanaf uw AiR-BOOT systeem diskette.', 13, 10, 0
TXT_VirusFound1any:            db '    U doet er best aan eerst te controleren virus achterblijvertjes.', 13, 10, 0
TXT_VirusFound2:               db '    Deze bevinden zich in het MBR van de partitie die u wou opstarten.', 13, 10
                               db '    Gebruik hiervoor een anti-virusprogramma. Mogelijks slechts alarm.', 13, 10
                               db '    Na de vewijdering moet u een en ander opnieuw instellen. Ga naar', 13, 10
                               db '    ''Partities instellen'' en schakel VIBR-detectie tweemaal (aan/uit).', 13, 10
                               db '    Indien slechts vals alarm, "uit" laten staan.', 13, 10, 0
TXT_VirusFoundEnd:             db '    Afgebroken! Tik op de RESET knop.', 0
TXT_HowEnterSetup:             db 13, 10, ' - Shift/Ctrl of Alt ingeduwd houden voor de AiR-BOOT Setup.', 0

TXT_BootingNow1:               db 'Er wordt nu opgestart van de ', 0
; DO NOT MODIFY HERE
TXT_BootingNow2:               db ''''
TXT_BootingNowPartName:        db 12 dup (0) ; Space for BootThisPart-Name
; DO NOT MODIFY TILL HERE
TXT_BootingNowPartition:       db ''' partitie', 0
TXT_BootingNowKernel:          db ''' kernel', 0
TXT_BootingHide:               db '; actieve verbergen', 0
TXT_BootingWait:               db '; Wachten graag...', 13, 10, 13, 10, 0

; FIXED LENGTH - 11 chars each string
;----------------------------------|---------|------------------------------
TXT_Floppy_NoName:             db 'Geen label '
TXT_Floppy_Drive:              db 'Station A: '
TXT_Floppy_NoDisc:             db 'Geen media '

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_PleaseEnterPassword        db 'Wachtwoord intikken:', 0
; the following 3 strings have to equal or *longer* than PleaseEnterPassword
TXT_ProtectedSystem            db '** SYSTEEM VERSLEUTELD! **', 0
TXT_ProtectedSetup             db '** SETUP VERSLEUTELD! **', 0
TXT_ProtectedBootUp            db '** OPSTARTEN VERSLEUTELD! **', 0

; will get completed using TXT_ERROR_CheckFailed from MBR.asm
TXT_ERROR_CheckConfig          db 13, 10, ' - De configuratie', 0

;----------------------------------|----------------------------------------------------------|
TXT_TooManyTries               db 'EŠn keer teveel! Afgebroken!', 0
