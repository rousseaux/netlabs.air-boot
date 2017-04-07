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
;                                                          AiR-BOOT / DEBUG
;---------------------------------------------------------------------------


; -----------------------
; Rousseau: # DEBUG.ASM #
; -----------------------
; This module contains functions for debugging AiR-BOOT.
; It is only included in debug builds and the codesize of AiR-BOOT increases
; in that case. To compensate for that, the FX code is disabled when debugging
; is active. Also, most of the debug-routines can selectively be disabled
; by setting the 'IF' directive to 0 or 1. Setting to 0 does an immediate
; return, setting to 1 enables the routine.



IFDEF   MODULE_NAMES
DB 'DEBUG',0
ENDIF



;
; Show help on keys.
;
dbh     db  10
        db  'h=HELP, d=DBGSCR-TOGGLE',10
        db  'l=DRIVE-LETTERS, g=GEO, i=IPT, r=RESTART, v=VOL-LETTERS, x=XREF',10
        db  '0-9=disk 80h-89h info',10
        db  10,0

DEBUG_ShowHelp      Proc
        pushf
        pusha
        mov     si, offset dbh
        call    AuxIO_Print
        popa
        popf
        ret
DEBUG_ShowHelp      EndP



;
; Dispatch table for debug hot-keys.
;
dbg_dispatch:
        db      't'
        dw      offset  DEBUG_Test
        db      'd'
        dw      offset  DEBUG_DebugScreenToggle
        db      'l'
        dw      offset  DEBUG_DumpDriveLetters
        db      'g'
        dw      offset  DEBUG_DumpGeo
        db      'h'
        dw      offset  DEBUG_ShowHelp
        db      'i'
        dw      offset  DEBUG_DumpIPT
        db      'r'
        dw      offset  AirbootRestart
        db      'v'
        dw      offset  DEBUG_DumpVolumeLetters
        db      'x'
        dw      offset  DEBUG_DumpPartitionXref
        db      'R'
        dw      offset  AirbootRestart
        db      0



;
; Show 'not assigned' message.
;
dbg_na  db  'This key is not assigned, press ''h'' for Help.',10,0
DEBUG_NotAssigned       Proc
        pushf
        pusha
        mov     si,offset dbg_na
        call    AuxIO_Print
        popa
        popf
        ret
DEBUG_NotAssigned       Endp


; ============================================================== [ dump stuff ]

;
; Dump the geometry.
;
IF 0
DEBUG_DumpGeo   Proc
        pushf
        pusha

        ; BIOS cyls
        mov     dx,word ptr [BIOS_Cyls+02]
        mov     ax,word ptr [BIOS_Cyls+00]
        call    AuxIO_TeletypeHexDWord
        call    AuxIO_TeletypeNL

        ; BIOS heads
        mov     dx,word ptr [BIOS_Heads+02]
        mov     ax,word ptr [BIOS_Heads+00]
        call    AuxIO_TeletypeHexDWord
        call    AuxIO_TeletypeNL

        ; BIOS secs
        mov     dx,word ptr [BIOS_Secs+02]
        mov     ax,word ptr [BIOS_Secs+00]
        call    AuxIO_TeletypeHexDWord
        call    AuxIO_TeletypeNL

        ; Bytes per sector
        mov     ax,[BIOS_Bytes]
        call    AuxIO_TeletypeHexWord
        call    AuxIO_TeletypeNL

        ; Total secs
        mov     bx, word ptr [BIOS_TotalSecs+06]
        mov     cx, word ptr [BIOS_TotalSecs+04]
        mov     dx, word ptr [BIOS_TotalSecs+02]
        mov     ax, word ptr [BIOS_TotalSecs+00]
        call    AuxIO_TeletypeHexDWord
        call    AuxIO_TeletypeNL

        ; CHS to LBA
        mov     dx,1
        mov     ax,29e5h
        mov     bx,23h
        mov     cx,9h
        call    CONV_CHS2LBA
        call     AuxIO_TeletypeHexDWord
        call     AuxIO_TeletypeNL

        popa
        popf
        ret
