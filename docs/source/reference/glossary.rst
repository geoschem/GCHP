
.. _gchp_glossary:

Terminology
===========

.. glossary::
   :sorted:

   absolute path
      The full path to a file, e.g., :file:`/example/foo/bar.txt`. An absolute path
      should always start with :literal:`/`. As opposed to a :term:`relative path`.

   relative path
      The path to a file relative to the current working directory. For example, the relative path to
      :file:`/example/foo/bar.txt` if your current working directory is :file:`/example` is :file:`foo/bar.txt`.
      As opposed to an :term:`absolute path`.

   compile
      Generating an executable program from source code (which is in a plain-text format).
   
   dependencies
      The software libraries that are needed to compile GCHP. These include HDF5, NetCDF, and ESMF. 
      See :ref:`software_requirements` for a complete list.

   environment
      The software packages and software configuration that are active in your current :term:`terminal` or :term:`script`.
      In Linux, the :file:`${HOME}/.bashrc` script performs automatic configuration when your terminal starts. You can
      manually configure your environment by running commands like :command:`source path_to_a_script` or with tools
      like TCL or LMod for modulefiles. Software containers are effectively a prepackaged operating system + software + environment.
   
   software environment
      See :term:`environment`.

   terminal
      A command-line.

   script
      A file that scripts a sequence of commands. Typically a bash that is written to execute a sequence of commands.

   checkpoint file
      See :term:`restart file`.

   build
      See :term:`compile`.

   build directory
      A directory where build configuration settings are stored, and where intermediate build files like object files,
      module files, and libraries are stored.

   run directory
      The working directory for a GEOS-Chem simulation. A run directory houses the simulation's configuration 
      files, the output directory (:file:`OutputDir`), and input files/links such as :term:`restart files <restart file>`
      or input data directories.

   restart file
      A NetCDF file with initial conditions for a simulation. Also called a :term:`checkpoint file` in GCHP.
   
   target face
      The face of a stretched-grid that is refined. The target face is centered on the target point.

   stretched-grid
      A cubed-sphere grid that is "stretched" to enhance the grid resolution in a region.

   gridded component
      A formal model component. MAPL organizes model components with a `tree structure <https://en.wikipedia.org/wiki/Tree_structure>`_,
      and facilitates component interconnections.

   HISTORY
      The MAPL :term:`gridded component` that handles model output. All GCHP output diagnostics are facilitated by HISTORY.
   
   