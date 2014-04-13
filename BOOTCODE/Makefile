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
# - Assembling the virus-detection code, MBR_PROT.ASM, which always results
#   in a 1024 bytes image.
# - Compiling the FIXCODE program that does the actual embedding.
# - Running the FIXCODE program against AIR-BOOT.COM creating the
#	final AIRBOOT.BIN image.
#

#
# After these operations have been completed, the AIRBOOT.BIN image
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





# 							DEFINITIONS AND STUFF
# _____________________________________________________________________________


# Include a Master Makefile with several cross-platform definitions and macros.
# This is used to compensate for the differences between the target platforms.
!include	../INCLUDE/MAKEFILE.MIF


# Specifies the level of debugging.
# Level 0 is no debugging (release) and each higher level may use other
# assembler / compiler / linker flags and define jammed-in constants
# to influence source assembly / compilation.
DEBUG_LEVEL=0
MAX_DEBUG_LEVEL=2

# Protect against missing or invalid debug-levels.
!ifndef DEBUG_LEVEL
!error DEBUG_LEVEL not defined !
!elseifndef MAX_DEBUG_LEVEL
!error MAX_DEBUG_LEVEL not defined !
!elseif $(DEBUG_LEVEL) > $(MAX_DEBUG_LEVEL)
!error DEBUG_LEVEL cannot exceed $(MAX_DEBUG_LEVEL) !
!elseif $(DEBUG_LEVEL) < 0
!error DEBUG_LEVEL cannot be negative !
!endif

# Source Level base-name of Target to build.
# The various language versions are created by replacing TXT-files
# and reassembling this file.
BASENAME=AIR-BOOT

# When you are developing, you might want to do that using your own language.
# Using 'wmake dev' will built a module called AIRBOOT.BIN with this language
# and leave all the intermediate files intact.
# When developing on a non-RU language version, you need to do a 'wmake RU'
# from time-to-time to verify that you do not run out of space.
# This is needed because for this language the cyrillic charset is in included,
# taking up extra space. If it builds for RU it will build for all other
# languages.
DEV_BLD_LANG=EN

# These are the languages that AiR-BOOT can be assembled with.
# Adding a new language requires creating the relevant TXT-files,
# placing then in the correct language directory and then add the lang-ID here.
# RU is last in the list since it includes the cyrillic charset and thus
# will run out-of-space sooner that the other languages.
# If that happens at least the others will be built.
BLD_LANGUAGES=EN DE NL FR IT SW RU
#BLD_LANGUAGES=EN DE NL

# For each language the Assembler source is compiled to a binary image
# with this basename. When building one or more language versions, the
# final image is renamed to contain the language it was built for.
# When developing the final image is not renamed.
# Note that it differs from the source basename.
MODULE=AIRBOOT

# This is a list of the Targets to be built.
# For AiR-BOOT there is only one real target: AIRBOOT.BIN.
# Each language build generates this target and it is later renamed.
# Only a dev-build does not rename it so it can directly be used by
# the installer.
TARGET=$(MODULE).BIN

#~ %AB_DEV=FALSE

# Assembler Selection.
# Uncomment to enable.
# May be overridden by environment or platform choise !

# JWTM -- JWasm, Wasm, Tasm and Masm.
ASM=jwasm
#ASM=wasm
#ASM=tasm
#ASM=masm
#ASM=alp



# If there is an assembler specified in the environment, override
# the choise made above, if any.
!if "$(%ASM)"!=""
ASM=$(%ASM)
!endif

# If no assembler is specified then default to JWasm.
!ifndef	ASM
ASM=jwasm
!endif

# JWasmD needs special settings in an OS/2 VDM so we override it for DOS.
# To run JWasmD in an OS/2 VDM, change DPMI from AUTO to ENABLED and
# set the XMS memory limit to 0.
# JWasmR will probably run out of memory and cannot be used.
!ifdef	__MSDOS__
ASM=tasm
!endif

# There are no masm or alp for Linux and the yasm tasm-mode is incompatible.
# So we override to jwasm when a non-jwasm assembler is specified and
# we are building on Linux.
!ifdef	__LINUX__
!if "$(ASM)"=="masm" | "$(ASM)"=="tasm" | "$(ASM)"=="alp"
ASM=jwasm
!endif
!endif

#
# Assembler Flags.
#

