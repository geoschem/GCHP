#ifdef MAPL3
#include "MAPL.h"
#else
#include "MAPL_Generic.h"
#endif

#ifdef MAPL3
module GCHP_GridCompMod

  use ESMF
  use mapl3
  use fv_arrays_mod, only: REAL4, REAL8
  use pflogger, only: logger_t => logger

  implicit none
  private

  public SetServices
  public Initialize
  public Run
  public Finalize

  integer,  parameter :: r4 = REAL4
  integer,  parameter :: r8 = REAL8

contains

  !=============================================================================
  ! SetServices -- Sets ESMF services for this component

  subroutine SetServices ( GC, RC )

    use mapl3g_generic, only : MAPL_GridCompAddSpec, MAPL_GridCompAddConnectivity

    type(ESMF_GridComp)  :: gc     ! composite gridded component
    integer, intent(out) :: rc     ! Error code, 0 all is well

    integer :: status
    class(logger_t), pointer :: logger

    call MAPL_GridCompGet(gc, logger=logger, _RC)
    call logger%debug("GCHP_GridCompMod.F90::SetServices starting...")

!    ! Add imports (alternatively can use GCHP_StateSpec.rc in source code to auto-generate). This is just for testing. Do not need imports in this gridcomp! 
!    call MAPL_GridCompAddSpec(gridcomp=gc, &
!         short_name='PS1', &
!         standard_name='Met surface pressure at time before advection', &
!         units='hPa', &
!         dims='xy', &
!         vstagger=VERTICAL_STAGGER_NONE, &
!         state_intent=ESMF_STATEINTENT_IMPORT, &
!         _RC)
!
!    call MAPL_GridCompAddSpec(gridcomp=gc, &
!         short_name='PS2', &
!         standard_name='Met surface pressure at time after advection', &
!         units='hPa', &
!         dims='xy', &
!         vstagger=VERTICAL_STAGGER_NONE, &
!         state_intent=ESMF_STATEINTENT_IMPORT, &
!         _RC)
!
!    call MAPL_GridCompAddSpec(gridcomp=gc, &
!         short_name='SPHU1', &
!         standard_name='Specific humidity', &
!         units='kg/kg', &
!         dims='xyz', &
!         vstagger=VERTICAL_STAGGER_CENTER, &
!         state_intent=ESMF_STATEINTENT_IMPORT, &
!         _RC)

    ! Add connections for children
    call MAPL_GridCompAddConnectivity(gridcomp=gc, &
         src_comp='GCHPctmEnv', &
         src_names='PLE0, PLE1, DryPLE0, DryPLE1, SPHU0', &
         dst_comp='FVdycoreCubed', &
         dst_names='PLE0, PLE1, DryPLE0, DryPLE1, SPHU0', &
         _RC)
