! 

! *********************************************************************
! *****                      Main Program                          ****
! *****                                                            ****
! *****                                                            ****
! *********************************************************************

#define I_AM_MAIN

#include "MAPL.h"

Program GCHPctm_Main
  use MAPL
  use MAPL_Cap_Mod, only: MAPL_CapCreate, MAPL_CapRun
  use ESMF

  implicit none

  integer           :: status
  character(len=18) :: Iam="GCHP_Main"
  type(MAPL_GriddedComponentDriver) :: driver
  type(ESMF_GridComp), allocatable  :: servers(:)

  _HERE, 'GCHPctm_Main started'
  _HERE, 'Calling MAPL_Initialize'
  call MAPL_Initialize(configFileNameFromArgNum=1, _RC)
  _HERE, 'Calling MAPL_CreateServers'
  call MAPL_CreateServers(servers, _RC)
  _HERE, 'Calling MAPL_CapCreate'
  call MAPL_CapCreate(driver, _RC)
  _HERE, 'Calling MAPL_RunServers'
  call MAPL_RunServers(servers, _RC)
  _HERE, 'Calling MAPL_CapRun'
  call MAPL_CapRun(driver, _RC)
  _HERE, 'Calling MAPL_Finalize'
  call MAPL_Finalize(_RC)
  _HERE, 'GCHPctm_Main finished'

end program GCHPctm_Main
