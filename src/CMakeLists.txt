# Add gFTL-shared
set(GIT_SUBMODULE OFF CACHE BOOL "Prevent gFTL-shared from trying to checkout its gFTL submodule")
add_subdirectory(gFTL-shared EXCLUDE_FROM_ALL)

# Add MAPL
set(LATEX_FOUND FALSE) # Disable LaTeX support (to avoid dependencies like ImageMagick)
add_subdirectory(MAPL EXCLUDE_FROM_ALL)

# Add GMAO_Shared
set(NO_F2PY TRUE)
add_subdirectory(GMAO_Shared EXCLUDE_FROM_ALL)

# Add FMS
add_subdirectory(FMS fms_r8 EXCLUDE_FROM_ALL)

# Add GCHP_GridComp
add_subdirectory(GCHP_GridComp EXCLUDE_FROM_ALL)

# The executable
add_executable(geos
    GCHPctm.F90
)
target_link_libraries(geos
	PUBLIC GCHP_GridComp ${CMAKE_DL_LIBS}
)
install(TARGETS geos RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})
