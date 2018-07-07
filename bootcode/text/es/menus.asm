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
TXT_SETUP_PartitionSetup       db 'CONFIGURAR PARTICIONES', 0
TXT_SETUP_BasicOptions         db 'OPCIONES B',0b5h,'SICAS', 0
TXT_SETUP_AdvOptions           db 'OPCIONES AVANZADAS', 0
TXT_SETUP_ExtOptions           db 'OPCIONES DE INICIO EXTENDIDAS', 0
TXT_SETUP_DefMasterPwd         db 'DEFINIR CONTRASE¥A MAESTRA', 0
TXT_SETUP_DefBootPwd           db 'DEFINIR CONTRASE¥A DE INICIO', 0
TXT_SETUP_SaveAndExit          db 'GUARDAR OPCIONES Y SALIR', 0
TXT_SETUP_JustExit             db 'SALIR SIN CAMBIOS', 0

; The Letters for all flags in Partition Setup
TXT_SETUP_FlagLetterBootable   equ 'I'
TXT_SETUP_FlagLetterVIBR       equ 'V'
TXT_SETUP_FlagLetterHide       equ 'O'
TXT_SETUP_FlagLetterDrvLetter  equ 'L'
TXT_SETUP_FlagLetterExtMShack  equ 'E'

TXT_SETUP_LetterYes            equ 'S'
TXT_SETUP_LetterYes2           equ 'Z'
TXT_SETUP_LetterNo             equ 'N'

; Basic Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_DefaultSelection     db 'Por omisi¢n iniciar', 0
TXT_SETUP_TimedBoot            db 'Temporizador', 0
TXT_SETUP_TimedBootDelay       db 'Tiempo para iniciar (s)', 0
TXT_SETUP_TimedKeyHandling     db 'Teclas durante cuenta', 0
TXT_SETUP_BootLastIfTimed      db 'Temp. = iniciar £ltimo', 0
TXT_SETUP_RememberLastBoot     db 'Recordar selecci¢n', 0
TXT_SETUP_RememberTimedBoot    db 'Recordar temporizaci¢n', 0
TXT_SETUP_IncludeFloppy        db 'Incluir disquetera', 0
TXT_SETUP_ShowLVMDriveLetters  db 'Mostrar unidades LVM',0
TXT_SETUP_MbrProtection        db 'Proteger MBR', 0
TXT_SETUP_IgnoreMbrWrites      db '-> Ignorar escritura', 0
TXT_SETUP_MakeSounds           db 'Sonido', 0
TXT_SETUP_CooperBars           db 'Cooper Bars', 0

; Advanced Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_BootMenu             db 'Men£ de inicio', 0
TXT_SETUP_PartAutoDetect       db 'Detectar particiones', 0
TXT_SETUP_SecurityOptions      db '-> Opcs. seguridad <-', 0
TXT_SETUP_PasswordedSetup      db 'Clave para configurar', 0
TXT_SETUP_PasswordedSystem     db 'Clave para iniciar', 0
TXT_SETUP_PasswordedChangeBoot db 'Clave para cambiar', 0
TXT_SETUP_GetFloppyName        db 'Leer etiqueta disquete', 0
TXT_SETUP_GetFloppyName2Sec    db '-> Leer cada 2 seg.', 0
TXT_SETUP_VirusDetect          db 'Detecci¢n de virus', 0
TXT_SETUP_StealthDetect        db 'Detecci¢n c¢d. oculto', 0
TXT_SETUP_VIBRdetect           db 'Detecci¢n virus VERA', 0
TXT_SETUP_ContinueBIOSboot     db 'Continuar inicio BIOS', 0

; Extended Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
; [Linux support removed since v1.02]
;TXT_SETUP_LinuxKernelPart      db 'Linux Kernel Partition', 0
;TXT_SETUP_LinuxDefaultKernel   db 'Linux Default Kernel', 0
;TXT_SETUP_LinuxRootPart        db 'Linux Root Partition', 0
; This here may be larger than 23 chars...
;TXT_SETUP_DefLinuxCmd          db 'DEFINE COMMAND LINE FOR LINUX', 0
TXT_SETUP_IgnoreLVM            db 'Ignorar infor. del LVM', 0
;~ TXT_SETUP_ForceLBAUsage        db 'Force BIOS-LBA Usage', 0
TXT_SETUP_ExtPartMShack        db 'Part. extendidas de M$', 0

