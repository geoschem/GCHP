#include "MAPL_Generic.h"
!=============================================================================
!BOP

! !MODULE: 
! GIGC\_GridCompMod -- this gridded component (GC) builds an ESMF application 
! out of the following three (children) components:
!   1. Advection (DYNAMICS)
!   2. Traditional GEOS-Chem except for advection (GIGCchem)
!   3. Cinderella component to derive variables for other components (GIGCenv)
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

module GIGC_GridCompMod

! !USES:

  use ESMF
  use MAPL_Mod
  use CHEM_GridCompMod,    only : AtmosChemSetServices => SetServices
  use AdvCore_GridCompMod, only : AtmosAdvSetServices  => SetServices
  use GEOS_ctmEnvGridComp, only : EctmSetServices      => SetServices

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

contains

!BOP

! !IROUTINE: SetServices -- Sets ESMF services for this component

! !INTERFACE:

    subroutine SetServices ( GC, RC )

! !ARGUMENTS:

    type(ESMF_GridComp), intent(INOUT) :: GC  ! gridded component
    integer,             intent(  OUT) :: RC  ! return code

! !DESCRIPTION:  The SetServices for the GIGC gridded component needs to 
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

!=============================================================================

! Begin...

    ! Get the target component name and set-up traceback handle
    !-----------------------------------------------------------
    Iam = 'SetServices'
    call ESMF_GridCompGet( GC, NAME=COMP_NAME, CONFIG=CF, RC=STATUS )
    _VERIFY(STATUS)
    Iam = trim(COMP_NAME) // "::" // Iam

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

! !IMPORT STATE:

! !EXPORT STATE:

! Create children`s gridded components and invoke their SetServices
! -----------------------------------------------------------------

   ! Add component for deriving variables for other components
   ECTM = MAPL_AddChild(GC, NAME='GIGCenv' , SS=EctmSetServices,      &
                            RC=STATUS)
   _VERIFY(STATUS)

   ! Add chemistry
   CHEM = MAPL_AddChild(GC, NAME='GIGCchem', SS=AtmosChemSetServices, &
                        RC=STATUS)
   _VERIFY(STATUS)

   ! Add dynamics
   ADV = MAPL_AddChild(GC, NAME='DYNAMICS',  SS=AtmosAdvSetServices,  &
                       RC=STATUS)
   _VERIFY(STATUS)

! Set internal connections between the children`s IMPORTS and EXPORTS
! -------------------------------------------------------------------
!BOP

! !CONNECTIONS:

      ! Connectivities between Children
      ! -------------------------------
      CALL MAPL_AddConnectivity ( GC,                       &
                                  SHORT_NAME  = (/'AREA'/), &
                                  DST_ID = ECTM,            &
                                  SRC_ID = ADV,             &
                                  __RC__ )

      CALL MAPL_AddConnectivity ( GC,                          &
                                  SHORT_NAME  = (/'AIRDENS'/), &
                                  DST_ID = CHEM,               &
                                  SRC_ID = ECTM,               &
                                  __RC__  )

      CALL MAPL_AddConnectivity ( GC, &
                                  SRC_NAME  = (/ 'CXr8     ',    &
                                                 'CYr8     ',    &
                                                 'MFXr8    ',    &
                                                 'MFYr8    ',    &
                                                 'PLE0r8   ',    &
                                                 'PLE1r8   ',    &
                                                 'DryPLE0r8',    &
                                                 'DryPLE1r8' /), &
                                  DST_NAME  = (/ 'CX     ',      &
                                                 'CY     ',      &
                                                 'MFX    ',      &
                                                 'MFY    ',      &
                                                 'PLE0   ',      &
                                                 'PLE1   ',      &
                                                 'DryPLE0',      &
                                                 'DryPLE1'   /), &
                                  DST_ID = ADV,                  &
                                  SRC_ID = ECTM,                 &
                                  __RC__  )

      CALL MAPL_AddConnectivity ( GC,                          &
                                  SHORT_NAME = (/ 'AREA  ',    &
                                                  'PLE   ',    &
                                                  'DryPLE' /), &
                                  DST_ID   = CHEM,             &
                                  SRC_ID = ADV,                &
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
! !IROUTINE: Initialize -- Initialize method for the GIGC Gridded Component

! !INTERFACE:

  subroutine Initialize ( GC, IMPORT, EXPORT, CLOCK, RC )

! !ARGUMENTS:

  type(ESMF_GridComp), intent(inout) :: GC     ! Gridded component 
  type(ESMF_State),    intent(inout) :: IMPORT ! Import state
  type(ESMF_State),    intent(inout) :: EXPORT ! Export state
  type(ESMF_Clock),    intent(inout) :: CLOCK  ! The clock
  integer, optional,   intent(  out) :: RC     ! Error code

! !DESCRIPTION: The Initialize method of the GIGC Composite Gridded 
!  Component. It acts as a driver for the initialization of the three 
!  children: DYNAMICS, GIGCchem, and GIGCenv.
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

! !IROUTINE: Run -- Run method for the composite GIGC Gridded Component
                 
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

! !DESCRIPTION: The run method for the GIGC gridded component calls the 
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

    call MAPL_TimerOff(STATE,"RUN")
    call MAPL_TimerOff(STATE,"TOTAL")

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

 end module GIGC_GridCompMod
