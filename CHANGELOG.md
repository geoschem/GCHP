# Changelog

This file documents all notable changes to the GCHP wrapper repository starting in version 14.0.0. See also CHANGELOG files for individual submodules, such as:
- src/GCHP_GridComp/GEOSChem_GridComp/geos-chem/CHANGELOG.md
- src/GCHP_GridComp/HEMCO_GridComp/HEMCO/CHANGELOG.md
- src/MAPL/CHANGELOG.md

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [14.2.3] - 2023-12-01
### Added
- Script `.release/changeVersionNumbers.sh` to change version numbers before a new GCHP release

## [14.2.2] - 2023-10-23
### Changed
- Updated GEOS-Chem submodule to 14.2.2

## [14.2.1] - 2023-10-10
### Changed
- `test` now points to `src/GCHP_GridComp/GEOSChem_GridComp/geos-chem/test`
- Hard-coded ESMF logging option removed from GCHPctm.F90
- Updated version numbers and documentation

## [14.2.0] - 2023-10-05
### Added
- Added run-time option to use dry air pressure in advection
- Added run-time option to correct mass flux for humidity
- Added `.readthedocs.yaml` to configure ReadTheDocs builds

### Changed
- Updated GEOS-Chem submodule to 14.2.0
- Updated HEMCO submodule to 3.7.0
- Updated version numbers in `CMakeLists.txt` and `docs/source/conf.py` to 14.2.0
- Changed default air pressure in advection from total to dry
- Updated `AUTHORS.txt` for GCHP 14.2.0
- Updated `README.md` so that links point to http://geos-chem.org
- Updated logo & badge links in `README.md`
- Updated version number to 14.2.0

### Fixed
- Fixed post-advection pressure edges (PLE1) passed to advection to be derived from the correct surface pressure
- Fixed typo in `docs/source/conf.py`, "_static" should be "_static/"

## [14.1.1] - 2023-03-03
### Added
- Added `EXE_FILE_NAME` and `INSTALLCOPY` to src/CMakeLists.txt (facilitates integration testing)

### Changed
- Changed "carboncycle" to "carbon" in `src/GCHP_GridComp/GEOSChem_GridComp/CMakeLists.txt`
- Simplified Github issue and pull request templates
- Updated ReadTheDocs to specify 8.1 is minimum version of ESMF
- Updated version numbers in `CMakeLists.txt` and `docs/source/conf.py` to 14.1.1

### Fixed
- Fixed global attributes written to stretched grid checkpoint files to enable restart
- Fixed day-of-week scale factor handling in MAPL ExtData
- Fixed stretched grid checkpoint file issue in MAPL that prevented restarting stretched grid simulations

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
- Units for State_Diag%RxnRate diagnostic are now `molec cm-3 s-1` instead of `s-1`


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