DEBUG_DumpGeo   Endp
ELSE
DEBUG_DumpGeo   Proc
        ret
DEBUG_DumpGeo   Endp
ENDIF



;
; Dump the internal partition table.
;
IF 0
DEBUG_DumpIPT   Proc
        pushf
        pusha

        call    AuxIO_TeletypeNL

        mov     si,offset [BIOScontIPTentry]
        ;~ mov     si,offset [PartitionTable]
        call    AuxIO_DumpSector

        popa
        popf
        ret
DEBUG_DumpIPT   EndP
ELSE
DEBUG_DumpIPT   Proc
        ret
DEBUG_DumpIPT   EndP
ENDIF



;
; Dump the new  partitions table.
;
IF 0
DEBUG_DumpNewPartTable  Proc
        pushf
        pusha

        call    AuxIO_TeletypeNL

        mov     si,offset [NewPartTable]
        call    AuxIO_DumpSector

        popa
        popf
        ret
DEBUG_DumpNewPartTable  EndP
DEBUG_DumpNewPartTable  Proc
        ret
DEBUG_DumpNewPartTable  EndP
ENDIF



;
; Dump the partition pointers table.
;
IF 0
DEBUG_DumpPartitionPointers     Proc
        pushf
        pusha

        call    AuxIO_TeletypeNL

        mov     si,offset [PartitionPointers]
        mov     cx,7

    DEBUG_DumpPartitionPointers_next:
        call    AuxIO_DumpParagraph
        add     si,16
        call    AuxIO_TeletypeNL
        loop    DEBUG_DumpPartitionPointers_next

        popa
        popf
        ret
DEBUG_DumpPartitionPointers     EndP
ELSE
DEBUG_DumpPartitionPointers     Proc
        ret
DEBUG_DumpPartitionPointers     EndP
ENDIF



;
; Dump the partition x-ref table.
;
IF 0
xrt     db  10,'XrefTable:',10,0
DEBUG_DumpPartitionXref     Proc
        pushf
        pusha

        mov     si, offset [xrt]
        call    AuxIO_Print
        ;~ call    AuxIO_TeletypeNL

        mov     si,offset [PartitionXref]
        mov     cx,3

    DEBUG_DumpPartitionXref_next:
        call    AuxIO_DumpParagraph
        add     si,16
        call    AuxIO_TeletypeNL
        loop    DEBUG_DumpPartitionXref_next

        popa
        popf
        ret
DEBUG_DumpPartitionXref     EndP
ELSE
DEBUG_DumpPartitionXref     Proc
        ret
DEBUG_DumpPartitionXref     EndP
ENDIF



;
; Dump the dl-feature drive-letters.
;
IF 0
ddl     db  10,'Driveletters:',10,0
DEBUG_DumpDriveLetters      Proc
        pushf
        pusha

        mov     si, offset [ddl]
        call    AuxIO_Print

        ; Dump the old drive-letters as set with the dl-feature.
        mov     si,offset [DriveLetters]
        mov     cx,3
    DEBUG_DumpDriveLetters_next_1:
        call    AuxIO_DumpParagraph
        add     si,16
        call    AuxIO_TeletypeNL
        loop    DEBUG_DumpDriveLetters_next_1

        ; Dump the new drive-letters as composed when scanning partitions
        ; and partitions were added or removed.
        mov     si,offset [NewDriveLetters]
        mov     cx,3
    DEBUG_DumpDriveLetters_next_2:
        call    AuxIO_DumpParagraph
        add     si,16
        call    AuxIO_TeletypeNL
        loop    DEBUG_DumpDriveLetters_next_2

        popa
        popf
        ret
DEBUG_DumpDriveLetters      EndP
ELSE
DEBUG_DumpDriveLetters      Proc
        ret
DEBUG_DumpDriveLetters      EndP
ENDIF



