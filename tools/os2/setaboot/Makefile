###############################################################################
# Makefile :: Builds the 'set(a)boot' 'setboot' replacement for OS/2  [WMake] #
# --------------------------------------------------------------------------- #
#                                                                             #
# This Makefile builds the 'set(a)boot' 'setboot' replacement for OS/2.       #
#                                                                             #
###############################################################################


#
# Include a Master Makefile with several cross-platform definitions and macros.
# This is used to compensate for the differences between the target platforms.
#
!include ../../../include/makefile.mif



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
BASENAME=setaboot

#
# Base Name of Executable Module to build.
# A letter is appended for each platform version:
# D=DOS, W=Windows, 2=OS2, L=Linux.
#
MODULE=$(BASENAME)

#
# This is a list of the Targets to be built.
#
#TARGETS=$(MODULE)d.exe $(MODULE)w.exe $(MODULE)2.exe $(MODULE)l.elf
TARGETS=$(MODULE).exe

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
ASM_FLAGS_D1=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Cp -Zd -Zi -Fo$^. -Sa -Fl=$^&.lst -Fw$^&.err
ASM_FLAGS_D2=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Cp -Zd -Zi -Fo$^. -Sa -Fl=$^&.lst -Fw$^&.err
!elseif "$(ASM)"=="wasm"
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -fo=$^. -fr=$^&.err
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -d1 -fo=$^. -fr=$^&.err
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -d1 -fo=$^. -fr=$^&.err
!elseif "$(ASM)"=="tasm"
# -ml	= case sensitive symbols
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -ml -l
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -ml -z -zi -c -la
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -ml -z -zi -c -la
!elseif "$(ASM)"=="alp"
ASM_FLAGS_D0=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ASSEMBLER=ALP -Mb +Feo:obj +Fl +Fel:lst +Fm +Fem:err
ASM_FLAGS_D1=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ASSEMBLER=ALP -Mb +Od:MS16 +Feo:obj +Fl +Fel:lst +Fm +Fem:err
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
CC16_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) $(%CC_DEFINES) -w4 -e25 -zq -otebmieran -fo=$^. -fr=$^&.err
#~ CC16_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) $(%CC_DEFINES) -w4 -e25 -zq -otexan -fo=$^. -fr=$^&.err
CC16_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) $(%CC_DEFINES) -d2 -w4 -e25 -zq -od -fo=$^. -fr=$^&.err
CC16_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) $(%CC_DEFINES) -d3 -w4 -e25 -zq -od -fo=$^. -fr=$^&.err
CC16_FLAGS=$(CC16_FLAGS_D$(DEBUG_LEVEL))

#
# 32-bits C Compiler
#
MM32=-mf
CC32=wcc386
# rousseau.comment.201711092035 :: -ol optimization generates inconsistent code
# It was already observed that building on Linux could generate different code
# as when building on OS/2, so releases were always built on OS/2.
# Lately, however, different code generation was also observed between building
# on a local drive and on a network drive, both under OS/2. But is was not the
# local or remote nature of the drive, but it seemed like the length of the
# path to the sources played a role. Doing two builds on a local drive on OS/2,
# one with a short path and one with a longer path generated substantially
# different (prolog / indexing) code at specific locations. The one used a
# combination of 'mov' and 'add' while the other used 'lea'.
#
# This has been tracked down to the wcc386 -ol (enable loop optimizations)
# flag, which is part of -ox, which is short for -obmiler -s.
# So the new flags replace -ox with -obmier and since we actually do want
# stack overflow checking (-s), this flag is not re-added.
#
# Now MD5SUMS are the same again, even when building on Linux.
# This requires further investigation and a cross-check against v1.9+ versions
# of Open Watcom.
CC32_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) $(%CC_DEFINES) -w4 -e25 -zq -otebmieran -6r -fo=$^. -fr=$^&.err
#~ CC32_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) $(%CC_DEFINES) -w4 -e25 -zq -otexan -6r -fo=$^. -fr=$^&.err
CC32_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) $(%CC_DEFINES) -d2 -w4 -e25 -zq -od -6r -fo=$^. -fr=$^&.err
CC32_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) $(%CC_DEFINES) -d3 -w4 -e25 -zq -od -6r -fo=$^. -fr=$^&.err
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
#~ LNK_FLAGS_D0=op q op v op map=$^&.map op de '\x40\x23KIEWITZ:1.18\x23\x40\x41iR-BOOT Installer by Kiewitz'
LNK_FLAGS_D0=op q op v op map=$^&.map
#~ LNK_FLAGS_D1=op q op v d all &
	#~ order clname CODE clname FAR_CONST clname FAR_DATA clnam BEGDATA clname DATA clname BSS clname STACK clname BLAP NOE &
	#~ op map=$^&.map
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
!ifdef	__MSDOS__
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
#all: .SYMBOLIC
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
	@echo = PROGRAM: 'setaboot', setboot replacement for OS/2          [OS/2] =
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
# MAIN TARGET
#

###############################################################################
# OS/2 32-bits (LX)
###############################################################################
$(MODULE).exe: $(MODULE).obj
	$(LNK) $(LNK_FLAGS) file $^&.obj name $^. sys os2v2
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@echo.
	#~ wstrip $^.

$(MODULE).obj:	$(BASENAME).c $(BASENAME).h
#	@echo.
	@echo TARGET: $^&.exe [OS/2 32-bits Executable]
	$(CC32) $(CC32_FLAGS) -I$(%WATCOM)$(DS)h$(DS)os2 -bt=os2 $(BASENAME).c
	@wdis -fi $^. > $^&.wda



#
# MAIN ACTIONS
#

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
	@if exist *.nda $(RM) *.nda
	@if exist *.map $(RM) *.map
	@if exist *.lst $(RM) *.lst
	@if exist *.err $(RM) *.err
	@if exist *.o   $(RM) *.o

# -----------------------------------------------------------------------------
# DISTRIBUTE TO RELEASE SPACE
# -----------------------------------------------------------------------------
# This distributes 'setaboot' 'release'.
# -----------------------------------------------------------------------------
dist: .SYMBOLIC
	@if exist *.exe $(CP) *.exe ..$(DS)..$(DS)..$(DS)release$(DS)os2
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
