#include "MAPL_Generic.h"
#include "MAPL.h" ! ewl try this

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
!ewl  use MAPL_Mod
  use mapl3 ! ewl added
  use fv_arrays_mod, only: REAL4 !ewl added
!ewl  use pFlogger, only: logging, Logger
!ewl  use CHEM_GridCompMod,    only : AtmosChemSetServices => SetServices
!ewl  use AdvCore_GridCompMod, only : AtmosAdvSetServices  => SetServices
  !ewl  use GCHPctmEnv_GridComp, only : EctmSetServices      => SetServices
  !new:
  use pflogger, only: logger_t => logger

  implicit none
  private

!
! !PUBLIC MEMBER FUNCTIONS:
!
  public SetServices

  integer,  parameter :: r4           = REAL4

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

contains

!BOP

! !IROUTINE: SetServices -- Sets ESMF services for this component

! !INTERFACE:

    subroutine SetServices ( GC, RC )

! !ARGUMENTS:

    type(ESMF_GridComp)  :: gc  ! gridded component
    integer, intent(out) :: rc  ! return code

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
!ewl    character(len=ESMF_MAXSTR)              :: COMP_NAME
    class(logger_t), pointer :: logger
! Locals

    type (ESMF_Config)                      :: CF
    logical                                 :: am_I_Root
#ifdef ADJOINT
    character(len=ESMF_MAXSTR)              :: ModelPhase
    logical                                 :: isAdjoint
#endif

!=============================================================================

! Begin...

    ! Changes based on DynCore_GridCompMod in mapl3 branch (ewl)
    !ewl    ! Get the target component name and set-up traceback handle
    !ewl    !-----------------------------------------------------------
    !ewl    Iam = 'SetServices'
    !ewl
    !ewl    call ESMF_GridCompGet( GC, NAME=COMP_NAME, CONFIG=CF, RC=STATUS )
    !ewl   _VERIFY(STATUS)
    !ewl    Iam = trim(COMP_NAME) // "::" // Iam
    !ewl lgr => logging%get_logger('GCHP')
    call MAPL_GridCompGet(gc, logger=logger, _RC)
    call logger%info("SetServices::GCHP_GridCompMod:: start...")
!    _SET_NAMED_PRIVATE_STATE(gc, GCHPState, PRIVATE_STATE) ! ewl: what is this?
     
! Register services for this component
! ------------------------------------

    ! ewl change based on DynCore
    !call MAPL_GridCompSetEntryPoint ( GC, ESMF_METHOD_INITIALIZE, Initialize, &
    !                                  RC=STATUS )
    !_VERIFY(STATUS)
    !call MAPL_GridCompSetEntryPoint ( GC, ESMF_METHOD_RUN, Run, RC=STATUS )
    !_VERIFY(STATUS)
    !call MAPL_GridCompSetEntryPoint ( GC, ESMF_METHOD_FINALIZE, Finalize, &
    !                                  RC=STATUS )
    !_VERIFY(STATUS)
      ! Register services for this component
      call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Initialize,  Initialize, _RC)
      call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Run, Run, phase_name="Run", _RC)
      call MAPL_GridCompSetEntryPoint(gc, ESMF_Method_Finalize, Finalize, _RC)
!BOP
! ewl: ignore adjoint for now
!#ifdef ADJOINT
!    CALL ESMF_ConfigGetAttribute( CF, ModelPhase, &
!                                  Label = "MODEL_PHASE:",&
!                                  Default="FORWARD", &
!                                  __RC__ ) 
!    isAdjoint = .false.
!    if (trim(ModelPhase) == 'ADJOINT') &
!         isAdjoint = .true.
!
!#ifdef REVERSE_OPERATORS
!    IF (.not. isAdjoint) THEN
!       IF (MAPL_Am_I_Root()) &
!            WRITE(*,*) '  Forward run, adding children in standard order. ' // ModelPhase
!#else
!       WRITE(*,*) '  Adding children in standard order. MODEL_PHASE: ' // ModelPhase
!#endif
!
!#endif

! !IMPORT STATE:

      ! ewl: add some dummy?

! !EXPORT STATE:

      ! ewl: add dummy here?

