#
# Quick and Dirty clean of release directories
#

default:	.SYMBOLIC
	@echo.
	@echo Use wmake clean to remove the distribution files
	@echo.

clean:		.SYMBOLIC
#	@for %%i in ($(RELDIRS)) do @$(MAKE) -h %%i
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@echo @@ CLEANING RELEASE DIRECTORIES
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@cd BOOTCODE
	@cd
	@if exist *.BIN del *.BIN
	@if exist *.EXE del *.EXE
	@if exist *.ELF del *.ELF
	@cd ..
	@cd DOS
	@cd
	@if exist *.BIN del *.BIN
	@if exist *.EXE del *.EXE
	@if exist *.ELF del *.ELF
	@cd ..
	@cd LINUX
	@cd
	@if exist *.BIN del *.BIN
	@if exist *.EXE del *.EXE
	@if exist *.ELF del *.ELF
	@cd ..
	@cd OS2
	@cd
	@if exist *.BIN del *.BIN
	@if exist *.EXE del *.EXE
	@if exist *.ELF del *.ELF
	@cd ..
	@cd WINNT
	@cd
	@if exist *.BIN del *.BIN
	@if exist *.EXE del *.EXE
	@if exist *.ELF del *.ELF
	@cd ..
