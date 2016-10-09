###############################################################################
# Makefile :: Builds the Installer for several platforms              [WMake] #
# --------------------------------------------------------------------------- #
#                                                                             #
# This Makefile builds the Installer for DOS, Windows, OS/2 and Linux.        #
# Like 'fixcode', each platform version has a letter appended it:             #
# 'D' for DOS, 'W' for Windows, '2' for OS/2 and 'L' for Linux.               #
#                                                                             #
###############################################################################


#
# Include a Master Makefile with several cross-platform definitions and macros.
# This is used to compensate for the differences between the target platforms.
#
!include ../../include/makefile.mif



#
# Define min and max debug levels.
# Level 0 is Release.
#
RELEASE_CODE=0
MAX_DEBUG_LEVEL=2

#
# Specifies the level of debugging.
# Comment-out from low to high to increase the debug level.
#
DEBUG_LEVEL=$(MAX_DEBUG_LEVEL)
DEBUG_LEVEL=1
DEBUG_LEVEL=$(RELEASE_CODE)

#
# Protect against missing or invalid debug-levels.
#
!ifndef DEBUG_LEVEL
!error DEBUG_LEVEL not defined !
!elseifndef MAX_DEBUG_LEVEL
!error MAX_DEBUG_LEVEL not defined !
!elseif $(DEBUG_LEVEL) > $(MAX_DEBUG_LEVEL)
!error DEBUG_LEVEL cannot exceed $(MAX_DEBUG_LEVEL) !
!elseif $(DEBUG_LEVEL) < 0
!error DEBUG_LEVEL cannot be negative !
!endif

#
# Base Name of Source Program to compile.
#
BASENAME=install

#
# Base Name of Executable Module to build.
# A letter is appended for each platform version:
# D=DOS, W=Windows, 2=OS2, L=Linux.
#
MODULE=airboot

#
# This is a list of the Targets to be built.
#
TARGETS=$(MODULE)d.exe $(MODULE)w.exe $(MODULE)2.exe $(MODULE)l.elf


#
# Assembler Tools.
#
#ASM=alp
#ASM=tasm
#ASM=wasm
ASM=jwasm

#
# There are no masm or alp for Linux and the yasm tasm-mode is incompatible.
# So we override to jwasm when a non-jwasm assembler is specified and
# we are building on Linux.
#
!ifdef __LINUX__
!if "$(ASM)"=="masm" | "$(ASM)"=="tasm" | "$(ASM)"=="alp"
ASM=jwasm
!endif
!endif

!if "$(ASM)"=="jwasm"
# -Cp   = case sensitive symbols
# -zcw = no _ prefix on symbols (C model)
ASM_FLAGS_D0=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Cp -Fo$^. -Fl=$^&.lst -Fw$^&.err
ASM_FLAGS_D1=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Zd -Zi -Fo$^. -Sa -Fl=$^&.lst -Fw$^&.err
ASM_FLAGS_D2=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Zd -Zi -Fo$^. -Sa -Fl=$^&.lst -Fw$^&.err
!elseif "$(ASM)"=="wasm"
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -fo=$^. -fr=$^&.err
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -d1 -fo=$^. -fr=$^&.err
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -d1 -fo=$^. -fr=$^&.err
!elseif "$(ASM)"=="tasm"
# -ml	= case sensitive symbols
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -l
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -z -zi -c -la
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -z -zi -c -la
!elseif "$(ASM)"=="alp"
ASM_FLAGS_D0=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ASSEMBLER=ALP -Mb +Feo:obj +Fl +Fel:lst +Fm +Fem:err
ASM_FLAGS_D1=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ASSEMBLER=ALP -Mb +Od:MS16 +Feo:obj +Fl +Fel:lst +Fm +Fem:err
ASM_FLAGS_D2=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ASSEMBLER=ALP -Mb +Od:MS16 +Feo:obj +Fl +Fel:lst +Fm +Fem:err
!else
!error Unknown Assembler specified !
!endif
ASM_FLAGS=$(ASM_FLAGS_D$(DEBUG_LEVEL))

#
# 16-bits C Compiler
#
MM16=-mc
CPU=-2
CC16=wcc
CC16_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(CPU) $(MM16) -w4 -e25 -zq -osexan -fo=$^. -fr=$^&.err
CC16_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(CPU) $(MM16) -d2 -w4 -e25 -zq -on -fo=$^. -fr=$^&.err
CC16_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(CPU) $(MM16) -d3 -w4 -e25 -zq -od -fo=$^. -fr=$^&.err
CC16_FLAGS=$(CC16_FLAGS_D$(DEBUG_LEVEL))

