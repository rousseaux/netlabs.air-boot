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

IFDEF ModuleNames
DB 'VIDEOIO',0
ENDIF

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
   ;movzx   ax, TextPosY
   mov   al,TextPosY
   mov   ah,0

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
VideoIO_PrintLikeLenOfName      Proc Near   Uses cx es di
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

; Rousseau:
; Turn off blinking
; http://www.ctyme.com/intr/rb-0088.htm does not mention this
VideoIO_NoBlinking              Proc Near   Uses ax bx
      mov      bx,0
      mov      ax,1003h
      int      10h
   ret
VideoIO_NoBlinking              EndP

;        In: AL - Single Char to Print
; Destroyed: None
VideoIO_PrintSingleChar         Proc Near   Uses ax bx es di
    mov     bl, al
    call    VideoIO_Internal_SetRegs
    mov     es:[di], bl
    mov     es:[di+1], ah
    inc     TextPosX
    ret
VideoIO_PrintSingleChar         EndP



; Print hex-byte to screen
; This outputs two characters
; In:          AL - byte to send
; Out:         AL - byte sent
; Destroyed:   None
VideoIO_PrintHexByte    Proc     Near  Uses  ax
      call     CONV_BinToAsc              ; Returns high hex-nibble in AH, low hex-nibble in AL
      xchg     al,ah                      ; High hex-nibble first
      call     VideoIO_PrintSingleChar    ; Output to screen
      xchg     al,ah                      ; Low hex-nibble next
      call     VideoIO_PrintSingleChar    ; Output to screen
      ret
VideoIO_PrintHexByte    EndP


; Print hex-word to screen
; This outputs four characters
; In:          AX - word to send
; Out:         AX - word sent
; Destroyed:   None
VideoIO_PrintHexWord    Proc     Near
      xchg     al,ah                      ; High byte first
      call     VideoIO_PrintHexByte       ; Output to screen
      xchg     al,ah                      ; low byte next
      call     VideoIO_PrintHexByte       ; Output to screen
      ret
VideoIO_PrintHexWord    EndP


; Print hex-dword to screen
; This outputs eight characters
; In:          DX:AX - dword to send
; Out:         DX:AX - dword sent
; Destroyed:   None
VideoIO_PrintHexDWord   Proc     Near
      xchg     ax,dx
      call     VideoIO_PrintHexWord       ; High word first
      xchg     ax,dx
      call     VideoIO_PrintHexWord       ; Low word next
      ret
VideoIO_PrintHexDWord   EndP


; Print hex-qword to screen
; This outputs sixteen characters
; In:          BX:CX:DX:AX - qword to send
; Out:         BX:CX:DX:AX - qword sent
; Destroyed:   None
VideoIO_PrintHexQWord   Proc     Near
      xchg     dx,bx
      xchg     ax,cx
      call     VideoIO_PrintHexDWord      ; High dword first
      xchg     dx,bx
      xchg     ax,cx
      call     VideoIO_PrintHexDWord      ; Low dword next
      ret
VideoIO_PrintHexQWord   EndP





;        In: AL - Single Char to Print
;            CL - Times to print it
; Destroyed: None
VideoIO_PrintSingleMultiChar    Proc Near   Uses ax bx cx es di
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
   ;movzx   bx, al
   mov   bl,al
   mov   bh,0

   call    VideoIO_Internal_SetRegs
   cmp     bl, 10
   jb      VIOPBN_Lower10
   push    ax
      ;movzx   ax, bl
      mov   al,bl
      mov   ah,0

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
VideoIO_PrintByteDynamicNumber  Proc Near   Uses ax bx cx dx es di               ; Rousseau: cx was missing from push-list
   xor     cl, cl
   mov     bh, al
   call    VideoIO_Internal_SetRegs
   xchg    bh, ah                        ; Exchange backgroundcolor with Number
   cmp     ah, 10
   jb      VIOPBDN_Lower10
   cmp     ah, 100
   jb      VIOPBDN_Lower100
   ;movzx   ax, ah
   mov   al,ah
   mov   ah,0

   mov     dl, 100
   div     dl
   add     al, 30h
   mov     es:[di], al
   mov     es:[di+1], bh
   inc     TextPosX
   add     di, 2
 VIOPBDN_Lower100:
   ;movzx   ax, ah
   mov   al,ah
   mov   ah,0

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
   ;movzx   dx, cl
   mov   dl,cl
   mov   dh,0

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
   ;movzx  dx, cl
   mov   dl,cl
   mov   dh,0

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
         ;movzx   bx, dl
         mov   bl,dl
         mov   bh,0

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
         ;movzx   bx, dl
         mov   bl,dl
         mov   bh,0

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



