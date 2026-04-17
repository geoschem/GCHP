! 

! *********************************************************************
! *****                      Main Program                          ****
! *****                                                            ****
! *****                                                            ****
! *********************************************************************

#define I_AM_MAIN

! Legacy code (MAPL2):
!!!#include "MAPL_Generic.h"
!!!
!!!Program GCHPctm_Main
!!!   use MAPL
!!!   use GCHP_GridCompMod, only:  ROOT_SetServices => SetServices
!!!
!!!   implicit none
!!!
!!!!EOP
!!!
!!!   character(len=18)      :: Iam="GCHP_Main"
!!!   type (MAPL_Cap)        :: cap
!!!   type (MAPL_CapOptions) :: cap_options
!!!   integer                :: status
!!!
!!!   cap_options = MAPL_CapOptions(cap_rc_file='CAP.rc')
!!!   cap_options%logging_config = 'logging.yml'
!!!   cap = MAPL_CAP('GCHP', ROOT_SetServices, cap_options=cap_options)
!!!   call cap%run(_RC)
!!!   _VERIFY(status)
!!!
!!! end Program GCHPctm_Main

! Implementation using MAPL3:
#include "MAPL.h"

Program GCHPctm_Main
   use mapl3
   use mapl3g_Cap
   use esmf
   use GCHP_GridCompMod, only:  ROOT_SetServices => SetServices

   implicit none

   logical                :: is_model_pet
   integer                :: status
   character(len=18)      :: Iam="GCHP_Main"
   type (ESMF_HConfig)    :: hconfig
   type (ESMF_GridComp), allocatable :: servers(:)

   call MAPL_Initialize(hconfig=hconfig, is_model_pet=is_model_pet, &
        servers=servers, configFileNameFromArgNum=1, _RC)
   call run_gchp(hconfig, is_model_pet=is_model_pet, servers=servers, _RC)
   call MAPL_Finalize(_RC)

contains

#undef I_AM_MAIN
#include "MAPL.h"

   subroutine run_gchp(hconfig, is_model_pet, servers, rc)
      type(ESMF_HConfig),            intent(inout) :: hconfig
      logical,                       intent(in)    :: is_model_pet
      type(ESMF_GridComp), optional, intent(in)    :: servers(:)
      integer,             optional, intent(out)   :: rc

      logical            :: has_cap_hconfig
      integer            :: status
      type(ESMF_HConfig) :: cap_hconfig

      has_cap_hconfig = ESMF_HConfigIsDefined(hconfig, keystring='cap', _RC)
      _ASSERT(has_cap_hconfig, 'No cap section found in configuration file')
      cap_hconfig = ESMF_HConfigCreateAt(hconfig, keystring='cap', _RC)

      call MAPL_run_driver(cap_hconfig, is_model_pet=is_model_pet, servers=servers, _RC)
      call ESMF_HConfigDestroy(cap_hconfig, _RC)

      _RETURN(_SUCCESS)
   end subroutine run_gchp

end program GCHPctm_Main

!EOC
