
Public INST_Add_IncludeCode
Public INST_Add_IncludeConfig

; -----------------------------------------------------------------------------

; This routine is called, if Code-Image has to be included into
;  MBR_CurrentSectors for later writing to harddrive.
INST_Add_IncludeCode            Proc Near   Uses ebx ecx edx esi edi
   ; Sector 2 (start of code-image)
   mov     esi, AiRBOOT_ImageSectorsPtr
   add     esi, 512
   xor     bx, bx
   movzx   ecx, bptr [AiRBOOT_ImageSectors+16]
 CalcCodeCheck:
      call    GetCheckOfSector
   loop    CalcCodeCheck
   ; Set checksum in MBR...
   mov     wptr [AiRBOOT_ImageSectors+11h], bx
   ; -------------------------------------------------------------------------
   ; Now copy everything to MBR_CurrentSectors and overwrite what is there...
   mov     esi, AiRBOOT_ImageSectorsPtr
   mov     edi, offset MBR_CurrentSectors
   mov     ecx, 1B8h/2
   rep     movsw                         ; Copy till 1B8h (Windoze NT hdd sig)
   add     esi, 72
   add     edi, 72                       ; Skip till Sector 2
   movzx   edx, bptr [AiRBOOT_ImageSectors+16]
  SectorCopyLoop:
      mov     ecx, 256
      rep     movsw                      ; Copy all sectors one-by-one
   dec     edx
   jnz     SectorCopyLoop
   ret
INST_Add_IncludeCode            EndP

; This routine is called, if Config-Image has to be included into
;  MBR_CurrentSectors for later writing to harddrive.
INST_Add_IncludeConfig          Proc Near   Uses ebx ecx edx esi edi
   mov     esi, AiRBOOT_ImageSectorsPtr
   add     esi, 6C00h
   ; Add DriveLetter Automatic variables, if set
   mov     al, AutoDriveLetter
   or      al, al
   jz      NoAutoDriveLetter
   mov     bptr [esi+1ABh], al           ; Hard-Coded: Auto-Drive-Letter
   mov     eax, AutoDriveLetterSerial
   mov     dptr [esi+1ACh], eax          ; Hard-Coded: Auto-Drive-Letter Serial
  NoAutoDriveLetter:
   ; Calculate new Config-CheckSum
   mov     wptr [esi+20], 0              ; delete current checksum
   xor     bx, bx
   mov     ecx, 5
  CalcConfigCheck:
      call    GetCheckOfSector
   loop    CalcConfigCheck
   mov     wptr [AiRBOOT_ImageSectors+6C00h+20], bx ; new checksum set
   ; -------------------------------------------------------------------------
   ; Now copy everything to MBR_CurrentSectors and overwrite what is there...
   mov     esi, AiRBOOT_ImageSectorsPtr
   add     esi, 6C00h                    ; Start Sector 55
   mov     edi, offset MBR_CurrentSectors+6C00h
   mov     ecx, 3072/2
   rep     movsw                     ; Copy 6 sectors over...
   ret
INST_Add_IncludeConfig          EndP
