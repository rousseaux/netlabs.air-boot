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
;------------------------------------------------------------------------------
;                                                        AiR-BOOT / OTHER TEXT
; v001 - French - by Michel Goyette
;------------------------------------------------------------------------------

TXT_TranslationBy              db 'French by Michel Goyette & Aymeric Peyret', 0

; TopInfosX variables are used for Boot-Menu and Partition Setup

; Maximum 2/10/11/6 chars
;----------------------------------||---------------------------------------
TXT_TopInfos_No                db 'No', 0
TXT_TopInfos_Hd                db 'Dd', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_HdSize            db 'Dd/Cap.:', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_Label             db '�tiq.:', 0
;----------------------------------|---------|------------------------------
TXT_TopInfos_Type              db 'Type:', 0
;----------------------------------|----|-----------------------------------
TXT_TopInfos_Flags             db 'Drap.:', 0      ; <-- for Partition Setup

; Will be added together to one line, maximum 76 chars
TXT_TimedBootLine              db 'Amor�age temporis� actif. D�marrage de '''
TXT_TimedBootEntryName         db 12 dup (0) ; Space for Default-Entry-Name
TXT_TimedBootLine2             db      ''' dans ', 0
TXT_TimedBootSeconds           db ' secondes. ', 0
TXT_TimedBootSecond            db ' seconde. ', 0 ; if only one is left, ELiTE :]
; Maximum 76 chars
;----------------------------------|--------------------------------------------------------------------------|
TXT_TimedBootDisabled          db 'Amor�age temporis� d�sactiv�; aucune temporisation n''arrivera.', 0
TXT_BootMenuHelpText1          db '[Esc] bascule l''amor�age temporis�, [Enter] accepte la s�lection courante.', 0
TXT_BootMenuHelpText2          db 'Fl�ches pour choisir une autre, ou [TAB] pour voir les messages POST BIOS.', 0
; Maximum 30 chars
;----------------------------------|----------------------------|
TXT_BootMenuEnterSetup         db 'F10 pour Configurer', 0

; Dynamic Length (till 80 chars)
TXT_BrokenPartitionTable       db 13, 10, ' - Votre syst�me a au moins d''une entr�e mauvaise de table de partition, ou'
                               db 13, 10, '   la disque d�r a des cass�e secteurs. Syst�me arr�t�.', 0
TXT_TooManyPartitions          db 13, 10, ' - Trop de partitions trouv�es. AiR-BOOT supporte un maximum de 45.', 0
TXT_NoBootAble                 db 13, 10, ' - Aucune partition amor�able d�finie. Syst�me arr�t�.', 0
TXT_BIOSchanged                db 13, 10, ' - BIOS CHANG�! Veuillez v�rifier votre syst�me contre un virus.'
                               db 13, 10, '   Appuyez sur une touche pour continuer...', 0

TXT_VirusFoundMain             db 13, 10, ' - !ATTENTION! -> UN VIRUS A �T� TROUV� <- !ATTENTION!', 13, 10, 0
TXT_VirusFound1ok              db '    Il est �radiqu�, mais le syst�me peut ne pas red�marrer correctement.', 13, 10
                               db '    Si c''est le cas, utiliser votre disquette syst�me AiR-BOOT.', 13, 10, 0
TXT_VirusFound1damn            db '    Malheureusement, il a d�truit la copie de sauvgarde de AiR-BOOT. Vous', 13, 10
                               db '    devez red�marrer en utilisant votre disquette syst�me AiR-BOOT.', 13, 10, 0
TXT_VirusFound1any             db '    Pour plus de s�ret�, v�rifiez votre disque contre des r�sidus du virus.', 13, 10, 0
TXT_VirusFound2                db '    Il est localis� dans le secteur d amor�age de la partition d�sir�e.', 13, 10
                               db '    Utilisez un logiciel antivirus. Ce peut �tre aussi une fausse alerte.', 13, 10
                               db '    Apr�s �radiquation, r�initialiser les variables de d�tection. Allez dans', 13, 10
                               db '    ''PARAM�TRAGE PARTITION'' et basculez D�tection-VIBR deux fois (off/on).', 13, 10
                               db '    Si c''�tait une fausse alerte, laissez-le d�sactiv�.', 13, 10, 0
TXT_VirusFoundEnd              db '    Syst�me arr�t�. Veuillez appuyez sur RESET.', 0
TXT_HowEnterSetup              db 13, 10, ' - Appuyez et tenez Strg/Ctrl ou Alt pour configurer AiR-BOOT.', 0

TXT_BootingNow1                db 'Amor�age du syst�me avec ', 0
; DO NOT MODIFY HERE
TXT_BootingNow2                db '''', 0
TXT_BootingNowPartName         db 12 dup (0) ; Space for BootThisPart-Name
; DO NOT MODIFY TILL HERE
TXT_BootingNowPartition        db '''', 0
TXT_BootingNowKernel           db '''', 0
TXT_BootingHide                db '; cach� actif', 0
TXT_BootingWait                db '; veuillez patienter...', 13, 10, 13, 10, 0

; FIXED LENGTH - 11 chars each string
;----------------------------------|---------|------------------------------
TXT_Floppy_NoName              db 'Sans nom   '
TXT_Floppy_Drive               db 'Disquette  '
TXT_Floppy_NoDisc              db 'Sans Disq. '

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_PleaseEnterPassword        db ' Veuillez entrez le mot de passe:', 0
; the following 3 strings have to equal or *longer* than PleaseEnterPassword
TXT_ProtectedSystem            db '** SYST�ME S�CURIS� PAR MOT DE PASSE **', 0
TXT_ProtectedSetup             db '** PARAM�TRAGE S�CURIS� PAR MOT DE PASSE! **', 0
TXT_ProtectedBootUp            db '** AMOR�AGE S�CURIS� PAR MOT DE PASSE **', 0

; will get completed using TXT_ERROR_CheckFailed from MBR.asm
TXT_ERROR_CheckConfig          db 13, 10, ' - La configuration', 0

;----------------------------------|----------------------------------------------------------|
TXT_TooManyTries               db 'Trop de Tentatives, Syst�me Arr�t�', 0
