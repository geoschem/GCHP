# GCHPctmEnv_GridComp/CMakeLists.txt

add_library(GCHPctmEnv_GridComp STATIC
    GCHPctmEnv_GridCompMod.F90
)
target_link_libraries(GCHPctmEnv_GridComp PUBLIC GeosCore)
