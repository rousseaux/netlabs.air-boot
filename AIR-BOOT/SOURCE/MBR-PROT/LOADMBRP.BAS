$INCLUDE "PIC.inc"

Open "mbr_prot.com" For BINARY As #1
Get$ #1, 32000, Image$
Close #1

Def Seg=&h9FC0
Poke$ 0, Image$

Dim MyPointer  as DWORD

! mov  ax, 9
! mov  MyPointer[00], ax
! mov  ax, &h9FC0
! mov  MyPointer[02], ax

Pokei 0, &h42FC
Pokei 2, &hDEC6
Pokei 4, &h01C5
Pokei 6, &h70

PIC_SetINT &h13, MyPointer

