#include "MAPL.h"

module GCHPctmEnv_GridCompMod

  use ESMF
  use MAPL
  use fv_arrays_mod, only: REAL4, REAL8 ! Note the reliance on FV!
  use pflogger, only: logger_t => logger

  implicit none
  private

  public SetServices

  logical, public :: import_mass_flux_from_extdata = .false.

  integer,  parameter :: r4 = REAL4
  integer,  parameter :: r8 = REAL8

  ! Currently number of levels is hard-coded to 72 for GCHP
  integer, parameter  :: nlev = 72

  ! Settings from gchpctmenv.yaml
  logical :: meteorology_vertical_index_is_top_down
  logical :: use_total_air_pressure_in_advection
  logical :: correct_mass_flux_for_humidity
  real(REAL8) :: run_dt

  ! GMAO 72 level grid: Ap [hPa] for 72 levels (73 edges)
  real(REAL8), parameter :: AP_72(73) = &
       (/ 0.000000d+00, 4.804826d-02, 6.593752d+00, 1.313480d+01, &
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

  ! GMAO 72 level grid: Bp [unitless] for 72 levels (73 edges)
  real(REAL8), parameter :: BP_72(73) = &
       (/ 1.000000d+00, 9.849520d-01, 9.634060d-01, 9.418650d-01, &
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

    call MAPL_GridCompGet(gc, hconfig=hconfig, logger=logger, _RC)
    call logger%debug("GCHctmEnvP_GridCompMod.F90::SetServices starting...")

    ! Register methods
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Initialize,  Initialize, _RC)
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Run, Run, phase_name="Run", _RC)
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Finalize, Finalize, _RC)

    ! Include auto-generated code for declaring non-vector imports
#include "GCHPctmEnv_Import___.h"

    ! Look up in yaml file whether to also import mass fluxes from ExtData or derive from winds
    call MAPL_GridCompGetResource(gc,      &
         'IMPORT_MASS_FLUX_FROM_EXTDATA',  &
         import_mass_flux_from_extdata,    &
         default=.false.,                  &
         _RC)
    if (import_mass_flux_from_extdata) then
       call logger%info("GCHPctmEnv config: will use offline mass fluxes and courant numbers")
       call MAPL_GridCompAddSpec(gridcomp=gc,                                 &
            short_name= 'MFXY' ,                                              &
            units='Pa m+2 s-1',                                               &
            typekind=ESMF_TYPEKIND_R4,                                        &
            dims='xyz',                                                       &
            vertical_stagger=MAPL_VERTICAL_STAGGER_CENTER,                    &
            itemtype=MAPL_STATEITEM_VECTOR,                                   &
            standard_name='pressure_weighted_(eastward,northward)_mass_flux', &
            state_intent=ESMF_STATEINTENT_IMPORT,                             &
            _RC)
       call MAPL_GridCompAddSpec(gridcomp=gc,                                 &
            short_name= 'CXY' ,                                               &
            units='1',                                                        &
            typekind=ESMF_TYPEKIND_R4,                                        &
            dims='xyz',                                                       &
            vertical_stagger=MAPL_VERTICAL_STAGGER_CENTER,                    &
            standard_name='(eastward,northward)_accumulated_courant_number',  &
            itemtype=MAPL_STATEITEM_VECTOR,                                   &
            state_intent=ESMF_STATEINTENT_IMPORT,                             &
            _RC)
    else
       call logger%info("GCHPctmEnv config: will derive mass fluxes and courant numbers from offline winds")
       call MAPL_GridCompAddSpec(gridcomp=gc,                                 &
            short_name= 'UV' ,                                                &
            units='m s-1',                                                    &
            typekind=ESMF_TYPEKIND_R4,                                        &
            dims='xyz',                                                       &
            vertical_stagger=MAPL_VERTICAL_STAGGER_CENTER,                    &
            itemtype=MAPL_STATEITEM_VECTOR,                                   &
            standard_name='(eastward,northward)_wind',                        &
            state_intent=ESMF_STATEINTENT_IMPORT,                             &
            _RC)
    end if

    ! Include auto-generated code for declaring exports
