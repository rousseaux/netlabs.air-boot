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



#include    "install.h"



// ============================================================================
//  Variables
// ============================================================================



//CHAR     Track0[SECTOR_COUNT * BYTES_PER_SECTOR];     // current track 0 from harddrive
//CHAR     Bootcode[SECTOR_COUNT * BYTES_PER_SECTOR];   // bootcode image from airboot.bin

/*
// With the addition of the C DOS-version, a static buffer for both
// Track0 and Bootcode would overflow the DGROUP segment. (>64kB)
// Placing the buffers in another segment does not work with Open Watcom v1.9.
// While the buffers are BSS and should be in segments like FAR_BSS,
// Open Watcom places the buffers in FAR_DATA and produces a bloated DOS
// executable. Using the same source and then building an OS/2 v1.x
// executable does not produce a bloated .EXE, eventhough the segments are
// called FAR_DATA and in the middle of the image.
// Microsoft C v6.0 displays the same behavior; DOS bloated, OS/2 v1.x ok.
// An interesting feat is that when building an OS/2 v1.x executable and then
// binding that to produce a FAPI executable does not produce a bloated .EXE
//
// Also, when experimenting with segments and #pragma data_seg(), some
// strange behavior was observed.
// WCC:
// Explicitly naming a segment and class for the static buffers caused
// wcc to keep generating it's default SS: based addressing, eventhough
// the segments are not part of DGROUP.
// Only the -zu flag corrects this. (DS!=SS)
// WPP:
// C++ wpp used correct addressing but the segment class in the #pragma
// was not honored and the segment name got mangled.
//
// In both cases the volatile (transient) data would occupy space in the
// disk-image.
// The only way seems to be putting the buffers in a separate segment using
// pragma's, using wcc with the -zu flag and use the wlink ORDER directive
// to place the FAR BSS data above the stack acompanied by a NOEMIT modifier.
// For this all the class names of the previous segments must be included
// in the wlink ORDER directive which would make the link phase dependend
// on segment names. This solution does not work for wpp because it mangles
// the segment name and overrides the custom class name to FAR_DATA.
//
// So, these buffers are now dynamically allocated.
*/
PCHAR   Track0      = NULL;     // Buffer for Track0 from harddisk.
PCHAR   Bootcode    = NULL;     // Buffer for AIRBOOT.BIN image.

UCHAR   Bootcode_LanguageID     = ' ';
USHORT  Bootcode_Version        = 0;
USHORT  Bootcode_ConfigVersion  = 0;

UCHAR   Status_Code             = STATUS_NOTINSTALLED;
UCHAR   Status_Config           = STATUS_NOTINSTALLED;
USHORT  Installed_CodeVersion   = 0;
USHORT  Installed_ConfigVersion = 0;
UCHAR   Installed_LanguageID    = ' ';

BOOL    Option_ForceCode        = FALSE;
BOOL    Option_ForceConfig      = FALSE;
BOOL    Option_Silent           = FALSE;
BOOL    Option_CID              = FALSE;

BOOL    Install_Code            = FALSE;
BOOL    Install_Config          = FALSE;
BOOL    Install_IsCorrupt       = FALSE;

//USHORT  StatusCode              = 0;
PSZ     ImpossibleCause         = NULL;

CHAR    TempHidPartTable[45 * 34];




// ============================================================================
//  Kidnapped bitfield functions needed to access the packed hideparttable
// ============================================================================

/*
// Pragma's could be used to interface with the bitfield functions, but I was
// not in the mood to examine how they behave when conditions like calling
// convention, memory model, optimization, etc. are changed. Especially
// optimization generates very different code depending on the -o flags so
// it felt a bit 'fragile' to me to use them without further analysis.
// So I opted for the 'easy way' of some small prolog code to pass the
// parameters to the correct registers required by the core bitfield functions.
*/


//~ #ifdef  __386__
//~ #pragma aux __airboot "*___" parm caller [EBX] [EDX] [ECX] [EAX ESI EDI] value [AL];
//~ #else
//~ #pragma aux __airboot "*___" parm caller [DI BX] [DX] [CX] [AX SI] value [AL];
//~ #endif
//~ #pragma aux (__airboot) get_bitfield;
//~ #pragma aux (__airboot) set_bitfield;

/* Prototypes */
void    bf_test();
char    get_bitfield(char* buffer, char index, char fieldwidth);
char    set_bitfield(char* buffer, char index, char fieldwidth, char value);

//~ #ifdef  __386__
//~ #pragma aux get_bitfield parm [EBX] [ECX] [EDX] value [AL];
//~ #pragma aux set_bitfield parm [EBX] [ECX] [EDX] [EAX];
//~ #else
//~ #pragma aux get_bitfield value [DL];
//~ #pragma aux set_bitfield parm [BX] [CX] [DX] [AX];
//~ #endif

void    DumpTrack0();

// In 32-bit mode EBX is used and in 16-bit mode BX, so we abstract it's name.
// The rest of the bitfield code uses 16-bit registers because I kidnapped
// it from AiR-BOOT.
#define dataptr16   "BX"
#define dataptr32   "EBX"
#ifdef  __386__
    #define dataptr     dataptr32
#else
    #define dataptr     dataptr16
#endif




/*
// ----------------------------------------------------------------------------
// bf_test -- Test function to analyse code generation
// ----------------------------------------------------------------------------
*/
void    bf_test() {
    char*   b1 = Track0;
    char*   b2 = Bootcode;
    char    i1 = 0x11;
    char    i2 = 0x12;
    char    v1 = 0x83;
    char    v2 = 0x84;
    char    rv1 = 0xf8;
    char    rv2 = 0xf9;

    rv1 = get_bitfield(b1, i1, 6);
    rv2 = set_bitfield(b2, i2, 6, v1+v2);
}

/*
// ----------------------------------------------------------------------------
// do_bf_test -- Simple function to test the bitfield functions
// ----------------------------------------------------------------------------
*/
void    do_bf_test() {
    char    buf[512];
    int     i;

    for (i=0; i<100; i++) {
        set_bitfield(buf, i, 6, i);
    }

    set_bitfield(buf, 18, 6, 255);
    set_bitfield(buf, 21, 6, 255);
    set_bitfield(buf, 33, 6, 255);
    set_bitfield(buf, 37, 6, 255);


    for (i=0; i<100; i++) {
        printf("index: %02d, value: %02d\n", i, get_bitfield(buf, i, 6));
    }
    return;
}


/*
// ----------------------------------------------------------------------------
// get_bitfield -- Get a n-bit wide bitfield at index i from a buffer in memory
// ----------------------------------------------------------------------------
// This is code kidnapped from AiR-BOOT and used here to handle the packed
// hideparttable. A 'record' in the hideparttable is 34 bytes long and it
// can store 45 partition numbers using 6-bits per partition number.
// Bitfield widths from 1 to 8 are supported and the maximum buffersize is
// 256 bytes.
*/
char    get_bitfield(char* buffer, char index, char fieldwidth) {

    char    rv = 0;
    // These are used to break-up the far pointer in large-data model 16-bit
    // code so the buffer can be addressed correctly.
    // In 32-bit flat mode they will have no effect and in 32-bit large-data
    // mode (imaginary) they can handle the buffer being in a seperate segment.
    unsigned    dseg = _FP_SEG(buffer);
    unsigned    dptr = _FP_OFF(buffer);

    // Prolog code.
    // Handle data-segment and parameters.
    _asm {
        push    ds      ; Save DS from caller.
        push    dseg    ; Setup DS to
        pop     ds      ; address our segment. (When 16-bit large data-model)

        mov     dl, index       ; Index to bitfield in DL.
        mov     dh, fieldwidth  ; Width of bitfield in DH.
        mov     dataptr, dptr   ; Pointer in [E]BX.
    }


    // This is practically a verbatim copy of the core routine from CONV.ASM.
    // Only a slight modification with regard to [E]BX addressing is made
    // so it can also function in 32-bit mode.
    _asm {

        ; IN:   DL = Index to store bitfield
        ;       DH = Bitfield width (1-8)
        ;    [E]BX = Pointer to bitfield array
        ; OUT:  AL = Value of requested bitfield
        ;       AH = Mask value

        ; Normalize bit-width in DH.
        dec     dh          ; Decrement bitfield width to mask invalid values.
        and     dh,07h      ; Only 3 bits are significant to determine width.
        mov     cl,dh       ; Save for later use to calculate mask.
        inc     dh          ; Put back to normalized value.

        ; Calculate corresponding AND-mask in CH.
        mov     ch,2        ; Were going to shift 2...
        shl     ch,cl       ; to obtain the mask corresponding...
        dec     ch          ; to the bitfield width.

        ; Calculate byte-index.
        mov     al,dl       ; Index in AL.
        inc     al          ; Increment for calculations.
        mul     dh          ; Multiply by bitfield width to get bits.
        mov     cl,8        ; Nr. of bits in a byte.
        div     cl          ; Divide to get byte index.

        ; Advance pointer to byte-index.
        add     bl,al       ; Advance pointer...
        adc     bh,0        ; to byte index.

        ; We have to 'carry on' to the high word of EBX if in 32-bit mode.
#ifdef  __386__
        pushf               ; Save the possible carry from the last addition.
        ror     ebx,16      ; Get high word of EBX in BX.
        popf                ; Restore possible carry.
        adc     bx,0        ; Add it and...
        rol     ebx,16      ; move back to have a valid 32-bit pointer again.
#endif

        ; Determine if we need 1 or 2 byte access to extract the bitfield.
        mov     cl,ah       ; Get remainder in CL.
        sub     cl,dh       ; Substract bitfield width to get shift-count.
        mov     ah,0        ; Prepare upper=0 when field spans no byte bound.
                            ; Don't change to xor ah,ah or any CY will be lost.

        ; Jump if the bitfield does not span byte boundaries.
        ; (Remainder - bitfield width >= 0)
        jae     CONV_GetBitfieldValue_nospan

        ; Bit-field spans byte boundaries, so adjust shift-count
        ; and use AH to get first part of bitfield.
        add     cl,8        ; Adjust shift-count.
        mov     ah,[dataptr]     ; Get byte into AH instead.
        dec     dataptr          ; Adjust pointer to load rest of bitfield.

    CONV_GetBitfieldValue_nospan:
        mov     al,[dataptr]     ; Load (rest of) bitfield into AL.
        shr     ax,cl       ; Shift bitfield to the right.
        mov     ah,ch       ; Get mask in AH.
        and     al,ah       ; Mask value.
    }


    // Epilog code.
    // Restore caller's DS.
    // Store return value.
    _asm {
        pop     ds
        mov     [rv],al
    }

    return rv;
}


