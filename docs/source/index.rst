##########################
GEOS-Chem High Performance
##########################
.. raw:: html

   <p>
     <a href="https://github.com/geoschem/GCHP/releases/"><img src="https://img.shields.io/github/v/release/geoschem/GCHP?label=Latest%20Stable%20Release" alt="Latest release"></a>
     <a href="https://github.com/geoschem/GCHP/"><img src="https://img.shields.io/github/release-date/geoschem/GCHP" alt="Release date"></a><br/>
     <a href="https://doi.org/10.5281/zenodo.4428926"><img src="https://img.shields.io/badge/DOI-10.5281%2Fzenodo.4428926-blue" alt="DOI"></a>
     <a href="https://github.com/geoschem/GCHP/blob/main/LICENSE.txt"><img src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
     <a href="https://gchp.readthedocs.io"><img src="https://img.shields.io/readthedocs/gchp?label=ReadTheDocs"></a>
   </p>


The `GEOS-Chem model <http://geos-chem.org/>`__ is a global 3-D model
of atmospheric composition driven by assimilated meteorological
observations from the Goddard Earth Observing System (GEOS) of the
`NASA Global Modeling and Assimilation Office
<http://gmao.gsfc.nasa.gov/>`__. It is applied by `research groups
around the world
<http://acmg.seas.harvard.edu/geos/geos_people.html>`__ to a wide range
of atmospheric composition problems.

* `GEOS-Chem Overview <http://geos-chem.org/geos-overview>`__
* `Narrative description of GEOS-Chem <http://geos-chem.org/geos-chem-narrative>`__

This site provides instructions for GEOS-Chem High Performance,
GEOS-Chem's multi-node variant. We provide two different instruction
sets for downloading and compiling GCHP: from a clone of the source
code, or using the Spack package manager.


Cloning and building from source code ensures you will have direct
access to the latest available versions of GCHP, provides additional
compile-time options, and allows you to make your own modifications to
GCHP's source code. Spack automates downloading and additional parts
of the compiling process while providing you with some standard
togglable compile-time options.


Our `Quick Start Guide <getting-started/quick-start.html>`__ and the
`downloading <user-guide/downloading.html>`__, `compiling
<user-guide/compiling.html>`__, and `creating a run directory
<user-guide/rundir-init.html>`__ sections of the User Guide give
instructions specifically for using a clone of the source code. Our
dedicated `Spack guide <geos-chem-shared-docs/supplemental-guides/spack-guide.html>`__ describes how to
install GCHP and create a run directory with Spack, as well as how to
use Spack to install GCHP's dependencies if needed.

.. note::

   **Develop and test locally.** GCHP can be built and run at
   coarse resolution (e.g. 4° x 5°) on a personal laptop using the prebuilt
   dependency image ``billzhuge/geos-chem-deps`` on Docker Hub — no manual
   library setup required.

.. toctree::
   :maxdepth: 1
   :caption: Getting Started

   getting-started/quick-start
   getting-started/requirements
   getting-started/key-references

.. toctree::
   :maxdepth: 2
   :caption: User Guide

   user-guide/downloading
   user-guide/compiling
   user-guide/rundir-init
   user-guide/getting-input-data
   user-guide/running
   user-guide/configuration-files
   user-guide/rundir-config
   user-guide/output_files
   user-guide/plotting-output
   user-guide/debugging

.. toctree::
   :caption: GEOS-Chem Simulations
   :maxdepth: 1

   supplement/gchp-simulations
   geos-chem-shared-docs/simulations/carbon
   geos-chem-shared-docs/simulations/fullchem
   geos-chem-shared-docs/simulations/tago3
   geos-chem-shared-docs/simulations/transport-tracers

.. toctree::
   :maxdepth: 1
   :caption: Supplemental Science Guides

   geos-chem-shared-docs/supplemental-guides/science-guides
   geos-chem-shared-docs/supplemental-guides/apm-guide
   geos-chem-shared-docs/supplemental-guides/ate-guide
   geos-chem-shared-docs/supplemental-guides/aerosols-guide
   geos-chem-shared-docs/supplemental-guides/cloud-conv-guide
   geos-chem-shared-docs/supplemental-guides/drydep-guide
   geos-chem-shared-docs/supplemental-guides/pm25-pm10-guide
   geos-chem-shared-docs/supplemental-guides/pbl-mixing-guide
   geos-chem-shared-docs/supplemental-guides/photolysis-guide
   geos-chem-shared-docs/supplemental-guides/phys-consts-guide
   geos-chem-shared-docs/supplemental-guides/rrtmg-guide
   geos-chem-shared-docs/supplemental-guides/tomas-guide
   geos-chem-shared-docs/supplemental-guides/wetdep-guide

.. toctree::
   :caption: Supplemental Technical Guides
   :maxdepth: 1

   supplement/technical-guides
   supplement/horizontal-grids
   supplement/vertical-grids
   supplement/run-gchp-on-cloud
   geos-chem-shared-docs/supplemental-guides/load-libraries-guide
   geos-chem-shared-docs/supplemental-guides/spack-guide
   supplement/caching-input-data
   supplement/containers
   supplement/stretched-grid
   supplement/satellite-overpass
   geos-chem-shared-docs/doc/gcid-portal-overview
   geos-chem-shared-docs/supplemental-guides/bashdatacatalog
   geos-chem-shared-docs/supplemental-guides/history-diag-guide
   geos-chem-shared-docs/supplemental-guides/netcdf-guide
   geos-chem-shared-docs/supplemental-guides/coards-guide
   geos-chem-shared-docs/supplemental-guides/customize-guide
   geos-chem-shared-docs/supplemental-guides/custom-emissions-guide
   geos-chem-shared-docs/supplemental-guides/error-guide
   geos-chem-shared-docs/supplemental-guides/debug-guide
   geos-chem-shared-docs/supplemental-guides/species-guide
   geos-chem-shared-docs/supplemental-guides/using-kpp-with-gc
   geos-chem-shared-docs/supplemental-guides/using-kpp-standalone
   geos-chem-shared-docs/supplemental-guides/related-docs

.. toctree::
   :maxdepth: 1
   :caption: Help & Reference

   reference/versioning
   reference/known-bugs
   reference/CONTRIBUTING.md
   reference/SUPPORT.md
   geos-chem-shared-docs/editing_these_docs
   reference/git-submodules
   reference/glossary
   reference/uploading_to_spack
