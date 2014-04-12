;
; OS/2 BLDLEVEL Information.
;


;
; The version values in here are derived from the AiR-BOOT versions
; as defined in VERSION.INC.
;

;
; For some reason JWasm and Tasm don't accept 'EN' for instance, but need
; it to be split-up. While 'iEN' does work. So all the strings that were not
; accepted are split-up.
;
; Changed langid to be just one letter in build-level, conforming to the
; AiR-BOOT signature.
;

; Vendor
BLDLVL_VENDOR           EQU     'KIEWITZ'
; Version
BLDLVL_MAJOR_VERSION    EQU     AB_MAJOR_VERSION    + '0'
BLDLVL_MIDDLE_VERSION   EQU     AB_MIDDLE_VERSION   + '0'
BLDLVL_MINOR_VERSION    EQU     AB_MINOR_VERSION    + '0'
; Build date
BLDLVL_YEAR             EQU     (AB_YEAR SHR 12 AND 0Fh)+'0',(AB_YEAR SHR 8 AND 0Fh)+'0',(AB_YEAR SHR 4 AND 0Fh)+'0',(AB_YEAR AND 0Fh)+'0'
BLDLVL_MONTH            EQU     (AB_MONTH SHR 4)+'0',(AB_MONTH AND 0Fh)+'0'
BLDLVL_DAY              EQU     (AB_DAY SHR 4)+'0',(AB_DAY AND 0Fh)+'0'
; Build time
BLDLVL_HOURS            EQU     (AB_HOURS SHR 4)+'0',(AB_HOURS AND 0Fh)+'0'
BLDLVL_MINUTES          EQU     (AB_MINUTES SHR 4)+'0',(AB_MINUTES AND 0Fh)+'0'
BLDLVL_SECONDS          EQU     (AB_SECONDS SHR 4)+'0',(AB_SECONDS AND 0Fh)+'0'
; Build machine
;BLDLVL_MACHINE          EQU     'ecs-devbox'
BLDLVL_MACHINE          EQU     '*UNKNOWN*'
; Build language
IFDEF   WASM
    ; Wasm can only process the reference to 'lang' in pass 2 because it comes
    ; from an included file which it has not processed yet at pass 1.
    IF2
        BLDLVL_LANGUAGE EQU     TXT_LanguageID
    ENDIF
; The other assemblers process 'lang' correctly in pass 1.
ELSE
    BLDLVL_LANGUAGE     EQU     TXT_LanguageID
ENDIF
; Description
BLDLVL_DESCRIPTION      EQU     'AiR-BOOT Boot Manager'



;~ bliep   struct
    ;~ db  '@#'
    ;~ db  BLDLVL_VENDOR
    ;~ db  ':'
    ;~ db  BLDLVL_MAJOR_VERSION
    ;~ db  '.'
    ;~ db  BLDLVL_MIDDLE_VERSION
    ;~ db  '.'
    ;~ db  BLDLVL_MINOR_VERSION
    ;~ db  '#@##1## '
;~ bld_level_date_start    db  BLDLVL_YEAR
    ;~ db  '/'
    ;~ db  BLDLVL_MONTH
    ;~ db  '/'
    ;~ db  BLDLVL_DAY
    ;~ db  ' '
    ;~ db  BLDLVL_HOURS
    ;~ db  ':'
    ;~ db  BLDLVL_MINUTES
    ;~ db  ':'
    ;~ db  BLDLVL_SECONDS
;~ bld_level_date_end    db  '      '
    ;~ db  BLDLVL_MACHINE
    ;~ db  '::'
    ;~ ; Wasm can only process the reference to 'lang' in pass 2 because it comes
    ;~ ; from an included file which it has not processed yet at pass 1.
    ;~ IFDEF   WASM
        ;~ IF2
            ;~ db  BLDLVL_LANGUAGE
        ;~ ENDIF
    ;~ ; The other assemblers process 'lang' correctly in pass 1.
    ;~ ELSE
        ;~ db  BLDLVL_LANGUAGE
    ;~ ENDIF
    ;~ db  '::'
    ;~ db  BLDLVL_MINOR_VERSION
    ;~ db  '::@@'
    ;~ db  BLDLVL_DESCRIPTION
    ;~ db  0
;~ bliep   ends


;
; This macro inserts the BLDLEVEL string at the place where it is invoked.
;
InsertBuildLevel    MACRO
    db  '@#'
    db  BLDLVL_VENDOR
    db  ':'
    db  BLDLVL_MAJOR_VERSION
    db  '.'
    db  BLDLVL_MIDDLE_VERSION
    db  '.'
    db  BLDLVL_MINOR_VERSION
    db  '#@##1## '
bld_level_date_start:
    db  BLDLVL_YEAR
    db  '/'
    db  BLDLVL_MONTH
    db  '/'
    db  BLDLVL_DAY
    db  ' '
    db  BLDLVL_HOURS
    db  ':'
    db  BLDLVL_MINUTES
    db  ':'
    db  BLDLVL_SECONDS
bld_level_date_end:
    db  '      '
    db  BLDLVL_MACHINE
    db  '::'
    ; Wasm can only process the reference to 'lang' in pass 2 because it comes
    ; from an included file which it has not processed yet at pass 1.
    IFDEF   WASM
        IF2
            db  BLDLVL_LANGUAGE
        ENDIF
    ; The other assemblers process 'lang' correctly in pass 1.
    ELSE
        db  BLDLVL_LANGUAGE
    ENDIF
    db  '::'
    db  BLDLVL_MINOR_VERSION
    db  '::@@'
    db  BLDLVL_DESCRIPTION
    db  0
ENDM

