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
;---------------------------------------------------------------------------
;                                          AiR-BOOT SETUP / ALL SETUP MENUS
; v001 - Italiano - di Stefano Gualtieri
;---------------------------------------------------------------------------

; Main Setup - Items - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUP_PartitionSetup       db 'CONFIGURA PARTIZIONI', 0
TXT_SETUP_BasicOptions         db 'OPZIONI PRINCIPALI', 0
TXT_SETUP_AdvOptions           db 'OPZIONI AVANZATE', 0
TXT_SETUP_ExtOptions           db 'OPZIONI SPECIALI', 0
TXT_SETUP_DefMasterPwd         db 'DEFINIRE PASSWORD PRINCIPALE', 0
TXT_SETUP_DefBootPwd           db 'DEFINIRE PASSWORD DI AVVIO', 0
TXT_SETUP_SaveAndExit          db 'SALVA IMPOSTAZIONI & ESCI', 0
TXT_SETUP_JustExit             db 'ABBANDONA SENZA SALVARE', 0

; The Letters for all flags in Partition Setup
TXT_SETUP_FlagLetterBootable   equ 'A'
TXT_SETUP_FlagLetterVIBR       equ 'V'
TXT_SETUP_FlagLetterHide       equ 'N'
TXT_SETUP_FlagLetterDrvLetter  equ 'D'
TXT_SETUP_FlagLetterExtMShack  equ 'P'

TXT_SETUP_LetterYes            equ 'S'
TXT_SETUP_LetterYes2           equ 'Z'
TXT_SETUP_LetterNo             equ 'N'

; Basic Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_DefaultSelection     db 'Selezione Standard', 0
TXT_SETUP_DefaultPart          db 'Partizione Predefinita', 0
TXT_SETUP_TimedBoot            db 'Avvio Temporizzato', 0
TXT_SETUP_TimedBootDelay       db 'Tempo Avvio Temp. (sec)', 0
TXT_SETUP_TimedKeyHandling     db 'Tasti e Temporizzazione', 0
TXT_SETUP_BootLastIfTimed      db 'Avvio Ultimo SO Tempor.', 0
TXT_SETUP_RememberLastBoot     db 'Ricorda Ultimo Avvio', 0
TXT_SETUP_RememberTimedBoot    db 'Ricorda Avvio Temporiz.', 0
TXT_SETUP_IncludeFloppy        db 'Includi Avvio da Floppy', 0
TXT_SETUP_MbrProtection        db 'Proteggi MBR', 0
TXT_SETUP_IgnoreMbrWrites      db '->Ignora modifiche MBR', 0
TXT_SETUP_MakeSounds           db 'Suoni di Sistema', 0
TXT_SETUP_CooperBars           db 'Barre colorate', 0

; Advanced Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_BootMenu             db 'Menu di Avvio', 0
TXT_SETUP_PartAutoDetect       db 'Rileva Partiz. Autom.', 0
TXT_SETUP_SecurityOptions      db '->Opzioni Sicurezza<-', 0
TXT_SETUP_PasswordedSetup      db 'Config. con Password', 0
TXT_SETUP_PasswordedSystem     db 'Sistema con Password', 0
TXT_SETUP_PasswordedChangeBoot db 'Cambio Avvio + Password', 0
TXT_SETUP_GetFloppyName        db 'Leggi Etichetta Floppy', 0
TXT_SETUP_GetFloppyName2Sec    db '-> Leggi Ogni 2 Secondi', 0
TXT_SETUP_VirusDetect          db 'Rilevaz. Virus', 0
TXT_SETUP_StealthDetect        db 'Rilevaz. Virus Stealth', 0
TXT_SETUP_VIBRdetect           db 'Rilevaz. VIBR', 0
TXT_SETUP_ContinueBIOSboot     db 'Continua Avvio dal BIOS', 0

; Extended Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
; [Linux support removed since v1.02]
;TXT_SETUP_LinuxKernelPart      db 'Partiz. kernel Linux', 0
;TXT_SETUP_LinuxDefaultKernel   db 'Kernel Linux predef.', 0
;TXT_SETUP_LinuxRootPart        db 'Partizione Root Linux', 0
; This here may be larger than 23 chars...
;TXT_SETUP_DefLinuxCmd          db 'DEFINIRE LINEA DI COMANDO LINUX', 0
TXT_SETUP_IgnoreLVM            db 'Ignorare LVM info.', 0
TXT_SETUP_ForceLBAUsage        db 'Forza uso LBA del BIOS', 0
TXT_SETUP_ExtPartMShack        db 'Est-Part MS Workaround', 0

