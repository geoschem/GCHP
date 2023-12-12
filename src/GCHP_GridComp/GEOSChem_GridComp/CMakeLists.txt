# GEOSChem_GridComp/CMakeLists.txt

# Cached variables
set(USE_REAL8 ON CACHE BOOL
  "Switch to set flexible precision 8-byte floating point real"
)
set(RRTMG OFF CACHE BOOL
  "Switch to build RRTMG as a component of GEOS-Chem"
)
set(TOMAS OFF CACHE BOOL
  "Switch to build TOMAS as a component of GEOS-Chem"
)
set(LUO_WETDEP OFF CACHE BOOL
  "Switch to build the Luo et al (2020) wetdep scheme into GEOS-Chem"
)
set(FASTJX OFF CACHE BOOL
  "Switch to use legacy FAST-JX photolysis in GEOS-Chem"
)

# Local variables
set(GC_EXTERNAL_CONFIG      TRUE)
set(GTMM                    FALSE)
set(MECH "fullchem" CACHE STRING "Name of the chemistry mechanism to use")
set(GCHP                    TRUE)
set(MODEL_GCHP              TRUE)
set(MODEL_GCHPCTM           TRUE)

# Add directories to build
add_subdirectory(geos-chem EXCLUDE_FROM_ALL)

# Configure build properties for GEOS-Chem
target_compile_definitions(GEOSChemBuildProperties INTERFACE
  ESMF_ EXTERNAL_GRID NC_HAS_COMPRESSION MODEL_GCHPCTM MODEL_GCHP
  $<$<BOOL:${USE_REAL8}>:USE_REAL8> $<$<BOOL:${RRTMG}>:RRTMG>
  $<$<BOOL:${ADJOINT}>:ADJOINT>
  $<$<BOOL:${REVERSE_OPERATORS}>:REVERSE_OPERATORS> 
  $<$<BOOL:${TOMAS}>:TOMAS>
  $<$<STREQUAL:${TOMAS_BINS},15>:TOMAS15>
  $<$<STREQUAL:${TOMAS_BINS},40>:TOMAS40>
  $<$<BOOL:${LUO_WETDEP}>:LUO_WETDEP>
  $<$<BOOL:${FASTJX}>:FASTJX>
)

target_link_libraries(GEOSChemBuildProperties INTERFACE
    $<LINK_ONLY:MAPL.base>
    $<LINK_ONLY:FVdycoreCubed_GridComp>
    $<LINK_ONLY:HCOI_MAPL_ESMF>
    $<$<BOOL:${OMP}>:OpenMP::OpenMP_Fortran>
    MPI::MPI_C MPI::MPI_Fortran
)
target_include_directories(GEOSChemBuildProperties INTERFACE
    $<TARGET_PROPERTY:MAPL.base,INTERFACE_INCLUDE_DIRECTORIES>
    $<TARGET_PROPERTY:FVdycoreCubed_GridComp,INTERFACE_INCLUDE_DIRECTORIES>
    $<TARGET_PROPERTY:HCOI_MAPL_ESMF,INTERFACE_INCLUDE_DIRECTORIES>
    ${CMAKE_Fortran_MODULE_DIRECTORY}
)

set(GEOSChem_Fortran_FLAGS_Intel
    -cpp -w -auto -noalign "SHELL:-convert big_endian" "SHELL:-fp-model source"
    -mcmodel=medium -shared-intel -traceback -DLINUX_IFORT
    CACHE STRING "GEOSChem compiler flags for all build types with Intel compilers"
)
set(GEOSChem_Fortran_FLAGS_RELEASE_Intel
   -O2
    CACHE STRING "GEOSChem compiler flags for build type release with Intel compilers"
)
set(GEOSChem_Fortran_FLAGS_RELWITHDEBINFO_Intel
    -O2
    CACHE STRING "GEOSChem compiler flags for build type relwithdebinfo with Intel compilers"
)
set(GEOSChem_Fortran_FLAGS_DEBUG_Intel
    -g -O0 "SHELL:-check arg_temp_created" "SHELL:-debug all" -fpe0 -ftrapuv -check,bounds
    CACHE STRING "GEOSChem compiler flags for build type debug with Intel compilers"
)

set(GEOSChem_Fortran_FLAGS_GNU
    -cpp -w -std=legacy -fautomatic -fno-align-commons
    -fconvert=big-endian -fno-range-check -mcmodel=medium
    -fbacktrace -g -DLINUX_GFORTRAN -ffree-line-length-none
    CACHE STRING "GEOSChem compiler flags for all build types with GNU compilers"
)
set(GEOSChem_Fortran_FLAGS_RELEASE_GNU
   -O3 -funroll-loops
   CACHE STRING "GEOSChem compiler flags for build type release with GNU compilers"
)
set(GEOSChem_Fortran_FLAGS_RELWITHDEBINFO_GNU
   -O3 -funroll-loops
   CACHE STRING "GEOSChem compiler flags for build type relwithdebinfo with GNU compilers"
)
set(GEOSChem_Fortran_FLAGS_DEBUG_GNU
    -g -gdwarf-2 -gstrict-dwarf -O0 -Wall -Wextra -Wconversion -Warray-temporaries
    -fcheck=array-temps -ffpe-trap=invalid,zero,overflow -finit-real=snan
    -fcheck=bounds -fcheck=pointer
    CACHE STRING "GEOSChem compiler flags for build type debug with GNU compilers"
)
set(CMAKE_Fortran_FLAGS "")
set(CMAKE_Fortran_FLAGS_RELEASE "")
set(CMAKE_Fortran_FLAGS_Debug "")
set(CMAKE_Fortran_FLAGS_RelWithDebInfo "")

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
gc_pretty_print(VARIABLE MECH OPTIONS "fullchem" "carbon" "custom")
gc_pretty_print(VARIABLE OMP IS_BOOLEAN)
gc_pretty_print(VARIABLE USE_REAL8 IS_BOOLEAN)
gc_pretty_print(VARIABLE APM IS_BOOLEAN)
gc_pretty_print(VARIABLE TOMAS IS_BOOLEAN)
gc_pretty_print(VARIABLE RRTMG IS_BOOLEAN)
gc_pretty_print(VARIABLE GTMM IS_BOOLEAN)
gc_pretty_print(VARIABLE LUO_WETDEP IS_BOOLEAN)
gc_pretty_print(VARIABLE FASTJX IS_BOOLEAN)
