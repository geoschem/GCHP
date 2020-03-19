# GCHP_GridComp/CMakeLists.txt

#---------------
# Add FV3
#---------------
set(FV_PRECISION R8) # GCHP's FV3 precision is R8
add_subdirectory(FVdycoreCubed_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add HEMCO
#---------------
set(HEMCO_EXTERNAL_CONFIG TRUE) # not HEMCO standalone
add_subdirectory(HEMCO_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add GEOS-Chem
#---------------
set(GC_EXTERNAL_CONFIG TRUE) # not GEOS-Chem Classic
add_subdirectory(GEOSChem_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add GCHPctmEnv
#---------------
add_subdirectory(GCHPctmEnv_GridComp EXCLUDE_FROM_ALL)

#--------------------------------
# Create the GCHP_GridComp target
#--------------------------------
add_library(GCHP_GridComp STATIC
    GCHP_GridCompMod.F90
)
target_link_libraries(GCHP_GridComp PUBLIC GCHPctmEnv_GridComp GCHP HCOI)
