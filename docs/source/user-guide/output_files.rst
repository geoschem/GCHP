Output Files
============

A successful GCHP run produces three categories of output files: diagnostics, restarts (also called checkpoints), and logs. Diagnostic and restart files are always in netCDF4 format, and logs are always ascii viewable with any text editor. Diagnostic files are output to the :file:`OutputDir` directory in the run directory. The restart files are output to the :file:`Restarts` directory. All other output files are saved to the main level of the run directory.

.. note::
   It is important to be aware that GCHP 3D data files in this version of GCHP have two different vertical dimension conventions. Restart files and Emissions diagnostic files are defined with top-of-atmospheric level equal to 1. All other data files, meaning all diagnostic files that are not Emissions collections, are defined with surface level equal to 1. This means files may be vertically flipped relative to each other. This should be taken into account when doing data visualization and analysis using these files.

--------------------------------

File descriptions
-----------------

Below is a summary of all GCHP output files that you may encounter depending on your run directory configuration.

.. option:: gchp.YYYYMMSS_HHmmSSz.log

   Standard output log file of GCHP, including both GEOS-Chem and HEMCO. 
   The date in the filename is the start date of the simulation. 
   Using this file is technically optional since it appears only in the run script. 
   However, the advantage of sending GCHP standard output to this file is that the logs of consecutive runs will not be over-written due to the date in the filename. 
   Note that the file contains HEMCO log information as well as GEOS-Chem. 
   Unlike in GEOS-Chem Classic there is no :file:`HEMCO.log` in GCHP. 

.. option:: batch job file, e.g. slurm-jobid.out

   If you use a job scheduler to submit GCHP as a batch job then you will have a job log file. 
   This file will contain output from your job script unless sent to a different file. 
   If your run crashes then the MPI error messages and error traceback will also appear in this file.

.. option:: allPES.log

   GCHP logging output based on configuration in `logging.yml <config-files/logging_yml.html>`__. 
   Treat this file as a debugging tool to help diagnose problems in MAPL, particularly the ExtData component of the model which handles input reading and regridding.

.. option:: logfile.000000.out

   Log file for advection. It includes information such as the domain stack size, stretched grid factors, and FV3 parameters used in the run. Generally this log is not useful for debugging.

.. option:: cap_restart

   This file is both input and output. As an input file it contains the simulation start date. 
   After a successful run the content of the file is updated to the simulation end date. 
   As an output file it is therefore the input file for the next run if running GCHP simulations consecutively in time.

.. option:: Restarts/GEOSChem.Restart.YYYYMMDD_HHmmz.cN.nc4

   GCHP restart files after being renamed within the run script. 
   Please note that the vertical level dimension in all GCHP restart files is positive down, meaning level 1 is top-of-atmosphere.
   These files are actually MAPL checkpoint files that are output with name set in configuration file :file:`GCHP.rc`.
   Checkpoint files that are output mid-run include datetime. Checkpoint files that are output at the end of the
   run do not. All checkpoint files are renamed by the run script (if you are using one our examples) to
   be the standard GEOS-Chem restart file format.
   Renaming is ideal because (1) it includes the datetime to prevent overwriting upon consecutive runs, and (2) it enables using the :file:`gchp_restart.nc4` symbolic link in the main run directory to automatically point to the correct restart file based on start date and grid resolution. 
   If your run crashes then you may see instead files that start with :file:`gcchem_internal_checkpoint`.

.. option:: OutputDir/GEOSChem.HistoryCollectionName.YYYYMMDD_HHmmz.nc4

   GCHP diagnostic data files. Each file contains the collection name configured in :file:`HISTORY.rc` and the datetime of the first data in the file. For time-averaged data files the datetime is the start of the averaging period. 
   Please note that the vertical level dimension in GCHP diagnostics files is collection-dependent. 
   Data are positive down, meaning level 1 is top-of-atmosphere, for the Emissions collection. 
   All other collections are positive up, meaning level 1 is surface.

.. option:: HistoryCollectionName.rcx

   Summary of settings in :file:`HISTORY.rc` per collection.

.. option:: EGRESS

   This file is empty and can be ignored. It is an artifact of the MAPL software used in GCHP.

.. option:: warnings_and_errors.log

   This file is empty and can be ignored. It is an artifact of configuration in :file:`logging.yml`.