#include "GCHPctmEnv_Export___.h"

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
    integer :: status, dt_int

    call MAPL_GridCompGet(gc, hconfig=hconfig, logger=logger, _RC)
    call logger%debug("GCHPctmEnv_GridCompMod.F90::Initialize starting...")

    ! Get run timestep [sec] and store as real8 for use in FV subroutines
    call MAPL_GridCompGetResource(gc, 'RUN_DT', dt_int, default=0, _RC)
    run_dt = dt_int

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

    use FV_StateMod,           only : fv_computeMassFluxes, fv_getVerticalMassFlux
    use GEOS_FV3_UtilitiesMod, only : A2D2C

    type(ESMF_GridComp)  :: gc     ! composite gridded component
    type(ESMF_State)     :: import ! import state
    type(ESMF_State)     :: export ! export state
    type(ESMF_Clock)     :: clock  ! the clock
    integer, intent(out) :: rc     ! Error code, 0 all is well

    integer      :: is, ie, js, je
    integer      :: status

    class(logger_t), pointer :: logger

    ! Include auto-generated code to declare non-vector import/export pointers
#include "GCHPctmEnv_DeclarePointer___.h"

    ! Special handling for vector imports
    type(ESMF_FieldBundle) :: bundle
    type(ESMF_Field), allocatable :: field_list(:)

    real(REAL4), pointer :: CX_in(:,:,:)  => NULL()
    real(REAL4), pointer :: CY_in(:,:,:)  => NULL()
    real(REAL4), pointer :: MFX_in(:,:,:) => NULL()
    real(REAL4), pointer :: MFY_in(:,:,:) => NULL()
    real(REAL4), pointer :: UA_in(:,:,:)  => NULL()
    real(REAL4), pointer :: VA_in(:,:,:)  => NULL()

    real(REAL8), allocatable :: uc_r8(:,:,:)
    real(REAL8), allocatable :: vc_r8(:,:,:)

#ifdef ADJOINT
    logical, save :: firstRun = .true.
#endif

    call MAPL_GridCompGet(gc, logger=logger, _RC)
    call logger%debug("GCHPctmEnv_GridCompMod.F90:: Run starting...")

    ! Include auto-generated code to get non-vector import/export pointers
    ! Pointers to vectors will be done conditionally later on
