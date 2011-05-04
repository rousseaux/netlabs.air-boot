;---------------------------------------------------------------------------
;                                          AiR-BOOT SETUP / ALL SETUP MENUS
; v046 - Swedish - by Bjîrn Sîderstrîm
;---------------------------------------------------------------------------

; Main Setup - Items - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUP_PartitionSetup       db 'SETUP AV PARTITIONER', 0
TXT_SETUP_BasicOptions         db 'GRUNDLéGGANDE OPTIONER', 0
TXT_SETUP_AdvOptions           db 'AVANCERADE OPTIONER', 0
TXT_SETUP_ExtOptions           db 'UTôKADE BOOTNINGSOPTIONER', 0
TXT_SETUP_DefMasterPwd         db 'DEFINIERA MASTER LôSENORD', 0
TXT_SETUP_DefBootPwd           db 'DEFINIERA BOOT LôSENORD', 0
TXT_SETUP_SaveAndExit          db 'SPARA & AVSLUTA SETUP', 0
TXT_SETUP_JustExit             db 'AVSLUTA UTAN ATT SPARA', 0

; The Letters for all flags in Partition Setup
TXT_SETUP_FlagLetterBootable   equ 'B'
TXT_SETUP_FlagLetterVIBR       equ 'V'
TXT_SETUP_FlagLetterHide       equ 'H'
TXT_SETUP_FlagLetterDrvLetter  equ 'L'
TXT_SETUP_FlagLetterExtMShack  equ 'P'

TXT_SETUP_LetterYes            equ 'J'
TXT_SETUP_LetterYes2           equ 'Z'
TXT_SETUP_LetterNo             equ 'N'

; Basic Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_DefaultPart          db 'Standard Partition', 0
TXT_SETUP_TimedBoot            db 'Tidstyrd Bootning', 0
TXT_SETUP_TimedBootDelay       db 'TidsBoot Fîrdrîj (sek)', 0
TXT_SETUP_TimedKeyHandling     db 'Tids Tangenthantering', 0
TXT_SETUP_BootLastIfTimed      db 'Boota fr.Senast Om Tids', 0
TXT_SETUP_RememberLastBoot     db 'Kom IhÜg Senaste Boot', 0
TXT_SETUP_RememberTimedBoot    db 'Kom IhÜg Tids Boot', 0
TXT_SETUP_IncludeFloppy        db 'Inkludera Diskettenhet', 0
TXT_SETUP_MbrProtection        db 'MBR Skydd', 0
TXT_SETUP_IgnoreMbrWrites      db '-> Ignorera MBR Skriv', 0
TXT_SETUP_MakeSounds           db 'AnvÑnd Ljud', 0
TXT_SETUP_CooperBars           db 'Cooper Bars', 0

; Advanced Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_BootMenu             db 'Bootning Meny', 0
TXT_SETUP_PartAutoDetect       db 'Partition AutoupptÑck', 0
TXT_SETUP_SecurityOptions      db '-> SÑkerhet Opt. <-', 0
TXT_SETUP_PasswordedSetup      db 'Lîsenskyddad Setup', 0
TXT_SETUP_PasswordedSystem     db 'Lîsenskyddat System', 0
TXT_SETUP_PasswordedChangeBoot db 'Lîsenskyddad BootÑndr.', 0
TXT_SETUP_GetFloppyName        db 'HÑmta Diskettnamn', 0
TXT_SETUP_GetFloppyName2Sec    db '-> HÑmta Var 2 Sekund', 0
TXT_SETUP_VirusDetect          db 'Virus UpptÑckt', 0
TXT_SETUP_StealthDetect        db 'Stealth UpptÑckt', 0
TXT_SETUP_VIBRdetect           db 'VIBR UpptÑckt', 0
TXT_SETUP_ContinueBIOSboot     db 'FortsÑtt BIOS Boot Sekv', 0