; DYNAMIC LENGTH, maximum 11 chars excluding ending zero
;----------------------------------|---------|------------------------------
TXT_SETUP_MAGIC_Enabled        db 'Attivato', 0
TXT_SETUP_MAGIC_Disabled       db 'Disattivato', 0
TXT_SETUP_MAGIC_Detailed       db 'Dettagli', 0
TXT_SETUP_MAGIC_NoBootable     db 'No Avviab.', 0
; [Linux support removed since v1.02]
;TXT_SETUP_MAGIC_NoLinux        db 'No Linux', 0
TXT_SETUP_MAGIC_DoNothing      db 'Nessuna Az.', 0
TXT_SETUP_MAGIC_ResetTime      db 'Reset Timer', 0
TXT_SETUP_MAGIC_StopTime       db 'Ferma Timer', 0
TXT_SETUP_MAGIC_CDROM          db 'CD-ROM', 0
TXT_SETUP_MAGIC_Network        db 'Rete', 0
TXT_SETUP_MAGIC_ZIPLS          db 'ZIP/LS120', 0
; Max Length: 10 (used in Hide-Configuration as well)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Hidden         db 'Nascosta', 0
TXT_SETUP_MAGIC_Unhidden       db 'Visibile', 0
; Max Length: 10 ("C:" will be appended afterwards)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Set            db 'Forza a ', 0

; Setup Control Help - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUPHELP_Main:            db 24,32,25,32,26,32,27,' : Scelta Azione', 0
                               db               'Enter   : Conferma Azione', 0
                               db               'F10 : Salva Config. & Esci', 0
                               db               'Esc : Abbandona Config.', 0

TXT_SETUPHELP_SubMenu:         db 24,32,25,32,26,32,27,' : Scelta Opzione', 0
                               db               'PgUp/Dn : Cambio Opzione', 0
                               db               'F1  : Mostra Aiuto Opzione', 0
                               db               'Esc : Ritorna al Menu Principale', 0

TXT_SETUPHELP_PartSetup:       db 24,32,25,32,26,32,27,' : Scelta Partizione', 0
                               db               'Enter   : Modifica Etichetta', 0
                               db               'F1  : Opz. (premi tasto x camb.)', 0
                               db               'Esc : Ritorna al Menu Principale', 0

; HELP FOR EVERY MENU-ITEM, Maximum Length = 22 chars PER line. Maximum 5 lines

                                  ;1234567890123456789012
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_PartitionSetup:  db 'Rende le partizioni ', 0
                               db 'avviabili, cambia il', 0
                               db 'loro nome, le nasconde', 0
                               db 'etc.', 0
                               db 0
TXT_SETUPHELP_BasicOptions:    db 'Opzioni disponibili', 0
                               db 'per utenti anche non', 0
                               db 'esperti', 0
                               db 0
TXT_SETUPHELP_AdvOptions:      db 'Opzioni solo per', 0
                               db 'utenti esperti. Se si', 0
                               db 'ignora come agiscono', 0
                               db 'non utilizzarle', 0
                               db 0
TXT_SETUPHELP_ExtOptions:      db 'Opzioni speciali per', 0
                               db 'specifici sistemi', 0
                               db 'operativi', 0
                               db 0
TXT_SETUPHELP_DefMasterPwd:    db 'Definisce la password', 0
                               db 'per accedere alla', 0
                               db 'configurazione del', 0
                               db 'sistema', 0
                               db 0
TXT_SETUPHELP_DefBootPwd:      db 'Definisce la password', 0
                               db 'per accedere al', 0
                               db 'sistema', 0
                               db 0
TXT_SETUPHELP_SaveAndExit:     db 'Continua l''avvio e', 0
                               db 'salva le impostazioni', 0
                               db 'correnti', 0
                               db 0
TXT_SETUPHELP_JustExit:        db 'Continua l''avvio, ', 0
                               db 'ma non salva', 0
                               db 'le impostazioni', 0
                               db 0

TXT_SETUPHELP_InPartitionSetup db 'A -Avviabile (boot)', 0
                               db 'V -Rilevazione VIBR', 0
                               db 'N -Supporto Nascoste', 0
                               db 'L -Lettera Partizione', 0
                               db 'P -Est-Part MS inventi', 0
                               db 0

TXT_SETUPHELP_HideSetup:       db 'Definisce lo stato', 0
                               db 'delle altre partizioni', 0
                               db 'quando la partizione', 0
                               db 'selezionata viene', 0
                               db 'avviata', 0
                               db 0

; Basic Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_DefaultSelection db 'Cambia la selezione', 0
                               db 'standard', 0
                               db 0