!ewl! Create children`s gridded components and invoke their SetServices
!ewl! -----------------------------------------------------------------
!ewl
!ewl   ! Add component for deriving variables for other components
!ewl   ECTM = MAPL_AddChild(GC, NAME='GCHPctmEnv' , SS=EctmSetServices,      &
!ewl                            RC=STATUS)
!ewl   _VERIFY(STATUS)
!ewl
!ewl#ifndef MODEL_CTMENV
!ewl   ! Add chemistry
!ewl   CHEM = MAPL_AddChild(GC, NAME='GCHPchem', SS=AtmosChemSetServices, &
!ewl                        RC=STATUS)
!ewl   _VERIFY(STATUS)
!ewl#endif
!ewl
!ewl   ! Add dynamics
!ewl   ADV = MAPL_AddChild(GC, NAME='DYNAMICS',  SS=AtmosAdvSetServices,  &
!ewl                       RC=STATUS)
!ewl   _VERIFY(STATUS)
!ewl
!ewl#ifdef ADJOINT
!ewl#ifdef REVERSE_OPERATORS
!ewl   ELSE
!ewl      IF (MAPL_Am_I_Root()) &
!ewl           WRITE(*,*) '  Adjoint run, adding children in reverse order. '
!ewl   ! Add dynamics
!ewl   ADV = MAPL_AddChild(GC, NAME='DYNAMICS',  SS=AtmosAdvSetServices,  &
!ewl                       RC=STATUS)
!ewl   _VERIFY(STATUS)
!ewl
!ewl   ! Add chemistry
!ewl   CHEM = MAPL_AddChild(GC, NAME='GCHPchem', SS=AtmosChemSetServices, &
!ewl                        RC=STATUS)
!ewl   _VERIFY(STATUS)
!ewl
!ewl   ! Add component for deriving variables for other components
!ewl   ECTM = MAPL_AddChild(GC, NAME='GCHPctmEnv' , SS=EctmSetServices,      &
!ewl                            RC=STATUS)
!ewl   _VERIFY(STATUS)
!ewl   ENDIF
!ewl#endif
!ewl#endif
!ewl
!ewl! Set internal connections between the children`s IMPORTS and EXPORTS
!ewl! -------------------------------------------------------------------
!ewl!BOP
!ewl
!ewl! !CONNECTIONS:
!ewl
!ewl      ! Connectivities between Children
!ewl      ! -------------------------------
!ewl      CALL MAPL_AddConnectivity ( GC,                          &
!ewl                                  SHORT_NAME = (/ 'CX     ',   &
!ewl                                                  'CY     ',   &
!ewl                                                  'MFX    ',   &
!ewl                                                  'MFY    ',   &
!ewl                                                  'PLE0   ',   &
!ewl                                                  'PLE1   ',   &
!ewl                                                  'DryPLE0',   &
!ewl                                                  'DryPLE1',   &
!ewl                                                  'SPHU0  '/), &
!ewl                                  DST_ID = ADV,                &
!ewl                                  SRC_ID = ECTM,               &
!ewl                                  __RC__ )
!ewl
!ewl#ifndef MODEL_CTMENV
!ewl      CALL MAPL_AddConnectivity ( GC,                          &
!ewl                                  SHORT_NAME = (/ 'AREA  ',    &
!ewl                                                  'DryPLE',    &
!ewl                                                  'PLE   ' /), &
!ewl                                  DST_ID   = CHEM,             &
!ewl                                  SRC_ID = ADV,                &
!ewl                                  __RC__ )
!ewl
!ewl      CALL MAPL_AddConnectivity ( GC,                           &
!ewl                                  SHORT_NAME = (/ 'DELPDRY' /), &
!ewl                                  DST_ID = ADV,                 &
!ewl                                  SRC_ID = CHEM,                &
!ewl                                  __RC__ )
!ewl#endif
!ewl
!ewl    CALL MAPL_TerminateImport    ( GC,                         &
!ewl                                     SHORT_NAME = (/'TRADV'/), &
!ewl                                     CHILD = ADV,                &
!ewl                                     __RC__  )
!ewl
!ewl    call MAPL_TimerAdd(GC, name="RUN", RC=STATUS)
!ewl    _VERIFY(STATUS)

    !ewl comment out since not in dyn
    !ewl call MAPL_GenericSetServices    ( GC, RC=STATUS )
    !ewl _VERIFY(STATUS)

!EOP

    !ewl _RETURN(ESMF_SUCCESS)
    _RETURN(_SUCCESS)

  end subroutine SetServices


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! !IROUTINE: Initialize -- Initialize method for the GCHP Gridded Component