# JWASM
!if "$(ASM)"=="jwasm"
# -Cp	= case sensitive symbols
# -zcw	= no _ prefix on symbols (C model)
# -Zm	= Masm51 compat -- don't use ! (Will generate incorrect offsets)
ASM_FLAGS_D0=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -W0 -Cp -zcw -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR
ASM_FLAGS_D1=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -W4 -Cp -zcw -Zd -Zi -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR
ASM_FLAGS_D2=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -W4 -Cp -zcw -Zd -Zi -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR

# WASM
!elseif "$(ASM)"=="wasm"
# -w0	= suppress warnings (wasm is nice to check for missing size qualifiers)
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dWASM -zq -w0 -fo=$^. -fr=$^&.ERR
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dWASM -zq -w4 -d1 -fo=$^. -fr=$^&.ERR
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dWASM -zq -w4 -d1 -fo=$^. -fr=$^&.ERR

# TASM
!elseif "$(ASM)"=="tasm"
# -ml	= case sensitive symbols
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -ml -m9 -l
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -ml -m9 -z -zi -c -la
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -ml -m9 -z -zi -c -la

# MASM
!elseif "$(ASM)"=="masm"
ASM_FLAGS_D0=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DMASM -c -nologo -Cp -Fo$^. -Sa -Fl$^&.LST
ASM_FLAGS_D1=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DMASM -c -nologo -Cp -Zd -Zi -Fo$^. -Sa -Fl$^&.LST
ASM_FLAGS_D2=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DMASM -c -nologo -Cp -Zd -Zi -Fo$^. -Sa -Fl$^&.LST

# ALP -- Does not support '/' for includes so it cannot be used for now.
!elseif "$(ASM)"=="alp"
ASM_FLAGS_D0=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP -Mb +Feo:OBJ +Fl +Fel:LST +Fm +Fem:ERR
ASM_FLAGS_D1=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP -Mb +Od:MS16 +Feo:OBJ +Fl +Fel:LST +Fm +Fem:ERR
ASM_FLAGS_D2=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP

# UNKNOWN
!else
!error Unknown Assembler specified ! *$(ASM)*
!endif
ASM_FLAGS=$(ASM_FLAGS_D$(DEBUG_LEVEL))


#
# Compiler Flags.
#


# 16-bits C Compiler.
CC16=wcc
CC16_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -w4 -e25 -zq -od -fo=$^.
CC16_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -d2 -w4 -e25 -zq -od -fo=$^.
CC16_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -d2 -w4 -e25 -zq -od -fo=$^.
CC16_FLAGS=$(CC16_FLAGS_D$(DEBUG_LEVEL))

# 32-bits C Compiler.
CC32=wcc386
CC32_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -w4 -e25 -zq -od -6r -mf -fo=$^.
CC32_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -d2 -w4 -e25 -zq -od -6r -mf -fo=$^.
CC32_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -d2 -w4 -e25 -zq -od -6r -mf -fo=$^.
CC32_FLAGS=$(CC32_FLAGS_D$(DEBUG_LEVEL))

#
# Linker Flags.
#

# Open Watcom Linker.
LNK=wlink
LNK_FLAGS_D0=op q op v disa {1014 1023} op map=$^&.MAP
LNK_FLAGS_D1=op q op v d all op map=$^&.MAP
LNK_FLAGS_D2=op q op v d all op map=$^&.MAP
LNK_FLAGS=$(LNK_FLAGS_D$(DEBUG_LEVEL))

# These need to be built
DEPTARGETS=MBR-PROT ..$(DS)TOOLS$(DS)INTERNAL



# 							BEFORE AND AFTER TARGETS
# _____________________________________________________________________________


# -----------------------------------------------------------------------------
# ANY PROCESSING BEFOREHAND
# -----------------------------------------------------------------------------
.BEFORE
#	@echo == BEFORE ==


# -----------------------------------------------------------------------------
# ANY PROCESSING AFTERWARDS
# -----------------------------------------------------------------------------
.AFTER
#	@echo == AFTER ==
!ifdef	__MSDOS__
	@echo $(WARN_DOS_BLD_ENV)
!endif
!if "$(ASM)"=="wasm" | "$(ASM)"=="masm"
	@echo $(WARN_OVERLAP_NOT_SUPPORTED)
!endif




# 						PSEUDO TARGETS FOR PREPARATION
# _____________________________________________________________________________


