;
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
AB_MONTH            EQU     09h
AB_DAY              EQU     09h

; The Hours, Minutes and Seconds, again in BCD for easy manipulation.
AB_HOURS            EQU     09h
AB_MINUTES          EQU     09h
AB_SECONDS          EQU     09h

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
