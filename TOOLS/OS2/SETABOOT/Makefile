###############################################################################
# Makefile :: Builds the SET(A)BOOT Helper for several platforms.     [wmake] #
###############################################################################
# rousseau@ecomstation.com
#
# Derived from the INSTALL Makefile.
#

#
# This Makefile builds the SET(A)BOOT Helper for DOS, Windows, OS/2 and Linux.
# Like FIXCODE, each platform version has a letter appended it:
# 'D' for DOS, 'W' for Windows, '2' for OS/2 and 'L' for Linux.
#

#
# Include a Master Makefile with several cross-platform definitions and macros.
# This is used to compensate for the differences between the target platforms.
#
!include	../../../INCLUDE/MAKEFILE.MIF



#
# Specifies the level of debugging.
# Level 0 is no debugging (release) and each higher level may use other
# assembler / compiler / linker flags and define jammed-in constants
# to influence source assembly / compilation.
#
DEBUG_LEVEL=0
MAX_DEBUG_LEVEL=2

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
BASENAME=SETABOOT

#
# Base Name of Executable Module to build.
# A letter is appended for each platform version:
# D=DOS, W=Windows, 2=OS2, L=Linux.
#
MODULE=$(BASENAME)

#
# This is a list of the Targets to be built.
#
#TARGETS=$(MODULE)D.EXE $(MODULE)W.EXE $(MODULE)2.EXE $(MODULE)L.ELF
TARGETS=$(MODULE).EXE

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
!ifdef	__LINUX__
!if "$(ASM)"=="masm" | "$(ASM)"=="tasm" | "$(ASM)"=="alp"
ASM=jwasm
!endif
!endif

!if "$(ASM)"=="jwasm"
# -Cp	= case sensitive symbols
# -zcw	= no _ prefix on symbols (C model)
ASM_FLAGS_D0=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Cp -Fo$^. -Fl=$^&.LST -Fw$^&.ERR
ASM_FLAGS_D1=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Cp -Zd -Zi -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR
ASM_FLAGS_D2=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Cp -Zd -Zi -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR
!elseif "$(ASM)"=="wasm"
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -fo=$^. -fr=$^&.ERR
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -d1 -fo=$^. -fr=$^&.ERR
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -d1 -fo=$^. -fr=$^&.ERR
!elseif "$(ASM)"=="tasm"
# -ml	= case sensitive symbols
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -ml -l
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -ml -z -zi -c -la
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -ml -z -zi -c -la
!elseif "$(ASM)"=="alp"
ASM_FLAGS_D0=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ASSEMBLER=ALP -Mb +Feo:OBJ +Fl +Fel:LST +Fm +Fem:ERR
ASM_FLAGS_D1=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ASSEMBLER=ALP -Mb +Od:MS16 +Feo:OBJ +Fl +Fel:LST +Fm +Fem:ERR
ASM_FLAGS_D2=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ASSEMBLER=ALP
!else
!error Unknown Assembler specified !
!endif
ASM_FLAGS=$(ASM_FLAGS_D$(DEBUG_LEVEL))

#
# 16-bits C Compiler
#
MM16=-ml
CC16=wcc
CC16_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) -w4 -e25 -zq -otexan -fo=$^. -fr=$^&.ERR
CC16_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) -d2 -w4 -e25 -zq -od -fo=$^. -fr=$^&.ERR
CC16_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) -d3 -w4 -e25 -zq -od -fo=$^. -fr=$^&.ERR
CC16_FLAGS=$(CC16_FLAGS_D$(DEBUG_LEVEL))

#
# 32-bits C Compiler
#
MM32=-mf
CC32=wcc386
CC32_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) -w4 -e25 -zq -otexan -6r -fo=$^. -fr=$^&.ERR
CC32_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) -d2 -w4 -e25 -zq -od -6r -fo=$^. -fr=$^&.ERR
CC32_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) -d3 -w4 -e25 -zq -od -6r -fo=$^. -fr=$^&.ERR
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
LNK_FLAGS_D0=op q op v op map=$^&.MAP
#~ LNK_FLAGS_D1=op q op v d all &
	#~ order clname CODE clname FAR_CONST clname FAR_DATA clnam BEGDATA clname DATA clname BSS clname STACK clname BLAP NOE &
	#~ op map=$^&.MAP