; DYNAMIC LENGTH, maximum 11 chars excluding ending zero
;----------------------------------|---------|------------------------------
TXT_SETUP_MAGIC_Enabled        db 'Activo', 0
TXT_SETUP_MAGIC_Disabled       db 'Inactivo', 0
TXT_SETUP_MAGIC_Detailed       db 'Detallado', 0
TXT_SETUP_MAGIC_NoBootable     db 'No iniciabl', 0
; [Linux support removed since v1.02]
;TXT_SETUP_MAGIC_NoLinux        db 'No Linux', 0
TXT_SETUP_MAGIC_DoNothing      db 'Ignorar', 0
TXT_SETUP_MAGIC_ResetTime      db 'Reiniciar', 0
TXT_SETUP_MAGIC_StopTime       db 'Detener', 0
TXT_SETUP_MAGIC_CDROM          db 'CD-ROM', 0
TXT_SETUP_MAGIC_Network        db 'Red', 0
TXT_SETUP_MAGIC_ZIPLS          db 'ZIP/LS120', 0
; Max Length: 10 (used in Hide-Configuration as well)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Hidden         db 'Oculta', 0
TXT_SETUP_MAGIC_Unhidden       db 'Visible', 0
; Max Length: 10 ("C:" will be appended afterwards)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Set            db 'hacer ', 0

; Setup Control Help - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUPHELP_Main             db 24,32,25,32,26,32,27,' : Navegar', 0
                               db               'Enter   : Entrar/Ejecutar', 0
                               db 'F10 : Guardar cambios y salir', 0
                               db 'Esc : Ir al men£ de inicio', 0

TXT_SETUPHELP_SubMenu          db 24,32,25,32,26,32,27,' : Navegar', 0
                               db               'Re/AvP g: Cambiar valor', 0
                               db 'F1  : Ayuda del elemento', 0
                               db 'Esc : Ir al men£ anterior', 0

TXT_SETUPHELP_PartSetup        db 24,32,25,32,26,32,27,' : Elegir partici¢n', 0
                               db               'Enter   : Editar etiqueta', 0
                               db 'F1  : Opciones (teclas independ.)', 0
                               db 'Esc : Ir al men£ anterior', 0

; HELP FOR EVERY MENU-ITEM, Maximum Length = 22 chars PER line. Maximum 5 lines

                                  ;1234567890123456789012
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_PartitionSetup   db 'Hacer sus particiones', 0
                               db 'iniciables, cambiarles', 0
                               db 'el nombre, opciones de', 0
                               db 'ocultaci¢n, etc.', 0
                               db 0
TXT_SETUPHELP_BasicOptions     db 'Establecer el sistema', 0
                               db 'iniciado por omisi¢n,', 0
                               db 'opciones de inicio por', 0
                               db 'tiempo, disquete, etc.', 0
                               db 0
TXT_SETUPHELP_AdvOptions       db 'Si no tiene el conoci-', 0
                               db 'miento t‚cnico para', 0
                               db 'estar seguro de qu‚', 0
                               db 'hacen, no las cambie.', 0
                               db 0
TXT_SETUPHELP_ExtOptions       db 'Opciones extendidas', 0
                               db 'para SO espec¡ficos.', 0
                               db 0
TXT_SETUPHELP_DefMasterPwd     db 'Defina una clave para', 0
                               db 'acceder a la configu-', 0
                               db 'raci¢n y el sistema.', 0
                               db 0
TXT_SETUPHELP_DefBootPwd       db 'Defina una clave para', 0
                               db 'iniciar el sistema.', 0
                               db 0
TXT_SETUPHELP_SaveAndExit      db 'Continuar el proceso', 0
                               db 'de inicio guardando', 0
                               db 'las opciones actuales.', 0
                               db 0
TXT_SETUPHELP_JustExit         db 'Continuar el proceso', 0
                               db 'de inicio sin guardar', 0
                               db 'cambios hechos a las', 0
                               db 'opciones.', 0
                               db 0

TXT_SETUPHELP_InPartitionSetup db 'I - Incluir en el men£', 0
                               db 'V - Detecci¢n VERA', 0
                               db 'O - Ocultaci¢n select.', 0
                               db 'L - Letra de unidad', 0
                               db 'E - Part. ext. a la M$', 0
                               db 0

TXT_SETUPHELP_HideSetup        db 'Establecer que las de-', 0
                               db 'm s particiones sean', 0
                               db 'visibles o no al ini-', 0
                               db 'ciar la seleccionada.', 0
                               db 0

; Basic Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_DefaultSelection db 'Cambia la selecci¢n de', 0
                               db 'inicio. Se puede usar', 0
                               db 'con temporizador.', 0
                               db 0
