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
call pack US
call pack DE
call pack DT
call pack FR
call pack IT
call pack RU
call pack SW
goto ExitMe

:Valid
cd %1
del AiR-BOOT*.zip
zip -R -S -9 AiR-BOOTv100_%1.zip *
cd ..\GENERIC
zip -R -S -9 ..\%1\AiR-BOOTv100_%1.zip *
cd ..