; Extended Options - Items - Max Length: 23
;----------------------------------|---------------------|------------------
TXT_SETUP_LinuxKernelPart      db 'Linux Kernel Partition', 0
TXT_SETUP_LinuxDefaultKernel   db 'Linux Standard KÑrna', 0
TXT_SETUP_LinuxRootPart        db 'Linux Root Partition', 0
TXT_SETUP_ForceLBAUsage        db 'Forc BIOS-LBA AnvÑndn.', 0
TXT_SETUP_ExtPartMShack        db 'Ext-Part MS Workaround', 0
; This here may be larger than 23 chars...
TXT_SETUP_DefLinuxCmd          db 'DEFINIERA KOMMANDORAD FôR LINUX', 0

; DYNAMIC LENGTH, maximum 11 chars excluding ending zero
;----------------------------------|---------|------------------------------
TXT_SETUP_MAGIC_Enabled        db 'Aktiverad', 0
TXT_SETUP_MAGIC_Disabled       db 'Avaktiverad', 0
TXT_SETUP_MAGIC_Detailed       db 'Detaljerad', 0
TXT_SETUP_MAGIC_NoBootable     db 'Ej Bootbar', 0
TXT_SETUP_MAGIC_NoLinux        db 'Ej Linux', 0
TXT_SETUP_MAGIC_DoNothing      db 'Gîr Inget', 0
TXT_SETUP_MAGIC_ResetTime      db 'èterst. Tid', 0
TXT_SETUP_MAGIC_StopTime       db 'Stopp Tid', 0
TXT_SETUP_MAGIC_CDROM          db 'CD-ROM', 0
TXT_SETUP_MAGIC_Network        db 'NÑtverk', 0
TXT_SETUP_MAGIC_ZIPLS          db 'ZIP/LS120', 0
; Max Length: 10 (used in Hide-Configuration as well)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Hidden         db 'Dold', 0
TXT_SETUP_MAGIC_Unhidden       db 'Ej Dold', 0
; Max Length: 10 ("C:" will be appended afterwards)
;----------------------------------|--------|-------------------------------
TXT_SETUP_MAGIC_Set            db 'sÑtt ', 0

; Setup Control Help - Max Length: 33
;----------------------------------|-------------------------------|--------
TXT_SETUPHELP_Main:            db 24,32,25,32,26,32,27,' : VÑlj Aktion', 0
                               db               'Enter   : VÑlj Aktion', 0
                               db               'F10 : Spara&Avsluta Setup', 0
                               db               'Esc : LÑmna Setup', 0

TXT_SETUPHELP_SubMenu:         db 24,32,25,32,26,32,27,' : VÑlj Post', 0
                               db               'PgUp/Dn : éndra Post', 0
                               db               'F1  : Visa hjÑlp fîr post', 0
                               db               'Esc : ètervÑnd till huvud-menyn', 0

TXT_SETUPHELP_PartSetup:       db 24,32,25,32,26,32,27,' : VÑlj partition', 0
                               db               'Enter   : Editera etikett', 0
                               db               'F1  : Flagga (tryck tg fîr vÑxl)', 0
                               db               'Esc : ètervÑnd till huvud-menyn', 0

; HELP FOR EVERY MENU-ITEM, Maximum Length = 22 chars PER line. Maximum 5 lines

                                  ;1234567890123456789012
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_PartitionSetup:  db 'Gîr dina partitioner', 0
                               db 'bootningsbara, Ñndra', 0
                               db 'deras namn, definiera', 0
                               db 'gîmma och mycket', 0
                               db 'annat.', 0
                               db 0
TXT_SETUPHELP_BasicOptions:    db 'Dessa optioner Ñr fîr', 0
                               db 'oerfarna anvÑndare.', 0
TXT_SETUPHELP_AdvOptions:      db 'Dessa Ñr fîr', 0
                               db 'avancerade anvÑndare.', 0
                               db 'Om du inte vet vad de', 0
                               db 'gîr, lÑmna som de Ñr.', 0
                               db 0
