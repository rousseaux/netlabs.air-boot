$COMPILE EXE

$INCLUDE "CRTC.inc"

Open "CYR.BIN" For BINARY As #1
Get$ #1, 1024, CyrillicFont$
Close #1

Compressed$ = "": CurPos%=0
Do
   NULcount% = 0
   Do
      incr CurPos%: incr NULcount%
   Loop Until Asc(CyrillicFont$,CurPos%)<>0
   Decr NULcount%
   CharCount% = 0: StartPos% = CurPos%
   Do
      incr CurPos%: incr CharCount%
   Loop Until Asc(CyrillicFont$,CurPos%)=0
   Decr CurPos%
   Shift Left CharCount%, 4
   Compressed$ = Compressed$+Chr$(CharCount%+NULcount%)+Mid$(CyrillicFont$,StartPos%,CurPos%-StartPos%+1)
Loop Until CurPos%=>1020
Open "COMPRESS.BIN" For BINARY As #2
Put$ #2, Compressed$
Close #2
end

NewFont$ = @CRTC_Font_ROM_25x80
Mid$(NewFont$, 2049, 768) = Left$(CyrillicFont$, 768)
Mid$(NewFont$, 3584, 256) = Right$(CyrillicFont$, 256)

CRTC_LoadFont_25x80 StrPtr32(NewFont$)
cls
for a%=0 to 255
   print chr$(a%);
   if (a% and 15)=15 Then print
next a%
end

Open "KOI8.F16" For BINARY As #1
Get$ #1, 4096, CyrillicFont$
close #1

print CyrillicFont$
CyrillicFont$ = Mid$(CyrillicFont$, 3073, 1024)
Open "CYRILLIC.BIN" For BINARY As #2
Put$ #2, CyrillicFont$
Close #2
