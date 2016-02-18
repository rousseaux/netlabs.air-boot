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

ifdef TXT_IncludeCyrillic
   ; Compressed Cyrillic 866 16x9 charset (1 counter-byte, followed by data)
  CHARSET_Cyrillic:
   dw 010A2h, 06C38h, 0C6C6h, 0C6FEh, 0C6C6h, 0A6C6h, 0C4FCh, 0C0C0h, 0C6FCh
   dw 0C6C6h, 0FCC6h, 0FCA6h, 0C6C6h, 0F8CCh, 0C6CCh, 0C6C6h, 0A6FCh, 0C2FEh
   dw 0C0C0h, 0C0C0h, 0C0C0h, 0C0C0h, 03EB6h, 03636h, 03636h, 06636h, 06666h
   dw 0C3FFh, 0FEA5h, 0C0C2h, 0F8C0h, 0C0C0h, 0C2C0h, 0A6FEh, 0D6D6h, 05454h
   dw 0547Ch, 05454h, 0D6D6h, 07CA6h, 086C6h, 03C06h, 00606h, 0C686h, 0A67Ch
   dw 0CEC6h, 0FEDEh, 0E6F6h, 0C6C6h, 0C6C6h, 06CC4h, 0C638h, 0DECEh, 0F6FEh
   dw 0C6E6h, 0C6C6h, 0A6C6h, 0C6C6h, 0D8CCh, 0F0F0h, 0CCD8h, 0C6C6h, 07EA6h
   dw 06666h, 06666h, 06666h, 0C666h, 0A6C6h, 0EEC6h, 0FEFEh, 0C6D6h, 0C6C6h
   dw 0C6C6h, 0C6A6h, 0C6C6h, 0FEC6h, 0C6C6h, 0C6C6h, 0A6C6h, 0C67Ch, 0C6C6h
   dw 0C6C6h, 0C6C6h, 07CC6h, 0FEA6h, 0C6C6h, 0C6C6h, 0C6C6h, 0C6C6h, 0A6C6h
   dw 0C6FCh, 0C6C6h, 0FCC6h, 0C0C0h, 0C0C0h, 03CA6h, 0C266h, 0C0C0h, 0C0C0h
   dw 066C2h, 0A63Ch, 05A7Eh, 01818h, 01818h, 01818h, 01818h, 0C6A6h, 0C6C6h
   dw 06EC6h, 0383Ch, 0E070h, 0A6C0h, 01038h, 0D67Ch, 09292h, 07CD6h, 03810h
   dw 0C6A6h, 06CC6h, 0387Ch, 07C38h, 0C66Ch, 0C6C6h, 0CCCCh, 0CCCCh, 0CCCCh
   dw 0CCCCh, 0FCCCh, 00606h, 0C6A4h, 0C6C6h, 0C6C6h, 006FEh, 00606h, 0A606h
   dw 0D6D6h, 0D6D6h, 0D6D6h, 0D6D6h, 0FED6h, 0D6C6h, 0D6D6h, 0D6D6h, 0D6D6h
   dw 0D6D6h, 006FEh, 0A406h, 0B0F0h, 03CB0h, 0333Eh, 03333h, 03C3Eh, 0C3A6h
   dw 0C3C3h, 0FBF3h, 0CBCBh, 0FBCBh, 0A6F3h, 06060h, 07860h, 0667Ch, 06666h
   dw 0787Ch, 078A6h, 086CCh, 03E06h, 00606h, 0CC86h, 0A678h, 0DFCEh, 0DBDBh
   dw 0FBFBh, 0DBDBh, 0CEDFh, 03EA6h, 0C666h, 03E66h, 06636h, 0C666h, 079C6h
   dw 0063Ch, 0663Eh, 06666h, 0A63Ah, 07C04h, 0F8C0h, 0CCCCh, 0CCCCh, 078CCh
   dw 07C79h, 06666h, 0667Ch, 07C66h, 07E79h, 06062h, 06060h, 06060h, 03C89h
   dw 02C2Ch, 04C6Ch, 07C4Ch, 078C6h, 0663Ch, 07E66h, 06660h, 0793Ch, 054D6h
   dw 0387Ch, 0547Ch, 079D6h, 0C67Ch, 03C06h, 0C606h, 0797Ch, 0CEC6h, 0F6DEh
   dw 0C6E6h, 0A6C6h, 03828h, 0C610h, 0DECEh, 0E6F6h, 0C6C6h, 06679h, 0786Ch
   dw 06C78h, 06666h, 03E79h, 03636h, 03636h, 06676h, 0C679h, 0FEEEh, 0C6D6h
   dw 0C6C6h, 06679h, 06666h, 0667Eh, 06666h, 03C79h, 06666h, 06666h, 03C66h
   dw 07E79h, 06666h, 06666h, 06666h, 09504h
   db 07Ch
   dw 06666h, 06666h, 0607Ch, 06060h, 03E77h, 06062h, 06060h, 03E62h, 07E79h
   dw 01818h, 01818h, 01818h, 06699h, 06666h, 03E66h, 0181Ch, 06070h, 03886h
   dw 07C10h, 0D6D6h, 0107Ch, 07938h, 06CC6h, 03838h, 06C38h, 099C6h, 0CCCCh
   dw 0CCCCh, 0CCCCh, 006FEh, 07706h, 0C6C6h, 0C6C6h, 006FEh, 07906h, 0D6D6h
   dw 0D6D6h, 0D6D6h, 099FEh, 0D6D6h, 0D6D6h, 0D6D6h, 006FEh, 07706h, 0B0F0h
   dw 03CB0h, 03636h, 0793Ch, 0C6C6h, 0F6C6h, 0D6D6h, 079F6h, 06060h, 07860h
   dw 06C6Ch, 07978h, 0663Ch, 00E06h, 06606h, 0793Ch, 0D6CCh, 0F6D6h, 0D6D6h
   dw 079CCh, 0663Eh, 03E66h, 06636h, 00466h
endif
