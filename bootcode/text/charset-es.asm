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
;                                                  AiR-BOOT / SPANISH CHARS
;---------------------------------------------------------------------------


; Glyphs from CP850 -- row layout: code-point, remap-to-point, byte[16] glyph-rows
CHARSET_Spanish:
    db 003h                                                                                             ; Number of glyphs in this table
    db 0b5h,0d9h,060h,0c0h,010h,038h,06ch,0c6h,0c6h,0feh,0c6h,0c6h,0c6h,0c6h,000h,000h,000h,000h        ; A with accent  (original remapped to 0xd9)
    db 0d6h,000h,00ch,018h,000h,03ch,018h,018h,018h,018h,018h,018h,018h,03ch,000h,000h,000h,000h        ; I with accent  (no remapping needed)
    db 0e0h,000h,018h,030h,000h,07ch,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,07ch,000h,000h,000h,000h        ; O with accent  (no remapping needed)
