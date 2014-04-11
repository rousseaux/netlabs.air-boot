###############################################################################
# Makefile :: Builds the AIRBOOT.BIN 16-bits RAW Loader Image.                #
###############################################################################
# rousseau@ecomstation.com
#
# Derived from the FIXCODE Makefile.
#

#
# This Makefile builds the AIRBOOT.BIN program.
# This is the actual AiR-BOOT that you see when starting your system.
# It operates at the BIOS level and thus without any operating-system
# being active. It's first 512 bytes get loaded by the BIOS at address
# 0000:7C00 and then control is transferred. This first 512 bytes constitute
# the AiR-BOOT MBR-code, and this code loads the rest of the AiR-BOOT image.
#

#
# AiR-BOOT, as designed by Martin Kiewitz, boosts a lot of powerful features
# in a tiny space (just over 31kB). One of this features is detecting
# possible virusses. This detection code is "hooked" into the interrupt-chain
# and therefore has it's own relocations which are not related to the main
# loader image. For this reason, when the main source AIR-BOOT.ASM is assembled
# to a RAW image, this virus-protection code is "embedded" as the last step.
# You could compare this to binding a resource-file to an OS/2 executable.
#
# When AiR-BOOT gets control, this virus-protection code is copied elsewhere
# and hooked into the interrupt-system. So it functions kinda like a DOS TSR.
#

#
# This embedding proccess consists of three parts:
# - Assembling the virus-detection code, which always results
#   in a 1024 bytes image.
# - Compiling the FIXCODE program that does the actual embedding.
# - Running the FIXCODE program against AIR-BOOT.COM creating the
#	final AIRBOOT.BIN image.
#

#
# After these operations have completed, the AIRBOOT.BIN image
# is ready to be installed.
#

#
# The installer is a C program for OS/2 and Win32, using Open Watcom's
# cross-platform capabilities. The DOS installer is currently an Assembler
# program, making it harder to maintain and stay in sync with the C version.
# No Linux installer is available yet, but work is in progress.
# In future versions the DOS installer will also be built from the C sources
# as will the Linux version, again using Open Watcom's cross-platform
# capabilities. I call it 'DWOL': DOS, Windows, OS/2 and Linux.
#


#
# Include a Master Makefile with several cross-platform definitions and macros.
# This is used to compensate for the differences between the target platforms.
#
!include	../INCLUDE/MAKEFILE.MIF

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
# Source Level base-name of Target to build.
# The various language versions are created by replacing TXT-files
# and reassembling this file.
#
BASENAME=AIR-BOOT

#
# When you are developing, you might want to do that using your own language.
# Using wmake dev will built a module called AIRBOOT.BIN with this language
# and leave all the intermediate files intact.
# You also want to set this to RU because for this language an extra charset
# in included, taking up extra space. If it builds with RU it will build
# with all other languages.
#
DEV_BLD_LANG=EN

#
# These are the languages that AiR-BOOT can be assembled with.
# Adding a new language requires creating the relevant TXT-files,
# placing then in the correct language directory and then add the lang-ID here.
# RU is last in the list since it includes a charset will run out-of-space
# sooner that the other languages. If that happens at least a few will be
# built for analysis.
#
BLD_LANGUAGES=EN DE NL FR IT SW RU
#BLD_LANGUAGES=EN DE NL

#
# For each language the Assembler source is compiled to a binary image
# with this basename. Note that it differs from the source basename.
#
MODULE=AIRBOOT

#
# This is a list of the Targets to be built.
# For AiR-BOOT there is only one real target: AIRBOOT.BIN.
# Each language build generates this target and it is later renamed.
# Only a dev-build does not rename it so it can directly be used by
# the installer.
#
TARGET=$(MODULE).BIN

#
# Assembler Tools.
#
#ASM=masm
#ASM=alp
#ASM=tasm
#ASM=wasm
ASM=jwasm