! !INTERFACE:

  subroutine Initialize( GC, IMPORT, EXPORT, CLOCK, RC )

    type(ESMF_GridComp):: gc   ! composite gridded component
    type(ESMF_State) :: import ! import state
    type(ESMF_State) :: export ! export state
    type(ESMF_Clock) :: clock  ! the clock
    integer, intent(out) :: rc ! Error code, 0 all is well

! !DESCRIPTION: The Initialize method of the GCHP Composite Gridded 
!  Component. It acts as a driver for the initialization of the three 
!  children: DYNAMICS, GCHPchem, and GCHPctmEnv.
!
!EOP

  ! ewl not sure how many of these are needed....
! ErrLog Variables

  character(len=ESMF_MAXSTR)           :: IAm 
  integer                              :: STATUS
  character(len=ESMF_MAXSTR)           :: COMP_NAME

! Local derived type aliases

   !ewl type (MAPL_MetaComp),       pointer :: STATE ! type not defined some commenting out for mapl3
   type (ESMF_GridComp),       pointer :: GCS(:)
   type (ESMF_State),          pointer :: GIM(:)
   type (ESMF_State),          pointer :: GEX(:)
   type (ESMF_FieldBundle)             :: BUNDLE
   type (ESMF_Field)                   :: FIELD
   type (ESMF_Grid)                    :: GRID
   type (ESMF_Config)                  :: CF
   integer                             :: NUM_TRACERS

   ! new (ewl)
   character(len=:), allocatable :: gchp_file
   class(logger_t), pointer :: logger

!=============================================================================

! Begin... 

    ! Change for mapl3
    !ewl  ! Get the target component name and set-up traceback handle
    !ewl  !----------------------------------------------------------
    !ewl  Iam = "Initialize"
    !ewl  call ESMF_GridCompGet ( GC, name=COMP_NAME, Config=CF, RC=STATUS )
    !ewl  _VERIFY(STATUS)
    !ewl  Iam = trim(COMP_NAME) // "::" // Iam
    call MAPL_GridCompGet(gc, logger=logger, _RC)
    call logger%info("Initialize::GCHP_GridCompMod:: starting...")
     ! Need to have this local...what type? (ewl)
!    _GET_NAME_PRIVATE_STATE(gc, GCHP, PRIVATE_STATE, self) !ewl what is this?

    ! ewl: need to adapt below to use MAPL_GridCompGetResource instead
    ! Get memory debug level
    !----------------------------------------------------------
    call ESMF_ConfigGetAttribute(CF, MemDebugLevel, &
                                 Label="MEMORY_DEBUG_LEVEL:" , RC=STATUS)
    _VERIFY(STATUS)
    ! ewl: not sure if the below new is correct. Use old above for now.
    !       call MAPL_GridCompGetResource(gc, "MEMORY_DEBUG_LEVEL", gchp_file, default="GCHP.rc", _RC)


    ! ewl: seems to not be needed anymore....
    !ewl ! Get my MAPL_Generic state
    !ewl !--------------------------
    !ewl call MAPL_GetObjectFromGC ( GC, STATE, RC=STATUS)
    !ewl _VERIFY(STATUS)

    ! ewl: comment out for now. not in dyncore
    !ewl ! Create Atmospheric grid
    !ewl !------------------------
    !ewl call MAPL_GridCreate( GC, rc=status )
    !ewl _VERIFY(STATUS)

! ewl: skip adjoint for now
!#ifdef ADJOINT
!    if (MAPL_Am_I_Root()) THEN
!       WRITE(*,*) 'Before Generic Init'
!    endif
!#endif

    ! ewl: keep for now, but not in dyncore
    !ewl Call Initialize for every Child
    !ewl -------------------------------
    !ewl call MAPL_GenericInitialize ( GC, IMPORT, EXPORT, CLOCK, __RC__ )
    !ewl _VERIFY(STATUS)

    ! ewl - timers are gone
    !ewl call MAPL_TimerOn(STATE,"TOTAL")
    !ewl !    call MAPL_TimerOn(STATE,"INITIALIZE")

! ewl: skip this for now since does not work
!    ! Get children and their im/ex states from my generic state.
!    !----------------------------------------------------------
!    call MAPL_Get ( STATE, GCS=GCS, GIM=GIM, GEX=GEX, RC=STATUS )
!    _VERIFY(STATUS)

! ewl: skip adjoint for now
!#ifdef ADJOINT
!    if (MAPL_Am_I_Root()) THEN
!       WRITE(*,*) 'After Generic Init'
!    endif
!#endif

