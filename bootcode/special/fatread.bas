$COMPILE EXE

Type LINUXIMG_13EXT_ControlType
   SizePaket       as WORD
   NumBlocks       as WORD
   Transfer        as DWORD
   Absolut         as DWORD
   Absolut2        as DWORD
End Type

Dim LINUXIMG_13EXT_Control             as shared LINUXIMG_13EXT_ControlType
Dim LINUXIMG_13EXT_ControlPtr          as shared DWORD
LINUXIMG_13EXT_ControlPtr = VarPtr32(LINUXIMG_13EXT_Control)
LINUXIMG_13EXT_Control.SizePaket = &h10

! mov   ah, &h41
! mov   bx, &h55AA
! mov   dl, &h80
! int   &h13
! cmp   bx, &h0AA55
! je    LINUXIMG_13EXT_Found
LINUXIMG_13EXT_NotFound:
print "þ INT 13h Extensions not found, you won't need this tool"
end

LINUXIMG_13EXT_Found:
! and   cx, 1
! jz    LINUXIMG_13EXT_NotFound
print "þ INT 13h Extensions found"

AbsPartitionBegin??? = 2618595
'AbsPartitionBegin??? = 16065+63
BootRecord$        = LINUXIMG_13EXT_ReadSector (&h80, AbsPartitionBegin???)
SectorsPerCluster? = CvByt(BootRecord$,14)
ReservedSectors??  = CvWrd(BootRecord$,15)
FATcopies?         = CvByt(BootRecord$,17)
NumOfRootEntries?? = CvWrd(BootRecord$,18)
SectorsPerFAT??    = CvWrd(BootRecord$,23)
print ReservedSectors??, FATcopies?, NumOfRootEntries??, SectorsPerFAT??, SectorsPerCluster?

FATstart???        = AbsPartitionBegin???+ReservedSectors??
RootStart???       = FATstart???+(FATcopies?*SectorsPerFAT??)
ClusterStart???    = RootStart???+NumOfRootEntries??/16

CurEntry?? = 0: RootSector?? = 0
Do
   RootTable$         = LINUXIMG_13EXT_ReadSector (&h80, RootStart???+RootSector??)
   LocalEntry?? = 0
   Do
      If Mid$(RootTable$,LocalEntry??*32+1,11) = "KERNELS    " Then
         KernelDirFound% = -1
        else
         Incr LocalEntry??
      End If
   Loop Until KernelDirFound% or LocalEntry??=>16
   Incr RootSector??: Incr CurEntry??, 16
   if inkey$<>"" Then End
Loop Until KernelDirFound% or CurEntry??=NumOfRootEntries??

If KernelDirFound% Then
   DirFlags? = CvByt(RootTable$,LocalEntry??*32+12)
   If DirFlags?=&h10 Then print "Valid Directory!"
   ClusterStart?? = CvWrd(RootTable$,LocalEntry??*32+27)
   print "Cluster start: ";ClusterStart??
   print "Next Cluster: ";GetNextCluster(FATstart???, ClusterStart??)

   DirCluster$ = GetClusterData (ClusterStart???, SectorsPerCluster?, ClusterStart??)
   ClusterStart?? = CvWrd(DirCluster$,2*32+27)
   print GetClusterData (ClusterStart???, SectorsPerCluster?, ClusterStart??)
End If
end

Function GetClusterData (byval ClusterStart???, byval SectorsPerCluster?, byval ClusterNo??) as STRING
   ClusterPos??? = (ClusterNo??-2)*SectorsPerCluster?

   ClusterData$      = LINUXIMG_13EXT_ReadSector (&h80, ClusterStart???+ClusterPos???)
   FUNCTION = ClusterData$
End Function

Function GetNextCluster (byval FATstart???, byval CurCluster??) as WORD
   FATpos??    = (CurCluster?? mod 256)
   FATsector?? = (CurCluster??-FATpos??)/256
   FATpos??    = FATpos??*2

   FATtable$         = LINUXIMG_13EXT_ReadSector (&h80, FATstart???+FATsector??)
   NextCluster??     = CvWrd(FATtable$, FATpos??+1)

   FUNCTION = NextCluster??
End Function

Function LINUXIMG_13EXT_ReadSector (byval Harddrive??, byval BlockNo???) as STRING
   local MyBlock$
   MyBlock$ = String$(512,0)
   LINUXIMG_13EXT_Control.NumBlocks   = 1
   LINUXIMG_13EXT_Control.Transfer    = StrPtr32(MyBlock$)
   LINUXIMG_13EXT_Control.Absolut     = BlockNo???
   ! push  ds
   ! mov   dl, Harddrive??
   ! lds   si, LINUXIMG_13EXT_ControlPtr
   ! mov   ah, &h42
   ! int   &h13
   ! pop   ds
   ! jc    LINUXIMG_13EXT_Error
   FUNCTION = MyBlock$
   Exit Function

  LINUXIMG_13EXT_Error:
   print "Error in partition-table/Bad sector on harddisc."
   end
End Function

Sub LINUXIMG_13EXT_WriteSectors (byval Harddrive??, byval BlockNo???, byval DataBlock$)
   local MyBlock$
   If len(DataBlock$)<5120 Then
      DataBlock$ = DataBlock$ + String$(5120-len(DataBlock$),0)
   End If
   LINUXIMG_13EXT_Control.NumBlocks   = 10
   LINUXIMG_13EXT_Control.Transfer    = StrPtr32(DataBlock$)
   LINUXIMG_13EXT_Control.Absolut     = BlockNo???
   ! push  ds
   ! mov   dl, Harddrive??
   ! lds   si, LINUXIMG_13EXT_ControlPtr
   ! mov   ah, &h43                   ; Write !
   ! int   &h13
   ! pop   ds
   ! jc    LINUXIMG_13EXT_ErrorWrite
   Exit Sub

  LINUXIMG_13EXT_ErrorWrite:
   print "Error, while writing to disc."
   end
End Sub