;
; Dump some disk information.
;
IF 0
ddi     db  10,'DumpDiskInfo:',10,0
DEBUG_DumpDiskInfo          Proc
        pushf
        pusha

        ; ASCII '0' to BIOS 80h, '1'->81h, etc.
        add     al, 50h

        mov     si, offset [ddi]
        call    AuxIO_Print

        ; Print disk-number
        call    AuxIO_TeletypeHexByte
        call    AuxIO_TeletypeNL

        ; Show disk parameters (legacy version)
        pusha
            mov     dl, al
            mov     ah, 08h
            int     13h
            call    DEBUG_DumpRegisters
        popa

        ; Show status of last operation
        pusha
            mov     dl, al
            mov     ah, 01
            int     13h
            mov     al, ah
            call    AuxIO_TeletypeHexByte
            call    AuxIO_TeletypeNL
        popa

        popa
        popf
        ret
DEBUG_DumpDiskInfo          EndP
ELSE
DEBUG_DumpDiskInfo          Proc
        ret
DEBUG_DumpDiskInfo          EndP
ENDIF



;
; Dump the lvm volume drive-letters.
;
IF 0
dvl     db  10,'VolumeLetters:',10,0
DEBUG_DumpVolumeLetters     Proc
        pushf
        pusha

        mov     si, offset [dvl]
        call    AuxIO_Print

        mov     si,offset [PartitionVolumeLetters]
        mov     cx,3

    DEBUG_DumpVolumeLetters_next:
        call    AuxIO_DumpParagraph
        add     si,16
        call    AuxIO_TeletypeNL
        loop    DEBUG_DumpVolumeLetters_next

        popa
        popf
        ret
DEBUG_DumpVolumeLetters     EndP
ELSE
DEBUG_DumpVolumeLetters     Proc
        ret
DEBUG_DumpVolumeLetters     EndP
ENDIF



;
; Dump the registers and flags.
;
IF 1
regAX   db  'AX:',0
regBX   db  ' BX:',0
regCX   db  ' CX:',0
regDX   db  ' DX:',0
regSI   db  ' SI:',0
regDI   db  ' DI:',0

regBP   db  'CS:',0
regSP   db  ' DS:',0
regCS   db  ' ES:',0
regSS   db  ' SS:',0
regDS   db  ' SP:',0
regES   db  ' BP:',0

regFS   db  'FS:',0
regGS   db  ' GS:',0

        db '       '

flagsSF db  ' SF:',0
flagsZF db  ' ZF:',0
flagsAF db  ' AF:',0
flagsPF db  ' PF:',0
flagsCF db  ' CF:',0

DEBUG_DumpRegisters     Proc

        ; Save state of caller
        pushf
        pusha

        ; Save flags so they can be printed later
        pushf

        ; Push the registers to print on the stack (SP is bogus)
.386
        push    gs
        push    fs
.286
        push    bp
        push    sp
        push    ss
        push    es
        push    ds
        push    cs
        push    di
        push    si
        push    dx
        push    cx
        push    bx
        push    ax

        ; Base of registers string
        mov     si, offset [regAX]

        ; Print AX BX CX DX SI DI
        mov     cx, 6
    @@:
        pop     ax
        call    AuxIO_Print
        call    AuxIO_TeletypeHexWord
        loop    @B

        ; 1st row printed
        call    AuxIO_TeletypeNL

        ; Print CS DS ES SS SP BP
        mov     cx, 6
    @@:
        pop     ax
        call    AuxIO_Print
        call    AuxIO_TeletypeHexWord
        loop    @B

        ; 2nd row printed
        call    AuxIO_TeletypeNL

        ; Print FS GS
        mov     cx, 2
    @@:
        pop     ax
        call    AuxIO_Print
        call    AuxIO_TeletypeHexWord
        loop    @B

        ; Restore the flags
        popf

        ; Load flags into AH
        lahf

        ; Base of flags string
        ;~ mov     si, offset [flagsSF]

        ; Print SF
        call    AuxIO_Print
        mov     al, ah
        shr     al, 7
        and     al, 01h
        add     al, '0'
        call    AuxIO_Teletype

        ; Print ZF
        call    AuxIO_Print
        mov     al, ah
        shr     al, 6
        and     al, 01h
        add     al, '0'
        call    AuxIO_Teletype

        ; Print AF
        call    AuxIO_Print
        mov     al, ah
        shr     al, 4
        and     al, 01h
        add     al, '0'
        call    AuxIO_Teletype

        ; Print PF
        call    AuxIO_Print
        mov     al, ah
        shr     al, 2
        and     al, 01h
        add     al, '0'
        call    AuxIO_Teletype

        ; Print CF
        call    AuxIO_Print
        mov     al, ah
        and     al, 01h
        add     al, '0'
        call    AuxIO_Teletype

        ; 3rd and last row printed
        call    AuxIO_TeletypeNL

        ; Restore caller state
        popa
        popf

        ret
