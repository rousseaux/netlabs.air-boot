@echo off
set INCLUDE=%INCLUDE%;%INCLUDE_TOOLKIT%;%INCLUDE_WATCOM%
set LIB=%LIB%;%LIB_TOOLKIT%;%LIB_WATCOM%
alp.exe -D:Flat asm\main.asm
if errorlevel 1 goto End
h:\IbmC\bin\icc /C /Ms /Sp1 setaboot.c
if errorlevel 1 goto End
ilink setaboot.obj ..\..\..\..\JimiHelp\stdcode\physdisk.obj ..\..\..\..\JimiHelp\stdcode\msg.obj ..\..\..\..\JimiHelp\stdcode\shutdown.obj setaboot.def
copy setaboot.exe ..\!RELEASE\GENERIC
:End
