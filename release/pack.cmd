@echo off
rem This script was done for OS/2, I don't know if it will work on other OS
if "%1"=="/?"  goto Help
if "%1"=="-?"  goto Help
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

:Help
echo pack.cmd [LanguageID] [Version]
echo e.g. pack EN v106
goto ExitMe

:BuildAll
if "%2"=="" goto NoVersion
call pack EN %2
call pack DE %2
call pack DT %2
call pack FR %2
call pack IT %2
call pack RU %2
call pack SW %2
goto ExitMe

:NoVersion
echo No version specified as 2nd parameter
goto ExitMe

:Valid
if "%2"=="" goto NoVersion
if not exist temp        md temp
if not exist temp\CD-ROM md temp\CD-ROM
if not exist temp\DOCS   md temp\DOCS
if not exist temp\DOS    md temp\DOS
if not exist temp\OS2    md temp\OS2
del temp\*.* /N
del temp\CD-ROM\*.* /N
del temp\DOCS\*.* /N
del temp\DOS\*.* /N
del temp\OS2\*.* /N
copy !README!.1ST temp
rem Language-specific bootcode
copy bootcode\%1.bin temp\airboot.bin
rem CD-ROM-specific files (ISO)
copy CD-ROM\*.* temp\CD-ROM\*.*
rem DOS-specific installer/tools
copy DOS\airboot.com temp
copy DOS\makedisk.com temp
copy DOS\inithdd.com temp\DOS
copy DOS\setaboot.com temp\DOS
rem OS/2-specific installer/tools
copy OS2\airboot2.exe temp
copy OS2\setaboot.exe temp\OS2
rem WINNT-specific installer
copy WINNT\airbootw.exe temp
rem Documentation
copy ..\DOCS\GENERIC\*.* temp\DOCS
copy ..\DOCS\%1\*.* temp\DOCS
cd temp
zip -R -S -9 AiRBOOT.zip *
cd ..
copy temp\AiRBOOT.zip ZIP\AiR-BOOT%2_%1.zip
:ExitMe
