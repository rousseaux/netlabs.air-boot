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
TXT_SETUP_PartitionSetup       db 'НАСТРОЙКИ РАЗДЕЛОВ', 0
TXT_SETUP_BasicOptions         db 'ОСНОВНЫЕ НАСТРОЙКИ', 0
TXT_SETUP_AdvOptions           db 'ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ', 0
TXT_SETUP_ExtOptions           db 'НАСТРОЙКА РАСШИРЕННОЙ ЗАГРУЗКИ', 0
TXT_SETUP_DefMasterPwd         db 'ЗАДАТЬ ОБЩИЙ ПАРОЛЬ', 0
TXT_SETUP_DefBootPwd           db 'ЗАДАТЬ ПАРОЛЬ НА ЗАГРУЗКУ', 0
TXT_SETUP_SaveAndExit          db 'СОХРАНИТЬ И ВЫЙТИ', 0
TXT_SETUP_JustExit             db 'ВЫЙТИ БЕЗ СОХРАНЕНИЯ', 0

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
TXT_SETUP_DefaultSelection     db 'Выбор по-умолчанию', 0
TXT_SETUP_TimedBoot            db 'Автоматическая загрузка', 0
TXT_SETUP_TimedBootDelay       db 'Время автозагрузки (с)', 0
TXT_SETUP_TimedKeyHandling     db 'Клавиши в автозагрузке', 0
TXT_SETUP_BootLastIfTimed      db 'Грузить последнюю сист.', 0
TXT_SETUP_RememberLastBoot     db 'Помнить последнюю сист.', 0
TXT_SETUP_RememberTimedBoot    db 'Помнить в автозагрузке', 0
TXT_SETUP_IncludeFloppy        db 'Добавить дисковод', 0
TXT_SETUP_MbrProtection        db 'Защита MBR', 0
TXT_SETUP_IgnoreMbrWrites      db '-> Не менять MBR', 0
TXT_SETUP_MakeSounds           db 'Разрешить звуки', 0
TXT_SETUP_CooperBars           db 'Красивая загрука', 0

; Advanced Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_BootMenu             db 'Меню при загрузке', 0
TXT_SETUP_PartAutoDetect       db 'Автопоиск разделов', 0
TXT_SETUP_SecurityOptions      db '-> Безопасность <-', 0
TXT_SETUP_PasswordedSetup      db 'Настройки по паролю', 0
TXT_SETUP_PasswordedSystem     db 'Система по паролю', 0
TXT_SETUP_PasswordedChangeBoot db 'Смена системы по паролю', 0
TXT_SETUP_GetFloppyName        db 'Получать метку дискеты', 0
TXT_SETUP_GetFloppyName2Sec    db '-> Каждые 2 секунды', 0
TXT_SETUP_VirusDetect          db 'Поиск вирусов', 0
TXT_SETUP_StealthDetect        db 'Поиск стелс-вирусов', 0
TXT_SETUP_VIBRdetect           db 'Поиск MBR-вирусов', 0
TXT_SETUP_ContinueBIOSboot     db 'Загрузка через BIOS', 0

; Extended Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
; [Linux support removed since v1.02]
;TXT_SETUP_LinuxKernelPart      db 'Раздел ядра Linux', 0
;TXT_SETUP_LinuxDefaultKernel   db 'Ядро Linux по умолчанию', 0
;TXT_SETUP_LinuxRootPart        db 'Раздел корня Linux', 0
; This here may be larger than 23 chars...
;TXT_SETUP_DefLinuxCmd          db 'ЗАДАЙТЕ КОМАНДНУЮ СТРОКУ ДЛЯ LINUX', 0
TXT_SETUP_IgnoreLVM            db 'Игнорировать данные LVM', 0
TXT_SETUP_ForceLBAUsage        db 'Использовать BIOS-LBA', 0
TXT_SETUP_ExtPartMShack        db 'Разделы для MS-систем', 0

