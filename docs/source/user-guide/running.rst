.. |br| raw:: html

   <br />

.. _running_gchp:

#############
Run the model
#############

This page presents the basic information needed to run GCHP as well as
how to verify a successful run and reuse a run directory.  A pre-run
checklist is included here for easy reference. Please read the rest of
this page to understand these steps.

=================
Pre-run checklist
=================

Prior to running GCHP, always run through the following checklist to
ensure everything is set up properly.

#. Check that the date is set in :ref:`cap-restart`. |br|
   |br|

#. Check that the executable :file:`gchp` is present. |br|
   |br|

#. Check that all symbolic links are valid (no broken links). |br|
   |br|

#. Check that all simulation settings are correct in
   :ref:`set-common-run-settings-sh`. |br|
   |br|

#. Check that :file:`setRestartLink.sh` runs without error.  (This
   ensures that the restart file is available for the date specified
   in :ref:`cap-restart`.) |br|
   |br|

#. If :ref:`running via a job scheduler <running_gchp_batch>`, check
   that the total cores in :ref:`set-common-run-settings-sh` matches the
   total cores requested in the run script. |br|
   |br|

#. If :ref:`running interactively <running_gchp_int>`, check if you
   have available locally the total cores in
   :ref:`set-common-run-settings-sh`.

===============
How to run GCHP
===============

You can run GCHP locally from within your run directory
("interactively") or by submitting your run to a job scheduler if one
is available.  Either way, it is useful to put run commands into a
reusable script we call the run script. Executing the script will
either run GCHP or submit a job that will run GCHP.

There is a symbolic link in the GCHP run directory called
:file:`runScriptSamples` that points to a directory in the source code
containing example run scripts.
Each file includes extra commands that make the run process easier and
less prone to user error.  These commands include:

#. Define a GCHP log file that includes start date configured in
   :ref:`cap-restart` in its name. |br|
   |br|

#. Load the software environment:

   .. code-block:: console

      $ source gchp.env

#. Update commonly changed run settings:

   .. code-block:: console

      $ source setCommonRunSettings.sh

#. Set restart file symbolic link :file:`gchp_restart.nc4` to target
   file in :file:`Restarts` subdirectory for configured start date and
   grid resolution. |br|
   |br|

#. Check that :file:`cap_restart` now contains the end date of your
   run. |br|
   |br|

#. Rename the output restart file to include run start date and grid
   resolution (format
   :literal:`GEOSChem.Restarts.YYYYMMDD_HHmmz.cN.nc4`).

.. _running_gchp_int:

Run interactively
-----------------

Copy or adapt example run script :file:`gchp.local.run` to run GCHP
locally on your machine. Before running, make sure the total number of
cores configured in :ref:`set-common-run-settings-sh` is available
locally. It must be at least 6.

To run, type the following at the command prompt:

.. code-block:: console

   $ ./gchp.local.run

Standard output will be displayed on your screen in addition to being
sent to a log file with filename format
:literal:`gchp.YYYYMMDD_HHmmSSz.log`. The HEMCO log output is also
included in this file.

.. _running_gchp_batch:

Run as batch job
----------------

Batch job run scripts will vary based on what job scheduler you have
available. We offer a template batch job run script in the
:file:`runScriptSamples` subdirectory called
:file:`gchp.batch_job.sh`. This file contains examples for 3 types of
job scheduler: SLURM, LSF, and PBS. You may copy and adapt this file
for your system and preferences as needed.

At the top of all batch job scripts are configurable run
settings. Most critically are requested # cores, # nodes, time, and
memory.  Figuring out the optimal values for your run can take some
trial and error.  See :ref:`hardware requirements
<hardware_requirements>` for guidance on what to choose.  The more
cores you request the faster GCHP will run given the same grid
resolution.  Configurable job scheduler settings and acceptable
formats are often accessible from the command line.  For example, type

.. code-block:: console

   $ man sbatch

to scroll through configurable options for SLURM, including various
ways of specifying number of cores, time and memory requested.

To submit a batch job using a run script called :file:`gchp.run` and
the SLURM job scheduler:

.. code-block:: console

   $ sbatch gchp.run

To submit using Grid Engine instead of SLURM:

.. code-block:: console

   $ qsub gchp.run

If your computational cluster uses a different job scheduler, check
with your IT staff or search the internet for how to configure and
submit batch jobs on your system.

=======================
Verify a successful run
=======================

