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
# MAPL2:
add_library(GCHP_GridComp STATIC
    GCHP_GridCompMod.F90
)

# For MAPL3 (in development)
#add_library(GCHP_GridComp SHARED
#    GCHP_GridCompMod.F90
#)

#----------------------------------------------------
# Set compile definitions and link libraries
#----------------------------------------------------

# For MAPL2:
target_link_libraries(GCHP_GridComp PUBLIC GCHPctmEnv_GridComp GCHP $<LINK_ONLY:HCOI_MAPL_ESMF>)

# For MAPL3:
#target_link_libraries(GCHP_GridComp PUBLIC
#  GCHPctmEnv_GridComp
#  GEOSChem_GridComp
#  GCHP
#  $<LINK_ONLY:HCOI_MAPL_ESMF>
#  $<LINK_ONLY:mapl3g>
#)
#target_link_libraries(GCHP_GridComp INTERFACE
#  $<LINK_ONLY:MAPL.cap3g>
#)
#target_include_directories(GCHP_GridComp PUBLIC
#  $<TARGET_PROPERTY:mapl3g,INTERFACE_INCLUDE_DIRECTORIES>
#)
#target_include_directories(GCHP_GridComp INTERFACE
#  $<TARGET_PROPERTY:MAPL.cap3g,INTERFACE_INCLUDE_DIRECTORIES>
#)