!ewl#ifndef MODEL_CTMENV
!ewl    ! AdvCore Tracers
!ewl    !----------------
!ewl    call ESMF_StateGet( GIM(ADV), 'TRADV', BUNDLE, RC=STATUS )
!ewl    _VERIFY(STATUS)
!ewl    
!ewl    call MAPL_GridCompGetFriendlies(GCS(CHEM), "DYNAMICS", BUNDLE, RC=STATUS )
!ewl    _VERIFY(STATUS)
!ewl    
!ewl    ! Count tracers
!ewl    !--------------
!ewl    call ESMF_FieldBundleGet(BUNDLE,FieldCount=NUM_TRACERS, RC=STATUS)
!ewl    _VERIFY(STATUS)
!ewl#endif

    ! ewl - timers are gone
    !ewl ! Disable this erroneous MAPL_TimerOff to fix timing. J.W.Zhuang 2017/04 
    !ewl ! call MAPL_TimerOff(STATE,"RUN")
    !ewl call MAPL_TimerOff(STATE,"TOTAL")

    ! ewl: new return success
    !ewl _RETURN(ESMF_SUCCESS)
    _RETURN(_SUCCESS)

  end subroutine Initialize

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!BOP

! !IROUTINE: Run -- Run method for the composite GCHP Gridded Component
                 
! !INTERFACE:

   subroutine Run( GC, IMPORT, EXPORT, CLOCK, RC )

! !USES:

  use MAPL_MemUtilsMod                         ! Optional memory prints

  type(ESMF_GridComp):: gc   ! composite gridded component
  type(ESMF_State) :: import ! import state
  type(ESMF_State) :: export ! export state
  type(ESMF_Clock) :: clock  ! the clock
  integer, intent(out) :: rc ! Error code, 0 all is well

