// AiR-BOOT (c) Copyright 1998-2009 M. Kiewitz
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



/*
// OS/2 BLDLEVEL Information
*/

// Vendor
#ifndef     BLDLVL_VENDOR
#define     BLDLVL_VENDOR           "*UNKNOWN*"
#endif

// Build machine
#ifndef     BLDLVL_MACHINE
#define     BLDLVL_MACHINE          "*UNKNOWN*"
#endif

// Build language
#define     BLDLVL_LANGUAGE         "EN"


// Release and TestBuild variants
#ifdef  RELEASE

// Version
#define     BLDLVL_MAJOR_VERSION    "1"
#define     BLDLVL_MIDDLE_VERSION   "1"
#define     BLDLVL_MINOR_VERSION    "4"

// Build date
#define     BLDLVL_YEAR             "2017"
#define     BLDLVL_MONTH            "11"
#define     BLDLVL_DAY              "07"

// Build time
#define     BLDLVL_HOURS            "01"
#define     BLDLVL_MINUTES          "01"
#define     BLDLVL_SECONDS          "04"

#else

// Version
#define     BLDLVL_MAJOR_VERSION    "1"
#define     BLDLVL_MIDDLE_VERSION   "1"
#define     BLDLVL_MINOR_VERSION    "3"

// Build date
#define     BLDLVL_YEAR             "2017"
#define     BLDLVL_MONTH            "11"
#define     BLDLVL_DAY              "07"

// Build time
#define     BLDLVL_HOURS            "23"
#define     BLDLVL_MINUTES          "59"
#define     BLDLVL_SECONDS          "59"

#endif