/*
// ----------------------------------------------------------------------------
// set_bitfield -- Set a n-bit wide bitfield at index i in a buffer in memory
// ----------------------------------------------------------------------------
// This is code kidnapped from AiR-BOOT and used here to handle the packed
// hideparttable. A 'record' in the hideparttable is 34 bytes long and it
// can store 45 partition numbers using 6-bits per partition number.
// Bitfield widths from 1 to 8 are supported and the maximum buffersize is
// 256 bytes.
*/
char    set_bitfield(char* buffer, char index, char fieldwidth, char value) {


    // These are used to break-up the far pointer in large-data model 16-bit
    // code so the buffer can be addressed correctly.
    // In 32-bit flat mode they will have no effect and in 32-bit large-data
    // mode (imaginary) they can handle the buffer being in a seperate segment.
    unsigned    dseg = _FP_SEG(buffer);
    unsigned    dptr = _FP_OFF(buffer);

    // Prolog code.
    // Handle data-segment and parameters.
    _asm {
        push    ds      ; Save DS from caller.
        push    dseg    ; Setup DS to
        pop     ds      ; address our segment. (When 16-bit large data-model)

        mov     dl, index       ; Index to bitfield in DL.
        mov     dh, fieldwidth  ; Width of bitfield in DH.
        mov     dataptr, dptr   ; Pointer in [E]BX.
        mov     al, value       ; Value we want to poke in AL.
    }


    // This is practically a verbatim copy of the core routine from CONV.ASM.
    // Only a slight modification with regard to [E]BX addressing is made
    // so it can also function in 32-bit mode.
    _asm {

        ; IN:   AL = Value to store
        ;       DL = Index to store bitfield
        ;       DH = Bitfield width (1-8)
        ;    [E]BX = Pointer to bitfield array
        ; OUT:  AL = Value of stored bitfield
        ;       AH = Mask value

        ; Push value for later use.
        push    ax

        ; Normalize bit-width in DH.
        dec     dh          ; Decrement bitfield width to mask invalid values.
        and     dh,07h      ; Only 3 bits are significant to determine width.
        mov     cl,dh       ; Save for later use to calculate mask.
        inc     dh          ; Put back to normalized value.

        ; Calculate corresponding AND-mask in CH.
        mov     ch,2        ; Were going to shift 2...
        shl     ch,cl       ; to obtain the mask corresponding...
        dec     ch          ; to the bitfield width.

        ; Calculate byte-index.
        mov     al,dl       ; Index in AL.
        inc     al          ; Increment for calculations.
        mul     dh          ; Multiply by bitfield width to get bits.
        mov     cl,8        ; Nr. of bits in a byte.
        div     cl          ; Divide to get byte index.

        ; Advance pointer to byte-index.
        add     bl,al       ; Advance pointer...
        adc     bh,0        ; to byte index.

        ; We have to 'carry on' to the high word of EBX if in 32-bit mode.
#ifdef  __386__
        pushf               ; Save the possible carry from the last addition.
        ror     ebx,16      ; Get high word of EBX in BX.
        popf                ; Restore possible carry.
        adc     bx,0        ; Add it and...
        rol     ebx,16      ; move back to have a valid 32-bit pointer again.
#endif

        ; Determine if we need 1 or 2 byte access to extract the bitfield.
        mov     cl,ah       ; Get remainder in CL.
        sub     cl,dh       ; Substract bitfield width to get shift-count.

        ; Restore value to poke.
        pop     ax


        ; Jump if the bitfield does not span byte boundaries.
        ; (Remainder - bitfield width >= 0)
        jae     CONV_SetBitfieldValue_nospan

        ; Bit-field spans byte boundaries, so adjust shift-count
        ; and use 16-bit access.
        add     cl,8        ; Adjust shift-count.

        ; Merge the bitfield to the array.
        push    cx          ; Save mask (CH) and shift-count (CL).
        push    ax          ; Save value to store.
        xor     ah,ah       ; Clear upper byte so we can shift in it.
        and     al,ch       ; Mask value.
        shl     ax,cl       ; Move the bitfield to the proper location.
        mov     dh,[dataptr]     ; Get 1st part of bitfield from array.
        dec     dataptr          ; Adjust pointer.
        mov     dl,[dataptr]     ; Get 2nd part of bitfield from array.
        push    bx          ; We need BX so save it.
        xor     bh,bh       ; Clear upper byte so we can shift in it.
        mov     bl,ch       ; Put mask in BL.
        shl     bx,cl       ; Shift mask to proper location.
        not     bx          ; Complement it to mask-out the required bitfield.
        and     dx,bx       ; Mask-out the required bitfield.
        pop     bx          ; Restore pointer.
        or      ax,dx       ; Merge the bitfields.
        mov     [dataptr],al     ; Store lower byte.
        inc     dataptr          ; Adjust pointer.
        mov     [dataptr],ah     ; Store upper byte.
        pop     ax          ; Restore value.
        pop     cx          ; Restore mask and shift-count.

        ; Done.
        jmp     CONV_SetBitfieldValue_end

    CONV_SetBitfieldValue_nospan:
        ; Merge the bitfield to the array.
        push    cx          ; Save mask (CH) and shift-count (CL).
        push    ax          ; Save value to store.
        and     al,ch       ; Mask value.
        shl     al,cl       ; Move the bitfield to the proper location.
        mov     dl,[dataptr]     ; Get byte containing bitfield.
        shl     ch,cl       ; Shift mask to proper location.
        not     ch          ; Complement it to mask-out the required bitfield.
        and     dl,ch       ; Mask-out the required bitfield.
        or      al,dl       ; Merge the bitfields.
        mov     [dataptr],al     ; Store byte containing bitfield.
        pop     ax          ; Restore value.
        pop     cx          ; Restore mask and shift-count.

    CONV_SetBitfieldValue_end:
        mov     ah,ch       ; Get mask in AH.
        and     al,ah       ; Mask value.
    }

    // Epilog code.
    // Restore caller's DS.
    _asm {
        pop     ds
    }

    return value;
}








// ============================================================================
//  Platform-specific helper functions
// ============================================================================


