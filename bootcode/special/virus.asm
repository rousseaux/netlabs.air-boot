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
;                                                AiR-BOOT / VIRUS DETECTION
;---------------------------------------------------------------------------

; Checks system for stealth-virus...if any is found, MBR will get restored and
; system will get halted. On Non-Real-Mode this will only save Interrupt Vectors.
; Segment Registers preserved

IFDEF   MODULE_NAMES
DB 'VIRUS',0
ENDIF

VIRUS_CheckForStealth      Proc Near  Uses ds si es di
   xor     al, al
   mov     cx, 4
   mov     di, offset CFG_VIR_INT08
   push    di
      repe     scasb
   pop     di
   jne     VCFS_AlreadyInitiated

  VCFS_InitNow:
   xor     ax, ax
   mov     ds, ax
   mov     ax, cs
   mov     es, ax
   mov     cx, 2
   mov     si, 08h*4
   rep     movsw                         ; INT 08 Ptr
   mov     cl, 2
   mov     si, 13h*4
   rep     movsw                         ; INT 13 Ptr
   mov     cl, 2
   mov     si, 1Ch*4
   rep     movsw                         ; INT 1C Ptr

   call    DriveIO_SaveConfiguration

   jmp     VCFS_Finished

  VCFS_AlreadyInitiated:
   xor     ax, ax
   mov     es, ax
   xor     si, si
   mov     ax, word ptr es:[si+08h*4]
   mov     dx, word ptr es:[si+08h*4+2]
   cmp     ax, word ptr ds:[di+0]
   jne     VCFS_Found
   cmp     dx, word ptr ds:[di+2]
   jne     VCFS_Found
   mov     ax, word ptr es:[si+13h*4]
   mov     dx, word ptr es:[si+13h*4+2]
   cmp     ax, word ptr ds:[di+4]
   jne     VCFS_Found
   cmp     dx, word ptr ds:[di+6]
   jne     VCFS_Found
   mov     ax, word ptr es:[si+1Ch*4]
   mov     dx, word ptr es:[si+1Ch*4+2]
   cmp     ax, word ptr ds:[di+8]
   jne     VCFS_Found
   cmp     dx, word ptr ds:[di+10]
   jne     VCFS_Found

  VCFS_Finished:
   ret

  VCFS_Found:
   ; New ROM-Proof Logic:
   ;  Mismatching vector found, so try to write to that location. If it doesn't
   ;  succeed, ROM will be assumed (so valid change), a message will get
   ;  displayed and new vectors will be saved. Otherwise Virus found.
   mov     es, dx
   mov     bx, ax
   mov     al, bptr es:[bx]              ; Get Byte from Interrupt Vector
   mov     ah, al
   xor     al, 0FFh
   mov     bptr es:[bx], al              ; Try to write there...
   mov     al, bptr es:[bx]              ; Get back...
   mov     bptr es:[bx], ah              ; And restore to original byte...
   cmp     al, ah
   jne     VCFS_WhewThisIsOne            ; Mismatch ? -> Virus found
   mov     si, offset TXT_BIOSchanged
   call    MBR_Teletype
   xor     ah, ah
   int     16h                           ; Waits for any keystroke
   jmp     VCFS_InitNow

  VCFS_WhewThisIsOne:
   call    VIRUS_TryRestore

   ; Code should no reach this since we halt the system in VIRUS_TryRestore.
   ret
VIRUS_CheckForStealth           EndP

