@echo off
rem This batch file builds 
if "%1"=="EN"  goto Valid
if "%1"=="DE"  goto Valid
if "%1"=="NL"  goto Valid
if "%1"=="FR"  goto Valid
if "%1"=="IT"  goto Valid
if "%1"=="RU"  goto Valid
if "%1"=="SW"  goto Valid
if "%1"=="ALL" goto BuildAll
echo Invalid language ID
goto ExitMe

rem -- We do English last so an English version can be copied
rem -- to this directory, using it's normal basename instead
rem -- of the language suffixed one.
:BuildAll
call make.bat DE
call make.bat NL
call make.bat FR
call make.bat IT
call make.bat RU
call make.bat SW
call make.bat EN
goto ExitMe

:Valid
echo.
echo.
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

@ren air-boot.LST air-boot.tsl
@ren air-boot.tsl AIR-BOOT.LST

..\tools\internal\fixcode.com

copy AIR-BOOT.COM ..\RELEASE\BOOTCODE\AIRBT-%1.BIN

copy AIR-BOOT.COM AIRBOOT.BIN

rem Cleanup
del AiR-BOOT.COM
del AiR-BOOT.EXE
del AiR-BOOT.OBJ
goto ExitMe

:Failed
echo Errorlevel not 0, make failed
:ExitMe

echo.
echo Gonna build the installer and setaboot now...
echo.

rem @pause
