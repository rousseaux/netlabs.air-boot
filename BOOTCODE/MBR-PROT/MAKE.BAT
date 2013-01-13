@echo off
rem Do actual build...
call ..\..\env\dos.bat
%assembler% mbr_prot.asm
if errorlevel 1 goto Failed
%linker% mbr_prot.obj >nul
if errorlevel 1 goto Failed
%exe2bin% mbr_prot.exe mbr_prot.com
if errorlevel 1 goto Failed
rem copy mbr_prot.com fixcode.com
rem if errorlevel 1 goto Failed

@ren mbr_prot.LST mbr_prot.TSL
@ren mbr_prot.TSL MBR_PROT.LST
@ren mbr_prot.com mbr_prot.moc
@ren mbr_prot.moc MBR_PROT.COM


rem Cleanup
del mbr_prot.exe
del mbr_prot.obj
goto ExitMe

:Failed
echo Errorlevel not 0, make failed
:ExitMe
rem pause