! !DESCRIPTION: The run method for the GCHP gridded component calls the 
!   children`s run methods. It also prepares inputs and couplings amongst them.

!EOP

! ErrLog Variables

   character(len=ESMF_MAXSTR)          :: IAm 
   integer                             :: STATUS
   character(len=ESMF_MAXSTR)          :: COMP_NAME

! Local derived type aliases

!   type (MAPL_MetaComp),      pointer  :: STATE
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

   ! ewl new
   real(r4), pointer :: lats(:,:), lons(:,:), temp2d(:,:)
   class(logger_t), pointer :: logger
   type(ESMF_GRID) :: esmfgrid
   type(ESMF_HConfig) :: hconfig

!=============================================================================

! Begin... 

!ewl      ! Get the target component name and set-up traceback handle
!ewl      ! ---------------------------------------------------------
!ewl      Iam = "Run"
!ewl      call ESMF_GridCompGet ( GC, name=COMP_NAME, config=CF, RC=STATUS )
!ewl      _VERIFY(STATUS)
   !ewl      Iam = trim(COMP_NAME) // "::" // Iam
   ! This is in dyncore but esmfgrid not found...
      call MAPL_GridCompGet(gc, grid=esmfgrid, hconfig=hconfig, logger=logger, _RC)
      call logger%info("Run::GCHP_GridCompMod:: starting...")
      call ESMF_GridValidate(esmfgrid, _RC)
      call MAPL_GridGet(esmfgrid, longitudes=lons, latitudes=lats, _RC)
      call MAPL_StateGetPointer(export, temp2d, "LONS", _RC)
      if( associated(temp2D) ) temp2d = lons
      call MAPL_StateGetPointer(export, temp2d, "LATS", _RC)
      if( associated(temp2D) ) temp2d = lats

! ewl do we need this? comment out for now. it is old.
!    ! Get my internal MAPL_Generic state
!    !-----------------------------------
!    call MAPL_GetObjectFromGC ( GC, STATE, RC=STATUS)
!    _VERIFY(STATUS)
!
!    ! Get the VM for optional memory prints (level >= 1)
!    !-----------------------------------
!    if ( MemDebugLevel > 0 ) THEN
!       call ESMF_VmGetCurrent(VM, RC=STATUS)
!       _VERIFY(STATUS)
!    endif

!ewl: ignore adjoint for now
!#ifdef ADJOINT
!    ! Check if this is an adjoint run
!    CALL ESMF_ConfigGetAttribute( CF, ModelPhase, &
!         Label = "MODEL_PHASE:",&
!         Default="FORWARD", &
!         __RC__ ) 
!    isAdjoint = .false.
!    if (trim(ModelPhase) == 'ADJOINT') &
!         isAdjoint = .true.
!#endif

!ewl    ! Start timers
!ewl    !-------------
!ewl    call MAPL_TimerOn(STATE,"TOTAL")
!ewl    call MAPL_TimerOn(STATE,"RUN")
!ewl
!ewl    ! Get the children`s states from the generic state
!ewl    !-------------------------------------------------
!ewl    call MAPL_Get ( STATE,                           &
!ewl                    GCS=GCS,                         &
!ewl                    GIM=GIM,                         &
!ewl                    GEX=GEX,                         &
!ewl                    IM = IM,                         &
!ewl                    JM = JM,                         &
!ewl                    LM = LM,                         &
!ewl                    GCNames = GCNames,               &
!ewl                    INTERNAL_ESMF_STATE = INTERNAL,  &
!ewl                    RC = STATUS )
!ewl    _VERIFY(STATUS)
!ewl
!ewl    ! Get heartbeat
!ewl    !--------------
!ewl    call ESMF_ConfigGetAttribute(CF, DT, Label="RUN_DT:" , RC=STATUS)
!ewl    _VERIFY(STATUS)
!ewl
!ewl#ifdef ADJOINT
!ewl    !------------------------------------------------------------
!ewl    ! If we're doing the adoint, we should be running these in
!ewl    ! reverse order. Possibly not the Environment module?
!ewl    ! In cany case, this isn't working yet, so disable it for now
!ewl    !------------------------------------------------------------
!ewl#ifdef REVERSE_OPERATORS
!ewl    IF (.not. isAdjoint) THEN
!ewl#else
!ewl    IF (.true.) THEN
!ewl#endif
!ewl    if (MAPL_Am_I_Root()) THEN
!ewl       WRITE(*,*) 'Not reversing high-level operators'
!ewl    endif
!ewl#endif
!ewl
!ewl    ! Cinderella Component: to derive variables for other components
!ewl    !---------------------
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'Before GCHPctmEnv: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl    call MAPL_TimerOn ( STATE, GCNames(ECTM) )
!ewl    call ESMF_GridCompRun ( GCS(ECTM),               &
!ewl                            importState = GIM(ECTM), &
!ewl                            exportState = GEX(ECTM), &
!ewl                            clock       = CLOCK,     &
!ewl                            userRC      = STATUS  )
!ewl    _VERIFY(STATUS)
!ewl
!ewl    call MAPL_TimerOff( STATE, GCNames(ECTM) )
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'After  GCHPctmEnv: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl#ifndef MODEL_CTMENV
!ewl    ! Dynamics & Advection
!ewl    !------------------
!ewl    ! SDE 2017-02-18: This needs to run even if transport is off, as it is
!ewl    ! responsible for the pressure level edge arrays. It already has an internal
!ewl    ! switch ("AdvCore_Advection") which can be used to prevent any actual
!ewl    ! transport taking place by bypassing the advection calculation.
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'GCHP, before Advection: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl    call MAPL_TimerOn ( STATE, GCNames(ADV) )
!ewl    call ESMF_GridCompRun ( GCS(ADV),               &
!ewl                            importState = GIM(ADV), &
!ewl                            exportState = GEX(ADV), &
!ewl                            clock       = CLOCK,    &
!ewl                            userRC      = STATUS );
!ewl    _VERIFY(STATUS)
!ewl    call MAPL_GenericRunCouplers (STATE, ADV, CLOCK, RC=STATUS );
!ewl    _VERIFY(STATUS)
!ewl    call MAPL_TimerOff( STATE, GCNames(ADV) )
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'GCHP, after  Advection: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl    ! Chemistry
!ewl    !------------------
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'GCHP, before GEOS-Chem: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl    call MAPL_TimerOn ( STATE, GCNames(CHEM) )
!ewl    call ESMF_GridCompRun ( GCS(CHEM),               &
!ewl                            importState = GIM(CHEM), &
!ewl                            exportState = GEX(CHEM), &
!ewl                            clock       = CLOCK,     &
!ewl                            userRC      = STATUS );
!ewl    _VERIFY(STATUS)
!ewl    call MAPL_GenericRunCouplers (STATE, CHEM, CLOCK, RC=STATUS );
!ewl    _VERIFY(STATUS)
!ewl    call MAPL_TimerOff(STATE,GCNames(CHEM))
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'GCHP, after  GEOS-Chem: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl#endif
!ewl
!ewl#ifdef ADJOINT
!ewl    ELSE
!ewl       if (MAPL_Am_I_Root()) THEN
!ewl          WRITE(*,*) 'Reversing high-level operators'
!ewl       endif
!ewl
!ewl       IF (firstRun) THEN
!ewl          ! Cinderella Component: to derive variables for other components
!ewl          !---------------------
!ewl
!ewl          if ( MemDebugLevel > 0 ) THEN
!ewl             call ESMF_VMBarrier(VM, RC=STATUS)
!ewl             _VERIFY(STATUS)
!ewl             call MAPL_MemUtilsWrite(VM, &
!ewl                  'GIGC, before GEOS_ctmE: ', RC=STATUS )
!ewl             _VERIFY(STATUS)
!ewl          endif
!ewl
!ewl          call MAPL_TimerOn ( STATE, GCNames(ECTM) )
!ewl          call ESMF_GridCompRun ( GCS(ECTM),               &
!ewl               importState = GIM(ECTM), &
!ewl               exportState = GEX(ECTM), &
!ewl               clock       = CLOCK,     &
!ewl               userRC      = STATUS  )
!ewl          _VERIFY(STATUS)
!ewl
!ewl          call MAPL_TimerOff( STATE, GCNames(ECTM) )
!ewl
!ewl          if ( MemDebugLevel > 0 ) THEN
!ewl             call ESMF_VMBarrier(VM, RC=STATUS)
!ewl             _VERIFY(STATUS)
!ewl             call MAPL_MemUtilsWrite(VM, &
!ewl                  'GIGC, after  GEOS_ctmE: ', RC=STATUS )
!ewl             _VERIFY(STATUS)
!ewl          endif
!ewl
!ewl          ! Dynamics & Advection
!ewl          !------------------
!ewl          ! SDE 2017-02-18: This needs to run even if transport is off, as it is
!ewl          ! responsible for the pressure level edge arrays. It already has an internal
!ewl          ! switch ("AdvCore_Advection") which can be used to prevent any actual
!ewl          ! transport taking place by bypassing the advection calculation.
!ewl
!ewl          if ( MemDebugLevel > 0 ) THEN
!ewl             call ESMF_VMBarrier(VM, RC=STATUS)
!ewl             _VERIFY(STATUS)
!ewl             call MAPL_MemUtilsWrite(VM, &
!ewl                  'GIGC, before Advection: ', RC=STATUS )
!ewl             _VERIFY(STATUS)
!ewl          endif
!ewl
!ewl          call MAPL_TimerOn ( STATE, GCNames(ADV) )
!ewl          call ESMF_GridCompRun ( GCS(ADV),               &
!ewl               importState = GIM(ADV), &
!ewl               exportState = GEX(ADV), &
!ewl               clock       = CLOCK,    &
!ewl               userRC      = STATUS );
!ewl          _VERIFY(STATUS)
!ewl          call MAPL_GenericRunCouplers (STATE, ADV, CLOCK, RC=STATUS );
!ewl          _VERIFY(STATUS)
!ewl          call MAPL_TimerOff( STATE, GCNames(ADV) )
!ewl
!ewl          if ( MemDebugLevel > 0 ) THEN
!ewl             call ESMF_VMBarrier(VM, RC=STATUS)
!ewl             _VERIFY(STATUS)
!ewl             call MAPL_MemUtilsWrite(VM, &
!ewl                  'GIGC, after  Advection: ', RC=STATUS )
!ewl             _VERIFY(STATUS)
!ewl          endif
!ewl
!ewl       ENDIF
!ewl    ! Chemistry
!ewl    !------------------
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'GIGC, before GEOS-Chem: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl    call MAPL_TimerOn ( STATE, GCNames(CHEM) )
!ewl    call ESMF_GridCompRun ( GCS(CHEM),               &
!ewl                            importState = GIM(CHEM), &
!ewl                            exportState = GEX(CHEM), &
!ewl                            clock       = CLOCK,     &
!ewl                            userRC      = STATUS );
!ewl    _VERIFY(STATUS)
!ewl    call MAPL_GenericRunCouplers (STATE, CHEM, CLOCK, RC=STATUS );
!ewl    _VERIFY(STATUS)
!ewl    call MAPL_TimerOff(STATE,GCNames(CHEM))
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'GIGC, after  GEOS-Chem: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl    ! Cinderella Component: to derive variables for other components
!ewl    !---------------------
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'GIGC, before GEOS_ctmE: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl    call MAPL_TimerOn ( STATE, GCNames(ECTM) )
!ewl    call ESMF_GridCompRun ( GCS(ECTM),               &
!ewl                            importState = GIM(ECTM), &
!ewl                            exportState = GEX(ECTM), &
!ewl                            clock       = CLOCK,     &
!ewl                            userRC      = STATUS  )
!ewl    _VERIFY(STATUS)
!ewl
!ewl    call MAPL_TimerOff( STATE, GCNames(ECTM) )
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'GIGC, after  GEOS_ctmE: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl    ! Dynamics & Advection
!ewl    !------------------
!ewl    ! SDE 2017-02-18: This needs to run even if transport is off, as it is
!ewl    ! responsible for the pressure level edge arrays. It already has an internal
!ewl    ! switch ("AdvCore_Advection") which can be used to prevent any actual
!ewl    ! transport taking place by bypassing the advection calculation.
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'GIGC, before Advection: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl    call MAPL_TimerOn ( STATE, GCNames(ADV) )
!ewl    call ESMF_GridCompRun ( GCS(ADV),               &
!ewl                            importState = GIM(ADV), &
!ewl                            exportState = GEX(ADV), &
!ewl                            clock       = CLOCK,    &
!ewl                            userRC      = STATUS );
!ewl    _VERIFY(STATUS)
!ewl    call MAPL_GenericRunCouplers (STATE, ADV, CLOCK, RC=STATUS );
!ewl    _VERIFY(STATUS)
!ewl    call MAPL_TimerOff( STATE, GCNames(ADV) )
!ewl
!ewl    if ( MemDebugLevel > 0 ) THEN
!ewl       call ESMF_VMBarrier(VM, RC=STATUS)
!ewl       _VERIFY(STATUS)
!ewl       call MAPL_MemUtilsWrite(VM, &
!ewl                  'GIGC, after  Advection: ', RC=STATUS )
!ewl       _VERIFY(STATUS)
!ewl    endif
!ewl
!ewl    ENDIF
!ewl#endif
!ewl
!ewl    call MAPL_TimerOff(STATE,"RUN")
!ewl    call MAPL_TimerOff(STATE,"TOTAL")

    ! Added for GCHP Adjoint
    firstRun = .false.