# -----------------------------------------------------------------------------
# BUILD ALL
# -----------------------------------------------------------------------------
# This builds all the languages using normal dependency rules.
# If this Makefile was modified, all targets are forcefully rebuilt.
# At the end all intermediate files are deleted.
# Use wmake dev to do development; that will generate one image and leave
# the intermediate files intact.
# -----------------------------------------------------------------------------
all:	.SYMBOLIC Makefile.bu mbrprot $(BLD_LANGUAGES) footer
#	@echo ALL !!
#	@#MAKE $(BLD_LANGUAGES)
#	@for %%i in ($(BLD_LANGUAGES)) do @%MAKE AB-%%i
#	@echo $<
	@%MAKE clean


# -----------------------------------------------------------------------------
# LANGUAGE SETUP
# -----------------------------------------------------------------------------
# Setup the relevant language files.
# This is done by generating include-files for the specified language.
# This is a 'pre-action' before assembling the AiR-BOOT.ASM source.
# -----------------------------------------------------------------------------
langsetup:	.SYMBOLIC .MULTIPLE
# Default to development language is none defined.
!if "$(%BLD_LANG)"==""
%BLD_LANG=DEV_BLD_LANG
!endif
# Generate include-files for specified language.
# After this, the Assembly sources are setup for the specified language.
# Note that this target is not used as a 'dependency' but 'called' explicitly
# by the $(BLD_LANGUAGES) target.
	@echo Include TEXT/$(%BLD_LANG)/MBR.ASM 		> TEXT$(DS)TXTMBR.ASM
	@echo Include TEXT/$(%BLD_LANG)/MENUS.ASM		> TEXT$(DS)TXTMENUS.ASM
	@echo Include TEXT/$(%BLD_LANG)/OTHER.ASM 		> TEXT$(DS)TXTOTHER.ASM


# -----------------------------------------------------------------------------
# BUILD ALL LANGUAGES
# -----------------------------------------------------------------------------
# For every language we Assemble and Link these steps are performed.
# This is the symbolic meta-target for building a language version.
# If functions as an iteration (for-next loop) because the 'all:' target
# depends on it.
# -----------------------------------------------------------------------------
$(BLD_LANGUAGES):	.SYMBOLIC
	@SET BLD_LANG=$@
	@%MAKE header
	@%MAKE clean
	@%MAKE rmbin
	@%MAKE langsetup
	@%MAKE $(TARGET)
# Checking %AB_DEV does not work from target 'dev:' when non-recursively
# invoked. Var '%AB_DEV' *is* set correctly but conditional !if's fail on it.
# Bug ?
#	@echo $(%AB_DEV)
# Do not rename for dev-build
!if	"$(%AB_DEV)"!="TRUE"
#~ !ifndef %AB_DEV
	@echo.
	@echo 	** Renaming Target **
	$(MV) $(TARGET) AIRBT-$@.BIN
!endif
#	@echo $(%AB_DEV)
#	@%MAKE clean


#
# Some targets have the .MULTIPLE directive defined.
# This is because the language iteration 'calls' for the creation of
# other (meta) targets. If .MULTIPLE were not defined these (meta) targets
# would not be 'built' anymore because they are considered up-to-date.
# With multiple this assumption is removed and the target is 'rebuilt' for
# every target that depends on it.
#


# -----------------------------------------------------------------------------
# SHOW THE HEADER FOR THE TARGET BEING BUILT
# -----------------------------------------------------------------------------
header:	.SYMBOLIC .MULTIPLE
	@echo.
	@echo =====================================================================
	@echo = MODULE: $(TARGET)    [$(%BLD_LANG)]           [16-bits Raw Binary Loader] =
	@echo =====================================================================
#	@echo.


# -----------------------------------------------------------------------------
# SHOW THE FOOTER
# -----------------------------------------------------------------------------
footer:	.SYMBOLIC
#	$(RM) $(TARGET)
	@echo All targets up to date !
	@echo.


# -----------------------------------------------------------------------------
# CHECK FOR MAKEFILE CHANGES
# -----------------------------------------------------------------------------
# Create a backup of the Makefile when it is modified.
# This also forces a rebuild of all targets.
# So, when changing i.e. the DEBUG_LEVEL, all targets are rebuilt
# using the new level.
# -----------------------------------------------------------------------------
Makefile.bu:	Makefile
	@echo.
	@echo Makefile modified, forcing rebuild of all targets !
	@echo.
	@%MAKE clean
	@$(CP) Makefile Makefile.bu > $(NULDEV)


