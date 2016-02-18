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
TXT_SETUP_AdvOptions           db 'OPTIONS AVANC�ES', 0
TXT_SETUP_ExtOptions           db 'OPTIONS �TENDUES D''AMOR�AGE', 0
TXT_SETUP_DefMasterPwd         db 'D�FINIR MOT DE PASSE MA�TRE', 0
TXT_SETUP_DefBootPwd           db 'D�FINIR MOT DE PASSE D�MARRAGE', 0
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
TXT_SETUP_DefaultSelection     db 'S�lection Par D�faut', 0
TXT_SETUP_TimedBoot            db 'Amor�age Temporis�', 0
TXT_SETUP_TimedBootDelay       db 'D�lai d''amor�age (sec)', 0
TXT_SETUP_TimedKeyHandling     db 'Gestion Touche Tempo.', 0
TXT_SETUP_BootLastIfTimed      db 'Amorce Dern. si Tempo.', 0
TXT_SETUP_RememberLastBoot     db 'M�moriser Dern. Amorce', 0
TXT_SETUP_RememberTimedBoot    db 'M�moriser Amorce Tempo.', 0
TXT_SETUP_IncludeFloppy        db 'Incl. Lecteur Disquette', 0
TXT_SETUP_ShowLVMDriveLetters  db 'Show LVM Drive Letters',0
TXT_SETUP_MbrProtection        db 'Protection MBR', 0
TXT_SETUP_IgnoreMbrWrites      db '-> Ignorer �criture MBR', 0
TXT_SETUP_MakeSounds           db 'Activer Sons', 0
TXT_SETUP_CooperBars           db 'Barres Cooper', 0

; Advanced Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_BootMenu             db 'Menu d''Amor�age', 0
TXT_SETUP_PartAutoDetect       db 'D�tect. Auto Partitions', 0
TXT_SETUP_SecurityOptions      db '-> Options S�curit� <-', 0
TXT_SETUP_PasswordedSetup      db 'Param�trage S�curis�', 0
TXT_SETUP_PasswordedSystem     db 'Syst�me S�curis�', 0
TXT_SETUP_PasswordedChangeBoot db 'Chg. Amor�age S�curis�', 0
TXT_SETUP_GetFloppyName        db 'Nom disquette', 0
TXT_SETUP_GetFloppyName2Sec    db '-> Lire au 2 Secondes', 0
TXT_SETUP_VirusDetect          db 'D�tection Virus', 0
TXT_SETUP_StealthDetect        db 'D�tection Furtif', 0
TXT_SETUP_VIBRdetect           db 'D�tection VIBR', 0
TXT_SETUP_ContinueBIOSboot     db 'Cont. S�q Amorce BIOS', 0

; Extended Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
; [Linux support removed since v1.02]
;TXT_SETUP_LinuxKernelPart      db 'Partition Noyau Linux', 0
;TXT_SETUP_LinuxDefaultKernel   db 'Noyau Linux par D�faut', 0
;TXT_SETUP_LinuxRootPart        db 'Partition Racine Linux', 0
; This here may be larger than 23 chars...
;TXT_SETUP_DefLinuxCmd          db 'D�FINIR LIGNE DE COMMANDE LINUX', 0
TXT_SETUP_IgnoreLVM            db 'Ignorer Information LVM', 0
;~ TXT_SETUP_ForceLBAUsage        db 'Force usage du BIOS-LBA', 0
TXT_SETUP_ExtPartMShack        db '�t-Part MS Workaround', 0

; DYNAMIC LENGTH, maximum 11 chars excluding ending zero
;----------------------------------|---------|------------------------------
TXT_SETUP_MAGIC_Enabled        db 'Activ�', 0
TXT_SETUP_MAGIC_Disabled       db 'D�sactiv�', 0
TXT_SETUP_MAGIC_Detailed       db 'D�taill�', 0
TXT_SETUP_MAGIC_NoBootable     db 'Pas Amorce', 0
; [Linux support removed since v1.02]
;TXT_SETUP_MAGIC_NoLinux        db 'Pas Linux', 0
TXT_SETUP_MAGIC_DoNothing      db 'Rien faire', 0
TXT_SETUP_MAGIC_ResetTime      db 'R�Z Temps', 0
TXT_SETUP_MAGIC_StopTime       db 'Temps Arr�t', 0
TXT_SETUP_MAGIC_CDROM          db 'CD-ROM', 0
TXT_SETUP_MAGIC_Network        db 'R�seau', 0
TXT_SETUP_MAGIC_ZIPLS          db 'ZIP/LS120', 0
; Max Length: 10 (used in Hide-Configuration as well)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Hidden         db 'Cach�e', 0
TXT_SETUP_MAGIC_Unhidden       db 'Visible', 0
; Max Length: 10 ("C:" will be appended afterwards)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Set            db 'choisir ', 0