/*
// Helper functions -- DOS implementation.
*/
#ifdef  PLATFORM_DOS
    USHORT CountHarddrives (void) {
        USHORT NumDrives = 0;

        /* Return the byte at 0040:0075 that contains the nr. of harddisks */
        _asm {
            push    es              ; We use ES to address the 40h segment.
            mov     ax,40h          ; Segment address of DOS BIOS DATA.
            mov     es,ax           ; Make ES address it.
            xor     ax,ax           ; Clear AX to receive return value.
            mov     al,es:[0075h]   ; Nr. of harddisks in AL.
            pop     es              ; Restore ES.
            mov     [NumDrives],ax  ; Return this value.
        }
        return NumDrives;
    }

    /*
    // On DOS this geometry check uses the INT13X value for sectors per track.
    // On OS/2 the DosDevIOCtl call uses a SPT value from the formatted disk,
    // irrespective of the physical geometry.
    */
    BOOL HarddriveCheckGeometry (void) {
        BOOL    rv = FALSE;

        _asm {
            ; According to Ralf Brown ES:DI=0000:0000 to avoid BIOS quirks.
            push    es
            push    di
            xor     di,di
            mov     es,di

            ; Get the disk parameters using normal (non-I13X) access.
            mov     ah,08h          ; Get Disk Parameters.
            mov     dl,80h          ; Boot Disk.
            int     13h             ; Transfer to BIOS.

            ; Check for errors
            mov     dx,0            ; Assume error.
            jc      end             ; CY if error.
            test    ah,ah           ; Double check for return-status.
            jnz     end             ; AH non-zero if error.

            ; Check sectors per track to be above 62
            and     cl,00111111b    ; Mask sectors.
            cmp     cl,SECTOR_COUNT ; Compare with max. AiR-BOOT sectors.
            jbe     end             ; SECTOR_COUNT or less is not enough.

            inc     dx              ; Set to no error.

        end:
            mov     ax,dx           ; Status to AX.

            ; Store in return value.
            mov     word ptr [rv],ax

            ; Restore ES:DI
            pop     di
            pop     es
        }
        return rv;
    }



    BOOL Track0Load (void) {
        BOOL        Success = FALSE;

        _asm {

            push    es              ; ES is used to point to loadbuffer.

            ; Load the complete AiR-BOOT image from Track0.
            mov     ah,02h          ; Read sectors from disk.
            mov     al,SECTOR_COUNT ; Number of sectors to read.
            mov     cx,1            ; Cyl 0, Sector 1.
            mov     dh,0            ; Head 0.
            mov     dl,80h          ; Boot Disk.
            les     bx,[Track0]     ; Buffer in ES:BX.
            int     13h             ; Transfer to BIOS.

            ; Check for errors
            mov     dx,0            ; Assume error.
            jc      end             ; CY if error.
            test    ah,ah           ; Double check status in AH.
            jnz     end             ; AH non-zero if error.

            inc     dx              ; Set to no error.

        end:
            mov     ax,dx           ; Status to AX.

            ; Store in return value.
            mov     word ptr [Success],ax

            ; Restore ES.
            pop     es
        }

        return Success;
    }

    BOOL Track0Write (void) {
        BOOL        Success = FALSE;

        _asm {

            push    es              ; ES is used to point to savebuffer.

            ; Save the complete AiR-BOOT image to Track0.
            mov     ah,03h          ; Write sectors to disk.
            mov     al,SECTOR_COUNT ; Number of sectors to write.
            mov     cx,1            ; Cyl 0, Sector 1.
            mov     dh,0            ; Head 0.
            mov     dl,80h          ; Boot Disk.
            les     bx,[Track0]     ; Buffer in ES:BX.
            int     13h             ; Transfer to BIOS.

            ; Check for errors
            mov     dx,0            ; Assume error.
            jc      end             ; CY if error.
            test    ah,ah           ; Double check status in AH.
            jnz     end             ; AH non-zero if error.

            inc     dx              ; Set to no error.

        end:
            mov     ax,dx           ; Status to AX.

            ; Store in return value.
            mov     word ptr [Success],ax

            ; Restore ES.
            pop     es
        }

        return Success;
    }

    void RebootSystem (void) {
        _asm {
            ; 65 * 65536 = 4259840 us = 4.2 sec.
            mov     ax,8600h        ; BIOS Wait.
            xor     dx,dx           ; Micro seconds Low.
            mov     cx,65           ; Micro seconds High.
            int     15h             ; Transfer to BIOS.

            //~ ; Try reboot via keyboard.
            //~ mov     al,0feh
            //~ out     64h,al

            ; Otherwise jump to F000:FFF0.
            db      0EAh
            dw      0FFF0h
            dw      0F000h
        }
        return;
    }

#endif



/*
// Helper functions -- OS/2 implementation.
*/
#ifdef  PLATFORM_OS2
    USHORT CountHarddrives (void) {
        USHORT NumDrives = 0;
        if (DosPhysicalDisk(INFO_COUNT_PARTITIONABLE_DISKS, &NumDrives, sizeof(NumDrives),NULL, 0) != 0)
            return 0;
        return NumDrives;
    }

    USHORT OS2_GetIOCTLHandle () {
        USHORT IOCTLHandle = 0;
        if (DosPhysicalDisk(INFO_GETIOCTLHANDLE, &IOCTLHandle, sizeof(IOCTLHandle),"1:" , 3) != 0)
            return 0;
        return IOCTLHandle;
    }

    void OS2_FreeIOCTLHandle (USHORT IOCTLHandle) {
        DosPhysicalDisk(INFO_FREEIOCTLHANDLE, NULL, 0, &IOCTLHandle, sizeof(IOCTLHandle));
        return;
    }

    // Special feature for OS/2, finds out boot drive letter and sends this
    //  information to AiR-BOOT, so that it's able to set that information
    //  during boot phase. Otherwise the user would have to set this.
    UCHAR AutoDriveLetter = ' ';
    ULONG AutoDriveLetterSerial = 0;

    void OS2_GetBootAutoDriveLetter (void) {
        ULONG  BootDrive;
        struct {
            ULONG       ulVSN;
            VOLUMELABEL vol;
        } InfoLevel2;
        DosQuerySysInfo (QSV_BOOT_DRIVE, QSV_BOOT_DRIVE, &BootDrive, sizeof(BootDrive));
        // BootDrive - 1-A:, 2-B:, 3-C:
        if ((BootDrive>2) & (!DosQueryFSInfo(BootDrive, FSIL_VOLSER, (PVOID)(&InfoLevel2), sizeof(InfoLevel2)))) {
            AutoDriveLetter       = (UCHAR) BootDrive+0x7D;
            AutoDriveLetterSerial = InfoLevel2.ulVSN;
            if (!Option_CID) {
                printf("%X\n", InfoLevel2.ulVSN);
            }
        }
    }

    /*
    // On DOS this geometry check uses the INT13X value for sectors per track.
    // On OS/2 the DosDevIOCtl call uses a SPT value from the formatted disk,
    // irrespective of the physical geometry.
    */
    BOOL HarddriveCheckGeometry (void) {
        USHORT               IOCTLHandle;
        USHORT               SectorsPerTrack = 0;
        DEVICEPARAMETERBLOCK DeviceParmBlock;
        ULONG                ulDataLength;

        IOCTLHandle = OS2_GetIOCTLHandle();

        if (!DosDevIOCtl(IOCTLHandle, IOCTL_PHYSICALDISK, PDSK_GETPHYSDEVICEPARAMS, NULL, 0, NULL, &DeviceParmBlock, sizeof(DeviceParmBlock), &ulDataLength))
            SectorsPerTrack = DeviceParmBlock.cSectorsPerTrack;
        OS2_FreeIOCTLHandle (IOCTLHandle);
        //if (SectorsPerTrack > 61) return TRUE;
        if (SectorsPerTrack > SECTOR_COUNT) return TRUE;
        // OS/2 is only able to support 512-byte/sector media, so we dont need to check this
        return FALSE;
    }

    BOOL Track0Load (void) {
        USHORT      IOCTLHandle;
        ULONG       TrackLayoutLen  = sizeof(TRACKLAYOUT)+sizeof(ULONG)*(SECTOR_COUNT-1);
        TRACKLAYOUT *TrackLayoutPtr = (TRACKLAYOUT*) malloc(TrackLayoutLen);
        ULONG       cbParms = sizeof(TrackLayoutPtr);
        ULONG       cbData  = BYTES_PER_SECTOR;
        int         i;
        BOOL        Success = FALSE;

        IOCTLHandle = OS2_GetIOCTLHandle();

        TrackLayoutPtr->bCommand      = 0x01;
        TrackLayoutPtr->usHead        = 0;
        TrackLayoutPtr->usCylinder    = 0;
        TrackLayoutPtr->usFirstSector = 0;
        TrackLayoutPtr->cSectors      = SECTOR_COUNT;

        for (i=0; i<SECTOR_COUNT; i++) {
            TrackLayoutPtr->TrackTable[i].usSectorNumber = i+1;
            TrackLayoutPtr->TrackTable[i].usSectorSize   = BYTES_PER_SECTOR;
        }

        if (!DosDevIOCtl(IOCTLHandle, IOCTL_PHYSICALDISK, PDSK_READPHYSTRACK,
            TrackLayoutPtr, cbParms, &cbParms, Track0, cbData, &cbData))
            Success = TRUE;

        OS2_FreeIOCTLHandle (IOCTLHandle);
        free (TrackLayoutPtr);
        return Success;
    }

    BOOL Track0Write (void) {
        USHORT      IOCTLHandle;
        ULONG       TrackLayoutLen  = sizeof(TRACKLAYOUT)+sizeof(ULONG)*(SECTOR_COUNT-1);
        TRACKLAYOUT *TrackLayoutPtr = (TRACKLAYOUT*) malloc(TrackLayoutLen);
        ULONG       cbParms = sizeof(TrackLayoutPtr);
        ULONG       cbData  = BYTES_PER_SECTOR;
        INT         i;
        BOOL        Success = FALSE;

        IOCTLHandle = OS2_GetIOCTLHandle();


        TrackLayoutPtr->bCommand      = 0x01;
        TrackLayoutPtr->usHead        = 0;
        TrackLayoutPtr->usCylinder    = 0;
        TrackLayoutPtr->usFirstSector = 0;
        TrackLayoutPtr->cSectors      = SECTOR_COUNT;

        for (i=0; i<SECTOR_COUNT; i++) {
            TrackLayoutPtr->TrackTable[i].usSectorNumber = i+1;
            TrackLayoutPtr->TrackTable[i].usSectorSize   = BYTES_PER_SECTOR;
        }

        if (!DosDevIOCtl(IOCTLHandle, IOCTL_PHYSICALDISK, PDSK_WRITEPHYSTRACK,
            TrackLayoutPtr, cbParms, &cbParms, Track0, cbData, &cbData))
            Success = TRUE;

        OS2_FreeIOCTLHandle (IOCTLHandle);
        free (TrackLayoutPtr);
        return Success;
    }

    #define CATEGORY_DOSSYS 0xD5
    #define FUNCTION_REBOOT 0xAB

    void RebootSystem (void) {
        HFILE  DosHandle;
        ULONG  DosOpenAction;

        DosSleep (2000);
        if (!DosOpen("DOS$", &DosHandle, &DosOpenAction, 0, FILE_NORMAL, FILE_OPEN, OPEN_ACCESS_READWRITE|OPEN_SHARE_DENYNONE, NULL)) {
            DosDevIOCtl(DosHandle, CATEGORY_DOSSYS, FUNCTION_REBOOT, NULL, 0, NULL, NULL, 0, NULL);
            DosSleep (60000);
        }
        DosClose(DosHandle);
    }