#include "GCHPctmEnv_GetPointer___.h"

    ! Get domain dimensions
    is = lbound(PLE0_out, 1)
    ie = ubound(PLE0_out, 1)
    js = lbound(PLE0_out, 2)
    je = ubound(PLE0_out, 2)

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
    call Calculate_PLE(PS1_in, is, ie, js, je, PLE0_out)

    ! Convert units and vertically flip
    PLE0_out = 100.0d0 * PLE0_out
    PLE0_out = PLE0_out(:,:,nlev+1:1:-1)

    ! Compute edge pressures for time after advection
    call Calculate_PLE(PS2_in, is, ie, js, je, PLE1_out)

    ! Convert units and vertically flip
    PLE1_out = 100.0d0 * PLE1_out
    PLE1_out = PLE1_out(:,:,nlev+1:1:-1)

    ! Also compute dry pressures if using dry pressure in advection
    if ( .not. use_total_air_pressure_in_advection ) then

       ! Compute dry edge pressures for time before advection
       call Calculate_PLE( PS1_in, is, ie, js, je, DryPLE0_out, &
            SPHU=SPHU1_in, topDownMet=meteorology_vertical_index_is_top_down )

       ! Convert units and vertically flip
       DryPLE0_out = 100.0d0 * DryPLE0_out
       DryPLE0_out = DryPLE0_out(:,:,nlev+1:1:-1)

       ! Compute dry edge pressures for time after advection
       call Calculate_PLE( PS2_in, is, ie, js, je, DryPLE1_out, &
            SPHU=SPHU2_in, topDownMet=meteorology_vertical_index_is_top_down )

       ! Convert units and vertically flip
       DryPLE1_out = 100.0d0 * DryPLE1_out
       DryPLE1_out = DryPLE1_out(:,:,nlev+1:1:-1)

    endif

    ! Prepare the pre-advection specific humidity export (ewl: only if needed?)
    ! Set specific humidity export as copy of import casted to real8
    ! and vertically flip if needed
    if ( meteorology_vertical_index_is_top_down ) then
       SPHU0_out = dble(SPHU1_in)
    else
       SPHU0_out = dble(SPHU1_in(:,:,nlev:1:-1))
    end if

    !     call prepare_massflux_exports(import, export, PLE, run_dt, _RC)
    call logger%debug('Preparing FV3 input MFX, MFY, CX, and CY')

    if ( import_mass_flux_from_extdata ) then

       ! Get mass flux components from import vector MFXY
       call ESMF_StateGet(import, "MFXY", bundle, _RC)
       call MAPL_FieldBundleGet(bundle, fieldList=field_list, _RC)
       _RETURN_UNLESS(size(field_list) == 2)
       call ESMF_FieldGet(field_list(1), farrayPtr=MFX_in, _RC)
       call ESMF_FieldGet(field_list(2), farrayPtr=MFY_in, _RC)

       ! Get Courant number components from import vector CXY
       call ESMF_StateGet(import, "CXY", bundle, _RC)
       call MAPL_FieldBundleGet(bundle, fieldList=field_list, _RC)
       _RETURN_UNLESS(size(field_list) == 2)
       call ESMF_FieldGet(field_list(1), farrayPtr=CX_in, _RC)
       call ESMF_FieldGet(field_list(2), farrayPtr=CY_in, _RC)

       if (meteorology_vertical_index_is_top_down) then
          MFX_out =  dble(MFX_in(:,:,:))
          MFY_out =  dble(MFY_in(:,:,:))
          CX_out  =  dble(CX_in(:,:,:))
          CY_out  =  dble(CY_in(:,:,:))
       else
          MFX_out =  dble(MFX_in(:,:,nlev:1:-1))
          MFY_out =  dble(MFY_in(:,:,nlev:1:-1))
          CX_out  =  dble(CX_in(:,:,nlev:1:-1))
          CY_out  =  dble(CY_in(:,:,nlev:1:-1))
       endif

       if ( correct_mass_flux_for_humidity > 0 ) then
          ! ewl: better to use the average humidity instead?
          MFX_out = MFX_out / ( 1.d0 - SPHU1_in )
          MFY_out = MFY_out / ( 1.d0 - SPHU1_in )
       endif

    else

       ! Get A-grid wind components from import vector UV
       call ESMF_StateGet(import, "UV", bundle, _RC)
       call MAPL_FieldBundleGet(bundle, fieldList=field_list, _RC)
       _RETURN_UNLESS(size(field_list) == 2)
       call ESMF_FieldGet(field_list(1), farrayPtr=UA_in, _RC)
       call ESMF_FieldGet(field_list(2), farrayPtr=VA_in, _RC)

       ! Allocate local arrays for C-grid winds
       ALLOCATE( uc_r8 (is:ie, js:je, nlev), STAT=STATUS);
       _VERIFY(STATUS)
       ALLOCATE( vc_r8 (is:ie, js:je, nlev), STAT=STATUS);
       _VERIFY(STATUS)

       ! Get r8 C-grid winds from r4 A-grid, flipping as needed so level 1 is TOA
       if (meteorology_vertical_index_is_top_down) then
          uc_r8 = dble(UA_in)
          vc_r8 = dble(VA_in)
       else
          uc_r8(:,:,:) = dble(UA_in(:,:,nlev:1:-1))
          vc_r8(:,:,:) = dble(VA_in(:,:,nlev:1:-1))
       end if
       call A2D2C(U=uc_r8, V=vc_r8, npz=nlev, getC=.true.)

#ifdef ADJOINT
       if (.not. firstRun) then
#endif
       ! Compute mass fluxes and Courant numbers from C-grid winds
       if (use_total_air_pressure_in_advection) then
          call fv_computeMassFluxes(uc_r8, vc_r8, PLE0_out, &
               MFX_out, MFY_out, CX_out, CY_out, run_dt)
       else
          call fv_computeMassFluxes(uc_r8, vc_r8, DryPLE0_out, &
               MFX_out, MFY_out, CX_out, CY_out, run_dt)
       endif
#ifdef ADJOINT
       else
          firstRun = .false.
       endif
