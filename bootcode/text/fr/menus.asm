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
; v001 - French - by Michel Goyette
;---------------------------------------------------------------------------

; Main Setup - Items - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUP_PartitionSetup       db 'CONFIGURER LES PARTITION(S)', 0
TXT_SETUP_BasicOptions         db 'OPTIONS DE BASE', 0
TXT_SETUP_AdvOptions           db 'OPTIONS AVANCêES', 0
TXT_SETUP_ExtOptions           db 'OPTIONS êTENDUES D''AMORáAGE', 0
TXT_SETUP_DefMasterPwd         db 'DêFINIR MOT DE PASSE MAåTRE', 0
TXT_SETUP_DefBootPwd           db 'DêFINIR MOT DE PASSE DêMARRAGE', 0
TXT_SETUP_SaveAndExit          db 'SAUVER & SORTIR', 0
TXT_SETUP_JustExit             db 'SORTIR SANS SAUVER', 0

; The Letters for all flags in Partition Setup
TXT_SETUP_FlagLetterBootable   equ 'A'
TXT_SETUP_FlagLetterVIBR       equ 'V'
TXT_SETUP_FlagLetterHide       equ 'C'
TXT_SETUP_FlagLetterDrvLetter  equ 'L'
TXT_SETUP_FlagLetterExtMShack  equ 'P'

TXT_SETUP_LetterYes            equ 'O'
TXT_SETUP_LetterYes2           equ 'O'
TXT_SETUP_LetterNo             equ 'N'

; Basic Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_DefaultSelection     db 'SÇlection Par DÇfaut', 0
TXT_SETUP_TimedBoot            db 'Amoráage TemporisÇ', 0
TXT_SETUP_TimedBootDelay       db 'DÇlai d''amoráage (sec)', 0
TXT_SETUP_TimedKeyHandling     db 'Gestion Touche Tempo.', 0
TXT_SETUP_BootLastIfTimed      db 'Amorce Dern. si Tempo.', 0
TXT_SETUP_RememberLastBoot     db 'MÇmoriser Dern. Amorce', 0
TXT_SETUP_RememberTimedBoot    db 'MÇmoriser Amorce Tempo.', 0
TXT_SETUP_IncludeFloppy        db 'Incl. Lecteur Disquette', 0
TXT_SETUP_ShowLVMDriveLetters  db 'Show LVM Drive Letters',0
TXT_SETUP_MbrProtection        db 'Protection MBR', 0
TXT_SETUP_IgnoreMbrWrites      db '-> Ignorer êcriture MBR', 0
TXT_SETUP_MakeSounds           db 'Activer Sons', 0
TXT_SETUP_CooperBars           db 'Barres Cooper', 0

; Advanced Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_BootMenu             db 'Menu d''Amoráage', 0
TXT_SETUP_PartAutoDetect       db 'DÇtect. Auto Partitions', 0
TXT_SETUP_SecurityOptions      db '-> Options SÇcuritÇ <-', 0
TXT_SETUP_PasswordedSetup      db 'ParamÇtrage SÇcurisÇ', 0
TXT_SETUP_PasswordedSystem     db 'Systäme SÇcurisÇ', 0
TXT_SETUP_PasswordedChangeBoot db 'Chg. Amoráage SÇcurisÇ', 0
TXT_SETUP_GetFloppyName        db 'Nom disquette', 0
TXT_SETUP_GetFloppyName2Sec    db '-> Lire au 2 Secondes', 0
TXT_SETUP_VirusDetect          db 'DÇtection Virus', 0
TXT_SETUP_StealthDetect        db 'DÇtection Furtif', 0
TXT_SETUP_VIBRdetect           db 'DÇtection VIBR', 0
TXT_SETUP_ContinueBIOSboot     db 'Cont. SÇq Amorce BIOS', 0

; Extended Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
; [Linux support removed since v1.02]
;TXT_SETUP_LinuxKernelPart      db 'Partition Noyau Linux', 0
;TXT_SETUP_LinuxDefaultKernel   db 'Noyau Linux par DÇfaut', 0
;TXT_SETUP_LinuxRootPart        db 'Partition Racine Linux', 0
; This here may be larger than 23 chars...
;TXT_SETUP_DefLinuxCmd          db 'DêFINIR LIGNE DE COMMANDE LINUX', 0
TXT_SETUP_IgnoreLVM            db 'Ignorer Information LVM', 0
;~ TXT_SETUP_ForceLBAUsage        db 'Force usage du BIOS-LBA', 0
TXT_SETUP_ExtPartMShack        db 'êt-Part MS Workaround', 0