#endif




/*
// Helper functions -- Win32 implementation.
*/
#ifdef  PLATFORM_WINNT
    // Checks, if we are under NT
    BOOL CheckWindowsVersion (void) {
        OSVERSIONINFO Version;
        Version.dwOSVersionInfoSize = sizeof(Version);
        GetVersionEx(&Version);
        if (Version.dwPlatformId == VER_PLATFORM_WIN32_NT)
            return TRUE;
        if (!Option_CID) {
            printf(" - This installer is for WindowsNT family only.\n");
            printf("    Please use DOS installer for Windows9x.\n");
        }
        return FALSE;
    }


    HANDLE WINNT_GetIOCTLHandle (void) {
        return CreateFile("\\\\.\\physicaldrive0", GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ|FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0);
    }

    void WINNT_FreeIOCTLHandle (HANDLE IOCTLHandle) {
        CloseHandle(IOCTLHandle);
    }

    USHORT CountHarddrives (void) {
        return 1;
    }

    BOOL HarddriveCheckGeometry (void) {
        HANDLE        IOCTLHandle;
        DISK_GEOMETRY Geometry;
        USHORT        SectorsPerTrack = 0;
        DWORD         Dummy;

        IOCTLHandle = WINNT_GetIOCTLHandle();
        if (DeviceIoControl(IOCTLHandle, IOCTL_DISK_GET_DRIVE_GEOMETRY, NULL, 0, &Geometry, sizeof(Geometry), &Dummy, NULL))
            SectorsPerTrack = (USHORT) Geometry.SectorsPerTrack;
        WINNT_FreeIOCTLHandle(IOCTLHandle);
        //if (SectorsPerTrack > 61) return TRUE;              // >60 should also be ok for normal image (60 for image 1 for lvm)
        if (SectorsPerTrack > SECTOR_COUNT)
            return TRUE;      // Note: This is 1 sector smaller than above !!

        return FALSE;
    }

    BOOL Track0Load (void) {
        HANDLE      IOCTLHandle;
        DWORD       BytesRead = 0;
        BOOL        Success = FALSE;

        IOCTLHandle = WINNT_GetIOCTLHandle();
        SetFilePointer(IOCTLHandle, 0, 0, FILE_BEGIN);
        if (ReadFile(IOCTLHandle, Track0, SECTOR_COUNT * BYTES_PER_SECTOR, &BytesRead, NULL))
            Success = TRUE;
        WINNT_FreeIOCTLHandle(IOCTLHandle);
        return Success;
    }

    BOOL Track0Write (void) {
        HANDLE      IOCTLHandle;
        DWORD       BytesWritten = 0;
        BOOL        Success = FALSE;

        IOCTLHandle = WINNT_GetIOCTLHandle();
        SetFilePointer(IOCTLHandle, 0, 0, FILE_BEGIN);
        if (WriteFile(IOCTLHandle, Track0, SECTOR_COUNT * BYTES_PER_SECTOR, &BytesWritten, NULL))
            Success = TRUE;
        WINNT_FreeIOCTLHandle(IOCTLHandle);
        return Success;
    }

    void RebootSystem (void) {
        HANDLE           token;
        TOKEN_PRIVILEGES tokenpriv;
        OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES|TOKEN_QUERY, &token);
        LookupPrivilegeValue(NULL, SE_SHUTDOWN_NAME, &tokenpriv.Privileges[0].Luid);
        tokenpriv.PrivilegeCount = 1;
        tokenpriv.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
        AdjustTokenPrivileges(token, FALSE, &tokenpriv, 0, NULL, 0);
        ExitWindowsEx(EWX_REBOOT, 0);
    }
#endif


/*
// Helper functions -- Linux implementation.
*/
#ifdef  PLATFORM_LINUX
    USHORT CountHarddrives (void) {
        USHORT NumDrives = 0;
        // Implement !
        return NumDrives;
    }

    BOOL HarddriveCheckGeometry (void) {

        // Implement !
        return FALSE;
    }

    BOOL Track0Load (void) {
        BOOL        Success = FALSE;

        // Implement !
        return Success;
    }

    BOOL Track0Write (void) {
        BOOL        Success = FALSE;

        // Implement !
        return Success;
    }

    void RebootSystem (void) {

        // Implement !
    }

#endif





// ============================================================================
//  Common Code
// ============================================================================


USHORT GetChecksumOfSector (USHORT Checksum, PCHAR SectorPtr) {
    PUSHORT TempPtr = (PUSHORT)SectorPtr;
    USHORT  i;
    for (i=0; i<256; i++) {
        Checksum = *TempPtr ^ 0xBABE ^ Checksum;
        TempPtr++;
    }
    if (Checksum==0)
        Checksum = 1;
    return Checksum;
}

// Loads airboot.bin into memory (if possible) and sets some variables
//  also makes sure that airboot.bin has correct length
BOOL LoadBootcodeFromFile (void) {
    FILE  *FileHandle = NULL;
    ULONG BootcodeSize = 0;

    // Try to open file...
    FileHandle = fopen(IMAGE_NAME, "rb");
    if (!FileHandle) {
        if (!Option_CID) {
            printf("%s not found\n", IMAGE_NAME);
        }
        return FALSE;
    }

    // Seek to end of file to determine image size...
    fseek (FileHandle, 0, SEEK_END);
    BootcodeSize = ftell(FileHandle);
    if (BootcodeSize!=IMAGE_SIZE && BootcodeSize!=IMAGE_SIZE_60SECS) {
        fclose (FileHandle);
        if (!Option_CID) {
            printf("Invalid %sn\n", IMAGE_NAME);
        }
        return FALSE;
    }

    // Read whole file into memory...
    fseek (FileHandle, 0, SEEK_SET);
    fread (Bootcode, 1, IMAGE_SIZE, FileHandle);
    fclose (FileHandle);

    // Extract language and version info...
    Bootcode_Version = (Bootcode[13] << 8) | Bootcode[14];
    Bootcode_LanguageID = Bootcode[15];
    Bootcode_ConfigVersion = (Bootcode[0x6C0D] << 8) | Bootcode[0x6C0E];
    return TRUE;
}

/**
 * Check MBR and AB signatures.
 * Also check code sectors if AB is installed.
 * Set global status accordingly.
 */
