
; Disclaimer:
;=============
; The sourcecode is released via www.netlabs.org CVS *ONLY*.
;  You MUST NOT upload it to other servers nor republish it in any way.
;  The sourcecode is still COPYRIGHTED and NOT RELEASED UNDER GPL.
;  It's (c) Copyright 1998-2003 by Martin Kiewitz.
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
;                                                AiR-BOOT / CHARSET SUPPORT
;---------------------------------------------------------------------------

; This file is only included, when compiling versions that are meant to
;  contain special characters that are not included in the Video ROM charset.

; May destroy all-purpose registers (AX,BX,CX,DX), will preserve all others
CHARSET_IncludeCyrillic        Proc Near  Uses si di bp
   ; First we get the ROM charset from BIOS...
   mov    ax, 1130h
   mov    bh, 6                          ; Get ROM VGA 25x80 charset
   int    10h                            ; VIDEO BIOS: Get charset table pointer
   mov    bx, ds                         ; ES:BP point to charset (in Video-ROM)
   mov    ax, es
   mov    es, bx
   mov    ds, ax
   mov    si, bp                         ; DS:SI - ROM Font 25x80 and ES==CS
   mov    di, offset CharsetTempBuffer
   mov    cx, 2048
   rep    movsw                          ; Copy ROM-charset to Temp-Buffer
   mov    ds, bx                         ; DS==CS
   mov    si, offset CHARSET_Cyrillic
   mov    di, offset CharSetTempBuffer+2048

   mov    dl, 64                         ; Decode 64 character bitmaps
   xor    al, al
   xor    ch, ch
  DecodeLoop:                            ; This is an uncompressing-loop
      mov    ah, ds:[si]
      inc    si
      mov    cl, ah
      and    cl, 0Fh
      rep    stosb                       ; Write NULs, count: lower 4 bits
      mov    cl, ah
      shr    cl, 4
      or     cl, cl
      jz     EndOfStream
      rep    movsb
      jmp    DecodeLoop
     EndOfStream:
      cmp    di, offset CharSetTempBuffer+3840
      jae    DecodeDone
      add    di, 768                     ; Skip 3x16 char blocks
      jmp    DecodeLoop
  DecodeDone:
   call   FX_WaitRetrace                 ; Wait for retrace to reduce flickering
   mov    ax, 1110h
   mov    bh, 16
   xor    bl, bl
   mov    cx, 0FFh
   xor    dx, dx
   mov    bp, offset CharSetTempBuffer ; ES:BP - New charset
   int    10h                            ; VIDEO BIOS: Set new charset table
   mov    ah, 12h
   mov    bl, 30h
   mov    al, 2                          ; 400 ScanLines
   int    10h                            ; VIDEO BIOS: Set Scanlines
   ret
CHARSET_IncludeCyrillic        EndP