Memory
------

Memory statistics are printed to the GCHP log each model timestep. As discussed in the run directory configuration section of this user guide, this includes percentage of memory committed, percentage of memory used, total used memory (MB), and total swap memory (MB) by default.

To inspect the memory usage of GCHP you can grep the output log file for string :literal:`Date:` and :literal:`Mem/Swap`. For example, :literal:`grep "Date:\|Mem/Swap" gchp.log`. The end of the line containing date and time shows memory committed and used. For example, :literal:`42.8% :  40.4% Mem Comm:Used` indicates 42.8% of memory available is committed and 40.4% of memory is actually used. The total memory used is in the next line, for example :literal:`Mem/Swap Used (MB) at MAPL_Cap:TimeLoop=  1.104E+05  0.000E+00`. The first value is the total memory used in MB, and the second line is swap (virtual) memory used. In this example GCHP is using around 110 gigabytes of memory with zero swap.

These memory statistics are useful for assessing how much memory GCHP is using and whether the memory usage grows over time. If the memory usage goes up throughout a run then it is an indication of a memory leak in the model. The memory debugging option is useful for isolating the memory leak by determining if there if it is in GEOS-Chem or advection.

Timing
------

Timing of GCHP components is done using MAPL timers. A summary of all timing is printed to the GCHP log at the end of a run. Configuring timers from the run directory is not currently possible but will be an option in a future version. Until then a complete summary of timing will always be printed to the end of the log for a successful GCHP run. You can use this information to help diagnose timing issues in the model, such as extra slow file read due to system problems.

The timing output written by MAPL is somewhat cryptic but you can use this guide to decipher it. Timing is broken in up into several sections.

1. :literal:`GCHPctmEnv`, the environment component that facilitates exchange between GEOS-Chem and FV3 advection
2. :literal:`GCHPchem`, the GEOS-Chem component containing chemistry, mixing, convection, emissions and deposition
3. :literal:`DYNAMICS`, the FV3 advection component
4. :literal:`GCHP`, the parent component of GCHPctmEnv, GCHPchem, and DYNAMICS, and sibling component to HIST and EXTDATA
5. :literal:`HIST`, the MAPL History component for writing diagnostics
6. :literal:`EXTDATA`, the MAPL ExtData component for processing inputs, including reading and regridding
7. Total model and MPI communicator run times broken into user, system, and total times
8. Full summary of all major model components, including core routines SetService, Initialize, Run, and Finalize
9. Model throughput in units of days per day

Each of the six gridded component sections contains two sub-sections. The first subsection shows timing statistics for core gridded component processes and their child functions. These statistics include number of execution cycles as well as inclusive and exclusive total time and percent time. :literal:`Inclusive` refers to the time spent in that function including called child functions. :literal:`Exclusive` refers to the time spent in that function excluding called child functions.

The second subsection shows from left to right minimum, mean, and maximum processor times for the gridded component and its MAPL timers. If you are interested in timing for a specific part of GEOS-Chem then use the timers in this section for :literal:`GCHPchem`, specifically the ones that start with prefix :literal:`GC_`. For chemistry you should look at timer :literal:`GC_CHEM` which includes the calls to compute overhead ozone, set H2O, and calling the chemistry driver routine.

Beware that the timers can be difficult to interpret because the component times do not always add up to the total run time. This is likely due to load imbalance where processors wait (timed in MAPL) while other processors complete (timed in other processes). You can get a sense of how large the wait time is by comparing the :literal:`Exclusive` time to the :literal:`Inclusive` time. If the former is smaller than the latter then the bulk of time is spent in a sub-process and the :literal:`Exclusive` time may be at least partially due to wait time. 

If you are interested in changing the definitions of GCHP timers, or adding a new one, you will need to edit the source code. Toggling :literal:`GC_` timers on and off are mostly in file :file:`geos-chem/Interfaces/GCHP/gchp_chunk_mod.F90`, but also in :file:`geos-chem/Interfaces/GCHP/Chem_GridCompMod.F90`, using MAPL subroutines :literal:`MAPL_TimerOn` and :file:`MAPL_TimerOff`. When in doubt about what a timer is measuring it is best to check the source code to see what calls it is wrapping.


