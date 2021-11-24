#include "MAPL_Generic.h"

module GCHPctmEnv_GridComp
   use ESMF
   use MAPL_Mod
   use FV_StateMod, only : fv_computeMassFluxes, fv_getVerticalMassFlux
   use GEOS_FV3_UtilitiesMod, only : A2D2C
   use m_set_eta,  only : set_eta
   use pFlogger, only: logging, Logger
   
   implicit none
   private
   
   public SetServices
   
   integer, parameter :: r8     = 8
   integer, parameter :: r4     = 4
   
   logical :: meteorology_vertical_index_is_top_down
   logical :: import_mass_flux_from_extdata = .false.
   
   class(Logger), pointer :: lgr => null()
   
   public import_mass_flux_from_extdata
   
   contains
   

   subroutine SetServices(GC, RC)
      type(ESMF_GridComp), intent(INOUT) :: GC  ! gridded component
      integer, intent(OUT)               :: RC  ! return code

      integer :: STATUS
      type (ESMF_Config) :: CF
      character(len=ESMF_MAXSTR) :: COMP_NAME
      character(len=ESMF_MAXSTR) :: IAm = 'SetServices'
      
      ! Get my name and set-up traceback handle
      call ESMF_GridCompGet(GC, NAME=COMP_NAME, CONFIG=CF, RC=STATUS)
      _VERIFY(STATUS)
      Iam = trim(COMP_NAME) // TRIM(Iam)
      
      lgr => logging%get_logger('GCHPctmEnv')
      
      call ESMF_ConfigGetAttribute(CF,value=import_mass_flux_from_extdata, &
      label='IMPORT_MASS_FLUX_FROM_EXTDATA:', Default=.false., __RC__)
      if (import_mass_flux_from_extdata) then
         call lgr%info('Configured to import mass fluxes from ''ExtData''')
      else
         call lgr%info('Configured to calculate and export mass flux and courant numbers')
      end if
      
      ! Register services for this component
      call MAPL_GridCompSetEntryPoint(gc, ESMF_METHOD_INITIALIZE, Initialize, RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_GridCompSetEntryPoint(gc, ESMF_METHOD_RUN, Run, RC=STATUS)
      _VERIFY(STATUS)
      
      call lgr%debug('Adding import specs')
      call MAPL_AddImportSpec(gc, &
                              SHORT_NAME='AREA', &
                              LONG_NAME='agrid_cell_area', &
                              UNITS='m+2', &
                              DIMS=MAPL_DimsHorzOnly, &
                              VLOCATION=MAPL_VLocationNone, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddImportSpec(gc, &
                              SHORT_NAME='PS1', &
                              LONG_NAME='pressure_at_surface_before_advection', &
                              UNITS='hPa', &
                              DIMS=MAPL_DimsHorzOnly, &
                              VLOCATION=MAPL_VLocationEdge, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddImportSpec(gc, &
                              SHORT_NAME='PS2', &
                              LONG_NAME='pressure_at_surface_after_advection', &
                              UNITS='hPa', &
                              DIMS=MAPL_DimsHorzOnly, &
                              VLOCATION=MAPL_VLocationEdge, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddImportSpec(gc, &
                              SHORT_NAME='SPHU1', &
                              LONG_NAME='specific_humidity_before_advection', &
                              UNITS='kg kg-1', &
                              DIMS=MAPL_DimsHorzVert, &
                              VLOCATION=MAPL_VLocationCenter, &
                              RC=STATUS)
      _VERIFY(STATUS)
      if (.not. import_mass_flux_from_extdata) then
         call MAPL_AddImportSpec(gc, &
                                 SHORT_NAME='UA', &
                                 LONG_NAME='eastward_wind_on_A-Grid', &
                                 UNITS='m s-1', &
                                 STAGGERING=MAPL_AGrid, &
                                 ROTATION=MAPL_RotateLL, & 
                                 DIMS=MAPL_DimsHorzVert, &
                                 VLOCATION=MAPL_VLocationCenter, &
                                 RC=STATUS)
         _VERIFY(STATUS)
         call MAPL_AddImportSpec(gc, &
                                 SHORT_NAME='VA', &
                                 LONG_NAME='northward_wind_on_A-Grid', &
                                 UNITS='m s-1', &
                                 STAGGERING=MAPL_AGrid, &
                                 ROTATION=MAPL_RotateLL, &
                                 DIMS=MAPL_DimsHorzVert, &
                                 VLOCATION=MAPL_VLocationCenter, &
                                 RC=STATUS)
         _VERIFY(STATUS)
      else
         call MAPL_AddImportSpec(gc, &
                                 SHORT_NAME='MFXC', &
                                 LONG_NAME='pressure_weighted_xward_mass_flux', &
                                 UNITS='Pa m+2 s-1', &
                                 DIMS=MAPL_DimsHorzVert, &
                                 VLOCATION=MAPL_VLocationCenter, &
                                 RC=STATUS)
         VERIFY_(STATUS)
         call MAPL_AddImportSpec(gc, &
                                 SHORT_NAME='MFYC', &
                                 LONG_NAME='pressure_weighted_yward_mass_flux', &
                                 UNITS='Pa m+2 s-1', &
                                 DIMS=MAPL_DimsHorzVert, &
                                 VLOCATION=MAPL_VLocationCenter, &
                                 RC=STATUS)
         VERIFY_(STATUS)
         call MAPL_AddImportSpec(gc, &
                                 SHORT_NAME='CXC', &
                                 LONG_NAME='xward_accumulated_courant_number', &
                                 UNITS='', &
                                 DIMS=MAPL_DimsHorzVert, &
                                 VLOCATION=MAPL_VLocationCenter, &
                                 RC=STATUS)
         VERIFY_(STATUS)
         call MAPL_AddImportSpec(gc, &
                                 SHORT_NAME='CYC', &
                                 LONG_NAME='yward_accumulated_courant_number', &
                                 UNITS='', &
                                 DIMS=MAPL_DimsHorzVert, &
                                 VLOCATION=MAPL_VLocationCenter, &
                                 RC=STATUS)
         VERIFY_(STATUS)
      end if
      
      call lgr%debug('Adding export specs')
      call MAPL_AddExportSpec(gc, &
                              SHORT_NAME='SPHU0', &
                              LONG_NAME='specific_humidity_before_advection', &
                              UNITS='kg kg-1', &
                              PRECISION=ESMF_KIND_R8, &
                              DIMS=MAPL_DimsHorzVert, &
                              VLOCATION=MAPL_VLocationCenter, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddExportSpec(gc, &
                              SHORT_NAME='PLE0', &
                              LONG_NAME='pressure_at_layer_edges_before_advection', &
                              UNITS='Pa', &
                              PRECISION=ESMF_KIND_R8, &
                              DIMS=MAPL_DimsHorzVert, &
                              VLOCATION=MAPL_VLocationEdge, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddExportSpec(gc, &
                              SHORT_NAME='PLE1', &
                              LONG_NAME='pressure_at_layer_edges_after_advection', &
                              UNITS='Pa', &
                              PRECISION=ESMF_KIND_R8, &
                              DIMS=MAPL_DimsHorzVert, &
                              VLOCATION=MAPL_VLocationEdge, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddExportSpec(GC, &
                              SHORT_NAME='AIRDENS', &
                              LONG_NAME='air_density', &
                              UNITS='kg m-3', &
                              DIMS=MAPL_DimsHorzVert, &
                              VLOCATION=MAPL_VLocationCenter, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddExportSpec(gc, &
                              SHORT_NAME='CX', &
                              LONG_NAME='xward_accumulated_courant_number', &
                              UNITS='', &
                              PRECISION=ESMF_KIND_R8, &
                              DIMS=MAPL_DimsHorzVert, &
                              VLOCATION=MAPL_VLocationCenter, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddExportSpec(gc, &
                              SHORT_NAME='CY', &
                              LONG_NAME='yward_accumulated_courant_number', &
                              UNITS='', &
                              PRECISION=ESMF_KIND_R8, &
                              DIMS=MAPL_DimsHorzVert, &
                              VLOCATION=MAPL_VLocationCenter, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddExportSpec(gc, &
                              SHORT_NAME='MFX', &
                              LONG_NAME='pressure_weighted_accumulated_xward_mass_flux', &
                              UNITS='Pa m+2 s-1', &
                              PRECISION=ESMF_KIND_R8, &
                              DIMS=MAPL_DimsHorzVert, &
                              VLOCATION=MAPL_VLocationCenter, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddExportSpec(gc, &
                              SHORT_NAME='MFY', &
                              LONG_NAME='pressure_weighted_accumulated_yward_mass_flux', &
                              UNITS='Pa m+2 s-1', &
                              PRECISION=ESMF_KIND_R8, &
                              DIMS=MAPL_DimsHorzVert, &
                              VLOCATION=MAPL_VLocationCenter, &
                              RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_AddExportSpec(gc, &
                              SHORT_NAME='UpwardsMassFlux', &
                              LONG_NAME='upward_mass_flux_of_air', &
                              UNITS='kg m-2 s-1', &
                              PRECISION=ESMF_KIND_R8, &
                              DIMS=MAPL_DimsHorzVert, &
                              VLOCATION=MAPL_VLocationEdge, &
                              RC=STATUS)
      _VERIFY(STATUS)
      
      call lgr%debug('Adding timers')
      call MAPL_TimerAdd(gc, name="INITIALIZE", RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_TimerAdd(gc, name="RUN", RC=STATUS)
      _VERIFY(STATUS)
      
      call lgr%debug('Calling MAPL_GenericSetServices')
      call MAPL_GenericSetServices(gc, RC=STATUS)
      _VERIFY(STATUS)
      
      _RETURN(ESMF_SUCCESS)
      
   end subroutine SetServices


   subroutine Initialize(GC, IMPORT, EXPORT, CLOCK, RC)
      type(ESMF_GridComp), intent(inout) :: GC     ! Gridded component 
      type(ESMF_State),    intent(inout) :: IMPORT ! Import state
      type(ESMF_State),    intent(inout) :: EXPORT ! Export state
      type(ESMF_Clock),    intent(inout) :: CLOCK  ! The clock
      integer, optional,   intent(out)   :: RC     ! Error code

      ! Locals
      __Iam__('Initialize')
      character(len=ESMF_MAXSTR) :: COMP_NAME
      REAL, POINTER, DIMENSION(:,:) :: cellArea
      type(ESMF_Grid) :: esmfGrid
      type (ESMF_VM) :: VM
      type(MAPL_MetaComp), pointer :: ggState      ! GEOS Generic State
      type (ESMF_Config) :: CF
      integer :: comm
      
      !  Get my name and set-up traceback handle
      call ESMF_GridCompGet(GC, NAME=COMP_NAME, CONFIG=CF, VM=VM, RC=STATUS)
      _VERIFY(STATUS)
      Iam = TRIM(COMP_NAME)//"::Initialize"
      
      !  Initialize GEOS Generic
      call MAPL_GenericInitialize(gc, IMPORT, EXPORT, clock, RC=STATUS)
      _VERIFY(STATUS)
      
      !  Get my internal MAPL_Generic state
      call MAPL_GetObjectFromGC(GC, ggState, RC=STATUS)
      _VERIFY(STATUS)
      
      call MAPL_TimerOn(ggSTATE, "TOTAL")
      call MAPL_TimerOn(ggSTATE, "INITIALIZE")
      
      ! Get the grid related information
      call ESMF_GridCompGet(GC, GRID=esmfGrid, rc=STATUS)
      _VERIFY(STATUS)
      
      call ESMF_ConfigGetAttribute(CF,value=meteorology_vertical_index_is_top_down, &
      label='METEOROLOGY_VERTICAL_INDEX_IS_TOP_DOWN:', Default=.false., __RC__)
      if (meteorology_vertical_index_is_top_down) then
         call lgr%info('Configured to expect ''top-down'' meteorological data from ''ExtData''')
      else
         call lgr%info('Configured to expect ''bottom-up'' meteorological data from ''ExtData''')
      end if
      
      call MAPL_TimerOff(ggSTATE,"INITIALIZE")
      call MAPL_TimerOff(ggSTATE,"TOTAL")
      
      _RETURN(ESMF_SUCCESS)
      
   end subroutine


   subroutine Run(GC, IMPORT, EXPORT, CLOCK, RC)
      type(ESMF_GridComp), intent(inout) :: GC     ! Gridded component 
      type(ESMF_State),    intent(inout) :: IMPORT ! Import state
      type(ESMF_State),    intent(inout) :: EXPORT ! Export state
      type(ESMF_Clock),    intent(inout) :: CLOCK  ! The clock
      integer, optional,   intent(out) :: RC       ! Error code

      ! Locals
      character(len=ESMF_MAXSTR) :: IAm = "Run"
      integer :: STATUS
      character(len=ESMF_MAXSTR) :: COMP_NAME
      type (MAPL_MetaComp), pointer :: ggState
      type (ESMF_Grid) :: esmfGrid

      ! Locals
      real(r8), pointer  :: PLE(:,:,:) ! Edge pressures
      integer :: ndt
      real(r8) :: dt
      
      logical, save :: firstRun = .true.
      
#ifdef ADJOINT
      integer :: reverseTime
#endif
      
      ! Get the target components name and set-up traceback handle.
      call ESMF_GridCompGet(GC, name=COMP_NAME, Grid=esmfGrid, RC=STATUS)
      _VERIFY(STATUS)
      Iam = trim(COMP_NAME) // TRIM(Iam)
      
      ! Get my internal MAPL_Generic state
      call MAPL_GetObjectFromGC(GC, ggState, RC=STATUS)
      _VERIFY(STATUS)
      
      call MAPL_TimerOn(ggState,"TOTAL")
      call MAPL_TimerOn(ggState,"RUN")
      
      ! Get the time-step
      call MAPL_GetResource(ggState, ndt, 'RUN_DT:', default=0, RC=STATUS)
      _VERIFY(STATUS)
      dt = ndt
      
#ifdef ADJOINT
      call MAPL_GetResource(ggState, reverseTime, 'REVERSE_TIME:', default=0, RC=STATUS)
      _VERIFY(STATUS)
      IF(MAPL_Am_I_Root()) THEN
         WRITE(*,*) ' GIGCenv REVERSE_TIME: ', reverseTime
      ENDIF
      IF(reverseTime .eq. 1) THEN
         WRITE(*,*) ' GIGCenv swapping timestep sign.'
         dt = -dt
      ENDIF
#endif
      
      call prepare_ple_exports(IMPORT, EXPORT, PLE, RC=STATUS)
      _VERIFY(STATUS)
      call prepare_sphu_export(IMPORT, EXPORT, RC=STATUS)
      _VERIFY(STATUS)
      call prepare_massflux_exports(IMPORT, EXPORT, PLE, dt, RC=STATUS)
      _VERIFY(STATUS)

      call MAPL_TimerOff(ggState,"RUN")
      call MAPL_TimerOff(ggState,"TOTAL")
      
      _RETURN(ESMF_SUCCESS)
   end subroutine


   subroutine prepare_ple_exports(IMPORT, EXPORT, PLE, RC)
      type(ESMF_State), intent(inout)  :: IMPORT
      type(ESMF_State), intent(inout)  :: EXPORT
      real(r8), intent(out), pointer   :: PLE(:,:,:) ! Edge pressures
      integer, optional, intent(out)   :: RC

      ! Locals
      real, pointer, dimension(:,:)       ::  PS1_IMPORT => null()
      real(r8), pointer, dimension(:,:,:) :: PLE0_EXPORT => null()
      real(r8), pointer, dimension(:,:,:) :: PLE1_EXPORT => null()
      integer :: num_levels
      integer :: STATUS

      call MAPL_GetPointer(IMPORT, PS1_IMPORT,    'PS1', RC=STATUS)
      _VERIFY(STATUS)

      call MAPL_GetPointer(EXPORT, PLE0_EXPORT,  'PLE0',  RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_GetPointer(EXPORT, PLE1_EXPORT,  'PLE1',  RC=STATUS)
      _VERIFY(STATUS)

      num_levels = size(PLE0_EXPORT,3) - 1

      PLE0_EXPORT(:,:,:)  = 0.0d0
      PLE1_EXPORT(:,:,:)  = 0.0d0

      ! Calculate PLE[01]_EXPORT (for FV3, thus, export with top-down index)
      call calculate_ple(PS1_IMPORT, PLE0_EXPORT)    ! output is bottom-up, units are hPa
      PLE0_EXPORT = 100.0d0*PLE0_EXPORT              ! convert hPa to Pa
      PLE0_EXPORT = PLE0_EXPORT(:,:,num_levels:0:-1) ! flip
      PLE1_EXPORT = PLE0_EXPORT                      ! copy PLE0 to PLE1

      PLE=>PLE0_EXPORT

      _RETURN(ESMF_SUCCESS)
   end subroutine


   subroutine prepare_sphu_export(IMPORT, EXPORT, RC)
      type(ESMF_State), intent(inout) :: IMPORT
      type(ESMF_State), intent(inout) :: EXPORT
      integer, optional, intent(out)  :: RC
      integer :: LM

      ! Locals
      real, pointer, dimension(:,:,:)     :: SPHU1_IMPORT => null()
      real(r8), pointer, dimension(:,:,:) :: SPHU0_EXPORT => null()
      integer :: STATUS

      call MAPL_GetPointer(IMPORT, SPHU1_IMPORT,  'SPHU1', RC=STATUS)
      _VERIFY(STATUS)
      
      call MAPL_GetPointer(EXPORT, SPHU0_EXPORT, 'SPHU0', RC=STATUS)
      _VERIFY(STATUS)

      SPHU0_EXPORT(:,:,:) = 0.0d0

      LM = size(SPHU1_IMPORT, 3)

      ! Calculate SPHU0_EXPORT (for FV3, thus, export with top-down index)
      if (meteorology_vertical_index_is_top_down) then 
         SPHU0_EXPORT = dble(SPHU1_IMPORT)
      else
         SPHU0_EXPORT(:,:,:) = dble(SPHU1_IMPORT(:,:,LM:1:-1))
      end if

      _RETURN(ESMF_SUCCESS)
   end subroutine

   subroutine prepare_massflux_exports(IMPORT, EXPORT, PLE, dt, RC)
      type(ESMF_State), intent(inout) :: IMPORT
      type(ESMF_State), intent(inout) :: EXPORT
      real(r8), intent(in), pointer   :: PLE(:,:,:) ! Edge pressures
      real(r8), intent(in)            :: dt
      integer, optional, intent(out)  :: RC       ! Error code

      real, pointer, dimension(:,:,:)     :: UA_IMPORT  => null()
      real, pointer, dimension(:,:,:)     :: VA_IMPORT  => null()
      real(r8), pointer, dimension(:,:,:) :: CX_EXPORT => null()
      real(r8), pointer, dimension(:,:,:) :: CY_EXPORT => null()
      real(r8), pointer, dimension(:,:,:) :: MFX_EXPORT => null()
      real(r8), pointer, dimension(:,:,:) :: MFY_EXPORT => null() 
      real(r8), pointer, dimension(:,:,:) :: UpwardsMassFlux => null()

      real, pointer, dimension(:,:,:) :: temp3_r4  => null()
      real, pointer, dimension(:,:,:) :: UC => null()
      real, pointer, dimension(:,:,:) :: VC => null()
      real(r8), pointer, dimension(:,:,:) :: UCr8 => null()
      real(r8), pointer, dimension(:,:,:) :: VCr8 => null()
      integer :: is, ie, js, je, lm
      integer :: STATUS


      is = lbound(PLE, 1); ie = ubound(PLE, 1)
      js = lbound(PLE, 2); je = ubound(PLE, 2)
      lm = size(PLE, 3) - 1

      call MAPL_GetPointer(EXPORT, MFX_EXPORT, 'MFX', RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_GetPointer(EXPORT, MFY_EXPORT, 'MFY', RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_GetPointer(EXPORT, CX_EXPORT, 'CX', RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_GetPointer(EXPORT, CY_EXPORT, 'CY', RC=STATUS)
      _VERIFY(STATUS)
      if (.not. import_mass_flux_from_extdata) then
         call MAPL_GetPointer(IMPORT, UA_IMPORT, 'UA', RC=STATUS)
         _VERIFY(STATUS)
         call MAPL_GetPointer(IMPORT, VA_IMPORT, 'VA', RC=STATUS)
         _VERIFY(STATUS)
         
         ! Temporaries
         ALLOCATE(UC(is:ie,js:je,lm), STAT=STATUS); 
         _VERIFY(STATUS)
         ALLOCATE(VC(is:ie,js:je,lm), STAT=STATUS); 
         _VERIFY(STATUS)
         ALLOCATE(UCr8(is:ie,js:je,lm), STAT=STATUS); 
         _VERIFY(STATUS)
         ALLOCATE(VCr8(is:ie,js:je,lm), STAT=STATUS); 
         _VERIFY(STATUS)
         
         ! Prepare inputs to fv_computeMassFluxes
         if (meteorology_vertical_index_is_top_down) then
            UC(:,:,:) = UA_IMPORT(:,:,:)
            VC(:,:,:) = VA_IMPORT(:,:,:)
         else
            UC(:,:,:) = UA_IMPORT(:,:,LM:1:-1)
            VC(:,:,:) = VA_IMPORT(:,:,LM:1:-1)
         end if
         
         ! Restagger winds (A-grid to C-grid)
         call A2D2C(U=UC, V=VC, npz=lm, getC=.true.) ! real4 only
         
         ! Convert real4->real8 for fv_computeMassFluxes 
         UCr8  = dble(UC)
         VCr8  = dble(VC)
         
#ifdef ADJOINT
         if (.not. firstRun) THEN
#endif
            ! Calculate mass fluxes and courant numbers
            call fv_computeMassFluxes(UCr8, VCr8, PLE, &
                                      MFX_EXPORT, MFY_EXPORT, & 
                                      CX_EXPORT, CY_EXPORT, dt)
#ifdef ADJOINT
         endif
         firstRun = .false.
#endif
         
         ! Deallocate temporaries
         DEALLOCATE(UC, VC, UCr8, VCr8)
      else
         ! Convert MF[XY]C and C[XY]C imports to real8 exports
         call MAPL_GetPointer(IMPORT, temp3_r4, 'MFXC',  RC=STATUS)
         _VERIFY(STATUS)
         MFX_EXPORT = dble(temp3_r4)
         
         call MAPL_GetPointer(IMPORT, temp3_r4, 'MFYC',  RC=STATUS)
         _VERIFY(STATUS)
         MFY_EXPORT = dble(temp3_r4)
         
         call MAPL_GetPointer(IMPORT, temp3_r4, 'CXC',  RC=STATUS)
         _VERIFY(STATUS)
         CX_EXPORT = dble(temp3_r4)
         
         call MAPL_GetPointer(IMPORT, temp3_r4, 'CYC',  RC=STATUS)
         _VERIFY(STATUS)
         CY_EXPORT = dble(temp3_r4)
      end if

      ! Vertical motion diagnostics
      call MAPL_GetPointer(EXPORT, UpwardsMassFlux, 'UpwardsMassFlux', RC=STATUS)
      _VERIFY(STATUS)
      
      if (associated(UpwardsMassFlux)) then
         ! Get vertical mass flux
         call fv_getVerticalMassFlux(MFX_EXPORT, MFY_EXPORT, UpwardsMassFlux, dt)
         ! Flip vertical so that GCHP diagnostic is positive="up"
         UpwardsMassFlux(:,:,:) = UpwardsMassFlux(:,:,LM:0:-1)
      end if

      _RETURN(ESMF_SUCCESS)
   end subroutine
   

   subroutine calculate_ple(PS, PLE)
      real(r4), intent(in)    :: PS(:,:)    ! Surface pressure [hPa]
      real(r8), intent(out)   :: PLE(:,:,:) ! Edge pressure    [hPa]
      integer, parameter      :: num_levels = 72
      integer, parameter      :: num_edges = num_levels + 1
      real(r8)                :: AP(num_edges), BP(num_edges)
      integer                 :: L
      
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
      
      ! Calculate level edges
      Do L=1,num_edges
         PLE(:,:,L) = (AP(L) + (BP(L) * dble(PS(:,:))))
      End Do
   end subroutine
   
end module GCHPctmEnv_GridComp