#endif

       ! Deallocate local arrays
       DEALLOCATE(uc_r8, vc_r8)

    endif

    if (associated(UpwardsMassFlux_out)) then
       call logger%debug('Calculating diagnostic export UpwardsMassFlux')

       ! Get vertical mass flux
       call fv_getVerticalMassFlux(MFX_out, MFY_out, UpwardsMassFlux_out, run_dt)

       ! Flip vertical so that GCHP diagnostic level is following GEOS-Chem convention
       ! Add negative sign to make positive = "up"
       UpwardsMassFlux_out(:,:,:) = -UpwardsMassFlux_out(:,:,nlev+1:1:-1)/run_dt

    endif

    ! Set the exports that are the same as imports
    SPHU1_out = SPHU1_in
    
    call logger%debug("GCHPctmEnv_GridCompMod.F90::Run done")

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

  !=============================================================================
  ! Calulate_PLE -- Compute edge pressures from meteorology imports and grid
  ! parameters. This subroutine is currently hard-coded for 72 levels only and
  ! returns pressure with vertical index bottom-up (level 1 is surface) in hPa.
  subroutine Calculate_PLE(PS, is, ie, js, je, PLE, SPHU, topDownMet )

    real(REAL4), intent(in)           :: PS(:,:)        ! Surface pressure [hPa]
    integer,     intent(in)           :: is, ie, js, je ! Domain indexes
    real(REAL8), intent(out)          :: PLE(:,:,:)     ! Edge pressure    [hPa]
    real(REAL4), intent(in), OPTIONAL :: SPHU(:,:,:)    ! Specific humidity [kg/kg]
    logical,     intent(in), OPTIONAL :: topDownMet     ! True if meteorology level 1 is TOA

    real(REAL8) :: PEdge_Bot, PEdge_Top, PSDry
    integer     :: I, J, L

    ! Calculate bottom-up level edge pressures [hPa]
    if ( .not. PRESENT( SPHU ) ) then
       ! Total pressure
       do L=1,nlev+1
          PLE(:,:,L) = AP_72(L) + ( BP_72(L) * dble(PS(:,:)) )
       enddo
    else
       ! Dry pressure
       if ( topDownMet ) then
          do J=js,je
             do I=is,ie
                ! Start with TOA pressure
                PSDry = AP_72(nlev+1)
                ! Stack up dry delta-P to get surface dry pressure
                ! Vertically flip humidity if using top-down meteorology (raw GMAO files)
                do L=1,nlev
                   PEdge_Bot = AP_72(L  ) + ( BP_72(L  ) * dble(PS(I,J)) )
                   PEdge_Top = AP_72(L+1) + ( BP_72(L+1) * dble(PS(I,J)) )
                   PSDry = PSDry &
                        + ( ( PEdge_Bot - Pedge_Top ) * ( 1.d0 - SPHU(I,J,nlev-L+1) ) )
                enddo
                ! Work back up from the surface to get dry level edges
                do L=1,nlev+1
                   PLE(I,J,L) = AP_72(L) + ( BP_72(L) * dble(PSDry) )
                enddo
             enddo
          enddo
       else
          do J=js,je
             do I=is,ie
                ! Start with TOA pressure
                PSDry = AP_72(nlev+1)
                ! Stack up dry delta-P to get surface dry pressure
                do L=1,nlev
                   PEdge_Bot = AP_72(L  ) + ( BP_72(L  ) * dble(PS(I,J)) )
                   PEdge_Top = AP_72(L+1) + ( BP_72(L+1) * dble(PS(I,J)) )
                   PSDry = PSDry &
                        + ( ( PEdge_Bot - Pedge_Top ) * ( 1.d0 - SPHU(I,J,L) ) )
                enddo
                ! Work back up from the surface to get dry level edges
                do L=1,nlev+1
                   PLE(I,J,L) = AP_72(L) + ( BP_72(L) * dble(PSDry) )
                enddo
             enddo
          enddo
       endif
    endif

  end subroutine Calculate_PLE

end module GCHPctmEnv_GridCompMod

subroutine GCHPctmEnv_SetServices(gc, rc)
   use ESMF
   use GCHPctmEnv_GridCompMod, only : mySetservices => SetServices
   type(ESMF_GridComp) :: gc
   integer, intent(out) :: rc
   call mySetServices(gc, rc=rc)
end subroutine GCHPctmEnv_SetServices
