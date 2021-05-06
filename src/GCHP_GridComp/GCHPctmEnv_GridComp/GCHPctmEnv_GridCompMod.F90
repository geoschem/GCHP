#include "MAPL_Generic.h"
!-------------------------------------------------------------------------
!         NASA/GSFC, Software Systems Support Office, Code 610.3         !
!-------------------------------------------------------------------------
!BOP
!
! !MODULE: GCHPctmEnv_GridComp -- Prepares derived variables for GEOSctm
!
! !INTERFACE:
!
      module GCHPctmEnv_GridComp
!
! !USES:
      use ESMF
      use MAPL_Mod
      use FV_StateMod, only : fv_computeMassFluxes, fv_getVerticalMassFlux
      use GEOS_FV3_UtilitiesMod, only : A2D2C
      use m_set_eta,  only : set_eta

      implicit none
      private

! !PUBLIC MEMBER FUNCTIONS:

      public SetServices
      public compAreaWeightedAverage

      interface compAreaWeightedAverage
         module procedure compAreaWeightedAverage_2d
         module procedure compAreaWeightedAverage_3d
      end interface
!
! !DESCRIPTION:
! This GC is used to derive variables needed by the CTM GC children.
!
! !AUTHORS:
! Jules.Kouatchou-1@nasa.gov
! Michael Long (mlong@seas.harvard.edu)
!
! !REVISION HISTORY:
!  08 Sep 2014 - M. Long - Modification to calculate pressure at vertical
!                          grid edges from hybrid coordinates
!  24 Jan 2019 - E. Lundgren - Modification for compatibility with ESMF v7.1.0r 
!
!EOP
!-------------------------------------------------------------------------
      integer,  parameter :: r8     = 8
      integer,  parameter :: r4     = 4

      INTEGER, PARAMETER :: sp = SELECTED_REAL_KIND(6,30)
      INTEGER, PARAMETER :: dp = SELECTED_REAL_KIND(14,300)
      INTEGER, PARAMETER :: qp = SELECTED_REAL_KIND(18,400)

      real(r8), parameter :: RADIUS = MAPL_RADIUS
      real(r8), parameter :: PI     = MAPL_PI_R8
      real(r8), parameter :: D0_0   = 0.0_r8
      real(r8), parameter :: D0_5   = 0.5_r8
      real(r8), parameter :: D1_0   = 1.0_r8
      real(r8), parameter :: GPKG   = 1000.0d0
      real(r8), parameter :: MWTAIR =   28.96d0

!-------------------------------------------------------------------------
      CONTAINS
!-------------------------------------------------------------------------
!BOP
!
! !IROUTINE: SetServices -- Sets ESMF services for this component
!
! !INTERFACE:
!
      subroutine SetServices ( GC, RC )
!
! !INPUT/OUTPUT PARAMETERS:
      type(ESMF_GridComp), intent(INOUT) :: GC  ! gridded component
!
! !OUTPUT PARAMETERS:
      integer, intent(OUT)               :: RC  ! return code
!
! !LOCAL VARIABLES:
      type (ESMF_State)                  :: INTERNAL
!
! !DESCRIPTION:  
!   The SetServices for the CTM Der GC needs to register its
!   Initialize and Run.  It uses the MAPL\_Generic construct for defining 
!   state specs. 
!
!EOP
!-------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
      integer                    :: STATUS
      integer                    :: I
      type (ESMF_Config)         :: CF
      character(len=ESMF_MAXSTR) :: COMP_NAME
      character(len=ESMF_MAXSTR) :: IAm = 'SetServices'

     ! Get my name and set-up traceback handle
     ! ---------------------------------------
      call ESMF_GridCompGet( GC, NAME=COMP_NAME, CONFIG=CF, RC=STATUS )
      _VERIFY(STATUS)
      Iam = trim(COMP_NAME) // TRIM(Iam)

     ! Register services for this component
     ! ------------------------------------
      call MAPL_GridCompSetEntryPoint ( GC, ESMF_METHOD_INITIALIZE, Initialize, __RC__ )
      call MAPL_GridCompSetEntryPoint ( GC, ESMF_METHOD_RUN,  Run,        __RC__ )

