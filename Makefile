###############################################################################
# Makefile :: Builds complete AiR-BOOT -- all platforms and languages (WMake) #
# --------------------------------------------------------------------------- #
#                                                                             #
# This is the Master Makefile and it builds the whole AiR-BOOT she-bang:      #
# - The AiR-BOOT Loader Code for all supported languages.                     #
# - The MBR Protection Image that get's embedded in the loader.               #
# - The 'fixcode' program that embeds the MBR Protection Image.               #
# - The Installers for all supported platforms.                               #
# - The 'set(a)boot' program for all supported platforms. (OS/2 only)         #
#                                                                             #
# Note:                                                                       #
# AiR-BOOT and it's helpers are relatively small to build.                    #
# So, although Makefiles are being used to build the lot, there's no explicit #
# separation between assembling/compiling from source or just only linking.   #
# In fact, because of multiple languages for the Loader and cross-platform    #
# support for the Helpers, any target will almost always be built from source #
# everytime.                                                                  #
#                                                                             #
# Also:                                                                       #
# While WMake does it's job, running it on Linux takes a bit of extra effort  #
# with regard to case sensitivity, directory separators, escape characters    #
# and other platform differences.                                             #
# This is handled in makefile.mif.                                            #
#                                                                             #
###############################################################################



#                           DEFINITIONS AND STUFF
# _____________________________________________________________________________

# This one is defined in the Environment so that all 'called' WMake invocations
# can adjust their behavior when they are invoked from this Master.
# When invoked from this Master, it is assumed the user/developer
# 'just-wants-to-have-all-the-stuff-built', so some messages are suppressed and
# some stuff is overridden.
# Building from this Master is how AiR-BOOT is built when released.
# It will force JWasm as the assembler and force DEBUG_LEVEL to 0.
# Also, targets are distributed to the RELEASE directory.
# Usage of lower level Makefiles directly is considered 'development'.
%MASTER=TRUE

# Include a Master Makefile with several cross-platform definitions and macros.
# This is used to compensate for the differences between the target platforms.
!include include/makefile.mif


# These are the Build Directories (Components) that produce
# one or more targets. WMake is invoked from this Master Makefile in each of
# this directories to produce the corresponding component.
# Note that the %MASTER Environment variable above is passed
# to influence build behavior of the individual Makefiles.
# The order of these Build Directories matters !
#
# - mbr-prot        ; MBR Protection Image later to be embedded.     (mbr-prot)
# - internal        ; Helper program to embed the MBR PI. (fixboot[d][2][w][l])
# - bootcode        ; AiR-BOOT Boot Manager itself.               (airboot.bin)
# - install/c       ; Installer for multiple platforms.   (install[d][2][w][l])
# - setaboot        ; The AiR-BOOT setboot replacement for OS/2.     (setaboot)
#
COMPONENTS=&
 bootcode$(DS)mbr-prot&
 tools$(DS)internal&
 install$(DS)c&
 tools$(DS)os2$(DS)setaboot&
 bootcode&


# Components to distribute to the RELEASE directories.
# These are the bootloader is several languages,
# the installer for several platforms,
# and the OS/2 setboot replacement (setaboot).
COMPONENTS2DIST=&
 install$(DS)c&
 tools$(DS)os2$(DS)setaboot&
 bootcode&





#                               MAIN ACTIONS
# _____________________________________________________________________________


# -----------------------------------------------------------------------------
# MAIN :-)
# -----------------------------------------------------------------------------
# Unless another target is specified, a 'build' is the default action.
# Using wmake build would be equivalent.
# -----------------------------------------------------------------------------
all: .SYMBOLIC Makefile.bu
	@%MAKE build



# -----------------------------------------------------------------------------
# BUILD AND DISTRIBUTE EVERYTHING
# -----------------------------------------------------------------------------
# Here we iterate over all AiR-BOOT components that have a Makefile.
# To be able to influence the 'action' we pass that using the Environment.
# In this case we are 'building'.
# Note that we don't use %ACTION=, because that would be evaluated by WMake
# when parsing the Makefile. It needs to be a command related to the target.
# -----------------------------------------------------------------------------
build: .SYMBOLIC
	@SET ACTION=BUILD
	@for %%i in ($(COMPONENTS)) do @$(MAKE) -h %%i
	@%MAKE dist
	@echo.

	@echo Cleaning up bootcode directory
	@cd bootcode
	@wmake -h clean
	@cd ..
	@echo Done.

	@echo.
	@echo.
	@echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	@echo :: !! Success !!                                                  ::
	@echo :: All AiR-BOOT stuff has been built.                             ::
	@echo :: Look in the RELEASE directory for the distribution files       ::
	@echo :: for each platform and the bootloader for each language.        ::
