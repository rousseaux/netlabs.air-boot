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
;                                                      AiR-BOOT / VIDEO I/O
;---------------------------------------------------------------------------

VideoIO_WaitRetrace             Proc Near   Uses ax dx
   mov     dx, 3DAh
 VIOWR_Jump1:
   in      al, dx
   test    al, 8
   jnz     VIOWR_Jump1
 VIOWR_Jump2:
   in      al, dx
   test    al, 8
   jz      VIOWR_Jump2
   ret
VideoIO_WaitRetrace             EndP

; Holds the current position. Yeah, I know this is in the code area, but who
;  cares :))
TextPosY                     db     0h
TextPosX                     db     0h
TextColorFore                db     7h
TextColorBack                db     0h

;        In: CH - Cursor Column, CL - Cursor Row (Start at 1,1)
; Destroyed: None
VideoIO_Locate                  Proc Near   Uses cx
   or      ch, ch
   jz      VIOL_IgnoreY
   dec     ch
   mov     TextPosY, ch
  VIOL_IgnoreY:
   or      cl, cl
   jz      VIOL_IgnoreX
   dec     cl
   mov     TextPosX, cl
  VIOL_IgnoreX:
   ret
VideoIO_Locate                  EndP

;        In: CH - Cursor Column, CL - Center Cursor Row (Start at 1,1)
;            DX - Length to use for centering
; Destroyed: None
VideoIO_LocateToCenter          Proc Near   Uses cx dx
   shr     dl, 1                         ; Length / 2
   sub     cl, dl
   call    VideoIO_Locate
   ret
VideoIO_LocateToCenter          EndP

;        In: CH - Color Fore, CL - Color Back
; Destroyed: None
VideoIO_Color                   Proc Near   Uses cx
    mov    TextColorFore, CH
    mov    TextColorBack, CL
    ret
VideoIO_Color                   EndP

VideoIO_CursorOff               Proc Near   Uses ax cx
   mov     ax, 0102h                     ; 02 for fixup on AMI BIOS
   mov     cx, 1000h
   int     10h                           ; Clears cursor
   ret
VideoIO_CursorOff               EndP

VideoIO_CursorOn                Proc Near   Uses ax cx
   mov     ax, 0102h                     ; 02 for fixup on AMI BIOS
   mov     cx, 0F0Eh
   int     10h                           ; Builds cursor
   ret
VideoIO_CursorOn                EndP

VideoIO_CursorSet               Proc Near   Uses ax bx dx
   mov     ah, 02h
   xor     bh, bh
   mov     dh, TextPosY
   mov     dl, TextPosX
   int     10h
   ret
VideoIO_CursorSet               EndP

VideoIO_Internal_SetRegs        Proc Near   Uses bx
   mov     ax, VideoIO_Segment
   mov     es, ax
   movzx   ax, TextPosY
   mov     bl, 160
   mul     bl
   xor     bh, bh
   mov     bl, TextPosX
   shl     bl, 1
   add     ax, bx
   mov     di, ax                        ; Location at ES:DI
   mov     ah, TextColorFore
   mov     al, TextColorBack
   shl     al, 4
   or      ah, al                        ; Color Attribute in AH
   ret
VideoIO_Internal_SetRegs        EndP

;        In: SI - String to Print (EOS is 0)
; Destroyed: SI
VideoIO_Print                   Proc Near   Uses es di
   call    VideoIO_Internal_SetRegs
     VIOP_Loop:
      lodsb
      or      al, al
      jz      VIOP_End
      mov     es:[di], al
      mov     es:[di+1], ah
      add     di, 2
      inc     TextPosX
      jmp     VIOP_Loop
  VIOP_End:
   ret
VideoIO_Print                   EndP