;
; Rousseau Additions.
;


; Function Template
;ProcName                        Proc Near   Uses ax bx cx dx si es di
;ProcName                        EndP


;
; Clear the current page
;
VideoIO_ClearScreen             Proc Near   Uses ax bx cx dx si es di
   mov   al, 0       ; clear entire window
   mov   bh,07h      ; Attribute for new lines
   xor   cx,cx       ; Row, Column ULC
   xor   dx,dx
   dec   dx          ; Row, Column LRC (does this corrupt other pages ?)
   mov   ah, 06h     ; Function Code
   int   10h         ; Do It !
   ret
VideoIO_ClearScreen             EndP

;
; Set position to teletype cursor
;
VideoIO_SyncPos                 Proc Near   Uses ax bx cx dx
   pushf
   mov   bh, 0
   mov   ah, 03h
   int   10h
   mov   [TextPosX], dl
   mov   [TextPosY], dh
   popf
   ret
VideoIO_SyncPos                 EndP



VideoIO_DBG_WriteString         Proc Near   Uses ax bx cx dx si es di
   mov   ch, [CFG_Partitions]                                                    ; y
   add   ch, 7
   add   ch, [CFG_IncludeFloppy]
   push cx
   mov   cl, 1                                                                   ; x
   call  VideoIO_Locate
   mov   ch, 15                                                                  ; fgc
   mov   cl, 0                                                                   ; bgc
   call  VideoIO_Color
   mov   si, offset ShowBootLog
   call  VideoIO_Print
   pop cx
   inc   ch

   ;mov   ch, 21                                                                 ; y
   mov   cl, 1                                                                   ; x
   call  VideoIO_Locate
   mov   ch, 15                                                                  ; fgc
   mov   cl, 0                                                                   ; bgc
   call  VideoIO_Color


   ; Rousseau:
   mov al, [NewPartitions]
   ;call  VideoIO_PrintByteDynamicNumber
   mov al, [CFG_Partitions]
   ;call  VideoIO_PrintByteDynamicNumber
   ret
VideoIO_DBG_WriteString         EndP


; Dump the disk-info.
; Disk number is in DL.
VideoIO_DumpDiskInfo    Proc Near uses ax bx cx dx

   VideoIO_DumpDiskInfo_next_disk:
      push     dx
      xor      ax,ax
      mov      al,[TextPosY]
      push     ax

      mov      ax,21
      mov      dh,dl
      and      dh,01111111b
      mul      dh
      mov      dh,al

      mov      [TextPosX],dh

      mov   si, offset Disk
      call  VideoIO_Print
      mov   al,dl

      ; NIET GOED, GAAT FOUT > 9, HEX PRINT GEBRUIKEN !!
      shr      al,4
      add      al,'0'
      call     VideoIO_PrintSingleChar
      mov      al,dl
      and      al,01111111b
      add      al,'0'
      call     VideoIO_PrintSingleChar
      mov      al,'h'
      call     VideoIO_PrintSingleChar

      inc      [TextPosY]
      mov      [TextPosX],dh

      mov      al,'-'
      mov      cl,17
      call     VideoIO_PrintSingleMultiChar

;      inc      [TextPosY]
;      mov      [TextPosX],dh
;      mov      si, offset BiosCyls
;      call     VideoIO_Print

