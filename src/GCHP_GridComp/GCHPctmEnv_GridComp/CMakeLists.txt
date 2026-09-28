# GCHPctmEnv_GridComp/CMakeLists.txt

esma_set_this (OVERRIDE GCHPctmEnv_GridComp)

esma_add_library (${this}
  SRCS GCHPctmEnv_GridCompMod.F90
  DEPENDENCIES MAPL FVdycoreCubed_GridComp
  TYPE SHARED)

target_include_directories (${this} PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>)

mapl_acg (${this} GCHPctmEnv_StateSpecs.acg
  IMPORT_SPECS EXPORT_SPECS GET_POINTERS DECLARE_POINTERS)

target_compile_definitions (${this} PRIVATE $<$<BOOL:${ADJOINT}>:ADJOINT>)

# old
#add_library (GCHPctmEnv_GridComp SHARED
#  GCHPctmEnv_GridCompMod.F90
#)
#
#target_link_libraries (GCHPctmEnv_GridComp PUBLIC
#  GeosCore
#  $<LINK_ONLY:MAPL>
#)
#
#target_include_directories (GCHPctmEnv_GridComp PUBLIC
#  $<TARGET_PROPERTY:MAPL,INTERFACE_INCLUDE_DIRECTORIES>
#  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
#)
#
#mapl_acg (GCHPctmEnv_GridComp GCHPctmEnv_StateSpecs.acg
#  IMPORT_SPECS
#  EXPORT_SPECS
#  GET_POINTERS
#  DECLARE_POINTERS
#)
#
#install (TARGETS GCHPctmEnv_GridComp LIBRARY DESTINATION lib)
