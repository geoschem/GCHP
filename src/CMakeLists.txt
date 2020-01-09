# Add gFTL-shared
add_subdirectory(gFTL-shared EXCLUDE_FROM_ALL)

# Add MAPL
set(LATEX_FOUND FALSE) # Disable LaTeX support (to avoid dependencies like ImageMagick)
add_subdirectory(MAPL EXCLUDE_FROM_ALL)

# Add GMAO_Shared
set(NO_F2PY TRUE)
add_subdirectory(GMAO_Shared EXCLUDE_FROM_ALL)

# Add fms
add_subdirectory(fms fms_r8 EXCLUDE_FROM_ALL)

# Add GIGC_GridComp
add_subdirectory(GIGC_GridComp EXCLUDE_FROM_ALL)

# The executable
add_executable(geos
    GEOSChem.F90
)
target_link_libraries(geos
	PUBLIC GIGC_GridComp ${CMAKE_DL_LIBS}
)
install(TARGETS geos RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})