TXT_SETUPHELP_TimedBoot        db 'AiR-BOOT iniciar  el', 0
                               db 'sistema tras cierto', 0
                               db 'intervalo de tiempo.', 0
                               db 0
TXT_SETUPHELP_TimedBootDelay   db 'El intervalo de tiempo', 0
                               db 'para el inicio.', 0
                               db 0
TXT_SETUPHELP_TimedKeyHandling db 'Establece qu‚ hacer si', 0
                               db 'se pulsa una tecla', 0
                               db 'durante la cuenta para', 0
                               db 'el inicio.', 0
                               db 0
TXT_SETUPHELP_BootLastIfTimed  db 'Si se activ¢ el inicio', 0
                               db 'por tiempo, iniciar el', 0
                               db '£ltimo sistema; si no,', 0
                               db 'iniciar el establecido', 0
                               db 'por omisi¢n.', 0
                               db 0
TXT_SETUPHELP_RememberLastBoot db 'Al inicio, colocar el', 0
                               db 'cursor del men£ sobre', 0
                               db 'el £ltimo sistema que', 0
                               db 'se arranc¢ desde ‚l.', 0
                               db 0
TXT_SETUPHELP_RememberTimeBoot db 'Tambi‚n se puede', 0
                               db 'recordar el £ltimo', 0
                               db 'sistema iniciado por', 0
                               db 'tiempo.', 0
                               db 0
TXT_SETUPHELP_IncludeFloppy    db 'Permitir  iniciar', 0
                               db 'disquetes de sistema', 0
                               db 'desde el men£.', 0
                               db 0
TXT_SETUPHELP_ShowLVMDriveLetters   db 'AiR-BOOT mostrar  las', 0
                                    db 'letras de unidad del', 0
                                    db 'LVM en el men£.', 0
                                    db 0
TXT_SETUPHELP_MbrProtection    db 'Activar 1KB de c¢digo', 0
                               db 'residente para prote-', 0
                               db 'ger el MBR. Puede ser', 0
                               db 'incompatible con algu-', 0
                               db 'nos SO.', 0
                               db 0
TXT_SETUPHELP_IgnoreMbrWrites  db 'Activado, se ignorar n', 0
                               db 'las operaciones de', 0
                               db 'escritura; desactivado', 0
                               db 'el sistema ®fallar ¯.', 0
                               db 0
TXT_SETUPHELP_MakeSounds       db 'AiR-BOOT puede emitir', 0
                               db 'sonidos mediante el', 0
                               db 'altavoz interno.', 0
                               db 0
TXT_SETUPHELP_CooperBars       db 'Will make some fancy', 0
                               db 'effect during bootup.', 0
                               db 0

; Advanced Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_BootMenu         db '®Inactivo¯ iniciar  el', 0
                               db 'sistema por omisi¢n', 0
                               db 'sin mostrar el men£.', 0
                               db '®Detallado¯ mostrar ', 0
                               db 'm s informaci¢n.', 0
                               db 0
TXT_SETUPHELP_PartAutoDetect   db 'Si AiR-BOOT debe', 0
                               db 'buscar particiones', 0
                               db 'nuevas que mostrar en', 0
                               db 'el men£ de inicio.', 0
                               db 0
TXT_SETUPHELP_PasswordedSetup  db 'Pedir una contrase¤a', 0
                               db 'para entrar a esta', 0
                               db 'configuraci¢n.', 0
                               db 0
TXT_SETUPHELP_PasswordedSystem db 'Pedir una contrase¤a', 0
                               db 'al iniciar el sistema.', 0
                               db 0
TXT_SETUPHELP_PasswordedBoot   db 'Pedir una contrase¤a', 0
                               db 'cuando el inicio no', 0
                               db 'est‚ temporizado.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName    db 'Al mostrar la unidad', 0
                               db 'de disquete en el men£', 0
                               db 'AiR-BOOT leer  la', 0
                               db 'etiqueta de volumen.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName2Sec db 'Y adem s lo intentar ', 0
                               db 'opcionalmente cada dos', 0
                               db 'segundos.', 0
                               db 0
TXT_SETUPHELP_VirusDetect      db 'Detectar los virus', 0
                               db 'normales (torpes).', 0
                               db 0
TXT_SETUPHELP_StealthDetect    db 'Detectar los virus', 0
                               db 'que se camuflan.', 0
                               db 0
TXT_SETUPHELP_VIBRdetect       db 'Detecci¢n de Virus En', 0
                               db 'Registro de Arranque', 0
                               db '(de la partici¢n).', 0
                               db 0
