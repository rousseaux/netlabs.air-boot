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
TXT_TopInfos_HdSize            db 'Hd/Размер:', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_Label             db 'Имя:', 0
;----------------------------------|---------|------------------------------
TXT_TopInfos_Type              db 'Тип:', 0
;----------------------------------|----|-----------------------------------
TXT_TopInfos_Flags             db 'Флаги:', 0      ; <-- for Partition Setup

; Will be added together to one line, maximum 76 chars
TXT_TimedBootLine              db 'Автозагрузка вклчюена. Будет загружена '''
TXT_TimedBootEntryName         db 12 dup (0) ; Space for Default-Entry-Name
TXT_TimedBootLine2             db      ''' через ', 0
TXT_TimedBootSeconds           db ' секунд. ', 0
TXT_TimedBootSecond            db ' секунду. ', 0 ; if only one is left, ELiTE :]
; Maximum 76 chars
;----------------------------------|--------------------------------------------------------------------------|
TXT_TimedBootDisabled          db 'Автозагрузка отключена, таймер отключен.', 0
TXT_BootMenuHelpText1          db 'Нажмите [Esc] для переключения автозагрузки, [Enter] для выбора раздела.', 0
TXT_BootMenuHelpText2          db 'Выберите раздел или нажмите [TAB], чтобы увидеть сообщения BIOS POST.', 0
; Maximum 30 chars
;----------------------------------|----------------------------|
TXT_BootMenuEnterSetup         db 'F10 для смены настроек.', 0

; Dynamic Length (till 80 chars)
TXT_BrokenPartitionTable       db 13, 10, ' - Обнаружен минимум один испорченный раздел, либо таблица разделов содержит'
                               db 13, 10, '   сбойные блоки. Система остановлена.', 0
TXT_TooManyPartitions          db 13, 10, ' - Слишком много разделов найдено. AiR-BOOT поддерживает до 45.', 0
TXT_NoBootAble                 db 13, 10, ' - Не найдено загружаемых разделов. Система остановлена.', 0
TXT_BIOSchanged                db 13, 10, ' - BIOS ИЗМЕНИЛСЯ, проверьте свою систему на предмет вирусов.'
                               db 13, 10, '   Нажмите любую клавишу для продолжения...', 0

TXT_VirusFoundMain             db 13, 10, ' - !ВНИМАНИЕ! -> НАЙДЕН ВИРУС <- !ВНИМАНИЕ!', 13, 10, 0
TXT_VirusFound1ok              db '    Он был унтичтожен, но система может не загрузиться правильно. Если это', 13, 10
                               db '    это произойдет, используйте Ваш диск AiR-BOOT.', 13, 10, 0
TXT_VirusFound1damn            db '    К сожалению, он стер настройки AiR-BOOT. Вы должны загрузиться, используя', 13, 10
                               db '    Ваш диск AiR-BOOT.', 13, 10, 0
TXT_VirusFound1any             db '    Для безопасности, Вам следует проверить Ваши жесткие диски на вирусы.', 13, 10, 0
TXT_VirusFound2                db '    Вирус находится в MBR раздела, который Вы хотите загрузить.', 13, 10
                               db '    Используйте программы поиска вирусов. Также это может быть ошибочным', 13, 10
                               db '    предупреждением. После удаления вируса, Вы должны перезадать переменные', 13, 10
                               db '    поиска вирусов в ''НАСТРОЙКЕ РАЗДЕЛОВ'' и переключить поиск MBR-вирусов два.', 13, 10
                               db '    раза (выкл/вкл). Если это было ошибочное предупреждение', 13, 10
                               db '    оставьте его в "выкл".', 13, 10, 0
TXT_VirusFoundEnd              db '    Система остановлена. Пожалуйста, нажмите RESET.', 0
TXT_HowEnterSetup              db 13, 10, ' - Нажмите и держите Ctrl или Alt для входа в настройки AiR-BOOT.', 0

TXT_BootingNow1                db 'Загрузка системы, используя ', 0
; DO NOT MODIFY HERE
TXT_BootingNow2                db '''', 0
TXT_BootingNowPartName         db 12 dup (0) ; Space for BootThisPart-Name
; DO NOT MODIFY TILL HERE
TXT_BootingNowPartition        db ' раздел', 0
TXT_BootingNowKernel           db ' ядро', 0
TXT_BootingHide                db '; сокрытие активно', 0
TXT_BootingWait                db '; пожалуйста, подождите...', 13, 10, 13, 10, 0

; FIXED LENGTH - 11 chars each string
;----------------------------------|---------|------------------------------
TXT_Floppy_NoName              db 'Без имени  '
TXT_Floppy_Drive               db 'Дисковод   '
TXT_Floppy_NoDisc              db 'Нет диска  '

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_PleaseEnterPassword        db ' Пожалуйста, введите пароль:', 0
; the following 3 strings have to equal or *longer* than PleaseEnterPassword
TXT_ProtectedSystem            db '**  СИСТЕМА ЗАЩИЩЕНА ПАРОЛЕМ  **', 0
TXT_ProtectedSetup             db '** НАСТРОЙКИ ЗАЩИЩЕНЫ ПАРОЛЕМ **', 0
TXT_ProtectedBootUp            db '** ЗАГРУЗКА ЗАЩИЩЕНА ПАРОЛЕМ! **', 0

; will get completed using TXT_ERROR_CheckFailed from MBR.asm
TXT_ERROR_CheckConfig          db 13, 10, ' - Конфигурация', 0

;----------------------------------|----------------------------------------------------------|
TXT_TooManyTries               db 'Слишком много попыток, система остановлена', 0
