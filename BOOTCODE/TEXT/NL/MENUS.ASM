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
; v001 - Dutch - by Kris Steenhaut
;---------------------------------------------------------------------------

; Main Setup - Items - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUP_PartitionSetup       db 'PARTITIE-INDELING', 0
TXT_SETUP_BasicOptions         db 'ALGEMENE OPTIES', 0
TXT_SETUP_AdvOptions           db 'GEAVANCEERDE OPTIES', 0
TXT_SETUP_ExtOptions           db 'NOG MEER OPSTARTOPTIES', 0
TXT_SETUP_DefMasterPwd         db 'ALGEMEEN WACHTWOORD INSTELLEN', 0
TXT_SETUP_DefBootPwd           db 'WACHTWOORD VOOR HET OPSTARTEN', 0
TXT_SETUP_SaveAndExit          db 'OPSLAAN EN AFSLUITEN', 0
TXT_SETUP_JustExit             db 'AFSLUITEN ZONDER OPSLAAN', 0

; The Letters for all flags in Partition Setup
TXT_SETUP_FlagLetterBootable   equ 'O'
TXT_SETUP_FlagLetterVIBR       equ 'D'
TXT_SETUP_FlagLetterHide       equ 'V'
TXT_SETUP_FlagLetterDrvLetter  equ 'L'
TXT_SETUP_FlagLetterExtMShack  equ 'P'

TXT_SETUP_LetterYes            equ 'J'
TXT_SETUP_LetterYes2           equ 'J'
TXT_SETUP_LetterNo             equ 'N'

; Basic Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_DefaultSelection     db 'Standaardkeuze', 0
TXT_SETUP_TimedBoot            db 'Opstart met wachttijd', 0
TXT_SETUP_TimedBootDelay       db 'Wachttijd: aantal sec', 0
TXT_SETUP_TimedKeyHandling     db 'Toetsuitvoer regelen', 0
TXT_SETUP_BootLastIfTimed      db 'Met wachttijd: ', 0
TXT_SETUP_RememberLastBoot     db 'Vorige keuze', 0
TXT_SETUP_RememberTimedBoot    db 'Vorige keuze/wachttijd', 0
TXT_SETUP_IncludeFloppy        db 'Inclusief station A:', 0
TXT_SETUP_ShowLVMDriveLetters  db 'Toon LVM Drive Letters',0
TXT_SETUP_MbrProtection        db 'MBR beveiligen', 0
TXT_SETUP_IgnoreMbrWrites      db '-> MBR niet beveiligen', 0
TXT_SETUP_MakeSounds           db 'Geluidje laten horen', 0
TXT_SETUP_CooperBars           db 'Coopers lichtspel', 0

; Advanced Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_BootMenu             db 'Opstartmenu', 0
TXT_SETUP_PartAutoDetect       db 'Autodetectie partities', 0
TXT_SETUP_SecurityOptions      db '-> Beveiliging <-', 0
TXT_SETUP_PasswordedSetup      db 'Setup versleuteld', 0
TXT_SETUP_PasswordedSystem     db 'Systeem versleuteld', 0
TXT_SETUP_PasswordedChangeBoot db 'Opstarten versleuteld', 0
TXT_SETUP_GetFloppyName        db 'Zoek het diskettelabel', 0
TXT_SETUP_GetFloppyName2Sec    db '-> Elke 2 seconden', 0
TXT_SETUP_VirusDetect          db 'Virussen opzoeken', 0
TXT_SETUP_StealthDetect        db 'Stealth viri opzoeken', 0
TXT_SETUP_VIBRdetect           db 'VIBR opzoeken', 0
TXT_SETUP_ContinueBIOSboot     db 'Opstarten van :', 0

