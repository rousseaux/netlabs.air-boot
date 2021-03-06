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
; v001 - English - by Martin Kiewitz
;---------------------------------------------------------------------------

; Main Setup - Items - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUP_PartitionSetup       db '��������� ��������', 0
TXT_SETUP_BasicOptions         db '�������� ���������', 0
TXT_SETUP_AdvOptions           db '�������������� ���������', 0
TXT_SETUP_ExtOptions           db '��������� ����������� ��������', 0
TXT_SETUP_DefMasterPwd         db '������ ����� ������', 0
TXT_SETUP_DefBootPwd           db '������ ������ �� ��������', 0
TXT_SETUP_SaveAndExit          db '��������� � �����', 0
TXT_SETUP_JustExit             db '����� ��� ����������', 0

; The Letters for all flags in Partition Setup
TXT_SETUP_FlagLetterBootable   equ 'B'
TXT_SETUP_FlagLetterVIBR       equ 'V'
TXT_SETUP_FlagLetterHide       equ 'H'
TXT_SETUP_FlagLetterDrvLetter  equ 'L'
TXT_SETUP_FlagLetterExtMShack  equ 'P'

TXT_SETUP_LetterYes            equ 'Y'
TXT_SETUP_LetterYes2           equ 'Z'
TXT_SETUP_LetterNo             equ 'N'

; Basic Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_DefaultSelection     db '�롮� ��-㬮�砭��', 0
TXT_SETUP_TimedBoot            db '��⮬���᪠� ����㧪�', 0
TXT_SETUP_TimedBootDelay       db '�६� ��⮧���㧪� (�)', 0
TXT_SETUP_TimedKeyHandling     db '������ � ��⮧���㧪�', 0
TXT_SETUP_BootLastIfTimed      db '��㧨�� ��᫥���� ���.', 0
TXT_SETUP_RememberLastBoot     db '������� ��᫥���� ���.', 0
TXT_SETUP_RememberTimedBoot    db '������� � ��⮧���㧪�', 0
TXT_SETUP_IncludeFloppy        db '�������� ��᪮���', 0
TXT_SETUP_ShowLVMDriveLetters  db 'Show LVM Drive Letters',0
TXT_SETUP_MbrProtection        db '���� MBR', 0
TXT_SETUP_IgnoreMbrWrites      db '-> �� ������ MBR', 0
TXT_SETUP_MakeSounds           db '������� ��㪨', 0
TXT_SETUP_CooperBars           db '��ᨢ�� ����㪠', 0

; Advanced Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_BootMenu             db '���� �� ����㧪�', 0
TXT_SETUP_PartAutoDetect       db '��⮯��� ࠧ�����', 0
TXT_SETUP_SecurityOptions      db '-> ������᭮��� <-', 0
TXT_SETUP_PasswordedSetup      db '����ன�� �� ��஫�', 0
TXT_SETUP_PasswordedSystem     db '���⥬� �� ��஫�', 0
TXT_SETUP_PasswordedChangeBoot db '����� ��⥬� �� ��஫�', 0
TXT_SETUP_GetFloppyName        db '������� ���� ��᪥��', 0
TXT_SETUP_GetFloppyName2Sec    db '-> ����� 2 ᥪ㭤�', 0
TXT_SETUP_VirusDetect          db '���� ����ᮢ', 0
TXT_SETUP_StealthDetect        db '���� �⥫�-����ᮢ', 0
TXT_SETUP_VIBRdetect           db '���� MBR-����ᮢ', 0
TXT_SETUP_ContinueBIOSboot     db '����㧪� �१ BIOS', 0

; Extended Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
; [Linux support removed since v1.02]
;TXT_SETUP_LinuxKernelPart      db '������ �� Linux', 0
;TXT_SETUP_LinuxDefaultKernel   db '��� Linux �� 㬮�砭��', 0
;TXT_SETUP_LinuxRootPart        db '������ ���� Linux', 0
; This here may be larger than 23 chars...
;TXT_SETUP_DefLinuxCmd          db '������� ��������� ������ ��� LINUX', 0
TXT_SETUP_IgnoreLVM            db '�����஢��� ����� LVM', 0
;~ TXT_SETUP_ForceLBAUsage        db '�ᯮ�짮���� BIOS-LBA', 0
TXT_SETUP_ExtPartMShack        db '������� ��� MS-��⥬', 0