void Status_CheckCode (void) {
    USHORT TotalCodeSectorsUsed = 0;
    USHORT Checksum = 0;
    PCHAR  SectorPtr = NULL;

    if (Status_Code==STATUS_IMPOSSIBLE)
        return;
    // EZ-Setup check!
    Status_Code = STATUS_NOTINSTALLED;
    if ((Track0[0x1FE]!=0x55) || (Track0[0x1FF]!=0xAA))
        return;                   // No MBR signature found, so not installed
    if (strncmp(&Track0[2], "AiRBOOT", 7)!=0)
        return;                             // No AiR-BOOT signature found, so not installed
    // MBR and AiR-BOOT signature found...
    TotalCodeSectorsUsed = Track0[0x10];                                          // 34h/52 in v1.06
    SectorPtr = &Track0[1 * BYTES_PER_SECTOR]; // Start at sector 2
    // Calculate checksum of code-sectors
    while (TotalCodeSectorsUsed>0) {
        Checksum = GetChecksumOfSector(Checksum, SectorPtr);
        SectorPtr += BYTES_PER_SECTOR;
        TotalCodeSectorsUsed--;
    }
    if (Checksum!=*(PUSHORT) &Track0[0x11]) {
        Status_Code = STATUS_CORRUPT;
        return;                                      // Bad checksum for code
    }
    // Checksum fine...
    Installed_LanguageID  = Track0[0x0F];
    Installed_CodeVersion = (Track0[0x0D] << 8) | Track0[0x0E];
    if (Installed_CodeVersion < Bootcode_Version)
        Status_Code = STATUS_INSTALLEDMGU;                                         // Do upgrade
    else
        Status_Code = STATUS_INSTALLED;                                            // Same version installed

    return;
}


void Status_CheckConfig (void) {
    PCHAR  ConfigSectorPtr = &Track0[CONFIG_OFFSET];                              // Config sector offset hard-coded !
    PCHAR  SectorPtr = NULL;
    USHORT Checksum = 0;
    USHORT ConfigChecksum = 0;
    USHORT SectorCount = 0;

    /*
    // Note that the 'AiRCFG-TABLE' string includes the invisible 0xAD char.
    */
    if (strncmp(ConfigSectorPtr, "AiRCFG-TABLE­", 13)==0) {
        // AiR-BOOT signature found...
        SectorPtr = &Track0[54 * BYTES_PER_SECTOR];                                // Start at sector 55
        ConfigChecksum = *(PUSHORT)&Track0[54 * BYTES_PER_SECTOR + 20];
        // Remove checksum
        *(PUSHORT)&Track0[54 * BYTES_PER_SECTOR + 20] = 0;                         // Config sector secnum hard-coded !

        /*
        // Rousseau: # Keep compatible with v1.07 CRC #
        // AB v1.07 had bugs in writing the wrong number of AB config sectors.
        // This is fixed in v1.0.8 but the CRC has to be calculated the "v1.07 way"
        // otherwise v1.07 SET(A)BOOT and INSTALL2.EXE will think the AB config
        // is corrupted.
        // So the CRC is calculated over 5 sectors instead of 7.
        */
        SectorCount = 5;

        while (SectorCount>0) {
            Checksum = GetChecksumOfSector(Checksum, SectorPtr);
            SectorPtr += BYTES_PER_SECTOR;
            SectorCount--;
        }
        // Restore checksum
        *(PUSHORT) &Track0[54 * BYTES_PER_SECTOR + 20] = ConfigChecksum;            // Config sector secnum hard-coded !
        if (Checksum != ConfigChecksum) {
            Status_Config = STATUS_CORRUPT;
            return;
        }
        // Checksum fine
        Installed_ConfigVersion = (Track0[54 * BYTES_PER_SECTOR + 0x0D] << 8) | Track0[54 * BYTES_PER_SECTOR + 0x0E];
        if (Installed_ConfigVersion >= Bootcode_ConfigVersion) {
            Status_Config = STATUS_INSTALLED;
            return;
        }
        Status_Config = STATUS_INSTALLEDMGU;

        // Abort if unknown installed config version.
        if ((Installed_ConfigVersion > 0x110)) {
            if (!Option_CID) {
                printf("\n");
                printf("Configuration version of installed AiR-BOOT not supported by this installer !\n");
                printf("\n");
            }
            exit(1);
        }

        // Abort if unknown to-install config version.
        if ((Bootcode_ConfigVersion > 0x110)) {
            if (!Option_CID) {
                printf("\n");
                printf("Configuration version of new AiR-BOOT.BIN not supported by this installer !\n");
                printf("\n");
            }
            exit(1);
        }


        // Those upgrades will copy useful configuration data to the image config
        // If new configuration data was added, those spaces are not overwritten
        // Sector 60 (MBR-BackUp) *MUST BE* copied, otherwise it would be lost.
        // Rousseau: Upgrade from v0.27
        if (Installed_ConfigVersion <= 0x27) {
            // UPGRADE v0.27 and prior versions

            // Sector 55
            // Changes: Offset  69 length 75 - Linux command line
            //          Offset 144 length  1 - Linux kernel partition
            //          Offset 145 Length 11 - Default kernel name
            //          Offset 156 Length  1 - Kernel name terminator 1
            //          Offset 157 Length 11 - Last kernel name
            //          Offset 168 Length  1 - Kernel name terminator 2
            //          Offset 169 Length  1 - Ext. partition M$-hack enable
            //           -> Total-length 101
            //          Offset 432 Length 34 - New IPT entry (BIOS continued)
            memcpy(&Bootcode[54 * BYTES_PER_SECTOR + 16], &Track0[54 * BYTES_PER_SECTOR + 16], 69 - 16);    // CHECKEN !!
            memcpy(&Bootcode[54 * BYTES_PER_SECTOR + 466], &Track0[54 * BYTES_PER_SECTOR + 466], 46);       // CHECKEN !!
            // Sector 56-57 no changes
            memcpy(&Bootcode[55*512], &Track0[55 * BYTES_PER_SECTOR], 1024);
            // Sector 58-59
            // Changes: Offset 900 Length 30 - Logical driveletter table
            memcpy(&Bootcode[57 * BYTES_PER_SECTOR], &Track0[57 * BYTES_PER_SECTOR], 900);               // AANPASSEN 900 !!
            // Sector 60 copy unmodified
            memcpy(&Bootcode[59 * BYTES_PER_SECTOR], &Track0[59 * BYTES_PER_SECTOR], BYTES_PER_SECTOR);  // CHECKEN !!
            return;
        }
        // Rousseau: Upgrade from v0.91
        if (Installed_ConfigVersion <= 0x91) {
            // UPGRADE v0.91 and prior versions
            // Sector 55-57 no changes
            memcpy(&Bootcode[54 * BYTES_PER_SECTOR + 16], &Track0[54 * BYTES_PER_SECTOR + 16], BYTES_PER_SECTOR + 1024 - 16);   // CHACKEN !!
            // Sector 58-59
            // Changes: Offset 900 Length 30 - Logical driveletter table
            memcpy(&Bootcode[57 * BYTES_PER_SECTOR], &Track0[57 * BYTES_PER_SECTOR], 900);               // AANPASSEN 900 !!
            // Sector 60/62 copy unmodified
            memcpy(&Bootcode[59 * BYTES_PER_SECTOR], &Track0[59 * BYTES_PER_SECTOR], BYTES_PER_SECTOR);
            return;
        }


        // UPGRADE to v1.06 format.
        // We don't need to "upgrade" the configuration to move to v1.06, we simply copy it over.
        // From Sector 55, 6 sectors in total but never header/version.
        // Rousseau: We copy two more sectors (8 in total) in the extended (45 partition) version.
        switch (IMAGE_SIZE) {
            case IMAGE_SIZE_60SECS: {
                memcpy(&Bootcode[54 * BYTES_PER_SECTOR + 16], &Track0[54 * BYTES_PER_SECTOR + 16], BYTES_PER_SECTOR * 6 - 16);
                break;
            }
            case IMAGE_SIZE_62SECS: {
                memcpy(&Bootcode[54 * BYTES_PER_SECTOR + 16], &Track0[54 * BYTES_PER_SECTOR + 16], BYTES_PER_SECTOR * 8 - 16);
                break;
            }
        }

        /*
        // Convert v1.06 hideparttable (30x30) to the v1.07 (30x45) format.
        // Also copy drive-letters to either v1.07 or v1.0.8+ location.
        */
        if ((Installed_ConfigVersion == 0x102) && (Bootcode_ConfigVersion >= 0x107)) {
            int     i,j;
            char    c;
            //printf("Converting 1.06 -> 1.07 hidepart");
            // Copy old hide-part table to new location.
            memcpy(&Bootcode[0x7400], &Track0[0x7200], 900);
            // Setup temporary table.
            memset(TempHidPartTable, 0xff, 45 * 34);
            // Copy old hide-part table to temporary table.
            for (i=0; i<30; i++) {
                for (j=0; j<30; j++) {
                    c = Bootcode[0x7400+i*30+j];
                    TempHidPartTable[i*45+j] = c;
                }
            }
            // Copy temporary table to final v1.07 location.
            memcpy(&Bootcode[0x7400], TempHidPartTable, 30 * 45);

            // Clear drive-letters if version being installed is v1.07.
            if (Bootcode_ConfigVersion == 0x107) {
                memset(&Bootcode[0x7946], 0, 45);
            }

            // Copy over drive-letters from v1.06 location to v1.08+ location.
            if ((Bootcode_ConfigVersion >= 0x108) && (Bootcode_ConfigVersion <= 0x110)) {
                memset(&Bootcode[0x6cb0], 0, 45);
                memcpy(&Bootcode[0x6cb0], &Track0[0x7584], 30);
            }
        }

        /*
        // Convert v1.07 hideparttable (30x45) to a packed v1.0.8+ (45x45) format.
        */
        if ((Installed_ConfigVersion < 0x108) && (Bootcode_ConfigVersion <= 0x110)) {
            int     i,j;
            char    c;
            //printf("Converting to 1.08 packed hidepart");
            // Setup temporary table.
            memset(TempHidPartTable, 0xff, 45 * 34);

            // Copy old hide-part table to temporary table.
            // Unpacked table is 30 rows with 45 columns per row.
            // Packed table is 45 rows with 45 columns per row packed in 34 bytes.
            for (i=0; i<30; i++) {
                for (j=0; j<45; j++) {
                    c = Bootcode[0x7400+i*45+j];                            // Get unpacked value
                    c = set_bitfield(&TempHidPartTable[i*34], j, 6, c);     // Store 6-bit packed value
                }
            }
            // Copy temporary table to final v1.0.8+ location (packed format)
            memcpy(&Bootcode[0x7400], TempHidPartTable, 45 * 34);
            // Show LVM Drive Letters.
            Bootcode[0x6c17] = 1;
        }

        return;
    }
    // MKW:
    // Check for prior v0.26 signature
    // not supported in C version anymore
    // Don't have this version here for testing and I can't risk breaking
    // configuration
    return;
}

