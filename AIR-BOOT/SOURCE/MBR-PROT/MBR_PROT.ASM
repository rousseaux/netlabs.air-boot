
; Disclaimer:
;=============
; The sourcecode is released via www.netlabs.org CVS *ONLY*.
;  You MUST NOT upload it to other servers nor republish it in any way.
;  The sourcecode is still COPYRIGHTED and NOT YET RELEASED UNDER GPL.
;  It's (c) Copyright 1998-2002 by Martin Kiewitz.
;  You may recompile the source and do *PRIVATE* modifications, but please keep
;  in mind that modifying this code needs at least *some* assembly skill. If
;  you mess up your system, because you needed to hack your way through, don't
;  blame me. Releasing a customized version of AiR-BOOT, selling it in any form
;  or reusing parts of this source is *PROHIBITED*. Ask me, if you have some
;  idea about new functionality *before* developing the code, otherwise I will
;  definitely reject it. Also please accept, that I have some basic design
;  rules on AiR-BOOT and I will maintain them at all costs, so this won't get
;  another GRUB.

;---------------------------------------------------------------------------
;                         AiR-BOOT SETUP / GENERIC & GENERAL SETUP ROUTINES
;---------------------------------------------------------------------------

                .386p
                .model large, basic

code_seg        segment public use16
                assume cs:code_seg, ds:nothing, es:nothing, ss:nothing
                org 0000h

OldInterrupt10  dd      'kcuf'              ; we are nice aren't we ;-)
OldInterrupt13  dd      'kcuf'
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

MBRProt_WriteLine              Proc Near
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

MBRP_Line1:     db      'ีออด!ATTENTION! -> A VIRUS WAS FOUND <- !ATTENTION!รออธ'
MBRP_EmptyLine: db      'ณ                                                     ณ'
                db      'ณ A program tried to write to your Master Boot Record ณ'
                db      'ณ     AiR-BOOT supposes this as a viral act, so it    ณ'
                db      'ณ        intercepted it and crashed the system.       ณ'
MBRP_Line2:     db      'ณ If you tried to install a OS or something like that ณ'
                db      'ณ  you have to deactivate MBR PROTECTION in AiR-BOOT  ณ'
                db      'ณ             or contact your supervisor.             ณ'
MBRP_Line3:     db      'ิออออดAiR-BOOT (c) Copyright by Martin Kiewitz ''99รอออพ'

code_seg        EndS
                end
