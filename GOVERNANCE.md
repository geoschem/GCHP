# Governance

GEOS-Chem, including GCHP (the high-performance, MPI/ESMF-parallel version of the model), is a grass-roots, open-access model owned by its [users](https://geoschem.github.io/community.html). This document summarizes how development priorities are set and how code moves from a contributor's changes into an official release. For the practical, step-by-step process of submitting a change, see `CONTRIBUTING.md`.

## Roles

### GEOS-Chem Steering Committee (GCSC)

The [GEOS-Chem Steering Committee](https://geoschem.github.io/steering-committee.html) provides scientific direction for the model. It meets quarterly to set [GEOS-Chem model development priorities](http://wiki.geos-chem.org/GEOS-Chem_model_development_priorities) and to slate submitted updates for inclusion into upcoming GEOS-Chem versions.

### Working Groups

[GEOS-Chem Working Groups](https://geoschem.github.io/working-groups.html) identify priority development needs within their science areas and advise the GCSC accordingly. Working Group chairs are the first point of contact for contributors who want to propose a model update, and can advise on timing for submitting code tied to a mature development.

### GEOS-Chem Support Team (GCST)

The [GEOS-Chem Support Team](https://geoschem.github.io/support-team.html), based at Harvard University and Washington University in St. Louis, manages the codebase day to day: it maintains this repository and its submodules (MAPL, GMAO_Shared, FVdycoreCubed_GridComp, geos-chem, HEMCO, Cloud-J, HETP), reviews and merges pull requests into the development branch for an upcoming version, and validates incoming updates with [benchmark simulations](http://wiki.geos-chem.org/GEOS-Chem_benchmarking) before release. If a benchmark reveals a problem with a submitted update, the GCST works with the contributor on corrective action.

## How a change becomes an official release

1. A contributor proposes an update to their relevant Working Group chair(s).

2. The Working Group forwards the request to the GCSC, which sets its priority and target version at a quarterly meeting.

3. The contributor submits the update as a pull request — to this repository if it touches the GCHP wrapper/coupling code, or to the relevant submodule's own repository otherwise (see `CONTRIBUTING.md` for the checklist covering coding conventions, `CHANGELOG.md` entries, and — for structural changes — difference testing).

4. The GCST reviews, merges, and benchmarks the update, then includes it in the next tagged release.

## Sponsors

GEOS-Chem development is supported by the US NASA Earth Science Division, the Canadian National Sciences and Engineering Research Council, and the Nanjing University of Information Science and Technology.