// Checks partition table for valid data
BOOL Virus_CheckThisMBR (PCHAR MBRptr) {                                         // Rousseau: adjusted this function
    USHORT PartitionNo;
    ////ULONG  CHSStart, CHSEnd;

    //printf("DEBUG: Virus_CheckThisMBR\n");

    if (*(PUSHORT)(MBRptr + BYTES_PER_SECTOR - 2)!=0x0AA55)
        return FALSE;

    //printf("DEBUG: Virus_CheckThisMBR - Checking Partitions\n");

    MBRptr += 446;
    for (PartitionNo=0; PartitionNo<4; PartitionNo++) {
        if (*(MBRptr+4) != 0) {
            /*
            // Rousseau 2011-02-04: ## Check for GPT ##
            */
            if (*(MBRptr+4) == GPT) {
                if (!Option_CID) {
                    printf("ERROR: This drive is partitioned with the modern GPT layout.\n");
                    printf("       AiR-BOOT is currently unable to handle GPT partitioned drives.\n");
                    printf("       Installation aborted, no changes made.\n");
                }
                exit(2);
            }

            /*
            // Rousseau: 2011-05-05
            //           Last minute change to have AB install on a disk
            //            with nopartitions on the it.  (check !)
            //           It still checks for GPT but will skip the check below.
            */
            continue;

            //printf("DEBUG: Virus_CheckThisMBR - Partition: %d\n", PartitionNo);
            // Partition-type defined, analyse partition data
            ////CHSStart = (*(MBRptr+3) | ((*(MBRptr+2) >> 6) << 8)) << 16;             // Cylinder
            ////CHSStart |= (*(MBRptr+2) & 0x3F) | ((*(MBRptr+1) << 8));                // Sector / Head
            //printf("DEBUG: Virus_CheckThisMBR - CHSStart: %d\n", CHSStart);                               // 3F MASK CHECKEN !!

            ////CHSEnd = (*(MBRptr+7) | ((*(MBRptr+6) >> 6) << 8)) << 16;               // Cylinder
            ////CHSEnd |= (*(MBRptr+6) & 0x3F) | ((*(MBRptr+5) << 8));                  // Sector / Head
            //printf("DEBUG: Virus_CheckThisMBR - CHSEnd: %d\n", CHSEnd);


            /*
            // Rousseau 2011-02-03: ## Changed below from < to <= ##
            // When a partition is above 1024x255x63 (8GiB) the start and end of the partition
            // in the MBR is the same (1024/255/63) to indicate extended CHS-values.
            // This made the installer see this as a non-valid entry.
            // Fixme: This could use some further optimazation like checking if CHS is really 1024/255/63
            //        to exclude truly faulty partition-entries.
            //        Also depends on conventions: IBM,MS,Partition Magic,...
            */
            /*if (CHSStart<CHSEnd) {*/
            ////if (CHSStart<=CHSEnd) {
            ////   if (*(PULONG)(MBRptr+12)!=0) // Absolute length > 0?
            ////      return TRUE;
            ////}
        }
    // Go to next partition
    MBRptr += 16;
    }
    // No partitions defined/no valid partitions found
    // Rousseau: Still return TRUE (OK)
    //return FALSE;
    return TRUE;
}

BOOL Virus_CheckCurrentMBR (void) {
    return Virus_CheckThisMBR((PCHAR) Track0);
}

BOOL Virus_CheckForBackUpMBR (void) {
    BOOL    bMbrBackup = FALSE;

    // All versions above v1.06 have expanded tables so the MBR-backup
    // is located 2 sectors higher in the track0 image.
    if (Installed_ConfigVersion <= 0x0106)
        bMbrBackup = Virus_CheckThisMBR((PCHAR) &Track0[59 * BYTES_PER_SECTOR]);
    else
        bMbrBackup = Virus_CheckThisMBR((PCHAR) &Track0[61 * BYTES_PER_SECTOR]);

    return bMbrBackup;
}

BOOL Virus_CheckForStealth (void) {
    PCHAR  CurPtr = (PCHAR) Track0;
    USHORT i;

    for (i=0; i<511; i++) {
        if (*(PUSHORT)CurPtr == 0x13CD) return FALSE;
        CurPtr++;
    }
    // No CD13h found? possible stealth
    return TRUE;
}

// Copies backup MBR into current MBR on current memory copy of track 0
// Rousseau: Two sectors higher in the extended version.
void Virus_CopyBackUpMBR (void) {
    switch (IMAGE_SIZE) {
        case IMAGE_SIZE_60SECS: {
            memcpy(Track0, &Track0[59 * BYTES_PER_SECTOR], BYTES_PER_SECTOR);      // sector 60
            break;
        }
        case IMAGE_SIZE_62SECS: {
            memcpy(Track0, &Track0[61 * BYTES_PER_SECTOR], BYTES_PER_SECTOR);      // sector 62
            break;
        }
    }
}

void Status_PrintF (ULONG Status, USHORT Version) {
    switch (Status) {
        case STATUS_NOTINSTALLED: {
            if (!Option_CID) {
                printf("not installed\n");
            }
            break;
        }
        case STATUS_CORRUPT: {
            if (!Option_CID) {
                printf("not intact\n");
            }
            break;
        }
        case STATUS_INSTALLED:
        case STATUS_INSTALLEDMGU:
            if (!Option_CID) {
                printf("intact (v%x.%1d.%1d)", Version>>8, (Version & 0x0F0)>>4, Version & 0x0F);
            }
            if (Status==STATUS_INSTALLEDMGU)
                if (!Option_CID) {
                printf(", but may be updated");
                }
            if (!Option_CID) {
                printf("\n");
            }
            break;

        case STATUS_IMPOSSIBLE:
            if (!Option_CID) {
                printf(ImpossibleCause);
            }
            break;
    }
}

void Language_PrintF(UCHAR LanguageID) {
    if (Option_CID)
        return;
    switch (LanguageID) {
        case 'E': printf("english");    break;
        case 'N': printf("dutch");      break;      // Changed from 'D' to 'N'
        case 'G': printf("german");     break;
        case 'F': printf("french");     break;
        case 'I': printf("italian");    break;
        case 'R': printf("russian");    break;
        case 'S': printf("swedish");    break;
        default:  printf("unknown");
    }
}

// Doesn't actually write code/config, but writes it to track0 memory
void Install_WriteCode (void) {
    USHORT TotalCodeSectorsUsed = 0;
    USHORT SectorCount = 0;
    USHORT Checksum = 0;
    PCHAR  SectorPtr = NULL;

    // Calculate checksum for code...
    TotalCodeSectorsUsed = Bootcode[0x10];                                        // SECTORS USED CHECKEN !! (34h / 52d in v1.06)
    SectorPtr = &Bootcode[1 * BYTES_PER_SECTOR]; // Start at sector 2
    SectorCount = TotalCodeSectorsUsed;
    while (SectorCount>0) {
        Checksum = GetChecksumOfSector(Checksum, SectorPtr);
        SectorPtr += BYTES_PER_SECTOR;
        SectorCount--;
    }
    *(PUSHORT)&Bootcode[0x11] = Checksum;

    // Copy MBR till offset 0x1B8 (Windows NT hdd signature location)
    memcpy(Track0, Bootcode, 0x1B8);

    // Copy over code sectors...
    memcpy(&Track0[BYTES_PER_SECTOR], &Bootcode[BYTES_PER_SECTOR], TotalCodeSectorsUsed * BYTES_PER_SECTOR);
}

