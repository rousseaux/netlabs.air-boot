@echo off
rem This batch file builds ISOs from basic1.iso, basic2.iso and the
rem  corresponding language-specific air-boot.bin from /RELEASE/BOOTCODE
rem  directory
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
call make.cmd EN
call make.cmd DE
call make.cmd DT
call make.cmd FR
call make.cmd IT
call make.cmd RU
call make.cmd SW
goto ExitMe

:Valid
echo Making %1 language version of AiR-BOOT ISO...

rem Do actual build...
makeiso\makeiso basic.iso ..\..\RELEASE\BOOTCODE\%1.bin ..\..\RELEASE\CD-ROM\%1.iso
goto ExitMe

:Failed
echo Errorlevel not 0, make failed
:ExitMe
