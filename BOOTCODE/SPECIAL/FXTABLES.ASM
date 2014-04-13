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
;                                                     AiR-BOOT / F/X TABLES
;---------------------------------------------------------------------------

IFDEF   MODULE_NAMES
DB 'FXTABLES',0
ENDIF

; Sinus-Table - 128xWORD = 256 Bytes
FX_SinusTab dw 00101h, 00102h, 00103h, 00105h, 00107h, 0010Ah, 0010Dh, 00111h
    dw 00115h, 00119h, 0011Dh, 00122h, 00127h, 0012Dh, 00133h, 00139h, 00140h
    dw 00146h, 0014Dh, 00155h, 0015Ch, 00164h, 0016Bh, 00173h, 0017Bh, 00184h
    dw 0018Ch, 00194h, 0019Dh, 001A5h, 001AEh, 001B7h, 001BFh, 001C8h, 001D0h
    dw 001D8h, 001E1h, 001E9h, 001F1h, 001F8h, 00200h, 00207h, 0020Fh, 00216h
    dw 0021Ch, 00223h, 00229h, 0022Fh, 00235h, 0023Ah, 0023Fh, 00243h, 00247h
    dw 0024Bh, 0024Fh, 00252h, 00255h, 00257h, 00259h, 0025Ah, 0025Bh, 0025Ch
    dw 0025Ch, 0025Ch, 0025Bh, 0025Ah, 00259h, 00257h, 00255h, 00252h, 0024Fh
    dw 0024Bh, 00247h, 00243h, 0023Fh, 0023Ah, 00235h, 0022Fh, 00229h, 00223h
    dw 0021Ch, 00216h, 0020Fh, 00207h, 00200h, 001F8h, 001F1h, 001E9h, 001E1h
    dw 001D8h, 001D0h, 001C8h, 001BFh, 001B7h, 001AEh, 001A5h, 0019Dh, 00194h
    dw 0018Ch, 00184h, 0017Ch, 00173h, 0016Bh, 00164h, 0015Ch, 00155h, 0014Dh
    dw 00146h, 00140h, 00139h, 00133h, 0012Dh, 00128h, 00122h, 0011Dh, 00119h
    dw 00115h, 00111h, 0010Dh, 0010Ah, 00107h, 00105h, 00103h, 00102h, 00101h
    dw 00100h, 00100h, 00100h

; Top-VLine-Position of all Cooper-Bars on startup
FX_StartCooperPos:
    dw 224, 221, 218, 215, 212, 209, 206
