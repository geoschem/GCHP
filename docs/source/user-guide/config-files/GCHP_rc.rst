GCHP.rc
=======

:file:`GCHP.rc` is the resource configuration file for the ROOT component within GCHP. 
The ROOT gridded component includes three children gridded components, including one each for GEOS-Chem (GCHPchem), FV3 advection (DYNAMICS), and the data utility environment needed to support them (GCHPctmEnv).

NX, NY	
   Number of grid cells in the two MPI sub-domain dimensions. Each face of the cubed-sphere grid is divided into NX x NY/6 subdomains.  NX * NY must equal the number of CPUs and NY must be a multiple of 6. These values are set automatically by setCommonRunSettings.sh.

If you are running GCHP using input mass fluxes then there are additional constraints on NX and NY due to MAPL constraints on horizontal regridding of fluxes. NX and NY/6 must evenly divide into (1) the source resolution N (e.g. N=180 if input mass flux resolution is c180), and (2) the target resolution N' (e.g. N'=90 if run resoltion is c90). This limits the total number of cores you can use when running GCHP with input mass fluxes.

GCHP.GRID_TYPE	
   Type of grid GCHP will be run at. This should always be set to Cubed-Sphere.

GCHP.GRIDNAME	
   Descriptive horizontal grid label for the simulation. The default grid name format is PE{N}x{N*6}-CF where N is the number of grid cells per cubed-sphere face side, e.g. 24 for C24. The grid name also includes how the pole is treated and whether it is a cubed-sphere grid or lat/lon (for GCHP it must always be cubed-sphere). For example, the name PE24x144-CF indicates polar edge (PE), 24 cells along one face side, 144 for 24*6, and a cubed-sphere grid (CF). This setting is updated automatically by setCommonRunSettings.sh.

GCHP.NF	
   Number of cubed-sphere faces. This must always be set to 6.

GCHP.IM_WORLD	
   Number of grid cells on the side of a single cubed sphere face. This is set automatically by :file:`setCommonRunSettings.sh` for your configured run resolution.

GCHP.IM	
   Number of grid cells on the side of a single cubed sphere face. This is set automatically by :file:`setCommonRunSettings.sh` for your configured run resolution.

GCHP.JM	
   Number of grid cells on one side of a cubed sphere face, times 6. This represents a second dimension if all six faces are stacked in a 2-dimensional array. Must be equal to IM*6. This is set automatically by :file:`setCommonRunSettings.sh` for your configured run resolution.

GCHP.LM	
   Number of vertical grid cells. This must be equal to the vertical resolution of the offline meteorological fields since MAPL cannot regrid vertically. It is set to 72 by default.

GCHP.STRETCH_FACTOR	
   Ratio of configured global resolution to resolution of targeted high resolution region if using stretched grid. This is set automatically by :file:`setCommonRunSettings.sh` based on configured stretched grid settings in that file..

GCHP.TARGET_LON	
   Target longitude for high resolution region if using stretched grid. This is set automatically by :file:`setCommonRunSettings.sh` based on configured stretched grid settings in that file. Negative values are acceptable for longitude.

GCHP.TARGET_LAT	
   Target latitude for high resolution region if using stretched grid. This is set automatically by :file:`setCommonRunSettings.sh` based on configured stretched grid settings in that file..

IM	
   Same as GCHP.IM and GCHP.IM_WORLD. This is set automatically by :file:`setCommonRunSettings.sh` for your configured run resolution.

JM	
   Same as GCHP.JM. This is set automatically by :file:`setCommonRunSettings.sh` for your configured run resolution.

LM	
   Same as GCHP.LM. This setting is set automatically by setCommonRunSettings.sh.

GEOChem_CTM	
   If set to 1, tells FVdycore that it is operating as a transport model rather than a prognostic model.

METEOROLOGY_VERTICAL_INDEX_IS_TOP_DOWN
   If set to .true. then GCHP assumes all input met-fields have level 1 corresponding to top-of-atmosphere.
   This field is set automatically when creating a run directory based on whether you choose to use
   processed or raw met-fields. Raw met-fields are top-down, while processed met-fields are not (level 1 = sfc).

IMPORT_MASS_FLUX_FROM_EXTDATA
   If set to .true. then input mass fluxes will be used in advection. If .false. mass flux will be derived
   online from input winds. This setting is automatically set during run directory creation.

USE_TOTAL_AIR_PRESSURE_IN_ADVECTION
   If set to 0 then dry pressure will be used in advection (default). Using total air pressure in advection
   is currently experimental.

CORRECT_MASS_FLUX_FOR_HUMIDITY
   If set to 1 then mass fluxes will be converted to dry air for use in advection.
   This switch is not used if using GMAO winds for advection.

AdvCore_Advection	
   Toggles offline advection. 0 is off, and 1 is on. This field is automatically updated by :file:`setCommonRunSettings.sh` based on whether you turn advection on or off in that file.

DYCORE	
   Should either be set to OFF (default) or ON. This value does nothing, but MAPL will crash if it is not declared.

HEARTBEAT_DT
   The timestep in seconds that the DYCORE Component should be called. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`. Note that this and all other timesteps are automatically set from :file:`setCommonRunSetting.sh` based on the configured grid resolution in that file.

SOLAR_DT	
   The timestep in seconds that the SOLAR Component should be called. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`. GCHP does not have a SOLAR component and this entry is therefore not used.

