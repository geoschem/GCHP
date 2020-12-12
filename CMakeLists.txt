cmake_minimum_required (VERSION 3.13)
project (gchp_ctm
  VERSION 13.0.0
  LANGUAGES Fortran CXX C
)

# Disable OMP by default if using gfortran to avoid a performance hit.
# Enable OMP if using ifort to avoid a run-time seg fault. Both of these issues
# are bugs under investigation.
if("${CMAKE_Fortran_COMPILER_ID}" STREQUAL "GNU")
  set(OMP OFF CACHE BOOL "Switch to enable/disable OpenMP")
elseif("${CMAKE_Fortran_COMPILER_ID}" STREQUAL "Intel")
  set(OMP ON CACHE BOOL "Switch to enable/disable OpenMP")
else()
    message(FATAL_ERROR "Unknown Fortran compiler: ${CMAKE_Fortran_COMPILER_ID}")
endif()

# Add ESMA_cmake and ecbuild's module directories to the module path
list(APPEND CMAKE_MODULE_PATH 
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

# Set variables so that include(esma) does what we want
set(BASEDIR IGNORE CACHE INTERNAL "Path to base libs")
set(ENABLE_TESTS OFF)
set(PFUNIT OFF)

# Override REQUIRED-ness of certain packages searched for in FindBaselibs.cmake
set(GFTL_IS_REQUIRED_ARG
	"" CACHE INTERNAL
	"Prevent Baselibs from requiring GFTL as an external library")
set(GFTL_SHARED_IS_REQUIRED_ARG
	"" CACHE INTERNAL
	"Prevent Baselibs from requiring GFTL_SHARED as an external library")
set(YAFYAML_IS_REQUIRED_ARG
	"" CACHE INTERNAL
	"Prevent Baselibs from requiring YAFYAML as an external library")
set(PFLOGGER_IS_REQUIRED_ARG
	"" CACHE INTERNAL
	"Prevent Baselibs from requiring PFLOGGER as an external library")
set(MKL_IS_REQUIRED_ARG
	"" CACHE INTERNAL
	"Prevent Baselibs from requiring MKL as an external library")
set(FLAP_IS_REQUIRED_ARG
	"" CACHE INTERNAL
	"Prevent Baselibs from requiring FLAG as an external library")

# Disable find packages that aren't required for gchp_ctm
set(CMAKE_DISABLE_FIND_PACKAGE_MKL          TRUE)
set(CMAKE_DISABLE_FIND_PACKAGE_FLAP         TRUE)
set(CMAKE_DISABLE_FIND_PACKAGE_GFTL         TRUE)
set(CMAKE_DISABLE_FIND_PACKAGE_GFTL_SHARED  TRUE)
set(CMAKE_DISABLE_FIND_PACKAGE_YAFYAML      TRUE)
set(CMAKE_DISABLE_FIND_PACKAGE_PFLOGGER     TRUE)
set(CMAKE_DISABLE_FIND_PACKAGE_FARGPARSE    TRUE)
set(CMAKE_DISABLE_FIND_PACKAGE_LATEX        TRUE)

# Add gchp_ctm's expected environment variables to CMAKE_PREFIX_PATH
list(APPEND CMAKE_PREFIX_PATH 
  $ENV{ESMF_ROOT} $ENV{ESMF_ROOT}/DEFAULTINSTALLDIR
)
# Include ESMA macros
include(esma)

# Declare ecbuild project
ecbuild_declare_project()

# Find MPI
find_package(MPI REQUIRED COMPONENTS C CXX Fortran)

if("${CMAKE_Fortran_COMPILER_ID}" STREQUAL "GNU")
  list(APPEND CMAKE_Fortran_FLAGS "-ffree-line-length-none")
endif()

# Add the directory with gchp_ctm's source code
add_subdirectory(src)

# Exclude the following libraries from the "all" target 
set_target_properties(
  MAPL_cfio_r8                    GMAO_pilgrim
  NSIDC-OSTIA_SST-ICE_blend       LANL_cice       GEOS_PertShared
  GEOS_PertSvecs                  Tapenade        GMAO_psas
  GMAO_transf                     GMAO_stoch      arpack
  lanso                           planso          post
  post_nompi                      nc_diag_write   nc_diag_res
  nc_diag_read                    nc_diag_cat     parpack
  putil                           util            GMAO_gfio_r4
  
  PROPERTIES EXCLUDE_FROM_ALL TRUE
)