!
!    call MAPL_GridCompAddConnectivity(gridcomp=gc, &
!         src_comp='FVdycoreCubed', &
!         src_names='AREA', &
!         dst_comp='GEOSchem', &
!         dst_names='AREA', &
!         _RC)

    ! Register services for this component
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Initialize,  Initialize, _RC)
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Run, Run, phase_name="Run", _RC)
    call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Finalize, Finalize, _RC)

    call logger%debug("GCHP_GridCompMod.F90::SetServices done")

    _RETURN(_SUCCESS)

  end subroutine SetServices

  !=============================================================================
  ! Initialize -- The Initialize method of the Gridded Component.

  subroutine Initialize( GC, IMPORT, EXPORT, CLOCK, RC )

    type(ESMF_GridComp):: gc   ! composite gridded component
    type(ESMF_State) :: import ! import state
    type(ESMF_State) :: export ! export state
    type(ESMF_Clock) :: clock  ! the clock
    integer, intent(out) :: rc ! Error code, 0 all is well

    integer :: status
    class(logger_t), pointer :: logger

    call MAPL_GridCompGet(gc, logger=logger, _RC)
    call logger%debug("Initialize::GCHP_GridCompMod: starting...")

    call logger%debug("Initialize::GCHP_GridCompMod: complete")

    _RETURN(_SUCCESS)

  end subroutine Initialize

  !=============================================================================
  ! Run -- The Run method of the Gridded Component.

  subroutine Run( GC, IMPORT, EXPORT, CLOCK, RC )

    !use MAPL_MemUtilsMod                         ! Optional memory prints
    use mapl3g_State_API, only: MAPL_StateGetPointer

    type(ESMF_GridComp):: gc   ! composite gridded component
    type(ESMF_State) :: import ! import state
    type(ESMF_State) :: export ! export state
    type(ESMF_Clock) :: clock  ! the clock
    integer, intent(out) :: rc ! Error code, 0 all is well

    integer :: status, iter, num_children
    character(len=:), allocatable :: child_name
    class(logger_t), pointer :: logger
    type(ESMF_GRID) :: esmfgrid
    type(ESMF_HConfig) :: hconfig
    real(r4), pointer :: PS1_import(:,:) ! Or auto-generate with ACG
    real(r4), pointer :: PS2_import(:,:)
    !real(r4), pointer :: lats(:,:), lons(:,:), temp2d(:,:)

    call MAPL_GridCompGet(gc, grid=esmfgrid, hconfig=hconfig, &
         logger=logger, num_children=num_children, _RC)
    call logger%debug("Run::GCHP_GridCompMod: starting...")

    ! Can change this to manually put in name, to ensure order
    do iter = 1, num_children
       child_name = MAPL_GridCompGetChildName(gc, iter, _RC)
       if ((index(child_name, "data")) /= 0) cycle
       call MAPL_GridCompRunChild(gc, child_name, phase_name="Run", _RC)
    end do

    call ESMF_GridValidate(esmfgrid, _RC)

!    call MAPL_StateGetPointer(import, PS1_import, 'PS1', _RC)
!    if ( associated(PS1_import) ) then
!       print *, "ewl: Successfully got pointer to PS1. Min/max values are ", &
!            MINVAL(PS1_import), MAXVAL(PS1_import)
!    endif
!
!    call MAPL_StateGetPointer(import, PS2_import, 'PS2', _RC)
!    if ( associated(PS2_import) ) then
!       print *, "ewl: Successfully got pointer to PS2. Min/max values are ", &
!            MINVAL(PS2_import), MAXVAL(PS2_import)
!    endif

   !     call MAPL_GridGet(esmfgrid, longitudes=lons, latitudes=lats, _RC)
!    call MAPL_StateGetPointer(export, temp2d, "LONS", _RC)
!    if( associated(temp2D) ) temp2d = lons
!    call MAPL_StateGetPointer(export, temp2d, "LATS", _RC)
!    if( associated(temp2D) ) temp2d = lats

!    PS1_import => NULL()
!    PS2_import => NULL()

    call logger%debug("Run::GCHP_GridCompMod: complete")

    _RETURN(_SUCCESS)

  end subroutine Run

  !=============================================================================
  ! Finalize -- The Finalize method of the Gridded Component.

  subroutine Finalize( GC, IMPORT, EXPORT, CLOCK, RC )

    type(ESMF_GridComp):: gc   ! composite gridded component
    type(ESMF_State) :: import ! import state
    type(ESMF_State) :: export ! export state
    type(ESMF_Clock) :: clock  ! the clock
    integer, intent(out) :: rc ! Error code, 0 all is well

    integer :: status
    class(logger_t), pointer :: logger

    call MAPL_GridCompGet(gc, logger=logger, _RC)
    call logger%debug("Finalize::GCHP_GridCompMod: starting...")

    call logger%debug("Finalize::GCHP_GridCompMod: complete")

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

#else
! MAPL2:
!=============================================================================
!BOP

! !MODULE: 
! GCHP\_GridCompMod -- this gridded component (GC) builds an ESMF application 
! out of the following three (children) components:
!   1. Advection (DYNAMICS)
!   2. Traditional GEOS-Chem except for advection (GCHPchem)
!   3. Cinderella component to derive variables for other comps (GCHPctmEnv)
!
! !NOTES:
! (1) For now, the dynamics module is rather primitive and based upon netCDF
! input fields for all met. variables (U,V,etc.). This module computes 
! pressure related quantities (PEDGE, PCENTER, BOXHEIGHT, AIRDEN, AD, DELP, 
! AIRVOL) and passes these variables to chemistry and HEMCO.
! Similarly, HEMCO inherits the grid box surface area from dynamics.
! (2) Tracers and emissions are passed as 'bundle' from one component to
! another.
! (3) All 3D fields are exchanged on the 'GEOS-5' vertical levels, i.e. with
! a reversed atmosphere (level 1 is top of atmosphere). 
!
! ---
!
! !INTERFACE:

module GCHP_GridCompMod

! !USES:

  use ESMF
  use MAPL_Mod
  use pFlogger, only: logging, Logger
  use CHEM_GridCompMod,    only : AtmosChemSetServices => SetServices
  use AdvCore_GridCompMod, only : AtmosAdvSetServices  => SetServices
  use GCHPctmEnv_GridComp, only : EctmSetServices      => SetServices

  implicit none
  private

!
! !PUBLIC MEMBER FUNCTIONS:
!
  public SetServices
!
! !PRIVATE MEMBER FUNCTIONS:
!
  private Initialize
  private Run
  private Finalize

!=============================================================================

! !DESCRIPTION:
 
!EOP

  integer ::  ADV, CHEM, ECTM, MemDebugLevel
  class(Logger), pointer  :: lgr => null()
  

contains

!BOP

! !IROUTINE: SetServices -- Sets ESMF services for this component

! !INTERFACE:

    subroutine SetServices ( GC, RC )

! !ARGUMENTS:

    type(ESMF_GridComp), intent(INOUT) :: GC  ! gridded component
    integer,             intent(  OUT) :: RC  ! return code

! !DESCRIPTION:  The SetServices for the GCHP gridded component needs to 
!   register its Initialize, Run, and Finalize.  It uses the MAPL_Generic 
!   construct for defining state specifications and couplings among its 
!   children.  In addition, it creates the children GCs (ADV, CHEM, ECTM) 
!   and run their respective SetServices.

!EOP

!=============================================================================
!
! ErrLog Variables

    character(len=ESMF_MAXSTR)              :: IAm
    integer                                 :: STATUS
    character(len=ESMF_MAXSTR)              :: COMP_NAME

! Locals

    type (ESMF_Config)                      :: CF
    logical                                 :: am_I_Root
#ifdef ADJOINT
    character(len=ESMF_MAXSTR)              :: ModelPhase
    logical                                 :: isAdjoint
#endif

!=============================================================================

! Begin...

    ! Get the target component name and set-up traceback handle
    !-----------------------------------------------------------
    Iam = 'SetServices'
    call ESMF_GridCompGet( GC, NAME=COMP_NAME, CONFIG=CF, RC=STATUS )
    _VERIFY(STATUS)
    Iam = trim(COMP_NAME) // "::" // Iam

    lgr => logging%get_logger('GCHP')

! Register services for this component
! ------------------------------------

   call MAPL_GridCompSetEntryPoint ( GC, ESMF_METHOD_INITIALIZE, Initialize, &
                                     RC=STATUS )
   _VERIFY(STATUS)
   call MAPL_GridCompSetEntryPoint ( GC, ESMF_METHOD_RUN, Run, RC=STATUS )
   _VERIFY(STATUS)
   call MAPL_GridCompSetEntryPoint ( GC, ESMF_METHOD_FINALIZE, Finalize, &
                                     RC=STATUS )
   _VERIFY(STATUS)

!BOP
#ifdef ADJOINT
    CALL ESMF_ConfigGetAttribute( CF, ModelPhase, &
                                  Label = "MODEL_PHASE:",&
                                  Default="FORWARD", &
                                  __RC__ ) 
    isAdjoint = .false.
    if (trim(ModelPhase) == 'ADJOINT') &
         isAdjoint = .true.

#ifdef REVERSE_OPERATORS
    IF (.not. isAdjoint) THEN
       IF (MAPL_Am_I_Root()) &
            WRITE(*,*) '  Forward run, adding children in standard order. ' // ModelPhase
#else
       WRITE(*,*) '  Adding children in standard order. MODEL_PHASE: ' // ModelPhase
#endif

#endif

! !IMPORT STATE:

! !EXPORT STATE:

