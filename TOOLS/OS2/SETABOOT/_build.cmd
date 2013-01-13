/* REXX */

/* -r use release flags, -d use debug flags */
debug='-d';

'ide2make '||debug||' -p SETABOOT.WPJ';
'wmake -h -f SETABOOT.MK';