DEBUG_DumpRegisters     EndP
ELSE
DEBUG_DumpRegisters     Proc
        ret
DEBUG_DumpRegisters     EndP
ENDIF



;
; Dump CHS values.
;
IF 0
DEBUG_DumpCHS   Proc    Near
        pushf
        pusha
        mov     al,'C'
        call    AuxIO_Teletype
        mov     al,':'
        call    AuxIO_Teletype
        mov     ah,cl
        shr     ah,6
        mov     al,ch
        call    AuxIO_TeletypeHexWord
        mov     al,' '
        call    AuxIO_Teletype
        mov     al,'H'
        call    AuxIO_Teletype
        mov     al,':'
        call    AuxIO_Teletype
        mov     al,dh
        call    AuxIO_TeletypeHexByte
        mov     al,' '
        call    AuxIO_Teletype
        mov     al,'S'
        call    AuxIO_Teletype
        mov     al,':'
        call    AuxIO_Teletype
        mov     al,cl
        and     al,00111111b
        call    AuxIO_TeletypeHexByte
        call    AuxIO_TeletypeNL
        popa
        popf
        ret
DEBUG_DumpCHS   EndP
ELSE
DEBUG_DumpCHS   Proc    Near
        ret
DEBUG_DumpCHS   EndP
ENDIF



;
; Dump BSS.
;
IF 0
DEBUG_DumpBSSSectors    Proc    Near
        pushf
        pusha

        mov     si, offset [PartitionSector]
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL

        mov     si, offset [PBRSector]
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL

        mov     si, offset [LVMSector]
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL

        mov     si, offset [TmpSector]
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL

        mov     si, offset [NewPartTable]
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL
        call    AuxIO_TeletypeNL

        popa
        popf
        ret
DEBUG_DumpBSSSectors    EndP
ELSE
DEBUG_DumpBSSSectors    Proc    Near
        ret
DEBUG_DumpBSSSectors    EndP
ENDIF



;
; Dump 6-bit packed hide partition table.
;
IF 0
DEBUG_DumpHidePartTables    Proc    Near
        pushf
        pusha

        mov     cx,3
        mov     si, offset [HidePartitionTable]
    again1:
        call    AuxIO_DumpSector
        add     si,512
        loop    again1
        call    AuxIO_TeletypeNL

        mov     cx,3
        mov     si, offset [PartitionXref]
    again2:
        call    AuxIO_DumpParagraph
        call    AuxIO_TeletypeNL
        add     si,16
        loop    again2
        call    AuxIO_TeletypeNL

        mov     cx,3
        mov     si, offset [NewHidePartTable]
    again3:
        call    AuxIO_DumpSector
        add     si,512
        loop    again3
        call    AuxIO_TeletypeNL

        popa
        popf
        ret
DEBUG_DumpHidePartTables    EndP
ELSE
DEBUG_DumpHidePartTables    Proc    Near
        ret
DEBUG_DumpHidePartTables    EndP
ENDIF



; ============================================================== [ test stuff ]

