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
;                                                    AiR-BOOT / AUXILARY I/O
;---------------------------------------------------------------------------


; -----------------------
; Rousseau: # AUXIO.ASM #
; -----------------------
; Output some stuff to the serial port.
; The aux parameters in the MBR must be initialized for this.
; Lower byte is com-port, 0=disabled, 1=com1, etc.
; High byte is initialization; see below. (0e3h)

IFDEF   MODULE_NAMES
DB 'AUXIO',0
ENDIF

; Initialize the com-port, but only when logging is enabled.
; It get's it's parameters from the value in the MBR.
; Out:         AX - line status
AuxIO_Init      Proc  Near  Uses dx si
        ; bits 7-5 = datarate   (000=110,001=150,010=300,011=600,100=1200,101=2400,110=4800,111=9600 bps)
        ; bits 4-3 = parity     (00 or 10 = none, 01 = odd, 11 = even)
        ; bit  2   = stop-bits  (set = 2 stop-bits, clear = 1 stop-bit)
        ; bits 1-0 = data-bits  (00 = 5, 01 = 6, 10 = 7, 11 = 8)
        ; mov      [BIOS_AuxParms],ax             ; save initialization and port
        mov     dx,[BIOS_AuxParms]            ; DL=port, 0=disabled, 1=com1; DH=config-parms
        test    dl,dl                         ; see if logging is enabled, if not, skip initialization
        jz      AuxIO_Init_NoLogging

        dec     dl                            ; adjust port-number
        and     dl,03h                        ; 3 is max value

        ; Initialization message
        mov     si,offset AuxInitMsg
        call    MBR_Teletype

        ; Port number
        call    VideoIO_SyncPos
        mov     al,dl
        inc     al
        call    VideoIO_PrintByteDynamicNumber
        xor     si,si
        call    MBR_TeletypeNL

        ; Do the initialization
        mov     al,dh                         ; initialization parameters to al
        mov     dh,0                          ; DX now contains port-number
        mov     ah,0
        int     14h                           ; intialize com-port
    AuxIO_Init_NoLogging:
        ret
AuxIO_Init      EndP


;
; Send the Build Information to the COM-port.
;
AuxIO_PrintBuildInfo    Proc    Near    Uses ax cx si di
        ; Print header.
        mov     si, offset build_info
        call    AuxIO_Print

        ; Prepare info in temorary buffer.
        mov     si,offset bld_level_date_start
        mov     cx,offset bld_level_date_end
        sub     cx,si
        mov     di,offset Scratch
        cld
        rep     movsb

        ; Fill spaces until assembler specification.
        mov     al,' '
        mov     cx,37
        rep     stosb

        ; Copy assembler specification.
    IFDEF       JWASM
        mov     al,'['
        stosb
        mov     si,offset jwasm_txt
    ELSEIFDEF   TASM
        mov     al,' '
        stosb
        mov     al,'['
        stosb
        mov     si,offset tasm_txt

    ELSEIFDEF   WASM
        mov     al,' '
        stosb
        mov     al,'['
        stosb
        mov     si,offset wasm_txt
    ELSEIFDEF   MASM
        mov     al,' '
        stosb
        mov     al,'['
        stosb
        mov     si,offset masm_txt
    ELSE
        mov     al,' '
        stosb
        mov     al,'['
        stosb
        mov     si,offset unknown_txt
    ENDIF

    AuxIO_PrintBuildInfo_a1:
        lodsb
        test    al,al
        jz      AuxIO_PrintBuildInfo_e1
        stosb
        jmp     AuxIO_PrintBuildInfo_a1
    AuxIO_PrintBuildInfo_e1:
        mov     al,']'
        stosb

        ; Insert NULL Terminator.
        xor     al,al
        stosb

        ; Print Info.
        mov     si, offset Scratch
        call    AuxIO_Print
        call    AuxIO_TeletypeNL

        ; OS/2 BLDLEVEL information.
        mov     si, offset bld_level
        call    AuxIO_Print
        call    AuxIO_TeletypeNL

        ret
AuxIO_PrintBuildInfo    EndP


; Print char to com-port (teletype style)
AuxIO_Teletype  Proc     Near  Uses  ax dx


    ;~ pusha
    ;~ xor     dx,dx
    ;~ mov     ah,03h
    ;~ mov     al,00h
    ;~ int     14h
    ;~ mov     ah,al
    ;~ shr     al,4
    ;~ and     al,0fh
    ;~ add     al,'0'
    ;~ cmp     al,'9'
    ;~ jbe     @F
    ;~ add     al,7
