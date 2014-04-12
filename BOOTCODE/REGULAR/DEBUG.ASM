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
; in that case.
;
; Had problems with RU language version because it includes cyrillic charset.
; Parts disabled for now.


IFDEF ModuleNames
DB 'DEBUG',0
ENDIF

DEBUG_CheckMath Proc    Near
        ;~ pushf
        ;~ pusha
;~
        ;~ ; Msg check math-module
        ;~ mov     si,offset db_checkmath
        ;~ call    AuxIO_Print
;~
        ;~ ; Output hex-word
        ;~ mov     ax,0BABEh
        ;~ call    AuxIO_TeletypeHexWord
;~
        ;~ mov     al,' '
        ;~ call    AuxIO_Teletype
        ;~ mov     al,'*'
        ;~ call    AuxIO_Teletype
        ;~ mov     al,' '
        ;~ call    AuxIO_Teletype
;~
        ;~ ; Output hex-word
        ;~ mov     ax,0BABEh
        ;~ call    AuxIO_TeletypeHexWord
;~
        ;~ mov     al,' '
        ;~ call    AuxIO_Teletype
        ;~ mov     al,'='
        ;~ call    AuxIO_Teletype
        ;~ mov     al,' '
        ;~ call    AuxIO_Teletype
;~
        ;~ mov     ax,0BABEh
        ;~ mul     ax
        ;~ call    AuxIO_TeletypeHexDWord
;~
        ;~ ; Start new line
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ ; Output hex-dword
        ;~ mov     dx,0DEADh
        ;~ mov     ax,0FACEh
        ;~ call    AuxIO_TeletypeHexDWord
;~
        ;~ mov     al,' '
        ;~ call    AuxIO_Teletype
        ;~ mov     al,'*'
        ;~ call    AuxIO_Teletype
        ;~ mov     al,' '
        ;~ call     AuxIO_Teletype
;~
        ;~ ; Output hex-dword
        ;~ mov     dx,0DEADh
        ;~ mov     ax,0FACEh
        ;~ call    AuxIO_TeletypeHexDWord
;~
        ;~ mov     al,' '
        ;~ call    AuxIO_Teletype
        ;~ mov     al,'='
        ;~ call    AuxIO_Teletype
        ;~ mov     al,' '
        ;~ call    AuxIO_Teletype
;~
        ;~ mov     bx,0DEADh
        ;~ mov     cx,0FACEh
        ;~ mov     dx,0DEADh
        ;~ mov     ax,0FACEh
        ;~ call    MATH_Mul32
        ;~ call    AuxIO_TeletypeHexQWord
;~
        ;~ call    AuxIO_TeletypeNL
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ popa
        ;~ popf

        ret
DEBUG_CheckMath EndP


DEBUG_DumpGeo   Proc
        ;~ pushf
        ;~ pusha
;~
        ;~ ; BIOS cyls
        ;~ mov     dx,word ptr [BIOS_Cyls+02]
        ;~ mov     ax,word ptr [BIOS_Cyls+00]
        ;~ call    AuxIO_TeletypeHexDWord
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ ; BIOS heads
        ;~ mov     dx,word ptr [BIOS_Heads+02]
        ;~ mov     ax,word ptr [BIOS_Heads+00]
        ;~ call    AuxIO_TeletypeHexDWord
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ ; BIOS secs
        ;~ mov     dx,word ptr [BIOS_Secs+02]
        ;~ mov     ax,word ptr [BIOS_Secs+00]
        ;~ call    AuxIO_TeletypeHexDWord
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ ; Bytes per sector
        ;~ mov     ax,[BIOS_Bytes]
        ;~ call    AuxIO_TeletypeHexWord
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ ; Total secs
        ;~ mov     bx, word ptr [BIOS_TotalSecs+06]
        ;~ mov     cx, word ptr [BIOS_TotalSecs+04]
        ;~ mov     dx, word ptr [BIOS_TotalSecs+02]
        ;~ mov     ax, word ptr [BIOS_TotalSecs+00]
        ;~ call    AuxIO_TeletypeHexDWord
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ ; CHS to LBA
        ;~ mov     dx,1
        ;~ mov     ax,29e5h
        ;~ mov     bx,23h
        ;~ mov     cx,9h
        ;~ call    CONV_CHS2LBA
        ;~ call     AuxIO_TeletypeHexDWord
        ;~ call     AuxIO_TeletypeNL
