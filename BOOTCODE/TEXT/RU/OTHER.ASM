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
; v001 - English - by Martin Kiewitz
;------------------------------------------------------------------------------

TXT_TranslationBy              db 'Russian by Denis Tazetdinov', 0

; TopInfosX variables are used for Boot-Menu and Partition Setup

; Maximum 2/10/11/6 chars
;----------------------------------||---------------------------------------
TXT_TopInfos_No                db 'No', 0
TXT_TopInfos_Hd                db 'Hd', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_HdSize            db 'Hd/������:', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_Label             db '���:', 0
;----------------------------------|---------|------------------------------
TXT_TopInfos_Type              db '���:', 0
;----------------------------------|----|-----------------------------------
TXT_TopInfos_Flags             db '�����:', 0      ; <-- for Partition Setup

; Will be added together to one line, maximum 76 chars
TXT_TimedBootLine              db '��⮧���㧪� �����. �㤥� ����㦥�� '''
TXT_TimedBootEntryName         db 12 dup (0) ; Space for Default-Entry-Name
TXT_TimedBootLine2             db      ''' �१ ', 0
TXT_TimedBootSeconds           db ' ᥪ㭤. ', 0
TXT_TimedBootSecond            db ' ᥪ㭤�. ', 0 ; if only one is left, ELiTE :]
; Maximum 76 chars
;----------------------------------|--------------------------------------------------------------------------|
TXT_TimedBootDisabled          db '��⮧���㧪� �⪫�祭�, ⠩��� �⪫�祭.', 0
TXT_BootMenuHelpText1          db '������ [Esc] ��� ��४��祭�� ��⮧���㧪�, [Enter] ��� �롮� ࠧ����.', 0
TXT_BootMenuHelpText2          db '�롥�� ࠧ��� ��� ������ [TAB], �⮡� 㢨���� ᮮ�饭�� BIOS POST.', 0
; Maximum 30 chars
;----------------------------------|----------------------------|
TXT_BootMenuEnterSetup         db 'F10 ��� ᬥ�� ����஥�.', 0

; Dynamic Length (till 80 chars)
TXT_BrokenPartitionTable       db 13, 10, ' - �����㦥� ������ ���� �ᯮ�祭�� ࠧ���, ���� ⠡��� ࠧ����� ᮤ�ন�'
                               db 13, 10, '   ᡮ��� �����. ���⥬� ��⠭������.', 0
TXT_TooManyPartitions          db 13, 10, ' - ���誮� ����� ࠧ����� �������. AiR-BOOT �����ন���� �� 45.', 0
TXT_NoBootAble                 db 13, 10, ' - �� ������� ����㦠���� ࠧ�����. ���⥬� ��⠭������.', 0
TXT_BIOSchanged                db 13, 10, ' - BIOS ���������, �஢���� ᢮� ��⥬� �� �।��� ����ᮢ.'
                               db 13, 10, '   ������ ���� ������� ��� �த�������...', 0

TXT_VirusFoundMain             db 13, 10, ' - !��������! -> ������ ����� <- !��������!', 13, 10, 0
TXT_VirusFound1ok              db '    �� �� ���⮦��, �� ��⥬� ����� �� ����㧨���� �ࠢ��쭮. �᫨ ��', 13, 10
                               db '    �� �ந������, �ᯮ���� ��� ��� AiR-BOOT.', 13, 10, 0
TXT_VirusFound1damn            db '    � ᮦ������, �� ��� ����ன�� AiR-BOOT. �� ������ ����㧨����, �ᯮ����', 13, 10
                               db '    ��� ��� AiR-BOOT.', 13, 10, 0
TXT_VirusFound1any             db '    ��� ������᭮��, ��� ᫥��� �஢���� ��� ���⪨� ��᪨ �� ������.', 13, 10, 0
TXT_VirusFound2                db '    ����� ��室���� � MBR ࠧ����, ����� �� ��� ����㧨��.', 13, 10
                               db '    �ᯮ���� �ணࠬ�� ���᪠ ����ᮢ. ����� �� ����� ���� �訡���', 13, 10
                               db '    �।�०������. ��᫥ 㤠����� �����, �� ������ ��१����� ��६����', 13, 10
                               db '    ���᪠ ����ᮢ � ''��������� ��������'' � ��४����� ���� MBR-����ᮢ ���.', 13, 10
                               db '    ࠧ� (�몫/���). �᫨ �� �뫮 �訡�筮� �।�०�����', 13, 10
                               db '    ��⠢�� ��� � "�몫".', 13, 10, 0
TXT_VirusFoundEnd              db '    ���⥬� ��⠭������. ��������, ������ RESET.', 0
TXT_HowEnterSetup              db 13, 10, ' - ������ � ��ন� Ctrl ��� Alt ��� �室� � ����ன�� AiR-BOOT.', 0

TXT_BootingNow1                db '����㧪� ��⥬�, �ᯮ���� ', 0
; DO NOT MODIFY HERE
TXT_BootingNow2                db '''', 0
TXT_BootingNowPartName         db 12 dup (0) ; Space for BootThisPart-Name
; DO NOT MODIFY TILL HERE
TXT_BootingNowPartition        db ' ࠧ���', 0
TXT_BootingNowKernel           db ' ��', 0
TXT_BootingHide                db '; ᮪��⨥ ��⨢��', 0
TXT_BootingWait                db '; ��������, ��������...', 13, 10, 13, 10, 0

; FIXED LENGTH - 11 chars each string
;----------------------------------|---------|------------------------------
TXT_Floppy_NoName              db '��� �����  '
TXT_Floppy_Drive               db '��᪮���   '
TXT_Floppy_NoDisc              db '��� ��᪠  '

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_PleaseEnterPassword        db ' ��������, ������ ��஫�:', 0
; the following 3 strings have to equal or *longer* than PleaseEnterPassword
TXT_ProtectedSystem            db '**  ������� �������� �������  **', 0
TXT_ProtectedSetup             db '** ��������� �������� ������� **', 0
TXT_ProtectedBootUp            db '** �������� �������� �������! **', 0

; will get completed using TXT_ERROR_CheckFailed from MBR.asm
TXT_ERROR_CheckConfig          db 13, 10, ' - ���䨣����', 0

;----------------------------------|----------------------------------------------------------|
TXT_TooManyTries               db '���誮� ����� ����⮪, ��⥬� ��⠭������', 0