;~ @@: push    ax
    ;~ xor     dx,dx
    ;~ mov     ah,01h
    ;~ int     14h
    ;~ pop     ax
    ;~ mov     al,ah
    ;~ and     al,0fh
    ;~ add     al,'0'
    ;~ cmp     al,'9'
    ;~ jbe     @F
    ;~ add     al,7
;~ @@: xor     dx,dx
    ;~ mov     ah,01h
    ;~ int     14h
    ;~ popa

        ;~ pusha
;~ @@:
        ;~ xor     dx,dx
        ;~ mov     ah,03h
        ;~ mov     al,00h
        ;~ int     14h
        ;~ and     al,20h
        ;~ cmp     al,20h
        ;~ jnz     @B
        ;~ popa


        mov     dx,[BIOS_AuxParms]            ; get port and parameters
        xor     dh,dh                         ; we don't need the parameters
        test    dl,dl                         ; test if logging is enabled
        jz      AuxIO_Teletype_NoLogging      ; nope, return immediately
        dec     dl                            ; adjust port-number
        and     dl,03h                        ; 3 is max value
        mov     ah,01h
        int     14h                           ; send char to com-port
    AuxIO_Teletype_NoLogging:
        ret
AuxIO_Teletype  EndP


; Print newline char (unix) to com-port (teletype style)
AuxIO_TeletypeNL    Proc     Near  Uses  ax
        mov     al,10
        call    AuxIO_Teletype
        ret
AuxIO_TeletypeNL    EndP


; Print Bin-byte to com-port (teletype style)
; This outputs 8 characters ('0' or '1' for each bit)
; In:          AL - byte to send
; Out:         AL - byte sent
; Destroyed:   None
AuxIO_TeletypeBinByte   Proc    Near Uses   ax cx
        mov     ah,al
        mov     cx,8
    AuxIO_TeletypeBinByte_nextchar:
        xor     al,al
        rcl     ah,1
        rcl     al,1
        add     al,'0'
        call    AuxIO_Teletype
        loop    AuxIO_TeletypeBinByte_nextchar
        ret
AuxIO_TeletypeBinByte   EndP

; Print Bin-word to com-port (teletype style)
; This outputs 16 characters ('0' or '1' for each bit)
; In:          AX - byte to send
; Out:         AX - byte sent
; Destroyed:   None
AuxIO_TeletypeBinWord   Proc
        xchg    al,ah                      ; High byte first
        call    AuxIO_TeletypeBinByte      ; Output to com-port
        xchg    al,ah                      ; low byte next
        call    AuxIO_TeletypeBinByte      ; Output to com-port
        ret
AuxIO_TeletypeBinWord   EndP

; Print Bin-dword to com-port (teletype style)
; This outputs 32 characters ('0' or '1' for each bit)
; In:          DX:AX - dword to send
; Out:         DX:AX - dword sent
; Destroyed:   None
AuxIO_TeletypeBinDWord  Proc     Near
        xchg    ax,dx
        call    AuxIO_TeletypeBinWord      ; High word first
        xchg    ax,dx
        call    AuxIO_TeletypeBinWord      ; Low word next
        ret
AuxIO_TeletypeBinDWord  EndP

; Print Bin-qword to com-port (teletype style)
; This outputs 64 characters ('0' or '1' for each bit)
; In:          BX:CX:DX:AX - qword to send
; Out:         BX:CX:DX:AX - qword sent
; Destroyed:   None
AuxIO_TeletypeBinQWord  Proc     Near
        xchg    dx,bx
        xchg    ax,cx
        call    AuxIO_TeletypeBinDWord     ; High dword first
        xchg    dx,bx
        xchg    ax,cx
        call    AuxIO_TeletypeBinDWord     ; Low dword next
        ret
AuxIO_TeletypeBinQWord  EndP


; Print hex-byte to com-port (teletype style)
; This outputs two characters
; In:          AL - byte to send
; Out:         AL - byte sent
; Destroyed:   None
AuxIO_TeletypeHexByte   Proc     Near  Uses  ax
        call    CONV_BinToAsc              ; Returns high hex-nibble in AH, low hex-nibble in AL
        xchg    al,ah                      ; High hex-nibble first
        call    AuxIO_Teletype             ; Output to com-port
        xchg    al,ah                      ; Low hex-nibble next
        call    AuxIO_Teletype             ; Output to com-port
        ret
AuxIO_TeletypeHexByte   EndP