;      push     dx
;      mov      bx,offset BIOS_Cyls
;      xor      dh,dh
;      and      dl,01111111b
;      shl      dx,1
;      shl      dx,1
;      add      bx,dx
;      mov      ax,[bx]
;      mov      dx,[bx+02]
;      call     VideoIO_PrintHexDWord
;      pop      dx

      inc      [TextPosY]
      mov      [TextPosX],dh
      mov      si, offset BiosHeads
      call     VideoIO_Print

      push     dx
      mov      bx,offset BIOS_Heads
      xor      dh,dh
      and      dl,01111111b
      shl      dx,1
      shl      dx,1
      add      bx,dx
      mov      ax,[bx]
      mov      dx,[bx+02]
      call     VideoIO_PrintHexDWord
      pop      dx

      inc      [TextPosY]
      mov      [TextPosX],dh
      mov      si, offset BiosSecs
      call     VideoIO_Print

      push     dx
      mov      bx,offset BIOS_Secs
      xor      dh,dh
      and      dl,01111111b
      shl      dx,1
      shl      dx,1
      add      bx,dx
      mov      ax,[bx]
      mov      dx,[bx+02]
      call     VideoIO_PrintHexDWord
      pop      dx

      inc      [TextPosY]
      mov      [TextPosX],dh
      mov      si, offset LvmSecs
      call     VideoIO_Print

      push     dx
      ; Offset of array containing LVM SPT values for each disk found
      mov      bx,offset TrueSecs
      ; DX to index
      xor      dh,dh
      and      dl,01111111b
      shl      dx,1
      shl      dx,1
      add      bx,dx
      ; Get LVM SPT
      mov      ax,[bx]
      mov      dx,[bx+02]
      call     VideoIO_PrintHexDWord
      pop      dx

      inc      [TextPosY]
      mov      [TextPosX],dh
      mov      si, offset BiosLBA
      call     VideoIO_Print

      push     dx
      mov      bx,offset BIOS_TotalSecs
      xor      dh,dh
      and      dl,01111111b
      shl      dx,1
      shl      dx,1
      shl      dx,1
      add      bx,dx
      mov      ax,[bx]
      mov      dx,[bx+02]
      call     VideoIO_PrintHexDWord
      pop      dx

      inc      [TextPosY]
      mov      [TextPosX],dh

      pop      ax
      mov      [TextPosY],al
      pop      dx

      inc      dl
      mov      al,dl
      and      al,01111111b
      cmp      al,[TotalHarddiscs]
      jae      VideoIO_DumpDiskInfo_end
      jmp      VideoIO_DumpDiskInfo_next_disk

   VideoIO_DumpDiskInfo_end:
      mov      [TextPosX],0
      add      [TextPosY],6
      ret
VideoIO_DumpDiskInfo    EndP



; Disk Info to Dump to AB LogScreen
Disk:             db "DISK ",0
BiosCyls:         db "Cyls    :",0
BiosHeads:        db "Heads   :",0
BiosSecs:         db "Secs    :",0
LvmSecs:          db "SecsLVM :",0
BiosLBA:          db "LBA Secs:",0


HugeBootDisk:     db "Boot Disk is Huge    : ",0
DisksFound:       db "Disks Found          : ",0
PartitionsFound:  db "Partitions Found     : ",0
;AutoStartPart:    db "Auto Start Partition : ",0

Phase1:           db "eCS Install Phase 1  : ",0


ShowMenu:         db "Press TAB to return to the AiR-BOOT Menu",0
ShowBootLog:      db "Press TAB to see the Boot Log...",0

Yes:              db "YES",0
No:               db "NO",0
On:               db "ON",0
Off:              db "OFF",0
None:             db "NONE",0
Active:           db "ACTIVE",0
NotActive:        db "NOT ACTIVE",0

; New Line for use by MBR_Teletype
NL:         db 0dh, 0ah, 0