; Setup Control Help - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUPHELP_Main             db 24,32,25,32,26,32,27,' : Choisir Action', 0
                               db 'Enter   : S�lectionner Action', 0
                               db 'F10 : Sauver & Sortir', 0
                               db 'Esc : Quitter', 0

TXT_SETUPHELP_SubMenu          db 24,32,25,32,26,32,27,' : Choisir Item', 0
                               db 'PgUp/Dn : Changer Item', 0
                               db 'F1  : Afficher Aide', 0
                               db 'Esc : Retour au menu principal', 0

TXT_SETUPHELP_PartSetup        db 24,32,25,32,26,32,27,' : Choisir partition', 0
                               db 'Enter   : Editer �tiquette', 0
                               db 'F1  : Drapeaux (lettre=bascule)', 0
                               db 'Esc : Retour au menu principal', 0

; HELP FOR EVERY MENU-ITEM, Maximum Length = 22 chars PER line. Maximum 5 lines

                                  ;1234567890123456789012
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_PartitionSetup   db 'Mettre vos partitions', 0
                               db 'amor�ables, changer', 0
                               db 'les noms, d�finir', 0
                               db 'cach� et plus encore.', 0
                               db 0
TXT_SETUPHELP_BasicOptions     db 'Ces options sont pour', 0
                               db 'les usagers d�butants.', 0
                               db 0
TXT_SETUPHELP_AdvOptions       db 'Pour usagers avanc�s.', 0
                               db 'Si vous ignorez leurs', 0
                               db 'fonctions, ne les', 0
                               db 'modifiez pas.', 0
                               db 0
TXT_SETUPHELP_ExtOptions       db 'Options �tendues pour', 0
                               db 'S.E. sp�cifiques.', 0
                               db 0
TXT_SETUPHELP_DefMasterPwd     db 'D�finir mot de passe', 0
                               db 'pour acc�s au', 0
                               db 'param�trage et au', 0
                               db 'syst�me.', 0
                               db 0
TXT_SETUPHELP_DefBootPwd       db 'D�finir mot de passe', 0
                               db 'pour acc�s au syst�me.', 0
                               db 0
TXT_SETUPHELP_SaveAndExit      db 'Continuera amor�age-', 0
                               db 'traite et sauve les', 0
                               db 'options courantes.', 0
                               db 0
TXT_SETUPHELP_JustExit         db 'Continuera, mais', 0
                               db 'annulera tout', 0
                               db 'changement aux', 0
                               db 'options.', 0
                               db 0

TXT_SETUPHELP_InPartitionSetup db 'A - Amor�able', 0
                               db 'V - D�tection VIBR', 0
                               db 'C - Support Cach�', 0
                               db 'L - Lettre Partition', 0
                               db 'P - �t-Part MS invent.', 0
                               db 0

TXT_SETUPHELP_HideSetup        db 'Choisir l''�tat des', 0
                               db 'partitions lorsque', 0
                               db 'la partition pr�sen-', 0
                               db 'tement s�lectionn�e', 0
                               db 'sera amor��e.', 0
                               db 0

; Basic Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_DefaultSelection db 'Modifier votre', 0
                               db 's�lection par d�faut.', 0
                               db 0
TXT_SETUPHELP_TimedBoot        db 'AiR-BOOT proc�dera', 0
                               db 'automatiquement apr�s', 0
                               db 'un d�lai sp�cifi�.', 0
                               db 0
TXT_SETUPHELP_TimedBootDelay   db 'D�lai sp�cifi� pour', 0
                               db 'Amor�age Temporis�.', 0
                               db 0
TXT_SETUPHELP_TimedKeyHandling db 'Que fait AiR-BOOT si', 0
                               db 'vous appuyez sur une', 0
                               db 'touche dans le menu', 0
                               db 'd''amor�age en mode', 0
                               db 'amor�age temporis�?', 0
                               db 0