; DYNAMIC LENGTH, maximum 11 chars excluding ending zero
;----------------------------------|---------|------------------------------
TXT_SETUP_MAGIC_Enabled        db 'Включено', 0
TXT_SETUP_MAGIC_Disabled       db 'Выключено', 0
TXT_SETUP_MAGIC_Detailed       db 'Детально', 0
TXT_SETUP_MAGIC_NoBootable     db 'Не загруж.', 0
; [Linux support removed since v1.02]
;TXT_SETUP_MAGIC_NoLinux        db 'Не Linux', 0
TXT_SETUP_MAGIC_DoNothing      db 'Бездейств.', 0
TXT_SETUP_MAGIC_ResetTime      db 'Сначала', 0
TXT_SETUP_MAGIC_StopTime       db 'Стоп время', 0
TXT_SETUP_MAGIC_CDROM          db 'CD-ROM', 0
TXT_SETUP_MAGIC_Network        db 'Сеть', 0
TXT_SETUP_MAGIC_ZIPLS          db 'ZIP/LS120', 0
; Max Length: 10 (used in Hide-Configuration as well)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Hidden         db 'Спрятан', 0
TXT_SETUP_MAGIC_Unhidden       db 'Открыт', 0
; Max Length: 10 ("C:" will be appended afterwards)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Set            db 'задать ', 0

; Setup Control Help - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUPHELP_Main:            db 24,32,25,32,26,32,27,' : Выбор действия', 0
                               db               'Enter   : Подтверждение', 0
                               db               'F10 : Сохранить и выйти', 0
                               db               'Esc : Выйти', 0

TXT_SETUPHELP_SubMenu:         db 24,32,25,32,26,32,27,' : Выбор пункт', 0
                               db               'PgUp/Dn : Смена пункта', 0
                               db               'F1  : Показать помощь', 0
                               db               'Esc : Главное меню', 0

TXT_SETUPHELP_PartSetup:       db 24,32,25,32,26,32,27,' : Выбор раздела', 0
                               db               'Enter   : Смена метки', 0
                               db               'F1  : Флаги (ключи)', 0
                               db               'Esc : Главное меню', 0

; HELP FOR EVERY MENU-ITEM, Maximum Length = 22 chars PER line. Maximum 5 lines

                                  ;1234567890123456789012
;----------------------------------|--------------------|-------------------

TXT_SETUPHELP_PartitionSetup:  db 'Можете задать разделы', 0
                               db 'загружаемыми, сменить', 0
                               db 'их название, спрятать', 0
                               db 'и многое другое.', 0
                               db 0
TXT_SETUPHELP_BasicOptions:    db 'Это настройки для', 0
                               db 'начинающих пользо-.', 0
                               db 'вателей.', 0
                               db 0
TXT_SETUPHELP_AdvOptions:      db 'Эти настройки для', 0
                               db 'опытных пользователей.', 0
                               db 'Если Вы не знаете, что', 0
                               db 'они значат, не', 0
                               db 'меняйте.', 0
                               db 0
TXT_SETUPHELP_ExtOptions:      db 'Расширенные опции для', 0
                               db 'разных систем.', 0
                               db 0
TXT_SETUPHELP_DefMasterPwd:    db 'Задание пароля для', 0
                               db 'доступа к настройкам', 0
                               db 'и системе.', 0
                               db 0
TXT_SETUPHELP_DefBootPwd:      db 'Задание пароля для', 0
                               db 'доступа к системе.', 0
                               db 0
TXT_SETUPHELP_SaveAndExit:     db 'Продолжить загрузку и', 0
                               db 'сохнанить текущие', 0
                               db 'настройки.', 0
                               db 0
TXT_SETUPHELP_JustExit:        db 'Продолжить загрузку,', 0
                               db 'но отменить все', 0
                               db 'изменения настроек.', 0
                               db 0

TXT_SETUPHELP_InPartitionSetup db 'B - Загружаемый', 0
                               db 'V - Поиск MBR-вирусов', 0
                               db 'H - Поддержка прятания', 0
                               db 'L - Буква раздела', 0
                               db 'P - Расш. Разд. MS-Хак', 0
                               db 0

TXT_SETUPHELP_HideSetup:       db 'Выберите состояние,', 0
                               db 'в котором раздел', 0
                               db 'должен быть, когда', 0
                               db 'выбранный раздел', 0
                               db 'загружается.', 0
                               db 0

; Basic Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_DefaultSelection db 'Сменить Ваш выбор', 0
                               db 'по-умолчанию.', 0
                               db 0
TXT_SETUPHELP_TimedBoot        db 'AiR-BOOT продолжит', 0
                               db 'загрузку после ука-', 0
                               db 'занного времени.', 0
                               db 0
