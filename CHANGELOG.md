# Changelog

This file documents all notable changes to the GCHP wrapper repository starting in version 14.0.0. See also CHANGELOG files for individual submodules, such as:
- src/GCHP_GridComp/GEOSChem_GridComp/geos-chem/CHANGELOG.md
- src/GCHP_GridComp/HEMCO_GridComp/HEMCO/CHANGELOG.md
- src/MAPL/CHANGELOG.md

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [14.1.0] - 2023-02-01
### Changed
  - Updated GEOS-Chem submodule to 14.1.0
  - Updated HEMCO submodule to 3.6.0
  - Updated MAPL submodule from v2.18.3 -> v2.26.0
  - Updated gFTL-shared submodule from v1.4.1 -> v1.5.0
  - Updated yaFyaml submodule from v1.0-beta.4 -> v1.0.4
  - Updated pFlogger submodule from v1.6.1 -> v1.9.1
  - Updated ReadTheDocs documentation for 14.1.0

### Fixed
  - Fixed logic in .github/workflows/findRefKey.sh for determining previous commit

## [14.0.2] - 2022-11-29
### Changed
  - Updated GEOS-Chem submodule to 14.0.2
  - Updated HEMCO submodule to 3.5.2
  - Updated the documentation for clarity

### Fixed
  - Removed memory leaks in GEOS-Chem and HEMCO submodule code
  - Units for State_Diag%RxnRate diagnostic are now `molec cm-3 s-1`
    instead of `s-1`


## [14.0.1] - 2022-10-31
### Changed
  - Updated GEOS-Chem submodule to 14.0.1


## [14.0.0] - 2022-10-25
### Added
  - Created CHANGELOG.md

### Changed
  - Changed GEOS-Chem submodule to 14.0.0 release
  - Changed HEMCO submodule version: 3.4.0 -> 3.5.0
  - Changed GEOS-ESM submodule versions:
    * MAPL: v2.6.3 -> v2.18.3
    * FVdycoreCubed_GridComp: v1.2.12 -> v1.8.0
    * fvdycore: geos/v1.1.6 -> geos/v1.4.0
    * GMAO_Shared: v1.3.8 -> v1.5.3
    * FMS: geos/2019.01.02+noaff.6 -> geos/2019.01.02+noaff.8
    * ESMA_cmake: v3.0.6 -> v3.8.0
  - Changed Goddard-Fortran-Ecosystem submodule versions:
    * gFTL-shared: v1.2.0 -> v1.4.1
    * gFTL: v1.3.1 -> v1.6.0
    * pFlogger: v1.5.0 -> v1.6.1
    * yaFyaml: v0.5.0 -> v1.0-beta.4
  - Updated build files for compatibility with new submodule versions
  - Updated CONTRIBUTING.md and SUPPORT.md to retire guidelines on GEOS-Chem wiki
  - Updated GCHP ReadTheDocs documentation
  - Updated spack deployment action to use new installation procedure
  - Update AWS benchmarking github actions to act on all dev* branches

### Removed
  - Removed Azure continuous integration test pipeline
  - Removed pFUnit submodule since not used

### Fixed
  - Fixed broken CMAKE_BUILD_TYPE options for intel and gfortran compilers
