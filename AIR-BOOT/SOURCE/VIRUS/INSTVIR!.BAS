$COMPILE EXE

Open "TESTVIR!.COM" For BINARY As #1
Get$ #1, 512, VirusBase$

If len(VirusBase$)>446 Then print "Image too long!": end
VirusBase$ = VirusBase$ + string$(446-len(VirusBase$), 0)

LocalMBR$ = AiRBOOT_LoadSector(1)
VirusMBR$ = VirusBase$ + Mid$(LocalMBR$, 447)

AiRBOOT_WriteSector 1, VirusMBR$
AiRBOOT_WriteSector 50, LocalMBR$
print "Test-Virus installed."

Function AiRBOOT_LoadSector (byval Sector%) as STRING
   SectorBuffer$ = string$(512, 0)
   SectorPtr??? = StrPtr32(SectorBuffer$)
 AiRBOOT_LoadSector_Retry:
   ! mov  ax, &h0201  ; load one sector
   ! mov  ch, 0
   ! mov  cl, Sector%
   ! mov  dx, &h0080  ; load to harddisc 0, head 0
   ! les  bx, SectorPtr???
   ! int  &h13
   ! jnc  AiRBOOT_LoadSector_Success
   ! mov  ah, &h00  ; reset disc
   ! mov  dl, &h80
   ! int  &h13
   ! jmp  AiRBOOT_LoadSector_Retry
 AiRBOOT_LoadSector_Success:
   FUNCTION = SectorBuffer$
End Function

Sub AIRBOOT_WriteSector (byval Sector%, byval SectorBuffer$)
   SectorBuffer$ = SectorBuffer$ + string$(512-len(SectorBuffer$), 0)
   SectorPtr??? = StrPtr32(SectorBuffer$)
 AiRBOOT_WriteSector_Retry:
   ! mov  ax, &h0301  ; write one sector
   ! mov  ch, 0
   ! mov  cl, Sector%
   ! mov  dx, &h0080  ; write to harddisc 0, head 0
   ! les  bx, SectorPtr???
   ! int  &h13
   ! jnc  AiRBOOT_WriteSector_Success
   ! mov  ah, &h00  ; reset disc
   ! mov  dl, &h80
   ! int  &h13
   ! jmp  AiRBOOT_WriteSector_Retry
 AiRBOOT_WriteSector_Success:
End Sub
