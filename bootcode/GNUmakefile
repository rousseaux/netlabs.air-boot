###############################################################################
# GNUmakefile :: Builds the 'airboot.bin' 16-bits RAW Loader Image            #
# --------------------------------------------------------------------------- #
# We are in the process of replacing Watcom Make with GNU Make.               #
# This transition will first start at the local developer site. When it is    #
# completed the switch to GNU Make will be propagated.                        #
###############################################################################

export CRC_IGNORE

# Use the new GNU Make build-system if USE_GNU_MAKE is set to 'y'
ifeq ($(USE_GNU_MAKE),y)
include airboot.gmk
else
include ../include/makefrwd.mif
endif
