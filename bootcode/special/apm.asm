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
;                                                    AiR-BOOT / APM SUPPORT
;---------------------------------------------------------------------------

IFDEF   MODULE_NAMES
DB 'APM',0
ENDIF

; Here is APM Code to turn off the computer
; Does not work on all BIOSes
; http://stackoverflow.com/questions/678458/shutdown-the-computer-using-assembly

APM_TurnOffComputer            Proc Near  Uses ax bx cx

IFDEF       AUX_DEBUG
            pusha
            mov     si, offset $+5
            jmp     @F
            db      10,'>> System Shutdown <<',10,0
@@:         call    AuxIO_Print
            popa
ENDIF

   mov     ax, 5301h
   xor     bx, bx
   int     15h
   mov     ax, 530Eh
   xor     bx, bx
   mov     cx, 102h
   int     15h
   mov     ax, 5307h
   mov     bx, 1
   mov     cx, 3
   int     15h
   ret                                   ; We should never return here <g>
APM_TurnOffComputer            EndP