TXT_SETUPHELP_TimedBootDelay   db 'Время до начала', 0
                               db 'автозагрузки.', 0
                               db 0
TXT_SETUPHELP_TimedKeyHandling db 'Действите при нажатии', 0
                               db 'клавиши в меню загруз-', 0
                               db 'ки при включенной', 0
                               db 'автозагрузке.', 0
                               db 0
TXT_SETUPHELP_BootLastIfTimed  db 'AiR-BOOT будет грузить', 0
                               db 'последний загруженный', 0
                               db 'раздел при автозагруз-', 0
                               db 'ке. Иначе - раздел по', 0
                               db 'умолчанию.', 0
                               db 0
TXT_SETUPHELP_RememberLastBoot db 'AiR-BOOT переменстит', 0
                               db 'указатель меню на пос-', 0
                               db 'ледний загруженный', 0
                               db 'раздел при старте.', 0
                               db 0
TXT_SETUPHELP_RememberTimeBoot db 'Аналогично предущему,', 0
                               db 'AiR-BOOT запомнит и', 0
                               db 'при автозагрузке.', 0
                               db 0
TXT_SETUPHELP_IncludeFloppy    db 'AiR-BOOT разрешит', 0
                               db 'загрузку с диска A:', 0
                               db 'через меню.', 0
                               db 0
TXT_SETUPHELP_MbrProtection    db 'Защищает MBR через', 0
                               db 'резидентный код. Нужно', 0
                               db '1кб базовой памяти.', 0
                               db 'Может быть не работать', 0
                               db 'с некоторыми ОС.', 0
                               db 0
TXT_SETUPHELP_IgnoreMbrWrites  db 'Игнорирование любой', 0
                               db 'записи в MBR, иначе', 0
                               db 'система будет', 0
                               db 'остановлена.', 0
                               db 0
TXT_SETUPHELP_MakeSounds       db 'AiR-BOOT будет играть', 0
                               db 'звуки через встроенный', 0
                               db 'динамик.', 0
                               db 0
TXT_SETUPHELP_CooperBars       db 'Сделает загрузку более', 0
                               db 'красивой.', 0
                               db 0

; Advanced Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_BootMenu         db 'Выключено - убирет', 0
                               db 'меню и грузит раздел', 0
                               db 'по умолчанию.', 0
                               db 'Детально - покажет', 0
                               db 'больше информации.', 0
                               db 0
TXT_SETUPHELP_PartAutoDetect   db 'Если AiR-BOOT найдет', 0
                               db 'новые разделы, он ', 0
                               db 'сделает их', 0
                               db 'загружаемыми.', 0
                               db 0
TXT_SETUPHELP_PasswordedSetup  db 'При заходе в настрйки', 0
                               db 'у Вас спросят пароль.', 0
                               db 0
TXT_SETUPHELP_PasswordedSystem db 'При старте компьютера', 0
                               db 'у Вас спросят пароль.', 0
                               db 0
TXT_SETUPHELP_PasswordedBoot   db 'При загрузке без', 0
                               db 'автозагрузки у Вас', 0
                               db 'спросят пароль.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName    db 'При выборе дискеты в', 0
                               db 'меню загрузки,', 0
                               db 'AiR-BOOT покажет', 0
                               db 'ее метку диска.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName2Sec db 'Дополнительно будет', 0
                               db 'обновлять эту мекту', 0
                               db 'каждые 2 секунды.', 0
                               db 0
TXT_SETUPHELP_VirusDetect      db 'Поиск обычных вирусов', 0
                               db '(простейших).', 0
                               db 0
TXT_SETUPHELP_StealthDetect    db 'Поиск стелс-висусов.', 0
                               db 0
TXT_SETUPHELP_VIBRdetect       db 'Поиск вирусов в MBR.', 0
                               db 0
TXT_SETUPHELP_ContinueBIOSboot db 'Эта опция позволит', 0
                               db 'продолжить загрузку', 0
                               db 'системы через средства', 0
                               db 'BIOS.', 0
                               db 0