; DYNAMIC LENGTH, maximum 11 chars excluding ending zero
;----------------------------------|---------|------------------------------
TXT_SETUP_MAGIC_Enabled        db 'ActivÇ', 0
TXT_SETUP_MAGIC_Disabled       db 'DÇsactivÇ', 0
TXT_SETUP_MAGIC_Detailed       db 'DÇtaillÇ', 0
TXT_SETUP_MAGIC_NoBootable     db 'Pas Amorce', 0
; [Linux support removed since v1.02]
;TXT_SETUP_MAGIC_NoLinux        db 'Pas Linux', 0
TXT_SETUP_MAGIC_DoNothing      db 'Rien faire', 0
TXT_SETUP_MAGIC_ResetTime      db 'RÖZ Temps', 0
TXT_SETUP_MAGIC_StopTime       db 'Temps Arràt', 0
TXT_SETUP_MAGIC_CDROM          db 'CD-ROM', 0
TXT_SETUP_MAGIC_Network        db 'RÇseau', 0
TXT_SETUP_MAGIC_ZIPLS          db 'ZIP/LS120', 0
; Max Length: 10 (used in Hide-Configuration as well)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Hidden         db 'CachÇe', 0
TXT_SETUP_MAGIC_Unhidden       db 'Visible', 0
; Max Length: 10 ("C:" will be appended afterwards)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Set            db 'choisir ', 0

; Setup Control Help - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUPHELP_Main             db 24,32,25,32,26,32,27,' : Choisir Action', 0
                               db 'Enter   : SÇlectionner Action', 0
                               db 'F10 : Sauver & Sortir', 0
                               db 'Esc : Quitter', 0

TXT_SETUPHELP_SubMenu          db 24,32,25,32,26,32,27,' : Choisir Item', 0
                               db 'PgUp/Dn : Changer Item', 0
                               db 'F1  : Afficher Aide', 0
                               db 'Esc : Retour au menu principal', 0

TXT_SETUPHELP_PartSetup        db 24,32,25,32,26,32,27,' : Choisir partition', 0
                               db 'Enter   : Editer Çtiquette', 0
                               db 'F1  : Drapeaux (lettre=bascule)', 0
                               db 'Esc : Retour au menu principal', 0

; HELP FOR EVERY MENU-ITEM, Maximum Length = 22 chars PER line. Maximum 5 lines

                                  ;1234567890123456789012
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_PartitionSetup   db 'Mettre vos partitions', 0
                               db 'amoráables, changer', 0
                               db 'les noms, dÇfinir', 0
                               db 'cachÇ et plus encore.', 0
                               db 0
TXT_SETUPHELP_BasicOptions     db 'Ces options sont pour', 0
                               db 'les usagers dÇbutants.', 0
                               db 0
TXT_SETUPHELP_AdvOptions       db 'Pour usagers avancÇs.', 0
                               db 'Si vous ignorez leurs', 0
                               db 'fonctions, ne les', 0
                               db 'modifiez pas.', 0
                               db 0
TXT_SETUPHELP_ExtOptions       db 'Options Çtendues pour', 0
                               db 'S.E. spÇcifiques.', 0
                               db 0
TXT_SETUPHELP_DefMasterPwd     db 'DÇfinir mot de passe', 0
                               db 'pour accäs au', 0
                               db 'paramÇtrage et au', 0
                               db 'systäme.', 0
                               db 0
TXT_SETUPHELP_DefBootPwd       db 'DÇfinir mot de passe', 0
                               db 'pour accäs au systäme.', 0
                               db 0
TXT_SETUPHELP_SaveAndExit      db 'Continuera amoráage-', 0
                               db 'traite et sauve les', 0
                               db 'options courantes.', 0
                               db 0
TXT_SETUPHELP_JustExit         db 'Continuera, mais', 0
                               db 'annulera tout', 0
                               db 'changement aux', 0
                               db 'options.', 0
                               db 0

TXT_SETUPHELP_InPartitionSetup db 'A - Amoráable', 0
                               db 'V - DÇtection VIBR', 0
                               db 'C - Support CachÇ', 0
                               db 'L - Lettre Partition', 0
                               db 'P - êt-Part MS invent.', 0
                               db 0

TXT_SETUPHELP_HideSetup        db 'Choisir l''Çtat des', 0
                               db 'partitions lorsque', 0
                               db 'la partition prÇsen-', 0
                               db 'tement sÇlectionnÇe', 0
                               db 'sera amoráÇe.', 0
                               db 0

; Basic Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_DefaultSelection db 'Modifier votre', 0
                               db 'sÇlection par dÇfaut.', 0
                               db 0
TXT_SETUPHELP_TimedBoot        db 'AiR-BOOT procÇdera', 0
                               db 'automatiquement apräs', 0
                               db 'un dÇlai spÇcifiÇ.', 0
                               db 0
TXT_SETUPHELP_TimedBootDelay   db 'DÇlai spÇcifiÇ pour', 0
                               db 'Amoráage TemporisÇ.', 0
                               db 0
