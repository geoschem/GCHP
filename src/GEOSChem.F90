! 

! *********************************************************************
! *****                      Main Program                          ****
! *****                                                            ****
! *****                                                            ****
! *********************************************************************

#define I_AM_MAIN

#include "MAPL_Generic.h"

Program GIGC_Main

   use MAPL_Mod
   use GIGC_GridCompMod, only:  ROOT_SetServices => SetServices

   implicit none

!EOP

   integer           :: STATUS
   character(len=18) :: Iam="GIGC_Main"
   type (MAPL_Cap)   :: cap

   ! Create MAPL_Cap instance and run
   cap = MAPL_CAP('GCHP', ROOT_SetServices, cap_rc_file='CAP.rc')
   call cap%run(_RC)
   _VERIFY(STATUS)

 end Program GIGC_Main

!EOC
