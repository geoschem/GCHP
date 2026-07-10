# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

GCHP (GEOS-Chem High Performance) is the MPI/ESMF-parallel, cubed-sphere
version of GEOS-Chem. This top-level repository is mostly a **thin wrapper**:
it provides the CMake build glue and a top-level ESMF gridded component
(`GCHP_GridComp`) that couples together several independently-developed
components pulled in as **git submodules** (see `.gitmodules`):

- `src/MAPL` — NASA GMAO's ESMF-based application infrastructure (grid
  comps, ExtData, History, generic component machinery)
- `src/GMAO_Shared`, `src/FMS`, `src/GFE` — supporting GMAO/ESMF utility
  libraries (gFTL, yaFyaml, pFlogger, fArgParse, etc.)
- `src/GCHP_GridComp/FVdycoreCubed_GridComp` — the FV3 cubed-sphere dynamical
  core grid component
- `src/GCHP_GridComp/GEOSChem_GridComp/geos-chem` — the actual GEOS-Chem
  science code (chemistry, transport driver, etc.) — this is the same
  `geoschem/geos-chem` repo used by GEOS-Chem Classic
- `src/GCHP_GridComp/GEOSChem_GridComp/HEMCO` — the HEMCO emissions component
- `src/GCHP_GridComp/GEOSChem_GridComp/Cloud-J` — photolysis (replaces legacy
  FAST-JX unless `-DFASTJX=y` is set)
- `src/GCHP_GridComp/GEOSChem_GridComp/HETP` — heterogeneous chemistry solver
- `ESMA_cmake` — shared CMake macros used across GMAO/GCHP builds
- `docs/source/geos-chem-shared-docs` — shared ReadTheDocs content

Because of this, **most day-to-day science/model logic lives in the
submodules, not in this repo**. When investigating behavior, check whether
the relevant code is actually in `geos-chem`, `HEMCO`, `MAPL`, or
`FVdycoreCubed_GridComp` before assuming it's in the GCHP wrapper itself.
The files directly owned by *this* repo are primarily: the root
`CMakeLists.txt`, `src/CMakeLists.txt`, `src/GCHP_GridComp/*.F90` and its
`CMakeLists.txt`, and `src/GCHP_GridComp/GEOSChem_GridComp/CMakeLists.txt`
(which sets GEOS-Chem's GCHP-specific build options and compiler flags).

Two symlinks at the repo root point into the geos-chem submodule:
`run -> src/GCHP_GridComp/GEOSChem_GridComp/geos-chem/run/GCHP` and
`test -> .../geos-chem/test`.

## Cloning

Always clone with submodules, or initialize them after the fact:

```
git clone --recurse-submodules https://github.com/geoschem/GCHP.git
# or, if already cloned:
git submodule update --init --recursive
```

## Build commands

GCHP uses a standard three-step CMake/Make workflow. It requires an
environment with a Fortran/C/C++ compiler, MPI, NetCDF-C/Fortran, and ESMF
already available (e.g. via environment modules or Spack).

```
mkdir build && cd build
cmake ..                              # or: cmake /path/to/GCHP
cmake . -DRUNDIR="/path/to/rundir"    # optional: configure install target(s)
make -j                               # incremental — no need to clean first
make install                          # copies bin/gchp (+ supplemental files) to RUNDIR
```

Re-running `cmake .` (with `.` as the existing build dir) picks up new
`-D` settings without needing a fresh build directory. Deleting the build
directory is the way to fully reset configuration.

Key build options (passed as `cmake . -D<NAME>=<VALUE>`):

- `RUNDIR` — semicolon-separated run directory path(s) that `make install`
  installs the executable into
- `CMAKE_BUILD_TYPE` — `Release` (default), `Debug`, or `RelWithDebInfo`
- `CMAKE_PREFIX_PATH` — extra search paths for dependencies (e.g. ESMF)
- `MECH` — chemistry mechanism: `fullchem` (default), `carbon`, or `custom`
- `RRTMG`, `TOMAS`, `LUO_WETDEP`, `FASTJX`, `KPPSA`, `JACOBIAN`,
  `MPI_LOAD_BALANCE`, `OMP` — component/feature switches, all boolean
  CMake cache variables defined in
  `src/GCHP_GridComp/GEOSChem_GridComp/CMakeLists.txt`
- `SANITIZE` — GNU-only; turns on `-fsanitize=leak,address,undefined`

GNU compilers recompile noticeably faster than Intel due to how `.mod`
files are regenerated — prefer GNU for iterative development.

## Running

A run directory is created independently of building, via
`run/createRunDir.sh` (interactive prompts for simulation type, met source,
resolution, etc.). Within a run directory:

- `setCommonRunSettings.sh` — edit then run this script to apply resolution,
  duration, core count, etc. to the actual config files (`GCHP.rc`, `CAP.rc`,
  `HISTORY.rc`, ...)
- `setRestartLink.sh` — (re)points the `gchp_restart.nc4` symlink at the
  restart file matching `cap_restart` date + configured resolution
- `setEnvironment.sh /path/to/env/file` — sets the `gchp.env` symlink; do
  `source gchp.env` before building/running so the same library environment
  is used consistently
- `runScriptSamples/` — example batch (SLURM/LSF) and interactive run
  scripts; GCHP requires a minimum of 6 MPI processes

GCHP writes the run's end date back into `cap_restart` on successful
completion, so a subsequent run can pick up where the last one left off.

## Submodule development workflow

To modify a submodule's code, fork it on GitHub, then repoint its URL in
`.gitmodules` (e.g. via `git config -f .gitmodules -e`), run
`git submodule sync`, and commit the `.gitmodules` change. Only repoint
submodules you actually need to change — leave the rest tracking
`geoschem/*`.

Commit messages in this repo that bump a submodule pointer follow the
convention `<Component> update: Merge PR #<N> (<short description>)`, e.g.
`GEOS-Chem update: Merge PR #3317 (...)`, `HEMCO update: Merge PR #362 (...)`,
`MAPL update: Merge PR #45 (...)`. Follow this convention for submodule bump
commits.

## Versions and changes

Update `CHANGELOG.md` for any user-facing change (this is a required step
per `CONTRIBUTING.md`). Note there are separate changelogs per repo — this
one covers the GCHP wrapper only; GEOS-Chem and HEMCO have their own in
their respective submodules.

## Testing

There is no unit test framework in this wrapper repo itself. Correctness is
validated via full model simulations:

- Structural/build changes should be diff-tested against the prior version
  (bit-for-bit or scientifically-equivalent output) before submitting a PR.
- `.github/workflows/cloud-benchmarking-workflow.yml` triggers a cloud-based
  benchmark simulation (via a separate `gc-cloud-infrastructure` step
  function) on pushes to `dev/*` branches and on tags.
- `.github/workflows/lint-ci-workflows.yml` lints the GitHub Actions
  workflow files themselves with `zizmor`.

## MAPL3 migration (in progress)

The codebase currently supports both the legacy MAPL/MAPL2 gridded-component
API and an in-progress MAPL3 API, gated behind `#ifdef MAPL3` /
`#else` blocks (see `src/GCHP_GridComp/GCHP_GridCompMod.F90`). The MAPL3
path uses `MAPL_GridCompAddSpec`/`MAPL_GridCompAddConnectivity` style
declarative import/export/connectivity specs instead of the legacy
`MAPL_Generic`-based calls. When editing `GCHP_GridCompMod.F90` or similar
top-level coupling code, check whether a change needs to be made in both
branches of the `#ifdef MAPL3`.
