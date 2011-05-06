/* REXX */

'@if exist air-boot.com del air-boot.com';
'@if exist air-boot.obj del air-boot.obj';
'@if exist air-boot.lst del air-boot.lst';
'@if exist air-boot.map del air-boot.map';
'@if exist airboot.bin del airboot.bin';
'rem @if exist blddate.asm del blddate.asm';  /* keep the builddate of the v1.07 eCS v2.1 release */

'@if exist ..\RELEASE\BOOTCODE\AIRBT-*.BIN del ..\RELEASE\BOOTCODE\AIRBT-*.BIN';

'@if exist ..\RELEASE\DOS\AIRBOOT.BIN del ..\RELEASE\DOS\AIRBOOT.BIN';
'@if exist ..\RELEASE\OS2\AIRBOOT.BIN del ..\RELEASE\OS2\AIRBOOT.BIN';
'@if exist ..\RELEASE\WINNT\AIRBOOT.BIN del ..\RELEASE\WINNT\AIRBOOT.BIN';
'@if exist ..\RELEASE\LINUX\AIRBOOT.BIN del ..\RELEASE\LINUX\AIRBOOT.BIN';

