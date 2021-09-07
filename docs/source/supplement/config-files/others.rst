CAP.rc, GCHP.rc, input.nml
==============================

CAP.rc
------

:file:`CAP.rc` is the configuration file for the top-level gridded component called CAP. 
This gridded component can be thought of as the primary driver of GCHP. 
Its config file handles general runtime settings for GCHP including time parameters, performance profiling routines, and system-wide timestep (hearbeat). 
Combined with output file :file:`cap_restart`, :file:`CAP.rc` configures the exact dates for the next GCHP run.

ROOT_NAME	
   Sets the name MAPL uses to initialize the ROOT child gridded component component within CAP. CAP uses this name in all operations when querying and interacting with ROOT. It is set to GCHP.

ROOT_CF	
   Resource configuration file for the ROOT component. It is set to :file:`GCHP.rc`.

HIST_CF	
   Resource configuration file for the MAPL HISTORY gridded component (another child gridded component of CAP). It is set to :file:`HISTORY.rc`.

BEG_DATE	
   Simulation begin date in format YYYYMMDD hhmmss. This parameter is overrided in the presence of output file :file:`cap_restart` containing a different start date.

END_DATE	
   Simulation end date in format YYYYMMDD hhmmss. If BEG_DATE plus duration (JOB_SGMT) is before END_DATE then simulation will end at BEG_DATE + JOB_SGMT. If it is after then simulation will end at END_DATE.

JOB_SGMT	
   Simulation duration in format YYYYMMDD hhmmss. The duration must be less than or equal to the difference between start and end date or the model will crash.

HEARTBEAT_DT	
   The timestep of the ESMF/MAPL internal clock, in seconds. All other timesteps in GCHP must be a multiple of HEARTBEAT_DT. ESMF queries all components at each heartbeat to determine if computation is needed. The result is based upon individual component timesteps defined in :file:`GCHP.rc`.

MAPL_ENABLE_TIMERS
   Toggles printed output of runtime MAPL timing profilers. This is set to YES. Timing profiles are output at the end of every GCHP run.

MAPL_ENABLE_MEMUTILS	
   Enables runtime output of the programs' memory usage. This is set to YES.

PRINTSPEC	
   Allows an abbreviated model run limited to initializat and print of Import and Export state variable names. Options include: 
   
   * 0 (default): Off
   * 1: Imports and Exports only
   * 2: Imports only
   * 3: Exports only

USE_SHMEM	
   This setting is deprecated but still has an entry in the file.

REVERSE_TIME	
   Enables running time backwards in CAP. Default is 0 (off).

----------------------------------

GCHP.rc
------------------

:file:`GCHP.rc` is the resource configuration file for the ROOT component within GCHP. 
The ROOT gridded component includes three children gridded components, including one each for GEOS-Chem, FV3 advection, and the data utility environment needed to support them.

NX, NY	
   Number of grid cells in the two MPI sub-domain dimensions. NX * NY must equal the number of CPUs. NY must be a multiple of 6.

GCHP.GRID_TYPE	
   Type of grid GCHP will be run at. Should always be Cubed-Sphere.

GCHP.GRIDNAME	
   Descriptive grid label for the simulation. The default grid name is PE24x144-CF. The grid name includes how the pole is treated, the face side length, the face side length times six, and whether it is a Cubed Sphere Grid or Lat/Lon. The name PE24x144-CF indicates polar edge (PE), 24 cells along one face side, 144 for 24*6, and a cubed-sphere grid (CF). Many options here are defined in MAPL_Generic.
   
   .. note:: Must be consistent with IM and JM.

GCHP.NF	
   Number of cubed-sphere faces. This is set to 6.

GCHP.IM_WORLD	
   Number of grid cells on the side of a single cubed sphere face.

GCHP.IM	
   Number of grid cells on the side of a single cubed sphere face.

GCHP.JM	
   Number of grid cells on one side of a cubed sphere face, times 6. This represents a second dimension if all six faces are stacked in a 2-dimensional array. Must be equal to IM*6.

GCHP.LM	
   Number of vertical grid cells. This must be equal to the vertical resolution of the offline meteorological fields (72) since MAPL cannot regrid vertically.

GCHP.STRETCH_FACTOR	
   Ratio of configured global resolution to resolution of targeted high resolution region if using stretched grid.

GCHP.TARGET_LON	
   Target longitude for high resolution region if using stretched grid.

GCHP.TARGET_LAT	
   Target latitude for high resolution region if using stretched grid.

IM	
   Same as GCHP.IM and GCHP.IM_WORLD.

JM	
   Same as GCHP.JM.

LM	
   Same as GCHP.LM.

GEOChem_CTM	
   If set to 1, tells FVdycore that it is operating as a transport model rather than a prognostic model.

AdvCore_Advection	
   Toggles offline advection. 0 is off, and 1 is on.

DYCORE	
   Should either be set to OFF (default) or ON. This value does nothing, but MAPL will crash if it is not declared.

HEARTBEAT_DT
   The timestep in seconds that the DYCORE Component should be called. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`.

SOLAR_DT	
   The timestep in seconds that the SOLAR Component should be called. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`.

