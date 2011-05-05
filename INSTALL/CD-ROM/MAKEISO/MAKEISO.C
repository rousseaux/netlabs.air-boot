// AiR-BOOT (c) Copyright 1998-2008 M. Kiewitz
//
// This file is part of AiR-BOOT
//
// AiR-BOOT is free software: you can redistribute it and/or modify it under
//  the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
// AiR-BOOT is distributed in the hope that it will be useful, but WITHOUT ANY
//  WARRANTY: without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
// You should have received a copy of the GNU General Public License along with
//  AiR-BOOT. If not, see <http://www.gnu.org/licenses/>.
//

#define INCL_BASE
#define INCL_WINSHELLDATA
#define INCL_DOS
#define INCL_DOSDEVIOCTL
#include <os2.h>
#include <malloc.h>

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <conio.h>
#include <string.h>

int main (int argc, char **argv) {
   PSZ   FilenameBasicISO    = NULL;
   FILE  *FileBasicISO       = NULL;
   ULONG FileBasicISOSize    = 0;
   PCHAR BasicISO            = NULL;
   PSZ   FilenameBootcode    = NULL;
   FILE  *FileBootcode       = NULL;
   ULONG FileBootcodeSize    = 0;
   PCHAR Bootcode            = NULL;
   PSZ   FilenameOutput      = NULL;
   FILE  *FileOutput         = NULL;
   PCHAR BasicISOBootcodePtr = NULL;
   ULONG BytesLeft           = 0;

   puts ("MAKEISO - AiR-BOOT Helper utility for making ISOs - (c) 2009 by M. Kiewitz");

   // This is a quick hackjob, it's only used during build, so i dont care.

   if (argc<4) {
      printf("MAKEISO [basic-iso] [bootcode] [output-iso]\n");
      return 1;
    }

   FilenameBasicISO = argv[1];
   FilenameBootcode = argv[2];
   FilenameOutput   = argv[3];

   FileBasicISO = fopen(FilenameBasicISO, "rb");
   if (!FileBasicISO) {
      printf("basic-iso not found\n");
      return 1;
    }
   // Read whole basic-iso into memory...
   fseek (FileBasicISO, 0, SEEK_END);
   FileBasicISOSize = ftell(FileBasicISO);
   BasicISO = malloc(FileBasicISOSize);
   if (!BasicISO) {
      printf("Out of memory\n");
      fclose(FileBasicISO);
      return 1;
    }
   fseek (FileBasicISO, 0, SEEK_SET);
   fread (BasicISO, 1, FileBasicISOSize, FileBasicISO);
   fclose (FileBasicISO);

   // Now search for AiRBOOT boot-record signature
   BasicISOBootcodePtr = BasicISO;
   BytesLeft = FileBasicISOSize - 9;
   while (BytesLeft > 0) {
      if (memcmp(BasicISOBootcodePtr, "\xFA\xEB\AiRBOOT", 9)==0) {
         break;
       }
      BasicISOBootcodePtr++; BytesLeft--;
    }
   if (BytesLeft==0) {
      free(BasicISO);
      printf("AiR-BOOT signature not found in basic-iso\n");
      return 1;
    }
   BytesLeft = BasicISOBootcodePtr - BasicISO;

   printf("AiR-BOOT signature found within basic-iso\n");

   FileBootcode = fopen(FilenameBootcode, "rb");
   if (!FileBootcode) {
      free(BasicISO);
      printf("bootcode not found\n");
      return 1;
    }
   // Read whole bootcode into memory...
   fseek (FileBootcode, 0, SEEK_END);
   FileBootcodeSize = ftell(FileBootcode);
   Bootcode = malloc(FileBootcodeSize);
   if (!Bootcode) {
      printf("Out of memory\n");
      fclose(FileBootcode);
      free(BasicISO);
      return 1;
    }
   fseek (FileBootcode, 0, SEEK_SET);
   fread (Bootcode, 1, FileBootcodeSize, FileBootcode);
   fclose (FileBootcode);

   // Now create output file
   FileOutput = fopen(FilenameOutput, "wb");
   if (!FileOutput) {
      free(BasicISO); free(Bootcode);
      printf("output could not be opened\n");
      return 1;
    }
   // Put ISO till bootcode
   fwrite (BasicISO, 1, BytesLeft, FileOutput);
   // Then put requested bootcode
   fwrite (Bootcode, 1, FileBootcodeSize, FileOutput);
   // Finally write rest of ISO
   BytesLeft = FileBasicISOSize - BytesLeft - FileBootcodeSize;
   fwrite (BasicISOBootcodePtr + FileBootcodeSize, 1, BytesLeft, FileOutput);
   fclose (FileOutput);
   free(BasicISO); free(Bootcode);
   printf("Output successfully written.\n");
   return 0;
 }