; Extended Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
; [Linux support removed since v1.02]
;TXT_SETUP_LinuxKernelPart      db 'Linux Kernel Partitie', 0
;TXT_SETUP_LinuxDefaultKernel   db 'Linux Standaard Kernel', 0
;TXT_SETUP_LinuxRootPart        db 'Linux hoofdafdeling', 0
; This here may be larger than 23 chars...
;TXT_SETUP_DefLinuxCmd          db 'Opdrachtenreeks voor Linux', 0
TXT_SETUP_IgnoreLVM            db 'LVM-gegevens negeren', 0
;~ TXT_SETUP_ForceLBAUsage        db 'Enkel BIOS-LBA', 0
TXT_SETUP_ExtPartMShack        db 'Ext-Part MS Workaround', 0
;----------------------------------|---------------------|------------------

; DYNAMIC LENGTH, maximum 11 chars excluding ending zero
;----------------------------------|---------|------------------------------
TXT_SETUP_MAGIC_Enabled        db 'Actief', 0
TXT_SETUP_MAGIC_Disabled       db 'Niet actief', 0
TXT_SETUP_MAGIC_Detailed       db 'Alles', 0
TXT_SETUP_MAGIC_NoBootable     db 'Geen opstbr', 0
; [Linux support removed since v1.02]
;TXT_SETUP_MAGIC_NoLinux        db 'Geen Linux', 0
TXT_SETUP_MAGIC_DoNothing      db 'Negeren', 0
TXT_SETUP_MAGIC_ResetTime      db 'Tijd op nul', 0
TXT_SETUP_MAGIC_StopTime       db 'Onderbreken', 0
TXT_SETUP_MAGIC_CDROM          db 'CD-ROM', 0
TXT_SETUP_MAGIC_Network        db 'Netwerk', 0
TXT_SETUP_MAGIC_ZIPLS          db 'ZIP/LS120', 0
; Max Length: 10 (used in Hide-Configuration as well)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Hidden         db 'Verbergen', 0
TXT_SETUP_MAGIC_Unhidden       db 'Zichtbaar', 0
; Max Length: 10 ("C:" will be appended afterwards)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Set            db 'kies ', 0

; Setup Control Help - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUPHELP_Main             db 24,32,25,32,26,32,27,' : Maak uw keuze', 0
                               db 'Enter   : Keuze bevestigen', 0
                               db 'F10 : Opslaan en afsluiten', 0
                               db 'Esc : Setup afsluiten', 0

TXT_SETUPHELP_SubMenu          db 24,32,25,32,26,32,27,' : Item kiezen', 0
                               db 'PgUp/Dn : Onderdelen van het item', 0
                               db 'F1  : Hulp voor dit item', 0
                               db 'Esc : Terug naar het hoofdmenu', 0

TXT_SETUPHELP_PartSetup        db 24,32,25,32,26,32,27,' : Partitie kiezen', 0
                               db 'Enter   : Label bewerken', 0
                               db 'F1  : Uitleg bij de toetsen', 0
                               db 'Esc : Terug naar het hoofdmenu', 0

; HELP FOR EVERY MENU-ITEM, Maximum Length = 22 chars PER line. Maximum 5 lines

                                  ;1234567890123456789012
;----------------------------------|--------------------|--------------------
TXT_SETUPHELP_PartitionSetup   db 'Partities opstartbaar', 0
                               db 'maken, label wijzigen,', 0
                               db 'partities verbergen of', 0
                               db 'toegankelijk maken', 0
                               db 'en nog veel meer.', 0
                               db 0
TXT_SETUPHELP_BasicOptions     db 'Opties voor minder', 0
                               db 'ervaren gebruikers.', 0
                               db 0
TXT_SETUPHELP_AdvOptions       db 'Opties voor ervaren', 0
                               db 'gebruikers. Stel hier', 0
                               db 'niets in tenzij u goed', 0
                               db 'weet waarover het gaat.', 0
                               db 0
TXT_SETUPHELP_ExtOptions       db 'Opties enkel bedoeld', 0
                               db 'voor een bepaald sy-', 0
                               db 'steem.', 0
                               db 0