;
; Activate zero or more test functions.
; When a call is _not_ commented out, the test-function can still be disabled
; if its 'IF' directive is 0.
;
IF 1
DEBUG_Test  Proc
    pushf
    pusha
    ;~ call    DEBUG_Test_CONV_BinToPBCD
    ;~ call    DEBUG_Test_MATH_Mul32
    popa
    popf
    ret
DEBUG_Test  EndP
ELSE
DEBUG_Test  Proc
    ret
DEBUG_Test  EndP
ENDIF



;
; Test the packed BCD conversion function.
;
IF 0
db_testbin2pbcd db "## TEST BIN2PBCD ##",10,0
DEBUG_Test_CONV_BinToPBCD   Proc
        pushf
        pusha

        ; Msg test bin2pbcd
        mov     si,offset [db_testbin2pbcd]
        call    AuxIO_Print

        ; Start with 0
        xor     cx, cx

        ; Print 0 - 255 as BYTE and packed BCD
    next_value:
        mov     al, cl                  ; Current value
        call    AuxIO_TeletypeHexByte   ; Print as byte
        mov     al, ' '
        call    AuxIO_Teletype
        mov     al, cl                  ; Current value
        call    CONV_BinToPBCD          ; Convert to packed BCD
        call    AuxIO_TeletypeHexWord   ; Print as word
        mov     al, ' '
        call    AuxIO_Teletype
        mov     al, cl                  ; Current value
        call    AuxIO_TeletypeDecByte   ; Print as decimal
        call    AuxIO_TeletypeNL
        inc     cx                      ; Next value
        cmp     cx, 0ffh                ; Check for last valid value
        jbe     next_value              ; Repeat if still in range

        popa
        popf
        ret
DEBUG_Test_CONV_BinToPBCD   EndP
ELSE
DEBUG_Test_CONV_BinToPBCD   Proc
        ret
DEBUG_Test_CONV_BinToPBCD   EndP
ENDIF



;
; Test the simple 32-bit math functions.
;
IF 0
db_testmul32   db "## TEST MUL32 ##",10,0
DEBUG_Test_MATH_Mul32   Proc    Near
        pushf
        pusha

        ; Msg test math-module
        mov     si,offset [db_testmul32]
        call    AuxIO_Print

        ; Output hex-word
        mov     ax,0BABEh
        call    AuxIO_TeletypeHexWord

        mov     al,' '
        call    AuxIO_Teletype
        mov     al,'*'
        call    AuxIO_Teletype
        mov     al,' '
        call    AuxIO_Teletype

        ; Output hex-word
        mov     ax,0BABEh
        call    AuxIO_TeletypeHexWord

        mov     al,' '
        call    AuxIO_Teletype
        mov     al,'='
        call    AuxIO_Teletype
        mov     al,' '
        call    AuxIO_Teletype

        mov     ax,0BABEh
        mul     ax
        call    AuxIO_TeletypeHexDWord

        ; Start new line
        call    AuxIO_TeletypeNL

        ; Output hex-dword
        mov     dx,0DEADh
        mov     ax,0FACEh
        call    AuxIO_TeletypeHexDWord

        mov     al,' '
        call    AuxIO_Teletype
        mov     al,'*'
        call    AuxIO_Teletype
        mov     al,' '
        call     AuxIO_Teletype

        ; Output hex-dword
        mov     dx,0DEADh
        mov     ax,0FACEh
        call    AuxIO_TeletypeHexDWord

        mov     al,' '
        call    AuxIO_Teletype
        mov     al,'='
        call    AuxIO_Teletype
        mov     al,' '
        call    AuxIO_Teletype

        mov     bx,0DEADh
        mov     cx,0FACEh
        mov     dx,0DEADh
        mov     ax,0FACEh
        call    MATH_Mul32
        call    AuxIO_TeletypeHexQWord

        call    AuxIO_TeletypeNL
        call    AuxIO_TeletypeNL

        popa
        popf
        ret
