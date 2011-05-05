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
; Some Standard macros to make life easier with ALP and other assemblers :D

MPush Macro reglist
   irp reg,<reglist>
      push    reg
   EndM
EndM

MPop Macro reglist
   irp reg,<reglist>
      pop     reg
   EndM
EndM

callfar Macro destination
   push    cs
   call    &destination
EndM

; Shortcuts for pointer-types
bptr                            equ   byte ptr
wptr                            equ   word ptr
dptr                            equ  dword ptr
qptr                            equ  qword ptr
tptr                            equ  tbyte ptr