! Create children`s gridded components and invoke their SetServices
! -----------------------------------------------------------------

   ! Add component for deriving variables for other components
   ECTM = MAPL_AddChild(GC, NAME='GCHPctmEnv' , SS=EctmSetServices,      &
                            RC=STATUS)
   _VERIFY(STATUS)

   ! Add chemistry
   CHEM = MAPL_AddChild(GC, NAME='GCHPchem', SS=AtmosChemSetServices, &
                        RC=STATUS)
   _VERIFY(STATUS)

   ! Add dynamics
   ADV = MAPL_AddChild(GC, NAME='DYNAMICS',  SS=AtmosAdvSetServices,  &
                       RC=STATUS)
   _VERIFY(STATUS)

#ifdef ADJOINT
#ifdef REVERSE_OPERATORS
   ELSE
      IF (MAPL_Am_I_Root()) &
           WRITE(*,*) '  Adjoint run, adding children in reverse order. '
   ! Add dynamics
   ADV = MAPL_AddChild(GC, NAME='DYNAMICS',  SS=AtmosAdvSetServices,  &
                       RC=STATUS)
   _VERIFY(STATUS)

   ! Add chemistry
   CHEM = MAPL_AddChild(GC, NAME='GCHPchem', SS=AtmosChemSetServices, &
                        RC=STATUS)
   _VERIFY(STATUS)

   ! Add component for deriving variables for other components
   ECTM = MAPL_AddChild(GC, NAME='GCHPctmEnv' , SS=EctmSetServices,      &
                            RC=STATUS)
   _VERIFY(STATUS)
   ENDIF
#endif
#endif

! Set internal connections between the children`s IMPORTS and EXPORTS
! -------------------------------------------------------------------
!BOP

! !CONNECTIONS:

      ! Connectivities between Children
      ! -------------------------------
      CALL MAPL_AddConnectivity ( GC,                          &
                                  SHORT_NAME = (/ 'CX     ',   &
                                                  'CY     ',   &
                                                  'MFX    ',   &
                                                  'MFY    ',   &
                                                  'PLE0   ',   &
                                                  'PLE1   ',   &
                                                  'DryPLE0',   &
                                                  'DryPLE1',   &
                                                  'SPHU0  '/), &
                                  DST_ID = ADV,                &
                                  SRC_ID = ECTM,               &
                                  __RC__ )

      CALL MAPL_AddConnectivity ( GC,                          &
                                  SHORT_NAME = (/ 'AREA  ',    &
                                                  'DryPLE',    &
                                                  'PLE   ' /), &
                                  DST_ID   = CHEM,             &
                                  SRC_ID = ADV,                &
                                  __RC__ )

      CALL MAPL_AddConnectivity ( GC,                           &
                                  SHORT_NAME = (/ 'DELPDRY' /), &
                                  DST_ID = ADV,                 &
                                  SRC_ID = CHEM,                &
                                  __RC__ )

      CALL MAPL_TerminateImport    ( GC,                         &
                                     SHORT_NAME = (/'TRADV'/), &
                                     CHILD = ADV,                &
                                     __RC__  )

    call MAPL_TimerAdd(GC, name="RUN", RC=STATUS)
    _VERIFY(STATUS)

    call MAPL_GenericSetServices    ( GC, RC=STATUS )
    _VERIFY(STATUS)

!EOP

    _RETURN(ESMF_SUCCESS)
  
  end subroutine SetServices


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! !IROUTINE: Initialize -- Initialize method for the GCHP Gridded Component

! !INTERFACE:

  subroutine Initialize ( GC, IMPORT, EXPORT, CLOCK, RC )

! !ARGUMENTS:

  type(ESMF_GridComp), intent(inout) :: GC     ! Gridded component 
  type(ESMF_State),    intent(inout) :: IMPORT ! Import state
  type(ESMF_State),    intent(inout) :: EXPORT ! Export state
  type(ESMF_Clock),    intent(inout) :: CLOCK  ! The clock
  integer, optional,   intent(  out) :: RC     ! Error code

! !DESCRIPTION: The Initialize method of the GCHP Composite Gridded 
!  Component. It acts as a driver for the initialization of the three 
!  children: DYNAMICS, GCHPchem, and GCHPctmEnv.
!
!EOP

! ErrLog Variables

  character(len=ESMF_MAXSTR)           :: IAm 
  integer                              :: STATUS
  character(len=ESMF_MAXSTR)           :: COMP_NAME

