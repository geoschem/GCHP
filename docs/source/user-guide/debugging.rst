.. _debugging:

#########
Debugging
#########

This page provides strategies for investigating errors encountered while using GCHP.
See also the GEOS-Chem ReadTheDocs pages on
`debugging<https://geos-chem.readthedocs.io/en/stable/geos-chem-shared-docs/supplemental-guides/debug-guide.html>`_
and
`understanding what error messages mean <https://gchp.readthedocs.io/en/stable/geos-chem-shared-docs/supplemental-guides/error-guide.html>`_ which are also linked to in the Supplementary Guides section
of the GCHP ReadTheDocs. Note that those pages, unlike this one, also describe GEOS-Chem Classic and thus
not all examples are applicable to GCHP.

================
Configure errors
================

Configuration using CMake occurs right before compiling the model.
A common problem that results in configuration errors is if you forget
to run :literal:`git submodule update --init --recursive` after cloning
the GCHP repository. Check that you did this correctly by looking to see if
all subdirectories contain files, e.g. src/MAPL.

Other configuration problems usually have to do with your environment and libraries.
Check that you have libraries loaded and that they meet the requirements for GCHP.
Also check the logs printed to the build directory, in particular :file:`CMakeCache.txt`.
That file lists the directories of the libraries that are used.
Check that these paths are what you intend. Sometimes on compute clusters
there can be multiple instances of the same library loaded, such as when using a spack-built
library when your compute cluster already has a different version of the same library set
by default. Check the library paths carefully to look for inconsistencies.

If you create a GitHub issue for a configuration error please include the :file:`CMakeCache.txt`
file in your help request as well as the output sent to screen.

==============
Compile errors
==============

Usually build-time errors are self-explanatory, with an error message indicating the file, line number, and reason
for the error. However, you may need to do some digging to find the error message.

If the build error is occuring with an unaltered GCHP version then the issue is likely related
to libraries. Check that your libraries meet the requirements of GCHP as specified on
ReadTheDocs. Also check your ESMF version and make sure you built ESMF using the same libraries with which you
are building GCHP.

If you encounter a build error and cannot figure it out from what is printed to the terminal,
rebuild with verbose on and send standard output and errors to a log. You can do this with
:literal:`make -j VERBOSE=1 2>&1 | build.log`.
Search the log for string :literal:`error`, first with a space in front of and after the word, and then only
in front. This usually hones in on where the error message occurs.
You want to find the very first occurrence of this in the log.

Read the error message carefully and then find the file and line number specified.
If it is not clear what the error is even from the error message then you can try doing a string search
on the GCHP GitHub issues page, or on the web in general, for the generic error message you get.

If you still have problems then please create an issue on GitHub containing the GCHP version, your
:file:`CMakeCache.txt` file, and your build log.

=======================================
Run-time errors that occur early in run
=======================================

The first step in debugging run-time errors is always to look at the logs. There are three main logs to look at, assuming standard error and standard output are sent to different files.

:file:`gchp.YYYYMMDD_hhmmz.log`
   This is the log file defined in the run script and contains all GEOS-Chem and HEMCO standard output.
   Look at this log to see how far the run got. It is possible the error was trapped by HEMCO or GEOS-Chem
   in which case there will be error messages explaining the problem.

:file:`slurm*.out` (or other scheduler log)
   If running on a job scheduler this would be a separate file from the main GCHP log file assuming you are
   using one of the example run scripts. The error in this file will include a traceback of the error,
   meaning filenames and line numbers where the error occurred, moving up the call stack from deepest to highest.
   Go to the very first file listed and find the line number. Also read the error message in the traceback.
   Try to determine if the error is in GEOS-Chem, HEMCO, MAPL ExtData, MAPL History, MAPL Cap, or somewhere else.

:file:`allPEs.log`
   This log is output by the logger used in MAPL. By default it provides basic information on the MAPL run
   including general GCHP infrastructure setup as well as model I/O. You can configure the model to output more
   to this file. See the section on errors in MAPL below.

Choose next steps based on what you see in the logs. The following sections go into detail about the different
approaches you can take to debugging based on the error. Read through all the topics to choose which approach
seems most appropriate.

For all strategies we recommend doing a short run at low resolution and with few cores
to make your debug runs fast and lightweight.
You should also always do a web search of the issue to see if there is an existing GitHub issue about it.
The `GCHP GitHub Issues page <https://github.com/geoschem/GCHP/issues>`_ includes a search bar.
Depending on the issue, you might also find the problem
already discussed on the `GEOS-Chem <https://github.com/geoschem/geos-chem/issues>`_ or
`HEMCO <https://github.com/geoschem/hemco/issues>`_ GitHub issues pages.

Segmentation faults
-------------------

If you are running into a segmentation fault then you should rebuild with debug flags turned on.
Do this by setting :literal:`-DCMAKE_BUILD_TYPE=Debug` during the configure step.
See compiling GCHP for more guidance on how to do this.
Once you rebuild and run there may be more information in the logs if the problem is an
out-of-bounds error or floating point exception.
Once the error is fixed remember to rebuild without debug flags on. Running the model after building
with debug flags will make the model run very slow.

Read the traceback
------------------

If the problem is not a segmentation fault and the GCHP log messages are not helpful then you should
follow the error traceback to the source code where the problem occurs. Always search for the first
file listed along with the line number. You can find the location of
files in GCHP by using the unix find command from the top-level source code directory,
e.g. :literal:`find . -name aerosol_mod.F90`.
Once you find the file and the line where the model fails you can read the code above it to try
to get a sense of the context of where it crashed. This will give clues as to
why it had a problem and may give you ideas of what to do to try to fix it.