! !IMPORT STATE:

      call MAPL_AddImportSpec(GC,                              &
           SHORT_NAME        = 'AREA',                         &
           LONG_NAME         = 'agrid_cell_area',              &
           UNITS             = 'm+2',                          &
           DIMS              = MAPL_DimsHorzOnly,              &
           VLOCATION         = MAPL_VLocationNone,    RC=STATUS)
      _VERIFY(STATUS)

      call MAPL_AddImportSpec ( gc,                                  &
           SHORT_NAME = 'PS1',                                       &
           LONG_NAME  = 'pressure_at_surface_before_advection',      &
           UNITS      = 'hPa',                                       &
           DIMS       = MAPL_DimsHorzOnly,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddImportSpec ( gc,                                  &
           SHORT_NAME = 'PS2',                                       &
           LONG_NAME  = 'pressure_at_surface_after_advection',       &
           UNITS      = 'hPa',                                       &
           DIMS       = MAPL_DimsHorzOnly,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddImportSpec ( gc,                                  &
           SHORT_NAME = 'SPHU1',                                     &
           LONG_NAME  = 'specific_humidity_before_advection',        &
           UNITS      = 'kg kg-1',                                   &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,           RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddImportSpec ( gc,                                  &
           SHORT_NAME = 'SPHU2',                                     &
           LONG_NAME  = 'specific_humidity_after_advection',         &
           UNITS      = 'kg kg-1',                                   &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,           RC=STATUS  )
      _VERIFY(STATUS)

!      call MAPL_AddImportSpec(GC,                                    &
!           SHORT_NAME = 'TH',                                        &
!           LONG_NAME  = 'potential_temperature',                     &
!           UNITS      = 'K',                                         &
!           DIMS       =  MAPL_DimsHorzVert,                          &
!           VLOCATION  =  MAPL_VLocationCenter,            RC=STATUS  )
!      _VERIFY(STATUS)
!
!      call MAPL_AddImportSpec(GC,                                    &
!           SHORT_NAME = 'Q',                                         &
!           LONG_NAME  = 'specific_humidity',                         &
!           UNITS      = 'kg kg-1',                                   &
!          DIMS       = MAPL_DimsHorzVert,                            &
!          VLOCATION  = MAPL_VLocationCenter,              RC=STATUS  )
!      _VERIFY(STATUS)
!
!     call MAPL_AddImportSpec(GC,                                    &
!          SHORT_NAME         = 'ZLE',                               &
!          LONG_NAME          = 'geopotential_height',               &
!          UNITS              = 'm',                                 &
!          DIMS               = MAPL_DimsHorzVert,                   &
!          VLOCATION          = MAPL_VLocationEdge,       RC=STATUS  )
!      _VERIFY(STATUS)
!
!      call MAPL_AddImportSpec ( gc,                                  &
!           SHORT_NAME = 'DELP',                                      &
!           LONG_NAME  = 'pressure_thickness',                        &
!           UNITS      = 'Pa',                                        &
!           DIMS       = MAPL_DimsHorzVert,                           &
!           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
!      _VERIFY(STATUS)

      call MAPL_AddImportSpec ( gc,                                  &
           SHORT_NAME = 'UA',                                        &
           LONG_NAME  = 'eastward_wind_on_A-Grid',                   &
           UNITS      = 'm s-1',                                     &
           STAGGERING = MAPL_AGrid,                                  &
           ROTATION   = MAPL_RotateLL,                               & 
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddImportSpec ( gc,                                  &
           SHORT_NAME = 'VA',                                        &
           LONG_NAME  = 'northward_wind_on_A-Grid',                  &
           UNITS      = 'm s-1',                                     &
           STAGGERING = MAPL_AGrid,                                  &
           ROTATION   = MAPL_RotateLL,                               &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
      _VERIFY(STATUS)

! Export State
      call MAPL_AddExportSpec(GC,                            &
        SHORT_NAME         = 'AIRDENS',                      &
        LONG_NAME          = 'air_density',                  &
        UNITS              = 'kg m-3',                       &
        DIMS               = MAPL_DimsHorzVert,              &
        VLOCATION          = MAPL_VLocationCenter,  RC=STATUS)
      _VERIFY(STATUS)

      call MAPL_AddExportSpec(GC,                            &
        SHORT_NAME         = 'MASS',                         &
        LONG_NAME          = 'total_mass',                   &
        UNITS              = 'kg',                           &
        DIMS               = MAPL_DimsHorzVert,              &
        VLOCATION          = MAPL_VLocationCenter,  RC=STATUS)
      _VERIFY(STATUS)

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'CXr8',                                      &
           LONG_NAME  = 'eastward_accumulated_courant_number',       &
           UNITS      = '',                                          &
           PRECISION  = ESMF_KIND_R8,                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'CYr8',                                      &
           LONG_NAME  = 'northward_accumulated_courant_number',      &
           UNITS      = '',                                          &
           PRECISION  = ESMF_KIND_R8,                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'MFXr8',                                     &
           LONG_NAME  = 'pressure_weighted_accumulated_eastward_mass_flux', &
           UNITS      = 'Pa m+2 s-1',                                &
           PRECISION  = ESMF_KIND_R8,                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'MFYr8',                                     &
           LONG_NAME  = 'pressure_weighted_accumulated_northward_mass_flux', &
           UNITS      = 'Pa m+2 s-1',                                &
           PRECISION  = ESMF_KIND_R8,                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
      _VERIFY(STATUS)

!---------------------------------------------------------------------
      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'CX',                                      &
           LONG_NAME  = 'eastward_accumulated_courant_number',       &
           UNITS      = '',                                          &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'CY',                                      &
           LONG_NAME  = 'northward_accumulated_courant_number',      &
           UNITS      = '',                                          &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
      _VERIFY(STATUS)
      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'MFX',                                     &
           LONG_NAME  = 'pressure_weighted_accumulated_eastward_mass_flux', &
           UNITS      = 'Pa m+2 s-1',                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'MFY',                                     &
           LONG_NAME  = 'pressure_weighted_accumulated_northward_mass_flux', &
           UNITS      = 'Pa m+2 s-1',                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationCenter,             RC=STATUS  )
      _VERIFY(STATUS)
!---------------------------------------------------------------------

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'DryPLE1r8',                                 &
           LONG_NAME  = 'dry_pressure_at_layer_edges_after_advection',&
           UNITS      = 'Pa',                                        &
           PRECISION  = ESMF_KIND_R8,                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'DryPLE0r8',                                 &
           LONG_NAME  = 'dry_pressure_at_layer_edges_before_advection',&
           UNITS      = 'Pa',                                        &
           PRECISION  = ESMF_KIND_R8,                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'PLE1r8',                                    &
           LONG_NAME  = 'pressure_at_layer_edges_after_advection',   &
           UNITS      = 'Pa',                                        &
           PRECISION  = ESMF_KIND_R8,                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'PLE0r8',                                    &
           LONG_NAME  = 'pressure_at_layer_edges_before_advection',  &
           UNITS      = 'Pa',                                        &
           PRECISION  = ESMF_KIND_R8,                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)

      call MAPL_AddExportSpec ( gc,                                  &
           SHORT_NAME = 'UpwardsMassFlux',                           &
           LONG_NAME  = 'upward_mass_flux_of_air',                   &
           UNITS      = 'kg m-2 s-1',                                &
           PRECISION  = ESMF_KIND_R8,                                &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)

      ! Internal State - MSL
      !-------------------------
      ! Store internal state with Config object in the gridded component
      CALL ESMF_UserCompSetInternalState( GC, 'ctmEnv_State', INTERNAL, STATUS )
      _VERIFY(STATUS)
      call MAPL_AddInternalSpec ( gc,                                &
           SHORT_NAME = 'PLE0',                                      &
           LONG_NAME  = 'pressure_at_layer_edges_before_advection',  &
           UNITS      = 'Pa',                                        &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)
      call MAPL_AddInternalSpec ( gc,                                &
           SHORT_NAME = 'PLE1',                                      &
           LONG_NAME  = 'pressure_at_layer_edges_after_advection',   &
           UNITS      = 'Pa',                                        &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)
      call MAPL_AddInternalSpec ( gc,                                &
           SHORT_NAME = 'DryPLE0',                                   &
           LONG_NAME  = 'dry_pressure_at_layer_edges_before_advection',&
           UNITS      = 'Pa',                                        &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)
      call MAPL_AddInternalSpec ( gc,                                &
           SHORT_NAME = 'DryPLE1',                                   &
           LONG_NAME  = 'dry_pressure_at_layer_edges_after_advection',&
           UNITS      = 'Pa',                                        &
           DIMS       = MAPL_DimsHorzVert,                           &
           VLOCATION  = MAPL_VLocationEdge,             RC=STATUS  )
      _VERIFY(STATUS)


      ! Set the Profiling timers
      !-------------------------
      call MAPL_TimerAdd(GC,    name="INITIALIZE"  ,RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_TimerAdd(GC,    name="RUN"         ,RC=STATUS)
      _VERIFY(STATUS)

      ! Create children's gridded components and invoke their SetServices
      ! -----------------------------------------------------------------
      call MAPL_GenericSetServices    ( GC, RC=STATUS )
      _VERIFY(STATUS)

      _RETURN(ESMF_SUCCESS)
  
      end subroutine SetServices
!
!EOC
!-------------------------------------------------------------------------
!BOP
!
! !IROUTINE: Initialize -- Initialized method for composite the CTMder
!
! !INTERFACE:
!
      subroutine Initialize ( GC, IMPORT, EXPORT, CLOCK, RC )
!
! !INPUT/OUTPUT PARAMETERS:
      type(ESMF_GridComp), intent(inout) :: GC     ! Gridded component 
      type(ESMF_State),    intent(inout) :: IMPORT ! Import state
      type(ESMF_State),    intent(inout) :: EXPORT ! Export state
      type(ESMF_Clock),    intent(inout) :: CLOCK  ! The clock
!
! !OUTPUT VARIABLES:
      integer, optional,   intent(  out) :: RC     ! Error code
!
! !DESCRIPTION: 
!  The Initialize method of the CTM Derived Gridded Component.
!
!EOP
!-------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
      __Iam__('Initialize')
      character(len=ESMF_MAXSTR)    :: COMP_NAME
      REAL, POINTER, DIMENSION(:,:) :: cellArea
      type(ESMF_Grid)               :: esmfGrid
      type (ESMF_VM)                :: VM
      integer                       :: im, jm, km, i
      type(MAPL_MetaComp), pointer  :: ggState      ! GEOS Generic State
      type (ESMF_Config)            :: CF
      integer                       :: dims(3)
      integer :: comm

      !  Get my name and set-up traceback handle
      !  ---------------------------------------
      call ESMF_GridCompGet( GC, NAME=COMP_NAME, CONFIG=CF, VM=VM, RC=STATUS )
      _VERIFY(STATUS)
      Iam = TRIM(COMP_NAME)//"::Initialize"

      !  Initialize GEOS Generic
      !  ------------------------
      call MAPL_GenericInitialize ( gc, IMPORT, EXPORT, clock,  RC=STATUS )
      _VERIFY(STATUS)

      !  Get my internal MAPL_Generic state
      !  -----------------------------------
      call MAPL_GetObjectFromGC ( GC, ggState, RC=STATUS)
      _VERIFY(STATUS)

      call MAPL_TimerOn(ggSTATE,"TOTAL")
      call MAPL_TimerOn(ggSTATE,"INITIALIZE")

      ! Get the grid related information
      !---------------------------------
      call ESMF_GridCompGet ( GC, GRID=esmfGrid, rc=STATUS)
      _VERIFY(STATUS)

      call MAPL_GridGet ( esmfGrid, globalCellCountPerDim=dims, RC=STATUS)
      _VERIFY(STATUS)

      im = dims(1)
      jm = dims(2)
      km = dims(3)
    
      ! Get the time-step
      ! -----------------------
      !call MAPL_GetResource( ggState, ndt, 'RUN_DT:', default=0, RC=STATUS )
      !_VERIFY(STATUS)
      !dt = ndt

      call MAPL_TimerOff(ggSTATE,"INITIALIZE")
      call MAPL_TimerOff(ggSTATE,"TOTAL")

      _RETURN(ESMF_SUCCESS)

      end subroutine Initialize
!EOC
!-------------------------------------------------------------------------
!BOP
!
! !IROUTINE: Run -- Run method
!
! !INTERFACE:
!
      subroutine Run ( GC, IMPORT, EXPORT, CLOCK, RC )
!
! !INPUT/OUTPUT PARAMETERS:
      type(ESMF_GridComp), intent(inout) :: GC     ! Gridded component 
      type(ESMF_State),    intent(inout) :: IMPORT ! Import state
      type(ESMF_State),    intent(inout) :: EXPORT ! Export state
      type(ESMF_Clock),    intent(inout) :: CLOCK  ! The clock
!
! !OUTPUT PARAMETERS:
      integer, optional,   intent(  out) :: RC     ! Error code
!
! !DESCRIPTION: 
! The Run method of the derived variables CTM Gridded Component.
!
!EOP
!-------------------------------------------------------------------------
!BOC 
!
! !LOCAL VARIABLES:
      character(len=ESMF_MAXSTR)      :: IAm = "Run"
      integer                         :: STATUS
      character(len=ESMF_MAXSTR)      :: COMP_NAME
      type (MAPL_MetaComp), pointer   :: ggState
      type (ESMF_Grid)                :: esmfGrid
      type (ESMF_State)               :: INTERNAL

      ! Imports
      !--------
      real, pointer, dimension(:,:)   ::       PS0 => null()
      real, pointer, dimension(:,:)   ::       PS1 => null()
      real, pointer, dimension(:,:,:) ::       UA  => null()
      real, pointer, dimension(:,:,:) ::       VA  => null()
      real, pointer, dimension(:,:,:) ::     SPHU0 => null()
      real, pointer, dimension(:,:,:) ::     SPHU1 => null()
      real, pointer, dimension(:,:,:) ::        th => null()
      real, pointer, dimension(:,:,:) ::         q => null()
      real, pointer, dimension(:,:,:) ::       zle => null()
      real, pointer, dimension(:,:,:) ::      DELP => null()
      real, pointer, dimension(:,:)   ::  cellArea => null()

      ! Exports
      !--------
      real,     pointer, dimension(:,:,:) ::       rho => null()
      real,     pointer, dimension(:,:,:) ::      mass => null()
      real(r8), pointer, dimension(:,:,:) ::      CXr8 => null()
      real(r8), pointer, dimension(:,:,:) ::      CYr8 => null()
      real(r8), pointer, dimension(:,:,:) ::    PLE1r8 => null()
      real(r8), pointer, dimension(:,:,:) ::    PLE0r8 => null()
      real(r8), pointer, dimension(:,:,:) :: DryPLE1r8 => null()
      real(r8), pointer, dimension(:,:,:) :: DryPLE0r8 => null()
      real(r8), pointer, dimension(:,:,:) ::     MFXr8 => null()
      real(r8), pointer, dimension(:,:,:) ::     MFYr8 => null()

!-MSL
      real, pointer, dimension(:,:,:) ::     MFX => null()
      real, pointer, dimension(:,:,:) ::     MFY => null()
      real, pointer, dimension(:,:,:) ::     CX => null()
      real, pointer, dimension(:,:,:) ::     CY => null()
!--
      real,     pointer, dimension(:,:,:) ::      UC => null()
      real,     pointer, dimension(:,:,:) ::      VC => null()
      real(r8), pointer, dimension(:,:,:) ::      UCr8 => null()
      real(r8), pointer, dimension(:,:,:) ::      VCr8 => null()
      real(r8), pointer, dimension(:,:,:) ::     PLEr8 => null()

      real,     pointer, dimension(:,:,:) ::      PLE0 => null()
      real,     pointer, dimension(:,:,:) ::      PLE1 => null()
      real,     pointer, dimension(:,:,:) ::   DryPLE0 => null()
      real,     pointer, dimension(:,:,:) ::   DryPLE1 => null()

      ! Vertical motion diagnostics
      real(r8), pointer, dimension(:,:,:) :: UpwardsMassFlux => null()

      integer               :: km, k, is, ie, js, je, lm, l, ik
      integer               :: ndt, isd, ied, jsd, jed
      real(r8), allocatable :: AP(:), BP(:)
      real(r8)              :: dt

      ! Dry pressure calculations
      integer               :: i, j
      real(r8)              :: PSDry0, PSDry1, PEdge_Bot, PEdge_Top

      logical, save         :: firstRun = .true.

#ifdef ADJOINT
      integer               :: reverseTime
#endif

      ! Get the target components name and set-up traceback handle.
      ! -----------------------------------------------------------
      call ESMF_GridCompGet ( GC, name=COMP_NAME, Grid=esmfGrid, RC=STATUS )
      _VERIFY(STATUS)
      Iam = trim(COMP_NAME) // TRIM(Iam)

      ! Get my internal MAPL_Generic state
      !-----------------------------------
      call MAPL_GetObjectFromGC ( GC, ggState, RC=STATUS )
      _VERIFY(STATUS)

      call MAPL_TimerOn(ggState,"TOTAL")
      call MAPL_TimerOn(ggState,"RUN")

      ! Get the time-step
      ! -----------------------
      call MAPL_GetResource( ggState, ndt, 'RUN_DT:', default=0, RC=STATUS )
      _VERIFY(STATUS)
      dt = ndt

#ifdef ADJOINT
      call MAPL_GetResource( ggState, reverseTime, 'REVERSE_TIME:', default=0, RC=STATUS )
      _VERIFY(STATUS)
      IF ( MAPL_Am_I_Root() ) THEN
         WRITE(*,*) ' GIGCenv REVERSE_TIME: ', reverseTime
      ENDIF
      IF ( reverseTime .eq. 1) THEN
         WRITE(*,*) ' GIGCenv swapping timestep sign.'
         dt = -dt
      ENDIF
#endif

      ! Get to the imports...
      ! ---------------------
      call MAPL_GetPointer ( IMPORT,     PS0,    'PS1', RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( IMPORT,     PS1,    'PS2', RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( IMPORT,      UA,    'UA',  RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( IMPORT,      VA,    'VA',  RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( IMPORT,   SPHU0,  'SPHU1', RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( IMPORT,   SPHU1,  'SPHU2', RC=STATUS )
      _VERIFY(STATUS)

      ! Get to the exports...
      ! ---------------------
      call MAPL_GetPointer ( EXPORT, PLE0r8, 'PLE0r8',  RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( EXPORT, PLE1r8, 'PLE1r8',  RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( EXPORT, DryPLE0r8, 'DryPLE0r8',  RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( EXPORT, DryPLE1r8, 'DryPLE1r8',  RC=STATUS )
      _VERIFY(STATUS)

      ! Reset the exports
      PLE0r8   (:,:,:) = 0.0d0
      PLE1r8   (:,:,:) = 0.0d0
      DryPLE0r8(:,:,:) = 0.0d0
      DryPLE1r8(:,:,:) = 0.0d0

      ! Get local dimensions
      is = lbound(UA,1); ie = ubound(UA,1)
      js = lbound(UA,2); je = ubound(UA,2)
      lm = size  (UA,3)

      ! Restagger A-grid winds to C-grid and rotate for CS - L.Bindle
      ! -------------------------------------------------------------
      ALLOCATE(UC(is:ie,js:je,lm), STAT=STATUS); 
      _VERIFY(STATUS)
      ALLOCATE(VC(is:ie,js:je,lm), STAT=STATUS); 
      _VERIFY(STATUS)
      UC(:,:,:) = UA(:,:,:)
      VC(:,:,:) = VA(:,:,:)
      call A2D2C(U=UC, V=VC, npz=lm, getC=.true.)

      ! Calcaulate PLE0/1 - M.Long
      ! ---------------------
#include "GEOS_HyCoords.H"
      
      ! Calculate dry surface pressure in hPa
      Do J=js,je
      Do I=is,ie
         ! Start with TOA pressure
         PSDry0 = AP(LM+1)
         PSDry1 = AP(LM+1)
         ! Stack up dry delta-P to get surface dry pressure
         Do L=1,LM
            ! Pre-advection
            PEdge_Bot = AP(L  ) + BP(L  ) * PS0(I,J)
            PEdge_Top = AP(L+1) + BP(L+1) * PS0(I,J)
            PSDry0    = PSDry0 + (PEdge_Bot - PEdge_Top) & 
                               * (1.d0 - SPHU0(I,J,L))
            ! Post-advection
            PEdge_Bot = AP(L  ) + BP(L  ) * PS1(I,J)
            PEdge_Top = AP(L+1) + BP(L+1) * PS1(I,J)
            PSDry1    = PSDry1 + (PEdge_Bot - PEdge_Top) & 
                               * (1.d0 - SPHU1(I,J,L))
         End Do
         ! Work back up from the surface to get dry level edges
         ! Do wet pressure at the same time - why not
         Do L=1,LM+1
            DryPLE0r8(I,J,L-1) = 100.d0*(AP(L)+(BP(L)*PSDry0  ))
            DryPLE1r8(I,J,L-1) = 100.d0*(AP(L)+(BP(L)*PSDry1  ))
            PLE0r8   (I,J,L-1) = 100.d0*(AP(L)+(BP(L)*PS0(I,J)))
            PLE1r8   (I,J,L-1) = 100.d0*(AP(L)+(BP(L)*PS1(I,J)))
         End Do
      End Do
      End Do


      ! Arrays were calculated so that 1 = Surface
      ! FV3 wants 1 = TOA, LM+1 = Surface
      ! Vertically flip all the arrays to accomplish this      
      DryPLE0r8(:,:,:) = DryPLE0r8(:,:,LM:0:-1)
      DryPLE1r8(:,:,:) = DryPLE1r8(:,:,LM:0:-1)
      PLE0r8   (:,:,:) = PLE0r8   (:,:,LM:0:-1)
      PLE1r8   (:,:,:) = PLE1r8   (:,:,LM:0:-1)
      UC       (:,:,:) =  UC      (:,:,LM:1:-1)
      VC       (:,:,:) =  VC      (:,:,LM:1:-1)

      DEALLOCATE( AP, BP )

      call MAPL_GetPointer ( EXPORT, MFXr8, 'MFXr8', RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( EXPORT, MFYr8, 'MFYr8', RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( EXPORT,  CXr8,  'CXr8', RC=STATUS )
      _VERIFY(STATUS)
      call MAPL_GetPointer ( EXPORT,  CYr8,  'CYr8', RC=STATUS )
      _VERIFY(STATUS)

      ! Compute the courant numbers and mass fluxes
      !--------------------------------------------
      ALLOCATE( UCr8(is:ie,js:je,lm),   STAT=STATUS); _VERIFY(STATUS)
      ALLOCATE( VCr8(is:ie,js:je,lm),   STAT=STATUS); _VERIFY(STATUS)
      ALLOCATE(PLEr8(is:ie,js:je,lm+1), STAT=STATUS); _VERIFY(STATUS)

      UCr8  = 1.00d0*(UC)
      VCr8  = 1.00d0*(VC)

      ! Use dry pressure at the start of the timestep to calculate mass
      ! fluxes. GMAO method uses mid-step UC, VC and PLE?
      PLEr8 = 1.00d0*(DryPLE0r8)

#ifdef ADJOINT
      if (.not. firstRun) THEN
#endif
      call fv_computeMassFluxes(UCr8, VCr8, PLEr8, &
                                   MFXr8, MFYr8, CXr8, CYr8, dt)
#ifdef ADJOINT
      endif
      firstRun = .false.
#endif

      !DEALLOCATE( UCr8, VCr8, PLEr8, PLE0, PLE1, DryPLE0, DryPLE1 )
      DEALLOCATE( UCr8, VCr8, PLEr8, UC, VC)

      ! Vertical motion diagnostics
      call MAPL_GetPointer ( EXPORT, UpwardsMassFlux, 'UpwardsMassFlux', ALLOC=.TRUE., RC=STATUS )
      _VERIFY(STATUS)

      ! Get vertical mass flux
      call fv_getVerticalMassFlux(MFXr8, MFYr8, UpwardsMassFlux, dt)

      ! Flip vertical so that GCHP diagnostic is positive="up"
      UpwardsMassFlux(:,:,:) = UpwardsMassFlux(:,:,LM:0:-1)

      ! LRB Note: 
      ! The upward_air_velocity could be calculated by
      !   upward_air_velocity = upward_mass_flux_of_air / air_density(edge)
      ! but calculating air_density(edge) is lossy because it requires 
      ! temperature be interpolated to the level edge. Therefore, I've 
      ! excluded it.

      call MAPL_TimerOff(ggState,"RUN")
      call MAPL_TimerOff(ggState,"TOTAL")

      ! All Done
      ! --------
      _RETURN(ESMF_SUCCESS)

      end subroutine Run
!EOC
!------------------------------------------------------------------------------
!BOP
      subroutine computeEdgePressure(PLE, PS, AK, BK, km)
!
! !INPUT PARAMETERS:
      INTEGER,  intent(in) :: km      ! number of vertical levels
      REAL(r4), intent(in) :: PS(:,:) ! Surface pressure (Pa)
      REAL(r8), intent(in) :: ak(km+1), bk(km+1)
!
! !OUTPUT PARAMETERS:
      REAL(r4), intent(out) :: PLE(:,:,:)  ! Edge pressure (Pa)
!EOP
!------------------------------------------------------------------------------
!BOC
      INTEGER  :: L
      
      DO L = 1, km
         PLE(:,:,L) = ak(L) + bk(L)*PS(:,:)
      END DO

      RETURN

      end subroutine computeEdgePressure
!EOC
!------------------------------------------------------------------------------
!BOP
      subroutine computeLWI(LWI, TSKIN, FRLAKE, FROCEAN, FRSEAICE)
!
! !INPUT PARAMETERS:
     REAL(r4), intent(in) :: TSKIN(:,:)    ! Surface skin temperature (K)
     REAL(r4), intent(in) :: FRLAKE(:,:)   ! Fraction of lake type in grid box (1)
     REAL(r4), intent(in) :: FROCEAN(:,:)  ! Fraction of ocean in grid box (1)
     REAL(r4), intent(in) :: FRSEAICE(:,:) ! Ice covered fraction of tile (1)
!
! !OUTPUT PARAMETERS:
     REAL(r4), intent(out) :: LWI(:,:) ! Land water ice flag (1)
!
!EOP
!------------------------------------------------------------------------------
!BOC

                                          LWI = 1.0  ! Land
      where ( FROCEAN+FRLAKE >= 0.6     ) LWI = 0.0  ! Water
      where ( LWI==0 .and. FRSEAICE>0.5 ) LWI = 2.0  ! Ice
      where ( LWI==0 .and. TSKIN<271.40 ) LWI = 2.0  ! Ice

      RETURN

      end subroutine computeLWI
!EOC
!------------------------------------------------------------------------------
!BOP
      subroutine computeRelativeHumidity(RH2, PRESS3D, T, QV)

!
! !INPUT PARAMETERS:
      REAL, intent(in) :: PRESS3D(:,:,:)  ! Pressure (Pa)
      REAL, intent(in) :: T      (:,:,:)  ! Air temperature (K)
      REAL, intent(in) :: QV     (:,:,:)  ! Specific humidity (kg/kg)
!
! !OUTPUT PARAMETERS:
      REAL, intent(out) :: RH2(:,:,:) ! Relative humidity (1)
!
!EOP
!------------------------------------------------------------------------------
!BOC

      ! -----------------------------------------------------------------
      ! First calculate relative humidity from Seinfeld (1986) p. 181.
      ! The first  RH2 is the temperature dependent parameter a.
      ! The second RH2 is the saturation vapor pressure of water.
      ! The third  RH2 is the actual relative humidity as a fraction.
      ! Then make sure RH2 is between 0 and 0.95.
      !-----------------------------------------------------------------

      RH2(:,:,:) = 1.0d0 - (373.15d0 / T(:,:,:))

      RH2(:,:,:) =  &
             1013.25d0 * Exp (13.3185d0 * RH2(:,:,:)    -  &
                               1.9760d0 * RH2(:,:,:)**2 -  &
                               0.6445d0 * RH2(:,:,:)**3 -  &
                               0.1299d0 * RH2(:,:,:)**4)

      RH2(:,:,:) = QV(:,:,:) * MWTAIR / 18.0d0 /  &
                      GPKG * PRESS3D(:,:,:) / RH2(:,:,:)

      RH2(:,:,:) = Max (Min (RH2(:,:,:), 0.95d0), 0.0d0)

      RETURN 

      end subroutine computeRelativeHumidity
!EOC
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINES: airdens
!
! !INTERFACE:

      subroutine airdens_ ( rho, pe, th, q )
!
! !INPUT PARAMETERS:
      real,    intent(in) :: pe(:,:,:)      ! pressure edges
      real,    intent(in) :: th(:,:,:)      ! (dry) potential temperature
      real,    intent(in) :: q(:,:,:)       ! apecific humidity
!
! !OUTPUT PARAMETERS:
      real,    intent(out) :: rho(:,:,:)    ! air density [kg/m3]
!
! !DESCRIPTION:
! Computes the air density that might be needed when GEOSchem is not
! exercised.
!
!EOP
!-----------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
      integer :: k, iml, jml, nl     ! dimensions
      real :: eps
      integer :: STATUS, RC
      character(len=ESMF_MAXSTR)      :: IAm = "airdens_"
      real, allocatable :: npk(:,:,:) ! normalized pk = (pe/p0)^kappa

      iml = size(q,1);  jml = size(q,2);  nl = size(q,3)

      allocate(npk(iml,jml,nl+1),stat=STATUS) ! work space
      _VERIFY(STATUS)

      eps = MAPL_RVAP / MAPL_RGAS - 1.0

      ! Compute normalized pe**Kappa
      ! ----------------------------
      npk = (pe/MAPL_P00)**MAPL_KAPPA

      ! Compute rho from hydrostatic equation
      ! -------------------------------------
      do k = 1, nl
         rho(:,:,k) =       ( pe(:,:,k+1) - pe(:,:,k) ) /      &
                      ( MAPL_CP * ( th(:,:,k)*(1. + eps*q(:,:,k) ) ) &
                              * ( npk(:,:,k+1) - npk(:,:,k) ) )
      end do

      deallocate(npk)

      end subroutine airdens_
!EOC
!-----------------------------------------------------------------------
!BOP
      function compAreaWeightedAverage_2d (var2D, vm, cellArea) result(wAverage)
!
! !INPUT PARAMETER:
      real            :: var2D(:,:)
      real            :: cellArea(:,:)
      type (ESMF_VM)  :: VM
!
! RETURNED VALUE:
      real  :: wAverage
!
! DESCRIPTION:
! Computes the area weighted average of a 2d variable.
!
!EOP
!-----------------------------------------------------------------------
!BOC
      logical, save :: first = .true.
      real(r8) , save :: sumArea
      real(r8) :: sumWeight
      integer :: ik, im, jm, STATUS, RC
      real(r8), pointer :: weightVals(:,:)
      real(r8) :: sumWeight_loc, sumArea_loc
      character(len=ESMF_MAXSTR) :: IAm = 'compAreaWeightedAverage_2d'

      ! Determine the earth surface area
      if (first) then
         sumArea_loc   = SUM( cellArea  (:,:)  )
         call MAPL_CommsAllReduceSum(vm, sendbuf= sumArea_loc, &
                                         recvbuf= sumArea, &
                                         cnt=1, RC=status)
         _VERIFY(STATUS)

         first = .false.
      end if

      im = size(cellArea,1)
      jm = size(cellArea,2)

      allocate(weightVals(im,jm))
      weightVals(:,:) = cellArea(:,:)*var2D(:,:)

      sumWeight_loc = SUM( weightVals(:,:) )

      call MAPL_CommsAllReduceSum(vm, sendbuf= sumWeight_loc, recvbuf= sumWeight, &
         cnt=1, RC=status)
      _VERIFY(STATUS)

      wAverage = sumWeight/sumArea

      deallocate(weightVals)

      return

      end function compAreaWeightedAverage_2d
!EOC
!-----------------------------------------------------------------------
!BOP
      function compAreaWeightedAverage_3d (var3D, vm, cellArea) result(wAverage)
!
! !INPUT PARAMETER:
      real            :: var3D(:,:,:)
      real            :: cellArea(:,:)
      type (ESMF_VM)  :: VM
!
! RETURNED VALUE:
      real  :: wAverage
!
! DESCRIPTION:
! Computes the area weighted average of a 3d variable.
!
!EOP
!-----------------------------------------------------------------------
!BOC
      logical, save :: first = .true.
      real(r8) , save :: sumArea
      real(r8) :: sumWeight
      integer :: ik, im, jm, STATUS, RC
      real(r8), pointer :: weightVals(:,:)
      real(r8) :: sumWeight_loc, sumArea_loc
      character(len=ESMF_MAXSTR) :: IAm = 'compAreaWeightedAverage_3d'

      ! Determine the earth surface area
      if (first) then
         sumArea_loc   = SUM( cellArea  (:,:)  )
         call MAPL_CommsAllReduceSum(vm, sendbuf= sumArea_loc, &
                                         recvbuf= sumArea, &
                                         cnt=1, RC=status)
         _VERIFY(STATUS)

         first = .false.
      end if

      im = size(cellArea,1)
      jm = size(cellArea,2)

      allocate(weightVals(im,jm))
      weightVals(:,:) = 0.0d0
      DO ik = lbound(var3D,3), ubound(var3D,3)
         weightVals(:,:) = weightVals(:,:) + cellArea(:,:)*var3D(:,:,ik)
      END DO

      sumWeight_loc = SUM( weightVals(:,:) )

      call MAPL_CommsAllReduceSum(vm, sendbuf= sumWeight_loc, recvbuf= sumWeight, &
         cnt=1, RC=status)
      _VERIFY(STATUS)

      wAverage = sumWeight/sumArea

      deallocate(weightVals)

      return

      end function compAreaWeightedAverage_3d
!EOC
!-----------------------------------------------------------------------
      end module GCHPctmEnv_GridComp
