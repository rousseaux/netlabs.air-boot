@echo off
rem Do actual build...
call ..\..\env\os2.cmd
%assembler% airboot.asm
if errorlevel 1 goto Failed
%linker% airboot.obj; >nul
if errorlevel 1 goto Failed
%exe2bin% airboot.exe airboot.com >nul
if errorlevel 1 goto Failed
copy airboot.com ..\..\RELEASE\DOS\AIRBOOT.COM

@ren airboot.LST airboot.TSL
@ren airboot.TSL AIRBOOT.LST

rem Cleanup
del airboot.com
del airboot.exe
del airboot.obj
goto ExitMe

:Failed
echo Errorlevel not 0, make failed
:ExitMe
rem pause
