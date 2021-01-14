# HEMCO_GridComp/CMakeLists.txt

# OMP_HEMCO allows overwriting default value of OMP in HEMCO.
# This is so that we can disable OMP in HEMCO, but leave
# OMP enabled elsewhere for the purpose of Intel compilers.
# See: https://github.com/geoschem/GCHP/issues/75
if(DEFINED OMP_HEMCO)
  set(SAVED_OMP_VALUE ${OMP})
  set(OMP ${OMP_HEMCO})
endif()

add_subdirectory(HEMCO EXCLUDE_FROM_ALL)

if(DEFINED OMP_HEMCO)
  set(OMP ${SAVED_OMP_VALUE})
endif()
