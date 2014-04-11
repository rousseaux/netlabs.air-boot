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


;
; An ORG directive resets the location counter where code and data is
; generated. If the location counter is reset back to a point where
; code or data already has been generated, this will be overwritten
; without warning.
; This macro can be used with every ORG directive to check for this condition,
; and when it occurs further assembly is terminated.

; NOTE:  Overlapchecking in JWasm is not as reliable as in Tasm.
;        Because it's a single pass assembler, the current location can be
;        incorrect. Tasm with multiple passes works correct.
; FIXME: Get JWasm and Tasm use some common ECHO/%OUT method.
;        (Tasm only pases first word of non-quoted string to a macro)
check_overlap   MACRO   loc

    ; Exit macro immediately if no overlap.
    ; We don't want to assign values to z_last_... if there is no
    ; overlap because they would then hold the values the last time this
    ; macro was called and not those of the last overlap.
    IF (loc - $) LE 0
    ;~ IF ($ - loc) GE 0
        EXITM
    ENDIF

    ; Calculate the overlap.
    z_last_overlap_size = (loc - $)
    z_last_overlap_location = loc - z_last_overlap_size

    IFDEF   JWASM
        ; Output message.
        ECHO
        ECHO ** ERROR: LOCATION OVERLAP DETECTED [JWASM] ! **
        ECHO .         THIS IS MOST LIKELY CAUSED BY CODE / DATA
        ECHO .         EXPANSION TOWARDS AN 'ORG' DIRECTIVE.
        ECHO .         LOOK AT 'z_last_overlap_location' TO SEE WHERE.
        ECHO .         LOOK AT 'z_last_overlap_size' TO SEE SIZE.
        ECHO .         FORCING ERROR...
        ECHO
    ENDIF
    IFDEF   TASM
        IF2
            ; Output message (only on pass2).
            %OUT
            %OUT ** ERROR: LOCATION OVERLAP DETECTED [TASM] ! **
            %OUT .         THIS IS MOST LIKELY CAUSED BY CODE / DATA
            %OUT .         EXPANSION TOWARDS AN 'ORG' DIRECTIVE.
            %OUT .         LOOK AT 'z_last_overlap_location' TO WHERE.
            %OUT .         LOOK AT 'z_last_overlap_size' TO SEE SIZE.
            %OUT .         FORCING ERROR...
            %OUT
        ENDIF
    ENDIF

    ; Terminate assembly by forcing an error.
    .ERR

ENDM


; Shortcuts for pointer-types
bptr                             equ   byte ptr
wptr                             equ   word ptr
dptr                             equ  dword ptr
qptr                             equ  qword ptr
tptr                             equ  tbyte ptr


sector_size                      equ   512
image_size_60secs                equ   7800h
image_size_62secs                equ   7c00h

;image_size                       equ   image_size_60secs
image_size                       equ   image_size_62secs

sector_count                     equ   image_size / sector_size                  ; Image size in sectors

IF image_size EQ image_size_60secs
   partition_count               equ   30                                        ; Maximum number of partitions supported
ELSE
   partition_count               equ   45                                        ; Maximum number of partitions supported
ENDIF
