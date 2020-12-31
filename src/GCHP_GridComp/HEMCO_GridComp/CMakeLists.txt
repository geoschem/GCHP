# HEMCO_GridComp/CMakeLists.txt

add_subdirectory(HEMCO EXCLUDE_FROM_ALL)

target_compile_definitions(HEMCOBuildProperties INTERFACE 
    $<$<BOOL:${ADJOINT}>:ADJOINT>
    $<$<BOOL:${REVERSE_OPERATORS}>:REVERSE_OPERATORS> 
    ""
)