! Local derived type aliases

   type (MAPL_MetaComp),       pointer :: STATE
   type (ESMF_GridComp),       pointer :: GCS(:)
   type (ESMF_State),          pointer :: GIM(:)
   type (ESMF_State),          pointer :: GEX(:)
   type (ESMF_FieldBundle)             :: BUNDLE
   type (ESMF_Field)                   :: FIELD
   type (ESMF_Grid)                    :: GRID
   type (ESMF_Config)                  :: CF
   integer                             :: NUM_TRACERS

!=============================================================================

! Begin... 

    ! Get the target component name and set-up traceback handle
    !----------------------------------------------------------
    Iam = "Initialize"
    call ESMF_GridCompGet ( GC, name=COMP_NAME, Config=CF, RC=STATUS )
    _VERIFY(STATUS)
    Iam = trim(COMP_NAME) // "::" // Iam


    ! Get memory debug level
    !----------------------------------------------------------
    call ESMF_ConfigGetAttribute(CF, MemDebugLevel, &
                                 Label="MEMORY_DEBUG_LEVEL:" , RC=STATUS)
    _VERIFY(STATUS)


    ! Get my MAPL_Generic state
    !--------------------------
    call MAPL_GetObjectFromGC ( GC, STATE, RC=STATUS)
    _VERIFY(STATUS)

    ! Create Atmospheric grid
    !------------------------
    call MAPL_GridCreate( GC, rc=status )
    _VERIFY(STATUS)

#ifdef ADJOINT
    if (MAPL_Am_I_Root()) THEN
       WRITE(*,*) 'Before Generic Init'
    endif
#endif

    ! Call Initialize for every Child
    !--------------------------------
    call MAPL_GenericInitialize ( GC, IMPORT, EXPORT, CLOCK, __RC__ )
    _VERIFY(STATUS)

    call MAPL_TimerOn(STATE,"TOTAL")
    !    call MAPL_TimerOn(STATE,"INITIALIZE")

    ! Get children and their im/ex states from my generic state.
    !----------------------------------------------------------
    call MAPL_Get ( STATE, GCS=GCS, GIM=GIM, GEX=GEX, RC=STATUS )
    _VERIFY(STATUS)

#ifdef ADJOINT
    if (MAPL_Am_I_Root()) THEN
       WRITE(*,*) 'After Generic Init'
    endif
#endif

    ! AdvCore Tracers
    !----------------
    call ESMF_StateGet( GIM(ADV), 'TRADV', BUNDLE, RC=STATUS )
    _VERIFY(STATUS)
    
    call MAPL_GridCompGetFriendlies(GCS(CHEM), "DYNAMICS", BUNDLE, RC=STATUS )
    _VERIFY(STATUS)
    
    ! Count tracers
    !--------------
    call ESMF_FieldBundleGet(BUNDLE,FieldCount=NUM_TRACERS, RC=STATUS)
    _VERIFY(STATUS)
   
    ! Disable this erroneous MAPL_TimerOff to fix timing. J.W.Zhuang 2017/04 
    ! call MAPL_TimerOff(STATE,"RUN")
    call MAPL_TimerOff(STATE,"TOTAL")

    _RETURN(ESMF_SUCCESS)
 end subroutine Initialize

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!BOP

! !IROUTINE: Run -- Run method for the composite GCHP Gridded Component
                 
! !INTERFACE:

   subroutine Run ( GC, IMPORT, EXPORT, CLOCK, RC )

! !USES:

  use MAPL_MemUtilsMod                         ! Optional memory prints

! !ARGUMENTS:

  type(ESMF_GridComp), intent(inout) :: GC     ! Gridded component 
  type(ESMF_State),    intent(inout) :: IMPORT ! Import state
  type(ESMF_State),    intent(inout) :: EXPORT ! Export state
  type(ESMF_Clock),    intent(inout) :: CLOCK  ! The clock
  integer, optional,   intent(  out) :: RC     ! Error code

