#include "MAPL_Generic.h"
#include "MAPL.h"

module GCHP_GridCompMod

  use ESMF
  use mapl3
  use fv_arrays_mod, only: REAL4
  use pflogger, only: logger_t => logger

  implicit none
  private

  public SetServices
  public Initialize
  public Run
  public Finalize

  integer,  parameter :: r4 = REAL4

contains

  !=============================================================================

    subroutine SetServices ( GC, RC )

    type(ESMF_GridComp)  :: gc  ! gridded component
    integer, intent(out) :: rc  ! return code

    integer :: status
    class(logger_t), pointer :: logger

    _HERE, 'ewl debug: SetServices::GCHP:: starting...'
    
    call MAPL_GridCompGet(gc, logger=logger, _RC)
    _HERE, 'ewl debug: SetServices::GCHP:: 1'
!    call logger%info("SetServices::GCHP_GridCompMod: starting...")

    ! Register services for this component
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Initialize,  Initialize, _RC)
    _HERE, 'ewl debug: SetServices::GCHP:: 2'
    !    call logger%info("SetServices::GCHP_GridCompMod: 1")
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Run, Run, phase_name="Run", _RC)
    !call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Run, Run, _RC)
    _HERE, 'ewl debug: SetServices::GCHP:: 3'
    !    call logger%info("SetServices::GCHP_GridCompMod: 2")
    _HERE, 'ewl debug: SetServices::GCHP:: 4'
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Finalize, Finalize, _RC)
!    call logger%info("SetServices::GCHP_GridCompMod: complete")
    _HERE, 'ewl debug: SetServices::GCHP:: complete'
    _RETURN(_SUCCESS)

  end subroutine SetServices

  !=============================================================================

  subroutine Initialize( GC, IMPORT, EXPORT, CLOCK, RC )

    type(ESMF_GridComp):: gc   ! composite gridded component
    type(ESMF_State) :: import ! import state
    type(ESMF_State) :: export ! export state
    type(ESMF_Clock) :: clock  ! the clock
    integer, intent(out) :: rc ! Error code, 0 all is well

    integer :: status
    class(logger_t), pointer :: logger
    character(len=:), allocatable :: gchp_file

    _HERE, 'ewl debug: Initialize::GCHP:: starting...'
    call MAPL_GridCompGet(gc, logger=logger, _RC)
!    call logger%info("Initialize::GCHP_GridCompMod: starting...")

!    call logger%info("Initialize::GCHP_GridCompMod: complete")
    _HERE, 'ewl debug: Initialize::GCHP:: complete'
    _RETURN(_SUCCESS)

  end subroutine Initialize

  !=============================================================================

  subroutine Run( GC, IMPORT, EXPORT, CLOCK, RC )

    use MAPL_MemUtilsMod                         ! Optional memory prints

    type(ESMF_GridComp):: gc   ! composite gridded component
    type(ESMF_State) :: import ! import state
    type(ESMF_State) :: export ! export state
    type(ESMF_Clock) :: clock  ! the clock
    integer, intent(out) :: rc ! Error code, 0 all is well

    integer :: status
    class(logger_t), pointer :: logger
    type(ESMF_GRID) :: esmfgrid
    type(ESMF_HConfig) :: hconfig
    real(r4), pointer :: lats(:,:), lons(:,:), temp2d(:,:)

    _HERE, 'ewl debug: Run::GCHP:: starting...'
    call MAPL_GridCompGet(gc, grid=esmfgrid, hconfig=hconfig, logger=logger, _RC)
!    call logger%info("Run::GCHP_GridCompMod: starting...")

    call ESMF_GridValidate(esmfgrid, _RC)
    call MAPL_GridGet(esmfgrid, longitudes=lons, latitudes=lats, _RC)
    call MAPL_StateGetPointer(export, temp2d, "LONS", _RC)
    if( associated(temp2D) ) temp2d = lons
    call MAPL_StateGetPointer(export, temp2d, "LATS", _RC)
    if( associated(temp2D) ) temp2d = lats
    _HERE, 'ewl debug: Run::GCHP:: complete'
!    call logger%info("Run::GCHP_GridCompMod: complete")

    _RETURN(_SUCCESS)

  end subroutine Run

!=============================================================================

  subroutine Finalize( GC, IMPORT, EXPORT, CLOCK, RC )

    type(ESMF_GridComp):: gc   ! composite gridded component
    type(ESMF_State) :: import ! import state
    type(ESMF_State) :: export ! export state
    type(ESMF_Clock) :: clock  ! the clock
    integer, intent(out) :: rc ! Error code, 0 all is well

    integer :: status
    class(logger_t), pointer :: logger

    call MAPL_GridCompGet(gc, logger=logger, _RC)
!    call logger%info("Finalize::GCHP_GridCompMod: starting...")

!    call logger%info("Finalize::GCHP_GridCompMod: complete")

    _RETURN(ESMF_SUCCESS)
  end subroutine Finalize

!=============================================================================

end module GCHP_GridCompMod

subroutine SetServices(gc, rc)
   use ESMF
   use GCHP_GridCompMod, only : mySetservices=>SetServices
   type(ESMF_GridComp) :: gc
   integer, intent(out) :: rc
   call mySetServices(gc, rc=rc)
end subroutine SetServices
