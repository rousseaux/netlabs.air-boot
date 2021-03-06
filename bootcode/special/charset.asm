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
;                                                AiR-BOOT / CHARSET SUPPORT
;---------------------------------------------------------------------------

; This file is only included, when compiling versions that are meant to
;  contain special characters that are not included in the Video ROM charset.



; We are building for Spanish so enable simple glyph injection for a few CP850 glyphs
IF  BLD_LANG_TXT EQ 'es'

; -----------------------------------------------------------------------------
; Load the glyphs used for Spanish into the video-system
; -----------------------------------------------------------------------------
; Spanish actually currently only uses codepoint 0xb5 from CP850.
; However, in CP437, which is used by the BIOS, 0xb5 is a box-char and used for
; building the menus. This function remaps stuff so the 0xb5 glyph from CP850
; can be displayed.
; -----------------------------------------------------------------------------
CHARSET_IncludeSpanish  Proc Near

        pusha

        ; First we get the ROM charset from BIOS...
        call    CHARSET_GetRomGlyphs

        ; Pointer to table with glyphs using simple injection format
        mov     si, offset CHARSET_Spanish

        ; Load nr of glyphs to process in CL
        cld
        lodsb
        mov     cl,al
        xor     ch,ch

    CHARSET_IncludeSpanish_NextGlyph:
        lodsw                   ; AL=code-point, if AH<>0 then backup-point
        test    ah,ah           ; Copy glyph to backup-point ?
        jz      CHARSET_IncludeSpanish_NoBackup

        ; Backup glyph to other code-point so it can be used
        push    cx              ; Save glyph counter
        push    si              ; Save glyph pointer
        mov     si,offset CharsetTempBuffer
        mov     di,si
        mov     dl,al           ; Glyph code-point
        xor     dh,dh
        shl     dx,4            ; Index in table assuming 16 scan-lines
        add     si,dx           ; Make SI point to it
        mov     dl,ah           ; Glyph code-point (backup)
        xor     dh,dh
        shl     dx,4            ; Index in table assuming 16 scan-lines
        add     di,dx           ; Make DI point to it (backup)
        mov     cx,16           ; Each byte is a scan-line
        rep     movsb           ; Backup the glyph
        pop     si              ; Restore glyph pointer
        pop     cx              ; Restore glyph counter

    CHARSET_IncludeSpanish_NoBackup:
        mov     di,offset CharsetTempBuffer
        mov     dl,al           ; Glyph code-point
        xor     dh,dh
        shl     dx,4            ; Index in table assuming 16 scan-lines
        add     di,dx           ; Make DI point to glyph to be replaced
        push    cx              ; Save glyph counter
        mov     cx,16           ; Each byte is a scan-line
        rep     movsb           ; Insert the new glyph
        pop     cx
        loop    CHARSET_IncludeSpanish_NextGlyph   ; Next glyph if any

        ; Upload the custom charset to the video-adapter
        call  CHARSET_SetCutsomGlyphs

        popa
        ret
CHARSET_IncludeSpanish  EndP

ENDIF


; We are building for Russian so enable compressed glyph injection to load the CP866 glyphs
IF  BLD_LANG_TXT EQ 'ru'

