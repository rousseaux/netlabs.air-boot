
Public INST_Virus_CheckCurrentMBR
Public INST_Virus_CheckForBackUpMBR
Public INST_Virus_CheckForStealth
Public INST_Virus_CopyBackUpMBR

; -----------------------------------------------------------------------------

CheckThisMBR                    Proc Near
   cmp     wptr [esi+01FEh], 0AA55h
   jne     InvalidMBR
   xor     cx, cx                         ; No entries checked
   xor     dx, dx                         ; No entries in MBR
   add     esi, 446                       ; Auf start Partition table seeken
  PartitionLoop:
      mov     al, [esi+3]                 ; Cylinder
      mov     ah, [esi+2]
      shr     ah, 6                       ; oberen Bits von Cylinder
      shl     eax, 16                     ; bringt Cylinder nach EAX[16-31]
      mov     ah, [esi+1]                 ; Seite nach EAX[8-15]
      mov     al, [esi+2]
      and     al, 111111b                 ; Sektor nach EAX[0-7]
      ; Anfangs-Wert fertig
      mov     bl, [esi+7]                 ; Cylinder
      mov     bh, [esi+6]
      shr     bh, 6                       ; oberen Bits von Cylinder
      shl     ebx, 16                     ; bringt Cylinder nach EAX[16-31]
      mov     bh, [esi+5]                 ; Seite nach EAX[8-15]
      mov     bl, [esi+6]
      and     bl, 111111b                 ; Sektor nach EAX[0-7]
      ; Anfangs-Wert fertig
      cmp     eax, ebx                    ; vergleichen, falls Begin kleiner
      ja      InvalidMBR

      inc     cx
      cmp     bptr [esi+4], 0             ; nur falls was definiert ist
      je      ValidButNone
      cmp     wptr [esi+14], 0            ; Absolute mit 0 vergleichen,
      jne     ValidOne                    ; falls ==0 -> Fehlerhaft
      cmp     wptr [esi+12], 0
      je      InvalidMBR
     ValidOne:
      inc     dx
     ValidButNone:
      add     esi, 16
   cmp     cx, 4
   jne     PartitionLoop
   cmp     dx, 1
   jb      InvalidMBR
   mov     eax, 1
   ret
  InvalidMBR:
   xor     eax, eax
   ret
CheckThisMBR                    EndP

; This routine is called to check current MBR for validity
INST_Virus_CheckCurrentMBR      Proc Near   Uses ebx ecx edx esi edi
   mov     esi, offset MBR_CurrentSectors
   call    CheckThisMBR
   ret
INST_Virus_CheckCurrentMBR      EndP

INST_Virus_CheckForBackUpMBR    Proc Near   Uses ebx ecx edx esi edi
   mov     esi, offset MBR_CurrentSectors+7600h ; Sector 60 contains backup
   call    CheckThisMBR
   ret
INST_Virus_CheckForBackUpMBR    EndP

INST_Virus_CheckForStealth      Proc Near   Uses ebx ecx edx esi edi
   mov     esi, offset MBR_CurrentSectors
   xor     bx, bx
  CheckLoop:
      cmp     esi, offset MBR_CurrentSectors+512
      ja      EndLoop
      lodsb
      cmp     al, 0CDh
      jne     CheckLoop
      cmp     bptr [esi], 13h
      jne     CheckLoop
      inc     bx
      jmp     CheckLoop
  EndLoop:
   xor     eax, eax
   or      bx, bx                        ; If no CD13h found -> possibly Stealth
   jnz     NotStealth
   inc     eax
  NotStealth:
   ret
INST_Virus_CheckForStealth      EndP

; Copies BackUp MBR into current MBR area, so it will get installed
INST_Virus_CopyBackUpMBR       Proc Near  Uses ecx esi edi
   mov     esi, offset MBR_CurrentSectors+7600h ; Sector 60
   mov     edi, offset MBR_CurrentSectors       ;  -> to Sector 1
   mov     ecx, 256
   rep     movsw                         ; Copies 1 sector...
   ret
INST_Virus_CopyBackUpMBR       EndP