TXT_SETUPHELP_DefMasterPwd     db 'Wachtwoord instellen', 0
                               db 'voor de setup en voor', 0
                               db 'het systeem.', 0
                               db 0
TXT_SETUPHELP_DefBootPwd       db 'Wachtwoord instellen', 0
                               db 'voor de toegang', 0
                               db 'tot het systeeem.', 0
                               db 0
TXT_SETUPHELP_SaveAndExit      db 'Het opstarten wordt nu', 0
                               db 'verder gezet terwijl', 0
                               db 'de nieuwe instellingen' , 0
                               db 'bewaard worden.', 0
                               db 0
TXT_SETUPHELP_JustExit         db 'Het opstarten wordt nu', 0
                               db 'verder gezet terwijl', 0
                               db 'de nieuwe instellingen' , 0
                               db 'NIET bewaard worden.', 0
                               db 0
TXT_SETUPHELP_InPartitionSetup db 'O - Opstartbaar', 0
                               db 'D - Detectie van VIBR', 0
                               db 'V - Verbergen', 0
                               db 'L - Partitie letter', 0
                               db 'P - Ext-Part MS invent', 0
                               db 0

TXT_SETUPHELP_HideSetup        db 'Bepaal hoe de andere', 0
                               db 'partities moeten wor-', 0
                               db 'den getoond wanneer', 0
                               db 'van de nu gekozen par-', 0
                               db 'titie wordt opgestart.', 0
                               db 0

; Basic Options - Help
;----------------------------------|--------------------|--------------------
TXT_SETUPHELP_DefaultSelection db 'Wijzigt de standaard-', 0
                               db 'selectie. Ook als er', 0
                               db 'een wachttijd werd', 0
                               db 'ingesteld.' ,0
                               db 0
TXT_SETUPHELP_TimedBoot        db 'AiR-BOOT zal automa-', 0
                               db 'tisch verder gaan na', 0
                               db 'een bepaald interval.', 0
                               db 0
TXT_SETUPHELP_TimedBootDelay   db 'De afteltijd', 0
                               db '(in seconden).', 0
                               db 0
TXT_SETUPHELP_TimedKeyHandling db 'Wat dient er te gebeu-', 0
                               db 'ren indien tijdens het', 0
                               db 'opstarten met wacht-', 0
                               db 'tijd een toets', 0
                               db 'wordt ingedrukt?', 0
                               db 0
TXT_SETUPHELP_BootLastIfTimed  db 'AiR-BOOT zal van de', 0
                               db 'vorig gekozen partitie', 0
                               db 'opstarten.', 0
                               db 'Ofwel de standaard-', 0
                               db 'partitie kiezen.', 0
                               db 0
TXT_SETUPHELP_RememberLastBoot db 'AiR-BOOT stelt de', 0
                               db 'menubalk in op de par-', 0
                               db 'titie die geselecteerd', 0
                               db 'werd tijdens de vorige' ,0
                               db 'opstart.', 0
                               db 0
TXT_SETUPHELP_RememberTimeBoot db 'Zoals hiervoor wordt', 0
                               db 'de menubalk ingesteld', 0
                               db 'gesteld op de partitie', 0
                               db 'die bij het vorige op-', 0
                               db 'starten werd gekozen.' ,0
                               db 0
TXT_SETUPHELP_IncludeFloppy    db 'U kunt van A: opstarten', 0
                               db 'via het AiR-BOOTmenu.', 0
                               db 0
TXT_SETUPHELP_ShowLVMDriveLetters   db 'AiR-BOOT will show', 0
                                    db 'LVM Drive Letters', 0
                                    db 'in the menu.', 0
                                    db 0
TXT_SETUPHELP_MbrProtection    db 'Beveiligt het MBR via', 0
                               db 'een residente code.', 0
                               db '1 Kb geheugen vereist.', 0
                               db 'Kan problemen geven', 0
                               db 'op bepaalde systemen.',0
                               db 0
