$COMPILE EXE

$INCLUDE "GLOBAL.inc"
'$INCLUDE "DOS.inc"

' Inserts MBR Protection into AiR-BOOT.com
Open "air-boot.com" For BINARY As #1
Get$ #1, 30976, CodeBuffer$
MBRProtectionImage& = Instr(CodeBuffer$,"AiR-BOOT MBR-Protection Image")
If MBRProtectionImage&>0 Then
   Open "mbr-prot\mbr_prot.com" For BINARY As #2
   Get$ #2, 1024, MBRProtectionImage$
   Close #2
   Seek #1, MBRProtectionImage&-1: Put$ #1, MBRProtectionImage$
   Mid$(CodeBuffer$,MBRProtectionImage&) = MBRProtectionImage$
End If
' Calculating CodeSectors and putting the count into the image
CodeTravelPos?? = 27136
While Mid$(CodeBuffer$,CodeTravelPos??+1,512)=String$(512,0)
   Decr CodeTravelPos??, 512
Wend
CodeSectorsUsed% = CodeTravelPos??/512
print "Code-Sectors Used: ";CodeSectorsUsed%
Seek #1, 16: Put$ #1, Chr$(CodeSectorsUsed%) ' Actually CodeSectors-1
Close #1
print "AiR-BOOT.com sucessfully updated."
end