#
# DOS WMake has a bug in that it expands $^& and $^. to lowercase,
# even though the definition is in uppercase.
# This gives problems when building in an OS/2 DOS-Box on a (samba) network
# share with a case-sensitive file-system where also a Linux build-environment
# is active. The Linux build-environment will not find the lowercase files.
# For example, a clean from Linux will not work properly in that case.
# This does not influence building DOS targets on Linux.
# It can be circumvented by using a case-insensitive file-system for the
# network share, like OS/2 JFS for instance.
# Linux can use OS/2 JFS and will honor it's case insensitivity.
# Or you could loop-mount the samba share either with the usual cifs tools
# or fuse-smb.
#

#
# While the DOS build-environment has been kept alive in this version,
# it has several drawbacks:
# - No support for long filenames
# - Very limited memory
# - JWasmR does not work because of memory limitations
# - JWasmD needs special OS/2 VDM settings
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


# 								MAIN TARGETS
# _____________________________________________________________________________


# -----------------------------------------------------------------------------
# FINAL AIRBOOT.BIN IMAGE
# -----------------------------------------------------------------------------
# This is the final AiR-BOOT image and has been built for the language
# requested. It can be installed on a system using the AiR-BOOT Installer.
# Note that this build-rule will be invoked multiple times if more than
# one language-build is requested.
# Also, the intermediate .COM and final .BIN targets are disassembled back
# with NDISASM for cross reference.
# -----------------------------------------------------------------------------
$(TARGET):	.MULTIPLE Makefile.bu $(BASENAME).COM
	@echo $^.:	[Final 16-bits raw Binary Image]
!ifdef	__MSDOS__
	..$(DS)TOOLS$(DS)INTERNAL$(DS)FIXCODED.EXE
!endif
!ifdef	__OS2__
	..$(DS)TOOLS$(DS)INTERNAL$(DS)FIXCODE2.EXE
!endif
!ifdef	__NT__
	..$(DS)TOOLS$(DS)INTERNAL$(DS)FIXCODEW.EXE
!endif
!ifdef	__LINUX__
#	..$(DS)TOOLS$(DS)INTERNAL$(DS)FIXCODE
	@chmod +x ..$(DS)TOOLS$(DS)INTERNAL$(DS)FIXCODEL.ELF
	..$(DS)TOOLS$(DS)INTERNAL$(DS)FIXCODEL.ELF
	@chmod +x $^.
!endif
	@echo.
!ifndef	__MSDOS__
	ndisasm $(BASENAME).COM > $(BASENAME).COM.NDA
	ndisasm $(TARGET) > $(TARGET).NDA
!endif
	@echo.
	@if exist $^. @echo		** $^. $(MSG_SUCCESS) - [$(%BLD_LANG) version] **


# -----------------------------------------------------------------------------
# INTERMEDIATE AIR-BOOT.COM IMAGE
# -----------------------------------------------------------------------------
# This is an intermediate image without embedded MBR-protection and code count.
# It needs to be post-processed with FIXBOOT.
#
# While both DOS COM and RAW linkage generate a flat 16-bits image with
# fixed-up locations, DOS COM checks that the addressibility of the image does
# not exceed the upper 64kB limit while RAW just wraps it's fixups.
# So we use DOS COM linkage to proteced us from overflow incorrect fixups.
# -----------------------------------------------------------------------------
$(BASENAME).COM:	.MULTIPLE $(BASENAME).OBJ
	@echo $^.:	[16-bits non-100h Intermediate Image]
	$(LNK) $(LNK_FLAGS) file $^&.OBJ name $^. sys dos com
#	$(LNK) $(LNK_FLAGS) file $^&.OBJ name $^. form raw


# -----------------------------------------------------------------------------
# INTERMEDIATE AIR-BOOT.OBJ OBJECT MODULE
# -----------------------------------------------------------------------------
# This is the result of assembling AIR-BOOT.ASM.
# It is assembled back twice with WDIS for cross reference.
# - once as an (almost) assemblable source-file
# - once as a disassembly with opcodes in it
# -----------------------------------------------------------------------------
$(BASENAME).OBJ:	.MULTIPLE $(BASENAME).ASM
	@echo $^.:	[16-bits OMF Object File]
	$(ASM) $(ASM_FLAGS) $(BASENAME).ASM
!ifndef	__MSDOS__
	@wdis -fi $^. > $^..WDA
!endif
	@wdis -a -p -fi $^. > $^&.WDA



# 								MAIN ACTIONS
# _____________________________________________________________________________


# -----------------------------------------------------------------------------
# DEVELOPER TARGET
# -----------------------------------------------------------------------------
# This meta-target builds an AIRBOOT.BIN module using the DEV_BLD_LANG setting.
# It does not change the file-name to correspond to the language,
# so it can directly be used by the installer.
# This is the main target when developing.
# -----------------------------------------------------------------------------
dev:	.SYMBOLIC
	@%MAKE rmbin
	@%MAKE mbrprot
	SET AB_DEV=TRUE