; DYNAMIC LENGTH, maximum 11 chars excluding ending zero
;----------------------------------|---------|------------------------------
TXT_SETUP_MAGIC_Enabled        db '����祭�', 0
TXT_SETUP_MAGIC_Disabled       db '�몫�祭�', 0
TXT_SETUP_MAGIC_Detailed       db '��⠫쭮', 0
TXT_SETUP_MAGIC_NoBootable     db '�� �����.', 0
; [Linux support removed since v1.02]
;TXT_SETUP_MAGIC_NoLinux        db '�� Linux', 0
TXT_SETUP_MAGIC_DoNothing      db '��������.', 0
TXT_SETUP_MAGIC_ResetTime      db '���砫�', 0
TXT_SETUP_MAGIC_StopTime       db '�⮯ �६�', 0
TXT_SETUP_MAGIC_CDROM          db 'CD-ROM', 0
TXT_SETUP_MAGIC_Network        db '����', 0
TXT_SETUP_MAGIC_ZIPLS          db 'ZIP/LS120', 0
; Max Length: 10 (used in Hide-Configuration as well)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Hidden         db '����⠭', 0
TXT_SETUP_MAGIC_Unhidden       db '�����', 0
; Max Length: 10 ("C:" will be appended afterwards)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Set            db '������ ', 0

; Setup Control Help - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUPHELP_Main             db 24,32,25,32,26,32,27,' : �롮� ����⢨�', 0
                               db               'Enter   : ���⢥ত����', 0
                               db               'F10 : ���࠭��� � ���', 0
                               db               'Esc : ���', 0

TXT_SETUPHELP_SubMenu          db 24,32,25,32,26,32,27,' : �롮� �㭪�', 0
                               db               'PgUp/Dn : ����� �㭪�', 0
                               db               'F1  : �������� ������', 0
                               db               'Esc : ������� ����', 0

TXT_SETUPHELP_PartSetup        db 24,32,25,32,26,32,27,' : �롮� ࠧ����', 0
                               db               'Enter   : ����� ��⪨', 0
                               db               'F1  : ����� (����)', 0
                               db               'Esc : ������� ����', 0

; HELP FOR EVERY MENU-ITEM, Maximum Length = 22 chars PER line. Maximum 5 lines

                                  ;1234567890123456789012
;----------------------------------|--------------------|-------------------

TXT_SETUPHELP_PartitionSetup   db '����� ������ ࠧ����', 0
                               db '����㦠��묨, ᬥ����', 0
                               db '�� ��������, ������', 0
                               db '� ������ ��㣮�.', 0
                               db 0
TXT_SETUPHELP_BasicOptions     db '�� ����ன�� ���', 0
                               db '��稭���� ���짮-.', 0
                               db '��⥫��.', 0
                               db 0
TXT_SETUPHELP_AdvOptions       db '�� ����ன�� ���', 0
                               db '������ ���짮��⥫��.', 0
                               db '�᫨ �� �� �����, ��', 0
                               db '��� �����, ��', 0
                               db '�����.', 0
                               db 0
TXT_SETUPHELP_ExtOptions       db '����७�� ��樨 ���', 0
                               db 'ࠧ��� ��⥬.', 0
                               db 0
TXT_SETUPHELP_DefMasterPwd     db '������� ��஫� ���', 0
                               db '����㯠 � ����ன���', 0
                               db '� ��⥬�.', 0
                               db 0
TXT_SETUPHELP_DefBootPwd       db '������� ��஫� ���', 0
                               db '����㯠 � ��⥬�.', 0
                               db 0
TXT_SETUPHELP_SaveAndExit      db '�த������ ����㧪� �', 0
                               db '�孠���� ⥪�騥', 0
                               db '����ன��.', 0
                               db 0
TXT_SETUPHELP_JustExit         db '�த������ ����㧪�,', 0
                               db '�� �⬥���� ��', 0
                               db '��������� ����஥�.', 0
                               db 0

TXT_SETUPHELP_InPartitionSetup db 'B - ����㦠���', 0
                               db 'V - ���� MBR-����ᮢ', 0
                               db 'H - �����প� ���⠭��', 0
                               db 'L - �㪢� ࠧ����', 0
                               db 'P - ����. ����. MS-���', 0
                               db 0

TXT_SETUPHELP_HideSetup        db '�롥�� ���ﭨ�,', 0
                               db '� ���஬ ࠧ���', 0
                               db '������ ����, �����', 0
                               db '��࠭�� ࠧ���', 0
                               db '����㦠����.', 0
                               db 0

; Basic Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_DefaultSelection db '������� ��� �롮�', 0
                               db '��-㬮�砭��.', 0
                               db 0
TXT_SETUPHELP_TimedBoot        db 'AiR-BOOT �த�����', 0
                               db '����㧪� ��᫥ 㪠-', 0
                               db '������� �६���.', 0
                               db 0