GEOS-Chem standard output and standard error will be sent to a file
specific to your scheduler, e.g. :file:`slurm-jobid.out`, unless you
configured your run script to send it to a different log
file. Variable :literal:`log` is defined in the template run script as
:file:`gchp.YYYYMMDD_HHmmSSz.log` if you wish to use it. The date
string in the log filename is the start date of your simulation as
configured in :ref:`cap-restart`. This log is automatically used if
you execute the interactive run script example
:file:`gchp.local.run`. GCHP produces another output log file called
:file:`allPEs.log` which is produced by the MAPL library logger for
debugging purposes. Several other logs are output for informational
purposes only but generally are not useful for debugging.

There are several ways to verify that your run was successful. Here
are just a few:

#. The GCHP log file shows every timestep (search for :literal:`AGCM
   Date`) and ends with timing information. |br|
   |br|

#. NetCDF files are present in the :file:`OutputDir/`
   subdirectory. |br|
   |br|

#. There is a restart file corresponding to your end date in the
   :file:`Restarts` subdirectory. |br|
   |br|

#. The start date in :ref:`cap-restart` has been updated to your run
   end date. |br|
   |br|

#. The job scheduler log does not contain any error messages. |br|
   |br|

#. Output file :file:`allPEs.log` does not contain any error
   messages.

If it looks like something went wrong, scan through the log files to
determine where there may have been an error. There are several debug
strategies depending on what you find. Below is a summary of steps to
take to debug GCHP runs. See also :ref:`debugging <debugging>` for
additional guidance.

#. Find the first error message in the GCHP log file to see if it tells
   you what is wrong. |br|
   |br|

#. Find the first line of the traceback for the error and find the file
   and line number listed to see if it gives a hint about what is
   wrong. |br|
   |br|

#. Review all of your configuration files to ensure you have proper
   setup, especially :ref:`set-common-run-settings-sh`. |br|
   |br|

#. :literal:`MAPL_Cap` or :literal:`CAP` errors in the run log
   typically indicate an  error with your start time and/or duration. Check
   :ref:`cap-restart` and :ref:`set-common-run-settings-sh`. |br|
   |br|

#. :literal:`MAPL_ExtData` or :literal:`ExtData` errors in the run log
   indicate an error with your input files. Check
   :ref:`cfg-hco-cfg` and :ref:`extdata-rc` for errors. |br|
   |br|

#. :literal:`MAPL_HistoryGridComp` or :literal:`History` errors in the
   run log are related to your configured diagnostics. Check
   :ref:`history-rc` file. |br|
   |br|

#. If the problem is a segmentation fault then rebuild the model with
   cmake option :literal:`-DCMAKE_BUILD_TYPE=Debug` and rerun. |br|
   |br|

#. If the problem appears to be in HEMCO then change the warnings and
   verbose options in :ref:`cfg-hco-cfg` to true and rerun. |br|
   |br|

#. If the problem appears to be in GEOS-Chem then change the verbose
   activate option in :ref:`cfg-gc-yml` to :literal:`true`
   and rerun. |br|
   |br|

#. If the problem appears to be in MAPL ExtData then change the
   :literal:`root_level` settings for :literal:`CAP.ExtData` in
   :ref:`logging-yml` to :literal:`DEBUG` and rerun.

If you still cannot figure out where the problem is then please create
a GCHP GitHub issue and include all config and log files for your
run.

=====================
Reuse a run directory
=====================

Archive run output
------------------

Reusing a GCHP run directory comes with the perils of losing your old
work. To mitigate this issue there is utility shell script
:file:`archiveRun.sh`. This script archives data output and
configuration files to a subdirectory that will not be deleted
if you clean your run directory.

Archiving runs is useful for other reasons as well, including:

* Save all settings and logs for later reference after a run crashes
* Generate data from the same executable using different run-time
  settings for comparison, e.g. c48 versus c180
* Run short runs to compare for debugging

To archive a run, pass the archive script a descriptive subdirectory
name where data will be archived. For example:

.. code-block:: console

   $ ./archiveRun.sh 1mo_c24_24hrdiag

Which files are copied and to where will be displayed on the
screen. Diagnostic files in the :file:`OutputDir/` directory will be
moved rather than copied so as not to duplicate large files.  Restart
files will not be archived. If you would like include restart files in
the archive you must manually copy or move them.

Clean a run directory
---------------------

It is good practice to clean your run directory prior to your next run
if starting on the same date.  This avoids confusion about what output
was generated when and with what settings.  To make run directory
cleaning simple we provide utility shell script
:file:`cleanRunDir.sh`. To clean the run directory simply execute this
script.

.. code-block:: console

   $ ./cleanRunDir.sh

All GCHP output diagnostic files and logs, including NetCDF files in
:file:`OutputDir/`, will be deleted.  Restart files in the
:file:`Restarts` subdirectory will not be deleted.
