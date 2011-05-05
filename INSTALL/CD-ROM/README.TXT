If there are changes in the AiR-BOOT installer kernel.sys file especially, if
those are size changes, you MUST recreate CONTENT\boot.bin. Afterwards call
makebase.cmd to create a bootable basic.iso file via mkisofs.

Be careful: I am patching the bootcode directly within the image, this means
             that the file on the floppy image needs not to be fragmented,
             otherwise it won't work.

As soon as you got that (or you use the supplied basic.iso from SVN), just call
make.bat to create a language-specific AiR-BOOT ISO. This will get placed into
RELEASE-directory structure.

Oh btw all utils in here are for meant for use under OS/2. If you want to build
anywhere else, you will need to get yourself a corresponding mkisofs, compile
makeiso for your platform and adjust make.cmd/makebase.cmd accordingly.
