@echo off
rem Do actual build...
call ..\..\..\env\os2.cmd
%assembler% setaboot.asm
if errorlevel 1 goto Failed
%linker% setaboot.obj; >nul
if errorlevel 1 goto Failed
%exe2bin% setaboot.exe setaboot.com >nul
if errorlevel 1 goto Failed
copy setaboot.com ..\..\..\RELEASE\DOS\setaboot.com

rem Cleanup
del setaboot.com
del setaboot.exe
del setaboot.obj
goto ExitMe

:Failed
echo Errorlevel not 0, make failed
:ExitMe
pause
