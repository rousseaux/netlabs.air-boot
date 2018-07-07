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
; v001 - Spanish - by Alfredo Fern ndez D¡az
;------------------------------------------------------------------------------

TXT_TranslationBy              db 0

; TopInfosX variables are used for Boot-Menu and Partition Setup

; Maximum 2/10/11/6 chars
;----------------------------------||---------------------------------------
TXT_TopInfos_No                db 'N§', 0
TXT_TopInfos_Hd                db 'DD', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_HdSize            db 'DD/Tama¤o:', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_Label             db 'Etiqueta:', 0
;----------------------------------|---------|------------------------------
TXT_TopInfos_Type              db 'Tipo:', 0
;----------------------------------|----|-----------------------------------
TXT_TopInfos_Flags             db 'Opcs.:', 0      ; <-- for Partition Setup

; Will be added together to one line, maximum 76 chars
TXT_TimedBootLine              db 'Inicio temporizado. Se iniciar  '''
TXT_TimedBootEntryName         db 12 dup (0) ; Space for Default-Entry-Name
TXT_TimedBootLine2             db      ''' en ', 0
TXT_TimedBootSeconds           db ' segundos. ', 0
TXT_TimedBootSecond            db ' segundo. ', 0 ; if only one is left, ELiTE :]
; Maximum 76 chars
;----------------------------------|--------------------------------------------------------------------------|
TXT_TimedBootDisabled          db 'Temporizador inactivo; no se iniciar  autom ticamente ning£n sistema.', 0
TXT_BootMenuHelpText1          db 'Pulse [Esc] para (des)activar, [Enter] para iniciar el sistema seleccionado.', 0
TXT_BootMenuHelpText2          db 'Seleccione con las flechas, o pulse [TAB] para ver mensajes POST de la BIOS.', 0
; Maximum 30 chars
;----------------------------------|----------------------------|
TXT_BootMenuEnterSetup         db 'F10 para configurar', 0
;TXT_BootMenuEnterBootLog       db 'TAB to enter Boot Log', 0

; Dynamic Length (till 80 chars)
TXT_BrokenPartitionTable       db 13, 10, ' - Hay al menos una entrada corrupta en la tabla de partici¢n o'
                               db 13, 10, '   sectores ilegibles en el disco duro. Sistema detenido.', 0
TXT_TooManyPartitions          db 13, 10, ' - Detectadas m s de 45 particiones (l¡mite de AiR-BOOT).', 0
TXT_NoBootAble                 db 13, 10, ' - Ninguna partici¢n designada iniciable. Sistema detenido.', 0
TXT_BIOSchanged                db 13, 10, ' - BIOS CAMBIADA; por favor, examine el sistema en busca de virus para'
                               db 13, 10, '   asegurarse. Pulse cualquier tecla para continuar...', 0

TXT_VirusFoundMain             db 13, 10, ' - ­ATENCIàN! -> ENCONTRADO VIRUS <- ­ATENCIàN!', 13, 10, 0
TXT_VirusFound1ok              db '    Ha sido sobreescrito, pero el sistema puede no iniciarse correctamente.', 13, 10
                               db '    Si ocurre esto, use su disco de sistema de AiR-BOOT.', 13, 10, 0
TXT_VirusFound1damn            db '    Desgraciadamente ha destruido la copia de seguridad de AiR-BOOT.', 13, 10
                               db '    Tiene que iniciar el sistema desde un disco de AiR-BOOT.', 13, 10, 0
TXT_VirusFound1any             db '    Por seguridad, deber¡a examinar el disco duro por si quedan restos.', 13, 10, 0
TXT_VirusFound2                db '    Est  en el registro de arranque de la partici¢n que quer¡a iniciar.', 13, 10
                               db '    Use un antivirus. Tambi‚n podr¡a ser una falsa alarma.', 13, 10
                               db '    Tras eliminarlo, debe reiniciar las variables de detecci¢n. Entre en', 13, 10
                               db '    ''CONFIGURAR PARTICIONES'' y desactive y reactivar la detecci¢n VIBR.', 13, 10
                               db '    Si esto ha sido una falsa alarma, d‚jela inactiva.', 13, 10, 0
TXT_VirusFoundEnd              db '    Sistema detenido. Pulse RESET.', 0
TXT_HowEnterSetup              db 13, 10, ' - Mantenga pulsado Ctrl o Alt para configurar AiR-BOOT.', 0

TXT_BootingNow1                db 'Iniciando en el sistema ', 0
; DO NOT MODIFY HERE
TXT_BootingNow2                db '''', 0
TXT_BootingNowPartName         db 12 dup (0) ; Space for BootThisPart-Name
; DO NOT MODIFY TILL HERE
TXT_BootingNowPartition        db ' (partici¢n)', 0
TXT_BootingNowKernel           db ' (kernel)', 0
TXT_BootingHide                db '; ocultando p. activa', 0
TXT_BootingWait                db '; por favor, espere...', 13, 10, 13, 10, 0

; FIXED LENGTH - 11 chars each string
;----------------------------------|---------|------------------------------
TXT_Floppy_NoName              db 'Sin nombre '
TXT_Floppy_Drive               db 'Disquete   '
TXT_Floppy_NoDisc              db 'Sin disco  '

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_PleaseEnterPassword        db ' Introduzca la contrase¤a:', 0
; the following 3 strings have to equal or *longer* than PleaseEnterPassword
TXT_ProtectedSystem            db '** SISTEMA PROTEGIDO POR CONTRASE¥A **', 0
TXT_ProtectedSetup             db '** CONFIGURACIàN PROTEGIDA POR CONTRASE¥A **', 0
TXT_ProtectedBootUp            db '** INICIO PROTEGIDO POR CONTRASE¥A **', 0

; will get completed using TXT_ERROR_CheckFailed from MBR.asm
TXT_ERROR_CheckConfig          db 13, 10, ' - La configuraci¢n', 0

;----------------------------------|----------------------------------------------------------|
TXT_TooManyTries               db 'Demasiados intentos. Sistema detenido.', 0