LNK_FLAGS_D1=op q op v d all op map=$^&.MAP
LNK_FLAGS_D2=op q op v d all op map=$^&.MAP
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
!ifdef	__MSDOS__
	@echo $(WARN_DOS_BLD_ENV)
!endif


#
# This builds all targets by using normal dependency rules.
# If this Makefile was modified, all targets are forcefully rebuilt.
#
all:	.SYMBOLIC Makefile.bu header $(TARGETS) footer


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
header:	.SYMBOLIC
	@echo.
	@echo =====================================================================
	@echo = PROGRAM: SETABOOT Multi Platform   [DOS, Win32, OS/2 and Linux] =
	@echo =====================================================================
#	@echo.


#
# Show the footer.
#
footer:	.SYMBOLIC
	@echo All targets up to date !
	@echo.


#
# Create a backup of the Makefile when it is modified.
# This also forces a rebuild of all targets.
# So, when changing i.e. the DEBUG_LEVEL, all targets are rebuilt
# using the new level.
#
Makefile.bu:	Makefile
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
# MAIN TARGET
#

###############################################################################
# OS/2 32-bits (LX)
###############################################################################
$(MODULE).EXE:	$(MODULE).OBJ
	$(LNK) $(LNK_FLAGS) file $^&.OBJ name $^. sys os2v2
	@if exist $^. @echo		$^. $(MSG_SUCCESS)
	@echo.
	#~ wstrip $^.

$(MODULE).OBJ:	$(BASENAME).C $(BASENAME).H
#	@echo.
	@echo TARGET: $^&.EXE	[OS/2 32-bits Executable]
	$(CC32) $(CC32_FLAGS) -I$(%WATCOM)$(DS)h$(DS)os2 -bt=os2 $(BASENAME).C
	@wdis -fi $^. > $^&.WDA



#
# MAIN ACTIONS
#

#
# Rebuild all targets.
#
rebuild:	.SYMBOLIC
	@%MAKE clean
	@%MAKE all

#
# Remove all generated files.
#
clean:	.SYMBOLIC
	@for %%i in ($(TARGETS)) do @if exist %%i $(RM) %%i
	@if exist *.OBJ $(RM) *.OBJ
	@if exist *.WDA $(RM) *.WDA
	@if exist *.NDA $(RM) *.NDA
	@if exist *.MAP $(RM) *.MAP
	@if exist *.LST $(RM) *.LST
	@if exist *.ERR $(RM) *.ERR
	@if exist *.o   $(RM) *.o

# -----------------------------------------------------------------------------
# DISTRIBUTE TO RELEASE SPACE
# -----------------------------------------------------------------------------
# This distributes all .BIN files to BOOTCODE.
# Then it installs the English version to RELEASES as AIRBOOT.BIN.
# -----------------------------------------------------------------------------
dist:	.SYMBOLIC
	@if exist *.EXE $(CP) *.EXE ..$(DS)..$(DS)..$(DS)RELEASE$(DS)OS2
#	@if exist *.EXE $(CP) *.EXE ..$(DS)..$(DS)..$(DS)RELEASE$(DS)BOOTCODE
#
# Help on using this Makefile.
#
help:	.SYMBOLIC
	@echo.
	@echo		The following actions are available:
	@echo		wmake 		to build all targets
	@echo		wmake show	to show the list of buildable targets
	@echo		wmake clean 	to remove all generated files
	@echo		wmake rebuild	to rebuild all targets
	@echo		wmake help 	for this information
	@echo.

#
# Show the list of buildable targets.
#
show:	.SYMBOLIC
	@echo.
	@echo		The following [case sensitive] targets can be built:
	@for %%i in ($(TARGETS)) do @echo 	%%i
	@echo.
# Alias for show
list:	.SYMBOLIC
	@%MAKE show

#
# Inform user that a rebuild might help if the build process fails.
#
.ERROR
	@echo.
	@echo		Oops!
	@echo		Some error occured in this build session.
	@echo		If it's a linker problem, it could be
	@echo		the result of out-of-sync object files.
	@echo		Doing a wmake rebuild might resolve the problem.
	@%MAKE help
	@echo.