TXT_SETUPHELP_IgnoreMbrWrites  db 'Indien dit werd inge-,', 0
                               db 'schakeld wordt elke', 0
                               db 'schrijfactie naar de', 0
                               db 'schijf genegeerd. An-', 0
                               db 'ders volgt een "crash".', 0
                               db 0
TXT_SETUPHELP_MakeSounds       db 'Geluidjes laten horen', 0
                               db 'via de interne', 0
                               db 'PC luidspreker.', 0
                               db 0
TXT_SETUPHELP_CooperBars       db 'Laat enkele leuke', 0
                               db 'dingetjes zien tijdens', 0
                               db 'het opstarten.', 0
                               db 0

; Advanced Options - Help
;----------------------------------|--------------------|--------------------
TXT_SETUPHELP_BootMenu         db '"Uitgeschakeld": geen', 0
                               db 'menu maar direct naar', 0
                               db 'de standaardpartitie.', 0
                               db '"Alles": laat details', 0
                               db 'en meer info zien.', 0
                               db 0
TXT_SETUPHELP_PartAutoDetect   db 'Worden nieuwe parti-', 0
                               db 'ties aangetrofen, dan', 0
                               db 'worden deze', 0
                               db 'opstartbaar gemaakt.', 0
                               db 0
TXT_SETUPHELP_PasswordedSetup  db 'Bij deze setup zal', 0
                               db 'u naar een wachtwoord', 0
                               db 'worden gevraagd.', 0
                               db 0
TXT_SETUPHELP_PasswordedSystem db 'Bij het opstarten', 0
                               db 'wordt u dan naar het', 0
                               db 'wachtwoord gevraagd.', 0
                               db 0
TXT_SETUPHELP_PasswordedBoot   db 'Wordt zonder wachttijd', 0
                               db 'opgestart, dan wordt u', 0
                               db 'naar het wachtwoord', 0
                               db 'gebraagd.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName    db 'AiR-BOOT toont ook het', 0
                               db 'diskettelabel in het,', 0
                               db 'opstartmenu.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName2Sec db 'Bovendien wordt het', 0
                               db 'diskettelabel elke 2', 0
                               db 'sec gecontroleerd.', 0
                               db 0
TXT_SETUPHELP_VirusDetect      db '"Doodgewone" virussen', 0
                               db 'worden opgezocht.', 0
                               db 0
TXT_SETUPHELP_StealthDetect    db 'Opzoeken Stealth', 0
                               db 'virussen.', 0
                               db 0
TXT_SETUPHELP_VIBRdetect       db 'Opzoeken VIBR.', 0
                               db 'VIBR betekent:', 0
                               db 'Virus-In-Boot-Record.', 0
                               db 0

;----------------------------------|--------------------|--------------------
TXT_SETUPHELP_ContinueBIOSboot db 'Terug naar BIOS om op', 0
                               db 'te starten van het', 0
                               db 'VOLGENDE apparaat zo-', 0
                               db 'als LS-120, Zipschijf,', 0
                               db 'netwerk, CD-Rom, ...', 0
                               db 0

; Extended Options - Help
;----------------------------------|--------------------|-------------------
; [Linux support removed since v1.02]
;TXT_SETUPHELP_LinuxKernelPart  db 'Bepaald de FAT-16', 0
;                               db 'partitie voor uw Li-', 0
;                               db 'nux kernelbestanden.', 0
;                               db 0
;TXT_SETUPHELP_LinuxDefaultKrnl db 'Specifieert de Linux', 0
;                               db 'standaard kernel be-', 0
;                               db 'standsnaam.', 0
;                               db 0
;TXT_SETUPHELP_LinuxRootPart    db 'Linux opstart-', 0
;                               db 'partitie wijzigen.', 0
;                               db 0
;TXT_SETUPHELP_DefLinuxCmd:     db 'Opdrachten voor Linux', 0
;                               db 'instellen, indien', 0
;                               db 'Linux beschikbaar.', 0
;                               db 0
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_IgnoreLVM        db 'Werd deze optie', 0
                               db 'geactiveerd,dan worden', 0
                               db 'LVM-gegevens als', 0
                               db 'onbestaande beschouwd.', 0
                               db 0
