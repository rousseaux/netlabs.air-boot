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
; v001 - German - by Martin Kiewitz
;---------------------------------------------------------------------------

; Main Setup - Items - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUP_PartitionSetup       db 'PARTITIONS SETUP', 0
TXT_SETUP_BasicOptions         db 'STANDARD OPTIONEN', 0
TXT_SETUP_AdvOptions           db 'ERWEITERTE OPTIONEN', 0
TXT_SETUP_ExtOptions           db 'SPEZIAL OPTIONEN', 0
TXT_SETUP_DefMasterPwd         db 'HAUPT PASSWORT DEFINIEREN', 0
TXT_SETUP_DefBootPwd           db 'BOOT PASSWORT DEFINIEREN', 0
TXT_SETUP_SaveAndExit          db 'SPEICHERN & VERLASSEN', 0
TXT_SETUP_JustExit             db 'VERLASSEN OHNE ZU SPEICHERN', 0

; The Letters for all flags in Partition Setup
TXT_SETUP_FlagLetterBootable   equ 'B'
TXT_SETUP_FlagLetterVIBR       equ 'V'
TXT_SETUP_FlagLetterHide       equ 'H'
TXT_SETUP_FlagLetterDrvLetter  equ 'L'
TXT_SETUP_FlagLetterExtMShack  equ 'P'

TXT_SETUP_LetterYes            equ 'J'
TXT_SETUP_LetterYes2           equ 'J'
TXT_SETUP_LetterNo             equ 'N'

; Basic Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_DefaultSelection     db 'Standard Selektion', 0
TXT_SETUP_TimedBoot            db 'Zeitgesteuerter Boot', 0
TXT_SETUP_TimedBootDelay       db '-> Anzahl Sekunden', 0
TXT_SETUP_TimedKeyHandling     db '-> Tastenaktion', 0
TXT_SETUP_BootLastIfTimed      db '-> Letzten wiederholen', 0
TXT_SETUP_RememberLastBoot     db 'Boot-Partition merken', 0
TXT_SETUP_RememberTimedBoot    db 'Zeit-Boot-Part. merken', 0
TXT_SETUP_IncludeFloppy        db 'Disk-LW hinzufÅgen', 0
TXT_SETUP_MbrProtection        db 'MBR Schutz', 0
TXT_SETUP_IgnoreMbrWrites      db '-> Ignoriere Schreiben', 0
TXT_SETUP_MakeSounds           db 'GerÑusche machen', 0
TXT_SETUP_CooperBars           db 'Cooper Bars', 0

; Advanced Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_BootMenu             db 'Boot MenÅ', 0
TXT_SETUP_PartAutoDetect       db 'Partition Autodetect', 0
TXT_SETUP_SecurityOptions      db '-> Sicherheit <-', 0
TXT_SETUP_PasswordedSetup      db 'Setup Passwort', 0
TXT_SETUP_PasswordedSystem     db 'System Passwort', 0
TXT_SETUP_PasswordedChangeBoot db 'Boot Passwort', 0
TXT_SETUP_GetFloppyName        db 'Lese Diskettennamen', 0
TXT_SETUP_GetFloppyName2Sec    db '-> ...alle 2 Sekunden', 0
TXT_SETUP_VirusDetect          db 'Virus Erkennung', 0
TXT_SETUP_StealthDetect        db 'Stealth Erkennung', 0
TXT_SETUP_VIBRdetect           db 'VIBR Erkennung', 0
TXT_SETUP_ContinueBIOSboot     db 'BIOS Boot fortsetzen', 0

; Extended Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
; [Linux support removed since v1.02]
;TXT_SETUP_LinuxKernelPart      db 'Linux Kernel Partition', 0
;TXT_SETUP_LinuxDefaultKernel   db 'Linux Default Kernel', 0
;TXT_SETUP_LinuxRootPart        db 'Linux Root Partition', 0
; This here may be larger than 23 chars...
;TXT_SETUP_DefLinuxCmd          db 'DEFINIERE LINUX KOMMANDOZEILE', 0
TXT_SETUP_IgnoreLVM            db 'Ignoriere LVM Daten', 0
TXT_SETUP_ForceLBAUsage        db 'Erzwinge BIOS-LBA', 0
TXT_SETUP_ExtPartMShack        db 'Erw-Part MS Workaround', 0

