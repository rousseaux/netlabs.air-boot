@echo off
if "%1"=="US"  goto Valid
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
call make US
call make DE
call make DT
call make FR
call make IT
call make RU
call make SW
goto ExitMe

:Valid
set INCLUDE=%INCLUDE%;%INCLUDE_TOOLKIT%;%INCLUDE_WATCOM%
set LIB=%LIB%;%LIB_TOOLKIT%;%LIB_WATCOM%
alp.exe -D:Flat asm\main.asm
if errorlevel 1 goto ExitMe
h:\IbmC\bin\icc /C /Ms airboot2.c
if errorlevel 1 goto ExitMe
ilink airboot2.obj main.obj ..\!IMAGES\airb_%1.obj ..\..\..\..\JimiHelp\stdcode\physdisk.obj ..\..\..\..\JimiHelp\stdcode\msg.obj ..\..\..\..\JimiHelp\stdcode\shutdown.obj airboot2.def
copy airboot2.exe ..\!RELEASE\%1
:ExitMe
