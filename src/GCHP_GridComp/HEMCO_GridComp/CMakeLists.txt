# HEMCO_GridComp/CMakeLists.txt

#add_library(HEMCO_GridComp STATIC
#    HEMCO_GridCompMod.F90
#)
#target_link_libraries(HEMCO_GridComp PUBLIC GeosCore)

add_subdirectory(HEMCO EXCLUDE_FROM_ALL)
set(HEMCO_EXTERNAL_CONFIG   TRUE)

#   set(GC_EXTERNAL_CONFIG      TRUE)
#   set(RRTMG                   FALSE)
#   set(GTMM                    FALSE)
#   set(TOMAS                   FALSE)
#   set(MECH                    "Standard") # for now, we only support "Standard"
#   set(GCHP                    TRUE)
#   set(MODEL_GCHP              TRUE)
#   set(MODEL_GCHPCTM           TRUE)
#   set(MAPL_ACG ${CMAKE_CURRENT_SOURCE_DIR}/../../MAPL/MAPL_Base/mapl_acg.pl)
   

#target_link_libraries(HEMCO_GridComp INTERFACE
#    MAPL_Base
#    MPI::MPI_C MPI::MPI_Fortran
#)

#   
#   # Configure BaseTarget's compiler options
#   list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/HEMCO/CMakeScripts)
#   include(HEMCO-DefaultCompilerOptions)
#
# Can get rid of this. The file is storedin GEOSchem_GridComp not in HEMCO
# in GEOSgcm.
#
#if(GEOS)
#   esma_set_this ()
#   
#   set (srcs
#      HEMCO_GridCompMod.F90
#      )
#   
#   esma_add_library (
#     ${this}
#     SRCS ${srcs}
#     DEPENDENCIES Chem_Shared MAPL HEMCO
#     )
#   target_compile_definitions (${this} PRIVATE ESMF_ DEVEL GEOS_FP)
#   target_include_directories (${this} PUBLIC ${INC_ESMF} ${INC_NETCDF})
#   
#   set (acg_headers
#     HEMCO_InternalSpec___.h HEMCO_DeclarePointer___.h HEMCO_GetPointer___.h
#     )
#   add_custom_command (
#     OUTPUT ${acg_headers}
#     COMMAND ${esma_include}/MAPL_Base/mapl_acg.pl ${acg_flags} -v -F ${CMAKE_CURRENT_SOURCE_DIR}/HEMCO_Registry.rc
#     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
#     MAIN_DEPENDENCY HEMCO_Registry.rc 
#   #  DEPENDS ${include_MAPL_Base}/mapl_acg.pl
#     COMMENT "Generating automated code for HEMCO"
#     )
#   add_custom_target (phony_HEMCO DEPENDS ${acg_headers})
#   add_dependencies (${this} phony_HEMCO)
#   
#   file (GLOB resource_files "*.rc")
#   
#   install(
#      FILES ${resource_files}
#      DESTINATION etc
#      )
#else()
#   add_subdirectory(HEMCO EXCLUDE_FROM_ALL)
#   
#   # Configure BaseTarget for HEMCO
#   target_compile_definitions(BaseTarget INTERFACE
#           ESMF_
#   )
#   
#   target_link_libraries(BaseTarget INTERFACE
#       MAPL_Base
#       MPI::MPI_C MPI::MPI_Fortran
#   )
#   
#   # Configure BaseTarget's compiler options
#   list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/HEMCO/CMakeScripts)
#   include(HEMCO-DefaultCompilerOptions)
#endif()
