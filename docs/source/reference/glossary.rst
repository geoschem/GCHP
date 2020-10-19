
.. _gchp_glossary:

Terminology
===========

.. glossary::
   :sorted:

   compile
      Generating an executable program from source code (which is in a plain-text format).

   build
      See :term:`compile`.

   build directory
      A directory where build configuration settings are stored, and where intermediate build files like object files,
      module files, and libraries are stored.

   run directory
      A directory that stores a GEOS-Chem simulation. This directory contains configuration files, the simulations
      ouptut, and sometimes input files like :term:`restart files <restart file>`.

   restart file
      A NetCDF file with initial conditions for a simulation.
   
   target face
      The face of a stretched-grid that is refined. The target face is centered on the target point.

   stretched-grid
      A cubed-sphere grid that is "stretched" to enhance the grid resolution in a region.

   gridded-component
      A formal model component. MAPL organizes model components with a `tree structure <https://en.wikipedia.org/wiki/Tree_structure>`_,
      and facilitates component interconnections.

   HISTORY
      The MAPL :term:`gridded-component` that handles model output. All GCHP output diagnostics are facilitated by HISTORY.