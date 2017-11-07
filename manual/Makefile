###############################################################################
# Makefile :: Redirect other Make utilities to GNU Make                       #
# --------------------------------------------------------------------------- #
# On OS/2, 'nmake' or 'wmake' are what 'make' is on *NIX systems.             #
# The top-level targets are supported when using NMake or WMake from the cli. #
# This is just for convenience and the other (intermediate) targets can only  #
# be used with GNU Make. Of course, the best way is to use File Commander,    #
# which will present a nice build-menu when F2 is pressed.                    #
###############################################################################

# For WMake, force a first blank line; for NMake, make it eat '.symbolic'
!ifdef __LOADDLL__
.before:;!@echo.
!else
.symbolic:
!endif

# Message to inform the user of the forwarding to GNU Make
fwdmsg=!!! NOTE: FORWARDING TO GNU MAKE !!!

# Recipe to forward to GNU Make, '-r' disables default rules speading things up
fwdrecipe=make -r

# First and thus the default NMake or WMake target
default: .symbolic fwdmsg
	!$(fwdrecipe)

# Forward top-level target 'info'
info: .symbolic $(phony) fwdmsg
	!$(fwdrecipe) $@

# Forward top-level target 'all'
all: .symbolic fwdmsg
	!$(fwdrecipe) $@

# Forward top-level target 'build'
build: .symbolic fwdmsg
	!$(fwdrecipe) $@

# Forward top-level target 'rebuild'
rebuild: .symbolic fwdmsg
	!$(fwdrecipe) $@

# Forward top-level target 'clean'
clean: .symbolic fwdmsg
	!$(fwdrecipe) $@

# Dependency target to display the forwarding message
fwdmsg: .symbolic
	!@echo $(fwdmsg)
