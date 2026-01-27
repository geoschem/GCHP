# GCHPctmEnv_GridComp/CMakeLists.txt

add_library(GCHPctmEnv_GridComp SHARED
    GCHPctmEnv_GridCompMod.F90
)
target_link_libraries(GCHPctmEnv_GridComp PUBLIC
  GeosCore
  $<LINK_ONLY:mapl3g>
)
target_include_directories(GCHPctmEnv_GridComp PUBLIC
  $<TARGET_PROPERTY:mapl3g,INTERFACE_INCLUDE_DIRECTORIES>
)
