
; Bad Test-Virus (c) Martin Kiewitz - For test of AiR-BOOT ANTIVIR

JUMPS

; First all Equs

ExecBaseSeg     equ     00000h
ExecBasePtr     equ     07C00h
BootBaseSeg     equ     8000h
BootBasePtr     equ     0h      ; We put our MBR to this location
BootBaseExec    equ     BootBasePtr+offset MBR_RealStart
StackSeg        equ     7000h

		.386p
                model large, basic

code_seg        segment public use16
                assume  cs:code_seg, ds:nothing, es:nothing, ss:nothing
                org     0000h


;---------------------------------------------------------------------------
air_boot:       cld
                mov     ax, ExecBaseSeg
                mov     ds, ax
                mov     si, ExecBasePtr
                mov     ax, BootBaseSeg
                mov     es, ax
                mov     di, BootBasePtr
                mov     cx, 256
                rep     movsw
                db      0EAh
                dw      BootBaseExec
                dw      BootBaseSeg
                ; jmp     far ptr BootBaseSeg:BootBaseExec

;        In: SI - Pointer to begin of string (EOS is 0)
; Destroyed: SI
MBR_Teletype                 Proc Near   Uses ax bx cx
   mov     ah, 0Eh
   mov     bx, 7
     MBR_Teletype_Loop:
      lodsb
      or      al, al
      jz      MBR_Teletype_End
      int     10h
      jmp     MBR_Teletype_Loop
  MBR_Teletype_End:
   ret
MBR_Teletype                 EndP

MBR_Virus_Message            db 'I''m a little MBR non-stealth virus...Come and get me', 13, 10, 0
;---------------------------------------------------------------------------
MBR_RealStart:  mov     ax, StackSeg
                mov     ss, ax
                mov     sp, 7FFFh
                mov     ax, es
                mov     ds, ax       ; Set DS to new segment
                ; Lade den fehlenden Part von der Festplatte

                mov     si, offset MBR_Virus_Message
                call    MBR_Teletype

                mov     ax, 8600h
                xor     cx, 100
                xor     dx, dx
                int     15h   ; Wait to display message

                mov     ax, ExecBaseSeg
                mov     es, ax
                mov     bx, ExecBasePtr
                mov     dx, 0080h         ; Erste HD, Sektor 50
                mov     cx, 0032h
                mov     ax, 0201h         ; 1 Sektor lesen
                int     13h

                db      0EAh
                dw      ExecBasePtr
                dw      ExecBaseSeg

code_seg	ends
		end	air_boot