!ewl    _RETURN(ESMF_SUCCESS)
    _RETURN(_SUCCESS)

  end subroutine Run

!=============================================================================

  subroutine Finalize( GC, IMPORT, EXPORT, CLOCK, RC )

    type(ESMF_GridComp):: gc   ! composite gridded component
    type(ESMF_State) :: import ! import state
    type(ESMF_State) :: export ! export state
    type(ESMF_Clock) :: clock  ! the clock
    integer, intent(out) :: rc ! Error code, 0 all is well

! !DESCRIPTION: The Finalize method 

!EOP

! ErrLog Variables

     character(len=ESMF_MAXSTR)          :: IAm 
     integer                             :: STATUS
     character(len=ESMF_MAXSTR)          :: COMP_NAME

     ! ewl new
     class(logger_t), pointer :: logger

     !ewl  ! Get the target component name and set-up traceback handle
     !ewl  Iam = "Finalize"
     !ewl  call ESMF_GridCompGet ( GC, name=COMP_NAME, RC=STATUS )
     !ewl  _VERIFY(STATUS)
     !ewl  Iam = trim(COMP_NAME) // Iam
     call MAPL_GridCompGet(gc, logger=logger, _RC)
     call logger%info("Finalize::GCHP_GridCompMod:: starting...")

     !ewl comment out for now since does not work. Maybe not needed anymore?
     ! ewl: dyncore has its own finalize routine specific to the state
     ! Call generic finalize
     !call MAPL_GenericFinalize( GC, IMPORT, EXPORT, CLOCK, RC=STATUS )
     !_VERIFY(STATUS)

     ! ewl: are these still needed?
     ! Destroy import and export states
     call ESMF_StateDestroy(IMPORT, rc=status)
     _VERIFY(STATUS)
     call ESMF_StateDestroy(EXPORT, rc=status)
     _VERIFY(STATUS)

     _RETURN(ESMF_SUCCESS)
   end subroutine Finalize

!=============================================================================

 end module GCHP_GridCompMod
