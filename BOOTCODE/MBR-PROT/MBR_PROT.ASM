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
;                         AiR-BOOT SETUP / GENERIC & GENERAL SETUP ROUTINES
;---------------------------------------------------------------------------
                ;
                ; First define processor so when a model is specified
                ; the correct default segments are created.
                ;
                .286
                ;.model large,c

;_TEXT           SEGMENT     USE16   PUBLIC  'CODE'
;_TEXT           ENDS

MBRPROT         GROUP       CODE_SEG
;DGROUP          GROUP       CODE_SEG

CODE_SEG        SEGMENT     USE16   PUBLIC  'CODE'

                ;assume cs:MBRPROT, ds:MBRPROT, es:nothing, ss:nothing
                assume cs:MBRPROT, ds:MBRPROT, es:nothing, ss:nothing

                org 0000h
                .386p

; Yes you are :-)
;OldInterrupt10  dd      'kcuf'              ; we are nice aren't we ;-)
;OldInterrupt13  dd      'kcuf'

OldInterrupt10  dd      0
OldInterrupt13  dd      0

MBR_IgnoreWrite db      0

MBRP_Routine:
    cmp     ah, 03h
    je      MBRP_NormalWriteTest
    cmp     ah, 0Bh
    je      MBRP_NormalWriteTest
    cmp     ah, 43h
    je      MBRP_ExtendedWriteTest
  MBRP_ResumeCall:
    jmp     dword ptr cs:[OldInterrupt13]

  MBRP_NormalWriteTest:
    cmp     ch, 0
    jne     MBRP_ResumeCall
    cmp     dh, 0
    jne     MBRP_ResumeCall
    ; We don't mind which sector, AiR-BOOT is everywhere ;-)
    test    dl, 80h
    jz      MBRP_ResumeCall
    jmp     MBRP_FakeOkay

  MBRP_ExtendedWriteTest:
    cmp     word ptr ds:[si+0Eh], 0
    jne     MBRP_ResumeCall
    cmp     word ptr ds:[si+0Ch], 0
    jne     MBRP_ResumeCall
    cmp     word ptr ds:[si+0Ah], 0
    jne     MBRP_ResumeCall
    cmp     word ptr ds:[si+08h], 63  ; If Logical Block-Number =>63
    jae     MBRP_ResumeCall
    jmp     MBRP_FakeOkay

  MBRP_FakeOkay:
    test    cs:[MBR_IgnoreWrite], 1
    jz      MBRP_CrunchSession
    xor     ah, ah
    clc
    retf 2

   MBRP_CrunchSession:
    ; We are ruining registers here, but we won't get back to caller...
    mov     ax, 03h                        ; Graphic: Set Mode 3
    pushf
    call    dword ptr cs:[OldInterrupt10]

    mov     ax, cs
    mov     ds, ax
    mov     ax, 0B800h
    mov     es, ax
    xor     di, di
    mov     ax, 4F20h
    mov     cx, 2000h                       ; Clears whole screen (using RED)
    rep     stosw

    mov     si, offset MBRP_Line1
    mov     di, 1120
    call    MBRProt_WriteBorderLine
    mov     cx, 4
    call    MBRProt_WriteLine
    mov     si, offset MBRP_EmptyLine
    mov     cx, 1
    call    MBRProt_WriteLine
    mov     si, offset MBRP_Line2
    mov     cx, 3
    call    MBRProt_WriteLine
    mov     si, offset MBRP_EmptyLine
    mov     cx, 1
    call    MBRProt_WriteLine
    mov     si, offset MBRP_Line3
    call    MBRProt_WriteBorderLine

    mov     ax, 8600h
    xor     cx, cx
    mov     dx, 500
    int     15h                             ; Wait for display...
   WindowsProcessing:
    cli
    jmp     WindowsProcessing

MBRProt_WriteLine              Proc Near    Uses ax bx cx dx
    add     di, 26
    mov     ah, 4Ch                      ; red/brightred
    lodsb
    stosw
    mov     ah, 4Fh                      ; red/brightwhite
    mov     dx, 53
   MBRP_WriteChar:
      lodsb
      stosw
      dec     dx
      jnz     MBRP_WriteChar
    mov     ah, 4Ch                      ; red/brightred
    lodsb
    stosw
    add     di, 24
    dec     cx
    jnz     MBRProt_WriteLine
    ret
MBRProt_WriteLine              EndP

MBRProt_WriteBorderLine        Proc Near
   add     di, 26
   mov     ah, 4Ch
   mov     dx, 55
  MBRP_WriteBorderChar:
      lodsb
      stosw
   dec     dx
   jnz     MBRP_WriteBorderChar
   add     di, 24
   ret
MBRProt_WriteBorderLine        EndP

MBRP_Line1      db      'ÕÍÍ´!ATTENTION! -> A V1RU5 WAS FOUND <- !ATTENTION!ÃÍÍ¸'
MBRP_EmptyLine  db      '³                                                     ³'
                db      '³ A program tried to write to your Master Boot Record ³'
                db      '³     AiR-BOOT supposes this as a viral act, so it    ³'
                db      '³        intercepted it and crashed the system.       ³'
MBRP_Line2      db      '³ If you tried to install a OS or something like that ³'
                db      '³  you have to deactivate MBR PROTECTION in AiR-BOOT  ³'
                db      '³             or contact your supervisor.             ³'
;MBRP_Line3      db      'ÔÍÍÍ´AiR-BOOT (c) Copyright by M. Kiewitz 1999-2009ÃÍÍ¾'
MBRP_Line3      db      'ÔÍÍÍ´AiR-BOOT (c) Copyright by M. Kiewitz 1999-2012ÃÍÍ¾'

org             1023
                db 0

CODE_SEG        ENDS
                end
