;------------------------------------------------------------------------------
;                                                        AiR-BOOT / OTHER TEXT
; v001 - Italiano - by Stefano Gualtieri
;------------------------------------------------------------------------------

TXT_TranslationBy              db 'Italian by Stefano Gualtieri', 0

; TopInfosX variables are used for Boot-Menu and Partition Setup

; Maximum 2/10/11/6 chars
;----------------------------------||---------------------------------------
TXT_TopInfos_No:               db 'Nr', 0
TXT_TopInfos_Hd:               db 'Hd', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_HdSize:           db 'Hd/Size:', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_Label:            db 'Etichetta:', 0
;----------------------------------|---------|------------------------------
TXT_TopInfos_Type:             db 'Tipo:', 0
;----------------------------------|----|-----------------------------------
TXT_TopInfos_Flags:            db 'Flags:', 0      ; <-- for Partition Setup

; Will be added together to one line, maximum 76 chars
TXT_TimedBootLine:             db 'Timer di Avvio Attivato. Avvio con '''
TXT_TimedBootEntryName         db 12 dup (0) ; Space for Default-Partition-Name
TXT_TimedBootLine2:            db      ''' tra ', 0
TXT_TimedBootSeconds:          db ' secondi. ', 0
TXT_TimedBootSecond:           db ' secondo. ', 0 ; if only one is left, ELiTE :]
; Maximum 76 chars
;----------------------------------|--------------------------------------------------------------------------|
TXT_TimedBootDisabled:         db 'Avvio Temporizzato Disabilitato. Pausa.', 0
TXT_BootMenuHelpText1:         db 'Premere [Esc] per resettare il timer, [Invio] per accettare la selezione.', 0
TXT_BootMenuHelpText2:         db 'Selezionare con i tasti freccia, oppure [TAB] per i messaggi POST del BIOS.', 0
TXT_BootMenuEnterSetup         db 'F10 to enter Setup', 0

; Dynamic Length (till 80 chars)
TXT_TooManyPartitions:         db 13, 10, ' - Trovate troppe partizioni. AiR-BOOT ne supporta fino a 30.', 0
TXT_NoBootAble:                db 13, 10, ' - Nessuna partizione avviabile definita. Sistema bloccato.', 0
TXT_BIOSchanged:               db 13, 10, ' - BIOS MODIFICATO! Controllare il sistema contro eventuali virus.'
                               db 13, 10, '   Premere un tasto per continuare...', 0

TXT_VirusFoundMain:            db 13, 10, ' - !ATTENZIONE! -> RILEVATO UN VIRUS <- !ATTENZIONE!', 13, 10, 0
TXT_VirusFound1ok:             db '    Ora sara'' sovrascritto, ma il sistema potrebbe non riavviarsi', 13, 10
                               db '    correttamente. In tal caso utilizzare il dischetto di AiR-BOOT.', 13, 10, 0
TXT_VirusFound1damn:           db '    Purtroppo il backup di AiR-BOOT non funziona. Riavviare con il', 13, 10
                               db '    dischetto di AiR-BOOT.', 13, 10, 0
TXT_VirusFound1any:            db '    Per sicurezza, controllare i dischi in caso di altre tracce virali. ', 13, 10, 0
TXT_VirusFound2:               db '    Il virus risiede nel boot-record della partizione in avvio.', 13, 10
                               db '    Usare un programma antivirus. Potrebbe anche essere un falso allarme.', 13, 10
                               db '    Dopo la rimozione occorre reinizializzare il rilevamento virus. Andare', 13, 10
                               db '    in ''CONFIGURAZIONE PARTIZIONI'' e modificare due volte Rilevamento VIBR', 13, 10
                               db '     (off/on). Se si tratta di falso allarme, lasciarlo disinserito (off).', 13, 10, 0
TXT_VirusFoundEnd:             db '    Sistema bloccato. Premere RESET.', 0
TXT_HowEnterSetup:             db 13, 10, ' - Premere e tenere premuto Ctrl o Alt per configurare AiR-BOOT.', 0

TXT_BootingNow1:               db 'Avvio del sistema con ', 0
; DO NOT MODIFY HERE
TXT_BootingNow2:               db ''''
TXT_BootingNowPartName:        db 12 dup (0) ; Space for BootThisPart-Name
; DO NOT MODIFY TILL HERE
TXT_BootingNowPartition:       db '''', 0
TXT_BootingNowKernel:          db ''' kernel', 0
TXT_BootingHide:               db '; part. attiva nascosta', 0
TXT_BootingWait:               db '; attendere, prego...', 13, 10, 13, 10, 0

; FIXED LENGTH - 11 chars each string
;----------------------------------|---------|------------------------------
TXT_Floppy_NoName:             db 'Nessun Nome'
TXT_Floppy_Drive:              db 'FloppyDrive'
TXT_Floppy_NoDisc:             db 'No Disco   '

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_PleaseEnterPassword        db ' Inserire la Password:', 0
; the following 3 strings have to equal or *longer* than PleaseEnterPassword
TXT_ProtectedSystem            db '** SISTEMA PROTETTO DA PASSWORD **', 0
TXT_ProtectedSetup             db '** CONFIGURAZIONE PROTETTA DA PASSWORD **', 0
TXT_ProtectedBootUp            db '** AVVIO PROTETTO DA PASSWORD **', 0

; will get completed using TXT_ERROR_CheckFailed from MBR.asm
TXT_ERROR_CheckConfig          db 13, 10, ' - La configurazione', 0

;----------------------------------|----------------------------------------------------------|
TXT_TooManyTries               db 'Troppi tentativi, Sistema Bloccato.', 0






