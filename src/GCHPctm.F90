! 

! *********************************************************************
! *****                      Main Program                          ****
! *****                                                            ****
! *****                                                            ****
! *********************************************************************

#define I_AM_MAIN

#ifdef MAPL3
#include "MAPL.h"
#else
#include "MAPL_Generic.h"
#endif ! MAPL2

Program GCHP_Main

#ifdef MAPL3
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

   _HERE, 'Calling MAPL_Initialize'
   call MAPL_Initialize(hconfig=hconfig, is_model_pet=is_model_pet, &
        servers=servers, configFileNameFromArgNum=1, _RC)
   _HERE, 'Calling run_gchp'
   call run_gchp(hconfig, is_model_pet=is_model_pet, servers=servers, _RC)
   _HERE, 'Calling MAPL_Finalize'
   call MAPL_Finalize(_RC)
   _HERE, 'GCHP_Main success!'

contains

#undef I_AM_MAIN
!#include "MAPL.h" ! ewl: is this needed since also above?

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

#else
  ! MAPL2
  use MAPL
  use GCHP_GridCompMod, only:  ROOT_SetServices => SetServices

  implicit none

  character(len=18)      :: Iam="GCHP_Main"
  type (MAPL_Cap)        :: cap
  type (MAPL_CapOptions) :: cap_options
  integer                :: status

   cap_options = MAPL_CapOptions(cap_rc_file='CAP.rc')
   cap_options%logging_config = 'logging.yml'
   cap = MAPL_CAP('GCHP', ROOT_SetServices, cap_options=cap_options)
   call cap%run(_RC)
   _VERIFY(status)
#endif

 end Program GCHP_Main

