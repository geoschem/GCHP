# GCHP_GridComp/CMakeLists.txt

# Set cmake logicals
set(FV_PRECISION R8)         # Set FV3 precision to R8
set(GCHP_WRAPPER TRUE)       # ewl: what is this used for?
set(GC_EXTERNAL_CONFIG TRUE) # ewl: what is this used for?
set(MAPL_ESMF TRUE)          # HEMCO and GEOS-Chem will use MAPL/ESMF

# Create the target
add_library (GCHP_GridComp SHARED
  GCHP_GridCompMod.F90
)

# Add gridded components
add_subdirectory (FVdycoreCubed_GridComp EXCLUDE_FROM_ALL)
add_subdirectory (GEOSChem_GridComp EXCLUDE_FROM_ALL)
add_subdirectory (GCHPctmEnv_GridComp EXCLUDE_FROM_ALL)

# Set compile definitions and link libraries
target_compile_definitions (GCHP_GridComp PRIVATE
  $<$<BOOL:${MODEL_CTMENV}>:MODEL_CTMENV>
)
target_link_libraries (GCHP_GridComp PUBLIC
  GCHPctmEnv_GridComp
  GCHP
  $<LINK_ONLY:MAPL>
  $<LINK_ONLY:HCOI_MAPL_ESMF>
)