;~
        ;~ popa
        ;~ popf

        ret
DEBUG_DumpGeo   Endp



DEBUG_DumpIPT   Proc
        pushf
        pusha

        call    AuxIO_TeletypeNL

        mov     si,offset [PartitionTable]
        call    AuxIO_DumpSector

        popa
        popf
        ret
DEBUG_DumpIPT   EndP

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


DEBUG_DumpPartitionXref     Proc
        pushf
        pusha

        call    AuxIO_TeletypeNL

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
        call    AuxIO_TeletypeNL

        ;~ call    DEBUG_DumpHidePartTables

        ;~ call    DEBUG_CheckMath

        ;~ call    DEBUG_DumpGeo

        ;~ call    DEBUG_CheckBitFields

        popa
        popf
        ret
DEBUG_Dump1     EndP


DEBUG_DumpBSSSectors    Proc    Near
        ;~ pushf
        ;~ pusha
;~
        ;~ mov     si, offset [PartitionSector]
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     si, offset [JfsPBR]
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     si, offset [LVMSector]
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     si, offset [TmpSector]
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     si, offset [NewPartTable]
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ popa
        ;~ popf
        ret
DEBUG_DumpBSSSectors    EndP


DEBUG_DumpHidePartTables    Proc    Near
        ;~ pushf
        ;~ pusha
;~
        ;~ mov     cx,3
        ;~ mov     si, offset [HidePartitionTable]
    ;~ again1:
        ;~ call    AuxIO_DumpSector
        ;~ add     si,512
        ;~ loop    again1
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     cx,3
        ;~ mov     si, offset [PartitionXref]
    ;~ again2:
        ;~ call    AuxIO_DumpParagraph
        ;~ call    AuxIO_TeletypeNL
        ;~ add     si,16
        ;~ loop    again2
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     cx,3
        ;~ mov     si, offset [NewHidePartTable]
    ;~ again3:
        ;~ call    AuxIO_DumpSector
        ;~ add     si,512
        ;~ loop    again3
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ popa
        ;~ popf
        ret
DEBUG_DumpHidePartTables    EndP


DEBUG_CheckBitFields    Proc
        ;~ pushf
        ;~ pusha
;~
        ;~ mov     bx,offset [ott]
;~
        ;~ mov     al,0
        ;~ mov     dl,0
        ;~ mov     dh,6
    ;~ DEBUG_CheckBitFields_next_write:
        ;~ call    CONV_SetBitfieldValue
        ;~ inc     al
        ;~ inc     dl
        ;~ jnz     DEBUG_CheckBitFields_next_write
;~
        ;~ mov     dl,0
        ;~ mov     dh,6
    ;~ DEBUG_CheckBitFields_next_read:
        ;~ mov     al,dl
        ;~ call    AuxIO_TeletypeHexByte
        ;~ mov     al,':'
        ;~ call    AuxIO_Teletype
        ;~ call    CONV_GetBitfieldValue
        ;~ call    AuxIO_TeletypeHexWord
        ;~ call    AuxIO_TeletypeNL
        ;~ inc     dl
        ;~ jnz     DEBUG_CheckBitFields_next_read
;~
        ;~ popa
        ;~ popf
        ret
DEBUG_CheckBitFields    EndP

;
; Dump information before the partition is booted.
;
DEBUG_Dump2     Proc  Near
        ;~ pushf
        ;~ pusha
;~
;~
        ;~ call    AuxIO_TeletypeNL
        ;~ call    AuxIO_TeletypeNL
;~
;~
        ;~ mov     si,offset db_config
        ;~ call    AuxIO_Print
