# GCHP_GridComp/CMakeLists.txt

set(FV_PRECISION R8)
set(GCHP_WRAPPER TRUE)
set(GC_EXTERNAL_CONFIG TRUE)
set(MAPL_ESMF TRUE)

# Add child gridded components
add_subdirectory (FVdycoreCubed_GridComp EXCLUDE_FROM_ALL)
add_subdirectory (GEOSChem_GridComp EXCLUDE_FROM_ALL) # Built but not yet used
add_subdirectory (GCHPctmEnv_GridComp EXCLUDE_FROM_ALL)

esma_set_this (OVERRIDE GCHP_GridComp)
esma_add_library (${this}
  SRCS GCHP_GridCompMod.F90
  DEPENDENCIES MAPL fvdycore   # fvdycore only for fv_arrays_mod
  TYPE SHARED
)

## Previous method used, now obsolete since using dso
#add_library (GCHP_GridComp SHARED
#  GCHP_GridCompMod.F90
#)
#
#target_link_libraries (GCHP_GridComp PUBLIC
#  GCHP
#  MAPL
#  $<LINK_ONLY:HCOI_MAPL_ESMF>
#)
#install (TARGETS GCHP_GridComp LIBRARY DESTINATION lib)
