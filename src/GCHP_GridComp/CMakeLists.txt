# GCHP_GridComp/CMakeLists.txt

#---------------
# Set cmake logicals needed for subprojects
#---------------
set(FV_PRECISION           R8    ) # FV3 precision is R8
set(GCHP_WRAPPER           TRUE  ) # GCHP model configuration
set(GC_EXTERNAL_CONFIG     TRUE  ) # Not GEOS-Chem Classic
set(MAPL_ESMF              TRUE  ) # HEMCO and GEOS-Chem will use MAPL/ESMF
set(MAPL_ACG ${CMAKE_CURRENT_SOURCE_DIR}/../MAPL/Apps/mapl_acg.pl)

#---------------
# Set whether running in CTMenv-only mode, with GEOS-chem not added
# as a gridded component and FV3 not run
#---------------
option(MODEL_CTMENV "Enable CTMenv-only mode in GCHP" OFF)
if(MODEL_CTMENV)
  message(STATUS "WARNING: Running in CTMenv-only mode in GCHP!")
endif()

#--------------------------------
# Create the GCHP_GridComp target
#--------------------------------
add_library(GCHP_GridComp STATIC
    GCHP_GridCompMod.F90
)

#-------------------------------------------
# Add DYNAMICS gridded component (advection)
#-------------------------------------------
add_subdirectory(FVdycoreCubed_GridComp EXCLUDE_FROM_ALL)

#-------------------------------------------
# Add GCHPchem gridded component (GEOS-Chem)
#-------------------------------------------
add_subdirectory(GEOSChem_GridComp EXCLUDE_FROM_ALL)

#----------------------------------------------------
# Add GCHPctmEnv gridded component (pre-advection)
#----------------------------------------------------
add_subdirectory(GCHPctmEnv_GridComp EXCLUDE_FROM_ALL)

#----------------------------------------------------
# Set compile definitions and link libraries
#----------------------------------------------------
target_compile_definitions(GCHP_GridComp PRIVATE
  $<$<BOOL:${MODEL_CTMENV}>:MODEL_CTMENV>
)
target_link_libraries(GCHP_GridComp PUBLIC
  GCHPctmEnv_GridComp
  GCHP
  $<LINK_ONLY:HCOI_MAPL_ESMF>
  $<LINK_ONLY:mapl3g>
)
target_link_libraries(GCHP_GridComp INTERFACE
  $<LINK_ONLY:MAPL.cap3g>
)
target_include_directories(GCHP_GridComp PUBLIC
  $<TARGET_PROPERTY:mapl3g,INTERFACE_INCLUDE_DIRECTORIES>
)
target_include_directories(GCHP_GridComp INTERFACE
  $<TARGET_PROPERTY:MAPL.cap3g,INTERFACE_INCLUDE_DIRECTORIES>
)
