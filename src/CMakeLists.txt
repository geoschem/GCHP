# Pretend LaTeX isn't found so that dependencies like ImageMagick aren't necessary
set(LATEX_FOUND FALSE)

add_subdirectory(MAPL EXCLUDE_FROM_ALL)

set(NO_F2PY TRUE)
add_subdirectory(GMAO_Shared EXCLUDE_FROM_ALL)

add_subdirectory(GIGC_GridComp EXCLUDE_FROM_ALL)

add_executable(geos
    GEOSChem.F90
)
target_link_libraries(geos
	PUBLIC GIGC_GridComp ${CMAKE_DL_LIBS}
)
