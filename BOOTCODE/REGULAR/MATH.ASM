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
;                                                           AiR-BOOT / MATH
;---------------------------------------------------------------------------


; ----------------------
; Rousseau: # MATH.ASM #
; ----------------------
; This module contains 32-bit multiply.
; Other math-stuff should be placed here.


IFDEF ModuleNames
DB 'MATH',0
ENDIF

; Multiply two 32-bit operands
; In:          DX:AX - operand 1
;              BX:CX - operand 2
; Out:         BX:CX:DX:AX 64-bit result
MATH_Mul32     Proc  Near
      local    p3:word
      local    p2:word
      local    p1:word
      local    p0:word
      local    fb1:word
      local    fb0:word
      local    fa1:word
      local    fa0:word

      ; Save parameters
      mov      [fb1],bx
      mov      [fb0],cx
      mov      [fa1],dx
      mov      [fa0],ax

      ; Clear return value
      xor      ax,ax
      mov      [p3],ax
      mov      [p2],ax
      mov      [p1],ax
      mov      [p0],ax

      ; Multiply high words
      mov      ax,[fa1]
      mul      [fb1]
      mov      [p2],ax
      mov      [p3],dx

      ; Multiply high with low
      mov      ax,[fa1]
      mul      [fb0]
      add      [p1],ax
      adc      [p2],dx
      adc      [p3],0


      ; Multiply low with high
      mov      ax,[fa0]
      mul      [fb1]
      add      [p1],ax
      adc      [p2],dx
      adc      [p3],0

      ; Multiply low words
      mov      ax,[fa0]
      mul      [fb0]
      mov      [p0],ax
      add      [p1],dx
      adc      [p2],0
      adc      [p3],0

      ; Return value BX:CX:DX:AX is QWORD result
      mov      bx,[p3]
      mov      cx,[p2]
      mov      dx,[p1]
      mov      ax,[p0]

      ret
MATH_Mul32     Endp
