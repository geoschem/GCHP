# Configure GEOS-Chem's configuration behaviour
set(GC_EXTERNAL_CONFIG      TRUE)
set(RRTMG                   FALSE)
set(GTMM                    FALSE)
set(TOMAS                   FALSE)
set(MECH                    "Standard") # for now, we only support "Standard"
set(GCHP                    TRUE)

# Add geos-chem
add_subdirectory(geos-chem)

# Configure BaseTarget for GCHP
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


# Add the registry
set(MAPL_ACG ${CMAKE_CURRENT_SOURCE_DIR}/../../MAPL/MAPL_Base/mapl_acg.pl)
add_subdirectory(Registry)

# Add GCHP targets
add_library(GEOSChem_GridComp STATIC
    Chem_GridCompMod.F90
    gigc_chunk_mod.F90
	gigc_historyexports_mod.F90
	gigc_providerservices_mod.F90
)
target_link_libraries(GEOSChem_GridComp
	PUBLIC GeosCore
)
add_dependencies(GEOSChem_GridComp registry)
target_include_directories(GEOSChem_GridComp PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/Registry)