; Print hex-word to com-port (teletype style)
; This outputs four characters
; In:          AX - word to send
; Out:         AX - word sent
; Destroyed:   None
AuxIO_TeletypeHexWord   Proc     Near
        xchg    al,ah                      ; High byte first
        call    AuxIO_TeletypeHexByte      ; Output to com-port
        xchg    al,ah                      ; low byte next
        call    AuxIO_TeletypeHexByte      ; Output to com-port
        ret
AuxIO_TeletypeHexWord   EndP


; Print hex-dword to com-port (teletype style)
; This outputs eight characters
; In:          DX:AX - dword to send
; Out:         DX:AX - dword sent
; Destroyed:   None
AuxIO_TeletypeHexDWord  Proc     Near
        xchg    ax,dx
        call    AuxIO_TeletypeHexWord      ; High word first
        xchg    ax,dx
        call    AuxIO_TeletypeHexWord      ; Low word next
        ret
AuxIO_TeletypeHexDWord  EndP


; Print hex-qword to com-port (teletype style)
; This outputs sixteen characters
; In:          BX:CX:DX:AX - qword to send
; Out:         BX:CX:DX:AX - qword sent
; Destroyed:   None
AuxIO_TeletypeHexQWord  Proc     Near
        xchg    dx,bx
        xchg    ax,cx
        call    AuxIO_TeletypeHexDWord     ; High dword first
        xchg    dx,bx
        xchg    ax,cx
        call    AuxIO_TeletypeHexDWord     ; Low dword next
        ret
AuxIO_TeletypeHexQWord  EndP



; Print 0-terminated string to com-port
AuxIO_Print     Proc     Near  Uses  ax bx cx dx
    AuxIO_PrintNext:
        lodsb
        test    al,al
        jz      AuxIO_PrintEOS
        call    AuxIO_Teletype
        jmp     AuxIO_PrintNext
    AuxIO_PrintEOS:
        ret
AuxIO_Print     EndP


; Dump a 16-byte block of memory to the com-port in debug-format (hex-bytes and ascii-bytes)
; In:    DS:SI - pointer to memory to dump
;
AuxIO_DumpParagraph     Proc  Near  Uses  ax cx dx si

        ; Dump the index dword
        xor     dx,dx
        mov     ax,si
        call    AuxIO_TeletypeHexDWord

        ; Separate it from the dump
        mov     al,' '
        call    AuxIO_Teletype
        mov     al,' '
        call    AuxIO_Teletype
        mov     al,'|'
        call    AuxIO_Teletype
        mov     al,' '
        call    AuxIO_Teletype

        ; Save si for later
        push    si

        ; Four groups of 4 bytes
        mov     cx,4


    AuxIO_DumpParagraph_Next_1:

        ; byte at offset 0
        lodsb
        call    AuxIO_TeletypeHexByte

        ; space separator
        mov     al,' '
        call    AuxIO_Teletype

        ; byte at offset 1
        lodsb
        call    AuxIO_TeletypeHexByte

        ; space separator
        mov     al,' '
        call    AuxIO_Teletype

        ; byte at offset 2
        lodsb
        call    AuxIO_TeletypeHexByte

        ; space separator
        mov      al,' '
        call    AuxIO_Teletype

        ; byte at offset 3
        lodsb
        call    AuxIO_TeletypeHexByte

        ; space separator
        mov      al,' '
        call    AuxIO_Teletype

        ; separator
        mov      al,'|'
        call    AuxIO_Teletype

        ; space separator
        mov      al,' '
        call    AuxIO_Teletype

        loop    AuxIO_DumpParagraph_Next_1

        ; space separator
        mov      al,' '
        call    AuxIO_Teletype

        ; recall pointer
        pop     si

        ; 16 ascii bytes to print
        mov     cx,16

    AuxIO_DumpParagraph_Next_2:
        mov     ah,'.'                              ; char to use ufnot printable
        lodsb                                       ; load byte
        call    CONV_ConvertToPrintable             ; use dot's if not printable
        call    AuxIO_Teletype                      ; print it
        loop    AuxIO_DumpParagraph_Next_2
        ret
AuxIO_DumpParagraph     EndP



AuxIO_DumpSector    Proc  Near  Uses  cx si
        mov     cx,32                      ; Number of paragraphs in a sector
    AuxIO_DumpSector_Next:
        call    AuxIO_DumpParagraph        ; Dump the paragraph
        add     si,16                      ; Advance pointer
        call    AuxIO_TeletypeNL
        loop    AuxIO_DumpSector_Next
        ret
AuxIO_DumpSector    EndP


AuxIOHello  db 10,10,10,10,10,'AiR-BOOT com-port debugging',10,0


