;------------------------------------------------------------------------------
;                                                        AiR-BOOT / OTHER TEXT
; v046 - Swedish - by Bj”rn S”derstr”m
;------------------------------------------------------------------------------

TXT_TranslationBy              db 'Swedish by Bj”rn S”derstr”m', 0

; TopInfosX variables are used for Boot-Menu and Partition Setup

; Maximum 2/10/11/6 chars
;----------------------------------||---------------------------------------
TXT_TopInfos_No:               db 'No', 0
TXT_TopInfos_Hd:               db 'Hd', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_HdSize:           db 'Hd/Storl:', 0
;----------------------------------|--------|-------------------------------
TXT_TopInfos_Label:            db 'Etikett:', 0
;----------------------------------|---------|------------------------------
TXT_TopInfos_Type:             db 'Typ:', 0
;----------------------------------|----|-----------------------------------
TXT_TopInfos_Flags:            db 'Flag:', 0      ; <-- for Partition Setup

; Will be added together to one line, maximum 76 chars
TXT_TimedBootLine:             db 'Tidsbootning aktiverad. Systemet kommer att boota '''
TXT_TimedBootEntryName         db 12 dup (0)
TXT_TimedBootLine2:            db      ''' om ', 0
TXT_TimedBootSeconds:          db ' sekunder. ', 0
TXT_TimedBootSecond:           db ' sekund. ', 0
; Maximum 76 chars
;----------------------------------|--------------------------------------------------------------------------|
TXT_TimedBootDisabled:         db 'Tidstyrd bootning avaktiverad; ingen tidsgr„ns kommer att upptr„da.', 0
TXT_BootMenuHelpText1:         db 'Tryck [Esc] f”r att v„xla tidsboot, [Enter] f”r att acceptera aktuellt val.', 0
TXT_BootMenuHelpText2:         db 'V„lj annan med pilarna, eller tryck [TAB] f”r att se BIOS POST meddelande.', 0
; Maximum 30 chars
;----------------------------------|----------------------------|
TXT_BootMenuEnterSetup         db 'F10 f”r att kommma till Setup', 0

; Dynamic Length (till 80 chars)
TXT_BrokenPartitionTable:      db 13, 10, ' - Your system has at least one broken partition table entry or your harddrive'
                               db 13, 10, '   contains bad sectors. Systemet haltat.', 0
TXT_TooManyPartitions:         db 13, 10, ' - F”r m†nga partitioner hittades. AiR-BOOT st”der endast upp till 30.', 0
TXT_NoBootAble:                db 13, 10, ' - Ingen bootningsbar partition definierad. Systemet haltat.', 0
TXT_BIOSchanged:               db 13, 10, ' - BIOS ŽNDRAT, var v„nlig kontrollera ditt system efter virus, f”r att vara s„ker.'
                               db 13, 10, '   Tryck n†gon tangent f”r att forts„tta...', 0

TXT_VirusFoundMain:            db 13, 10, ' - !VARNING! -> ETT VIRUS HITTADES <- !VARNING!', 13, 10, 0
TXT_VirusFound1ok:             db '    Det f”rst”rdes, men systemet kanske inte bootas om korrekt. Om det intr„ffar,', 13, 10
                               db '    anv„nd din AiR-BOOT systemdisk.', 13, 10, 0
TXT_VirusFound1damn:           db '    Olyckligtvis f”rst”rdes AiR-BOOTs backup. Du m†ste boota om genom att anv„nda din', 13, 10
                               db '    AiR-BOOT systemdisk.', 13, 10, 0
TXT_VirusFound1any:            db '    F”r s„kerhets skull, b”r du kontrollera din h†rddisk mot ytterligare virus.', 13, 10, 0
TXT_VirusFound2:               db '    Det finns i boot-sektorn hos den partition, som du ville boota.', 13, 10
                               db '    Anv„nd ett antivirus program. Det kan vara falskt alarm eller.', 13, 10
                               db '    Efter avl„gsnande, m†ste du initiera om uppt„cktsvariablerna, g† till ', 13, 10
                               db '    ''PARTITION SETUP'' och v„xla VIBR-uppt„ckt tv† g†nger (av/p†).', 13, 10
                               db '    Om det bara var ett falskt alarm, l„mna det i av-l„ge.', 13, 10, 0
TXT_VirusFoundEnd:             db '    Systemet haltat. Var v„nlig tryck RESET.', 0
TXT_HowEnterSetup:             db 13, 10, ' - Tryck och h†ll Ctrl eller Alt f”r att komma till AiR-BOOT Setup.', 0

TXT_BootingNow1:               db 'Bootar systemet anv„ndande ', 0
; DO NOT MODIFY HERE
TXT_BootingNow2:               db ''''
TXT_BootingNowPartName:        db 12 dup (0) ; Space for BootThisPart-Name
; DO NOT MODIFY TILL HERE
TXT_BootingNowPartition:       db ''' partition', 0
TXT_BootingNowKernel:          db ''' k„rna', 0
TXT_BootingHide:               db '; d”lj aktiv', 0
TXT_BootingWait:               db '; var v„nlig v„nta...', 13, 10, 13, 10, 0

; FIXED LENGTH - 11 chars each string
;----------------------------------|---------|------------------------------
TXT_Floppy_NoName:             db 'Inget Namn '
TXT_Floppy_Drive:              db 'Diskett    '
TXT_Floppy_NoDisc:             db 'Ingen Disk '

; Maximum 60 chars (should not be reached)
;----------------------------------|----------------------------------------------------------|
TXT_PleaseEnterPassword        db ' Var v„nlig Ange L”senord:', 0
; the following 3 strings have to equal or *longer* than PleaseEnterPassword
TXT_ProtectedSystem            db '** L™SENORDSKYDDAT SYSTEM **', 0
TXT_ProtectedSetup             db '** L™SENORDSKYDDAD SETUP! **', 0
TXT_ProtectedBootUp            db '** L™SENORDSKYDDAD BOOTUP **', 0

; will get completed using TXT_ERROR_CheckFailed from MBR.asm
TXT_ERROR_CheckConfig          db 13, 10, ' - Konfigurationen', 0

;----------------------------------|----------------------------------------------------------|
TXT_TooManyTries               db 'F”r M†nga F”rs”k, Systemet Haltat', 0