#	@echo :: The packages directory contains packages for each supported    ::
#	@echo :: platform.                                                      ::
	@echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	@echo.
	@echo ***** NOTE: Only the EN-build has the FX-module included !!    *****
	@echo *****       To regain space, the FX-module will be completely  *****
	@echo *****       excluded from future AiR-BOOT releases !           *****
	@echo.



# -----------------------------------------------------------------------------
# SHOW MASTER BUILD INFORMATION
# -----------------------------------------------------------------------------
info: .SYMBOLIC
!ifdef	__LINUX__
	@clear
	@less BUILD.NFO
	@echo
!else
	@cls
	@type BUILD.NFO | more
	@echo.
	@pause
!endif



# -----------------------------------------------------------------------------
# SHOW LICENSE
# -----------------------------------------------------------------------------
license: .SYMBOLIC
!ifdef	__LINUX__
	@clear
	@less COPYING
	@echo
!else
	@cls
	@type COPYING | more
	@echo.
	@pause
!endif



# -----------------------------------------------------------------------------
# CREATE PACKAGE
# -----------------------------------------------------------------------------
package: .SYMBOLIC
!ifdef	__LINUX__
	@echo
	@echo "*** Packaging is not implemented yet ***"
	@echo
!else
	@echo.
	@echo *** Packaging is not implemented yet ***
	@echo.
!endif



# -----------------------------------------------------------------------------
# DISTRIBUTE RELEVANT TARGETS TO RELEASE DIRECTORY
# -----------------------------------------------------------------------------
# This target is invoked by build to distribute the relevant targets to the
# distribution directory.
# -----------------------------------------------------------------------------
dist: .SYMBOLIC
	@SET ACTION=DIST
	@for %%i in ($(COMPONENTS2DIST)) do @$(MAKE) -h %%i
	@echo.



# -----------------------------------------------------------------------------
# CLEANUP EVERYTHING
# -----------------------------------------------------------------------------
# Here we iterate over all AiR-BOOT components that have a Makefile.
# To be able to influence the 'action' we pass that using the Environment.
# In this case we are 'cleaning'.
# Note that we don't use %ACTION=, because that would be evaluated by WMake
# when parsing the Makefile. It needs to be a command related to the target.
# -----------------------------------------------------------------------------
clean: .SYMBOLIC
	@cd release
	@$(MAKE) -h clean
	@cd ..
	@SET ACTION=CLEAN
	@for %%i in ($(COMPONENTS)) do @$(MAKE) -h %%i
	@if exist Makefile.bu $(RM) Makefile.bu
	@echo.
	@echo Done.
	@echo.



# -----------------------------------------------------------------------------
# SHOW HELP ON USING THIS MAKEFILE
# -----------------------------------------------------------------------------
help: .SYMBOLIC
	@echo.
	@echo The following actions are available:
	@echo wmake         to build all targets and all languages
	@echo wmake dev     to build a develoopment target
	@echo wmake [LANG]  to build EN,DE,NL,FR,IT or RU versions
	@echo wmake list    to show the list of buildable targets
	@echo wmake clean   to remove almost all generated files
	@echo wmake rmbin   to remove all residual BIN files
	@echo wmake rebuild to rebuild all targets
	@echo wmake dist    to populate the dist directories
	@echo wmake help    to show this information
	@echo.



# -----------------------------------------------------------------------------
# CHECK FOR MAKEFILE CHANGES
# -----------------------------------------------------------------------------
# Create a backup of the Makefile when it is modified.
# This also forces a rebuild of all targets.
# -----------------------------------------------------------------------------
Makefile.bu: Makefile
	@echo.
	@echo Makefile modified, forcing rebuild of all targets !
	@echo.
	@%MAKE clean
	@$(CP) Makefile Makefile.bu > $(NULDEV)



#                               GENERIC HANDLERS
# _____________________________________________________________________________


# -----------------------------------------------------------------------------
# ACTION HANDLER FOR BUILD DIRECTORIES
# -----------------------------------------------------------------------------
# This is the generic handler.
# The action to undertake is set in the Environment.
# It functions like a "switch".
# -----------------------------------------------------------------------------
$(COMPONENTS): .SYMBOLIC
	@echo.
	@echo.
	@echo.
!if "$(%ACTION)"=="BUILD"
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@echo @@ BUILDING $@
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@cd $@
	@cd
	@$(MAKE) -h
!elseif "$(%ACTION)"=="DIST"
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@echo @@ DISTRIBUTING $@
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@cd $@
	@cd
	@$(MAKE) -h dist
!elseif "$(%ACTION)"=="CLEAN"
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@echo @@ CLEANING $@
	@echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@cd $@
	@cd
	@$(MAKE) -h clean
	@if exist Makefile.bu $(RM) Makefile.bu
!else
	@echo.
	@echo !! Undefined Action !!
	@echo.
!endif
