@echo off
rem Do actual build...
call ..\..\..\env\dos.bat
%assembler% inithdd.asm
if errorlevel 1 goto Failed
%linker% inithdd.obj >nul
if errorlevel 1 goto Failed
%exe2bin% inithdd.exe inithdd.com >nul
if errorlevel 1 goto Failed
copy inithdd.com ..\..\..\RELEASE\DOS\inithdd.com

rem Cleanup
del inithdd.com
del inithdd.exe
del inithdd.obj
goto ExitMe

:Failed
echo Errorlevel not 0, make failed
:ExitMe
pause
