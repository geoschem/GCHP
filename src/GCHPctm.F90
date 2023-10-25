! 

! *********************************************************************
! *****                      Main Program                          ****
! *****                                                            ****
! *****                                                            ****
! *********************************************************************

#define I_AM_MAIN

#include "MAPL_Generic.h"

Program GCHPctm_Main
   use MAPL
   use GCHP_GridCompMod, only:  ROOT_SetServices => SetServices

   implicit none

!EOP

   character(len=18)      :: Iam="GCHP_Main"
   type (MAPL_Cap)        :: cap
   type (MAPL_CapOptions) :: cap_options
   integer                :: status

   cap_options = MAPL_CapOptions(cap_rc_file='CAP.rc')
   cap_options%logging_config = 'logging.yml'
   cap = MAPL_CAP('GCHP', ROOT_SetServices, cap_options=cap_options)
   call cap%run(_RC)
   _VERIFY(status)

 end Program GCHPctm_Main

!EOC
