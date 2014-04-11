###############################################################################
# Makefile :: Builds AiR-BOOT for all supported Languages.                    #
###############################################################################

#
# The default language for the loader code is EN.
# Supported languages are: EN,DE,FR,SW,IT,NL,RU.
# The 1.06 version used 'DT' for the Dutch language,
# this has been changed to 'NL'.
# To build all languages, set the LANGUAGE macro below to ALL.
#
LANGUAGE=EN

#
# Used tools:
# Open Watcom v1.9
# Tasm v4.1 DOS (136018 bytes)
# Tlink v4.0 DOS (72585 bytes)
# Caldera EXE2BIN.EXE R1.01 (9845 bytes)
#


#
# Build the loader code, the installers and SETABOOT.
#
all: .SYMBOLIC
# AiR-BOOT loader code
	cd BOOTCODE
	call _clean.cmd
	call _build.cmd $(LANGUAGE)
	@cd ..

# OS2 and WIN32 installer
	cd INSTALL\C
	call _clean.cmd
	call _build.cmd
	cd ..\..

# OS2 SETABOOT
	cd TOOLS\OS2\SETABOOT
	call _clean.cmd
	call _build.cmd
	cd ..\..\..

#
# Cleanup.
#
clean: .SYMBOLIC
	cd BOOTCODE
	call _clean.cmd
	cd MBR-PROT
	call _clean.cmd
	cd ..
	cd ..

	cd INSTALL\C
	call _clean.cmd
	cd ..\..

	cd TOOLS\OS2\SETABOOT
	call _clean.cmd
	cd ..\..\..

	cd TOOLS\INTERNAL
	call _clean.cmd
	cd ..\..