TXT_SETUPHELP_ExtOptions:      db 'Utîkade optioner fîr', 0
                               db 'specifika OS.', 0
                               db 0
TXT_SETUPHELP_DefMasterPwd:    db 'Definiera ett', 0
                               db 'lîsenord fîr access', 0
                               db 'till setup och', 0
                               db 'system.', 0
                               db 0
TXT_SETUPHELP_DefBootPwd:      db 'Definiera ett', 0
                               db 'lîsenord fîr access', 0
                               db 'till system.',0
                               db 0
TXT_SETUPHELP_SaveAndExit:     db 'Kommer att forsÑtta', 0
                               db 'bootprocessen och', 0
                               db 'spara de aktuella', 0
                               db 'optionerna.',0
                               db 0
TXT_SETUPHELP_JustExit:        db 'Kommer att forsÑtta', 0
                               db 'men ignorerar alla', 0
                               db 'Ñndringar som gjorts', 0
                               db 'till optionerna.',0
                               db 0

TXT_SETUPHELP_InPartitionSetup db 'B - Bootningbar', 0
                               db 'V - VIBR-UpptÑckt', 0
                               db 'H - Dolt Stîd', 0
                               db 'L - Partition Bokstav', 0
                               db 'P - Ext-Part MS invent', 0
                               db 0

TXT_SETUPHELP_HideSetup:       db 'VÑlj status fîr', 0
                               db 'vilka partitioner', 0
                               db 'som skall dîljas,', 0
                               db 'nÑr den aktuellt valda', 0
                               db 'partitionen bootas.', 0
                               db 0

; Basic Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_DefaultPart      db 'éndrar din standard', 0
                               db 'partition. Den kan', 0
                               db 'anvÑndas vid Tidstyrd', 0
                               db 'Bootning.', 0
                               db 0
TXT_SETUPHELP_TimedBoot        db 'AiR-BOOT kommer att', 0
                               db 'fortsÑtta automatiskt', 0
                               db 'efter en specificerad', 0
                               db 'fîrdrîjning.', 0
                               db 0
TXT_SETUPHELP_TimedBootDelay   db 'Den omnÑmnda', 0
                               db 'fîrdrîjningen fîr.', 0
                               db 'Tidsstyrd Bootning.', 0
                               db 0
TXT_SETUPHELP_TimedKeyHandling db 'Om du trycker en', 0
                               db 'tangent i Bootmenyn', 0
                               db 'nÑr du anvÑnder Tids', 0
                               db 'Boot, vad skall', 0
                               db 'AiR-BOOT gîra?',0
                               db 0
TXT_SETUPHELP_BootLastIfTimed  db 'AiR-BOOT kommer att', 0
                               db 'anvÑnda sist-bootade', 0
                               db 'part. med TidsBoot.', 0
                               db 'Annars kommer den', 0
                               db 'att anvÑnda standard', 0
			       db 0
TXT_SETUPHELP_RememberLastBoot db 'AiR-BOOT kommer att', 0
                               db 'hÜlla meny-raden pÜ', 0
                               db 'sist bootade', 0
                               db 'partionen vid start.', 0
                               db 0
TXT_SETUPHELP_RememberTimeBoot db 'Liksom den senaste', 0
                               db 'optionen, kommer', 0
                               db 'AiR-BOOT att hÜlla', 0
                               db 'raden ocksÜ fîr', 0
                               db 'Tidsstyrd Bootning.', 0
			       db 0
TXT_SETUPHELP_IncludeFloppy    db 'AiR-BOOT kommer att', 0
                               db 'tillÜta booting', 0
                               db 'frÜn A: via menyn.', 0
                               db 0
TXT_SETUPHELP_MbrProtection    db 'Skydda din MBR via', 0
                               db 'resident kod. Behîver', 0
                               db '1 KByte av bas-minne', 0
                               db 'Kan vara inkompatibelt', 0
                               db 'med vissa OS.', 0
			       db 0