TXT_SETUPHELP_TimedBootDelay   db '�६� �� ��砫�', 0
                               db '��⮧���㧪�.', 0
                               db 0
TXT_SETUPHELP_TimedKeyHandling db '����⢨� �� ����⨨', 0
                               db '������ � ���� �����-', 0
                               db '�� �� ����祭���', 0
                               db '��⮧���㧪�.', 0
                               db 0
TXT_SETUPHELP_BootLastIfTimed  db 'AiR-BOOT �㤥� ��㧨��', 0
                               db '��᫥���� ����㦥���', 0
                               db 'ࠧ��� �� ��⮧����-', 0
                               db '��. ���� - ࠧ��� ��', 0
                               db '㬮�砭��.', 0
                               db 0
TXT_SETUPHELP_RememberLastBoot db 'AiR-BOOT ��६�����', 0
                               db '㪠��⥫� ���� �� ���-', 0
                               db '������ ����㦥���', 0
                               db 'ࠧ��� �� ����.', 0
                               db 0
TXT_SETUPHELP_RememberTimeBoot db '�������筮 �।�饬�,', 0
                               db 'AiR-BOOT �������� �', 0
                               db '�� ��⮧���㧪�.', 0
                               db 0
TXT_SETUPHELP_IncludeFloppy    db 'AiR-BOOT ࠧ���', 0
                               db '����㧪� � ��᪠ A:', 0
                               db '�१ ����.', 0
                               db 0
TXT_SETUPHELP_ShowLVMDriveLetters   db 'AiR-BOOT will show', 0
                                    db 'LVM Drive Letters', 0
                                    db 'in the menu.', 0
                                    db 0
TXT_SETUPHELP_MbrProtection    db '���頥� MBR �१', 0
                               db '१������ ���. �㦭�', 0
                               db '1�� ������� �����.', 0
                               db '����� ���� �� ࠡ����', 0
                               db '� ������묨 ��.', 0
                               db 0
TXT_SETUPHELP_IgnoreMbrWrites  db '�����஢���� ��', 0
                               db '����� � MBR, ����', 0
                               db '��⥬� �㤥�', 0
                               db '��⠭������.', 0
                               db 0
TXT_SETUPHELP_MakeSounds       db 'AiR-BOOT �㤥� �����', 0
                               db '��㪨 �१ ���஥���', 0
                               db '�������.', 0
                               db 0
TXT_SETUPHELP_CooperBars       db '������� ����㧪� �����', 0
                               db '��ᨢ��.', 0
                               db 0

; Advanced Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_BootMenu         db '�몫�祭� - 㡨��', 0
                               db '���� � ��㧨� ࠧ���', 0
                               db '�� 㬮�砭��.', 0
                               db '��⠫쭮 - �������', 0
                               db '����� ���ଠ樨.', 0
                               db 0
TXT_SETUPHELP_PartAutoDetect   db '�᫨ AiR-BOOT ������', 0
                               db '���� ࠧ����, �� ', 0
                               db 'ᤥ���� ��', 0
                               db '����㦠��묨.', 0
                               db 0
TXT_SETUPHELP_PasswordedSetup  db '�� ��室� � ����੪�', 0
                               db '� ��� ����� ��஫�.', 0
                               db 0
TXT_SETUPHELP_PasswordedSystem db '�� ���� ��������', 0
                               db '� ��� ����� ��஫�.', 0
                               db 0
TXT_SETUPHELP_PasswordedBoot   db '�� ����㧪� ���', 0
                               db '��⮧���㧪� � ���', 0
                               db '����� ��஫�.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName    db '�� �롮� ��᪥�� �', 0
                               db '���� ����㧪�,', 0
                               db 'AiR-BOOT �������', 0
                               db '�� ���� ��᪠.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName2Sec db '�������⥫쭮 �㤥�', 0
                               db '��������� ��� �����', 0
                               db '����� 2 ᥪ㭤�.', 0
                               db 0
TXT_SETUPHELP_VirusDetect      db '���� ������ ����ᮢ', 0
                               db '(���⥩��).', 0
                               db 0
TXT_SETUPHELP_StealthDetect    db '���� �⥫�-����ᮢ.', 0
                               db 0
TXT_SETUPHELP_VIBRdetect       db '���� ����ᮢ � MBR.', 0
                               db 0
TXT_SETUPHELP_ContinueBIOSboot db '�� ���� ��������', 0
                               db '�த������ ����㧪�', 0
                               db '��⥬� �१ �।�⢠', 0
                               db 'BIOS.', 0
                               db 0

