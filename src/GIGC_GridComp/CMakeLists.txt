
set(FV_PRECISION R8)
add_subdirectory(AdvCore_GridComp EXCLUDE_FROM_ALL)
add_subdirectory(GEOSChem_GridComp EXCLUDE_FROM_ALL)
add_subdirectory(GEOSctmEnv_GridComp EXCLUDE_FROM_ALL)

add_library(GIGC_GridComp STATIC
    GIGC_GridCompMod.F90
)
target_link_libraries(GIGC_GridComp PUBLIC GEOSctmEnv_GridComp)