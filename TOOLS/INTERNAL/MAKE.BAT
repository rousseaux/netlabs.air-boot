@echo off
rem Do actual build...
call ..\..\env\dos.bat
%assembler% fixcode.asm
if errorlevel 1 goto Failed
%linker% fixcode.obj >nul
if errorlevel 1 goto Failed
%exe2bin% fixcode.exe fixcode.com >nul
if errorlevel 1 goto Failed

rem Cleanup
del fixcode.exe
del fixcode.obj
goto ExitMe

:Failed
echo Errorlevel not 0, make failed
:ExitMe
pause
