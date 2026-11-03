# GCHP_GridComp/CMakeLists.txt

#---------------
# Set cmake logicals needed for subprojects
#---------------
set(FV_PRECISION           R8    ) # FV3 precision is R8
set(MAPL_ACG ${CMAKE_CURRENT_SOURCE_DIR}/../MAPL/Apps/mapl_acg.pl)

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

#--------------------------------
# Create the GCHP_GridComp target
#--------------------------------
if(MAPL3)

  # MAPL3 (in development): shared library loaded at run time by MAPL3
  esma_set_this(OVERRIDE GCHP_GridComp)
  esma_add_library(${this}
    SRCS GCHP_GridCompMod.mapl3.F90
    DEPENDENCIES MAPL fvdycore   # fvdycore only for fv_arrays_mod
    TYPE SHARED
  )
  target_compile_definitions(${this} PRIVATE MAPL3)

else()

  # MAPL2
  add_library(GCHP_GridComp STATIC
      GCHP_GridCompMod.F90
  )
  target_link_libraries(GCHP_GridComp PUBLIC GCHPctmEnv_GridComp GCHP $<LINK_ONLY:HCOI_MAPL_ESMF>)

endif()