! !DESCRIPTION: The run method for the GCHP gridded component calls the 
!   children`s run methods. It also prepares inputs and couplings amongst them.

!EOP

! ErrLog Variables

   character(len=ESMF_MAXSTR)          :: IAm 
   integer                             :: STATUS
   character(len=ESMF_MAXSTR)          :: COMP_NAME

! Local derived type aliases

   type (MAPL_MetaComp),      pointer  :: STATE
   type (ESMF_GridComp),      pointer  :: GCS(:)
   type (ESMF_State),         pointer  :: GIM(:)
   type (ESMF_State),         pointer  :: GEX(:)
   type (ESMF_State)                   :: INTERNAL
   type (ESMF_Config)                  :: CF
   type (ESMF_VM)                      :: VM
   character(len=ESMF_MAXSTR),pointer  :: GCNames(:)
   integer                             :: I, L
   integer                             :: IM, JM, LM
   real                                :: DT
 
   ! Added for GCHP Adjoint
   character(len=ESMF_MAXSTR)          :: ModelPhase
   logical                             :: isAdjoint
   logical, save                       :: firstRun = .true.
 
!=============================================================================

! Begin... 

    ! Get the target component name and set-up traceback handle
    ! ---------------------------------------------------------
    Iam = "Run"
    call ESMF_GridCompGet ( GC, name=COMP_NAME, config=CF, RC=STATUS )
    _VERIFY(STATUS)
    Iam = trim(COMP_NAME) // "::" // Iam

    ! Get my internal MAPL_Generic state
    !-----------------------------------
    call MAPL_GetObjectFromGC ( GC, STATE, RC=STATUS)
    _VERIFY(STATUS)

    ! Get the VM for optional memory prints (level >= 1)
    !-----------------------------------
    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VmGetCurrent(VM, RC=STATUS)
       _VERIFY(STATUS)
    endif

#ifdef ADJOINT
    ! Check if this is an adjoint run
    CALL ESMF_ConfigGetAttribute( CF, ModelPhase, &
         Label = "MODEL_PHASE:",&
         Default="FORWARD", &
         __RC__ ) 
    isAdjoint = .false.
    if (trim(ModelPhase) == 'ADJOINT') &
         isAdjoint = .true.
#endif

    ! Start timers
    !-------------
    call MAPL_TimerOn(STATE,"TOTAL")
    call MAPL_TimerOn(STATE,"RUN")

    ! Get the children`s states from the generic state
    !-------------------------------------------------
    call MAPL_Get ( STATE,                           &
                    GCS=GCS,                         &
                    GIM=GIM,                         &
                    GEX=GEX,                         &
                    IM = IM,                         &
                    JM = JM,                         &
                    LM = LM,                         &
                    GCNames = GCNames,               &
                    INTERNAL_ESMF_STATE = INTERNAL,  &
                    RC = STATUS )
    _VERIFY(STATUS)

    ! Get heartbeat
    !--------------
    call ESMF_ConfigGetAttribute(CF, DT, Label="RUN_DT:" , RC=STATUS)
    _VERIFY(STATUS)

#ifdef ADJOINT
    !------------------------------------------------------------
    ! If we're doing the adoint, we should be running these in
    ! reverse order. Possibly not the Environment module?
    ! In cany case, this isn't working yet, so disable it for now
    !------------------------------------------------------------
#ifdef REVERSE_OPERATORS
    IF (.not. isAdjoint) THEN
#else
    IF (.true.) THEN
#endif
    if (MAPL_Am_I_Root()) THEN
       WRITE(*,*) 'Not reversing high-level operators'
    endif