void Install_WriteConfig (void) {
    USHORT SectorCount = 0;
    USHORT Checksum = 0;
    PCHAR  SectorPtr = NULL;

#ifdef PLATFORM_OS2
    if (AutoDriveLetter!=0) {
        // Add DriveLetter Automatic veriables, if set
        Bootcode[54 * BYTES_PER_SECTOR + 0x1AB] = AutoDriveLetter;                       // CHECKEN !
        *(PULONG)&Bootcode[54 * BYTES_PER_SECTOR + 0x1AC] = AutoDriveLetterSerial;
    }
#endif

    // Delete current checksum
    *(PUSHORT)&Bootcode[54 * BYTES_PER_SECTOR + 20] = 0;

    SectorPtr = &Bootcode[54 * BYTES_PER_SECTOR];                                 // Start at sector 55

    /*
    // Rousseau: # Keep compatible with v1.07 CRC #
    // AB v1.07 had bugs in writing the wrong number of AB config sectors.
    // This is fixed in v1.0.8+ but the CRC has to be calculated the "v1.07 way"
    // otherwise v1.07 SET(A)BOOT and AIRBOOT2.EXE will think the AB config
    // is corrupted.
    // So the CRC is calculated over 5 sectors instead of 7.
    */
    SectorCount = 5;

    while (SectorCount>0) {
        Checksum = GetChecksumOfSector(Checksum, SectorPtr);
        SectorPtr += BYTES_PER_SECTOR;
        SectorCount--;
    }
    *(PUSHORT)&Bootcode[54 * BYTES_PER_SECTOR + 20] = Checksum;

    // Copy configuration sectors
    // Rousseau: Two more sectors for extended version.
    switch (IMAGE_SIZE) {
        case IMAGE_SIZE_60SECS: {
            memcpy(&Track0[54 * BYTES_PER_SECTOR], &Bootcode[54 * BYTES_PER_SECTOR], 6 * BYTES_PER_SECTOR);
            break;
        }
        case IMAGE_SIZE_62SECS: {
            memcpy(&Track0[54 * BYTES_PER_SECTOR], &Bootcode[54 * BYTES_PER_SECTOR], 8 * BYTES_PER_SECTOR);
            break;
        }
    }

    return;
}


void    DumpTrack0() {
    int i,j;
    for (i=27; i<32; i++) {
        for (j=0; j<16; j++) {
            printf("%02X",Track0[i*16+j]);
        }
        printf("\n");
    }
}




void    DoDebug() {
    USHORT  t0codv  = 0;
    USHORT  t0cfgv  = 0;
    USHORT  bccodv  = 0;
    USHORT  bccfgv  = 0;

    //do_bf_test();

    printf("\nHardisks : %d\n", CountHarddrives());
    printf("\nGEO      : %d\n", HarddriveCheckGeometry());
    printf("\nTrack0   : %d\n", Track0Load());
    printf("\nBootcode : %d\n", LoadBootcodeFromFile());


    // Dump Track0
    DumpTrack0();
    printf("\n\n");
    // Dump Bootcode
    //~ {
        //~ int i;
        //~ for (i=0; i<512; i++) {
            //~ printf("%02X",Bootcode[i]);
        //~ }
    //~ }
    //~ printf("\n\n");

    t0codv = Track0[13] << 8 | Track0[14];
    printf("t0codv : %04X\n", t0codv);

    t0cfgv = Track0[0x6c00+13] << 8 | Track0[0x6c00+14];
    printf("t0cfgv : %04X\n", t0cfgv);

    bccodv = Bootcode[13] << 8 | Bootcode[14];
    printf("bccodv : %04X\n", bccodv);

    bccfgv = Bootcode[0x6c00+13] << 8 | Bootcode[0x6c00+14];
    printf("bccfgv : %04X\n", bccfgv);

    return;

}


// ============================================================================
//  Main Entrypoint
// ============================================================================



#define MAXCMDPARMLEN 11

