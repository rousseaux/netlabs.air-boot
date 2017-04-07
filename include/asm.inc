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

; Macro to show some text when using debugging.
; Possibly a register dump is done after this code, so we save and restore
; the flags too.
DBG_TEXT_OUT_AUX   MACRO   txt
        local   skip00              ; macro local jump labels
        local   txt00               ; macro local storage definitions
        jmp     skip00              ; jump over the string
txt00   db      10,txt,10,0         ; macro text-string parameter inserted here
    skip00:
        pushf                       ; save flags
        push    si                  ; used to print the string
        mov     si, offset [txt00]  ; address of the string
        call    AuxIO_Print         ; output to serial port
        pop     si                  ; restore previous value
        popf                        ; restore flags
ENDM

; Push CPU working context
PUSHRF  MACRO
        pusha
        pushf
ENDM

; Restore CPU working context
POPRF   MACRO
        popf
        popa
ENDM

; Push CPU working context including DS and ES
PUSHRSF MACRO
        pusha
        push    ds
        push    es
        pushf
ENDM

; Restore CPU working context including DS and ES
POPRSF  MACRO
        popf
        pop     es
        pop     ds
        popa
ENDM

; Rousseau:
; My editor (Geany) keeps auto-completing 'call' to 'callfar' because
; of this definition. Since it's not used anywhere I disabled it.
;~ callfar Macro destination
   ;~ push    cs
   ;~ call    &destination
;~ EndM


;
; OLD OVERLAP CHECKER, DOES NOT WORK WELL WITH JWASM.
;
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


;
; A normal ORG directive resets the location counter where code and data is
; going to be emitted. If the location counter is reset back to a point
; where code or data already has been emitted, this will be overwritten
; without warning.
; This macro does a check for this condition and aborts if it exists.
; If there is space between the new location and the last emitted code or data
; it will be filled with a filler-value defined in this macro..
;
; There are differences between assemblers on when and how labels and values
; are evaluated. Since JWasm is a single-pass assembler, some expressions
; do not work that do work in multi-pass Tasm.
; That's why the actual check for overlap is done by db getting a negative
; value if an overlap occured.
; Don't change the (after - before) expression to a pre-calculated label
; because that won't work and will break this macro.
;
ORIGIN  MACRO   loc
    ;~ IFDEF   JWASM
        ;~ db  (@F - $)   dup('X')
        ;~ ORG     loc
        ;~ @@:
    ;~ ENDIF

    ; Use this value to fill the gap between the new origin and the last
    ; emitted code or data.
    IFDEF   AUX_DEBUG
        fillchar = '#'
    ELSE
        fillchar = 0
    ENDIF

    ; Mark the location of the last emitted code or data.
    z_&loc&_1before:

    ; JWasm can do db 0 dup (0).
    ; Using db dup() causes JWasm to recognize the after label so that
    ; overlap calculations are correct.
    IFDEF   JWASM
        db  (z_&loc&_2after - z_&loc&_1before)   dup(fillchar)
    ENDIF

    ; Tasm cannot do db 0 dup(0), so we exclude that condition.
    ; Overlap checking could be done differently in Tasm but to keep things
    ; easy the JWasm method above is used.
    IFDEF   TASM
        IF (z_&loc&_2after - z_&loc&_1before) NE 0
            db  (z_&loc&_2after - z_&loc&_1before)   dup(fillchar)
        ENDIF
    ENDIF

    ; Masm can also do db 0 dup (0), and it does calculate correctly
    ; but cannot find the after label.
    ; Same issue as with JWasm but the db construct does not solve it for Masm.
    ; The label-values show-up to be correct in the listing though.
    ; Currently overlap-checking is disabled when assembling with Masm !
    ; FIXME: Find a solution for Masm.
    IFDEF   MASM
        ;~ db  (z_&loc&_2after - z_&loc&_1before)   dup(fillchar)
        ECHO ** Warning: Overlap Check on: loc not performed !
    ENDIF

    ; Wasm can also do db 0 dup (0), but it complains about brackets or so.
    ; Seems to be some syntax issue.
    ; It cannot generate a list-file so values cannot be checked.
    ; It does not even support ECHO so no warning can be given.
    ; So overlap-checking is disabled when assembling with Wasm !
    ; FIXME: Find a solution for Wasm.
    IFDEF   WASM
        ; NOT EVEN ECHO IS SUPPORTED !
        ;~ db  (z_&loc&_2after - z_&loc&_1before)   dup(fillchar)
    ENDIF

    ; Set the new origin.
    ORG     loc

    ; Mark the new location.
    z_&loc&_2after:

    ; Calculate the gap.
    z_&loc&_3gap = z_&loc&_2after - z_&loc&_1before

    ;
    ; Note that the variables are prefixed with z_ so they appear
    ; at the end of the list-file.
    ;
ENDM


;
; This macro inserts the AiR-BOOT signature at the place where it is invoked.
;
InsertAirbootSignature  MACRO   lang
    db      'AiRBOOT'
    dw      AB_SIG_DATE
    dw      AB_SIG_YEAR
    dw      AB_SIG_VERSION
    ; Wasm can only process the reference to 'lang' in pass 2 because it comes
    ; from an included file which it has not processed yet at pass 1.
    IFDEF   WASM
        IF2
            db      lang
        ENDIF
    ; The other assemblers process 'lang' correctly in pass 1.
    ELSE
        db      lang
    ENDIF
ENDM


; Shortcuts for pointer-types
bptr                             equ   byte ptr
wptr                             equ   word ptr
dptr                             equ  dword ptr
qptr                             equ  qword ptr
tptr                             equ  tbyte ptr


sector_size                      equ   512      ; Normal size of a sector.
image_size_60secs                equ   7800h    ; Size of the pre v1.07 image.
image_size_62secs                equ   7c00h    ; Size of the post v1.06 image.

;image_size                       equ   image_size_60secs
image_size                       equ   image_size_62secs

; Image size in sectors
sector_count                     equ   image_size / sector_size

IF image_size EQ image_size_60secs
    ; Maximum number of partitions supported in pre v1.07.
   max_partitions                equ   30
ELSE
    ; Maximum number of partitions supported in post v1.06.
   max_partitions                equ   45
ENDIF