;~
        ;~ mov     si,offset db_cfgparts
        ;~ call    AuxIO_Print
        ;~ mov     al,[CFG_Partitions]
        ;~ call    AuxIO_TeletypeHexByte
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     si,offset db_cfgpartdef
        ;~ call    AuxIO_Print
        ;~ mov     al,[CFG_PartDefault]
        ;~ call    AuxIO_TeletypeHexByte
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     si,offset db_cfgpartlast
        ;~ call    AuxIO_Print
        ;~ mov     al,[CFG_PartLast]
        ;~ call    AuxIO_TeletypeHexByte
        ;~ call    AuxIO_TeletypeNL
        ;~ call    AuxIO_TeletypeNL
;~
;~
;~
        ;~ mov     si,offset db_vars
        ;~ call    AuxIO_Print
;~
        ;~ mov     si,offset db_newpart
        ;~ call    AuxIO_Print
        ;~ mov     si,offset NewPartTable
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
        ;~ add     si,512
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     si,offset db_newhide
        ;~ call    AuxIO_Print
        ;~ mov     si,offset NewHidePartTable
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
        ;~ add     si,512
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     si,offset db_dletters
        ;~ call    AuxIO_Print
        ;~ mov     si,offset NewDriveLetters
        ;~ call    AuxIO_DumpParagraph
        ;~ call    AuxIO_TeletypeNL
        ;~ add     si,16
        ;~ call    AuxIO_DumpParagraph
        ;~ call    AuxIO_TeletypeNL
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     si,offset db_tmpec
        ;~ call    AuxIO_Print
        ;~ mov     si,offset TmpSector
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ mov     si,offset db_partsec
        ;~ call    AuxIO_Print
        ;~ mov     si,offset PartitionSector
        ;~ call    AuxIO_DumpSector
        ;~ call    AuxIO_TeletypeNL
        ;~ call    AuxIO_TeletypeNL
;~
        ;~ popa
        ;~ popf
        ret
DEBUG_Dump2     EndP



db_mbr              db "## MBR ##",10,0
db_masterlvm        db "## MLVMR ##",10,0

db_checkmath        db "## CHK MATH ##",10,0


db_config           db '## CFG (DMP2) ##',10,0
db_cfgparts         db 'CFG_Partitions:',0
db_cfgpartdef       db 'CFG_PartDefault:',0
db_cfgpartlast      db 'CFG_PartLast:',0


db_vars             db '## VARS ##',10,0
db_partsec          db 'PartitionSector:',10,0
;db_lvmsec           db 'LVMSector :',10,0
db_tmpec            db 'TmpSector :',10,0

db_newpart          db 'NewPartTable :',10,0
db_newhide          db 'NewHideTable:',10,0
db_dletters         db 'NewDriveLetters:',10,0

;db_partsize         db 'PartitionSizeTable:',10,0
;db_partpoint        db 'PartitionPointers:',10,0
;db_partpointcnt     db 'PartitionPointerCount:',0
;db_partxref         db 'PartitionXref:',10,0
;db_partvoldl        db 'PartitionVolumeLetters:',10,0

;db_totaldisks       db 'TotalHarddiscs:',0
;db_lbaswitchtab     db 'LBASwitchTable:',10,0
;db_newparts         db 'NewPartitions:',0

;db_exabspos         db 'ExtendedAbsPos:',0
;db_exabsposset      db 'ExtendedAbsPosSet:',0

db_curpartloc       db 'CurPartition_Location:',0
;db_curiox           db 'CurIO_UseExtension:',0

db_curlvmsec        db 'Current LVM Sector:',0


drive                   db 'drive                    : ',0
before_lvm_adjust       db 'before lvm adjust        : ',0
after_lvm_adjust        db 'after lvm adjust         : ',0
before_lvm_adjust_log   db 'before lvm logical adjust: ',0
after_lvm_adjust_log    db 'after lvm logical adjust : ',0
spt_used                db 'spt used                 : ',0
