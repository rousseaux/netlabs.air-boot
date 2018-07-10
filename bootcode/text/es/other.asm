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
TXT_Floppy_Drive               db 'Disquetera '
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

;
; Strings used in the pre-MENU screen
;
DisksFound          db "Discos Encontrados      : ",0
PartitionsFound     db "Particiones Encontradas : ",0
Phase1              db "Fase 1 Instalaci¢n OS/2 : ",0
TABMessage          db "Pulse TAB para volver al men£ de AiR-BOOT",0
PREPMessage         db "Preparando Men£ de Inicio...",0
Yes                 db "SÖ",0
No                  db "NO",0
;~ On                  db "SÖ",0
;~ Off                 db "NO",0
;~ None                db "NINGUNO",0
;~ Active              db "ACTIVA",0
;~ NotActive           db "NO ACTIVA",0
;~ AutoStartPart       db "Autoiniciar Partici¢n: ",0

; Label positions for disk information in preboot-menu
VideoIO_DisplayDiskInfo_labpos  db  0, 6, 19, 28, 37, 47, 56, 61, 71

; Label names for disk information in preboot-menu
VideoIO_DisplayDiskInfo_labels  db  'DISCO '
                                db  'SECTORES_LBA '
                                db  'TAM¥SEC  '
                                db  'GEO_I13  '
                                db  'GEO_I13X  '
                                db  'GEO_LVM  '
                                db  'BUS  '
                                db  'INTERFAZ  '
                                db  'EXTRAÖBLE'
                                db  0

TXT_SETUP_NoEditType35      db 'Imposible cambiar etiqueta de partici¢n de datos LVM', 0
TXT_SETUP_NoBootType35      db 'Imposible hacer arrancables particiones de datos LVM', 0
TXT_BootMenuPowerOff        db 'SUPR para apagar', 0
TXT_NoINT13XSupport         db 'Esta BIOS no soporta funciones INT13h extendidas', 0
;~ TXT_ERROR_TooManyPartitions db '­Demasiadas particiones - Funcionamiento no garantizado!', 0

; MBR protection; should also be translated and moved.
NonMBRwrite     db  '­­AiR-BOOT INTENTà ESCRIBIR A DISCO ALGO QUE NO ES UN MBR!!',0
NonMBRwrite_rep db  'Por favor, informe de esto a rousseau.os2dev@gmx.com',0
SystemHalted    db  'Sistema detenido',0

; Build Information string.
build_date      db  'Compilaci¢n: ',0
scanning_txt    db  'Explorando...',0

; Colors for special words hard-coded. Keep all 0s.
TXT_SETUP_LowerMessage      db 'Este programa se publica bajo licencia ', 0, 'GPLv3+', 0
                            db 'http://lslspanish.github.io/translation_GPLv3_to_spanish', 0
                            db 'Para m s informaci¢n y el c¢digo fuente, por favor visite:', 0
                            db 'http://svn.netlabs.org/air-boot', 0
                            db 'Correo electr¢nico: ', 0, 'rousseau.os2dev@gmx.com', 0

; Drive-Letter indication for OS/2 partitions
dl_text     db  '   en unidad ',0
dl_hidden   db  '   oculta    ',0

; Displayed above SETUP Menu
SETUP_UpperFixString        db 'CONFIGURACIàN DE AiR-BOOT ',0
