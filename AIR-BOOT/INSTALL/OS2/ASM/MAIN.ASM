.386p
.model flat, SYSCALL
assume CS:FLAT, DS:FLAT, ES:FLAT, SS:FLAT

include stdmacro.inc
include extern.inc
include airb_msg.inc

;******************************************************************************
;* Global data segment, accessible across all instances.
;*
;* Watcom compiler apparently stuffs all the data segs into DGROUP, so it is
;* necessary to define this segment seperately in asm
;*
;******************************************************************************

DATA                    SEGMENT DWORD USE32 PUBLIC 'DATA' ; Global data
   include ..\..\GLOBAL.ASM\Const.asm
   include ..\..\GLOBAL.ASM\Glob_Var.asm
DATA                    ENDS


;******************************************************************************
;* Resident code segment
;*
;******************************************************************************

CODE                    SEGMENT DWORD USE32 PUBLIC 'CODE' ; Code
   include Status.asm
   include Proc_Add.asm
   include Virus.asm
CODE                    ENDS

                        end