#endif

    ! Cinderella Component: to derive variables for other components
    !---------------------

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GCHP, before GCHPctmEnv: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    call MAPL_TimerOn ( STATE, GCNames(ECTM) )
    call ESMF_GridCompRun ( GCS(ECTM),               &
                            importState = GIM(ECTM), &
                            exportState = GEX(ECTM), &
                            clock       = CLOCK,     &
                            userRC      = STATUS  )
    _VERIFY(STATUS)

    call MAPL_TimerOff( STATE, GCNames(ECTM) )

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GCHP, after  GCHPctmEnv: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    ! Dynamics & Advection
    !------------------
    ! SDE 2017-02-18: This needs to run even if transport is off, as it is
    ! responsible for the pressure level edge arrays. It already has an internal
    ! switch ("AdvCore_Advection") which can be used to prevent any actual
    ! transport taking place by bypassing the advection calculation.

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GCHP, before Advection: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    call MAPL_TimerOn ( STATE, GCNames(ADV) )
    call ESMF_GridCompRun ( GCS(ADV),               &
                            importState = GIM(ADV), &
                            exportState = GEX(ADV), &
                            clock       = CLOCK,    &
                            userRC      = STATUS );
    _VERIFY(STATUS)
    call MAPL_GenericRunCouplers (STATE, ADV, CLOCK, RC=STATUS );
    _VERIFY(STATUS)
    call MAPL_TimerOff( STATE, GCNames(ADV) )

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GCHP, after  Advection: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    ! Chemistry
    !------------------

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GCHP, before GEOS-Chem: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    call MAPL_TimerOn ( STATE, GCNames(CHEM) )
    call ESMF_GridCompRun ( GCS(CHEM),               &
                            importState = GIM(CHEM), &
                            exportState = GEX(CHEM), &
                            clock       = CLOCK,     &
                            userRC      = STATUS );
    _VERIFY(STATUS)
    call MAPL_GenericRunCouplers (STATE, CHEM, CLOCK, RC=STATUS );
    _VERIFY(STATUS)
    call MAPL_TimerOff(STATE,GCNames(CHEM))

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GCHP, after  GEOS-Chem: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

#ifdef ADJOINT
    ELSE
       if (MAPL_Am_I_Root()) THEN
          WRITE(*,*) 'Reversing high-level operators'
       endif

       IF (firstRun) THEN
          ! Cinderella Component: to derive variables for other components
          !---------------------

          if ( MemDebugLevel > 0 ) THEN
             call ESMF_VMBarrier(VM, RC=STATUS)
             _VERIFY(STATUS)
             call MAPL_MemUtilsWrite(VM, &
                  'GIGC, before GEOS_ctmE: ', RC=STATUS )
             _VERIFY(STATUS)
          endif

          call MAPL_TimerOn ( STATE, GCNames(ECTM) )
          call ESMF_GridCompRun ( GCS(ECTM),               &
               importState = GIM(ECTM), &
               exportState = GEX(ECTM), &
               clock       = CLOCK,     &
               userRC      = STATUS  )
          _VERIFY(STATUS)

          call MAPL_TimerOff( STATE, GCNames(ECTM) )

          if ( MemDebugLevel > 0 ) THEN
             call ESMF_VMBarrier(VM, RC=STATUS)
             _VERIFY(STATUS)
             call MAPL_MemUtilsWrite(VM, &
                  'GIGC, after  GEOS_ctmE: ', RC=STATUS )
             _VERIFY(STATUS)
          endif

          ! Dynamics & Advection
          !------------------
          ! SDE 2017-02-18: This needs to run even if transport is off, as it is
          ! responsible for the pressure level edge arrays. It already has an internal
          ! switch ("AdvCore_Advection") which can be used to prevent any actual
          ! transport taking place by bypassing the advection calculation.

          if ( MemDebugLevel > 0 ) THEN
             call ESMF_VMBarrier(VM, RC=STATUS)
             _VERIFY(STATUS)
             call MAPL_MemUtilsWrite(VM, &
                  'GIGC, before Advection: ', RC=STATUS )
             _VERIFY(STATUS)
          endif

          call MAPL_TimerOn ( STATE, GCNames(ADV) )
          call ESMF_GridCompRun ( GCS(ADV),               &
               importState = GIM(ADV), &
               exportState = GEX(ADV), &
               clock       = CLOCK,    &
               userRC      = STATUS );
          _VERIFY(STATUS)
          call MAPL_GenericRunCouplers (STATE, ADV, CLOCK, RC=STATUS );
          _VERIFY(STATUS)
          call MAPL_TimerOff( STATE, GCNames(ADV) )

          if ( MemDebugLevel > 0 ) THEN
             call ESMF_VMBarrier(VM, RC=STATUS)
             _VERIFY(STATUS)
             call MAPL_MemUtilsWrite(VM, &
                  'GIGC, after  Advection: ', RC=STATUS )
             _VERIFY(STATUS)
          endif

       ENDIF
    ! Chemistry
    !------------------

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GIGC, before GEOS-Chem: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    call MAPL_TimerOn ( STATE, GCNames(CHEM) )
    call ESMF_GridCompRun ( GCS(CHEM),               &
                            importState = GIM(CHEM), &
                            exportState = GEX(CHEM), &
                            clock       = CLOCK,     &
                            userRC      = STATUS );
    _VERIFY(STATUS)
    call MAPL_GenericRunCouplers (STATE, CHEM, CLOCK, RC=STATUS );
    _VERIFY(STATUS)
    call MAPL_TimerOff(STATE,GCNames(CHEM))

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GIGC, after  GEOS-Chem: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    ! Cinderella Component: to derive variables for other components
    !---------------------

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GIGC, before GEOS_ctmE: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    call MAPL_TimerOn ( STATE, GCNames(ECTM) )
    call ESMF_GridCompRun ( GCS(ECTM),               &
                            importState = GIM(ECTM), &
                            exportState = GEX(ECTM), &
                            clock       = CLOCK,     &
                            userRC      = STATUS  )
    _VERIFY(STATUS)

    call MAPL_TimerOff( STATE, GCNames(ECTM) )

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GIGC, after  GEOS_ctmE: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    ! Dynamics & Advection
    !------------------
    ! SDE 2017-02-18: This needs to run even if transport is off, as it is
    ! responsible for the pressure level edge arrays. It already has an internal
    ! switch ("AdvCore_Advection") which can be used to prevent any actual
    ! transport taking place by bypassing the advection calculation.

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GIGC, before Advection: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    call MAPL_TimerOn ( STATE, GCNames(ADV) )
    call ESMF_GridCompRun ( GCS(ADV),               &
                            importState = GIM(ADV), &
                            exportState = GEX(ADV), &
                            clock       = CLOCK,    &
                            userRC      = STATUS );
    _VERIFY(STATUS)
    call MAPL_GenericRunCouplers (STATE, ADV, CLOCK, RC=STATUS );
    _VERIFY(STATUS)
    call MAPL_TimerOff( STATE, GCNames(ADV) )

    if ( MemDebugLevel > 0 ) THEN
       call ESMF_VMBarrier(VM, RC=STATUS)
       _VERIFY(STATUS)
       call MAPL_MemUtilsWrite(VM, &
                  'GIGC, after  Advection: ', RC=STATUS )
       _VERIFY(STATUS)
    endif

    ENDIF
