$COMPILE EXE

$INCLUDE "GLOBAL.inc"
'$INCLUDE "DOS.inc"

Open "MAKEDISK.COM" For BINARY As #1

' Read in AiR-BOOT Image -> Main-Code of AiR-BOOT placed at Offset 16384
Open command$ For BINARY As #2
Get$ #2, 30976, CodeBuffer$
Close #2
Seek #1, 16384-&h100: Put$ #1, CodeBuffer$

' Read in DSK_BOOT.COM -> Installer-Code of AiR-BOOT placed at offset 8192
Open "dsk_boot.com" For BINARY As #2
Seek #2, &h7C00
Get$ #2, 8192, CodeBuffer$
Close #2
Seek #1, 8192-&h100: Put$ #1, CodeBuffer$

Close #1
print "MAKEDISK sucessfully updated."
end
