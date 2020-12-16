GEOS-Chem High Performance
==========================

.. important:: This is a prerelease of the GEOS-Chem High Performance user guide.
   These pages are the most up-to-date and accurate instructions for GCHP, but they
   are still a work in progress. 
   
   Contributions (e.g., suggestions, edits, revisions) would be greatly appreciated. See
   :ref:`editing this guide <editing_this_user_guide>` and our :doc:`contributing guidelines <reference/CONTRIBUTING>`. 
   If you find a something hard to understand---let us know!

The `GEOS--Chem model <http://acmg.seas.harvard.edu/geos/>`_ is a global 3-D model of atmospheric
composition driven by assimilated meteorological observations from the Goddard Earth Observing
System (GEOS) of the `NASA Global Modeling and Assimilation Office <http://gmao.gsfc.nasa.gov/>`_.
It is applied by `research groups around the world
<http://acmg.seas.harvard.edu/geos/geos_people.html>`_ to a wide range of atmospheric composition
problems.

* `GEOS-Chem Overview <http://acmg.seas.harvard.edu/geos/geos_overview.html>`_
* `Narrative description of GEOS-Chem <http://acmg.seas.harvard.edu/geos/geos_chem_narrative.html>`_

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
   user-guide/running.rst


.. toctree::
   :maxdepth: 1
   :caption: Supplement

   supplement/rundir-config.rst
   supplement/config-files.rst
   supplement/spack.rst
   supplement/containers.rst
   supplement/plotting-output.rst
   stretched-grid.rst
   supplement/satellite-overpass.rst

.. toctree::
   :maxdepth: 1
   :caption: Tutorials

   tutorials/stretched-grid.rst

.. toctree::
   :maxdepth: 1
   :caption: Help & Reference

   reference/SUPPORT.md
   reference/CONTRIBUTING.md
   geos-chem-shared-docs/editing_these_docs.rst
   reference/git-submodules.rst
   reference/glossary.rst
   reference/versioning.rst