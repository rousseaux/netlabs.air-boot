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
; If the EQU below is enabled, the testbuild color-scheme will be used.
;
TESTBUILD           EQU

; COLORS basic
; 0 = black
; 1 = blue
; 2 = green
; 3 = cyan
; 4 = red
; 5 = magenta
; 6 = brown
; 7 = white
; 8 = grey

; COLORS all (fg)
; 00h black
; 10h blue
; 20h green (also nice)
; 30h cyan (also nice)
; 40h red
; 50h magenta
; 60h brown (nice)
; 70h white
; 80h grey
; 90h light blue (nice)
; a0h bright green
; b0h bright cyan
; c0h bright red
; d0h bright magenta
; e0h bright yellow
; f0h bright white

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
AB_MIDDLE_VERSION   EQU     1
AB_MINOR_VERSION    EQU     1

; The Year, Month and Day in BCD so we can easily extract nibbles.
AB_YEAR             EQU     2017h
AB_MONTH            EQU     03h
AB_DAY              EQU     20h

; The Hours, Minutes and Seconds, again in BCD for easy manipulation.
;~ AB_HOURS            EQU     01h
;~ AB_MINUTES          EQU     01h
;~ AB_SECONDS          EQU     01h
AB_HOURS            EQU     23h
AB_MINUTES          EQU     59h
AB_SECONDS          EQU     59h

; The AiR-BOOT signature uses big-endian so we shuffle some bits around.
AB_SIG_VERSION      EQU     (((AB_MIDDLE_VERSION SHL 4) OR AB_MINOR_VERSION) SHL 8) OR AB_MAJOR_VERSION
AB_SIG_YEAR         EQU     ((AB_YEAR SHR 8) OR (AB_YEAR SHL 8) AND 0FFFFh)
AB_SIG_DATE         EQU     (AB_MONTH SHL 8) OR AB_DAY

