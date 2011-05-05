@echo off
rem This batch file builds 
if "%1"=="EN"  goto Valid
if "%1"=="DE"  goto Valid
if "%1"=="DT"  goto Valid
if "%1"=="FR"  goto Valid
if "%1"=="IT"  goto Valid
if "%1"=="RU"  goto Valid
if "%1"=="SW"  goto Valid
if "%1"=="ALL" goto BuildAll
echo Invalid language ID
goto ExitMe

:BuildAll
call make.bat EN
call make.bat DE
call make.bat DT
call make.bat FR
call make.bat IT
call make.bat RU
call make.bat SW
goto ExitMe

:Valid
echo Making %1 language version of AiR-BOOT bootcode...
echo Include TEXT\%1\MBR.asm >TEXT\TXTMBR.asm
echo Include TEXT\%1\MENUS.asm >TEXT\TXTMENUS.asm
echo Include TEXT\%1\OTHER.asm >TEXT\TXTOTHER.asm

rem Do actual build...
call ..\env\dos.bat
%assembler% air-boot.asm
if errorlevel 1 goto Failed
%linker% air-boot.obj >nul
if errorlevel 1 goto Failed
%exe2bin% air-boot.exe air-boot.com >nul
if errorlevel 1 goto Failed
..\tools\internal\fixcode.com
copy AIR-BOOT.com ..\RELEASE\BOOTCODE\%1.bin

rem Cleanup
rem del AiR-BOOT.com
del AiR-BOOT.exe
del AiR-BOOT.obj
goto ExitMe

:Failed
echo Errorlevel not 0, make failed
:ExitMe
