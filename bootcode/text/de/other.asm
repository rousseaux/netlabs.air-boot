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
; v001 - German - by Martin Kiewitz
;------------------------------------------------------------------------------

TXT_TranslationBy              db 'German by Martin Kiewitz', 0

; TopInfosX variables are used for Boot-Menu and Partition Setup

; Maximum 2/10/11/6 chars
;----------------------------------||---------------------------------------
TXT_TopInfos_No                db 'Nr', 0
TXT_TopInfos_Hd                db 'Hd', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_HdSize            db 'Hd/Gr”áe:', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_Label             db 'Name:', 0
;----------------------------------|---------|------------------------------
TXT_TopInfos_Type              db 'Typ:', 0
;----------------------------------|----|-----------------------------------
TXT_TopInfos_Flags             db 'Flags:', 0      ; <-- for Partition Setup

; Will be added together to one line, maximum 76 chars
TXT_TimedBootLine              db 'Zeitgesteuerter Boot aktiviert. System l„dt '''
TXT_TimedBootEntryName         db 12 dup (0) ; Space for Default-Entry-Name
TXT_TimedBootLine2             db      ''' in ', 0
TXT_TimedBootSeconds           db ' Sekunden. ', 0
TXT_TimedBootSecond            db ' Sekunde. ', 0 ; if only one is left, ELiTE :]
; Maximum 76 chars
;----------------------------------|--------------------------------------------------------------------------|
TXT_TimedBootDisabled          db 'Zeitgesteuerter Boot deaktiviert.', 0
TXT_BootMenuHelpText1          db '[Esc] um Automatischen Boot an/auszuschalten, [Enter] um Auswahl zu booten', 0
TXT_BootMenuHelpText2          db 'Mit den Pfeiltasten ausw„hlen oder [TAB] fr den BIOS POST Bildschirm.', 0
; Maximum 30 chars
;----------------------------------|----------------------------|
TXT_BootMenuEnterSetup         db 'F10 um ins Setup zu gelangen', 0

; Dynamic Length (till 80 chars)
TXT_BrokenPartitionTable       db 13, 10, ' - Mindestens einer Ihrer Partitionseintr„ge ist ungltig oder Ihre Festplatte'
                               db 13, 10, '   beinhaltet defekte Sektoren. System angehalten.', 0
TXT_TooManyPartitions          db 13, 10, ' - Zuviele Partitionen gefunden. AiR-BOOT untersttzt maximal 45.', 0
TXT_NoBootAble                 db 13, 10, ' - Keine bootbare Partition definiert. System angehalten.', 0
TXT_BIOSchanged                db 13, 10, ' - BIOS HAT SICH VERŽNDERT. šberprfen Sie ihr System auf Viren.'
                               db 13, 10, '   Drcken Sie eine Taste um fortzufahren...', 0

TXT_VirusFoundMain             db 13, 10, ' - !ACHTUNG! -> EIN VIRUS WURDE GEFUNDEN <- !ACHTUNG!', 13, 10, 0
TXT_VirusFound1ok              db '    Er wurde zerst”rt, es kann allerdings sein, daá Ihr System nicht mehr', 13, 10
                               db '    hochf„hrt. In diesem Fall booten Sie bitte von der AiR-BOOT Install-Disk.', 13, 10, 0
TXT_VirusFound1damn            db '    Leider hat er das BackUp von AiR-BOOT zerst”rt. Sie mssen mit der AiR-BOOT', 13, 10
                               db '    Install-Diskette booten.', 13, 10, 0
TXT_VirusFound1any             db '    Sicherheitshalber sollten Sie Ihre Festplatte auf Viren untersuchen.', 13, 10, 0
TXT_VirusFound2                db '    Er ist im Boot-Record der Partition, die Sie gerade booten wollten.', 13, 10
                               db '    Bentzen Sie einen Viren-Scanner. Es k”nnte sich auch um einen falschen', 13, 10
                               db '    Alarm handeln. Sie k”nnen diese Fehlermeldung unterbinden, indem Sie ins', 13, 10
                               db '    ''PARTITIONS SETUP'' gehen und VIBR-Erkennung aus und wieder anschalten.', 13, 10
                               db '    Falls diese Meldung dann wieder erscheint, sollten Sie VIBR fr diese', 13, 10
                               db '    Partition ausschaltet lassen.', 13, 10, 0
TXT_VirusFoundEnd              db '    System angehalten. Bitte drcken Sie RESET.', 0
TXT_HowEnterSetup              db 13, 10, ' - Drcken und halten Sie Strg/Ctrl oder Alt um ins AiR-BOOT SETUP zu gelangen.', 0

TXT_BootingNow1                db 'Booten des Systems durch ', 0
; DO NOT MODIFY HERE
TXT_BootingNow2                db '''', 0
TXT_BootingNowPartName         db 12 dup (0) ; Space for BootThisPart-Name
; DO NOT MODIFY TILL HERE
TXT_BootingNowPartition        db ' Partition', 0
TXT_BootingNowKernel           db ' Kernel', 0
TXT_BootingNow3                db '''', 0
TXT_BootingHide                db '; Hide aktiv', 0
TXT_BootingWait                db '; Bitte warten...', 13, 10, 13, 10, 0

; FIXED LENGTH - 11 chars each string
;----------------------------------|---------|------------------------------
TXT_Floppy_NoName              db 'kein Name  '
TXT_Floppy_Drive               db 'Floppy-Disk'
TXT_Floppy_NoDisc              db 'Keine Disk '

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_PleaseEnterPassword        db 'Bitte geben Sie Passwort ein:', 0
; the following 3 strings have to equal or *longer* than PleaseEnterPassword
TXT_ProtectedSystem            db '** PASSWORT GESCHšTZTES SYSTEM **', 0
TXT_ProtectedSetup             db '** PASSWORT GESCHšTZTES SETUP **', 0
TXT_ProtectedBootUp            db '** PASSWORT GESCHšTZTER BOOT-UP **', 0

; will get completed using TXT_ERROR_CheckFailed from MBR.asm
TXT_ERROR_CheckConfig          db 13, 10, ' - Die Konfiguration', 0

;----------------------------------|----------------------------------------------------------|
TXT_TooManyTries               db 'Zuviele Versuche, System Angehalten', 0