TXT_SETUPHELP_IgnoreMbrWrites  db 'Om det Ñr aktiverat,', 0
                               db 'kommer all skrivning', 0
                               db 'att ignoreras, annars', 0
                               db 'kommer systemet att', 0
                               db '"krascha".', 0
			       db 0
TXT_SETUPHELP_MakeSounds       db 'AiR-BOOT kan fÜs att', 0
                               db 'utfîra ljud med din', 0
                               db 'interna hîgtalare.', 0
                               db 0
TXT_SETUPHELP_CooperBars       db 'Kommer att utfîra', 0
                               db 'snygga effekter', 0
                               db 'under bootning.', 0
                               db 0

; Advanced Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_BootMenu         db 'Avaktiverad visar den', 0
                               db 'inte menyn och bootar', 0
                               db 'standard partion', 0
                               db 'direkt. Detaljerad', 0
                               db 'visar mer information.', 0
                               db 0
TXT_SETUPHELP_PartAutoDetect   db 'Om AiR-BOOT hittar nya', 0
                               db 'partitioner, kommer', 0
                               db 'den att gîra dom', 0
                               db 'bootningsbara.', 0
                               db 0
TXT_SETUPHELP_PasswordedSetup  db 'NÑr du kommer till den', 0
                               db 'hÑr setupen, kommer du', 0
                               db 'att bli tillfrÜgad om', 0
                               db 'ett lîsenord.', 0
                               db 0
TXT_SETUPHELP_PasswordedSystem db 'NÑr du bootar din', 0
                               db 'dator, kommer du att', 0
                               db 'bli tillfrÜgad om det.', 0
                               db 0
TXT_SETUPHELP_PasswordedBoot   db 'NÑr Tidstyrd Bootning', 0
                               db 'inte anvÑnds kommer du', 0
                               db 'att bli tillfrÜgad.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName    db 'NÑr du visar diskett', 0
                               db 'i boot-menyn, kommer', 0
                               db 'AiR-BOOT att hÑmta', 0
                               db 'diskettnamnet.', 0
                               db 0
TXT_SETUPHELP_GetFloppyName2Sec db 'Som tillÑgg kommer', 0
                               db 'den att uppdatera', 0
                               db 'diskettnamnet', 0
                               db 'varannan sekund.', 0
                               db 0
TXT_SETUPHELP_VirusDetect      db 'Kommer att upptÑcka', 0
                               db 'normala virus (enkla).', 0
                               db 0
TXT_SETUPHELP_StealthDetect    db 'Kommer att upptÑcka', 0
                               db 'Stealth virus.', 0
                               db 0
TXT_SETUPHELP_VIBRdetect       db 'Kommer att upptÑcka', 0
                               db 'VIBR. VIBR stÜr fîr', 0
                               db 'Virus-In-Boot-Record.', 0
                               db 0
TXT_SETUPHELP_ContinueBIOSboot db 'Om aktiverad, kommer', 0
                               db 'den hÑr optionen att', 0
                               db 'returnera kontrollen', 0
                               db 'till BIOS fîr det.', 0
                               db 'spec. devicet.', 0
                               db 0

; Extended Options - Help
;----------------------------------|--------------------|-------------------
TXT_SETUPHELP_LinuxKernelPart  db 'Definierar FAT-16', 0
                               db 'partition som', 0
                               db 'innehÜller dina', 0
                               db 'Linux kÑrnor.', 0
                               db 0
TXT_SETUPHELP_LinuxDefaultKrnl db 'Definiera din', 0
                               db 'standardkÑrnas', 0
                               db 'filnamn.', 0
                               db 0
TXT_SETUPHELP_LinuxRootPart    db 'éndrar din Linux', 0
                               db 'root partition.', 0
                               db 0
