#
# Quick and Dirty clean of release directories
#

# Include a Master Makefile with several cross-platform definitions and macros.
# This is used to compensate for the differences between the target platforms.
!include	../INCLUDE/MAKEFILE.MIF

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
	@if exist *.BIN $(RM) *.BIN
	@if exist *.EXE $(RM) *.EXE
	@if exist *.ELF $(RM) *.ELF
	@cd ..
	@cd DOS
	@cd
	@if exist *.BIN $(RM) *.BIN
	@if exist *.EXE $(RM) *.EXE
	@if exist *.ELF $(RM) *.ELF
	@cd ..
	@cd LINUX
	@cd
	@if exist *.BIN $(RM) *.BIN
	@if exist *.EXE $(RM) *.EXE
	@if exist *.ELF $(RM) *.ELF
	@cd ..
	@cd OS2
	@cd
	@if exist *.BIN $(RM) *.BIN
	@if exist *.EXE $(RM) *.EXE
	@if exist *.ELF $(RM) *.ELF
	@cd ..
	@cd WINNT
	@cd
	@if exist *.BIN $(RM) *.BIN
	@if exist *.EXE $(RM) *.EXE
	@if exist *.ELF $(RM) *.ELF
	@cd ..
