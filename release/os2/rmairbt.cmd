/* REXX */

/*
// This script will remove AiR-BOOT and install a standard MBR.
// It uses LVM and will not work on pre-LVM systems.
// The AiR-BOOT configuration will be retained and a new installation of AiR-BOOT
// will reuse this configuration. It is located at LBA-sector 55d (37h) -- CHS(0,0,56).
// Don't forget to re-enable OS/2 BootManager or some other bootable partition.
*/

'@cls';
Say "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
Say "!! AiR-BOOT WILL BE REMOVED AND A STANDARD MBR WILL BE INSTALLED !!";
Say "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
Say "";
Say "!! Type OK and ENTER to continue, any other key will abort...    !!";
Say "";

resp = LineIn();

if (SubStr(resp,1,2) = "OK") then
	DO
		Say "";
		Say "** AiR-BOOT IS BEING REMOVED...                                            **";
		'@LVM /NEWMBR:1';
		Say "";
		Say "*****************************************************************************";
		Say "** AiR-BOOT IS REMOVED AND A STANDARD MBR HAS BEEN INSTALLED.              **";
		Say "** The AiR-BOOT CONFIGURATION IS RETAINED AND WILL BE REUSED ON REINSTALL. **";
		Say "*****************************************************************************";
		Say "";
		Say "";
		Say "** --> DON'T FORGET TO RE-ENABLE OS/2 BOOT-MANAGER  !!  **";
	END
else
	DO
		Say "";
		Say "** NO CHANGES HAVE BEEN MADE **";
	END

Say "";
Say "";
Say "Press ENTER...";
resp = LineIn();