IRRAD_DT	
   The timestep in seconds that the IRRAD Component should be called. ESMF checks this value during its timestep check. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`.

RUN_DT	
   The timestep in seconds that the RUN Component should be called.

GCHPchem_DT	
   The timestep in seconds that the GCHPchem Component should be called. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`.

RRTMG_DT	
   The timestep in seconds that RRTMG should be called. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`.

DYNAMICS_DT	
   The timestep in seconds that the FV3 advection Component should be called. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`.

SOLARAvrg, IRRADAvrg	
   Default is 0.

GCHPchem_REFERENCE_TIME	
   HHMMSS reference time used for GCHPchem MAPL alarms.

PRINTRC	
   Specifies which resource values to print. Options include 0: non-default values, and 1: all values. Default setting is 0.

PARALLEL_READFORCING	
   Enables or disables parallel I/O processes when writing the restart files. Default value is 0 (disabled).

NUM_READERS, NUM_WRITERS	
   Number of simultaneous readers. Should divide evenly unto NY. Default value is 1.

BKG_FREQUENCY	
   Active observer when desired. Default value is 0.

RECORD_FREQUENCY	
   Frequency of periodic restart file write in format HHMMSS.

RECORD_REF_DATE	
   Reference date(s) used to determine when to write periodic restart files.

RECORD_REF_TIME	
   Reference time(s) used to determine when to write periodic restart files.

GCHOchem_INTERNAL_RESTART_FILE	
   The filename of the internal restart file to be written.

GCHPchem_INTERNAL_RESTART_TYPE	
   The format of the internal restart file. Valid types include pbinary and pnc4. Only use pnc4 with GCHP.

GCHPchem_INTERNAL_CHECKPOINT_FILE	
   The filename of the internal checkpoint file to be written.

GCHPchem_INTERNAL_CHECKPOINT_TYPE	
   The format of the internal checkstart file. Valid types include pbinary and pnc4. Only use pnc4 with GCHP.

GCHPchem_INTERNAL_HEADER	
   Only needed when the file type is set to pbinary. Specifies if a binary file is self-describing.

DYN_INTERNAL_RESTART_FILE	
   The filename of the DYNAMICS internal restart file to be written. Please note that FV3 is not configured in GCHP to use an internal state and therefore will not have a restart file.

DYN_INTERNAL_RESTART_TYPE	
   The format of the DYNAMICS internal restart file. Valid types include pbinary and pnc4. Please note that FV3 is not configured in GCHP to use an internal state and therefore will not have a restart file.

DYN_INTERNAL_CHECKPOINT_FILE	
   The filename of the DYNAMICS internal checkpoint file to be written. Please note that FV3 is not configured in GCHP to use an internal state and therefore will not have a restart file.

DYN_INTERNAL_CHECKPOINT_TYPE	
   The format of the DYNAMICS internal checkpoint file. Valid types include pbinary and pnc4. Please note that FV3 is not configured in GCHP to use an internal state and therefore will not have a restart file.

DYN_INTERNAL_HEADER	
   Only needed when the file type is set to pbinary. Specifies if a binary file is self-describing.

RUN_PHASES	
   GCHP uses only one run phase. The GCHP gridded component for chemistry, however, has the capability of two. The two-phase feature is used only in GEOS.

HEMCO_CONFIG	
   Name of the HEMCO configuration file. Default is :file:`HEMCO_Config.rc` in GCHP.

STDOUT_LOGFILE	
   Log filename template. Default is :file:`PET%%%%%.GEOSCHEMchem.log`. This file is not actually used for primary standard output.

STDOUT_LOGLUN	
   Logical unit number for stdout. Default value is 700.

MEMORY_DEBUG_LEVEL	
   Toggle for memory debugging. Default is 0 (off).

WRITE_RESTART_BY_OSERVER	
   Determines whether MAPL restart write should use o-server. This must be set to YES for high core count (>1000) runs to avoid hanging during file write. It is NO by default.

----------------------------------

input.nml
-----------------

input.nml controls specific aspects of the FV3 dynamical core used for advection. Entries in input.nml are described below.

&fms_nml	
   Header for the FMS namelist which includes all variables directly below the header.

print_memory_usage	
   Toggles memory usage prints to log. However, in practice turning it on or off does not have any effect.

domain_stack_size	
   Domain stack size in bytes. This is set to 20000000 in GCHP to be large enough to use very few cores in a high resolution run. If the domain size is too small then you will get an "mpp domain stack size overflow error" in advection. If this happens, try increasing the domain stack size in this file.

&fv_core_nml	
   Header for the finite-volume dynamical core namelist. This is commented out by default unless running on a stretched grid. Due to the way the file is read, commenting out the header declaration requires an additional comment character within the string, e.g. :literal:`#&fv#_core_nml`.

do_schmidt	
   Logical for whether to use Schmidt advection. Set to .true. if using stretched grid; otherwise this entry is commented out.

stretch_fac	
   Stretched grid factor, equal to the ratio of grid resolution in targeted high resolution region to the configured run resolution. This is commented out if not using stretched grid.

target_lat	
   Target latitude of high resolution region if using stretched grid. This is commented out if not using stretched grid.

target_lon	
   Target longitude of high resolution region if using stretched grid. This is commented out if not using stretched grid.
