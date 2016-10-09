###############################################################################
# Makefile :: Builds the 'mbr-prot.bin' 16-bits RAW Protection Image          #
# --------------------------------------------------------------------------- #
#                                                                             #
# This Makefile builds the 'mbr_prot.bin' image.                              #
# This image is embedded in 'airboot.bin' to provide virus protection.        #
# The 'fixcode' program embeds this image in 'airboot.bin'.                   #
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
# Source Level base-name of Target to build.
#
BASENAME=mbr-prot

#
# Bin Level base-name.
#
MODULE=$(BASENAME)

#
# This is a list of the Targets to be built.
# For MBR_PROT there is only one real target: mbr-prot.bin.
#
TARGET=$(MODULE).bin

#
# Assembler Tools.
#
#ASM=masm
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
ASM_FLAGS_D0=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -Cp -zcw -Fo$^&.obj -Sa -Fl=$^&.lst -Fw$^&.err
ASM_FLAGS_D1=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -Cp -zcw -Zd -Zi -Fo$^&.obj -Sa -Fl=$^&.lst -Fw$^&.err
ASM_FLAGS_D2=-DDEBUG_LEVEL=$(DEBUG_LEVEL) -DJWASM -q -Cp -zcw -Zd -Zi -Fo$^&.obj -Sa -Fl=$^&.lst -Fw$^&.err
!elseif "$(ASM)"=="masm"
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dMASM -zq -fo=$^&.obj -fr=$^&.err
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dMASM -zq -d1 -fo=$^&.obj -fr=$^&.err
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dMASM -zq -d1 -fo=$^&.obj -fr=$^&.err
!elseif "$(ASM)"=="wasm"
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dWASM -zq -fo=$^&.obj -fr=$^&.err
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dWASM -zq -d1 -fo=$^&.obj -fr=$^&.err
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dWASM -zq -d1 -fo=$^&.obj -fr=$^&.err
!elseif "$(ASM)"=="tasm"
# -ml   = case sensitive symbols
ASM_FLAGS_D0=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -ml -m9 -l
ASM_FLAGS_D1=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -ml -m9 -z -zi -c -la
ASM_FLAGS_D2=-dDEBUG_LEVEL=$(DEBUG_LEVEL) -dTASM -t -ml -m9 -z -zi -c -la
!elseif "$(ASM)"=="alp"
ASM_FLAGS_D0=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP -Mb +Feo:obj +Fl +Fel:lst +Fm +Fem:err
ASM_FLAGS_D1=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP -Mb +Od:MS16 +Feo:obj +Fl +Fel:lst +Fm +Fem:err
ASM_FLAGS_D2=-D:DEBUG_LEVEL=$(DEBUG_LEVEL) -D:ALP
!else
!error Unknown Assembler specified !
!endif
ASM_FLAGS=$(ASM_FLAGS_D$(DEBUG_LEVEL))

#
# Linker
#
LNK=wlink
LNK_FLAGS_D0=op q op v disa {1014 1023} op map=$^&.map
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
# This builds the target using normal dependency rules.
# If this Makefile was modified, all targets are forcefully rebuilt.
#
all: .SYMBOLIC Makefile.bu header $(TARGET) footer


#
# Show the header.
#
header: .SYMBOLIC
	@echo.
	@echo =====================================================================
	@echo = MODULE: $(TARGET)               [16-bits Raw Protection Image] =
	@echo =====================================================================
#	@echo.


#
# Show the footer.
#
footer: .SYMBOLIC
#	$(RM) $(TARGET)
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
# MAIN TARGETS
#

###############################################################################
# 16-bits RAW :: MBR virus protection to be embedded in the 'airboot.bin' image
###############################################################################
#$(TARGET):	$(BASENAME).com
#	$(LNK) $(LNK_FLAGS) file $^&.obj name $^. sys dos com
#	$(CP) $(BASENAME).com $(TARGET)
#	@echo $(%BLD_LANG)>$^.
#	@if exist $^. @echo		$^. $(MSG_SUCCESS) - [$(%BLD_LANG) version]
#	$(RM) $(TARGET)
#	@echo.



###############################################################################
# 16-bits RAW :: MBR virus protection to be embedded in the 'airboot.bin' image
###############################################################################
$(TARGET): $(BASENAME).asm
	@echo TARGET: $^. [DOS 16-bits Raw Image]
	$(ASM) $(ASM_FLAGS) $(BASENAME).asm
	@wdis -fi $^&.obj > $^&.wda
	$(LNK) $(LNK_FLAGS) file $^&.obj name $^. sys dos com
#	$(LNK) $(LNK_FLAGS) file $^&.obj name $^. form raw
	@if exist $^. @echo $^. $(MSG_SUCCESS)
	@ndisasm -k9,0 $^. > $^&.nda
#	@echo.

#$(BASENAME).obj: $(BASENAME).asm
#	@echo.
#	@echo TARGET: $^. [DOS 16-bits Raw Image]
#	$(ASM) $(ASM_FLAGS) $(BASENAME).asm
#	@wdis -fi $^. > $^&.wda



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
#	@echo CLEANING UP
#	@for %%i in ($(TARGET)) do @if exist %%i $(RM) %%i
	@if exist *.com $(RM) *.com
	@if exist *.bin $(RM) *.bin
	@if exist *.obj $(RM) *.obj
	@if exist *.wda $(RM) *.wda
	@if exist *.nda $(RM) *.nda
	@if exist *.map $(RM) *.map
	@if exist *.lst $(RM) *.lst
	@if exist *.err $(RM) *.err
	@if exist *.o   $(RM) *.o

#
# Remove all residual .BIN files.
#
rmbin: .SYMBOLIC
	@if exist *.bin $(RM) *.bin


#
# Help on using this Makefile.
#
help: .SYMBOLIC
	@echo.
	@echo The following actions are available:
	@echo wmake         to build all targets and all languages
	@echo wmake list    to show the list of buildable targets
	@echo wmake clean   to remove almost all generated files
	@echo wmake rmbin   to remove all residual BIN files
	@echo wmake rebuild to rebuild all targets
	@echo wmake help    to show this information
	@echo.

#
# Show the list of buildable targets.
#
show:	.SYMBOLIC
	@echo.
	@echo The following [case sensitive] targets can be built:
	@for %%i in ($(TARGET)) do @echo %%i
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
	@echo Doing a wmake rebuild might solve the problem.
	@%MAKE help
	@echo.