; DYNAMIC LENGTH, maximum 11 chars excluding ending zero
;----------------------------------|---------|------------------------------
TXT_SETUP_MAGIC_Enabled        db 'Aktiv', 0
TXT_SETUP_MAGIC_Disabled       db 'Inaktiv', 0
TXT_SETUP_MAGIC_Detailed       db 'Detailiert', 0
TXT_SETUP_MAGIC_NoBootable     db 'Nix Bootbar', 0
; [Linux support removed since v1.02]
;TXT_SETUP_MAGIC_NoLinux        db 'Kein Linux', 0
TXT_SETUP_MAGIC_DoNothing      db 'Nichts', 0
TXT_SETUP_MAGIC_ResetTime      db 'Zeit Reset', 0
TXT_SETUP_MAGIC_StopTime       db 'Zeit Stop', 0
TXT_SETUP_MAGIC_CDROM          db 'CD-ROM', 0
TXT_SETUP_MAGIC_Network        db 'Netzwerk', 0
TXT_SETUP_MAGIC_ZIPLS          db 'ZIP/LS120', 0
; Max Length: 10 (used in Hide-Configuration as well)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Hidden         db 'Versteckt', 0
TXT_SETUP_MAGIC_Unhidden       db 'Sichtbar', 0
; Max Length: 10 ("C:" will be appended afterwards)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Set            db 'setze ', 0

; Setup Control Help - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUPHELP_Main:            db 24,32,25,32,26,32,27,' : Aktion AuswÑhlen', 0
                               db               'Enter   : Aktion BestÑtigen', 0
                               db               'F10 : Speichern&Beenden', 0
                               db               'Esc : Beenden', 0

TXT_SETUPHELP_SubMenu:         db 24,32,25,32,26,32,27,' : Option AuswÑhlen', 0
                               db               'Bild ',24,25,' : Option éndern', 0
                               db               'F1  : Zeige Hilfe Åber Option', 0
                               db               'Esc : ZurÅck ins HauptmenÅ', 0

TXT_SETUPHELP_PartSetup:       db 24,32,25,32,26,32,27,' : Partition AuswÑhlen', 0
                               db               'Enter   : Label editieren', 0
                               db               'F1  : Optionen', 0
                               db               'Esc : ZurÅck ins HauptmenÅ', 0

; HELP FOR EVERY MENU-ITEM, Maximum Length = 22 chars PER line. Maximum 5 lines

                                  ;1234567890123456789012
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_PartitionSetup:  db 'Partionen als Bootbar', 0
                               db 'definieren, Namen', 0
                               db 'Ñndern und einiges', 0
                               db 'mehr.', 0
                               db 0
TXT_SETUPHELP_BasicOptions:    db 'Diese Optionen sind', 0
                               db 'fÅr unerfahrene User.', 0
                               db 0
TXT_SETUPHELP_AdvOptions:      db 'Diese Optionen sind', 0
                               db 'fÅr erfahrene User.', 0
                               db 'VerÑndern Sie nichts,', 0
                               db 'falls Sie nicht wissen', 0
                               db 'was es bedeutet.', 0
                               db 0
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_ExtOptions:      db 'Spezial Optionen fÅr', 0
                               db 'bestimmte Betriebs-', 0
                               db 'system.', 0
                               db 0
TXT_SETUPHELP_DefMasterPwd:    db 'Definiert ein Passwort', 0
                               db 'fÅr Setup und System.', 0
                               db 0
TXT_SETUPHELP_DefBootPwd:      db 'Definiert ein Passwort', 0
                               db 'fÅrs Booten.', 0
                               db 0
TXT_SETUPHELP_SaveAndExit:     db 'Mit dem Boot-Prozess', 0
                               db 'fortfahren und die', 0
                               db 'Optionen speichern.', 0
                               db 0
TXT_SETUPHELP_JustExit:        db 'Mit dem Boot-Prozess', 0
                               db 'fortfahren und die', 0
                               db 'énderungen verwerfen.', 0
                               db 0

TXT_SETUPHELP_InPartitionSetup db 'B - Bootbar', 0
                               db 'V - VIBR-Detection', 0
                               db 'H - Hide Support', 0
                               db 'L - Laufwerksbuchstabe', 0
                               db 'P - Erw-Part MS invent', 0
                               db 0

TXT_SETUPHELP_HideSetup:       db 'Status wÑhlen, indem', 0
                               db 'sich die Partitionen', 0
                               db 'befinden sollen, wenn', 0
                               db 'die ausgewÑhlte', 0
                               db 'Partition geladen wird', 0
                               db 0

; Basic Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_DefaultSelection db 'éndert die Standard', 0
                               db 'Selektion. Wird u.a.', 0
                               db 'beim zeitgesteuerten', 0
                               db 'Boot verwendet.', 0
                               db 0
