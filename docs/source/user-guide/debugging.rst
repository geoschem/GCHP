.. _debugging:

#########
Debugging
#########

This page provides strategies for investigating errors encountered
while using GCHP.

================
Configure errors
================

The most basic configuration problem occurs if you forget to run :literal:`git submodule update --init --recursive`
after cloning the GCHP repository. Check that you did this correctly. Other configuration problems usually have to do
with libraries. Check that you have libraries loaded and that they meet the requirements for GCHP. Also check
the logs printed to the build directory, in particular :literal:`CMakeCache.txt`. That file lists the directories
of the libraries that are used. Check that these paths are what you intend to use. Sometimes on compute clusters
there can be multiple instances of the same library loaded, such as when using a spack-built library when the
cluster already has a different version of the same library. Check the library paths carefully to look for
inconsistencies.

=================
Build-time errors
=================

Usually build-time errors are self-explanatory, with an error message indicating the file, line number, and reason
for the error. Sometimes you need to do some digging in the build log to find where the error is. Searching for string
" error " (note the space before and after) usually hones in on the problem fast. Read the error message carefully and then
find the file and line
number specified. If it is not clear what the error is even from the error message then you can try doing a string search
on the GCHP GitHub issues page, or on the web in general. If the error is occuring with an out-of-the-box GCHP version
then the issue is likely a library. Check that your libraries meet the requirements of GCHP as specified on
ReadTheDocs. Also check your ESMF version and make sure you build ESMF using the same libraries with which you
are building GCHP.

===============
Run-time errors
===============

The first step in debugging run-time errors is always to look at the logs. First check the :literal:`gchp.*.log`
(* is the start time of the run) to see how far the run got. It is possible the error was trapped by HEMCO or GEOS-Chem
in which case there will likey be error messages explaining the problem. Also check the standard error log. If running on a job
scheduler this would be a separate file from the main GCHP log file. The error should include a traceback of the error,
meaning filenames and line numbers where the error occurred, moving up the call stack from deepest to highest. Go to the
first file listed and find the line number. Also read the error message in the traceback. Try to determine if the error
is in GEOS-Chem, HEMCO, MAPL, or somewhere else. If the error is in MAPL then you should check output file
:literal:`allPEs.log`. This log provides basic information on the MAPL run, which includes general GCHP infrastructure setup
as well as model I/O.

Recompile with debug flags
--------------------------

If you are running into a segmentation fault or the model appears to hang within GEOS-Chem then you should try building
with GEOS-Chem debug flags turned on. Recompile using debug flags by setting :literal:`-DCMAKE_BUILD_TYPE=Debug` during
the configure step. See the section of the user guide on compiling GCHP for more guidance on how to do this. Once you
rebuild and run there will be more information in the logs if the problem is an out-of-bounds error or floating point
exception.

Enable maximum print output for GEOS-Chem and HEMCO
---------------------------------------------------

To more information about the execution within GEOS-Chem and HEMCO you can enable additional prints to the main GCHP log within
:literal:`geoschem_config.yml` and :literal:`HEMCO_Config.rc`.

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

#. Activate HEMCO verbose output by editing
   :file:`HEMCO_Config.rc` as shown below.  This will tell
   HEMCO to send extra printout to the :file:`gchp.YYYYMMDD_hhmmz.log`
   file.

   .. code-block:: kconfig

      ###############################################################################
      ### BEGIN SECTION SETTINGS
      ###############################################################################

      # ... etc not shown ...
      Verbose:                     false   <=== Change this to true

Enable ESMF error log output
----------------------------

If the error is in MAPL then check if the call where the error occurs contains "ESMF". If the error is occuring in a call to
ESMF then you should enable ESMF error log files in GCHP. Look for file :literal:`ESMF.rc` in your run directory. Open it and
set the :literal:`logKindFlag` parameter to :literal:`ESMF_LOGKIND_MULTI_ON_ERROR` and run again. You should then get
ESMF error log files upon rerun. There will be one log file per processor. More often than not the ESMF error message will
appear in every file.

Enable maximum print output for MAPL
------------------------------------

If you see :literal:`ExtData` in the error traceback then the problem has to do with input files. It is common to run into
errors when adding new input files because of strict rules for import files within MAPL.
If there is not enough information in :literal:`allPEs.log` to determine what the input file
problem is then you should enable additional MAPL prints and rerun. This is mostly recommended for input file issues
because MAPL ExtData is
where most of the debug logging statements are currently implemented. However, problems elsewhere in MAPL might have useful
debugging error messages as well. You can also go into the code and add your own by searching for examples with string
:literal:`lgr%debug`. Contact the GEOS-Chem Support Team if you need help deciphering the resulting log output.

#. Activate the :literal:`CAP.EXTDATA` and :literal:`MAPL` debug loggers by
   editing the :file:`logging.yml` configuration file as shown below.
   This will send all MAPL debug-level logging prints to the :file:`allPEs.log` file.

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

Read the code
-------------

If log error messages are not helpful in determining the problem then you may be able to solve it by reading the
code. Follow the traceback to find the file and line number where the code crashed. You can find the location of
files in GCHP by using the unix find command from the top-level source code directory,
e.g. :literal:`find . -name aerosol_mod.F90` Once you find the file and the line where the model fails, read
the code above it to try
to get a sense of the context of where it crashed. This will give clues as to why it had a problem and may give you
ideas of what to do to try to fix it. You can also add your own debug code, recompile, and run.

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

Inspecting timing
-----------------

Model timing information is printed out at the end of each GCHP run. Check the end of the GCHP log for a breakdown
of component timing. 