Errors in GEOS-Chem and HEMCO
-----------------------------

Sometimes enabling built-in debug prints from GEOS-Chem and HEMCO can help find the error.
You can enable additional prints to the main GCHP log within configuration files
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


MAPL ExtData errors (data inputs)
---------------------------------

If you see :literal:`ExtData` in the error traceback then the problem has to do with input files and you should check
log file :file:`allPEs.log`. If there is not enough information in :literal:`allPEs.log` to determine what the
input file problem is then you should enable additional MAPL prints and rerun. This is mostly recommended for input
file issues because MAPL ExtData is where most of the debug logging statements are currently implemented.

Activate the :literal:`CAP.EXTDATA` and :literal:`MAPL` debug loggers by
editing the :file:`logging.yml` configuration file as shown below.
This will send all MAPL debug-level logging prints to the :file:`allPEs.log` file.

.. code-block:: yaml

   loggers:
      
      # ... etc not shown ...
      
      MAPL:
          handlers: [mpi_shared]
          level: WARNING
          root_level: INFO   <=== Change this to DEBUG
      
      CAP.EXTDATA:
          handlers: [mpi_shared]
          level: WARNING
          root_level: INFO   <=== Change this to DEBUG

See `logging.yml <config-files/logging_yml.html>`__ for more information on the MAPL logger config file.
Contact the GEOS-Chem Support Team if you need help deciphering the resulting log output.

If needed, you can also turn off certain emissions in :file:`HEMCO_Config.rc` to verify which inventory
is causing problems. This can sometimes help hone in the sections of the configuration files to
look for typos.

If the problem is due to adding new input files then you may have an issue in either the configuration
files or with the file itself. It is common to run into these sorts of errors when adding new input
files because of strict rules for import files within MAPL and the need to follow a specific format
for input data in configuration files. Make sure that you read the ReadTheDocs
pages on `HEMCO_Config.rc <config-files/HEMCO_Config_rc.html>`__ and `ExtData.rc <config-files/ExtData_rc.html>`__.
Also see NASA wiki page on
`supported ExtData input files <https://github.com/GEOS-ESM/MAPL/wiki/Guide-to-Supported-ExtData-Input-Files>`_.

Diagnostic errors
-----------------

If :file:`MAPL_HistoryGridCompMod.F90` appears in the error traceback then the issue has to do with diagnostics
in MAPL. This is usually due to a typo in `HISTORY.rc <config-files/HISTORY_rc.html>`__. Try to comment
out different collections in your :file:`HISTORY.rc` file to see if you can get past the issue.
If you isolate it to one or more collections then look closely at the file to try to find a typo.
Following the traceback to the MAPL History code is also very useful since it may tell you which entry in
the config file is causing the problem.

There can be other problems with GCHP diagnostics that do not have to do with MAPL History.
If your log has error messages from GEOS-Chem about not being able to find an entry in the Registry,
or if the error traceback includes file :file:`gchp_historyexports_mod.F90`, then the issue is likely
in GEOS-Chem. You can print out more diagnostic information to the GCHP log by enabling verbose prints
in GEOS-Chem (see earlier section on this page).

You can print out even more information by manually
uncommenting :literal:`CALL Print_DiagList`, :literal:`CALL Print_TaggedDiagList`, and
:literal:`CALL Print_HistoryExportsList` within
:literal:`src/GCHP_GridComp/GEOSChem_GridComp/geos-chem/Interfaces/GCHP/gchp_historyexports_mod.F90`.
Then rebuild and rerun. This will show you what diagnostics GEOS-Chem "registers", meaning how it
interprets :file:`HISTORY.rc`, as well as what diagnostics MAPL makes into imports. Any mismatch in these
lists will result in a run error. Note that MAPL creates imports for all fields in collections that are
turned on using the name that appears in :file:`HISTORY.rc`. GEOS-Chem's registry of fields is more
complicated because it uses the field names to determine which arrays the data are located in. Mismatches are
thus usually because of a problem in GEOS-Chem's parsing of the configuration file.

Other MAPL errors
-----------------

If the error is in MAPL but is not in ExtData or History then you should still enable
additional MAPL prints to log and rerun.
See the section above on ExtData errors for how to do that. Currently most logging messages are in ExtData
but there are a few others that might be useful. You can also add your own within MAPL. See the next section for
how to do that.

If the error is in MAPL and the traceback leads you to a call to ESMF then you should enable ESMF error
log files in GCHP and rerun. Look for file :literal:`ESMF.rc` in your run directory. Open it and
set the :literal:`logKindFlag` parameter to :literal:`ESMF_LOGKIND_MULTI_ON_ERROR` and run again. You should then get
ESMF error log files upon rerun. There will be one log file per processor and each file will start with :literal:`PET`.
More often than not the ESMF error message will appear in every file.

Add your own prints
-------------------

Sometimes the best way to find the problem is to add print commands to the source code, rebuild, and rerun.
This is particularly true if you know it is failing in a loop reading data files or parsing a
configuration file.
You can find examples in GEOS-Chem and HEMCO on printing messages from within nearly all files.
For MAPL you can use the logger. Search MAPL for :literal:`lgr%debug` to find examples.

======================================
Run-time errors that occur late in run
======================================


==================
Performance issues
==================

Performance issues in the model generally include speed and memory.

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
memory see `Memory <output_files#memory>`__ in the output files section of ReadTheDocs.

Inspecting timing
-----------------

Model timing information is printed out at the end of each GCHP run. Check the end of the GCHP log for a breakdown
of component timing. See `Timing <output_files#memory>`__ in the output files section of ReadTheDocs
for instructions on how to read the timing information printed to log.

