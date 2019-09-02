add_library(GEOSctmEnv_GridComp STATIC
    GEOS_ctmEnvGridComp.F90
)
target_link_libraries(GEOSctmEnv_GridComp PUBLIC GEOSChem_GridComp)