GCHP.rc
=======

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
