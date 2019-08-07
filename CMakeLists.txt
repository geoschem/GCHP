cmake_minimum_required (VERSION 3.13)

project (gchp_ctm
  VERSION 13.0.0
  LANGUAGES Fortran CXX C
)

# Add ESMA_cmake and ecbuild's module directories to the module path
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/ESMA_cmake ${CMAKE_CURRENT_SOURCE_DIR}/ecbuild/cmake)

# Import ESMA's cmake macros
include(esma-community)

# Declare ecbuild project
ecbuild_declare_project()

# Find MPI
find_package(MPI REQUIRED COMPONENTS C CXX Fortran)

# Add MPI compiler flags
set(CMAKE_Fortran_FLAGS ${CMAKE_Fortran_FLAGS} ${MPI_Fortran_COMPILE_OPTIONS})
set(CMAKE_C_FLAGS ${CMAKE_C_FLAGS} ${MPI_C_COMPILE_OPTIONS})
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${MPI_CXX_COMPILE_OPTIONS})
add_definitions(${MPI_Fortran_COMPILE_DEFINITIONS} ${MPI_C_COMPILE_DEFINITIONS} ${MPI_CXX_COMPILE_DEFINITIONS})
include_directories(${MPI_Fortran_INCLUDE_DIRS} ${MPI_C_INCLUDE_DIRS} ${MPI_CXX_INCLUDE_DIRS})

if("${CMAKE_Fortran_COMPILER_ID}" STREQUAL "GNU")
  list(APPEND CMAKE_Fortran_FLAGS "-ffree-line-length-none")
endif()

# Add the directory with gchp_ctm's source code
add_subdirectory(src)