TXT_SETUPHELP_TimedKeyHandling db 'Que fait AiR-BOOT si', 0
                               db 'vous appuyez sur une', 0
                               db 'touche dans le menu', 0
                               db 'd''amoráage en mode', 0
                               db 'amoráage temporisÇ?', 0
                               db 0
TXT_SETUPHELP_BootLastIfTimed  db 'AiR-BOOT utilisera la', 0
                               db 'derniäre partition', 0
                               db 'dÇmarrÇe en amoráage', 0
                               db 'temporisÇ. Sinon, ce', 0
                               db 'sera celle par dÇfaut.', 0
                               db 0
TXT_SETUPHELP_RememberLastBoot db 'Au lancement, AiR-BOOT', 0
                               db 'placera la barre de', 0
                               db 'menu sur la derniäre', 0
                               db 'partition amorcÇe.', 0
                               db 0
TXT_SETUPHELP_RememberTimeBoot db 'Tout comme la derniäre', 0
                               db 'option, AiR-BOOT', 0
                               db 'conservera aussi la', 0
                               db 'barre sur les', 0
                               db 'amoráages temporisÇs.', 0
                               db 0
TXT_SETUPHELP_IncludeFloppy    db 'AiR-BOOT permettra un', 0
                               db 'amoráage de A: par', 0
                               db 'menu.', 0
                               db 0
TXT_SETUPHELP_ShowLVMDriveLetters   db 'AiR-BOOT will show', 0
                                    db 'LVM Drive Letters', 0
                                    db 'in the menu.', 0
                                    db 0
TXT_SETUPHELP_MbrProtection    db 'Protäge MBR par code', 0
                               db 'rÇsidant. NÇcessite', 0
                               db '1 Ko de mÇmoire.', 0
                               db 'Peut àtre incompatible', 0
                               db 'avec certains OS.', 0
                               db 0
TXT_SETUPHELP_IgnoreMbrWrites  db 'Si activÇe, toute', 0
                               db 'Çcriture sera ignorÇe.', 0
                               db 'Si dÇsactivÇe, le', 0
                               db 'systäme sera arràtÇ.', 0
                               db 0
TXT_SETUPHELP_MakeSounds       db 'AiR-BOOT peut produire', 0
                               db 'des sons en utilisant', 0
                               db 'votre haut-parleur', 0
                               db 'interne.', 0
                               db 0
TXT_SETUPHELP_CooperBars       db 'Produira des effets', 0
                               db 'spÇciaux Ö l''amoráage.', 0
                               db 0

; Advanced Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_BootMenu         db 'Sans ceci, AiR-BOOT', 0
                               db 'amoráera la partition', 0
                               db 'par dÇfaut sans menu.', 0
                               db 'DÇtaillÇ affichera un', 0
                               db 'surplus d''information', 0
                               db 0
TXT_SETUPHELP_PartAutoDetect   db 'Si AiR-BOOT trouve de', 0
                               db 'nouvelles partitions,', 0
                               db 'les rendre amoráables.', 0
                               db 0
TXT_SETUPHELP_PasswordedSetup  db 'Un mot de passe vous', 0
                               db 'sera demandÇ en', 0
                               db 'accÇdant Ö ce menu.', 0
                               db 0
TXT_SETUPHELP_PasswordedSystem db 'En dÇmarrant votre', 0
                               db 'ordinateur, il vous', 0
                               db 'sera demandÇ.', 0
                               db 0
TXT_SETUPHELP_PasswordedBoot   db 'Si vous n''àtes pas en', 0
                               db 'Amoráage TemporisÇ,', 0
                               db 'il vous sera demandÇ.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName    db 'Si le lecteur de', 0
                               db 'disquette est affichÇ', 0
                               db 'dans le menu amoráage,', 0
                               db 'AiR-BOOT lira son nom.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName2Sec db 'De plus, actualisera', 0
                               db 'le nom de disquette', 0
                               db 'au 2 secondes.', 0
                               db 0
TXT_SETUPHELP_VirusDetect      db 'DÇtectera un virus', 0
                               db 'normal.', 0
                               db 0
TXT_SETUPHELP_StealthDetect    db 'DÇtectera un virus', 0
                               db 'furtif.', 0
                               db 0
TXT_SETUPHELP_VIBRdetect       db 'DÇtectera VIBR.', 0
                               db 'VIBR est acronyme de', 0
                               db 'Virus-In-Boot-Record.', 0
                               db 0
TXT_SETUPHELP_ContinueBIOSboot db 'Si activÇe, cette', 0
                               db 'option retournera', 0
                               db 'le contrìle au BIOS', 0
                               db 'pour le pÇriphÇrique', 0
                               db 'spÇcifiÇ.', 0
                               db 0