#
# 32-bits C Compiler
#
MM32=-mf
CC32=wcc386
CC32_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) -w4 -e25 -zq -osexan -6r -fo=$^. -fr=$^&.err
CC32_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) -d2 -w4 -e25 -zq -on -6r -fo=$^. -fr=$^&.err
CC32_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) -d3 -w4 -e25 -zq -od -6r -fo=$^. -fr=$^&.err
CC32_FLAGS=$(CC32_FLAGS_D$(DEBUG_LEVEL))

#
# Linker
#
LNK=wlink
#
# DESCRIPTION does not work under WLink/Linux
# @ Cannot be escaped like with \x40 and it is still processed in quotes.
# WLink/2 can use the '\x40' variant.
#
#~ LNK_FLAGS_D0=op q op v op map=$^&.MAP op de '\x40\x23KIEWITZ:1.18\x23\x40\x41iR-BOOT Installer by Kiewitz'
LNK_FLAGS_D0=op q op v op map=$^&.map
#~ LNK_FLAGS_D1=op q op v d all &
#~ order clname CODE clname FAR_CONST clname FAR_DATA clnam BEGDATA clname DATA clname BSS clname STACK clname BLAP NOE &
#~ op map=$^&.MAP
LNK_FLAGS_D1=op q op v d all op map=$^&.map
LNK_FLAGS_D2=op q op v d all op map=$^&.map
LNK_FLAGS=$(LNK_FLAGS_D$(DEBUG_LEVEL))


#
# This is executed before Makefile processing.
#
.BEFORE
#	@echo == BEFORE ==

#
# This is executed after Makefile processing.
#
.AFTER
#	@echo == AFTER ==
!ifdef __MSDOS__
	@echo $(WARN_DOS_BLD_ENV)
!endif


#
# This builds all targets by using normal dependency rules.
# If this Makefile was modified, all targets are forcefully rebuilt.
#
all: .SYMBOLIC Makefile.bu header $(TARGETS) footer


#
# Alternative ways to build all targets.
# The first method builds all targets by recursively
# invoking WMake for each target.
# If concatenation is used, like adding include-directories to the environment,
# this may result in multiple identical concatenations.
# The second method uses the procedure method, no concatenation problem.
#
#all:	.SYMBOLIC
#	Recursive method (concatenation problem)
#	@for %%i in (header $(TARGETS) footer) do @$(MAKE) -h %%i
#	Procedure method (no concatenation problem, no re-invocation)
#	@for %%i in (header $(TARGETS) footer) do @%MAKE %%i



#
# Show the header.
#
header: .SYMBOLIC
	@echo.
	@echo =====================================================================
	@echo = PROGRAM: 'install' Multi Platform    [DOS, Win32, OS/2 and Linux] =
	@echo =====================================================================
#	@echo.


#
# Show the footer.
#
footer: .SYMBOLIC
	@echo All targets up to date !
	@echo.


#
# Create a backup of the Makefile when it is modified.
# This also forces a rebuild of all targets.
# So, when changing i.e. the DEBUG_LEVEL, all targets are rebuilt
# using the new level.
#
Makefile.bu: Makefile
	@echo.
	@echo Makefile modified, forcing rebuild of all targets !
	@echo.
	@%MAKE clean
	$(CP) Makefile Makefile.bu


#
# DOS WMake has a bug in that it expands $^& and $^. to lowercase,
# even though the definition is in uppercase.
# This gives problems when building in an OS/2 DOS-Box on a network
# share where also a Linux build-environment is active.
# The Linux build-environment is case sensitive and will not
# find the lowercase files.
# For example, a clean from Linux will not work properly in that case.
# This does not influence building DOS targets on Linux.
#

#
# While the DOS build-environment has been kept alive in this version,
# it has several drawbacks:
# - No support for long filenames
# - Very limited memory
# - JWasmR does not work because of memory limitations
# - JWasmD does not work at all
# - Batch scripting is very rudimentairy
#
# Therefore, the DOS build-environment will most probably disappear
# in future versions.
# This does not influence the building of DOS targets, which can be done
# on OS/2, Windows or Linux.
#




#
# MAIN TARGETS
#

###############################################################################
# DOS 16-bits (MZ)
###############################################################################
$(MODULE)d.exe: $(MODULE)d.obj
#	@cat $^&.MD5
	$(LNK) $(LNK_FLAGS) op stack=8192 file $^&.obj name $^. sys dos
#	@md5sum $^. > $^&.md5
#	@cat $^&.md5
	@wdump $^. > $^&.wdu
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@echo.
	#~ wstrip $^.