;        In: SI - String to Print (EOS is 0)
; Destroyed: SI
VideoIO_PrintLikeLenOfName      Proc Near   Uses es di
   push    si
      xor     cx, cx
     VIOPLLON_Loop:
         lodsb
         inc     cx
      or      al, al
      jnz     VIOPLLON_Loop
   pop     si
   call    GetLenOfName                  ; Gets the real length...tricky ;)
   jz      VIOPLLON_Nul
   call    VideoIO_FixedPrint            ; we are lazy :)
  VIOPLLON_Nul:
   ret
VideoIO_PrintLikeLenOfName      EndP

;        In: SI - String to Print
;            CL - Len Of String
; Destroyed: SI
VideoIO_FixedPrint              Proc Near   Uses es di
   or      cl, cl
   jz      VIOFP_NoString
   call    VideoIO_Internal_SetRegs
  VIOFP_Loop:
      lodsb
      mov     es:[di], al
      mov     es:[di+1], ah
      add     di, 2
      inc     TextPosX
  dec      cl
  jnz      VIOFP_Loop
 VIOFP_NoString:
   ret
VideoIO_FixedPrint              EndP

;        In: AL - Single Char to Print
; Destroyed: None
VideoIO_PrintSingleChar         Proc Near   Uses ax es di
   mov     bl, al
   call    VideoIO_Internal_SetRegs
   mov     es:[di], bl
   mov     es:[di+1], ah
   inc     TextPosX
   ret
VideoIO_PrintSingleChar         EndP

;        In: AL - Single Char to Print
;            CL - Times to print it
; Destroyed: None
VideoIO_PrintSingleMultiChar    Proc Near   Uses ax cx es di
   or      cl, cl
   jz      VIOPSMC_NoChars
   mov     bl, al
   call    VideoIO_Internal_SetRegs
  VIOPSMC_Loop:
      mov     es:[di], bl
      mov     es:[di+1], ah
      add     di, 2
      inc     TextPosX
   dec     cl
   jnz     VIOPSMC_Loop
  VIOPSMC_NoChars:
   ret
VideoIO_PrintSingleMultiChar    EndP

; Will print a number to screen (2 bytes t.m. 0-99)
;        In: AL - Single Byte to Print
; Destroyed: None
VideoIO_PrintByteNumber         Proc Near   Uses ax bx dx es di
   cmp     al, 99
   ja      VIOPBN_DoNotWriteAnything
   movzx   bx, al
   call    VideoIO_Internal_SetRegs
   cmp     bl, 10
   jb      VIOPBN_Lower10
   push    ax
      movzx   ax, bl
      mov     dl, 10
      div     dl
      mov     bh, al                     ; BH = Upper Number
      mov     bl, ah                     ; BL = Rest
   pop     ax
 VIOPBN_Lower10:
   add     bh, 30h
   add     bl, 30h
   mov     es:[di], bh
   mov     es:[di+1], ah
   mov     es:[di+2], bl
   mov     es:[di+3], ah
 VIOPBN_DoNotWriteAnything:
   add     TextPosX, 2
   ret
VideoIO_PrintByteNumber         EndP

; Will print a number to screen (dynamic bytes from 0 to 255)
;        In: AL - Single Byte to Print
; Destroyed: None
VideoIO_PrintByteDynamicNumber  Proc Near   Uses ax bx dx es di
   xor     cl, cl
   mov     bh, al
   call    VideoIO_Internal_SetRegs
   xchg    bh, ah                        ; Exchange backgroundcolor with Number
   cmp     ah, 10
   jb      VIOPBDN_Lower10
   cmp     ah, 100
   jb      VIOPBDN_Lower100
   movzx   ax, ah
   mov     dl, 100
   div     dl
   add     al, 30h
   mov     es:[di], al
   mov     es:[di+1], bh
   inc     TextPosX
   add     di, 2
 VIOPBDN_Lower100:
   movzx   ax, ah
   mov     dl, 10
   div     dl
   add     al, 30h
   mov     es:[di], al
   mov     es:[di+1], bh
   inc     TextPosX
   add     di, 2
 VIOPBDN_Lower10:
   add     ah, 30h
   mov     es:[di], ah
   mov     es:[di+1], bh
   inc     TextPosX
   add     di, 2
   ret