;
; This procedure is created to avoid jumping to labels that are local to
; procedures. JWasm does not allow that.
; Should be fixed better later.
;
VIRUS_TryRestore    Proc Near
        mov     si, offset TXT_VirusFoundMain
        call    MBR_Teletype
        ; Now check BackUp MBR for validation (AiRBOOT signature), do this
        ; using direct-calls to original bios handler.
        call    ANTIVIR_RestoreMBR
        jnc     VIRUS_TryRestore_ValidRestore

        mov     si, offset TXT_VirusFound1damn
        call    MBR_Teletype
        call    MBR_Teletype                  ; VirusFound1any
        mov     si, offset TXT_VirusFoundEnd
        call    MBR_Teletype
        jmp     MBR_HaltSystem

    VIRUS_TryRestore_ValidRestore:
        mov     si, offset TXT_VirusFound1ok
        call    MBR_Teletype
        mov     si, offset TXT_VirusFound1any
        call    MBR_Teletype
        mov     si, offset TXT_VirusFoundEnd
        call    MBR_Teletype
        jmp     MBR_HaltSystem

        ; Code should not reach this since we halt the system.
VIRUS_TryRestore    Endp


; Checks system for normal-MBR-virus... (done by comparing current MBR with
; memory image). Note: We will only compare the first 446 bytes.
; if one is found, MBR will get restored and system will get halted.
; Segment Registers preserved
VIRUS_CheckForVirus             Proc Near  Uses ds si es di
   push    cs
   push    cs
   pop     ds
   pop     es
   mov     bx, offset TmpSector
   mov     dx, 0080h
   mov     cx, 0001h  ; Harddisc 0, Sector 1
   mov     ax, 0201h
   int     13h
   jnc     VCFV_MBRloaded
   ret
 VCFV_MBRloaded:
   mov     si, BootBasePtr
   mov     di, offset TmpSector
   mov     cx, 223                       ; Compare 446 bytes
   repz    cmpsw                         ; if fail: Cross call to Stealth-Virus
   ;jne     VCFS_WhewThisIsOne
   je      VIRUS_CheckForVirus_end
   call    VIRUS_TryRestore
  VIRUS_CheckForVirus_end:
   ret
VIRUS_CheckForVirus             EndP

; ============================================================================
;      ANTI-VIRUS-CODE
; ============================================================================

; Saves a backup of the current MBR to harddisc (used before booting)
ANTIVIR_SaveBackUpMBR           Proc Near  Uses ax bx cx dx es
   push    cs
   pop     es
   mov     bx, BootBasePtr
   mov     dx, 0080h
   ;mov     cx, 003Ch                     ; First Harddrive, Sector 60
   mov     cx, image_size / sector_size  ; Harddisc 0, Sector 60 (or 62 for extended version)
   mov     ax, 0301h                     ; Write 1 Sector
   int     13h
   ret
ANTIVIR_SaveBackUpMBR           EndP

; Will report Carry-Clear, if BackUp MBR is valid (supposingly)
ANTIVIR_CheckBackUpMBR          Proc Near
   push    cs
   push    cs
   pop     es
   pop     ds
   mov     bx, offset TmpSector
   mov     dx, 0080h
   ;mov     cx, 003Ch                     ; Harddisc 0, Sector 60
   mov     cx, image_size / sector_size  ; Harddisc 0, Sector 60 (or 62 for extended version)
   mov     ax, 0201h                     ; Load 1 Sector
   pushf
   call    dword ptr cs:[CFG_VIR_INT13]  ; Get Sector 60 directly (w/o INT 13h)
   jc      ACBUMBR_Failed
   mov     cx, 7
   mov     di, offset TmpSector
   add     di, 2                         ; Position for "AiRBOOT" normally
   mov     si, offset CheckID_MBR
   repz    cmpsb
   stc
   jne     ACBUMBR_Failed
   clc
  ACBUMBR_Failed:
   ret
ANTIVIR_CheckBackUpMBR          EndP

ANTIVIR_RestoreMBR              Proc Near
   call    ANTIVIR_CheckBackUpMBR
   jnc     ARMBR_DoIt
   ret
  ARMBR_DoIt:
   mov     bx, offset TmpSector
   mov     dx, 0080h
   mov     cx, 0001h                     ; Harddisc 0, Sector 1
   mov     ax, 0301h                     ; Write 1 Sector
   pushf
   call    dword ptr cs:[CFG_VIR_INT13]  ; Writes to Sector 1 directly
   ret
ANTIVIR_RestoreMBR              EndP