#endif

    call MAPL_TimerOff(STATE,"RUN")
    call MAPL_TimerOff(STATE,"TOTAL")

    ! Added for GCHP Adjoint
    firstRun = .false.

    _RETURN(ESMF_SUCCESS)

  end subroutine Run

!=============================================================================

  subroutine Finalize ( GC, IMPORT, EXPORT, CLOCK, RC )

    ! !ARGUMENTS:
    
    type(ESMF_GridComp), intent(inout) :: GC     ! Gridded component 
    type(ESMF_State),    intent(inout) :: IMPORT ! Import state
    type(ESMF_State),    intent(inout) :: EXPORT ! Export state
    type(ESMF_Clock),    intent(inout) :: CLOCK  ! The clock
    integer, optional,   intent(  out) :: RC     ! Error code
    
! !DESCRIPTION: The Finalize method 

!EOP

! ErrLog Variables

     character(len=ESMF_MAXSTR)          :: IAm 
     integer                             :: STATUS
     character(len=ESMF_MAXSTR)          :: COMP_NAME
     
     ! Get the target component name and set-up traceback handle
     Iam = "Finalize"
     call ESMF_GridCompGet ( GC, name=COMP_NAME, RC=STATUS )
     _VERIFY(STATUS)
     Iam = trim(COMP_NAME) // Iam

     ! Call generic finalize
     call MAPL_GenericFinalize( GC, IMPORT, EXPORT, CLOCK, RC=STATUS )
     _VERIFY(STATUS)

     ! Destroy import and export states
     call ESMF_StateDestroy(IMPORT, rc=status)
     _VERIFY(STATUS)
     call ESMF_StateDestroy(EXPORT, rc=status)
     _VERIFY(STATUS)

     _RETURN(ESMF_SUCCESS)
   end subroutine Finalize

!=============================================================================

 end module GCHP_GridCompMod
#endif