TXT_SETUPHELP_TimedBoot        db 'AiR-BOOT procede', 0
                               db 'automaticamente dopo', 0
                               db 'il tempo indicato', 0
                               db 0
TXT_SETUPHELP_TimedBootDelay   db 'Tempo di ritardo per', 0
                               db 'Avvio Temporizzato', 0
                               db 0
TXT_SETUPHELP_TimedKeyHandling db 'Funzione eseguita in', 0
                               db 'caso di pressione di ', 0
                               db 'un tasto durante', 0
                               db 'l''Avvio Temporizzato', 0
                               db 0
TXT_SETUPHELP_BootLastIfTimed  db 'AiR-BOOT usa', 0
                               db 'l''ultima partizione', 0
                               db 'avviata in Avvio', 0
                               db 'Temporizzato. Oppure', 0
                               db 'usa la predefinita', 0
                               db 0
TXT_SETUPHELP_RememberLastBoot db 'AiR-BOOT posiziona', 0
                               db 'la barra del menu di', 0
                               db 'selezione partizione', 0
                               db 'sull''ultima avviata', 0
                               db 0
TXT_SETUPHELP_RememberTimeBoot db 'Come la precedente,', 0
                               db 'AiR-BOOT posiziona la', 0
                               db 'barra del menu anche', 0
                               db 'in caso di Avvio', 0
                               db 'Temporizzato', 0
                               db 0
TXT_SETUPHELP_IncludeFloppy    db 'AiR-BOOT permette di', 0
                               db 'avviare dal floppy A:', 0
                               db 'tramite il menu', 0
                               db 0
TXT_SETUPHELP_MbrProtection    db 'Protegge il MBR con un', 0
                               db 'programma residente.', 0
                               db 'Richiede 1 KByte di', 0
                               db 'memoria convenzionale.', 0
                               db 'Problemi con certi OS', 0
                               db 0
TXT_SETUPHELP_IgnoreMbrWrites  db 'Ignora le modifiche al', 0
                               db 'MBR, altrimenti blocca', 0
                               db 'il sistema', 0
                               db 0
TXT_SETUPHELP_MakeSounds       db 'Effetti sonori in', 0
                               db 'avvio tramite lo', 0
                               db 'speaker interno', 0
                               db 0
TXT_SETUPHELP_CooperBars       db 'Crea barre colorate', 0
                               db 'all''avvio del sistema', 0
                               db 0

; Advanced Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_BootMenu         db 'Disabilita: AiR-BOOT', 0
                               db 'avvia la partizione', 0
                               db 'predefinita (no menu)', 0
                               db 'Dettagli: mostra', 0
                               db 'altre informazioni', 0
                               db 0
TXT_SETUPHELP_PartAutoDetect   db 'Se AiR-BOOT trova ', 0
                               db 'nuove partizioni, le', 0
                               db 'rende automaticamente', 0
                               db 'avviabili', 0
                               db 0
TXT_SETUPHELP_PasswordedSetup  db 'AiR-BOOT chiede una', 0
                               db 'password per accedere', 0
                               db 'alla configurazione', 0
                               db 0
TXT_SETUPHELP_PasswordedSystem db 'AiR-BOOT chiede una', 0
                               db 'password per avviare', 0
                               db 'il sistema', 0
                               db 0
TXT_SETUPHELP_PasswordedBoot   db 'AiR-BOOT chiede una', 0
                               db 'password per cambiare', 0
                               db 'la partizione di avvio', 0
                               db 'se non si usa Avvio', 0
                               db 'Temporizzato', 0
                               db 0
TXT_SETUPHELP_GetFloppyName    db 'In caso il floppy sia', 0
                               db 'avviabile da menu,', 0
                               db 'AiR-BOOT mostra la', 0
                               db 'etichetta del floppy', 0
                               db 0
TXT_SETUPHELP_GetFloppyName2Sec db 'In aggiunta alla ', 0
                               db 'precedente, rilegge', 0
                               db 'l''etichetta del', 0
                               db 'floppy ogni 2 secondi', 0
                               db 0
TXT_SETUPHELP_VirusDetect      db 'Rileva virus normali', 0
                               db '(virus non troppo', 0
                               db 'aggressivi)', 0
                               db 0
TXT_SETUPHELP_StealthDetect    db 'Rileva virus tipo', 0
                               db 'Stealth (tunnell', 0
                               db 'virus)', 0
                               db 0
TXT_SETUPHELP_VIBRdetect       db 'Rileva virus tipo', 0
                               db 'VIBR, ovvero', 0
                               db 'Virus-In-Boot-Record', 0
                               db '(Virus da settore di', 0
                               db 'avvio)', 0
                               db 0