DEBUG_Test_MATH_Mul32   EndP
ELSE
DEBUG_Test_MATH_Mul32   Proc    Near
        ret
DEBUG_Test_MATH_Mul32   EndP
ENDIF



;
; Test the bitfield routines.
;
IF 0
DEBUG_TestBitFieldFunctions Proc
        pushf
        pusha

        mov     bx,offset [dbg_scratch]

        mov     al,0
        mov     dl,0
        mov     dh,6
    DEBUG_TestBitFieldFunctions_next_write:
        call    CONV_SetBitfieldValue
        inc     al
        inc     dl
        jnz     DEBUG_TestBitFieldFunctions_next_write

        mov     dl,0
        mov     dh,6
    DEBUG_TestBitFieldFunctions_next_read:
        mov     al,dl
        call    AuxIO_TeletypeHexByte
        mov     al,':'
        call    AuxIO_Teletype
        call    CONV_GetBitfieldValue
        call    AuxIO_TeletypeHexWord
        call    AuxIO_TeletypeNL
        inc     dl
        jnz     DEBUG_TestBitFieldFunctions_next_read

        popa
        popf
        ret
DEBUG_TestBitFieldFunctions EndP
ELSE
DEBUG_TestBitFieldFunctions Proc
        ret
DEBUG_TestBitFieldFunctions EndP
ENDIF



;
; Like the MBR version, but uses video page 3.
;
DBG_Teletype    Proc Near   Uses ax bx cx
        mov     ah, 0Eh
        mov     bh, 03h
        mov     bl, 07h
    DBGT_Loop:
        lodsb
        or      al, al
        jz      DBGT_End
        int     10h
        jmp     DBGT_Loop
    DBGT_End:
        ret
DBG_Teletype    EndP



;
; Dump information before the menu is displayed.
;
DEBUG_Dump1     Proc  Near
        pushf
        pusha

        ; Hello message
        mov     si, offset AuxIOHello
        call    AuxIO_Print

        ; Build Info
        ;~ mov     si, offset BUILD_DATE
        ;~ call    AuxIO_Print
        call    AuxIO_PrintBuildInfo

        ; Start new line
        call    AuxIO_TeletypeNL
        ;~ call    AuxIO_TeletypeNL

        ;~ call    DEBUG_DumpHidePartTables
        ;~ call    DEBUG_CheckMath
        ;~ call    DEBUG_DumpGeo
        ;~ call    DEBUG_CheckBitFields

        popa
        popf
        ret
DEBUG_Dump1     EndP



;
; Dump information before the partition is booted.
;
IF 0
DEBUG_Dump2     Proc  Near
        pushf
        pusha

        call    AuxIO_TeletypeNL
        call    AuxIO_TeletypeNL

        mov     si,offset db_config
        call    AuxIO_Print

        mov     si,offset db_cfgparts
        call    AuxIO_Print
        mov     al,[CFG_Partitions]
        call    AuxIO_TeletypeHexByte
        call    AuxIO_TeletypeNL

        mov     si,offset db_cfgpartdef
        call    AuxIO_Print
        mov     al,[CFG_PartDefault]
        call    AuxIO_TeletypeHexByte
        call    AuxIO_TeletypeNL

        mov     si,offset db_cfgpartlast
        call    AuxIO_Print
        mov     al,[CFG_PartLast]
        call    AuxIO_TeletypeHexByte
        call    AuxIO_TeletypeNL
        call    AuxIO_TeletypeNL

        mov     si,offset db_vars
        call    AuxIO_Print

        mov     si,offset db_newpart
        call    AuxIO_Print
        mov     si,offset NewPartTable
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL
        add     si,512
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL
        call    AuxIO_TeletypeNL

        mov     si,offset db_newhide
        call    AuxIO_Print
        mov     si,offset NewHidePartTable
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL
        add     si,512
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL
        call    AuxIO_TeletypeNL

        mov     si,offset db_dletters
        call    AuxIO_Print
        mov     si,offset NewDriveLetters
        call    AuxIO_DumpParagraph
        call    AuxIO_TeletypeNL
        add     si,16
        call    AuxIO_DumpParagraph
        call    AuxIO_TeletypeNL
        call    AuxIO_TeletypeNL

        mov     si,offset db_tmpec
        call    AuxIO_Print
        mov     si,offset TmpSector
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL
        call    AuxIO_TeletypeNL

        mov     si,offset db_partsec
        call    AuxIO_Print
        mov     si,offset PartitionSector
        call    AuxIO_DumpSector
        call    AuxIO_TeletypeNL
        call    AuxIO_TeletypeNL

        popa
        popf
        ret
