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
call buildimg US
call buildimg DE
call buildimg DT
call buildimg FR
call buildimg IT
call buildimg RU
goto ExitMe

:Valid
echo Include TEXT\%1\MBR.asm >SOURCE\TEXT\TXTMBR.asm
echo Include TEXT\%1\MENUS.asm >SOURCE\TEXT\TXTMENUS.asm
echo Include TEXT\%1\OTHER.asm >SOURCE\TEXT\TXTOTHER.asm
cd SOURCE
call make com air-boot
..\TOOLS\mergeimg.exe
copy AIR-BOOT.com ..\INSTALL\!IMAGES\airb_%1.bin
cd ..
cd INSTALL\!IMAGES
..\..\tools\mkobj airb_%1.bin airb_%1.obj /3 /s=DATA SEGMENT USE32 PARA PUBLIC 'DATA' nodosseg /p=AiRBOOT_ImageSectors,0
cd ..\..
:ExitMe