; Extended Options - Help
;----------------------------------|--------------------|-------------------
; [Linux support removed since v1.02]
;TXT_SETUPHELP_LinuxKernelPart  db '������ FAT-16, ��', 0
;                               db '���஬ �ᯮ������', 0
;                               db '��� �� Linux.', 0
;                               db 0
;TXT_SETUPHELP_LinuxDefaultKrnl db '��� 䠩�� ��� ��', 0
;                               db '�� 㬮�砭��.', 0
;                               db 0
;TXT_SETUPHELP_LinuxRootPart    db '������ � ��୥��', 0
;                               db '��⠫���� Linux.', 0
;                               db 0
;TXT_SETUPHELP_DefLinuxCmd:     db '��������� ��ப� ���', 0
;                               db '����㧪� Linux, �᫨', 0
;                               db '����室���.', 0
;                               db 0
TXT_SETUPHELP_IgnoreLVM        db '�� ����祭�� �⮩', 0
                               db '��樨 AiR-BOOT ��', 0
                               db '�㤥� �᪠��', 0
                               db '���ଠ�� LVM', 0
                               db 0
;~ TXT_SETUPHELP_ForceLBAUsage    db '�ॡ㤥� �ᯮ�짮�����', 0
                               ;~ db 'BIOS LBA API �����', 0
                               ;~ db '�������஢������ - CHS', 0
                               ;~ db '� LBA.', 0
                               ;~ db 0
TXT_SETUPHELP_ExtPartMShack    db '����砥� ����������', 0
                               db 'ᬥ�� ⨯� ���७���', 0
                               db 'ࠧ����� � �⠭�����', 0
                               db '��� MS.', 0
                               db '(㪠���� �१ P-䫠�)', 0
                               db 0

; Maximum 26 chars (should not be reached)
;----------------------------------|------------------------|---------------
TXT_SETUPHELP_Base             db ' ������ ', 0
TXT_SETUPHELP_Enter            db '<ENTER>', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_PasswordOld          db '���� ��஫�:', 0
TXT_SETUP_PasswordDefine       db '������ ��஫�:', 0
TXT_SETUP_PasswordVerify       db '������ ��஫�:', 0
TXT_SETUP_PasswordIncorrect    db '���� ��஫� ����७', 0
TXT_SETUP_PasswordMismatch     db '��ᮢ�������! ����⠭����� ���� ��஫�', 0
TXT_SETUP_PasswordDisabled     db '��� ��஫� -> ���� �⪫�祭�', 0
TXT_SETUP_PasswordMatched      db '** ���⢥ত���! ����� ���� ��஫� **', 0

; Maximum 60 chars (should not be reached anyway)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_SaveAndExitNow       db '��������� � �����', 0
TXT_SETUP_QuitWithoutSaveNow   db '����� ��� ����������', 0
; Must be shorter than SaveAndExitNow / QuitWithoutSaveNow
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_AreYouSure1          db '�� �������?', 0
TXT_SETUP_AreYouSure2          db '(Y/N)', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
; [Linux support removed since v1.02]
;TXT_SETUP_EnterLinuxCmdLine    db '������ ��� ��ࠢ�� ��������� ��ப�:', 0
;TXT_SETUP_NoLinuxInstalled     db '� ��� �� ��⠭����� Linux', 0
TXT_SETUP_NoLDLpartition       db '��࠭�� ࠧ��� �� ���� HPFS/FAT16/JFS', 0

; Maximum 34 chars (should not be reached)
;----------------------------------|--------------------------------|-------
TXT_SETUP_HideFeature          db '�����প� �����', 0
;----------------------------------|---------------------|------------------
TXT_SETUP_HideFeature2         db '����ﭨ� �� ����㧪� ', 0

; Drive-Letter Menu Header - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUP_DriveLetter          db '�㪢� ࠧ����', 0

; Drive-Letter Keys - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUPHELP_DriveLetter      db '������ C-Z', 0

; Colors for special words hard-coded. Keep all 0s.
;TXT_SETUP_LowerMessage         db '�� �ணࠬ�� ',0,'��ᯫ�⭠',0,' ��� ���������᪮�� �ᯮ�짮�����.',0
;                               db '�� ',0,'��',0,' ����� �����࠭���/�ᯮ�짮���� AiR-BOOT � ',0,'-�����-',0,' �ଥ,',0
;                               db '�᫨ �� ����砥� �� �� ���죨.',0
;                               db '�᫨ �� ��� �ᯮ�짮���� AiR-BOOT � ',0,'� ��㣨� ��⥬��',0,', ',0,'�।��⠭��������',0,' ���',0
;                               db '�����࠭���',0,' �令��� � ���� �� e-mail: ',0,'kiewitz@netlabs.org',0,' !',0