DEBUG_Dump2     EndP
ELSE
DEBUG_Dump2     Proc  Near
        ret
DEBUG_Dump2     EndP
ENDIF



;
; Display a number that was put on the stack.
; Used to track code-flow.
;
dbp     db  '>---------->> DebugProbe: ',0
DEBUG_Probe     Proc
IF 0
        push    bp
        mov     bp,sp
        pushf
        pusha

        mov     si,offset [dbp]         ; Default probe-text.
        call    AuxIO_Print
        mov     ax,[bp+04]              ; Get probe-number from stack.
        call    AuxIO_TeletypeHexWord
        call    AuxIO_TeletypeNL

        ; Also display registers.
        popa
        pusha
        call    DEBUG_DumpRegisters

        popa
        popf
        pop     bp
ENDIF
        ret     2
DEBUG_Probe     Endp



;
; Toggle display of debug video page.
;
IF 0
DEBUG_DebugScreenToggle Proc
        pushf
        pusha

        mov     si, offset $+5
        jmp     @F
        db      10,'DebugScreenToggle:',10,0
prvpg   db      00h
hdr     db      10,'[Debug Console]',13,10,0
@@:     call    AuxIO_Print

        ; Get current page in BH
        mov     ah, 0fh
        int     10h

        ; Already debug page ?
        cmp     bh, 03h
        je      DEBUG_DebugScreenToggle_back

        ; Remember page
        mov     [prvpg], bh

        ; Switch to debug page
        mov     al, 03h
        mov     ah, 05h
        int     10h

        ; Get cursor position in DX (DH=row, DL=column)
        ;~ mov     ah, 03h
        ;~ mov     bh, 03h
        ;~ int     10h

        ;~ mov     al, 01h
        ;~ mov     bh, 03h
        ;~ mov     bl, 07h
        ;~ mov     bp, offset [hdr]
        ;~ mov     cx, sizeof(hdr)
        ;~ mov     ah, 13h
        ;~ int     10h

        ;~ mov     bh, 03h
        ;~ mov     dh, 00h
        ;~ mov     dl, 00h
        ;~ mov     ah, 02h
        ;~ int     10h

        mov     si, offset [hdr]
        call    DBG_Teletype

        jmp     DEBUG_DebugScreenToggle_end

    DEBUG_DebugScreenToggle_back:
        ; Switch back to previous page
        mov     al, [prvpg]
        mov     ah, 05h
        int     10h
        jmp     DEBUG_DebugScreenToggle_end

    DEBUG_DebugScreenToggle_end:
        popa
        popf
        ret
DEBUG_DebugScreenToggle EndP
ELSE
DEBUG_DebugScreenToggle Proc
        ret
DEBUG_DebugScreenToggle EndP
ENDIF



