# GEOSChem_GridComp/CMakeLists.txt

set(GC_EXTERNAL_CONFIG      TRUE)
set(RRTMG                   FALSE)
set(GTMM                    FALSE)
set(TOMAS                   FALSE)
set(MECH                    "Standard") # for now, we only support "Standard"
set(GCHP                    TRUE)
set(MODEL_GCHP              TRUE)
set(MODEL_GCHPCTM           TRUE)
add_subdirectory(geos-chem EXCLUDE_FROM_ALL)

# Configure build properties for GEOS-Chem
target_compile_definitions(GEOSChemBuildProperties INTERFACE
        ESMF_ EXTERNAL_GRID USE_REAL8 NC_HAS_COMPRESSION BPCH_TBPC MODEL_GCHPCTM MODEL_GCHP
)

target_link_libraries(GEOSChemBuildProperties INTERFACE
    MAPL_Base
    FVdycoreCubed_GridComp
    MPI::MPI_C MPI::MPI_Fortran
    HCOI_GCHP
)

# Configure GEOSChemBuildProperties's compiler options
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/geos-chem/CMakeScripts)