;~ TXT_SETUPHELP_ForceLBAUsage    db 'Uitschakelen van de', 0
                               ;~ db 'combinatie van LBA', 0
                               ;~ db 'en CHS. Er wordt dan', 0
                               ;~ db 'ENKEL gebruik gemaakt', 0
                               ;~ db 'van de BIOS LBA API''s.', 0
                               ;~ db 0
TXT_SETUPHELP_ExtPartMShack    db 'Schakelt dynamische', 0
                               db 'wijziging van ext.', 0
                               db 'part. type id naar', 0
                               db 'standaard of MS-Invent', 0
                               db '(gedef. door P optie)', 0
                               db 0

; Maximum 26 chars (should not be reached)
;----------------------------------|------------------------|---------------
TXT_SETUPHELP_Base             db ' Hulp ', 0
TXT_SETUPHELP_Enter            db '<ENTER>', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_PasswordOld          db 'Vorig wachtwoord:', 0
TXT_SETUP_PasswordDefine       db 'Wachtwoord instellen:', 0
TXT_SETUP_PasswordVerify       db 'Wachtwoord controleren:', 0
TXT_SETUP_PasswordIncorrect    db 'Vorig wachtwoord niet juist. Jammer!', 0
TXT_SETUP_PasswordMismatch     db 'Klopt niet! Het vorig wachtwoord wordt opnieuw ingesteld', 0
TXT_SETUP_PasswordDisabled     db 'Er werd geen wachtwoord ingesteld -> Beveiliging uitgeschakeld', 0
TXT_SETUP_PasswordMatched      db '** Klopt! Het nieuwe wachtwoord werd ingesteld **', 0

; Maximum 60 chars (should not be reached anyway)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_SaveAndExitNow       db 'Opslaan en afsluiten.', 0
TXT_SETUP_QuitWithoutSaveNow   db 'Afsluiten zonder op te slaan.', 0
; Must be shorter than SaveAndExitNow / QuitWithoutSaveNow
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_AreYouSure1          db 'Zeker weten?', 0
TXT_SETUP_AreYouSure2          db '(J/N)', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
; [Linux support removed since v1.02]
;TXT_SETUP_EnterLinuxCmdLine    db 'U kan nu Linux opdrachten invoeren of wijzigen:', 0
;TXT_SETUP_NoLinuxInstalled     db 'Linux niet aanwezig op uw systeem!', 0
TXT_SETUP_NoLDLpartition       db 'Deze partitie werd noch FAT16/HPFS/JFS geformatteerd!', 0

; Maximum 34 chars (should not be reached)
;----------------------------------|--------------------------------|-------
TXT_SETUP_HideFeature          db 'Verdwijntrucje', 0
;----------------------------------|---------------------|------------------
TXT_SETUP_HideFeature2         db 'Tonen bij opstart. ', 0

; Drive-Letter Menu Header - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUP_DriveLetter          db 'Partitie letter', 0

; Drive-Letter Keys - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUPHELP_DriveLetter      db 'Kies uit C @ Z', 0

; Colors for special words hard-coded. Keep all 0s.
;TXT_SETUP_LowerMessage:        db 'U mag dit programma ',0,'vrijelijk',0,' gebruiken ten privaten titel.',0
;                               db 'U mag in ',0,'GEEN GEVAL',0,' AiR-BOOT gebruiken/verdelen indien dit op ',0,'-ENIGERLEI-',0,0
;                               db 'manier, gepaard gaat met een geldelijke vergoeding.',0
;                               db 'Wilt u AiR-BOOT gebruiken ',0,'in andere omstandigheden',0,', ',0,'zoals voorge‹nstalleerd',0,' of',0
;                               db 'afzonderlijk verdeeld',0,', vraag het dan via email aan: ',0,'kiewitz@netlabs.org',0,' !',0