;
; Handle keypresses when the main menu is active.
;
DEBUG_HandleKeypress    Proc
        pushf
        pusha

        ; Save hot-key
        mov     dl,al

        ; Check for digit.
        cmp     al,'0'
        jb      DEBUG_HandleKeypress_exit
        cmp     al,'9'
        ja      DEBUG_HandleKeypress_try_alpha
        ; It was a digit, dump disk info ('0' for 80h, '1' for 81h, etc)
        call    DEBUG_DumpDiskInfo
        ;~ jmp     DEBUG_HandleKeypress_check_it
        jmp     DEBUG_HandleKeypress_exit

        ; Check for alpha.
    DEBUG_HandleKeypress_try_alpha:
        ; Force upper-case.
        and     al,11011111b
        cmp     al,'A'
        jb      DEBUG_HandleKeypress_exit
        cmp     al,'Z'
        ja      DEBUG_HandleKeypress_exit
        ; It was an alpha.
        jmp     DEBUG_HandleKeypress_check_it


        ; Check if the key is a hot-key.
    DEBUG_HandleKeypress_check_it:
        cld
        mov     si,offset dbg_dispatch

        ; Loop over jump-list.
    DEBUG_HandleKeypress_next_entry:

        ; Load the hot-key.
        lodsb
        ; No hot-key (not implemented) if end-of-list.
        test    al,al
        jz      DEBUG_HandleKeypress_ni

        ; Compare hot-key and iterate if not the same.
        cmp     dl,al
        lodsw
        jne     DEBUG_HandleKeypress_next_entry

        ; Entry found, call corresponding routine.
        mov     bx,ax
        call    bx

        ; Done.
        jmp     DEBUG_HandleKeypress_exit

        ; Call not-assigned routine.
    DEBUG_HandleKeypress_ni:
        call    DEBUG_NotAssigned
        jmp     DEBUG_HandleKeypress_exit

        ; Return to caller.
    DEBUG_HandleKeypress_exit:
        popa
        popf
        ret
DEBUG_HandleKeypress    Endp



;
; These strings can also be referenced outside the debug module when debugging
; is enabled.
;
;~ dlra    db  10,'LVM_DoLetterReassignment: ',0
ptetb   db  10,'Partition Table Entry to boot',10,0
bios_reg    db  10,'Registers passed by BIOS:',10,0
;~ diopmbr db  10,'DriveIO_ProtectMBR',10,0


;~ db_mbr              db "## MBR ##",10,0
;~ db_masterlvm        db "## MLVMR ##",10,0


;~ db_config           db '## CFG (DMP2) ##',10,0
;~ db_cfgparts         db 'CFG_Partitions:',0
;~ db_cfgpartdef       db 'CFG_PartDefault:',0
;~ db_cfgpartlast      db 'CFG_PartLast:',0


;~ db_vars             db '## VARS ##',10,0
;~ db_partsec          db 'PartitionSector:',10,0
;~ db_lvmsec           db 'LVMSector :',10,0
;~ db_tmpec            db 'TmpSector :',10,0

;~ db_newpart          db 'NewPartTable :',10,0
;~ db_newhide          db 'NewHideTable:',10,0
;~ db_dletters         db 'NewDriveLetters:',10,0

;~ db_partsize         db 'PartitionSizeTable:',10,0
;~ db_partpoint        db 'PartitionPointers:',10,0
;~ db_partpointcnt     db 'PartitionPointerCount:',0
;~ db_partxref         db 'PartitionXref:',10,0
;~ db_partvoldl        db 'PartitionVolumeLetters:',10,0

;~ db_totaldisks       db 'TotalHarddiscs:',0
;~ db_lbaswitchtab     db 'LBASwitchTable:',10,0
;~ db_newparts         db 'NewPartitions:',0

;~ db_exabspos         db 'ExtendedAbsPos:',0
;~ db_exabsposset      db 'ExtendedAbsPosSet:',0

;~ db_curpartloc       db 'CurPartition_Location:',0
;~ db_curiox           db 'CurIO_UseExtension:',0

;~ db_curlvmsec        db 'Current LVM Sector:',0


;~ drive                   db 'drive                    : ',0
;~ before_lvm_adjust       db 'before lvm adjust        : ',0
;~ after_lvm_adjust        db 'after lvm adjust         : ',0
;~ before_lvm_adjust_log   db 'before lvm logical adjust: ',0
;~ after_lvm_adjust_log    db 'after lvm logical adjust : ',0
;~ spt_used                db 'spt used                 : ',0