TXT_SETUPHELP_TimedBoot        db 'Automatisiertes Booten', 0
                               db 'nach einer bestimmten', 0
                               db 'Verzîgerung.', 0
                               db 0
TXT_SETUPHELP_TimedBootDelay   db 'Die Verzîgerungsdauer.', 0
                               db 0
TXT_SETUPHELP_TimedKeyHandling db 'Was soll mit der Zeit', 0
                               db 'passieren, sobald eine', 0
                               db 'Taste im BootmenÅ', 0
                               db 'gedrÅckt wird ?', 0
                               db 0
TXT_SETUPHELP_BootLastIfTimed  db 'Soll automatisiertes', 0
                               db 'Booten den letzten', 0
                               db 'Boot wiederholen oder', 0
                               db 'die Default Partition', 0
                               db 'laden ?', 0
                               db 0
TXT_SETUPHELP_RememberLastBoot db 'Soll sich AiR-BOOT den', 0
                               db 'letzten manuellen', 0
                               db 'Boot merken ?', 0
                               db 0
TXT_SETUPHELP_RememberTimeBoot db 'Soll sich AiR-BOOT den', 0
                               db 'letzten automatischen', 0
                               db 'Boot merken ?', 0
                               db 0
TXT_SETUPHELP_IncludeFloppy    db 'AiR-BOOT erlaubt das', 0
                               db 'Booten von Laufwerk A:', 0
                               db 0
TXT_SETUPHELP_MbrProtection    db 'BeschÅtzt Ihren MBR', 0
                               db 'durch residenten Code.', 0
                               db 'Benîtigt 1 KByte.', 0
                               db 'Kann inkompatibel zu', 0
                               db 'manchen OSen sein.', 0
                               db 0
TXT_SETUPHELP_IgnoreMbrWrites  db 'MBR Schutz ignoriert', 0
                               db 'hiermit alle Schreib-', 0
                               db 'Befehle und hÑlt das', 0
                               db 'System nicht an.', 0
                               db 0
TXT_SETUPHELP_MakeSounds       db 'Hiermit macht AiR-BOOT', 0
                               db 'GerÑusche mit dem', 0
                               db 'internen Lautsprecher.', 0
                               db 0
TXT_SETUPHELP_CooperBars       db 'Hiermit wird ein GFX', 0
                               db 'Effekt beim Booten', 0
                               db 'angezeigt.', 0
                               db 0

; Advanced Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_BootMenu         db 'Ohne BootmenÅ wird', 0
                               db 'direkt die Default', 0
                               db 'Partition gebootet.', 0
                               db 0
TXT_SETUPHELP_PartAutoDetect   db 'Neue Partitionen', 0
                               db 'werden hiermit als', 0
                               db 'bootbar markiert.', 0
                               db 0
TXT_SETUPHELP_PasswordedSetup  db 'Das Setup wird hiermit', 0
                               db 'passwortgeschÅtzt.', 0
                               db 0
TXT_SETUPHELP_PasswordedSystem db 'Das ganze System wird', 0
                               db 'hiermit passwort-', 0
                               db 'geschÅtzt.', 0
                               db 0
TXT_SETUPHELP_PasswordedBoot   db 'Manuelles Booten wird', 0
                               db 'hiermit passwort-', 0
                               db 'geschÅtzt.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName    db 'AiR-BOOT wird hiermit', 0
                               db 'den Disketten-Namen', 0
                               db 'einmal auslesen und', 0
                               db 'anzeigen.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName2Sec db 'ZusÑtzlich wird der', 0
                               db 'Disketten-Name alle', 0
                               db '2 Sekunden ausgelesen.', 0
                               db 0
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_VirusDetect      db 'Findet normale MBR-', 0
                               db 'Viren.', 0
                               db 0
TXT_SETUPHELP_StealthDetect    db 'Findet Stealth MBR-', 0
                               db 'Viren.', 0
                               db 0
TXT_SETUPHELP_VIBRdetect       db 'Findet VIBR-Viren.', 0
                               db 'VIBR steht fÅr', 0
                               db 'Virus-In-Boot-Record.', 0
                               db 0
TXT_SETUPHELP_ContinueBIOSboot db 'ZusÑtzlicher Eintrag', 0
                               db 'um via BIOS bestimmte', 0
                               db 'weitere Medien zu', 0
                               db 'booten.', 0
                               db 0