VideoIO_PrintByteDynamicNumber  EndP


;        In: AL - Zeichen zum Zeichnen, CL - Wie oft
; Destroyed: None Important
VideoIO_Internal_MakeWinDown    Proc Near   Uses dx di
   movzx   dx, cl
   mov     bl, al
   call    VideoIO_Internal_SetRegs
   mov     al, bl
  VIOIMWD_Loop:
      mov     es:[di], al
      mov     es:[di+1], ah
      add     di, 160
      inc     TextPosY
   dec     dx
   jnz     VIOIMWD_Loop
   ret      
VideoIO_Internal_MakeWinDown    EndP

;        In: AL - Zeichen zum Zeichnen, CL - Wie oft
; Destroyed: None Important
VideoIO_Internal_MakeWinRight   Proc Near   Uses dx di
   movzx  dx, cl
   mov    bl, al
   call   VideoIO_Internal_SetRegs
   mov    al, bl
  VIOIMWR_Loop:
      mov    es:[di], al
      mov    es:[di+1], ah
      add    di, 2
      inc    TextPosX
      dec    dx
   jnz    VIOIMWR_Loop
   ret      
VideoIO_Internal_MakeWinRight   EndP

WinBeginPosY    db        0h
WinBeginPosX    db        0h
WinEndPosY      db        0h
WinEndPosX      db        0h
WinCharRight    db      0CDh
WinCharDown     db      0B3h
WinCharBB       db      0D5h
WinCharBE       db      0B8h
WinCharEB       db      0D4h
WinCharEE       db      0BEh

;        In: BX - Begin Position, DX - End Position
; Destroyed: BX DX
VideoIO_MakeWindow              Proc Near   Uses ax bx cx es di
   mov     WinBeginPosY, bh
   mov     WinBeginPosX, bl
   mov     WinEndPosY, dh
   mov     WinEndPosX, dl
   mov     cx, bx
   inc     ch
   call    VideoIO_Locate                ; StartPos left line
   mov     cl, WinEndPosY
   sub     cl, WinBeginPosY
   dec     cl
   mov     al, WinCharDown
   push    cx
   call    VideoIO_Internal_MakeWinDown
   mov     ch, WinBeginPosY
   mov     cl, WinEndPosX
   inc     ch
   call    VideoIO_Locate                ; StartPos right line
   pop     cx
   mov     al, WinCharDown
   call    VideoIO_Internal_MakeWinDown
   ; Left & Right are already done...
   mov     ch, WinBeginPosY
   mov     cl, WinBeginPosX
   call    VideoIO_Locate                ; StartPos upper line
   mov     al, WinCharBB
   call    VideoIO_PrintSingleChar
   mov     cl, WinEndPosX
   sub     cl, WinBeginPosX
   dec     cl
   mov     al, WinCharRight
   push    cx
   call    VideoIO_Internal_MakeWinRight
   mov     al, WinCharBE
   call    VideoIO_PrintSingleChar
   mov     ch, WinEndPosY
   mov     cl, WinBeginPosX
   call    VideoIO_Locate                ; StartPos lower line
   mov     al, WinCharEB
   call    VideoIO_PrintSingleChar
   pop     cx
   mov     al, WinCharRight
   call    VideoIO_Internal_MakeWinRight
   mov     al, WinCharEE
   call    VideoIO_PrintSingleChar
   ; Frame done, now just filling...
   mov     bh, WinEndPosY
   sub     bh, WinBeginPosY
   dec     bh
   mov     bl, WinEndPosX
   sub     bl, WinBeginPosX
   dec     bl
 
  VIOIMW_Loop:
      mov     ch, WinBeginPosY
      add     ch, bh
      mov     cl, WinBeginPosX
      inc     cl
      call    VideoIO_Locate

      mov     al, 20h
      mov     cl, bl
      push    bx
      call    VideoIO_Internal_MakeWinRight
      pop     bx
   dec     bh
   jnz     VIOIMW_Loop
   ret
