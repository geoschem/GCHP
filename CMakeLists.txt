cmake_minimum_required (VERSION 3.13)
project (gchp_ctm
  VERSION 14.2.3
  LANGUAGES Fortran CXX C
)

cmake_policy(SET CMP0079 NEW)

set(OMP OFF CACHE BOOL "Switch to enable/disable OpenMP")

# Add ESMA_cmake and ecbuild's module directories to the module path
list(APPEND CMAKE_MODULE_PATH 
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake
  ${CMAKE_CURRENT_SOURCE_DIR}/ESMA_cmake 
  ${CMAKE_CURRENT_SOURCE_DIR}/ESMA_cmake/ecbuild/cmake
)

# Run directory
set(RUNDIR "" CACHE PATH "Path(s) to run directory (semicolon separated list). Specifies install locations for gchp")
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Fake CMAKE_INSTALL_PREFIX (use RUNDIR instead)" FORCE)
set(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT FALSE)

# Find nc-config and nf-config
find_program(NC_CONFIG NAMES "nc-config" DOC "Location of nc-config utility")
find_program(NF_CONFIG NAMES "nf-config" DOC "Location of nf-config utility")

# A function to call nx-config with an argument, and append the resulting path to a list
function(inspect_netcdf_config VAR NX_CONFIG ARG)
    execute_process(
        COMMAND ${NX_CONFIG} ${ARG}
        OUTPUT_VARIABLE NX_CONFIG_OUTPUT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(EXISTS "${NX_CONFIG_OUTPUT}")
        list(APPEND ${VAR} ${NX_CONFIG_OUTPUT})
        set(${VAR} ${${VAR}} PARENT_SCOPE)
    endif()
endfunction()

# Add nc-config and nf-config paths to CMAKE_PREFIX_PATH
inspect_netcdf_config(CMAKE_PREFIX_PATH "${NC_CONFIG}" "--prefix")
inspect_netcdf_config(CMAKE_PREFIX_PATH "${NF_CONFIG}" "--prefix")

# Add gchp_ctm's expected environment variables to CMAKE_PREFIX_PATH
list(APPEND CMAKE_PREFIX_PATH 
  $ENV{ESMF_ROOT} $ENV{ESMF_ROOT}/DEFAULTINSTALLDIR
)

set(ECBUILD_LOG_LEVEL ERROR)

find_package(NetCDF REQUIRED)
find_package(ESMF REQUIRED)

# Include ESMA macros
include(esma)

# Declare ecbuild project
ecbuild_declare_project()

# Find MPI
find_package(MPI REQUIRED COMPONENTS C CXX Fortran)

if("${CMAKE_Fortran_COMPILER_ID}" STREQUAL "GNU")
  list(APPEND CMAKE_Fortran_FLAGS "-ffree-line-length-none")
endif()

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)

# Add the directory with gchp_ctm's source code
add_subdirectory(src)

# Fix the "all" target so it only contains GCHP: add EXCLUDE_FROM_ALL=TRUE to every
# GMAO target. 
set_target_properties(
  MAPL_cfio_r8                    GMAO_pilgrim
  NSIDC-OSTIA_SST-ICE_blend       GEOS_PertShared
  GEOS_PertSvecs                  Tapenade        GMAO_psas
  GMAO_transf                     GMAO_stoch      arpack
  lanso                           planso          post
  post_nompi                      nc_diag_write   nc_diag_res
  nc_diag_read                    nc_diag_cat     parpack
  putil                           util            GMAO_gfio_r4
  MAPL.generic MAPL.oomph MAPL MAPL.gridcomps MAPL.cap MAPL.history
  MAPL.orbit MAPL.ExtData MAPL.griddedio GEOS_Shared
  GMAO_hermes CICE4 GMAO_pyobs GMAO_gfio_r8 FVdycoreCubed_GridComp
  fvdycore
  MAPL_cfio_r4 MAPL.pfio MAPL.profiler MAPL.shared MAPL.constants
  MAPL.base GMAO_mpeu GMAO_eu mpi0 fms_r8

  PROPERTIES EXCLUDE_FROM_ALL TRUE
)


#target_compile_definitions(Baselibs INTERFACE 
#    $<$<BOOL:${ADJOINT}>:ADJOINT>
#    $<$<BOOL:${REVERSE_OPERATORS}>:REVERSE_OPERATORS> 
#    ""
#)
