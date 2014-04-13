===============================================================================
 1README.TXT -- General Information about AiR-BOOT v1.1.0
===============================================================================

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



Preface:
--------
When you are reading this file you are either browsing the AiR-BOOT sources
or you have 'checked-them-out' from the Netlabs repository.
Either way, this is what you should be aware of:
- AiR-BOOT was originally invented and designed by Martin Kiewitz.
- Martin seems to not develop it anymore and his last version (v1.06)
  can be found on sourceforge.
- *This* version is a 'fork' and although the name is the same,
  it's sources reside on Netlabs and an other developer maintains it.
  So, please do not bother Martin with bugs in this 'fork'.
- This AiR-BOOT fork has been enhanced to cope with issues like 'huge disks'
  and it's goal is to be a replacement for the ancient IBM Boot Manager
  (formerly) used by eComStation.
- With the release of eComStation v2.1, in may 2011, this AiR-BOOT 'fork'
  is distributed with it and positioned as the 'preferred bootmanager'
  for eComStation.
- While AiR-BOOT is 'operating-system agnostinc', meaning that it is not tied
  to any particular OS, the main effort of this 'fork' is to replace IBM-BM
  and be highly compatible with eComStation.
- The secondary goal of this 'fork' is to support even more operating-systems,
  new 'boot-technologies' like UEFI, new partitioning schemes like GPT
  and more.


Note 1:
-------
This is the "eComStation fork" of AiR-BOOT and it is maintained by a
different developer. The file you are currently reading, 1README.TXT,
replaces the original README.TXT as created by Martin Kiewitz.
The latter can be found in README.MKW, but note that the information
in there about building AiR-BOOT is completely outdated.
Please refer to BUILD.NFO for more information about building AiR-BOOT.


Note 2:
-------
Martin, at the time (1998+), found that it was important that AiR-BOOT could
be completely built on a DOS-system. In that 'era' this was a reasonable
requirement. With AiR-BOOT replacing IBM Boot Manager for eComStation
as of 2011, and upcoming stuff like EFI and GPT, AiR-BOOT itself and
it's 'build-environment' need to break out of the 'DOS-box'.

This means that the 8.3 filename format cannot be retained in some situations
and that building AiR-BOOT cannot use DOS .BAT files anymore.

Therefore, the 'build environment' has been 'revamped' to use Makefiles
and the Open Watcom tool-chain in combination with the JWasm Assembler.
This tool-chain can operate under DOS,Win32,OS/2 and Linux.

While care has been taken that the major components of AiR-BOOT can still be
built on DOS (or DOS-emulation environments),
the preferred build-environment is now eComStation -or- Linux.

If you really need to build on DOS, beware that:
- The DOS build-environment has limitations regarding memory and filenames.
- An eCS DOS-Session needs to have DPMI set from 'auto' to 'enabled'
  and the XMS mem-limit needs to be set to 0, to be able the use of JWasmD.
- It has not been tested as thoroughly as the eCS and Linux environments.
- It will be dropped in the future.


Note 3:
-------
An other 'operating-system' from a company that thinks it owns all computers,
all the disks in them, all it's users, their pets, and whatnot,
is also supported. AiR-BOOT can boot Windows and there is also a Win32 version
of the installer. (AIRBOOTW.EXE)

However, the AiR-BOOT Installer code for Win32 is much less tested than 
the eComStation version. This however, does not apply to the AiR-BOOT loader, 
which will do it's very best to boot any Windows it finds.


Note 4:
-------
AiR-BOOT can also boot Linux, or more accurately, chainload GRUB.
For this to work, GRUB needs to be installed on the partition Linux resides
on, since the MBR is taken by AiR-BOOT. If GRUB is installed in the MBR it
needs to be moved to the PBR. The procedure for such an action depends
on the GRUB and Linux versions used.

 

Building AiR-BOOT
-----------------
- Checkout the sources from http://svn.netlabs.org/air-boot.
- Setup the Open Watcom build-environment for your OS.
- Download JWasm for your OS.
- Run wmake without paramaters to build AiR-BOOT for all languages.

See BUILD.NFO for more information.


Rousseau.
