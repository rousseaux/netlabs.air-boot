@echo off
if "%1"=="US"  goto Valid
if "%1"=="DE"  goto Valid
if "%1"=="DT"  goto Valid
if "%1"=="FR"  goto Valid
if "%1"=="IT"  goto Valid
if "%1"=="RU"  goto Valid
if "%1"=="ALL" goto BuildAll
echo Invalid language ID
goto ExitMe

:BuildAll
call builddsk US
call builddsk DE
call builddsk DT
call builddsk FR
call builddsk IT
call builddsk RU
goto ExitMe

:Valid
cd INSTALL\FLOPPY
call make com dsk_boot
call make com makedisk
..\..\TOOLS\mergedsk.exe ..\!IMAGES\airb_%1.bin
pklite makedisk.com
hs makedisk.com
copy makedisk.com ..\!RELEASE\%1\makedisk.com
cd ..\..
:ExitMe