TXT_SETUPHELP_BootLastIfTimed  db 'AiR-BOOT utilisera la', 0
                               db 'derni�re partition', 0
                               db 'd�marr�e en amor�age', 0
                               db 'temporis�. Sinon, ce', 0
                               db 'sera celle par d�faut.', 0
                               db 0
TXT_SETUPHELP_RememberLastBoot db 'Au lancement, AiR-BOOT', 0
                               db 'placera la barre de', 0
                               db 'menu sur la derni�re', 0
                               db 'partition amorc�e.', 0
                               db 0
TXT_SETUPHELP_RememberTimeBoot db 'Tout comme la derni�re', 0
                               db 'option, AiR-BOOT', 0
                               db 'conservera aussi la', 0
                               db 'barre sur les', 0
                               db 'amor�ages temporis�s.', 0
                               db 0
TXT_SETUPHELP_IncludeFloppy    db 'AiR-BOOT permettra un', 0
                               db 'amor�age de A: par', 0
                               db 'menu.', 0
                               db 0
TXT_SETUPHELP_ShowLVMDriveLetters   db 'AiR-BOOT will show', 0
                                    db 'LVM Drive Letters', 0
                                    db 'in the menu.', 0
                                    db 0
TXT_SETUPHELP_MbrProtection    db 'Prot�ge MBR par code', 0
                               db 'r�sidant. N�cessite', 0
                               db '1 Ko de m�moire.', 0
                               db 'Peut �tre incompatible', 0
                               db 'avec certains OS.', 0
                               db 0
TXT_SETUPHELP_IgnoreMbrWrites  db 'Si activ�e, toute', 0
                               db '�criture sera ignor�e.', 0
                               db 'Si d�sactiv�e, le', 0
                               db 'syst�me sera arr�t�.', 0
                               db 0
TXT_SETUPHELP_MakeSounds       db 'AiR-BOOT peut produire', 0
                               db 'des sons en utilisant', 0
                               db 'votre haut-parleur', 0
                               db 'interne.', 0
                               db 0
TXT_SETUPHELP_CooperBars       db 'Produira des effets', 0
                               db 'sp�ciaux � l''amor�age.', 0
                               db 0

; Advanced Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_BootMenu         db 'Sans ceci, AiR-BOOT', 0
                               db 'amor�era la partition', 0
                               db 'par d�faut sans menu.', 0
                               db 'D�taill� affichera un', 0
                               db 'surplus d''information', 0
                               db 0
TXT_SETUPHELP_PartAutoDetect   db 'Si AiR-BOOT trouve de', 0
                               db 'nouvelles partitions,', 0
                               db 'les rendre amor�ables.', 0
                               db 0
TXT_SETUPHELP_PasswordedSetup  db 'Un mot de passe vous', 0
                               db 'sera demand� en', 0
                               db 'acc�dant � ce menu.', 0
                               db 0
TXT_SETUPHELP_PasswordedSystem db 'En d�marrant votre', 0
                               db 'ordinateur, il vous', 0
                               db 'sera demand�.', 0
                               db 0
TXT_SETUPHELP_PasswordedBoot   db 'Si vous n''�tes pas en', 0
                               db 'Amor�age Temporis�,', 0
                               db 'il vous sera demand�.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName    db 'Si le lecteur de', 0
                               db 'disquette est affich�', 0
                               db 'dans le menu amor�age,', 0
                               db 'AiR-BOOT lira son nom.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName2Sec db 'De plus, actualisera', 0
                               db 'le nom de disquette', 0
                               db 'au 2 secondes.', 0
                               db 0
TXT_SETUPHELP_VirusDetect      db 'D�tectera un virus', 0
                               db 'normal.', 0
                               db 0
TXT_SETUPHELP_StealthDetect    db 'D�tectera un virus', 0
                               db 'furtif.', 0
                               db 0
TXT_SETUPHELP_VIBRdetect       db 'D�tectera VIBR.', 0
                               db 'VIBR est acronyme de', 0
                               db 'Virus-In-Boot-Record.', 0
                               db 0