#	@%MAKE $(DEV_BLD_LANG)
# We need to recurse here because the environment is used to pass AB_DEV and
# the testing on it does not seem to work when using @%MAKE syntax. (bug ?)
# We also don't want .MULTIPLE which we won't get if we build just one target.
	@$(MAKE) $(DEV_BLD_LANG)
# Display the BLDLEVEL information if we are building on OS/2.
!ifdef	__OS2__
	@echo.
	@bldlevel $(TARGET)
!endif
!ifdef	__LINUX__
	@echo.
	@if exist AIR-BOOT.LST @grep ^zzz_code_space AIR-BOOT.LST
	@echo.
!endif

# -----------------------------------------------------------------------------
# REBUILD ALL TARGETS
# -----------------------------------------------------------------------------
rebuild:	.SYMBOLIC
	@%MAKE clean
	@%MAKE all


# -----------------------------------------------------------------------------
# CLEANUP (intermediate files)
# -----------------------------------------------------------------------------
clean:	.SYMBOLIC .MULTIPLE
#	@echo CLEANING UP
	@for %%i in ($(TARGET)) do @if exist %%i $(RM) %%i
	@if exist *.COM $(RM) *.COM
	@if exist *.COM $(RM) *.EXE
	@if exist *.OBJ $(RM) *.OBJ
	@if exist *.WDA $(RM) *.WDA
	@if exist *.NDA $(RM) *.NDA
	@if exist *.MAP $(RM) *.MAP
	@if exist *.LST $(RM) *.LST
	@if exist *.ERR $(RM) *.ERR
	@if exist *.o   $(RM) *.o


# -----------------------------------------------------------------------------
# REMOVE ALL RESIDUAL .BIN FILES (old builds)
# -----------------------------------------------------------------------------
rmbin:	.SYMBOLIC
	@if exist *.BIN $(RM) *.BIN


# -----------------------------------------------------------------------------
# DISTRIBUTE TO RELEASE SPACE
# -----------------------------------------------------------------------------
# This distributes all .BIN files to BOOTCODE.
# Then it installs the English version to RELEASES as AIRBOOT.BIN.
# -----------------------------------------------------------------------------
dist:	.SYMBOLIC
	@if exist *.BIN $(CP) *.BIN ..$(DS)RELEASE$(DS)BOOTCODE
	@if exist AIRBT-EN.BIN $(CP) AIRBT-EN.BIN ..$(DS)RELEASE$(DS)DOS$(DS)$(TARGET)
	@if exist AIRBT-EN.BIN $(CP) AIRBT-EN.BIN ..$(DS)RELEASE$(DS)WINNT$(DS)$(TARGET)
	@if exist AIRBT-EN.BIN $(CP) AIRBT-EN.BIN ..$(DS)RELEASE$(DS)OS2$(DS)$(TARGET)
	@if exist AIRBT-EN.BIN $(CP) AIRBT-EN.BIN ..$(DS)RELEASE$(DS)LINUX$(DS)$(TARGET)


# -----------------------------------------------------------------------------
# SHOW HELP ON USING THIS MAKEFILE
# -----------------------------------------------------------------------------
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


# -----------------------------------------------------------------------------
# SHOW LIST OF BUILDABLE TARGETS
# -----------------------------------------------------------------------------
show:	.SYMBOLIC
	@echo.
	@echo		The following [case sensitive] targets can be built:
	@for %%i in ($(TARGET)) do @echo 	%%i
	@echo.
# Alias for show
list:	.SYMBOLIC
	@%MAKE show


# -----------------------------------------------------------------------------
# HINT USER WHEN A BUILD FAILS
# -----------------------------------------------------------------------------
.ERROR
	@echo.
	@echo		Oops!
	@echo		Some error occured in this build session.
	@echo		If you see stuff about "positive count"
	@echo		you have a section overlap.
	@echo		Check the z_* values at the end of the list-file
	@echo		and look for a negative gap.
	@echo		Type 'wmake help' in the target dir for a list of actions.
#	@%MAKE help
	@echo.


# -----------------------------------------------------------------------------
# How the hell can we use more than one command in the for-loop ??
# -----------------------------------------------------------------------------
ttt:	.SYMBOLIC
# This does not work...
#	@for %%i in ($(BLD_LANGUAGES)) do %%i=X; $%WMAKE;
