/* REXX */

/* -r use release flags, -d use debug flags */
debug='-r';

/* OS2 version */
'ide2make '||debug||' -p OS2.WPJ';
'wmake -f OS2.MK';

/* WIN32 version */
'ide2make '||debug||' -p WIN32.WPJ';
'wmake -f WIN32.MK';

