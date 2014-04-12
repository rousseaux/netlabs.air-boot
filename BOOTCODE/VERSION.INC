;
; AiR-BOOT Version Information.
;

;
; First we define the numeric (BCD) AiR-BOOT version information.
; This is used to derive ASCII and other representations.
;

; AiR-BOOT version conform WarpIN format with implicit 0 as fourth number.
; Note that the config-version is managed manually.
AB_MAJOR_VERSION    EQU     1
AB_MIDDLE_VERSION   EQU     0
AB_MINOR_VERSION    EQU     8

; The Year, Month and Day in BCD so we can easily extract nibbles.
AB_YEAR             EQU     2012h
AB_MONTH            EQU     04h
AB_DAY              EQU     21h

; The Hours, Minutes and Seconds, again in BCD for easy manipulation.
AB_HOURS            EQU     08h
AB_MINUTES          EQU     35h
AB_SECONDS          EQU     00h

; The AiR-BOOT signature uses big-endian so we shuffle some bits around.
AB_SIG_VERSION      EQU     (((AB_MIDDLE_VERSION SHL 4) OR AB_MINOR_VERSION) SHL 8) OR AB_MAJOR_VERSION
AB_SIG_YEAR         EQU     ((AB_YEAR SHR 8) OR (AB_YEAR SHL 8) AND 0FFFFh)
AB_SIG_DATE         EQU     (AB_MONTH SHL 8) OR AB_DAY


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
