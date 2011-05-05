 AiR-BOOT (c) Copyright 1998-2009 M. Kiewitz

 This file is part of AiR-BOOT

 AiR-BOOT is free software: you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation, either version 3 of the License, or (at your option)
  any later version.

 AiR-BOOT is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY: without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
  details.

 You should have received a copy of the GNU General Public License along with
  AiR-BOOT. If not, see <http://www.gnu.org/licenses/>.

Personal Message...
====================
It's now around 10 years after the first line of AiR-BOOT was written.
 I consider it to be a very mature project of mine, I often get e-mails from
 people that had problems booting their new system and after installing
 AiR-BOOT everything just worked (at least the booting aspect). I'm now
 releasing it under GPL and on http://AiR-BOOT.sourceforge.net

 I cleaned up some of my documentation, did 2 new native installers (DOS&WinNT)
  and also changed a lot of the sourcecode directory structure. Some people say
  that assembly projects would be complicated to manage or update. I did my
  best to keep the sources tidy and every 2-3 years that I'm working on it, I
  never had problem to enhance the code. I hope other people will be able to do
  so as well.

 AiR-BOOT is 100% assembly, yes. That's why so many features fit into that
  little space. It's also really really compatible that way. I'm using only a
  few BIOS functions. That's the main problem with some other boot managers.
  They use VESA and other features, but those are often buggy especially in
  the latest BIOS versions of the latest computers (sadly). Also some of them
  also load further parts from partitions, because they use that much space.

 Anyway, the native installers for WinNT and OS/2 are written in 100% C. I did
  use assembly for the native DOS installer, because this code is also used by
  the bootable floppy and Floppy/CD-ROM (code recycling). That would be almost
  impossible to do with C, especially because floppy needs DOS services and
  Floppy/CD-ROM needs BIOS services. It would be quite a big hack, so directly
  using assembly is much cleaner.

 Regards
  M. Kiewitz

Important things!
==================
If you want to extend AiR-BOOT (adding new languages, etc.) please use 8+3
 directory and filenames. AiR-BOOT source-code is supposed to be 100%
 maintainable under pure DOS environment. Also note that this code is supposed
 to work on 286 machines as well. Don't include 386 instructions.

If you want to translate AiR-BOOT to another language, you will need to process
 the following: documentation in DOCS-subdirectory. Bootcode translation in
 BOOTCODE\TEXT-subdirectory. Changing make.bat in BOOTCODE and changing
 PACK.cmd in RELEASE-subdirectory.

I'm currently not interested in translating the installers. I don't think it's
 needed. If someone wants to do it, please contact me. Anyway, airboot2.msg is
 gone and all text is now sadly hardcoded in the C sourcecode.

What's where?
==============
.\BOOTCODE             - actual AiR-BOOT source-code
.\DOCS                 - Documentation for end-user
.\INSTALL\C            - Installer for OS/2 / eCS / WinNT environment
.\INSTALL\DOS          - Installer for DOS/Win9x environment
.\INSTALL\FLOPPY       - Installer for Floppy/CD-ROM
.\INSTALL\INST_X86     - Generic code for DOS/Win9x and CD-ROM/Floppy installer
.\TOOLS\DOS\INITHDD    - InitHDD for DOS
.\TOOLS\DOS\SETABOOT   - SetABoot for DOS
.\TOOLS\OS2\SETABOOT   - SetABoot for OS/2 (also replacement for IBM's SETBOOT)
.\TOOLS\INTERNAL       - Internal tools needed for bootcode build
.\TOOLS\TEST           - Test-Virus for virus checking
.\RELEASE\BOOTCODE     - Compiled bootcode images
.\RELEASE\CD-ROM       - CD-ROM ISO image
.\RELEASE\DOS          - Compiled Tools/Installer for DOS/Win9x environment
.\RELEASE\OS2          - Compiled Tools/Installer for OS/2 / eCS environment
.\RELEASE\TEMP         - Temporary directory for packing
.\RELEASE\WINNT        - Compiled Installer for WinNT environment
.\RELEASE\ZIP          - Official ZIP archives done for release

Building all the various files:
================================
First of all, you will need TASM 4.0, TLINK 4.01 and Caldera's EXE2BIN R1.01
 for building bootcode image. You will need Watcom C for all the files that
 have C sourcecode (OS/2 SETABOOT, OS/2 / WinNT installer).

If there is a make.bat in the subdirectory, just execute it.
All the various C sourcecodes are meant to be build using Watcom IDE.

.\RELEASE is supposed to get all the various binaries. If everything was
 successfully build, you may use .\RELEASE\pack.cmd for making official ZIP
 packages. Anyway, doing so should not be needed. If you want to get an
 official ZIP, just download it from sourceforge.

Contact:
=========
You may contact me via m_kiewitz [AT] users.sourceforge.net
