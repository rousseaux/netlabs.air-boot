/* REXX */

/* Cleanup OS2 files */
'@if exist OS2.MK del OS2.MK';
'@if exist INST-OS2.EXE del INST-OS2.EXE';
'@if exist INST-OS2.OBJ del INST-OS2.OBJ';
'@if exist INST-OS2.MK1 del INST-OS2.MK1';
'@if exist INST-OS2.LK1 del INST-OS2.LK1';
'@if exist INST-OS2.MAP del INST-OS2.MAP';
'@if exist *.err del *.err';
'@if exist ..\..\RELEASE\OS2\AIRBOOT2.EXE del ..\..\RELEASE\OS2\AIRBOOT2.EXE';

/* Cleanup WIN32 files */
'@if exist WIN32.MK del WIN32.MK';
'@if exist INST-WIN.EXE del INST-WIN.EXE';
'@if exist INST-WIN.OBJ del INST-WIN.OBJ';
'@if exist INST-WIN.MK1 del INST-WIN.MK1';
'@if exist INST-WIN.LK1 del INST-WIN.LK1';
'@if exist INST-WIN.MAP del INST-WIN.MAP';
'@if exist *.err del *.err';
'@if exist ..\..\RELEASE\WINNT\AIRBOOTW.EXE del ..\..\RELEASE\WINNT\AIRBOOTW.EXE';