#
# JWasm does not work on DOS, so we override it.
#
!ifdef	__MSDOS__
ASM=tasm
!endif

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
ASM_FLAGS_D0=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -zcw -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR
ASM_FLAGS_D1=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -zcw -Zd -Zi -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR
ASM_FLAGS_D2=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -zcw -Zd -Zi -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR
!elseif "$(ASM)"=="masm"
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dMASM -zq -fo=$^. -fr=$^&.ERR
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dMASM -zq -d1 -fo=$^. -fr=$^&.ERR
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dMASM -zq -d1 -fo=$^. -fr=$^&.ERR
!elseif "$(ASM)"=="wasm"
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dWASM -zq -fo=$^. -fr=$^&.ERR
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dWASM -zq -d1 -fo=$^. -fr=$^&.ERR
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dWASM -zq -d1 -fo=$^. -fr=$^&.ERR
!elseif "$(ASM)"=="tasm"
# -ml	= case sensitive symbols
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -m2 -l
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -m9 -z -zi -c -la
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -m9 -z -zi -c -la
!elseif "$(ASM)"=="alp"
ASM_FLAGS_D0=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP -Mb +Feo:OBJ +Fl +Fel:LST +Fm +Fem:ERR
ASM_FLAGS_D1=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP -Mb +Od:MS16 +Feo:OBJ +Fl +Fel:LST +Fm +Fem:ERR
ASM_FLAGS_D2=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP
!else
!error Unknown Assembler specified !
!endif
ASM_FLAGS=$(ASM_FLAGS_D$(DEBUG_LEVEL))

#
# 16-bits C Compiler
#
CC16=wcc
CC16_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -w4 -e25 -zq -od -fo=$^.
CC16_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -d2 -w4 -e25 -zq -od -fo=$^.
CC16_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -d2 -w4 -e25 -zq -od -fo=$^.
CC16_FLAGS=$(CC16_FLAGS_D$(DEBUG_LEVEL))

#
# 32-bits C Compiler
#
CC32=wcc386
CC32_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -w4 -e25 -zq -od -6r -mf -fo=$^.
CC32_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -d2 -w4 -e25 -zq -od -6r -mf -fo=$^.
CC32_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -d2 -w4 -e25 -zq -od -6r -mf -fo=$^.
CC32_FLAGS_R=-w4 -e25 -zq -od -6r -mf -fo=$^.
CC32_FLAGS=$(CC32_FLAGS_D$(DEBUG_LEVEL))

#
# Linker
#
LNK=wlink
LNK_FLAGS_D0=op q op v disa {1014 1023} op map=$^&.MAP
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
# This builds all the languages using normal dependency rules.
# If this Makefile was modified, all targets are forcefully rebuilt.
# At the end all intermediate files are deleted.
# Use wmake dev to to development; this generated one image and leaves
# the intermediate files intact.
#
all:	.SYMBOLIC Makefile.bu mbrprot $(BLD_LANGUAGES) footer
#	@echo ALL !!
#	@#MAKE $(BLD_LANGUAGES)
#	@for %%i in ($(BLD_LANGUAGES)) do @%MAKE AB-%%i
#	@echo $<
	@%MAKE clean

#
# Setup the relevant language files.
#
langsetup:	.SYMBOLIC .MULTIPLE
	@echo Include TEXT/$(%BLD_LANG)/MBR.ASM 		> TEXT$(DS)TXTMBR.ASM
	@echo Include TEXT/$(%BLD_LANG)/MENUS.ASM		> TEXT$(DS)TXTMENUS.ASM
	@echo Include TEXT/$(%BLD_LANG)/OTHER.ASM 	> TEXT$(DS)TXTOTHER.ASM

#
# For every language we Assemble and Link steps are performed.
# This is the symbolic meta-target for that.
# If functions as an iteration (for-next loop).
#
$(BLD_LANGUAGES):	.SYMBOLIC
	@SET BLD_LANG=$@
	@%MAKE header
	@%MAKE clean
	@%MAKE rmbin
	@%MAKE langsetup
	@%MAKE $(TARGET)
# Supress rename message for dev-build
!if	"$(%AB_DEV)"!="TRUE"
	@echo 	Renaming to AIRBT-$@.BIN
	$(MV) $(TARGET) AIRBT-$@.BIN
#	@echo $@>AIRBT-$@.BIN $(%AB_DEV)
!endif

#	@%MAKE clean


#
# Some targets have the .MULTIPLE directive defined.
# This is because the iteration "calls" for the creation of other (meta)
# targets. If .MULTIPLE would not be defined these (meta) targets would not
# be "built" anymore because the are considered up-to-date.
# With multiple this assumption is removed and the target is "rebuilt" for
# every target that depends on it.
# This mostly concerns meta operations like clean etc.,
# but of course also the main building of the AIRBOOT.BIN module.
#

#
# Show the header.
#
header:	.SYMBOLIC .MULTIPLE
	@echo.
	@echo =====================================================================
	@echo = MODULE: $(TARGET)    [$(%BLD_LANG)]           [16-bits Raw Binary Loader] =
	@echo =====================================================================
#	@echo.


#
# Show the footer.
#
footer:	.SYMBOLIC
#	$(RM) $(TARGET)
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
# This builds the MBR Protection Image.
# It will be embedded into the final AiR-BOOT binary. (AIRBOOT.BIN)
#
mbrprot:	.symbolic
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@echo @ Building MBR Protection Image and FixCode first @
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	cd MBR-PROT
	wmake -h
	cd ..
	@%MAKE fixcode
	@echo ______________________________________________________________________________

