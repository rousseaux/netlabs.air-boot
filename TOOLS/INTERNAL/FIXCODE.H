#ifndef     __FIXCODE_H__
#define     __FIXCODE_H__


#if defined(__DOS__)
    #define PLATFORM_DOS
#elif defined(__OS2__) && !defined(OS2)
    #define INCL_NOPMAPI
    #define INCL_BASE
    #define INCL_DOS
    #define INCL_DOSDEVIOCTL
    #include <os2.h>
    #define PLATFORM_OS2
#elif defined(__NT__)
    #include <windows.h>
    #define PLATFORM_WINNT
#elif defined(__LINUX__)
    #define PLATFORM_LINUX
#else
    #error Unsupported platform
#endif

#include    <stdlib.h>
#include    <stdio.h>
#include    <string.h>











#endif