IRRAD_DT	
   The timestep in seconds that the IRRAD Component should be called. ESMF checks this value during its timestep check. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`. GCHP does not have an IRRAD component and this entry is therefore not used.

RUN_DT	
   The timestep in seconds that the RUN Component should be called. This setting is set automatically by setCommonRunSettings.sh.

GCHPchem_DT	
   The timestep in seconds that the GCHPchem Component should be called. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`. This setting is set automatically by setCommonRunSettings.sh.

RRTMG_DT	
   The timestep in seconds that RRTMG should be called. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`. This setting is set automatically by setCommonRunSettings.sh.

DYNAMICS_DT	
   The timestep in seconds that the FV3 advection Component should be called. This must be a multiple of HEARTBEAT_DT in :file:`CAP.rc`. This setting is set automatically by setCommonRunSettings.sh.

SOLARAvrg, IRRADAvrg	
   Default is 0.

GCHPchem_REFERENCE_TIME	
   HHMMSS reference time used for GCHPchem MAPL alarms which coordinate when subcomponents with different timesteps are executed, e.g. chemistry and dynamics. It is automatically set from :file:`setCommonRunSettings.sh` to be equal to the dynamic timestep.

PRINTRC	
   Specifies which resource values to print. Options include 0: non-default values, and 1: all values. Default setting is 0.

PARALLEL_READFORCING	
   Enables or disables parallel I/O processes. Default value is 0 (disabled). This option does not impact reading or writing restart files and should be left as is.

NUM_READERS
   Number of simultaneous readers for reading restart files. Default value is 1. Try increasing this to anywhere from 6 to 24 to improve restart read time. Whether this helps wit dependent on your file system and MPI stack.

NUM_WRITERS	
   Number of simultaneous writers for writing restart files. Default value is 1. Increasing it to anywhere from 6 to 24 may increase restart write speed depending on your file system and MPI stack.

BKG_FREQUENCY	
   Active observer when desired. Default value is 0. This option is not used in GCHP.

MAPL_ENABLE_BOOTSTRAP
   When set to YES MAPL will initialize all entries of the internal state not in the restart file with zero values.
   Note that missing species will later be set to the background value in the species database if this is allowed
   (see next entry)

INITIAL_RESTART_SPECIES_REQUIRED
   If set to 0 then the GCHP run will fail if any species is missing from the restart file. Set to 1 to allow
   missing species. Note that this is different from GC-Classic which requires updates to :file:`HEMCO_Config.rc`
   to allow missing species. That part of :file:`HEMCO_Config.rc` is ignored in GCHP.

RECORD_FREQUENCY	
   Frequency of periodic restart file write in format HHMMSS. This is set automatically by :file:`setCommonRunSettings.sh` based on mid-run checkpoint settings configured in that file.

RECORD_REF_DATE	
   Reference date(s) used to determine when to write periodic restart files. This is set automatically by :file:`setCommonRunSettings.sh` based on mid-run checkpoint settings configured in that file.

RECORD_REF_TIME	
   Reference time(s) used to determine when to write periodic restart files. This is set automatically by :file:`setCommonRunSettings.sh` based on mid-run checkpoint settings configured in that file.

GCHPchem_INTERNAL_RESTART_FILE	
   The filename of the internal restart file to be written. For GCHP we always use the name of the symbolic link in the run directory that points to the restart file. Use a sample run script to get the functionality of setting the symbolic link based on run start date. Note that the restart file includes all variables stored in the MAPL internal state.

GCHPchem_INTERNAL_RESTART_TYPE	
   The format of the internal restart file. Valid types include pbinary and pnc4. Only use pnc4 with GCHP.

GCHPchem_INTERNAL_CHECKPOINT_FILE	
   The filename of the internal checkpoint file to be written. By default this does not include date-time. Use a sample GCHP run script to get the functionality to rename it to include date and time post-run.

GCHPchem_INTERNAL_CHECKPOINT_TYPE	
   The format of the internal checkstart file. Valid types include pbinary and pnc4. Only use pnc4 with GCHP.

GCHPchem_INTERNAL_HEADER	
   Only needed when the file type is set to pbinary. Specifies if a binary file is self-describing. This feature is not used in GCHP.

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
   Log filename template. Default is :file:`PET%%%%%.GEOSCHEMchem.log`. This file is not actually used for primary standard output and not helpful for debugging. You may ignore it.

STDOUT_LOGLUN	
   Logical unit number for stdout. Default value is 700.

MEMORY_DEBUG_LEVEL	
   Toggle for memory debugging. Default is 0 (off). Changing to 1 will print memory usage between each GCHP gridcomp run (advection, GCHPctmEnv, and GEOS-Chem) as well as between major GEOS-Chem components. Using the default will result in memory usage print once per timestep only.

WRITE_RESTART_BY_OSERVER
   Determines whether MAPL restart write should use a dedicated node (O-server). For some MPI stacks we find that this must be set to YES for high core count (>1000) runs to avoid hanging during file write. It is NO by default. If you run into problems with writing restart files with the O-server off you can try to switch this setting to on. In previous versions we have automatically turned this on for core counts but we no longer do this because whether it works varies with your system.

MODEL_PHASE
   Use FORWARD for the forward model. ADJOINT is used for adjoint runs (experimental). Other entries in this section that are commented out are reserved for adjoint development and testing.