; Extended Options - Help
;----------------------------------|--------------------|-------------------
; [Linux support removed since v1.02]
;TXT_SETUPHELP_LinuxKernelPart  db 'DÇfinir la partition', 0
;                               db 'FAT-16 contenant vos', 0
;                               db 'noyaux Linux.', 0
;                               db 0
;TXT_SETUPHELP_LinuxDefaultKrnl db 'DÇfinir le nom du', 0
;                               db 'noyau par dÇfaut.', 0
;                               db 0
;TXT_SETUPHELP_LinuxRootPart    db 'Modifier votre', 0
;                               db 'partition racine', 0
;                               db 'Linux.', 0
;                               db 0
;TXT_SETUPHELP_DefLinuxCmd:     db 'DÇfinir la ligne de', 0
;                               db 'commande pour Linux,', 0
;                               db 'si disponible.', 0
;                               db 0
TXT_SETUPHELP_IgnoreLVM        db 'Si activÇ, AiR-BOOT', 0
                               db 'ignorera l''information', 0
                               db 'LVM.', 0
                               db 0
;~ TXT_SETUPHELP_ForceLBAUsage    db 'Forcer l''usage de', 0
                               ;~ db 'l''API BIOS LBA au lieu', 0
                               ;~ db 'd''un amalgame de', 0
                               ;~ db 'CHS et LBA.', 0
                               ;~ db 0
TXT_SETUPHELP_ExtPartMShack    db 'Changement dynamique', 0
                               db 'du type id (standard', 0
                               db 'ou MS-invention) de la', 0
                               db 'partition Çtendue.', 0
                               db '(dÇfini par drapeau P)', 0
                               db 0

; Maximum 26 chars (should not be reached)
;----------------------------------|------------------------|---------------
TXT_SETUPHELP_Base             db ' AIDE ', 0
TXT_SETUPHELP_Enter            db '<ENTER>', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_PasswordOld          db 'Ancien Mot de Passe:', 0
TXT_SETUP_PasswordDefine       db 'DÇfinir Mot de Passe:', 0
TXT_SETUP_PasswordVerify       db 'VÇrifier Mot de Passe:', 0
TXT_SETUP_PasswordIncorrect    db 'Ancien Mot de Passe Incorrect, DÇsolÇ', 0
TXT_SETUP_PasswordMismatch     db 'DiffÇrents!!! Ancient Mot de passe ConservÇ', 0
TXT_SETUP_PasswordDisabled     db 'Pas de Mot de Passe -> Protection DÇsactivÇ', 0
TXT_SETUP_PasswordMatched      db '** Identiques, Nouveau Mot de Passe ActivÇ **', 0

; Maximum 60 chars (should not be reached anyway)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_SaveAndExitNow       db 'SAUVER & QUITTER MAINTENANT', 0
TXT_SETUP_QuitWithoutSaveNow   db 'QUITTER SANS SAUVER', 0
; Must be shorter than SaveAndExitNow / QuitWithoutSaveNow
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_AreYouSure1          db 'àTES-VOUS CERTAIN?', 0
TXT_SETUP_AreYouSure2          db '(O/N)', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
; [Linux support removed since v1.02]
;TXT_SETUP_EnterLinuxCmdLine    db 'Veuillez entrer/modifier votre ligne de commande Linux:', 0
;TXT_SETUP_NoLinuxInstalled     db 'Linux non installÇ', 0
TXT_SETUP_NoLDLpartition       db 'La partition sÇlectionnÇe n''est pas du type HPFS/FAT16/JFS', 0

; Maximum 34 chars (should not be reached)
;----------------------------------|--------------------------------|-------
TXT_SETUP_HideFeature          db 'Cacher Fonction', 0
;----------------------------------|---------------------|------------------
TXT_SETUP_HideFeature2         db 'êtat Ö l''amoráage de ', 0

; Drive-Letter Menu Header - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUP_DriveLetter          db 'Lettre Partition', 0

; Drive-Letter Keys - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUPHELP_DriveLetter      db 'Appuyez C-Z', 0

; Colors for special words hard-coded. Keep all 0s.
;TXT_SETUP_LowerMessage         db 'Ce programme est ',0,'gratuit',0,' pour une utilisation privÇe non-commerciale.',0
;                               db 'Vous ne devez ',0,'PAS',0,' distribuer/utiliser AiR-BOOT sous ',0,'-TOUTE-',0,' forme,',0
;                               db 'si vous àtes payÇ pour la distribution du produit ou du service.',0
;                               db 'Pour utiliser AiR-BOOT dans des ',0,'conditions diffÇrentes',0,', ',0,'prÇ-installer',0,' ou',0
;                               db 'le distribuer',0,', svp veuillez me contacter par courriel: ',0,'kiewitz@netlabs.org',0,' !',0
