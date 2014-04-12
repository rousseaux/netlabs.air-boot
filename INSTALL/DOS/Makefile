###############################################################################
# Makefile :: Builds the MBR_PROT.BIN 16-bits RAW Protection Image.           #
###############################################################################
# rousseau@ecomstation.com
#
# Derived from the AIR-BOOT Makefile.
#

#
# This Makefile builds the MBR_PROT.BIN image.
# This image is embedded in the AIRBOOT.BIN image to provide virus protection.
# The FIXCODE program embeds this image in AIRBOOT.BIN.
#


#
# Include a Master Makefile with several cross-platform definitions and macros.
# This is used to compensate for the differences between the target platforms.
#
!include	../../INCLUDE/MAKEFILE.MIF

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
#
BASENAME=AIRBOOT

#
# Bin Level base-name.
#
MODULE=$(BASENAME)

#
# This is a list of the Targets to be built.
# For MBR_PROT there is only one real target: MBR_PROT.BIN.
#
TARGET=$(MODULE).COM

#
# Assembler Tools.
#
#ASM=masm
#ASM=alp
ASM=tasm
#ASM=wasm
#ASM=jwasm

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
ASM_FLAGS_D0=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -Cp -zcw -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR
ASM_FLAGS_D1=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -Cp -zcw -Zd -Zi -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR
ASM_FLAGS_D2=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -Cp -zcw -Zd -Zi -Fo$^. -Sa -Fl=$^&.LST -Fw$^&.ERR
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
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -ml -m9 -l
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -ml -m9 -z -zi -c -la
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -ml -m9 -z -zi -c -la
!elseif "$(ASM)"=="alp"
ASM_FLAGS_D0=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP -Mb +Feo:OBJ +Fl +Fel:LST +Fm +Fem:ERR
ASM_FLAGS_D1=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP -Mb +Od:MS16 +Feo:OBJ +Fl +Fel:LST +Fm +Fem:ERR
ASM_FLAGS_D2=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP
!else
!error Unknown Assembler specified !
!endif
ASM_FLAGS=$(ASM_FLAGS_D$(DEBUG_LEVEL))

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
# This builds the target using normal dependency rules.
# If this Makefile was modified, all targets are forcefully rebuilt.
#
all:	.SYMBOLIC Makefile.bu header $(TARGET) footer


#
# Show the header.
#
header:	.SYMBOLIC
	@echo.
	@echo =====================================================================
	@echo = MODULE: $(TARGET)               [16-bits Raw Protection Image] =
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
# MAIN TARGETS
#


###############################################################################
# 16-bits COM :: Intermediate image without embedded MBR-prot. and code count.
###############################################################################
$(BASENAME).COM:	$(BASENAME).OBJ
	$(LNK) $(LNK_FLAGS) file $^&.OBJ name $^. sys dos com
#	$(LNK) $(LNK_FLAGS) file $^&.OBJ name $^. form raw
#	@if exist $^. @echo		$^. $(MSG_SUCCESS)
#	@echo.

$(BASENAME).OBJ:	$(BASENAME).ASM
#	@echo.
	@echo TARGET: $^.	[DOS 16-bits Raw Image]
	$(ASM) $(ASM_FLAGS) $(BASENAME).ASM
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
#	@echo CLEANING UP
#	@for %%i in ($(TARGET)) do @if exist %%i $(RM) %%i
	@if exist *.COM $(RM) *.COM
	@if exist *.BIN $(RM) *.BIN
	@if exist *.OBJ $(RM) *.OBJ
	@if exist *.WDA $(RM) *.WDA
	@if exist *.NDA $(RM) *.NDA
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
# Help on using this Makefile.
#
help:	.SYMBOLIC
	@echo.
	@echo		The following actions are available:
	@echo		wmake 		to build all targets and all languages
	@echo		wmake list	to show the list of buildable targets
	@echo		wmake clean 	to remove almost all generated files
	@echo		wmake rmbin 	to remove all residual BIN files
	@echo		wmake rebuild	to rebuild all targets
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
	@%MAKE help
	@echo.
