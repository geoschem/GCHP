# GCHP_GridComp/CMakeLists.txt

#---------------
# Set cmake logicals needed for subprojects
#---------------
set(FV_PRECISION           R8    ) # FV3 precision is R8
set(GCHP_WRAPPER           TRUE  ) # GCHP model configuration
set(GC_EXTERNAL_CONFIG     TRUE  ) # Not GEOS-Chem Classic
set(MAPL_ESMF              TRUE  ) # HEMCO and GEOS-Chem will use MAPL/ESMF
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
add_library(GCHP_GridComp STATIC
    GCHP_GridCompMod.F90
)
target_link_libraries(GCHP_GridComp PUBLIC GCHPctmEnv_GridComp GCHP $<LINK_ONLY:HCOI_MAPL_ESMF>)
