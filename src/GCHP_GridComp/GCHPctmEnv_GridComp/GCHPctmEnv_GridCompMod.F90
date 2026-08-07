#include "MAPL.h"

module GCHPctmEnv_GridCompMod

  use ESMF
  use MAPL
  use fv_arrays_mod, only: REAL4, REAL8
  use pflogger, only: logger_t => logger

  implicit none
  private

  public SetServices

  logical, public :: import_mass_flux_from_extdata = .false.

  integer,  parameter :: r4 = REAL4
  integer,  parameter :: r8 = REAL8

  integer :: run_dt
  integer :: nlev
  logical :: meteorology_vertical_index_is_top_down
  logical :: use_total_air_pressure_in_advection
  logical :: correct_mass_flux_for_humidity

contains

  !=============================================================================
  ! SetServices - External visible registration routine
  !
  subroutine SetServices(gc, rc)

    type(ESMF_GridComp)  :: gc     ! composite gridded component
    integer, intent(out) :: rc     ! Error code, 0 all is well

    type(ESMF_HConfig) :: hconfig
    class(logger_t), pointer :: logger
    integer :: status

#include "GCHPctmEnv_Import___.h"
#include "GCHPctmEnv_Export___.h"

    call MAPL_GridCompGet(gc, hconfig=hconfig, logger=logger, _RC)
    call logger%debug("GCHctmEnvP_GridCompMod.F90::SetServices starting...")

    ! Register methods
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Initialize,  Initialize, _RC)
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Run, Run, phase_name="Run", _RC)
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Finalize, Finalize, _RC)

    ! Look up in yaml file whether to import mass fluxes from ExtData or derive from winds
    call MAPL_GridCompGetResource(gc,      &
         'IMPORT_MASS_FLUX_FROM_EXTDATA',  &
         import_mass_flux_from_extdata,    &
         default=.false.,                  &
         _RC)
    if (import_mass_flux_from_extdata) then
       call logger%info("GCHPctmEnv config: will use offline mass fluxes and courant numbers")
    else
       call logger%info("GCHPctmEnv config: will derive mass fluxes and courant numbers from offline winds")
    end if

    call logger%debug("GCHPctmEnv_GridCompMod.F90::SetServices done")

    _RETURN(_SUCCESS)

  end subroutine SetServices

  !=============================================================================
  ! Initialize routine
  subroutine Initialize(gc, import, export, clock, rc)

    type(ESMF_GridComp)  :: gc     ! composite gridded component
    type(ESMF_State)     :: import ! import state
    type(ESMF_State)     :: export ! export state
    type(ESMF_Clock)     :: clock  ! the clock
    integer, intent(out) :: rc     ! Error code, 0 all is well

    type(ESMF_HConfig) :: hconfig
    class(logger_t), pointer :: logger
    integer :: status

#include "GCHPctmEnv_DeclarePointer___.h"

    call MAPL_GridCompGet(gc, hconfig=hconfig, logger=logger, _RC)
    call logger%debug("GCHPctmEnv_GridCompMod.F90::Initialize starting...")