TXT_SETUPHELP_ContinueBIOSboot db 'Restituisce il', 0
                               db 'controllo al BIOS per', 0
                               db 'la gestione del', 0
                               db 'dispositivo di avvio', 0
                               db 0

; Extended Options - Help
;----------------------------------|--------------------|-------------------
; [Linux support removed since v1.02]
;TXT_SETUPHELP_LinuxKernelPart  db 'Partizione FAT-16', 0
;                               db 'contenente i vari', 0
;                               db 'kernels di Linux', 0
;                               db 0
;TXT_SETUPHELP_LinuxDefaultKrnl db 'Definisce il nome del', 0
;                               db 'kernel predefinito', 0
;                               db 0
;TXT_SETUPHELP_LinuxRootPart    db 'Cambia la partizione', 0
;                               db 'root di Linux', 0
;                               db 0
;TXT_SETUPHELP_DefLinuxCmd:     db 'Definisce la linea di', 0
;                               db 'comando per Linux, se', 0
;                               db 'disponibile', 0
;                               db 0
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_IgnoreLVM        db 'Se attivato AiR-BOOT', 0
                               db 'non cerca neanche LVM', 0
                               db 'informazione.', 0
                               db 0
TXT_SETUPHELP_ForceLBAUsage    db 'Forza l''uso delle API', 0
                               db 'LBA del BIOS invece', 0
                               db 'dell''uso misto di CHS', 0
                               db 'ed LBA.', 0
                               db 0
TXT_SETUPHELP_ExtPartMShack    db 'Abilita il cambiamento', 0
                               db 'dinamico della partiz.', 0
                               db 'estesa, da "type id"', 0
                               db 'standard a tipo MS', 0
                               db '(definito dal P-flag)', 0
                               db 0

; Maximum 26 chars (should not be reached)
;----------------------------------|------------------------|---------------
TXT_SETUPHELP_Base             db ' AIUTO ', 0
TXT_SETUPHELP_Enter            db '<INVIO>', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_PasswordOld          db 'Password Precedente:', 0
TXT_SETUP_PasswordDefine       db 'Definire Password:', 0
TXT_SETUP_PasswordVerify       db 'Verifica Password:', 0
TXT_SETUP_PasswordIncorrect    db 'Password Precedente Errata, Spiacente.', 0
TXT_SETUP_PasswordMismatch     db 'Incorretta, Mantenuta la Password Precedente.', 0
TXT_SETUP_PasswordDisabled     db 'Nessuna Password/Protezione Disabilitata.', 0
TXT_SETUP_PasswordMatched      db '** Corretta, Nuova Password Attivata **', 0

; Maximum 60 chars (should not be reached anyway)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_SaveAndExitNow       db 'SALVA IMPOSTAZ. & ESCI', 0
TXT_SETUP_QuitWithoutSaveNow   db 'ESCI SENZA SALVARE', 0
; Must be shorter than SaveAndExitNow / QuitWithoutSaveNow
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_AreYouSure1          db 'SEI SICURO?', 0
TXT_SETUP_AreYouSure2          db '(S/N)', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
; [Linux support removed since v1.02]
;TXT_SETUP_EnterLinuxCmdLine    db 'Inserire/modificare la linea di comando per Linux:', 0
;TXT_SETUP_NoLinuxInstalled     db 'Linux non installato nel sistema', 0
TXT_SETUP_NoLDLpartition       db 'Partizione selezionata non HPFS/FAT16/JFS', 0

; Maximum 34 chars (should not be reached)
;----------------------------------|--------------------------------|-------
TXT_SETUP_HideFeature          db 'Nascondi Partizioni', 0
;----------------------------------|---------------------|------------------
TXT_SETUP_HideFeature2         db 'Stato all''avvio ', 0

; Drive-Letter Menu Header - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUP_DriveLetter          db 'Lettera Partizione', 0

; Drive-Letter Keys - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUPHELP_DriveLetter      db 'Premere C a Z', 0

; Colors for special words hard-coded. Keep all 0s.
;TXT_SETUP_LowerMessage         db 'Programma ',0,'gratuito',0,' per uso privato non commerciale.',0
;                               db 'Proibita ',0,'ASSOLUTAMENTE',0,' distribuzione o uso di AiR-BOOT in ',0,'-OGNI-',0,' modo,',0
;                               db 'in caso di pagamento del prodotto o del servizio fornito con esso.',0
;                               db 'Se si vuole usare AiR-BOOT secondo ',0,'altre condizioni',0,', ',0,'preinstallarlo',0,' o ',0
;                               db 'distribuirlo',0,' , contattatemi via e-mail: ',0,'kiewitz@netlabs.org',0,' !',0