int main (int argc, char **argv) {
    ULONG   CurArgument     = 0;
    size_t  ArgumentLen     = 0;
    PCHAR   StartPos        = 0;
    UCHAR   UserKey         = ' ';
    BOOL    ExitOnly        = FALSE;
    CHAR    TempSpace[MAXCMDPARMLEN+1];


    // Check commandline parameters
    CurArgument = 1;
    while (CurArgument<argc) {
        StartPos = argv[CurArgument];
        ArgumentLen = strlen(StartPos);

        if (((*StartPos=='-') || (*StartPos=='/')) && (ArgumentLen>1)) {
            StartPos++; ArgumentLen--;
            if (ArgumentLen>MAXCMDPARMLEN)
                ArgumentLen = MAXCMDPARMLEN;
            strncpy((char *) TempSpace, StartPos, ArgumentLen);
            TempSpace[ArgumentLen] = 0;
            StartPos = (PCHAR) TempSpace;
            while (*StartPos!=0) {
                *StartPos = tolower(*StartPos); StartPos++;
            }
            if (strcmp((char *) TempSpace, "forcecode")==0) Option_ForceCode = TRUE;
            if (strcmp((char *) TempSpace, "forceconfig")==0) Option_ForceConfig = TRUE;
            if (strcmp((char *) TempSpace, "silent")==0) Option_Silent = TRUE;
            if (strcmp((char *) TempSpace, "cid")==0) Option_CID = TRUE;
        }
        CurArgument++;
    }


// Only support /cid on OS/2 for the moment.
// The DOS code behaves quirky with /cid and Win32 is not tested at all.
#ifndef PLATFORM_OS2
    Option_CID = FALSE;
#endif

    if (Option_CID) {
        Option_Silent = TRUE;
    }


    // Show header.
    if (!Option_CID) {
        printf("AiR-BOOT Installer v%s.%s.%s for %s\n",
            BLDLVL_MAJOR_VERSION,
            BLDLVL_MIDDLE_VERSION,
            BLDLVL_MINOR_VERSION,
            PLATFORM_NAME);
        printf(" - (c) Copyright 1998-2012 by Martin Kiewitz.\n");
        printf("\n-> ...Please wait... <-\n");
    }


    // Allocate buffers for Track0 and 'airboot.bin'.
    Track0 = malloc(SECTOR_COUNT * BYTES_PER_SECTOR);
    Bootcode = malloc(SECTOR_COUNT * BYTES_PER_SECTOR);


    // Exit of allocation failed.
    if (!(Track0 && Bootcode)) {
        if (!Option_CID) {
            printf("- Unable to allocate enough memory, operation aborted!\n");
        }
        exit(4);
    }


    //~ DoDebug();
    //~ exit(0);


#ifdef PLATFORM_WINNT
    if (CheckWindowsVersion()==FALSE)
        return 1;
#endif

    if (CountHarddrives()==0) {
        if (!Option_CID) {
            printf(" - No physical drives found on this system. Install impossible.\n");
        }
        return 3;   // Rouseau: changed from 1 to 3
    }

    if (!Option_CID) {
        printf(" - Loading bootcode from file...");
    }

    if (LoadBootcodeFromFile()==FALSE)
        return 1;

    if (!Option_CID) {
        printf("ok\n");
    }

    if (!Option_CID) {
        printf(" - Loading MBR from harddisc...");
    }


    if (!Track0Load()) {
        if (!Option_CID) {
            printf("LOAD ERROR!\n");
        }
        return 1;
    }
    else {
       if (!Option_CID) {
            printf("ok\n");
        }
    }

    if (!HarddriveCheckGeometry()) {
        // No EZ-SETUP check here, because we are under 32-bit OS and this
        //  wouldn't make any sense
        //printf("\nDEBUG: STATUS_IMPOSSIBLE\n");
        Status_Code = STATUS_IMPOSSIBLE;
        ImpossibleCause = "unable to install\n   Your harddisc does not have at least 63 sectors per track.";
    }


    if (!Option_CID) {
        printf("\n-> ...Current Status... <-\n");
    }

    Status_CheckCode();
    if (!Option_CID) {
        printf(" - AiR-BOOT is ");
    }
    Status_PrintF(Status_Code, Installed_CodeVersion);
    if (Status_Code==STATUS_IMPOSSIBLE)
        return 1;
    Status_CheckConfig();
    if (!Option_CID) {
        printf(" - Configuration is ");
    }
    Status_PrintF(Status_Config, Installed_ConfigVersion);
    // Display language as well, if code installed
    if ((Status_Code==STATUS_INSTALLED) || (Status_Code==STATUS_INSTALLEDMGU)) {
        if (!Option_CID) {
            printf(" - Language is ");
        }
        Language_PrintF(Installed_LanguageID);
        if (!Option_CID) {
            printf("\n");
        }
    }

    // =============================================================
    //  PRE-CHECKING, WHAT WE ARE SUPPOSED TO DO...
    // =============================================================
    if ((Option_ForceCode) || (Status_Code!=STATUS_INSTALLED) || (Installed_LanguageID!=Bootcode_LanguageID))
        Install_Code = TRUE;  // If LanguageID different or not installed
    if ((Option_ForceConfig) || (Status_Config!=STATUS_INSTALLED))
        Install_Config = TRUE; // If not installed

    if ((Status_Code==STATUS_CORRUPT) || (Status_Config==STATUS_CORRUPT))
        Install_IsCorrupt = TRUE; // If anything is corrupt

    // =============================================================
    //  VIRUS
    // =============================================================
    // If-Table
    // ---------
    //  Code==not installed, Config=not installed -> Check MBR
    //  Code==installed, config==installed -> Check MBR (-> Virus?)
    //  Code==not installed, config==installed -> (-> Virus?)
    //  Code==installed, config==not installed -> Check MBR (-> Virus?)

    //printf("DEBUG: Status_Code: %d, Status_Config: %d\n", Status_Code, Status_Config);  // Rousseau: DEBUG

    if ((Status_Code==STATUS_NOTINSTALLED) & (Status_Config==STATUS_NOTINSTALLED)) {
        // Nothing installed, so check MBR, if squashed...
        if (!Virus_CheckCurrentMBR()) {
            if (!Option_CID) {
                printf("\n\n");
                printf("AiR-BOOT detected that the data on your harddisc got damaged.\n");
                printf("If you had AiR-BOOT installed before: the corruption killed AiR-BOOT completly!\n");
                printf("Installation halted.\n");
            }
            return 255; // Rousseau: changed from 1 to 255
        }
        //printf("DEBUG: Installing...\n");                                               // Rousseau: DEBUG
    }
    else {
        if ((Status_Code==STATUS_NOTINSTALLED) | (!Virus_CheckCurrentMBR())) {
            // Code not installed, but Config or MBR squashed...
            //  -> Virus proposed, check for backup (if available)
            if (!Option_CID) {
                printf("\n\n");
                printf("-> ...!ATTENTION!... <-\n");
            }
            if (Virus_CheckForStealth())
                if (!Option_CID) {
                    printf("Your system GOT infected by a stealth-virus (or your MBR got trashed).\n");
                }
            else
                if (!Option_CID) {
                    printf("Probably your system was infected by a virus.\n");
                    printf("Repairing AiR-BOOT will normally squash the virus.\n");
                    printf("But to be sure it's gone, you should check your harddisc using a virus-scanner.\n");
                }

            if (!Virus_CheckCurrentMBR()) {
                // MBR squashed, so check backup and display message
                if (!Option_CID) {
                    printf("\n");
                    printf("AiR-BOOT detected that the virus has broken your partition-table.\n");
                }
                if (Virus_CheckForBackUpMBR()) {
                    if (!Option_CID) {
                        printf("Good news: AiR-BOOT has found a (hopefully) functional backup.\n");
                        printf("Shall I use this backup, instead of the current active one? (Y/N)\n");
                    }
                    // User selection, Y/N, if he wants to restore MBR
                    //  *NOT* CID (silent) able
                    do {
                        UserKey = getch() | 0x20;
                    } while (!((UserKey=='y') | (UserKey=='n')));
                    if (UserKey=='y')
                        Virus_CopyBackUpMBR();
                }
                else {
                    if (!Option_CID) {
                        printf("Sadly the virus also broke AiR-BOOT's backup. You will have to help yourself.\n");
                    }
                }
            }
        }
    }



    // =============================================================
    //  MAIN-MENU
    // =============================================================
    if (!Option_CID) {
        printf("\n-> ...Please press... <-\n");
    }

    if (!Option_CID) {
        if (Install_IsCorrupt)
            printf(" <R> - Repair AiR-BOOT ");
        else
            if (Status_Code==STATUS_NOTINSTALLED)
                printf(" <A> - Add AiR-BOOT ");
            else
                printf(" <U> - Update/Change AiR-BOOT to ");

        printf("'v%x.%1d.%1d/", Bootcode_Version>>8, (Bootcode_Version & 0x0F0)>>4, Bootcode_Version & 0x0F);
        Language_PrintF(Bootcode_LanguageID);
        printf("' on current system\n");

        printf(" <D> - Delete AiR-BOOT from current system\n");
        printf(" <Q> - Quit without any change\n");
    }



    if (Option_Silent || Option_CID) {
        // Silent operation? Always add AiR-BOOT then
        UserKey = 'a';
    }
    else {
        do {
            UserKey = getch() | 0x20;
        } while (!((UserKey=='a') || (UserKey=='r') || (UserKey=='u') || (UserKey=='d') || (UserKey=='q')));
    }

    if (!Option_CID) {
        printf("\n\n\n-------------------------------------------------------------------------------\n");
    }

    switch (UserKey) {
        case 'a':
        case 'r':
        case 'u': {
            if (Install_Code || Install_Config) {
                if (!Option_CID) {
                    printf("Add/Repair/Update AiR-BOOT in progress...\n");
                }
#ifdef PLATFORM_OS2
                OS2_GetBootAutoDriveLetter();
#endif
                if (Install_Code) {
                    if (!Option_CID) {
                        printf(" þ Writing AiR-BOOT code...");
                    }
                    //~ DumpTrack0();
                    Install_WriteCode();
                    //~ DumpTrack0();
                    if (!Option_CID) {
                        printf("ok\n");
                    }
                }
                if (Install_Config) {
                    if (!Option_CID) {
                        printf(" þ Writing AiR-BOOT configuration...");
                    }
                    Install_WriteConfig();
                    if (!Option_CID) {
                        printf("ok\n");
                    }
                }


                if (!Track0Write()) {
                    if (!Option_CID) {
                        printf("SAVE ERROR!\n");
                    }
                    return 1;
                }

                if (!Option_CID) {
                    printf("\n");
                    printf("Your copy of AiR-BOOT is now fully functional.\n");
                    if (!Option_Silent) {
                        printf("Please hit ESC to exit AiR-BOOT installer or ENTER to reboot your system...\n");
                    }
                }
                if (Option_Silent || Option_CID) {
                    // Silent operation? Always reboot system (shall we do this really?)
                    // No, otherwise installing from MiniLVM will reboot the system
                    // which is not what the user would expect.
                    //UserKey = 0x0D;
                    UserKey = 0x1B;
                }
                else {
                    do {
                        UserKey = getch();             // React on ENTER or ESC
                    } while (!((UserKey==0x0D) || (UserKey==0x1B)));
                }
                if (UserKey==0x0D) {              // ENTER reboots system... (if not in OS/2 install mode)

                    /*
                    // Rousseau: ## Disable Reboot when installing eComStation ##
                    // In the install-environment, the MEMDRIVE env-var is defined.
                    // So, only reboot if this env-var is not defined.
                    */
                    if (!getenv("MEMDRIVE")) {
                        if (!Option_CID) {
                            printf("Now rebooting system...\n");
                        }
                        RebootSystem();
                    }
                    ExitOnly = TRUE;
                }
            }
            else {
                if (!Option_CID) {
                    printf(" þ All components of AiR-BOOT are intact and up-to-date. Nothing to do.\n");
                }
                ExitOnly = TRUE;
            }
            break;
        }
        case 'd': {
            if (!Option_CID) {
                printf(" þ Removing AiR-BOOT automatically is not possible at this time.\n");
            }
#ifdef PLATFORM_OS2
            if (!Option_CID) {
                printf("    You may remove AiR-BOOT manually by entering \"FDISK /MBR\" or \"LVM /NEWMBR:1\"\n");
                printf("    in commandline.\n");
            }
#endif
#ifdef PLATFORM_WINNT
            if (!Option_CID) {
                printf("    You may remove AiR-BOOT manually by entering \"FDISK /MBR\" in commandline.\n");
            }
#endif
            ExitOnly = TRUE;
            break;
        }
        default:
        break;
    }

    if (ExitOnly) {
        if (!(Option_CID || Option_Silent)) {
            printf("\n");
            printf("Please hit ENTER to exit AiR-BOOT installer...\n");
            while (getch()!=0x0D);
        }
    }

    // Free the buffer memory.
    if (Track0)     free(Track0);
    if (Bootcode)   free(Bootcode);

   return 0;
}
