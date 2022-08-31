CAP.rc
======

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
