
.. _running_gchp:

Running GCHP
============

This page presents the basic information needed to run GCHP as well as how to verify a successful run and reuse a run directory. 
A pre-run checklist is included at the end to help prevent run errors. 
The GCHP "standard" simulation run directory is configured for a 1-hr simulation at c24 resolution and is a good first test case to check that GCHP runs on your system.

How to run GCHP
---------------

You can run GCHP locally from within your run directory ("interactively") or by submitting your run to a job scheduler if one is available. 
Either way, it is useful to put run commands into a reusable script we call the run script. 
Executing the script will either run GCHP or submit a job that will run GCHP.

There is a symbolic link in the GCHP run directory called :file:`runScriptSamples` that points to a directory in the source code containing example run scripts. 
Each file includes extra commands that make the run process easier and less prone to user error. 
These commands include:

1. Source environment file symbolic link :file:`gchp.env` to ensure run environment consistent with build
2. Source config file :file:`runConfig.sh` to set run-time configuration
3. Delete any previous run output files that might interfere with the new run if present
4. Send standard output to run-time log file :file:`gchp.log`
5. Rename the output restart file to include "restart" and datetime

Run interactively
^^^^^^^^^^^^^^^^^

Copy or adapt example run script gchp.local.run to run GCHP locally on your machine. 
Before running, open your run script and set nCores to the number of processors you plan to use. 
Make sure you have this number of processors available locally. 
It must be at least 6. 
Next, open file runConfig.sh and set NUM_CORES, NUM_NODES, and NUM_CORES_PER_NODE to be consistent with your run script.

To run, type the following at the command prompt:

.. code-block:: console

   $ ./gchp.local.run

Standard output will be displayed on your screen in addition to being sent to log file :file:`gchp.log`.

Run as batch job
^^^^^^^^^^^^^^^^

Batch job run scripts will vary based on what job scheduler you have available. 
Most of the example run scripts are for use with SLURM, and the most basic example of these is :file:`gchp.run`. 
You may copy any of the example run scripts to your run directory and adapt for your system and preferences as needed.

At the top of all batch job scripts are configurable run settings. 
Most critically are requested # cores, # nodes, time, and memory. 
Figuring out the optimal values for your run can take some trial and error. 
For a basic six core standard simulation job on one node you should request at least ___ min and __ Gb. 
The more cores you request the faster GCHP will run.

To submit a batch job using SLURM:

.. code-block:: console

   $ sbatch gchp.run

To submit a batch job using Grid Engine:

.. code-block:: console

   $ qsub gchp.run

Standard output will be sent to log file :file:`gchp.log` once the job is started unless you change that feature of the run script. 
Standard error will be sent to a file specific to your scheduler, e.g. :file:`slurm-jobid.out` if using SLURM, unless you configure your run script to do otherwise.

If your computational cluster uses a different job scheduler, e.g. Grid Engine, LSF, or PBS, check with your IT staff or search the internet for how to configure and submit batch jobs. 
For each job scheduler, batch job configurable settings and acceptable formats are available on the internet and are often accessible from the command line. 
For example, type :command:`man sbatch` to scroll through options for SLURM, including various ways of specifying number of cores, time and memory requested.

Verify a successful run
-----------------------

There are several ways to verify that your run was successful.

1. NetCDF files are present in the :file:`OutputDir/` subdirectory
2. Standard output file :file:`gchp.log` ends with :literal:`Model Throughput` timing information
3. The job scheduler log does not contain any error messages

If it looks like something went wrong, scan through the log files to determine where there may have been an error. Here are a few debugging tips:

* Review all of your configuration files to ensure you have proper setup
* :literal:`MAPL_Cap` errors typically indicate an error with your start time, end time, and/or duration set in :file:`runConfig.sh`
* :literal:`MAPL_ExtData` errors often indicate an error with your input files specified in either :file:`HEMCO_Config.rc` or :file:`ExtData.rc`
* :literal:`MAPL_HistoryGridComp` errors are related to your configured output in :file:`HISTORY.rc`

If you cannot figure out where the problem is please do not hesitate to create a GCHPctm GitHub issue.

Reuse a run directory
---------------------

Archive run output
^^^^^^^^^^^^^^^^^^
Reusing a GCHP run directory comes with the perils of losing your old work. 
To mitigate this issue there is utility shell script :file:`archiveRun.sh`. 
This script archives data output and configuration files to a subdirectory that will not be deleted if you clean your run directory.

Archiving runs is useful for other reasons as well, including:

* Save all settings and logs for later reference after a run crashes
* Generate data from the same executable using different run-time settings for comparison, e.g. c48 versus c180
* Run short runs in quick succession for debugging

To archive a run, pass the archive script a descriptive subdirectory name where data will be archived. For example:

.. code-block:: console

   $ ./archiveRun.sh 1mo_c24_24hrdiag

All files are archived to subfolders in the new directory. 
Which files are copied and to where are displayed on the screen. 
Diagnostic files in the :file:`OutputDir/` directory are moved rather than copied so as not to duplicate large files. 
You will be prompted at the command line to accept this change prior to data move.

Clean a run directory
^^^^^^^^^^^^^^^^^^^^^

You should always clean your run directory prior to your next run. 
This avoids confusion about what output was generated when and with what settings. 
Under certain circumstances it also avoids having your new run crash. 
GCHP will crash if:

* Output file :file:`cap_restart` is present and you did not change your start/end times
* Your last run failed in such a way that the restart file was not renamed in the post-run commands in the run script

The example run scripts include extra commands to clean the run directory of the two problematic files listed above. 
However, you may write your own run script and omit them in which case not cleaning the run directory prior to rerun will cause problems.

To make run directory cleaning simple is utility shell script :file:`cleanRunDir.sh`. To clean the run directory simply execute this script.

.. code-block:: console

   $ ./cleanRunDir.sh

All GCHP output files, including diagnostics files in :file:`OutputDir/`, will then be deleted. 
Only restart files with names matching :literal:`gcchem*` are deleted. 
This preserve the initial restart symbolic links that come with the run directory.

Pre-run checklist
-----------------

Prior to running GCHP, always run through the following checklist to ensure everything is set up properly.

1. Your run directory contains the executable :file:`gchp`.
2. All symbolic links in your run directory are valid (no broken links)
3. You have looked through and set all configurable settings in :file:`runConfig.sh`
4. If running via a job scheduler: you have a run script and the resource allocation in :file:`runConfig.sh` and your run script are consistent (# nodes and cores)
5. If running interactively: the resource allocation in :file:`runConfig.sh` is available locally
6. If reusing a run directory (optional but recommended): you have archived your last run with :literal:`./archiveRun.sh` if you want to keep it and you have deleted old output files with :literal:`./cleanRunDir.sh`
