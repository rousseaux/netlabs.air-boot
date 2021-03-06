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
;                                               AiR-BOOT / CYRILLIC CHARSET
;---------------------------------------------------------------------------


; Check if extended glyphs need to be loaded.
; Both use a different algorithm because for ES only one char is needed while
; for RU the cyrillic chars are loaded. Code is 'bootcode/special/charset.asm'.
IFDEF TXT_LoadCharset

; Spanish (cp850)
IF  BLD_LANG_TXT EQ 'es'
	include charset-es.asm
ENDIF

; Russian (cp866)
IF  BLD_LANG_TXT EQ 'ru'
   include charset-ru.asm
ENDIF

ENDIF
