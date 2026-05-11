# GCHPctmEnv_GridComp/CMakeLists.txt

# MAPL2
add_library(GCHPctmEnv_GridComp STATIC
    GCHPctmEnv_GridCompMod.F90
)
target_link_libraries(GCHPctmEnv_GridComp PUBLIC GeosCore)

# MAPL3 (in development)
#add_library(GCHPctmEnv_GridComp SHARED
#     GCHPctmEnv_GridCompMod.F90
# )
#target_link_libraries(GCHPctmEnv_GridComp PUBLIC
#  GeosCore
#  $<LINK_ONLY:mapl3g>
#  $<LINK_ONLY:MAPL.generic3g>
#  $<LINK_ONLY:MAPL.state>
#)
#target_include_directories(GCHPctmEnv_GridComp PUBLIC
#  $<TARGET_PROPERTY:mapl3g,INTERFACE_INCLUDE_DIRECTORIES>
#  $<TARGET_PROPERTY:MAPL.generic3g,INTERFACE_INCLUDE_DIRECTORIES>
#  $<TARGET_PROPERTY:MAPL.state,INTERFACE_INCLUDE_DIRECTORIES>
#)
## Comment out for now, and use yaml file
##mapl_acg(GCHPctmEnv_GridComp GCHPctmEnv_StateSpecs.rc
##  IMPORT_SPECS EXPORT_SPECS INTERNAL_SPECS
##  GET_POINTERS DECLARE_POINTERS
##  3g
##)
