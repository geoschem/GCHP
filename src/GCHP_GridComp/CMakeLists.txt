# GCHP_GridComp/CMakeLists.txt

#---------------
# Set cmake logicals needed for subprojects
#---------------
set(FV_PRECISION          R8    ) # FV3 precision is R8
set(HEMCO_EXTERNAL_CONFIG TRUE  ) # Not HEMCO standalone
set(GC_EXTERNAL_CONFIG    TRUE  ) # Not GEOS-Chem Classic
set(MAPL_ESMF             TRUE  ) # HEMCO and GEOS-Chem will use MAPL/ESMF
set(MAPL_ACG ${CMAKE_CURRENT_SOURCE_DIR}/../MAPL/Apps/mapl_acg.pl)

#---------------
# Add FV3
#---------------
add_subdirectory(FVdycoreCubed_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add HEMCO
#---------------
add_subdirectory(HEMCO_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add GEOS-Chem
#---------------
add_subdirectory(GEOSChem_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add GCHPctmEnv
#---------------
add_subdirectory(GCHPctmEnv_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add Skeleton
#---------------
add_subdirectory(Skeleton_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add aCHEM
#---------------
add_subdirectory(GEOSachem EXCLUDE_FROM_ALL)

#---------------
# Add MAM
#---------------
add_subdirectory(MAM EXCLUDE_FROM_ALL)

#---------------
# Add Aerosols
#---------------
add_subdirectory(GCHP_Aerosols EXCLUDE_FROM_ALL)

#--------------------------------
# Create the GCHP_GridComp target
#--------------------------------
add_library(GCHP_GridComp STATIC
    GCHP_GridCompMod.F90
)
target_link_libraries(GCHP_GridComp PUBLIC GCHPctmEnv_GridComp GCHP $<LINK_ONLY:HCOI_MAPL_ESMF>)
target_link_libraries(GCHP_GridComp PUBLIC Skeleton_GridComp   GCHP $<LINK_ONLY:HCOI_MAPL_ESMF>)
target_link_libraries(GCHP_GridComp PUBLIC GEOSachem           GCHP $<LINK_ONLY:HCOI_MAPL_ESMF>)
target_link_libraries(GCHP_GridComp PUBLIC MAM                 GCHP $<LINK_ONLY:HCOI_MAPL_ESMF>)
target_link_libraries(GCHP_GridComp PUBLIC Aerosols_GridComp   GCHP $<LINK_ONLY:HCOI_MAPL_ESMF>)

