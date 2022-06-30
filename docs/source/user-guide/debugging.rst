Debugging
=========

This page provides strategies for investigating errors encountered while using GCHP.

.. contents:: Table of contents
    :depth: 4

---------------------------------------------------------------------------------------------------

Configure errors
-----------------

Coming soon

---------------------------------------------------------------------------------------------------

Build-time errors
-----------------

Coming soon

---------------------------------------------------------------------------------------------------

Run-time errors
---------------

Recompile with debug flags
^^^^^^^^^^^^^^^^^^^^^^^^^^

Recompile using debug flags by setting :literal:`-DCMAKE_BUILD_TYPE=Debug` during the configure step. See the section of the user guide on compiling GCHP for more guidance on how to do this. Once you rebuild there may be more information in the logs when you run again.


Enable maximum print output
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Besides compiling with :literal:`CMAKE_BUILD_TYPE=Debug`, there are a few run-time settings you can configure to boost your chance of successful debugging.
All of them involve sending additional print statements to the log files.

1. Set Turn on debug printout? in :file:`geoschem_config.yml` to T to turn on extra GEOS-Chem print statements in the main log file.
2. Set the Verbose and Warnings settings in :file:`HEMCO_Config.rc` to maximum values of 3 to send the maximum number of prints to :file:`HEMCO.log`.
3. Set :literal:`CAP.EXTDATA` and :literal:`MAPL` options :literal:`root_level` in :file:`logging.yml` to :literal:`DEBUG` to send root thread MAPL prints to :file:`allPEs.log`.
4. Set :literal:`CAP.EXTDATA` and :literal:`MAPL` option :literal:`level` in :file:`logging.yml` to :literal:`DEBUG` to send all thread MAPL ExtData (input) prints to :file:`allPEs.log`.

None of these options require recompiling. Be aware that all of them will slow down your simulation.  Be sure to set them back to the default values after you are finished debugging.

Inspecting memory
^^^^^^^^^^^^^^^^^

Memory statistics are printed to the GCHP log each model timestep by default. This includes percentage of memory committed, percentage of memory used, total used memory (MB), and total swap memory (MB). This information is always printed and is not configurable from the run directory. However, additional memory prints may be enabled by changing the value set for variable :literal:`MEMORY_DEBUG_LEVEL` in run directory file :literal:`GCHP.rc`. Setting this to a value greater than zero will print out total used memory and swap memory before and after run methods for gridded components GCHPctmEnv, FV3 advection, and GEOS-Chem. Within GEOS-Chem, total and swap memory will also be printed before and after subroutines to run GEOS-Chem, perform chemistry, and apply emissions. For more information about inspecting memory see the output files section of this user guide.