; -----------------------------------------------------------------------------
; Load the glyphs used for Russian into the video-system
; -----------------------------------------------------------------------------
; Russian uses the Cyrillic glyphs from CP866.
; CP866 is box-char compatible with CP437, which is used by the BIOS, so only
; the Cyrillic glyps are overlaid the CP437 glyphs.
; -----------------------------------------------------------------------------
CHARSET_IncludeCyrillic        Proc Near

        pusha

        ; First we get the ROM charset from BIOS...
        call    CHARSET_GetRomGlyphs

        ; Pointer to table with glyphs using compressed format
        mov     si, offset CHARSET_Cyrillic
        mov     di, offset CharsetTempBuffer+2048

        mov     dl, 64          ; Decode 64 character bitmaps
        xor     al, al
        xor     ch, ch
    DecodeLoop:                 ; This is an uncompressing-loop
        mov     ah, ds:[si]
        inc     si
        mov     cl, ah
        and     cl, 0Fh
        rep     stosb           ; Write NULs, count: lower 4 bits
        mov     cl, ah
        shr     cl, 4
        or      cl, cl
        jz      EndOfStream
        rep     movsb
        jmp     DecodeLoop
    EndOfStream:
        cmp     di, offset CharsetTempBuffer+3840
        jae     DecodeDone
        add     di, 768         ; Skip 3x16 char blocks
        jmp     DecodeLoop

    DecodeDone:
        ; Upload the custom charset to the video-adapter
        call    CHARSET_SetCutsomGlyphs

        popa
        ret
CHARSET_IncludeCyrillic        EndP

ENDIF



; -----------------------------------------------------------------------------
; Get the standard CP437 glyphs from the video-bios -- (400 scanlines version)
; -----------------------------------------------------------------------------
; Returns ES:BP pointer to charset (in Video-ROM)
; http://www.ctyme.com/intr/rb-0158.htm
; -----------------------------------------------------------------------------
CHARSET_GetRomGlyphs    Proc
        mov     ax, 1130h
        mov     bh, 6               ; Get ROM VGA 25x80 charset
        int     10h                 ; VIDEO BIOS: Get charset table pointer
        mov     bx, ds
        mov     ax, es
        mov     es, bx              ; ES now points to Data-Segment      (dest)
        mov     ds, ax              ; DS now points to Video-ROM          (src)
        mov     si, bp              ; SI now points to ROM Font 25x80
        mov     di, offset CharsetTempBuffer    ; Located in BSS
        mov     cx, 2048
        rep     movsw               ; Copy ROM-charset to Temp-Buffer in BSS
        mov     ds, bx              ; Restore DS (DS==ES==CS)
        ret
CHARSET_GetRomGlyphs    EndP



; -----------------------------------------------------------------------------
; Set the custom glyphs for the video-adapter assuming 400 scanlines
; -----------------------------------------------------------------------------
; rousseau.comment.201807071938 :: Changed call from 0x1110 to 0x1100
; On a HP Pavilion dv9000 laptop, when pressing TAB to switch to preboot-menu,
; the text did not start at 0,0 anymore but was moved some 50 odd characters
; to the right. However, the preboot-menu was displayed correctly during the
; scanning phase, so the quirk occurred when the preboot-menu was moved to the
; second video-page. Information from Ralph Brown does state that for 0x1110h
; video-page 0 needs to be active, which might not be the case when the custom
; glyphs are loaded. Switching to 0x1100 solves the problem on the HP Pavilion
; and the other test-laptop, which did not have this quirk, still works fine.
; That leaves the question why 0x1110 was chosen by Martin in the first place.
; http://www.ctyme.com/intr/rb-0136.htm  <!-- 0x1100 -->
; http://www.ctyme.com/intr/rb-0143.htm  <!-- 0x1110 ~~ video page 0 remark -->
; -----------------------------------------------------------------------------
CHARSET_SetCutsomGlyphs Proc
IFDEF FX_ENABLED
        call    FX_WaitRetrace      ; Wait for retrace to reduce flickering
ENDIF
        ;~ mov     ax, 1110h           ; Works quirky on HP Pavilion dv9000
        mov     ax, 1100h           ; Works OK on HP Pavilion dv9000
        mov     bh, 16
        xor     bl, bl
        mov     cx, 0FFh
        xor     dx, dx
        mov     bp, offset CharsetTempBuffer    ; ES:BP - New charset
        int     10h                 ; VIDEO BIOS: Set new charset table
        mov     ah, 12h
        mov     bl, 30h
        mov     al, 2               ; 400 ScanLines
        int     10h                 ; VIDEO BIOS: Set Scanlines
        ret
CHARSET_SetCutsomGlyphs EndP
