.. _debugging:

#########
Debugging
#########

This page provides strategies for investigating errors encountered
while using GCHP.

================
Configure errors
================

Coming soon

=================
Build-time errors
=================

Coming soon

===============
Run-time errors
===============

Recompile with debug flags
--------------------------

Recompile using debug flags by setting
:literal:`-DCMAKE_BUILD_TYPE=Debug` during the configure step. See the
section of the user guide on compiling GCHP for more guidance on how
to do this. Once you rebuild there may be more information in the logs
when you run again.


Enable maximum print output
---------------------------

Besides compiling with :literal:`CMAKE_BUILD_TYPE=Debug`, there are a few run-time settings you can configure to boost your chance of successful debugging.
All of them involve sending additional print statements to the log files.

#. Activate GEOS-Chem verbose output by editing
   :file:`geoschem_config.yml` as shown below.  This will tell
   GEOS-Chem to send extra printout to the :file:`gchp.YYYYMMDD_hhmmz.log`
   file.

   .. code-block:: yaml

      #============================================================================
      # Simulation settings
      #============================================================================
      simulation:
        # ... etc not shown ...
        verbose:
          activate: false   <=== Change this to true
          on_cores: root       # Allowed values: root all

#. Activate GEOS-Chem verbose output by editing
   :file:`HEMCO_Config.rc` as shown below.  This will tell
   HEMCO to send extra printout to the :file:`gchp.YYYYMMDD_hhmmz.log`
   file.

   .. code-block:: kconfig

      ###############################################################################
      ### BEGIN SECTION SETTINGS
      ###############################################################################

      # ... etc not shown ...
      Verbose:                     false   <=== Change this to true

#. Activate the :literal:`CAP.EXTDATA` and literal:`MAPL` debug loggers by
   editing the :file:`logging.yml` configuration file as shown below.
   This will tell GCHP to send debug priontout from MAPL and
   ExtData to the :file:`allPEs.log` file.

   .. code-block:: yaml

      loggers:

         # ... etc not shown ...

         MAPL:
             handlers: [mpi_shared]
             level: WARNING     <=== Change this to DEBUG
             root_level: INFO   <=== Change this to DEBUG

         CAP.EXTDATA:
             handlers: [mpi_shared]
             level: WARNING     <=== Change this to DEBUG
             root_level: INFO   <=== Change this to DEBUG

None of these options require recompiling. Be aware that all of them
will slow down your simulation.  Be sure to set them back to the
default values after you are finished debugging.


Inspecting memory
-----------------

Memory statistics are printed to the GCHP log each model timestep by
default. This includes percentage of memory committed, percentage of
memory used, total used memory (MB), and total swap memory (MB). This
information is always printed and is not configurable from the run
directory. However, additional memory prints may be enabled by
changing the value set for variable :literal:`MEMORY_DEBUG_LEVEL` in
run directory file :literal:`GCHP.rc`. Setting this to a value greater
than zero will print out total used memory and swap memory before and
after run methods for gridded components GCHPctmEnv, FV3 advection,
and GEOS-Chem. Within GEOS-Chem, total and swap memory will also be
printed before and after subroutines to run GEOS-Chem, perform
chemistry, and apply emissions. For more information about inspecting
memory see the output files section of this user guide.
