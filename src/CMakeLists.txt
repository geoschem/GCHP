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
set(YAFYAML_DIR ${YAFYAML_SOURCE_DIR})
message(STATUS "${YAFYAML_DIR}")

# Add pFlogger
add_subdirectory(pFlogger EXCLUDE_FROM_ALL)

# Add MAPL
set(LATEX_FOUND FALSE) # Disable LaTeX support (to avoid dependencies like ImageMagick)
set(BUILD_WITH_FLAP OFF CACHE BOOL "Disable FLAP for GCHP build")
set(BUILD_SHARED_MAPL OFF CACHE BOOL "Build MAPL as static libraries")
add_subdirectory(MAPL EXCLUDE_FROM_ALL)

# Add GMAO_Shared
set(NO_F2PY TRUE)
add_subdirectory(GMAO_Shared EXCLUDE_FROM_ALL)

# Add FMS
add_subdirectory(FMS fms_r8 EXCLUDE_FROM_ALL)

# Add GCHP_GridComp
add_subdirectory(GCHP_GridComp EXCLUDE_FROM_ALL)

#-----------------------------------------------------------------------------
# Define the GCHP executable:
# 1. Specify a cache variable with the default target name
# 2. Specify the location of the main program
# 3. Specify libraries that the main program depends on
# 4. Store the binary exectuable file in the bin folder (pre-install)
#
# The default file name will be "gchp".  If a name is specified at
# configuration time with -DEXE_FILE_NAME, then that will be used instead.
#-----------------------------------------------------------------------------
set(EXE_FILE_NAME gchp CACHE STRING
  "Default name for the GCHP executable file")
mark_as_advanced(EXE_FILE_NAME)

add_executable(${EXE_FILE_NAME}
  GCHPctm.F90
)
target_link_libraries(${EXE_FILE_NAME}
  PUBLIC
  GCHP_GridComp
  ${CMAKE_DL_LIBS}
)
set_target_properties(${EXE_FILE_NAME}
  PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

#-----------------------------------------------------------------------------
# Define the KPP standalone executable:
# 1. Specify a cache variable with the default target name
# 2. Specify the location of the main program
# 3. Specify libraries that the main program depends on
# 4. Store the binary exectuable file in the bin folder (pre-install)
#
# At present build KPP standalone only for fullchem or custom mechanisms.
#-----------------------------------------------------------------------------
if("${MECH}" STREQUAL fullchem OR "${MECH}" STREQUAL custom)
  set(KPPSA_FILE_NAME kpp_standalone CACHE STRING
    "Default name for the KPP standalone executable file")
  mark_as_advanced(KPPSA_FILE_NAME)

  add_executable(${KPPSA_FILE_NAME}
    GCHP_GridComp/GEOSChem_GridComp/geos-chem/KPP/standalone/kpp_standalone.F90
  )
  target_link_libraries(${KPPSA_FILE_NAME}
    PUBLIC
    KPPStandalone
  )
  set_target_properties(${KPPSA_FILE_NAME}
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
  )
endif()

#-----------------------------------------------------------------------------
# Allow GCHP to be installed either to the path specified by -DRUNDIR or
# -DINSTALLCOPY.  In most instances, the build directory is a subdirectory
# of the run directory, so -DRUNDIR=.. will install the executable in the run
# directory.  Using -DINSTALLCOPY allows you to specify an arbitrary folder
# where the executable file wll be placed.  This facilitates automatic
# testing (such as integration testing).
#-----------------------------------------------------------------------------

# Define set of installation paths to consider
set(COMBINED_INSTALL_DIRS "")
list(APPEND COMBINED_INSTALL_DIRS ${RUNDIR})
list(APPEND COMBINED_INSTALL_DIRS ${INSTALLCOPY})

# Consider installation to all of the specified paths
foreach(INSTALL_PATH ${COMBINED_INSTALL_DIRS})
    if(INSTALL_PATH IN_LIST RUNDIR)
        set(CHECK_IS_RUNDIR TRUE)
    else()
        set(CHECK_IS_RUNDIR FALSE)
    endif()

    # Convert INSTALL_PATH to absolute
    if(NOT IS_ABSOLUTE "${INSTALL_PATH}")
      get_filename_component(INSTALL_PATH "${INSTALL_PATH}" ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")
    endif()

    # Issue warning and skip if geoschem_config.yml doesn't exist
    # (i.e. if it doens't look like a run directory)
    if(CHECK_IS_RUNDIR AND (NOT EXISTS ${INSTALL_PATH}/geoschem_config.yml))
      # Installation path is not a GEOS-Chem run directory
      # Skip ahead -- a warning will be raised elsewhere.
      continue()
    else()
      # Installation path is a GEOS-Chem run directory,
      # Therefore we will install the executable there.
      install(TARGETS ${EXE_FILE_NAME} RUNTIME DESTINATION ${INSTALL_PATH})
      install(TARGETS ${KPPSA_FILE_NAME} RUNTIME DESTINATION ${INSTALL_PATH})
    endif()

endforeach()
