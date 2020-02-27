add_library(GCHPctmEnv_GridComp STATIC
    GCHPctmEnv_GridComp.F90
)
target_link_libraries(GCHPctmEnv_GridComp PUBLIC GeosCore)
