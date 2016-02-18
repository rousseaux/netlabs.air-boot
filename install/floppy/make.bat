@echo off
rem Do actual build...
call ..\..\env\dos.bat
echo Building kernel.com...
%assembler% kernel.asm
if errorlevel 1 goto Failed
%linker% kernel.obj >nul
if errorlevel 1 goto Failed
%exe2bin% kernel.exe kernel.com >nul
if errorlevel 1 goto Failed

echo Building makedisk.com...
%assembler% makedisk.asm
if errorlevel 1 goto Failed
%linker% makedisk.obj >nul
if errorlevel 1 goto Failed
%exe2bin% makedisk.exe makedisk.com >nul
if errorlevel 1 goto Failed

echo Appending kernel.com and freedos.bin onto makedisk.com
copy /B makedisk.com+freedos.bin+kernel.com ..\..\RELEASE\DOS

rem Cleanup
del kernel.com
del kernel.exe
del kernel.obj
del makedisk.com
del makedisk.exe
del makedisk.obj
goto ExitMe

:Failed
echo Errorlevel not 0, make failed
:ExitMe
pause