; Extended Options - Help
;----------------------------------|--------------------|-------------------
; [Linux support removed since v1.02]
;TXT_SETUPHELP_LinuxKernelPart  db 'Раздел FAT-16, на', 0
;                               db 'котором расположены', 0
;                               db 'Ваши ядра Linux.', 0
;                               db 0
;TXT_SETUPHELP_LinuxDefaultKrnl db 'Имя файла для ядра', 0
;                               db 'по умолчанию.', 0
;                               db 0
;TXT_SETUPHELP_LinuxRootPart    db 'Раздел с корневым', 0
;                               db 'каталогом Linux.', 0
;                               db 0
;TXT_SETUPHELP_DefLinuxCmd:     db 'Командная строка для', 0
;                               db 'загрузки Linux, если', 0
;                               db 'необходимо.', 0
;                               db 0
TXT_SETUPHELP_IgnoreLVM        db 'При включении этой', 0
                               db 'опции AiR-BOOT не', 0
                               db 'будет искать', 0
                               db 'информацию LVM', 0
                               db 0
TXT_SETUPHELP_ForceLBAUsage    db 'Требудет использование', 0
                               db 'BIOS LBA API вместо', 0
                               db 'комбинированного - CHS', 0
                               db 'и LBA.', 0
                               db 0
TXT_SETUPHELP_ExtPartMShack    db 'Включает динамическую', 0
                               db 'смену типа расширенных', 0
                               db 'разделов в стандартный', 0
                               db 'или MS.', 0
                               db '(указать через P-флаг)', 0
                               db 0

; Maximum 26 chars (should not be reached)
;----------------------------------|------------------------|---------------
TXT_SETUPHELP_Base             db ' ПОМОЩЬ ', 0
TXT_SETUPHELP_Enter            db '<ENTER>', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_PasswordOld          db 'Старый пароль:', 0
TXT_SETUP_PasswordDefine       db 'Укажите пароль:', 0
TXT_SETUP_PasswordVerify       db 'Повторите пароль:', 0
TXT_SETUP_PasswordIncorrect    db 'Старый пароль неверен', 0
TXT_SETUP_PasswordMismatch     db 'Несовпадение! Восстановлен старый пароль', 0
TXT_SETUP_PasswordDisabled     db 'Нет пароля -> защита отключена', 0
TXT_SETUP_PasswordMatched      db '** Подтверждено! Задан новый пароль **', 0

; Maximum 60 chars (should not be reached anyway)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_SaveAndExitNow       db 'СОХРАНИТЬ И ВЫЙТИ', 0
TXT_SETUP_QuitWithoutSaveNow   db 'ВЫЙТИ БЕЗ СОХРАНЕНИЯ', 0
; Must be shorter than SaveAndExitNow / QuitWithoutSaveNow
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_AreYouSure1          db 'ВЫ УВЕРЕНЫ?', 0
TXT_SETUP_AreYouSure2          db '(Y/N)', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
; [Linux support removed since v1.02]
;TXT_SETUP_EnterLinuxCmdLine    db 'Введите или исправьте командную строку:', 0
;TXT_SETUP_NoLinuxInstalled     db 'У Вас не установлен Linux', 0
TXT_SETUP_NoLDLpartition       db 'Выбранный раздел не является HPFS/FAT16/JFS', 0

; Maximum 34 chars (should not be reached)
;----------------------------------|--------------------------------|-------
TXT_SETUP_HideFeature          db 'Поддержка скрытия', 0
;----------------------------------|---------------------|------------------
TXT_SETUP_HideFeature2         db 'Состояние при загрузке ', 0

; Drive-Letter Menu Header - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUP_DriveLetter          db 'Буква раздела', 0

; Drive-Letter Keys - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUPHELP_DriveLetter      db 'Нажмите C-Z', 0

; Colors for special words hard-coded. Keep all 0s.
;TXT_SETUP_LowerMessage         db 'Эта программа ',0,'бесплатна',0,' для некоммерческого использования.',0
;                               db 'Вы ',0,'НЕ',0,' можете распространять/использовать AiR-BOOT в ',0,'-ЛЮБОЙ-',0,' форме,',0
;                               db 'если Вы получаете за это деньги.',0
;                               db 'Если Вы хотите использовать AiR-BOOT в ',0,'в других системах',0,', ',0,'предустанавливать',0,' или',0
;                               db 'распространять',0,' свяжитесь со мной по e-mail: ',0,'kiewitz@netlabs.org',0,' !',0
