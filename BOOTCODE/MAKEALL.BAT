@cls
@echo:
@echo ############
@echo # MBR-PROT #
@echo ############
@CD MBR-PROT
@CALL MAKE.BAT
@CD ..
rem @pause

@cls
@echo:
@echo #################
@echo # INSTALL (DOS) #
@echo #################
@CD ..\INSTALL\DOS
@CALL MAKE.BAT
@CD ..\..\BOOTCODE
rem @pause

@cls
@echo:
@echo ############
@echo # INITHDD  #
@echo ############
@CD ..\TOOLS\DOS\INITHDD
@CALL MAKE.BAT
@CD ..\..\..\BOOTCODE
rem @pause

@cls
@echo:
@echo ############
@echo # FIXCODE  #
@echo ############
@CD ..\TOOLS\INTERNAL
@CALL MAKE.BAT
@CD ..\..\BOOTCODE
rem @pause

@cls
@echo:
@echo #############
@echo # AiR-BOOT  #
@echo #############
@CALL MAKE.BAT %1

@if "%1"=="ALL" goto english_default
@if not "%1"=="ALL" goto lang_default


:english_default
@Rem Copy English version to platform-dirs for install testing when building all languages
@copy ..\RELEASE\BOOTCODE\AIRBT-EN.BIN ..\RELEASE\DOS\AIRBOOT.BIN
@copy ..\RELEASE\BOOTCODE\AIRBT-EN.BIN ..\RELEASE\OS2\AIRBOOT.BIN
@copy ..\RELEASE\BOOTCODE\AIRBT-EN.BIN ..\RELEASE\WINNT\AIRBOOT.BIN
@copy ..\RELEASE\BOOTCODE\AIRBT-EN.BIN ..\RELEASE\LINUX\AIRBOOT.BIN
@goto end


:lang_default
@Rem Copy Language version to platform-dirs for install testing when building one language
@copy AIRBOOT.BIN ..\RELEASE\DOS\AIRBOOT.BIN
@copy AIRBOOT.BIN ..\RELEASE\OS2\AIRBOOT.BIN
@copy AIRBOOT.BIN ..\RELEASE\WINNT\AIRBOOT.BIN
@copy AIRBOOT.BIN ..\RELEASE\LINUX\AIRBOOT.BIN
@goto end


:end

@pause
