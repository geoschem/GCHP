#---------------
# Add FV3
#---------------
set(FV_PRECISION R8) # GCHP's FV3 precision is R8
add_subdirectory(AdvCore_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add GEOS-Chem
#---------------
set(GC_EXTERNAL_CONFIG      TRUE)
set(RRTMG                   FALSE)
set(GTMM                    FALSE)
set(TOMAS                   FALSE)
set(MECH                    "Standard") # for now, we only support "Standard"
set(GCHP                    TRUE)
add_subdirectory(geos-chem EXCLUDE_FROM_ALL)

# Configure BaseTarget for GEOS-Chem
target_compile_definitions(BaseTarget INTERFACE
        ESMF_ EXTERNAL_GRID USE_REAL8 NC_HAS_COMPRESSION BPCH_TBPC
)
target_link_libraries(BaseTarget INTERFACE
    MAPL_Base
    AdvCore_GridComp
    MPI::MPI_C MPI::MPI_Fortran
)

# Configure BaseTarget's compiler options
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/geos-chem/CMakeScripts)
include(GC-DefaultCompilerOptions)

#---------------
# Add GEOSctmEnv
#---------------
add_subdirectory(GEOSctmEnv_GridComp EXCLUDE_FROM_ALL)

#--------------------------------
# Create the GIGC_GridComp target
#--------------------------------
add_library(GIGC_GridComp STATIC
    GIGC_GridCompMod.F90
)
target_link_libraries(GIGC_GridComp PUBLIC GEOSctmEnv_GridComp GeosCore GCHP)