TXT_SETUPHELP_ForceLBAUsage    db 'Forc. anvÑndning av', 0
                               db 'BIOS LBA APIs', 0
                               db 'istÑllet fîr mixad anv.', 0
                               db 'av CHS och LBA.', 0
                               db 0
TXT_SETUPHELP_ExtPartMShack    db 'Aktiverar dyn. Ñndring', 0
                               db 'av den utîkade part.,', 0
                               db 'skriv id fîr standard', 0
                               db 'eller MS-uppfinnade.', 0
                               db '(definierad av P-flag)', 0
                               db 0
TXT_SETUPHELP_DefLinuxCmd:     db 'Definierar kommando', 0
                               db 'rad fîr Linux, om', 0
                               db 'tillgÑngligt.', 0
                               db 0

; Maximum 26 chars (should not be reached)
;----------------------------------|------------------------|---------------
TXT_SETUPHELP_Base             db ' HJéLP ', 0
TXT_SETUPHELP_Enter            db '<ENTER>', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_PasswordOld          db 'Gammalt Lîsenord:', 0
TXT_SETUP_PasswordDefine       db 'Definiera Lîsenord:', 0
TXT_SETUP_PasswordVerify       db 'Verifiera Lîsenord:', 0
TXT_SETUP_PasswordIncorrect    db 'Gammalt Lîsenord Inte Korrekt, Ledsen', 0
TXT_SETUP_PasswordMismatch     db 'Matchar Inte, Gammalt Lîsenord BehÜlls', 0
TXT_SETUP_PasswordDisabled     db 'Inget Lîsenord/Skydd Avaktiverat', 0
TXT_SETUP_PasswordMatched      db '** Matchar, Nytt Lîsenord Satt **', 0

; Maximum 60 chars (should not be reached anyway)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_SaveAndExitNow       db 'SPARA & AVSLUTA NU', 0
TXT_SETUP_QuitWithoutSaveNow   db 'AVSLUTA UTAN ATT SPARA', 0
; Must be shorter than SaveAndExitNow / QuitWithoutSaveNow
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_AreYouSure1          db 'éR DU SéKER?', 0
TXT_SETUP_AreYouSure2          db '(J/N)', 0

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_SETUP_EnterLinuxCmdLine    db 'Var vÑnlig ange/modifiera din Linux kommando-rad:', 0
TXT_SETUP_NoLinuxInstalled     db 'Du har inte Linux installerat', 0
TXT_SETUP_NoLDLpartition       db 'Den valda partitionen Ñr inte varken HPFS eller FAT16', 0

; Maximum 34 chars (should not be reached)
;----------------------------------|--------------------------------|-------
TXT_SETUP_HideFeature          db 'Dîlj Funktion', 0
;----------------------------------|---------------------|------------------
TXT_SETUP_HideFeature2         db 'Status vid bootning ', 0

; Drive-Letter Menu Header - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUP_DriveLetter          db 'Partition Bokstav', 0

; Drive-Letter Keys - Max Length: 19 chars
;----------------------------------|-----------------|----------------------
TXT_SETUPHELP_DriveLetter      db 'Tryck C-Z', 0

IFNDEF ReleaseCommercial
   ; Colors for special words hard-coded. Keep all 0s.
   TXT_SETUP_LowerMessage      db 'Detta program Ñr ',0,'fritt',0,' fîr icke-kommersiell privat anvÑndning.',0
                               db 'Du fÜr ',0,'INTE',0,' distribuera/anvÑnda AiR-BOOT i ',0,'-NèGON-',0,' form,',0
                               db 'om du erhÜller pengar fîr den distribuerade produkten eller servicen.',0
                               db 'Om du vill anvÑnda AiR-BOOT i ',0,'andra sammanhang',0,', ',0,'fîrinstallera',0,' eller',0
                               db 'distribuera',0,' den, var vÑnlig och kontakta mig via e-mail: ',0,'kiewitz@netlabs.org',0,' !',0
ENDIF
