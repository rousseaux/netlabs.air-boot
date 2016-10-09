#
# Quick and Dirty clean of release directories
#

# Include a Master Makefile with several cross-platform definitions and macros.
# This is used to compensate for the differences between the target platforms.
!include ../include/makefile.mif

default: .SYMBOLIC
	@echo.
	@echo Use wmake clean to remove the distribution files
	@echo.

clean: .SYMBOLIC
#	@for %%i in ($(RELDIRS)) do @$(MAKE) -h %%i
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@echo @@ CLEANING RELEASE DIRECTORIES
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@cd bootcode
	@cd
	@if exist *.bin $(RM) *.bin
	@if exist *.exe $(RM) *.exe
	@if exist *.elf $(RM) *.elf
	@cd ..
	@cd dos
	@cd
	@if exist *.bin $(RM) *.bin
	@if exist *.exe $(RM) *.exe
	@if exist *.elf $(RM) *.elf
	@cd ..
	@cd linux
	@cd
	@if exist *.bin $(RM) *.bin
	@if exist *.exe $(RM) *.exe
	@if exist *.elf $(RM) *.elf
	@cd ..
	@cd os2
	@cd
	@if exist *.bin $(RM) *.bin
	@if exist *.exe $(RM) *.exe
	@if exist *.elf $(RM) *.elf
	@cd ..
	@cd winnt
	@cd
	@if exist *.bin $(RM) *.bin
	@if exist *.exe $(RM) *.exe
	@if exist *.elf $(RM) *.elf
	@cd ..
