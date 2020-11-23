# GEOSChem_GridComp/CMakeLists.txt

# Cached variables
set(USE_REAL8 ON CACHE BOOL
  "Switch to set flexible precision 8-byte floating point real"
)
set(RRTMG OFF CACHE BOOL
  "Switch to build RRTMG as a component of GEOS-Chem"
)

# Local variables
set(GC_EXTERNAL_CONFIG      TRUE)
set(GTMM                    FALSE)
set(TOMAS                   FALSE)
set(MECH                    "fullchem") # for now, we only support "fullchem"
set(GCHP                    TRUE)
set(MODEL_GCHP              TRUE)
set(MODEL_GCHPCTM           TRUE)
add_subdirectory(geos-chem EXCLUDE_FROM_ALL)

# Configure build properties for GEOS-Chem
target_compile_definitions(GEOSChemBuildProperties INTERFACE
  ESMF_ EXTERNAL_GRID NC_HAS_COMPRESSION MODEL_GCHPCTM MODEL_GCHP
  $<$<BOOL:${USE_REAL8}>:USE_REAL8> $<$<BOOL:${RRTMG}>:RRTMG>
)

target_link_libraries(GEOSChemBuildProperties INTERFACE
    $<LINK_ONLY:MAPL.base>
    $<LINK_ONLY:FVdycoreCubed_GridComp>
    $<LINK_ONLY:HCOI_MAPL_ESMF>
    MPI::MPI_C MPI::MPI_Fortran
)
target_include_directories(GEOSChemBuildProperties INTERFACE
    $<TARGET_PROPERTY:MAPL.base,INTERFACE_INCLUDE_DIRECTORIES>
    $<TARGET_PROPERTY:FVdycoreCubed_GridComp,INTERFACE_INCLUDE_DIRECTORIES>
    $<TARGET_PROPERTY:HCOI_MAPL_ESMF,INTERFACE_INCLUDE_DIRECTORIES>
)


set(GEOSChem_Fortran_FLAGS_${CMAKE_Fortran_COMPILER_ID}
    ""
    CACHE STRING "GEOSChem compiler flags for all build types with ${CMAKE_Fortran_COMPILER_ID} compilers"
)
set(GEOSChem_Fortran_FLAGS_RELEASE_${CMAKE_Fortran_COMPILER_ID}
    ${GEOS_Fortran_FLAGS_RELEASE}
    CACHE STRING "GEOSChem compiler flags for build type release with ${CMAKE_Fortran_COMPILER_ID} compilers"
)
set(GEOSChem_Fortran_FLAGS_RELWITHDEBINFO_${CMAKE_Fortran_COMPILER_ID}
    ${GEOS_Fortran_FLAGS_RELEASE}
    CACHE STRING "GEOSChem compiler flags for build type relwithdebinfo with ${CMAKE_Fortran_COMPILER_ID} compilers"
)
set(GEOSChem_Fortran_FLAGS_DEBUG_${CMAKE_Fortran_COMPILER_ID}
    ${GEOS_Fortran_FLAGS_DEBUG}
    CACHE STRING "GEOSChem compiler flags for build type debug with ${CMAKE_Fortran_COMPILER_ID} compilers"
)

set(GEOSChem_SUPPORTED_COMPILER_IDS "Intel" "GNU")
if(NOT CMAKE_Fortran_COMPILER_ID IN_LIST GEOSChem_SUPPORTED_COMPILER_IDS)
   message(FATAL_ERROR "GEOSChem does not support ${CMAKE_Fortran_COMPILER_ID} compilers")
endif()

#---------------------------------------------------------------------
# Assign comiler options to build properties
#---------------------------------------------------------------------
target_compile_options(GEOSChemBuildProperties
   INTERFACE
   $<$<STREQUAL:${CMAKE_Fortran_COMPILER_ID},Intel>:
      ${GEOSChem_Fortran_FLAGS_Intel}
      $<$<CONFIG:Debug>:${GEOSChem_Fortran_FLAGS_DEBUG_Intel}>
      $<$<CONFIG:RelWithDebInfo>:${GEOSChem_Fortran_FLAGS_RELWITHDEBINFO_Intel}>
      $<$<CONFIG:Release>:${GEOSChem_Fortran_FLAGS_RELEASE_Intel}>
   >
   $<$<STREQUAL:${CMAKE_Fortran_COMPILER_ID},GNU>:
      ${GEOSChem_Fortran_FLAGS_GNU}
      $<$<CONFIG:Debug>:${GEOSChem_Fortran_FLAGS_DEBUG_GNU}>
      $<$<CONFIG:RelWithDebInfo>:${GEOSChem_Fortran_FLAGS_RELWITHDEBINFO_GNU}>
      $<$<CONFIG:Release>:${GEOSChem_Fortran_FLAGS_RELEASE_GNU}>
   >
)

target_compile_definitions(GEOSChemBuildProperties
    INTERFACE
    $<$<STREQUAL:${CMAKE_Fortran_COMPILER_ID},Intel>:LINUX_IFORT>
    $<$<STREQUAL:${CMAKE_Fortran_COMPILER_ID},GNU>:LINUX_GFORTRAN>
)

# Print the options that are turned on in GEOS-Chem
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/geos-chem/CMakeScripts)
include(GC-Helpers)
gc_pretty_print(SECTION "Settings")
set(MECH "fullchem")
gc_pretty_print(VARIABLE OMP IS_BOOLEAN)
gc_pretty_print(VARIABLE USE_REAL8 IS_BOOLEAN)
gc_pretty_print(VARIABLE APM IS_BOOLEAN)
gc_pretty_print(VARIABLE RRTMG IS_BOOLEAN)
gc_pretty_print(VARIABLE GTMM IS_BOOLEAN)
gc_pretty_print(VARIABLE LUO_WETDEP IS_BOOLEAN)