TXT_SETUPHELP_ContinueBIOSboot db 'Al activarse, esta', 0
                               db 'opci¢n devuelve el', 0
                               db 'control a la BIOS', 0
                               db 'para este dispositivo.', 0
                               db 0

; Extended Options - Help
;----------------------------------|--------------------|-------------------
; [Linux support removed since v1.02]
;TXT_SETUPHELP_LinuxKernelPart  db 'Defines the FAT-16', 0
;                               db 'partition that holds', 0
;                               db 'your Linux kernels.', 0
;                               db 0
;TXT_SETUPHELP_LinuxDefaultKrnl db 'Defines your default', 0
;                               db 'kernel filename.', 0
;                               db 0
;TXT_SETUPHELP_LinuxRootPart    db 'Changes your Linux', 0
;                               db 'root partition.', 0
;                               db 0
;TXT_SETUPHELP_DefLinuxCmd:     db 'Defines the command', 0
;                               db 'line for Linux, if', 0
;                               db 'available.', 0
;                               db 0
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_IgnoreLVM        db 'Al activarse, AiR-BOOT', 0
                               db 'ni siquiera buscar ', 0
                               db 'informaci¢n del LVM', 0
                               db 'en las particiones.', 0
                               db 0
;~ TXT_SETUPHELP_ForceLBAUsage    db 'Forces the usage of', 0
                               ;~ db 'BIOS LBA APIs instead', 0
                               ;~ db 'of mixed usage of CHS', 0
                               ;~ db 'and LBA.', 0
                               ;~ db 0
TXT_SETUPHELP_ExtPartMShack    db 'Cambiar din micamente', 0
                               db 'entre el identificador', 0
                               db 'de partici¢n extendida', 0
                               db 'est ndar y el de M$.', 0
                               db '(Control por tecla E.)', 0
                               db 0

; Maximum 26 chars (should not be reached)
;----------------------------------|------------------------|---------------
TXT_SETUPHELP_Base             db ' AYUDA ', 0
TXT_SETUPHELP_Enter            db '<ENTER>', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_PasswordOld          db 'Contrase¤a anterior:', 0
TXT_SETUP_PasswordDefine       db 'Nueva contrase¤a:', 0
TXT_SETUP_PasswordVerify       db 'Repetir contrase¤a:', 0
TXT_SETUP_PasswordIncorrect    db 'Contrase¤a anterior incorrecta, lo sentimos.', 0
TXT_SETUP_PasswordMismatch     db 'No son iguales, vuelta a la anterior', 0
TXT_SETUP_PasswordDisabled     db 'Sin contrase¤a -> No hay protecci¢n', 0
TXT_SETUP_PasswordMatched      db '** Nueva contrase¤a establecida **', 0

; Maximum 60 chars (should not be reached anyway)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_SaveAndExitNow       db 'GUARDAR Y SALIR', 0
TXT_SETUP_QuitWithoutSaveNow   db 'SALIR SIN GUARDAR', 0
; Must be shorter than SaveAndExitNow / QuitWithoutSaveNow
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_AreYouSure1          db '¨EST',0b5h,' SEGURO?', 0
TXT_SETUP_AreYouSure2          db '(S/N)', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
; [Linux support removed since v1.02]
;TXT_SETUP_EnterLinuxCmdLine    db 'Please enter/modify your Linux command-line:', 0
;TXT_SETUP_NoLinuxInstalled     db 'You do not have Linux installed', 0
TXT_SETUP_NoLDLpartition       db 'La partici¢n seleccionada no es HPFS/FAT16/JFS', 0

;;;;;;;;;

; Maximum 34 chars (should not be reached)
;----------------------------------|--------------------------------|-------
TXT_SETUP_HideFeature          db 'Ocultaci¢n selectiva', 0
;----------------------------------|---------------------|------------------
TXT_SETUP_HideFeature2         db 'Visibilidad al iniciar ', 0

; Drive-Letter Menu Header - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUP_DriveLetter          db 'Letra de unidad', 0

; Drive-Letter Keys - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUPHELP_DriveLetter      db 'Pulse C-Z', 0

; Colors for special words hard-coded. Keep all 0s.
;TXT_SETUP_LowerMessage      db 0,'Free',0,' private usage, but NOT for people that are/were working for US government',0
;                            db 'This software is released under ', 0, 'GPLv3+.', 0
;                            db 'For more information and source, please visit', 0
;                            db 'http://AiR-BOOT.sourceforge.net', 0
;                            db 'Contact via e-mail: ', 0, 'm_kiewitz [AT] users.sourceforge.net', 0
