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
    MAPL.base
    FVdycoreCubed_GridComp
    MPI::MPI_C MPI::MPI_Fortran
    HCOI_GCHP
)

# Configure GEOSChemBuildProperties's compiler options
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/geos-chem/CMakeScripts)
