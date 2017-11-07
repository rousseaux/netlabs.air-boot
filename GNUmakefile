###############################################################################
# GNUmakefile :: Builds complete AiR-BOOT -- all platforms and languages      #
# --------------------------------------------------------------------------- #
# We are in the process of replacing Watcom Make with GNU Make.               #
# This transition will first start at the local developer site. When it is    #
# completed the switch to GNU Make will be propagated.                        #
###############################################################################

# Use the new GNU Make build-system if USE_GNU_MAKE is set to 'y'
ifeq ($(USE_GNU_MAKE),y)
include air-boot.gmk
else
include include/makefrwd.mif
endif
