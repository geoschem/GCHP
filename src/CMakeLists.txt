# Add gFTL-shared
set(GIT_SUBMODULE OFF CACHE BOOL "Prevent gFTL-shared from trying to checkout its gFTL submodule")
add_subdirectory(gFTL-shared EXCLUDE_FROM_ALL)

# Add pFUnit
set(PFUNIT_FOUND FALSE) # Do not rely on ESMA_cmake/FindBaseLibs.cmake to set this
if(PFUNIT_FOUND)
  add_subdirectory(pFUnit EXCLUDE_FROM_ALL)
endif()

# Add yaFyaml
add_subdirectory(yaFyaml EXCLUDE_FROM_ALL)

# Add pFlogger
add_subdirectory(pFlogger EXCLUDE_FROM_ALL)

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
add_executable(gchp
    GCHPctm.F90
)
target_link_libraries(gchp
	PUBLIC GCHP_GridComp ${CMAKE_DL_LIBS}
)
set_target_properties(gchp PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
foreach(RUNDIR_PATH ${RUNDIR})
	# If RUNDIR is not a relative path, make it an absolute path relative to the build directory
	if(NOT IS_ABSOLUTE "${RUNDIR_PATH}")
		get_filename_component(RUNDIR_PATH "${RUNDIR_PATH}" ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")
	endif()
	install(TARGETS gchp RUNTIME DESTINATION ${RUNDIR_PATH})
endforeach()
