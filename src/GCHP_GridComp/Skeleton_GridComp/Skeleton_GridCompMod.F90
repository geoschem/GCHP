#include "MAPL_Generic.h"

module Skeleton_GridComp
   use ESMF
   use MAPL_Mod
   
   implicit none
   private
   
   public SetServices
   
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
      
      ! Register services for this component
      call MAPL_GridCompSetEntryPoint(gc, ESMF_METHOD_INITIALIZE, Initialize, RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_GridCompSetEntryPoint(gc, ESMF_METHOD_RUN, Run, RC=STATUS)
      _VERIFY(STATUS)
      
      call MAPL_TimerAdd(gc, name="INITIALIZE", RC=STATUS)
      _VERIFY(STATUS)
      call MAPL_TimerAdd(gc, name="RUN", RC=STATUS)
      _VERIFY(STATUS)
      
      call MAPL_GenericSetServices(gc, RC=STATUS)
      _VERIFY(STATUS)
 
      write(*,*)
      write(*,*)
      write(*,*) "This is the SetServices subroutine"
 
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
      
      call MAPL_TimerOff(ggSTATE,"INITIALIZE")
      call MAPL_TimerOff(ggSTATE,"TOTAL")
      
      write(*,*)
      write(*,*)
      write(*,*) "This is the initialize subroutine"
      
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
      integer :: ndt
      
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
      
      call MAPL_TimerOff(ggState,"RUN")
      call MAPL_TimerOff(ggState,"TOTAL")
      
      _RETURN(ESMF_SUCCESS)
   end subroutine

end module Skeleton_GridComp
