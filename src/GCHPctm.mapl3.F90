!------------------------------------------------------------------------------
! MAPL3 DEVELOPMENT ONLY
!
! This is the main program for GCHP built with MAPL3, which is in development
! and not supported for general use. This file is compiled only if GCHP is
! configured with -DMAPL3=y and is NOT used in standard GCHP builds.
! The operational (MAPL2) version is in GCHPctm.F90.
!------------------------------------------------------------------------------
#ifdef MAPL3
#define I_AM_MAIN
#include "MAPL.h"

program gchp
  use MAPL
  use mapl_CapDriver_mod, only: MAPL_CapCreate, MAPL_CapRun
  use esmf
  implicit none

  integer :: status
  type(MAPL_GriddedComponentDriver) :: driver
  type(ESMF_GridComp), allocatable  :: servers(:)
  type(ESMF_HConfig) :: config

  _HERE, 'GCHP_main started'

  _HERE, 'Calling MAPL_Initialize'
  call MAPL_Initialize(configFileNameFromArgNum=1, app_config=config, _RC)

  _HERE, 'Calling MAPL_CreateServers'
  call MAPL_CreateServers(servers, _RC)

  _HERE, 'Calling MAPL_CapCreate'
  call MAPL_CapCreate(driver, config=config, _RC)

  _HERE, 'Calling MAPL_RunServers'
  call MAPL_RunServers(servers, _RC)

  _HERE, 'Calling MAPL_CapRun'
  call MAPL_CapRun(driver, config=config, _RC)

  _HERE, 'Calling MAPL_Finalize'
  call MAPL_Finalize(_RC)

  _HERE, 'GCHP_main finished'

end program gchp
#endif