TXT_SETUPHELP_ContinueBIOSboot db 'Si activ�e, cette', 0
                               db 'option retournera', 0
                               db 'le contr�le au BIOS', 0
                               db 'pour le p�riph�rique', 0
                               db 'sp�cifi�.', 0
                               db 0

; Extended Options - Help
;----------------------------------|--------------------|-------------------
; [Linux support removed since v1.02]
;TXT_SETUPHELP_LinuxKernelPart  db 'D�finir la partition', 0
;                               db 'FAT-16 contenant vos', 0
;                               db 'noyaux Linux.', 0
;                               db 0
;TXT_SETUPHELP_LinuxDefaultKrnl db 'D�finir le nom du', 0
;                               db 'noyau par d�faut.', 0
;                               db 0
;TXT_SETUPHELP_LinuxRootPart    db 'Modifier votre', 0
;                               db 'partition racine', 0
;                               db 'Linux.', 0
;                               db 0
;TXT_SETUPHELP_DefLinuxCmd:     db 'D�finir la ligne de', 0
;                               db 'commande pour Linux,', 0
;                               db 'si disponible.', 0
;                               db 0
TXT_SETUPHELP_IgnoreLVM        db 'Si activ�, AiR-BOOT', 0
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
                               db 'partition �tendue.', 0
                               db '(d�fini par drapeau P)', 0
                               db 0

; Maximum 26 chars (should not be reached)
;----------------------------------|------------------------|---------------
TXT_SETUPHELP_Base             db ' AIDE ', 0
TXT_SETUPHELP_Enter            db '<ENTER>', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_PasswordOld          db 'Ancien Mot de Passe:', 0
TXT_SETUP_PasswordDefine       db 'D�finir Mot de Passe:', 0
TXT_SETUP_PasswordVerify       db 'V�rifier Mot de Passe:', 0
TXT_SETUP_PasswordIncorrect    db 'Ancien Mot de Passe Incorrect, D�sol�', 0
TXT_SETUP_PasswordMismatch     db 'Diff�rents!!! Ancient Mot de passe Conserv�', 0
TXT_SETUP_PasswordDisabled     db 'Pas de Mot de Passe -> Protection D�sactiv�', 0
TXT_SETUP_PasswordMatched      db '** Identiques, Nouveau Mot de Passe Activ� **', 0

; Maximum 60 chars (should not be reached anyway)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_SaveAndExitNow       db 'SAUVER & QUITTER MAINTENANT', 0
TXT_SETUP_QuitWithoutSaveNow   db 'QUITTER SANS SAUVER', 0
; Must be shorter than SaveAndExitNow / QuitWithoutSaveNow
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_AreYouSure1          db '�TES-VOUS CERTAIN?', 0
TXT_SETUP_AreYouSure2          db '(O/N)', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
; [Linux support removed since v1.02]
;TXT_SETUP_EnterLinuxCmdLine    db 'Veuillez entrer/modifier votre ligne de commande Linux:', 0
;TXT_SETUP_NoLinuxInstalled     db 'Linux non install�', 0
TXT_SETUP_NoLDLpartition       db 'La partition s�lectionn�e n''est pas du type HPFS/FAT16/JFS', 0

; Maximum 34 chars (should not be reached)
;----------------------------------|--------------------------------|-------
TXT_SETUP_HideFeature          db 'Cacher Fonction', 0
;----------------------------------|---------------------|------------------
TXT_SETUP_HideFeature2         db '�tat � l''amor�age de ', 0

; Drive-Letter Menu Header - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUP_DriveLetter          db 'Lettre Partition', 0

; Drive-Letter Keys - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUPHELP_DriveLetter      db 'Appuyez C-Z', 0

; Colors for special words hard-coded. Keep all 0s.
;TXT_SETUP_LowerMessage         db 'Ce programme est ',0,'gratuit',0,' pour une utilisation priv�e non-commerciale.',0
;                               db 'Vous ne devez ',0,'PAS',0,' distribuer/utiliser AiR-BOOT sous ',0,'-TOUTE-',0,' forme,',0
;                               db 'si vous �tes pay� pour la distribution du produit ou du service.',0
;                               db 'Pour utiliser AiR-BOOT dans des ',0,'conditions diff�rentes',0,', ',0,'pr�-installer',0,' ou',0
;                               db 'le distribuer',0,', svp veuillez me contacter par courriel: ',0,'kiewitz@netlabs.org',0,' !',0