#include "GCHPctmEnv_GetPointer___.h"

    ! Initialize exports
    SPHU0 = 0.0d0
    PLE0 = 0.0d0
    PLE1 = 0.0d0
    DryPLE0 = 0.0d0
    DryPLE1 = 0.0d0
    MFX = 0.0d0
    MFY = 0.0d0
    CX = 0.0d0
    CY = 0.0d0

    ! Get number of levels
    nlev = size(PLE0,3) - 1

    ! Get run timestep [sec]
    call MAPL_GridCompGetResource(gc, 'RUN_DT', run_dt, default=0, _RC)
    
    ! Look up in yaml file whether met vertical index is top down
    call MAPL_GridCompGetResource(gc,               &
         'METEOROLOGY_VERTICAL_INDEX_IS_TOP_DOWN',  &
         meteorology_vertical_index_is_top_down,    &
         default=.false.,                           &
         _RC)
    if (meteorology_vertical_index_is_top_down) then
       call logger%info("GCHPctmEnv config: meteorology vertical index is top-down")
    else
       call logger%info("GCHPctmEnv config: meteorology vertical index is bottom-up")
    end if

    ! Look up in yaml file whether to use total or dry air pressure in advection
    call MAPL_GridCompGetResource(gc,            &
         "USE_TOTAL_AIR_PRESSURE_IN_ADVECTION",  &
         use_total_air_pressure_in_advection,    &
         default=.false.,                        &
         _RC)
    if (use_total_air_pressure_in_advection) then
       call logger%info("GCHPctmEnv config: advection will use dry air pressure")
    else
       call logger%info("GCHPctmEnv config: advection will use total air pressure")
    end if

    ! Look up in yaml file whether to convert moist mass flux to dry mass flux
    call MAPL_GridCompGetResource(gc,       &
         'CORRECT_MASS_FLUX_FOR_HUMIDITY',  &
         correct_mass_flux_for_humidity,    &
         default=.false.,                   &
         _RC)
    if (correct_mass_flux_for_humidity) then
       call logger%info("GCHPctmEnv config: will convert moist mass flux to dry for advection")
    else
       call logger%info("GCHPctmEnv config: will use moist mass flux in advection")
    end if

    call logger%debug("GCHPctmEnv_GridCompMod.F90::Initialize done")

    _RETURN(_SUCCESS)
      
  end subroutine Initialize

  !=============================================================================
  ! Run -- The Run method of the Gridded Component.

  subroutine Run(gc, import, export, clock, rc)

    type(ESMF_GridComp)  :: gc     ! composite gridded component
    type(ESMF_State)     :: import ! import state
    type(ESMF_State)     :: export ! export state
    type(ESMF_Clock)     :: clock  ! the clock
    integer, intent(out) :: rc     ! Error code, 0 all is well

    integer            :: status
    type(ESMF_Grid)    :: esmfGrid

    class(logger_t), pointer :: logger

    ! Saved variables
    logical, save :: firstRun = .true.

#include "GCHPctmEnv_DeclarePointer___.h"

    call MAPL_GridCompGet(gc, logger=logger, _RC)
    call logger%debug("GCHPctmEnv_GridCompMod.F90::Initialize starting...")

    ! if need to get anything from yaml file, here is example:
    ! call MAPL_GridCompGetResource(gc, "DYCORE", dycore, default="", _RC)

