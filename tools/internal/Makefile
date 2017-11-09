###############################################################################
# Makefile :: Builds 'fixcode' program for several platforms.         [WMake] #
# --------------------------------------------------------------------------- #
#                                                                             #
# This Makefile builds the 'fixcode' program for DOS, Windows, OS/2 & Linux.  #
# It is used to embed the anti-virus code into the AiR-BOOT image.            #
# This anti-virus code protects the MBR and is installed as a TSR by the      #
# loader. That's why it cannot be included at the source level.               #
#                                                                             #
###############################################################################


#
# Include a Master Makefile with several cross-platform definitions and macros.
# This is used to compensate for the differences between the target platforms.
#
!include ../../include/makefile.mif



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
# Base Name of Program to build.
# A letter is appended for each platform version:
# D=DOS, W=Windows, 2=OS2, L=Linux.
# The DOS COM-version has no suffix.
#
BASENAME=fixcode

#
# This is a list of the Targets to be built.
#
#TARGETS=$(BASENAME)d.exe
#TARGETS=$(BASENAME).com
#TARGETS=$(BASENAME).com $(BASENAME)d.exe $(BASENAME)w.exe $(BASENAME)2.exe $(BASENAME)l.elf
TARGETS=$(BASENAME)d.exe $(BASENAME)w.exe $(BASENAME)2.exe $(BASENAME)l.elf

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
# -zcw  = no _ prefix on symbols (C model)
ASM_FLAGS_D0=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Cp -Fo$^. -Fl=$^&.lst -Fw$^&.err
ASM_FLAGS_D1=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Zd -Zi -Fo$^. -Sa -Fl=$^&.lst -Fw$^&.err
ASM_FLAGS_D2=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DASSEMBLER=JWASM -q -Zd -Zi -Fo$^. -Sa -Fl=$^&.lst -Fw$^&.err
!elseif "$(ASM)"=="wasm"
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -fo=$^. -fr=$^&.err
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -d1 -fo=$^. -fr=$^&.err
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -zq -d1 -fo=$^. -fr=$^&.err
!elseif "$(ASM)"=="tasm"
# -ml  = case sensitive symbols
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -l
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -z -zi -c -la
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dASSEMBLER=TASM -t -z -zi -c -la
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
CC16=wcc
MM16=-ml
#~ CC16_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) $(%CC_DEFINES) -w4 -e25 -zq -otexan -fo=$^. -fr=$^&.err
CC16_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) $(%CC_DEFINES) -w4 -e25 -zq -otebmieran -fo=$^. -fr=$^&.err
CC16_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) $(%CC_DEFINES) -d2 -w4 -e25 -zq -od -fo=$^. -fr=$^&.err
CC16_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM16) $(%CC_DEFINES) -d2 -w4 -e25 -zq -od -fo=$^. -fr=$^&.err
CC16_FLAGS=$(CC16_FLAGS_D$(DEBUG_LEVEL))

#
# 32-bits C Compiler
#
MM32=-mf
CC32=wcc386
#~ CC32_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) $(%CC_DEFINES) -w4 -e25 -zq -otexan -6r -fo=$^. -fr=$^&.err
CC32_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) $(%CC_DEFINES) -w4 -e25 -zq -otebmieran -6r -fo=$^. -fr=$^&.err
CC32_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) $(%CC_DEFINES) -d2 -w4 -e25 -zq -od -6r -fo=$^. -fr=$^&.err
CC32_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) $(MM32) $(%CC_DEFINES) -d2 -w4 -e25 -zq -od -6r -fo=$^. -fr=$^&.err
CC32_FLAGS_R=-w4 -e25 -zq -od -6r -mf -fo=$^.
CC32_FLAGS=$(CC32_FLAGS_D$(DEBUG_LEVEL))

#
# Linker
#
LNK=wlink
LNK_FLAGS_D0=op q op v op map=$^&.map
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
	@echo = PROGRAM: 'fixcode' Multi Platform    [DOS, Win32, OS/2 and Linux] =
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
# MAIN TARGETS
#

###############################################################################
# DOS 16-bits (COM)
###############################################################################
$(BASENAME).com: $(BASENAME).obj
	$(LNK) $(LNK_FLAGS) file $^&.obj name $^. sys dos com
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@echo.

$(BASENAME).obj: $(BASENAME).asm
#	@echo.
	@echo TARGET: $^&.com [DOS 16-bits COM-file]
	$(ASM) $(ASM_FLAGS) $(BASENAME).asm
	@wdis -fi $^. > $^&.wda


###############################################################################
# DOS 16-bits (MZ)
###############################################################################
$(BASENAME)d.exe: $(BASENAME)d.obj
	$(LNK) $(LNK_FLAGS) file $^&.obj name $^. sys dos
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@echo.

$(BASENAME)d.obj: $(BASENAME).c $(BASENAME).h
#	@echo.
	@echo TARGET: $^&.exe [DOS 16-bits Executable]
	$(CC16) $(CC16_FLAGS) -bt=dos $(BASENAME).c
	@wdis -fi $^. > $^&.wda


###############################################################################
# NT 32-bits (PE)
###############################################################################
$(BASENAME)w.exe: $(BASENAME)w.obj
	$(LNK) $(LNK_FLAGS) file $^&.obj name $^. sys nt
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@echo.

$(BASENAME)w.obj: $(BASENAME).c $(BASENAME).h
#	@echo.
	@echo TARGET: $^&.exe [NT 32-bits Executable]
	$(CC32) $(CC32_FLAGS) -I$(%WATCOM)$(DS)h$(DS)nt -bt=nt $(BASENAME).c
	@wdis -fi $^. > $^&.wda


###############################################################################
# OS/2 32-bits (LX)
###############################################################################
$(BASENAME)2.exe: $(BASENAME)2.obj
	$(LNK) $(LNK_FLAGS) file $^&.obj name $^. sys os2v2
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@echo.

$(BASENAME)2.obj: $(BASENAME).c $(BASENAME).h
#	@echo.
	@echo TARGET: $^&.exe [OS/2 32-bits Executable]
	$(CC32) $(CC32_FLAGS) -I$(%WATCOM)$(DS)h$(DS)os2 -bt=os2 $(BASENAME).c
	@wdis -fi $^. > $^&.wda


###############################################################################
# Linux 32-bits (ELF)
###############################################################################
$(BASENAME)l.elf: $(BASENAME)l.obj
	$(LNK) $(LNK_FLAGS) file $^&.obj name $^&.elf sys linux
#	$(MV) $^&.elf $^.
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@echo.

$(BASENAME)l.obj: $(BASENAME).c $(BASENAME).h
#	@echo.
	@echo TARGET: $^&.elf [Linux 32-bits Executable]
	$(CC32) $(CC32_FLAGS) -bt=linux $(BASENAME).c
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