VideoIO_MakeWindow              EndP

;        In: AX - Segment to copy B800 to...
; Destroyed: BX DX
VideoIO_BackUpTo                Proc Near   Uses cx ds si es di
   mov     es, ax
   mov     ax, 0B800h
   mov     ds, ax
   xor     si, si
   xor     di, di
   mov     cx, 800h                         ; Copy 1000h bytes
   rep     movsw
   ret
VideoIO_BackUpTo                EndP

VideoIO_RestoreFrom             Proc Near   Uses cx ds si es di
   mov     ds, ax
   mov     ax, 0B800h
   mov     es, ax
   xor     si, si
   xor     di, di
   mov     cx, 800h                         ; Copy 1000h bytes
   rep     movsw
   ret
VideoIO_RestoreFrom             EndP

;        In: CL - Total Length of String
;            DS:SI - Actual String
;       Out: Carry Set if String was ENTERd
; Destroyed: *none*
VideoIO_LetUserEditString       Proc Near   Uses ax bx cx dx si es di
   local StartPosX:byte, LastPosX:byte
   local StringLen:byte

   or      cl, cl
   jnz     VIOLUES_LenNotNUL
   clc
   ret

  VIOLUES_LenNotNUL:
   mov     al, TextPosX
   inc     al
   mov     StartPosX, al
   mov     StringLen, cl

   push    cx
      call    VideoIO_Internal_SetRegs   ; ES:DI - Pos on Screen at Start

      xor     ch, ch
      call    GetLenOfName               ; CX - Actual Length of String
      mov     dl, cl

      ; Set Cursor behind String and turn it on...
      add     cl, StartPosX
      call    VideoIO_Locate
      call    VideoIO_CursorSet
      call    VideoIO_CursorOn           ; Set and turn cursor on
      
      ; ES:DI - Screen-Position to Start of String
      ; DL    - Position in String (relative to begin, base=0)

     VIOLUES_Loop:
         mov     ah, 0
         int     16h
         cmp     ah, Keys_ESC
         je      VIOLUES_KeyESC
         cmp     ah, Keys_Enter
         je      VIOLUES_KeyENTER
         cmp     ah, Keys_Backspace
         je      VIOLUES_KeyBACKSPACE
         ; Check for valid char...
         cmp     al, 32
         jb      VIOLUES_Loop
         cmp     al, 166
         ja      VIOLUES_Loop
         ; Okay, Character to add to string
         cmp     dl, StringLen           ; String "full" ?
         jae     VIOLUES_Loop
         movzx   bx, dl
         shl     bx, 1
         mov     es:[di+bx], al
         inc     dl
        VIOLUES_UpdateCursor:
         mov     cl, dl
         add     cl, StartPosX
         call    VideoIO_Locate
         call    VideoIO_CursorSet
         jmp     VIOLUES_Loop

        VIOLUES_KeyBACKSPACE:
         or      dl, dl                  ; String "empty" ?
         jz      VIOLUES_Loop
         mov     al, ' '
         dec     dl
         movzx   bx, dl
         shl     bx, 1
         mov     es:[di+bx], al
         jmp     VIOLUES_UpdateCursor

  VIOLUES_KeyESC:
   pop     cx
   call    VideoIO_CursorOff             ; Bye Bye cursor
   clc
   ret

  VIOLUES_KeyENTER:
   pop     cx
   ; ENTERd, so copy data to String-Pointer...
  VIOLUES_CopyLoop:
      mov     al, es:[di]
      add     di, 2
      mov     ds:[si], al
      inc     si
   dec     cl
   jnz     VIOLUES_CopyLoop
   ; Finally Cursor off-line...
   call    VideoIO_CursorOff
   stc
   ret
VideoIO_LetUserEditString       EndP