#
# FixCode embeds the MBR Protection Image into the final AiR-BOOT binary.
#
fixcode:	.procedure
	cd ..$(DS)TOOLS$(DS)INTERNAL
	wmake -h
	cd ..$(DS)..$(DS)BOOTCODE


#
# MAIN TARGETS
#


###############################################################################
# 16-bits RAW :: Final image that can be executed when activated by the BIOS.
###############################################################################
$(TARGET):	.MULTIPLE $(BASENAME).COM
#	$(LNK) $(LNK_FLAGS) file $^&.OBJ name $^. sys dos com
!ifdef	__OS2__
	..$(DS)TOOLS$(DS)INTERNAL$(DS)FIXCODE.COM
!endif
#	@echo 	FIXCODE
	$(CP) $(BASENAME).COM $(TARGET)
	ndisasm $(BASENAME).COM > $(BASENAME).COM.NDA
	ndisasm $(TARGET) > $(TARGET).NDA
#	@echo $(%BLD_LANG)>$^.
	@if exist $^. @echo		$^. $(MSG_SUCCESS) - [$(%BLD_LANG) version]
#	$(RM) $(TARGET)
#	@echo.



###############################################################################
# 16-bits COM :: Intermediate image without embedded MBR-prot. and code count.
###############################################################################
$(BASENAME).COM:	.MULTIPLE $(BASENAME).OBJ
	$(LNK) $(LNK_FLAGS) file $^&.OBJ name $^. sys dos com
#	$(LNK) $(LNK_FLAGS) file $^&.OBJ name $^. form raw
#	@if exist $^. @echo		$^. $(MSG_SUCCESS)
#	@echo.

$(BASENAME).OBJ:	.MULTIPLE $(BASENAME).ASM
#	@echo.
	@echo TARGET: $^.	[DOS 16-bits Raw Image]
	$(ASM) $(ASM_FLAGS) $(BASENAME).ASM
	@wdis $^. > $^&.WDA



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
clean:	.SYMBOLIC .MULTIPLE
#	@echo CLEANING UP
	@for %%i in ($(TARGET)) do @if exist %%i $(RM) %%i
	@if exist *.COM $(RM) *.COM
	@if exist *.OBJ $(RM) *.OBJ
	@if exist *.WDA $(RM) *.WDA
	@if exist *.MAP $(RM) *.MAP
	@if exist *.LST $(RM) *.LST
	@if exist *.ERR $(RM) *.ERR
	@if exist *.o   $(RM) *.o

#
# Remove all residual .BIN files.
#
rmbin:	.SYMBOLIC
	@if exist *.BIN $(RM) *.BIN

#
# This meta-target build a module using the DEV_BLD_LANG setting.
# It does not change the file-name so it can directly be used by the
# installer.
#
dev:	.SYMBOLIC
	#eee
	@%MAKE rmbin
	@%MAKE mbrprot
	SET AB_DEV=TRUE
#	@%MAKE $(DEV_BLD_LANG)
# We need to recurse here because the environment is used to pass AB_DEV.
# We also don't want .MULTIPLE which we won't get if we build just one target.
	@$(MAKE) $(DEV_BLD_LANG)

dist:	.SYMBOLIC
	$(CP) $(TARGET) ..$(DS)RELEASE$(DS)DOS

#
# Help on using this Makefile.
#
help:	.SYMBOLIC
	@echo.
	@echo		The following actions are available:
	@echo		wmake 		to build all targets and all languages
	@echo		wmake dev	to build a develoopment target
	@echo		wmake [LANG]	to build EN,DE,NL,FR,IT or RU versions
	@echo		wmake list	to show the list of buildable targets
	@echo		wmake clean 	to remove almost all generated files
	@echo		wmake rmbin 	to remove all residual BIN files
	@echo		wmake rebuild	to rebuild all targets
	@echo		wmake dist	to populate the dist directories
	@echo		wmake help 	for this information
	@echo.

#
# Show the list of buildable targets.
#
show:	.SYMBOLIC
	@echo.
	@echo		The following [case sensitive] targets can be built:
	@for %%i in ($(TARGET)) do @echo 	%%i
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
	@echo		Doing a wmake rebuild might solve the problem.
	@echo		Type wmake help for a list of actions.
#	@%MAKE help
	@echo.

#
# How the hell can we use get more than one command in the for-loop ??
#
ttt:	.SYMBOLIC
#	@for %%i in ($(BLD_LANGUAGES)) do %%i=X; $%WMAKE;