; Extended Options - Help
;----------------------------------|--------------------|-------------------
; [Linux support removed since v1.02]
;TXT_SETUPHELP_LinuxKernelPart  db 'Definiert die FAT-16', 0
;                               db 'Partition, die Linux', 0
;                               db 'Kernels beinhaltet.', 0
;                               db 0
;TXT_SETUPHELP_LinuxDefaultKrnl db 'Definiert den Default', 0
;                               db 'Kernel Namen.', 0
;                               db 0
;TXT_SETUPHELP_LinuxRootPart    db 'Definiert die Linux', 0
;                               db 'Root Partition.', 0
;                               db 0
;TXT_SETUPHELP_DefLinuxCmd:     db 'Definiert die Linux', 0
;                               db 'Kommandozeile.', 0
;                               db 0
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_IgnoreLVM        db 'AiR-BOOT sucht in', 0
                               db 'diesem Fall nicht nach', 0
                               db 'LVM Informationen.', 0
                               db 0
TXT_SETUPHELP_ForceLBAUsage    db 'Erzwingt BenÅtzung der', 0
                               db 'BIOS LBA APIs anstatt', 0
                               db 'gemischter Verwendung', 0
                               db 'von CHS und LBA.', 0
                               db 0
TXT_SETUPHELP_ExtPartMShack    db 'Aktiviert dynamisches', 0
                               db 'Ñndern des erweiterten', 0
                               db 'Partitionstyp durch', 0
                               db 'das P-Flag in Standard', 0
                               db 'oder MS-Erfindung.', 0
                               db 0

; Maximum 26 chars (should not be reached)
;----------------------------------|------------------------|---------------
TXT_SETUPHELP_Base             db ' HILFE ', 0
TXT_SETUPHELP_Enter            db '<ENTER>', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_PasswordOld          db 'Altes Passwort:', 0
TXT_SETUP_PasswordDefine       db 'Definiere Passwort:', 0
TXT_SETUP_PasswordVerify       db 'öberprÅfe Passwort:', 0
TXT_SETUP_PasswordIncorrect    db 'Altes Passwort inkorrekt, Sorry', 0
TXT_SETUP_PasswordMismatch     db 'Nicht gleich, altes Passwort beibehalten', 0
TXT_SETUP_PasswordDisabled     db 'Kein Passwort -> Schutz Deaktiviert', 0
TXT_SETUP_PasswordMatched      db '** Neues Passwort Gesetzt **', 0

; Maximum 60 chars (should not be reached anyway)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_SaveAndExitNow       db 'SPEICHERN & VERLASSEN', 0
TXT_SETUP_QuitWithoutSaveNow   db 'VERLASSEN OHNE SPEICHERN', 0
; Must be shorter than SaveAndExitNow / QuitWithoutSaveNow
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_AreYouSure1          db 'SIND SIE SICHER?', 0
TXT_SETUP_AreYouSure2          db '(J/N)', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
; [Linux support removed since v1.02]
;TXT_SETUP_EnterLinuxCmdLine    db 'Bitte geben Sie ihre Linux Kommandozeile ein:', 0
;TXT_SETUP_NoLinuxInstalled     db 'Sie haben kein Linux installiert', 0
TXT_SETUP_NoLDLpartition       db 'Diese Partition ist weder vom Typ HPFS/FAT16/JFS', 0

; Maximum 34 chars (should not be reached)
;----------------------------------|--------------------------------|-------
TXT_SETUP_HideFeature          db 'Hide Funktion', 0
;----------------------------------|---------------------|------------------
TXT_SETUP_HideFeature2         db 'Status fÅrs Booten von ', 0

; Drive-Letter Menu Header - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUP_DriveLetter          db 'Laufwerksbuchstabe', 0

; Drive-Letter Keys - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUPHELP_DriveLetter      db 'C-Z drÅcken', 0

; Colors for special words hard-coded. Keep all 0s.
;TXT_SETUP_LowerMessage         db 'Dieses Programm ist ',0,'kostenlos',0,' fÅr nicht-kommerzielle BenÅtzung.',0
;                               db 'Sie dÅrfen AiR-BOOT ',0,'NICHT',0,' in ',0,'-IRGENDEINER-',0,' Form vertreiben/benÅtzen,',0
;                               db 'falls Sie Geld fÅr das jeweilige Produkt oder die Installation erhalten.',0
;                               db 'Sofern Sie AiR-BOOT in ',0,'anderen Bereichen',0,' benutzen oder',0,0,0
;                               db 'vorinstallieren',0,' mîchten, kontaktieren Sie mich via: ',0,'kiewitz@netlabs.org',0,' !',0