$(MODULE)d.obj: $(BASENAME).c $(BASENAME).h
#	@echo.
	@echo TARGET: $^&.exe [DOS 16-bits Executable]
	$(CC16) $(CC16_FLAGS) -I$(%WATCOM)$(DS)h$(DS)os21x -bt=dos $(BASENAME).c
	@wdis -fi $^. > $^&.wda


###############################################################################
# NT 32-bits (PE)
###############################################################################
$(MODULE)w.exe: $(MODULE)w.obj
	$(LNK) $(LNK_FLAGS) file $^&.obj name $^. sys nt
	@wdump $^. > $^&.wdu
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@echo.

$(MODULE)w.obj: $(BASENAME).c $(BASENAME).h
#	@echo.
	@echo TARGET: $^&.exe [NT 32-bits Executable]
	$(CC32) $(CC32_FLAGS) -I$(%WATCOM)$(DS)h$(DS)nt -bt=nt $(BASENAME).c
	@wdis -fi $^. > $^&.wda


###############################################################################
# OS/2 32-bits (LX)
###############################################################################
$(MODULE)2.exe: $(MODULE)2.obj
	$(LNK) $(LNK_FLAGS) file $^&.obj name $^. sys os2v2
	@wdump $^. > $^&.wdu
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@echo.
	#~ wstrip $^.

$(MODULE)2.obj: $(BASENAME).c $(BASENAME).h
#	@echo.
	@echo TARGET: $^&.exe [OS/2 32-bits Executable]
	$(CC32) $(CC32_FLAGS) -I$(%WATCOM)$(DS)h$(DS)os2 -bt=os2 $(BASENAME).c
	@wdis -fi $^. > $^&.wda


###############################################################################
# Linux 32-bits (ELF)
###############################################################################
$(MODULE)l.elf: $(MODULE)l.obj
	$(LNK) $(LNK_FLAGS) file $^&.obj name $^&.elf sys linux
	@wdump $^. > $^&.wdu
#	$(MV) $^&.elf $^.
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@echo.

$(MODULE)l.obj: $(BASENAME).c $(BASENAME).h
#	@echo.
	@echo TARGET: $^&.elf [Linux 32-bits Executable]
	$(CC32) $(CC32_FLAGS) -I$(%WATCOM)$(DS)h$(DS)os2 -bt=linux $(BASENAME).c
	@wdis -fi $^. > $^&.wda






#
# MAIN ACTIONS
#


# -----------------------------------------------------------------------------
# DISTRIBUTE TO RELEASE SPACE
# -----------------------------------------------------------------------------
# This distributes all '.bin' files to 'bootcode'.
# Then it installs the English version to 'releases' as 'airboot.bin'.
# -----------------------------------------------------------------------------
dist: .SYMBOLIC
	@if exist airboot2.exe $(CP) airboot2.exe ..$(DS)..$(DS)release$(DS)os2
	@if exist airbootd.exe $(CP) airbootd.exe ..$(DS)..$(DS)release$(DS)dos
	@if exist airbootl.elf $(CP) airbootl.elf ..$(DS)..$(DS)release$(DS)linux
	@if exist airbootw.exe $(CP) airbootw.exe ..$(DS)..$(DS)release$(DS)winnt

#
# Rebuild all targets.
#
rebuild: .SYMBOLIC
	@%MAKE clean
	@%MAKE all

#
# Remove all generated files.
#
clean: .SYMBOLIC
	@for %%i in ($(TARGETS)) do @if exist %%i $(RM) %%i
	@if exist *.obj $(RM) *.obj
	@if exist *.wda $(RM) *.wda
	@if exist *.wdu $(RM) *.wdu
	@if exist *.nda $(RM) *.nda
	@if exist *.map $(RM) *.map
	@if exist *.lst $(RM) *.lst
	@if exist *.err $(RM) *.err
	@if exist *.o   $(RM) *.o

#
# Help on using this Makefile.
#
help: .SYMBOLIC
	@echo.
	@echo The following actions are available:
	@echo wmake         to build all targets
	@echo wmake show    to show the list of buildable targets
	@echo wmake clean   to remove all generated files
	@echo wmake rebuild to rebuild all targets
	@echo wmake help    to show this information
	@echo.

#
# Show the list of buildable targets.
#
show: .SYMBOLIC
	@echo.
	@echo The following [case sensitive] targets can be built:
	@for %%i in ($(TARGETS)) do @echo %%i
	@echo.
# Alias for show
list: .SYMBOLIC
	@%MAKE show

#
# Inform user that a rebuild might help if the build process fails.
#
.ERROR
	@echo.
	@echo Oops!
	@echo Some error occured in this build session.
	@echo If it's a linker problem, it could be
	@echo the result of out-of-sync object files.
	@echo Doing a wmake rebuild might resolve the problem.
	@%MAKE help
	@echo.
