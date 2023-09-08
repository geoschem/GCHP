##########################
GEOS-Chem High Performance
##########################
.. raw:: html

   <p>
   <a href="https://github.com/geoschem/GCHP/releases"><img src="https://img.shields.io/github/v/release/geoschem/GCHP?include_prereleases&label=Latest%20Pre-Release"></a>
   <a href="http://wiki.seas.harvard.edu/geos-chem/index.php/GEOS-Chem_versions"><img src="https://img.shields.io/github/v/release/geoschem/GCHP?label=Latest%20Stable%20Release"></a>
   <a href="https://github.com/geoschem/GCHP/releases/"><img src="https://img.shields.io/github/release-date/geoschem/GCHP"></a><br/>
   <a href="https://zenodo.org/badge/latestdoi/200900441"><img src="https://zenodo.org/badge/200900441.svg"></a>
   <a href="https://github.com/geoschem/GCHP/blob/main/LICENSE.txt"><img src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
   <a href="https://gchp.readthedocs.io/en/latest/"><img src="https://img.shields.io/readthedocs/gchp?label=ReadTheDocs"></a>
   <a href="https://dev.azure.com/geoschem/GCHP/_build"><img src="https://img.shields.io/azure-devops/build/geoschem/GCHP/20/main?label=Build%20Matrix"></a>
   </p>

The `GEOS--Chem model <http://geos-chem.org/>`_ is a global 3-D model
of atmospheric composition driven by assimilated meteorological
observations from the Goddard Earth Observing System (GEOS) of the
`NASA Global Modeling and Assimilation Office
<http://gmao.gsfc.nasa.gov/>`_. It is applied by `research groups
around the world
<http://acmg.seas.harvard.edu/geos/geos_people.html>`_ to a wide range
of atmospheric composition problems.

* `GEOS-Chem Overview <http://geos-chem.org/geos-overview>`_
* `Narrative description of GEOS-Chem <http://geos-chem.org/geos-chem-narrative>`_

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
dedicated `Spack guide <supplement/spack.html>`__ describes how to
install GCHP and create a run directory with Spack, as well as how to
use Spack to install GCHP's dependencies if needed.

.. toctree::
   :maxdepth: 1
   :caption: Getting Started

   getting-started/quick-start.rst
   getting-started/requirements.rst
   getting-started/key-references.rst

.. toctree::
   :maxdepth: 2
   :caption: User Guide

   user-guide/downloading.rst
   user-guide/compiling.rst
   user-guide/rundir-init.rst
   user-guide/getting-input-data.rst
   user-guide/running.rst
   user-guide/configuration-files.rst
   user-guide/rundir-config.rst
   user-guide/output_files.rst
   user-guide/plotting-output.rst
   user-guide/debugging.rst

.. toctree::
   :maxdepth: 1
   :caption: Supplemental Guides

   geos-chem-shared-docs/supplemental-guides/load-libraries-guide.rst
   geos-chem-shared-docs/supplemental-guides/spack-guide.rst
   supplement/setting-up-aws-parallelcluster.rst
   supplement/caching-input-data.rst
   supplement/containers.rst
   supplement/stretched-grid.rst
   supplement/satellite-overpass.rst
   geos-chem-shared-docs/supplemental-guides/bashdatacatalog.rst
   geos-chem-shared-docs/supplemental-guides/customize-guide.rst
   geos-chem-shared-docs/supplemental-guides/error-guide.rst
   geos-chem-shared-docs/supplemental-guides/debug-guide.rst
   geos-chem-shared-docs/supplemental-guides/species-guide.rst
   geos-chem-shared-docs/supplemental-guides/using-kpp-with-gc.rst
   geos-chem-shared-docs/supplemental-guides/related-docs.rst

.. toctree::
   :maxdepth: 1
   :caption: Help & Reference

   reference/SUPPORT.md
   reference/CONTRIBUTING.md
   geos-chem-shared-docs/editing_these_docs.rst
   reference/git-submodules.rst
   reference/glossary.rst
   reference/versioning.rst
   reference/uploading_to_spack.rst
