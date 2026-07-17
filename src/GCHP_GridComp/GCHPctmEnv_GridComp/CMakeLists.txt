# GCHPctmEnv_GridComp/CMakeLists.txt

add_library(GCHPctmEnv_GridComp SHARED
    GCHPctmEnv_GridCompMod.F90
)
target_link_libraries(GCHPctmEnv_GridComp PUBLIC
  GeosCore
  $<LINK_ONLY:MAPL.base3g>
)
target_include_directories(GCHPctmEnv_GridComp PUBLIC
  $<TARGET_PROPERTY:MAPL.base3g,INTERFACE_INCLUDE_DIRECTORIES>
)