#include "GCHPctmEnv_GetPointer___.h"

    ! Compute the exports

    ! Reminder: MAPL ExtData exports that are imported here are PS1
    ! (surface pressure before advection) and PS2 (surface pressure after
    ! advection). These are used to derive GCHPctmEnv exports PLE0 and PLE1
    ! (edge pressure profiles before and after advection) for use in advection

    ! Compute pressure edge exports from surface pressure and
    ! then convert from hPa to Pa and vertically flip so that level index
    ! is top-down (level 1 is TOA). The transformation is needed because
    ! calculate_ple returns bottom-up pressure as in [hPa] and advection
    ! expects top-down pressure in [Pa].

    ! Compute edge pressures for time before advection
    call calculate_ple(PS1, PLE0)

    ! Convert units and vertically flip (MAPL vertical dimension is 0-based)
    PLE0 = 100.0d0 * PLE0
    PLE0 = PLE0(:,:,nlev:0:-1)

    ! Compute edge pressures for time after advection
    call calculate_ple(PS2, PLE1)

    ! Convert units and vertically flip (MAPL vertical dimension is 0-based)
    PLE1 = 100.0d0 * PLE1
    PLE1 = PLE1(:,:,nlev:0:-1)

    ! Also compute dry pressures if using dry pressure in advection
    if ( .not. use_total_air_pressure_in_advection ) then

       ! Compute dry edge pressures for time before advection
       call calculate_ple( PS1, DryPLE0, SPHU=SPHU1,           &
            topDownMet=meteorology_vertical_index_is_top_down )

       ! Convert units and vertically flip (MAPL vertical dimension is 0-based)
       DryPLE0 = 100.0d0 * DryPLE0
       DryPLE0 = DryPLE0(:,:,nlev:0:-1)

       ! Compute dry edge pressures for time after advection
       call calculate_ple( PS2, DryPLE1, SPHU=SPHU2,           &
            topDownMet=meteorology_vertical_index_is_top_down )

       ! Convert units and vertically flip (MAPL vertical dimension is 0-based)
       DryPLE1 = 100.0d0 * DryPLE1
       DryPLE1 = DryPLE1(:,:,nlev:0:-1)

    endif

    ! Prepare the specific humidity export (ewl: only if needed?)
    ! Set specific humidity export as copy of import casted to real8
    ! and vertically flip if needed
    if ( meteorology_vertical_index_is_top_down ) then
       SPHU0 = dble(SPHU1)
    else
       SPHU0 = dble(SPHU1(:,:,nlev:1:-1))
    end if

    !     call prepare_massflux_exports(import, export, PLE, run_dt, _RC)

    call logger%debug("GCHPctmEnv_GridCompMod.F90::Run done")

    firstRun = .false.

    _RETURN(_SUCCESS)

  end subroutine Run

  !=============================================================================
  ! Finalize -- The Finalize method of the Gridded Component.

  subroutine Finalize( gc, import, export, clock, rc )

    type(ESMF_GridComp)  :: gc     ! composite gridded component
    type(ESMF_State)     :: import ! import state
    type(ESMF_State)     :: export ! export state
    type(ESMF_Clock)     :: clock  ! the clock
    integer, intent(out) :: rc     ! Error code, 0 all is well

    integer :: status
    class(logger_t), pointer :: logger

    ! ewl: is this needed?

    call MAPL_GridCompGet(gc, logger=logger, _RC)
    call logger%debug("GCHPctmEnv_GridCompMod.F90::Finalize starting...")

    call logger%debug("GCHPctmEnv_GridCompMod.F90::Finalize done")

    _RETURN(ESMF_SUCCESS)

  end subroutine Finalize


  !
  !   subroutine prepare_massflux_exports(IMPORT, EXPORT, PLE, dt, RC)
  !     ! !DESCRIPTION:
  !     ! Set mass flux and courant exports needed for offline advection. How this
  !     ! is done is dependent upon whether importing them via ExtData or computing
  !     ! from winds.
  !
  !     real(r8), intent(in), pointer   :: PLE(:,:,:) ! Edge pressures
  !     real(r8), intent(in)            :: dt
  !     type(ESMF_State), intent(inout) :: IMPORT
  !     type(ESMF_State), intent(inout) :: EXPORT
  !     integer, optional, intent(out)  :: RC       ! Error code
  !
  !     integer :: is, ie, js, je, nlev
  !     integer :: STATUS
  !
  !     ! Pointers to exports
  !     real(r8), pointer, dimension(:,:,:) :: MFX_EXPORT => null()
  !     real(r8), pointer, dimension(:,:,:) :: MFY_EXPORT => null()
  !     real(r8), pointer, dimension(:,:,:) :: CX_EXPORT  => null()
  !     real(r8), pointer, dimension(:,:,:) :: CY_EXPORT  => null()
  !     real(r8), pointer, dimension(:,:,:) :: SPHU0_EXPORT  => null()
  !
  !     ! Pointers to R4 exports for diagnostics
  !     real(r4), pointer, dimension(:,:,:) :: MFX_R4_EXPORT => null()
  !     real(r4), pointer, dimension(:,:,:) :: MFY_R4_EXPORT => null()
  !     real(r4), pointer, dimension(:,:,:) :: CX_R4_EXPORT  => null()
  !     real(r4), pointer, dimension(:,:,:) :: CY_R4_EXPORT  => null()
  !
  !     ! Pointers to imports
  !     real,     pointer, dimension(:,:,:) :: MFX_IMPORT => null()
  !     real,     pointer, dimension(:,:,:) :: MFY_IMPORT => null()
  !     real,     pointer, dimension(:,:,:) :: CX_IMPORT  => null()
  !     real,     pointer, dimension(:,:,:) :: CY_IMPORT  => null()
  !     real,     pointer, dimension(:,:,:) :: UA_IMPORT  => null()
  !     real,     pointer, dimension(:,:,:) :: VA_IMPORT  => null()
  !
  !     ! Pointer to diagnostic export
  !     real(r8), pointer, dimension(:,:,:) :: UpwardsMassFlux => null()
  !     real(r4), pointer, dimension(:,:,:) :: UpwardsMassFlux_R4 => null()
  !
  !     ! Pointers to local arrays
  !     real,     pointer, dimension(:,:,:) :: UC        => null()
  !      real,     pointer, dimension(:,:,:) :: VC        => null()
  !      real(r8), pointer, dimension(:,:,:) :: UCr8      => null()
  !      real(r8), pointer, dimension(:,:,:) :: VCr8      => null()
  !
  !#ifdef ADJOINT
  !      logical, save :: firstRun = .true.
  !#endif
  !
  !      !=====================================
  !      ! prepare_massflux_exports starts here
  !      !=====================================
  !
  !      call lgr%debug('Preparing FV3 input MFX, MFY, CX, and CY')
  !
  !      is = lbound(PLE, 1); ie = ubound(PLE, 1)
  !      js = lbound(PLE, 2); je = ubound(PLE, 2)
  !      nlev = size(PLE, 3) - 1
  !
  !      ! Get exports (real8)
  !      call MAPL_GetPointer(EXPORT, MFX_EXPORT, 'MFX', RC=STATUS)
  !      _VERIFY(STATUS)
  !      call MAPL_GetPointer(EXPORT, MFY_EXPORT, 'MFY', RC=STATUS)
  !      _VERIFY(STATUS)
  !      call MAPL_GetPointer(EXPORT, CX_EXPORT, 'CX', RC=STATUS)
  !      _VERIFY(STATUS)
  !      call MAPL_GetPointer(EXPORT, CY_EXPORT, 'CY', RC=STATUS)
  !      _VERIFY(STATUS)
  !
  !      if ( import_mass_flux_from_extdata ) then
  !
  !         ! Get SPHU0 export set in prepare_sphu_export
  !         if ( correct_mass_flux_for_humidity > 0 ) then
  !            call MAPL_GetPointer(EXPORT, SPHU0_EXPORT, 'SPHU0', RC=STATUS)
  !            _VERIFY(STATUS)
  !         endif
  !
  !         ! Get imports (real4) and copy to exports, converting to real8
  !         call MAPL_GetPointer(IMPORT, MFX_IMPORT, 'MFXC',  RC=STATUS)
  !         _VERIFY(STATUS)
  !         call MAPL_GetPointer(IMPORT, MFY_IMPORT, 'MFYC',  RC=STATUS)
  !         _VERIFY(STATUS)
  !         call MAPL_GetPointer(IMPORT, CX_IMPORT, 'CXC',  RC=STATUS)
  !         _VERIFY(STATUS)
  !         call MAPL_GetPointer(IMPORT, CY_IMPORT, 'CYC',  RC=STATUS)
  !         _VERIFY(STATUS)
  !
  !         if (meteorology_vertical_index_is_top_down) then
  !            MFX_EXPORT =  dble(MFX_IMPORT(:,:,:))
  !            MFY_EXPORT =  dble(MFY_IMPORT(:,:,:))
  !            CX_EXPORT  =  dble(CX_IMPORT(:,:,:))
  !            CY_EXPORT  =  dble(CY_IMPORT(:,:,:))
  !         else
  !            MFX_EXPORT =  dble(MFX_IMPORT(:,:,nlev:1:-1))
  !            MFY_EXPORT =  dble(MFY_IMPORT(:,:,nlev:1:-1))
  !            CX_EXPORT  =  dble(CX_IMPORT(:,:,nlev:1:-1))
  !            CY_EXPORT  =  dble(CY_IMPORT(:,:,nlev:1:-1))
  !         endif
  !
  !         if ( correct_mass_flux_for_humidity > 0 ) then
  !            MFX_EXPORT = MFX_EXPORT / ( 1.d0 - SPHU0_EXPORT )
  !            MFY_EXPORT = MFY_EXPORT / ( 1.d0 - SPHU0_EXPORT )
  !         endif
  !
  !      else
  !
  !         ! Get wind imports (real4, A-grid)
  !         call MAPL_GetPointer(IMPORT, UA_IMPORT, 'UA', RC=STATUS)
  !         _VERIFY(STATUS)
  !         call MAPL_GetPointer(IMPORT, VA_IMPORT, 'VA', RC=STATUS)
  !         _VERIFY(STATUS)
  !
  !         ! Allocate local arrays for C-grid, both real4 and real8
  !         ALLOCATE( UC   (is:ie, js:je, nlev), STAT=STATUS);
  !         _VERIFY(STATUS)
  !         ALLOCATE( VC   (is:ie, js:je, nlev), STAT=STATUS);
  !         _VERIFY(STATUS)
  !         ALLOCATE( UCr8 (is:ie, js:je, nlev), STAT=STATUS);
  !         _VERIFY(STATUS)
  !         ALLOCATE( VCr8 (is:ie, js:je, nlev), STAT=STATUS);
  !         _VERIFY(STATUS)
  !
  !         ! Copy imports to local arrays so that vertical index is top down
  !         if (meteorology_vertical_index_is_top_down) then
  !            UC(:,:,:) = UA_IMPORT(:,:,:)
  !            VC(:,:,:) = VA_IMPORT(:,:,:)
  !         else
  !            UC(:,:,:) = UA_IMPORT(:,:,nlev:1:-1)
  !            VC(:,:,:) = VA_IMPORT(:,:,nlev:1:-1)
  !         end if
  !
  !         ! ewl debug: try putting this here and passing to A2D2C as real8...
  !         ! Seems to work! Clean up later.
  !         UCr8  = dble(UC)
  !         VCr8  = dble(VC)
  !         call A2D2C(U=UCr8, V=VCr8, npz=nlev, getC=.true.)
  !
  !!         ! Restagger winds (A-grid to C-grid) (requires real4)
  !!         call A2D2C(U=UC, V=VC, npz=nlev, getC=.true.)
  !!
  !!         ! Store as real8 for input to FV3 subroutine to compute mass fluxes
  !!         UCr8  = dble(UC)
  !!         VCr8  = dble(VC)
  !
  !#ifndef ADJOINT
  !         ! Calculate mass fluxes and courant numbers
  !         call fv_computeMassFluxes(UCr8, VCr8, PLE, &
  !              MFX_EXPORT, MFY_EXPORT, &
  !              CX_EXPORT, CY_EXPORT, dt)
  !#else
  !         if (.not. firstRun) THEN
  !            ! Calculate mass fluxes and courant numbers
  !            call fv_computeMassFluxes(UCr8, VCr8, PLE, &
  !                 MFX_EXPORT, MFY_EXPORT, &
  !                 CX_EXPORT, CY_EXPORT, dt)
  !         endif
  !         firstRun = .false.
  !#endif
  !
  !         ! Deallocate local arrays
  !         DEALLOCATE(UC, VC, UCr8, VCr8)
  !
  !      end if
  !
  !      ! Set R4 exports for diagnostics
  !      call MAPL_GetPointer(EXPORT, MFX_R4_EXPORT, 'MFX_R4', NotFoundOK=.TRUE., _RC)
  !      IF ( ASSOCIATED(MFX_R4_EXPORT) ) MFX_R4_EXPORT = MFX_EXPORT
  !      call MAPL_GetPointer(EXPORT, MFY_R4_EXPORT, 'MFY_R4', NotFoundOK=.TRUE., _RC)
  !      IF ( ASSOCIATED(MFY_R4_EXPORT) ) MFY_R4_EXPORT = MFY_EXPORT
  !      call MAPL_GetPointer(EXPORT, CX_R4_EXPORT, 'CX_R4', NotFoundOK=.TRUE., _RC)
  !      IF ( ASSOCIATED(CX_R4_EXPORT) ) CX_R4_EXPORT  = CX_EXPORT
  !      call MAPL_GetPointer(EXPORT, CY_R4_EXPORT, 'CY_R4', NotFoundOK=.TRUE., _RC)
  !      IF ( ASSOCIATED(CY_R4_EXPORT) ) CY_R4_EXPORT  = CY_EXPORT
  !
  !      ! Set vertical motion diagnostic if enabled in HISTORY.rc
  !      call MAPL_GetPointer(EXPORT, UpwardsMassFlux, 'UpwardsMassFlux', &
  !           NotFoundOK=.TRUE., RC=STATUS)
  !      _VERIFY(STATUS)
  !      if (associated(UpwardsMassFlux)) then
  !         call lgr%debug('Calculating diagnostic export UpwardsMassFlux')
  !
  !         ! Get vertical mass flux
  !         call fv_getVerticalMassFlux(MFX_EXPORT, MFY_EXPORT, UpwardsMassFlux, dt)
  !
  !         ! Flip vertical so that GCHP diagnostic level is following GEOS-Chem convention
  !         ! Add negative sign to make positive = "up"
  !         UpwardsMassFlux(:,:,:) = -UpwardsMassFlux(:,:,nlev:0:-1)/dt
  !      end if
  !
  !      ! nullify pointers
  !      MFX_EXPORT      => null()
  !      MFY_EXPORT      => null()
  !      CX_EXPORT       => null()
  !      CY_EXPORT       => null()
  !      SPHU0_EXPORT    => null()
  !      MFX_IMPORT      => null()
  !      MFY_IMPORT      => null()
  !      CX_IMPORT       => null()
  !      CY_IMPORT       => null()
  !      UA_IMPORT       => null()
  !      VA_IMPORT       => null()
  !      UpwardsMassFlux => null()
  !      UC              => null()
  !      VC              => null()
  !      UCr8            => null()
  !      VCr8            => null()
  !
  !      ! Nullify R4 exports used for diagnostics
  !      MFX_R4_EXPORT      => null()
  !      MFY_R4_EXPORT      => null()
  !      CX_R4_EXPORT       => null()
  !      CY_R4_EXPORT       => null()
  !
  !      _RETURN(ESMF_SUCCESS)
  !
  !   end subroutine prepare_massflux_exports
  !

  ! Compute edge pressures from surface pressure and grid parameters. This
  ! subroutine is currently hard-coded for 72 levels only and returns pressure
  ! with vertical index bottom-up (level 1 is surface) in units of hPa.
  subroutine calculate_ple(PS, PLE, SPHU, topDownMet )

    real(r4), intent(in)           :: PS(:,:)     ! Surface pressure [hPa]
    real(r8), intent(out)          :: PLE(:,:,:)  ! Edge pressure    [hPa]
    real(r4), intent(in), OPTIONAL :: SPHU(:,:,:) ! Specific humidity [kg/kg]
    logical,  intent(in), OPTIONAL :: topDownMet  ! True if meteorology level 1 is TOA
    ! NOTE: Want to make number of levels configurable
    integer, parameter  :: num_levels = 72
    integer, parameter  :: num_edges = num_levels + 1
    real(r8)            :: AP(num_edges), BP(num_edges)
    real(r8)            :: PEdge_Bot, PEdge_Top, PSDry
    integer             :: I, J, L, is, ie, js, je, nlev

    !================================
    ! calculate_ple starts here
    !================================
    AP = 1d0
    BP = 0d0
    ! GMAO 72 level grid
    ! Ap [hPa] for 72 levels (73 edges)
    AP = (/ 0.000000d+00, 4.804826d-02, 6.593752d+00, 1.313480d+01, &
         1.961311d+01, 2.609201d+01, 3.257081d+01, 3.898201d+01, &
         4.533901d+01, 5.169611d+01, 5.805321d+01, 6.436264d+01, &
         7.062198d+01, 7.883422d+01, 8.909992d+01, 9.936521d+01, &
         1.091817d+02, 1.189586d+02, 1.286959d+02, 1.429100d+02, &
         1.562600d+02, 1.696090d+02, 1.816190d+02, 1.930970d+02, &
         2.032590d+02, 2.121500d+02, 2.187760d+02, 2.238980d+02, &
         2.243630d+02, 2.168650d+02, 2.011920d+02, 1.769300d+02, &
         1.503930d+02, 1.278370d+02, 1.086630d+02, 9.236572d+01, &
         7.851231d+01, 6.660341d+01, 5.638791d+01, 4.764391d+01, &
         4.017541d+01, 3.381001d+01, 2.836781d+01, 2.373041d+01, &
         1.979160d+01, 1.645710d+01, 1.364340d+01, 1.127690d+01, &
         9.292942d+00, 7.619842d+00, 6.216801d+00, 5.046801d+00, &
         4.076571d+00, 3.276431d+00, 2.620211d+00, 2.084970d+00, &
         1.650790d+00, 1.300510d+00, 1.019440d+00, 7.951341d-01, &
         6.167791d-01, 4.758061d-01, 3.650411d-01, 2.785261d-01, &
         2.113490d-01, 1.594950d-01, 1.197030d-01, 8.934502d-02, &
         6.600001d-02, 4.758501d-02, 3.270000d-02, 2.000000d-02, &
         1.000000d-02 /)
    ! Bp [unitless] for 72 levels (73 edges)
    BP = (/ 1.000000d+00, 9.849520d-01, 9.634060d-01, 9.418650d-01, &
         9.203870d-01, 8.989080d-01, 8.774290d-01, 8.560180d-01, &
         8.346609d-01, 8.133039d-01, 7.919469d-01, 7.706375d-01, &
         7.493782d-01, 7.211660d-01, 6.858999d-01, 6.506349d-01, &
         6.158184d-01, 5.810415d-01, 5.463042d-01, 4.945902d-01, &
         4.437402d-01, 3.928911d-01, 3.433811d-01, 2.944031d-01, &
         2.467411d-01, 2.003501d-01, 1.562241d-01, 1.136021d-01, &
         6.372006d-02, 2.801004d-02, 6.960025d-03, 8.175413d-09, &
         0.000000d+00, 0.000000d+00, 0.000000d+00, 0.000000d+00, &
         0.000000d+00, 0.000000d+00, 0.000000d+00, 0.000000d+00, &
         0.000000d+00, 0.000000d+00, 0.000000d+00, 0.000000d+00, &
         0.000000d+00, 0.000000d+00, 0.000000d+00, 0.000000d+00, &
         0.000000d+00, 0.000000d+00, 0.000000d+00, 0.000000d+00, &
         0.000000d+00, 0.000000d+00, 0.000000d+00, 0.000000d+00, &
         0.000000d+00, 0.000000d+00, 0.000000d+00, 0.000000d+00, &
         0.000000d+00, 0.000000d+00, 0.000000d+00, 0.000000d+00, &
         0.000000d+00, 0.000000d+00, 0.000000d+00, 0.000000d+00, &
         0.000000d+00, 0.000000d+00, 0.000000d+00, 0.000000d+00, &
         0.000000d+00 /)
    ! Calculate bottom-up level edge pressures [hPa]
    if ( .not. PRESENT( SPHU ) ) then
       ! Total pressure
       do L=1,num_edges
          PLE(:,:,L) = AP(L) + ( BP(L) * dble(PS(:,:)) )
       enddo
    else
       ! Dry pressure
       is = lbound(PS,1)
       ie = ubound(PS,1)
       js = lbound(PS,2)
       je = ubound(PS,2)
       nlev = size  (SPHU,3)
       if ( topDownMet ) then
          do J=js,je
             do I=is,ie
                ! Start with TOA pressure
                PSDry = AP(nlev+1)
                ! Stack up dry delta-P to get surface dry pressure
                ! Vertically flip humidity if using top-down meteorology (raw GMAO files)
                do L=1,nlev
                   PEdge_Bot = AP(L  ) + ( BP(L  ) * dble(PS(I,J)) )
                   PEdge_Top = AP(L+1) + ( BP(L+1) * dble(PS(I,J)) )
                   PSDry = PSDry &
                        + ( ( PEdge_Bot - Pedge_Top ) * ( 1.d0 - SPHU(I,J,nlev-L+1) ) )
                enddo
                ! Work back up from the surface to get dry level edges
                do L=1,nlev+1
                   PLE(I,J,L) = AP(L) + ( BP(L) * dble(PSDry) )
                enddo
             enddo
          enddo
       else
          do J=js,je
             do I=is,ie
                ! Start with TOA pressure
                PSDry = AP(nlev+1)
                ! Stack up dry delta-P to get surface dry pressure
                do L=1,nlev
                   PEdge_Bot = AP(L  ) + ( BP(L  ) * dble(PS(I,J)) )
                   PEdge_Top = AP(L+1) + ( BP(L+1) * dble(PS(I,J)) )
                   PSDry = PSDry &
                        + ( ( PEdge_Bot - Pedge_Top ) * ( 1.d0 - SPHU(I,J,L) ) )
                enddo
                ! Work back up from the surface to get dry level edges
                do L=1,nlev+1
                   PLE(I,J,L) = AP(L) + ( BP(L) * dble(PSDry) )
                enddo
             enddo
          enddo
       endif
    endif
  end subroutine calculate_ple
end module GCHPctmEnv_GridCompMod

subroutine GCHPctmEnv_SetServices(gc, rc)
   use ESMF
   use GCHPctmEnv_GridCompMod, only : mySetservices => SetServices
   type(ESMF_GridComp) :: gc
   integer, intent(out) :: rc
   call mySetServices(gc, rc=rc)
end subroutine GCHPctmEnv_SetServices
