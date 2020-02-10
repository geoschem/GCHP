#---------------
# Add FV3
#---------------
set(FV_PRECISION R8) # GCHP's FV3 precision is R8
add_subdirectory(FVdycoreCubed_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add GEOS-Chem
#---------------
add_subdirectory(GEOSChem_GridComp EXCLUDE_FROM_ALL)

#---------------
# Add GEOSctmEnv
#---------------
add_subdirectory(GEOSctmEnv_GridComp EXCLUDE_FROM_ALL)

#--------------------------------
# Create the GCHP_GridComp target
#--------------------------------
add_library(GCHP_GridComp STATIC
    GIGC_GridCompMod.F90 # Will be renamed to GCHP_GridCompMod.F90
)
target_link_libraries(GCHP_GridComp PUBLIC GEOSctmEnv_GridComp GCHP)
