Configuration files
===================

GCHP is controlled using a set of resource configuration files that are included in the GCHP run directory, most of which are denoted by suffix :file:`.rc`. 
These files contain all run-time information required by GCHP. Files include:

* :file:`CAP.rc`
* :file:`ExtData.rc`
* :file:`GCHP.rc`
* :file:`input.geos`
* :file:`HEMCO_Config.rc`
* :file:`HEMCO_Diagn.rc`
* :file:`input.nml`
* :file:`HISTORY.rc`

Much of the labor of updating the configuration files has been eliminated by run directory shell script :file:`runConfig.sh`. 
It is important to remember that sourcing :file:`runConfig.sh` will overwrite settings in other configuration files, and you therefore should never manually update other configuration files unless you know the specific option is not available in :file:`runConfig.sh`.

That being said, it is still worth understanding the contents of all configuration files and what all run options include. 
This page details the settings within all configuration files and what they are used for.

---------------------------------

File descriptions
-----------------

The following table lists the core functions of each of the configuration files in the GCHP run directory. 
See the individual subsections on each file for additional information.

:file:`CAP.rc`
   Controls parameters used by the highest level gridded component (CAP). 
   This includes simulation run time information, name of the Root gridded component (GCHP), config filenames for Root and History, and toggles for certain MAPL logging utilities (timers, memory, and import/export name printing).

:file:`ExtData.rc`
   Config file for the MAPL ExtData component. 
   Specifies input variable information, including name, regridding method, read frequency, offset, scaling, and file path. 
   All GCHP imports must be specified in this file. 
   Toggles at the top of the file enable MAPL ExtData debug prints and using most recent year if current year of data is unavailable. 
   Default values may be used by specifying file path :file:`/dev/null`.      

:file:`GCHP.rc`
   Controls high-level aspects of the simulation, including grid type and resolution, core distribution, stretched-grid parameters, timesteps, and restart file configuration.

:file:`input.geos`
   Primary config file for GEOS-Chem. 
   Same function as in GEOS-Chem Classic except grid, simulation start/end, met field source, timers, and data directory information are ignored.

:file:`HEMCO_Config.rc`
   Contains emissions information used by HEMCO. 
   Same function as in GEOS-Chem Classic except only HEMCO name, species, scale IDs, category, and hierarchy are used. 
   Diagnostic frequency, file path, read frequency, and units are ignored, and are instead stored in GCHP config file :file:`ExtData.rc`. 
   All HEMCO variables listed in :file:`HEMCO_Config.rc` for enabled emissions must also have an entry in :file:`ExtData.rc`.

:file:`HEMCO_Diagn.rc`
   Contains information mapping :file:`HISTORY.rc` diagnostic names to HEMCO containers. 
   Same function as in GEOS-Chem Classic except that not all items in :file:`HEMCO_Diagn.rc` will be output; only emissions listed in :file:`HISTORY.rc` will be included in diagnostics. 
   All GCHPctm diagnostics listed in :file:`HISTORY.rc` that start with Emis, Hco, or Inv must have a corresponding entry in :file:`HEMCO_Diagn.rc`.

:file:`input.nml`
   Namelist used in advection for domain stack size and stretched grid parameters.

:file:`HISTORY.rc`
   Config file for the MAPL History component. Configures diagnostic output from GCHP.

---------------------------------

:file:`CAP.rc`
--------------

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

---------------------------------

:file:`ExtData.rc`
------------------

:file:`ExtData.rc` contains input variable and file read information for GCHP. 
Explanatory information about the file is located at the top of the configuration file in all run directories. 
The file format is the same as that used in the GEOS model, and GMAO/NASA documentation for it can be found at the ExtData component page on the GEOS-5 wiki.

The following two parameters are set at the top of the file:

Ext_AllowExtrat	
   Logical toggle to use data from nearest year available. This is set to true for GCHP. Note that GEOS-Chem Classic accomplishes the same effect but with more flexibility in :file:`HEMCO_Config.rc`. That functionality of :file:`HEMCO_Config.rc` is ignored in GCHP.

DEBUG_LEVEL	
   Turns MAPL ExtData debug prints on/off. This is set to 0 in GCHP (off), but may be set to 1 to enable. Beware that turning on ExtData debug prints greatly slows down the model, and prints are only done from the root thread. Use this when debugging problems with input files.

The rest of the file contains space-delimited lines, one for each variable imported to the model from an external file. 
Columns are as follows in order as they appear left to right in the file:

Export Name	
   Name of imported met field (e.g. ALBD) or HEMCO emissions container name (e.g. GEIA_NH3_ANTH).

Units	
   Unit string nested within single quotes. '1' indicates there is no unit conversion from the native units in the netCDF file.
Clim	
   Enter Y if the file is a 12 month climatology, otherwise enter N. If you specify it is a climatology ExtData the data can be on either one file or 12 files if they are templated appropriately with one per month.
Conservative	
   Enter Y the data should be regridded in a mass conserving fashion through a tile file. :literal:`F;{VALUE}` can also be used for fractional regridding. Otherwise enter N to use the non-conervative bilinear regridding.

Refresh 
   Time Template	Possible values include:
   
   * -: The field will only be updated once the first time ExtData runs
   * 0: Update the variable at every step. ExtData will do a linear interpolation to the current time using the available data.
   * %y4-%m2-%h2T%h2:%n2:00: Set the recurring time to update the file. The file will be updated when the evaluated template changes. For example, a template in the form %y4-%m2-%d2T12:00:00 will cause the variable to be updated at the start of a new day (i.e. when the clock hits 2007-08-02T00:00:00 it will update the variable but the time it will use for reading and interpolation is 2007-08-02T12:00:00).

Offset Factor	
   Factor the variable will be shifted by. Use none for no shifting.

Scale Factor	
   Factor the variable will be scaled by. Use none for no scaling.
   
External File Variable	
   The name of the variable in the netCDF data file, e.g. ALBEDO in met fields.

External File Template	
   Path to the netCDF data file. If not using the data, specify :file:`/dev/null` to reduce processing time. If there are no tokens in the template name ExtData will assume that all the data is on one file. Note that if the data on file is at a different resolution that the application grid, the underlying I/O library ExtData uses will regrid the data to the application grid.

---------------------------------

:file:`GCHP.rc`
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

---------------------------------

:file:`input.geos`
------------------

Information about the :file:`input.geos` file is the same as for GEOS-Chem Classic with a few exceptions. 
See the :file:`input.geos` file wiki page for an overview of the file.

The :file:`input.geos` file used in GCHP is different in the following ways:

* Start/End datetimes are ignored. Set this information in :file:`CAP.rc` instead.
* Root data directory is ignored. All data paths are specified in :file:`ExtData.rc` instead with the exception of the FAST-JX data directory which is still listed (and used) in :file:`input.geos`.
* Met field is ignored. Met field source is described in file paths in :file:`ExtData.rc`.
* GC classic timers setting is ineffectual. GEOS-Chem Classic timers code is not compiled when building GCHP.

Other parts of the GEOS-Chem Classic :file:`input.geos` file that are not relevant to GCHP are simply not included in the file that is copied to the GCHP run directory.

---------------------------------

:file:`HEMCO_Config.rc`
-----------------------

Like :file:`input.geos`, information about the :file:`HEMCO_Config.rc` file is the same as for GEOS-Chem Classic with a few exceptions. 
Refer to the HEMCO documentation for an overview of the file.

Some content of the :file:`HEMCO_Config.rc` file is ignored by GCHP. 
This is because MAPL ExtData handles file input rather than HEMCO in GCHP.

Items at the top of the file that are ignored include:

* ROOT data directory path
* METDIR path
* DiagnPrefix
* DiagnFreq
* Wildcard

In the BASE EMISSIONS section and beyond, columns that are ignored include:

* sourceFile
* sourceVar
* sourceTime
* C/R/E
* SrcDim
* SrcUnit

All of the above information is specified in file :file:`ExtData.rc` instead with the exception of diagnostic prefix and frequency. Diagnostic filename and frequency information is specified in :file:`HISTORY.rc`.

---------------------------------

:file:`HEMCO_Diagn.rc`
-----------------------

Like in GEOS-Chem Classic, the :file:`HEMCO_Diagn.rc` file is used to map between HEMCO containers and output file diagnostic names. 
However, while all uncommented diagnostics listed in :file:`HEMCO_Diagn.rc` are output as HEMCO diagnostics in GEOS-Chem Classic, only the subset also listed in :file:`HISTORY.rc` are output in GCHP. 
See the HEMCO documentation for an overview of the file.

---------------------------------

:file:`input.nml`
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

---------------------------------

:file:`HISTORY.rc`
------------------

The :file:`HISTORY.rc` configuration file controls the diagnostic files output by GCHP. Information is organized into several sections:

1. Single parameters set at the top of the file
2. Grid label declaration list
3. Definition for each grid in grid label list
4. Variable collection declaration list
5. Definition for each collection in collection list.

Single parameters set at the top of :file:`HISTORY.rc` are as follows and apply to all collections:

EXPID	
   Filename prefix concatenated with each collection template string to define file path. It is set to OutputDir/GCHP so that all output diagnostic files are output to run subdirectory OutputDir and have filename begin with GCHP.

EXPDSC	
   Export description included as attribute "Title" in output files

CoresPerNode	
   Number of CPUs per node for your simulation.

VERSION	
   Optional parameter included as attribute in output file.

The grid labels section of :file:`HISTORY.rc` declares a list of descriptive grid strings followed by a definition for each declared grid label. 
Grids not in the grid label list may have definitions in the file; however, this will prevent them from being used in output collections. 
See the :file:`HISTORY.rc` grid label section for syntax on declaring and defining grid labels.

Keywords that may be used for grid label definitions are in the table below. 
Note that this list is not exhaustive; MAPL may have additional keywords that may be used that have not yet been explored for use with GCHP.

GRID_TYPE	
   Type of grid. May be Cubed-Sphere or LatLon.

IM_WORLD	
   Side length of one cubed-sphere face, e.g. 24 if grid resolution is C24, or number of longitudinal grid boxes if lat-lon.

JM_WORLD	
   Same as IM_WORLD but multiplied by 6 (number of faces), or number of latitudinal grid boxes if lat-lon.

POLE	
   For lat-lon grids only. PC if latitudes are pole-centered and PE if latitudes are polar edge.

DATELINE	
   For lat-lon grids only. DC if longitudes are dateline-centered and DE if longitudes are dateline-edge.

LAT_RANGE	
   For lat-lon grids only. Regional grid latitudinal bounds.

LON_RANGE	
   For lat-lon grids only. Regional grid longitudinal bounds.

LM	
   Number of vertical levels.

The collections section of :file:`HISTORY.rc` declares a list of descriptive strings that define unique collections of output variables and settings. 
As with grid labels, it is followed by a definition for each declared collection. 
Collections not in the collection list, or present but commented out, may have definitions in the file; however, this will prevent them from being output. 
See the :file:`HISTORY.rc` collection section for syntax on declaring and defining output collections.

Keywords that may be used for collection definitions are in the table below. 
Note that this list is not exhaustive; MAPL may have additional keywords that may be used that have not yet been explored for use with GCHP.

{COLLECTION}.template	
   The output filename suffix that is appended to global parameter EXPID to define full output file path. Including a date string, such as '%y4%m2%d2, will insert the simulation start day following GrADS conventions. The default template for GCHP is set to %y4%m2%d2_%h2%n2z.nc4.

{COLLECTION}.format	
   Character string defining the file format. Options include CFIO (default) for netCDF-4 or flat for binary files. Always output as CFIO when using GCHP.

{COLLECTION}.grid_label	
   Declared grid label for output grid. If excluded the collection will be output on the cubed-sphere grid at native resolution, e.g. C24 if you run GCHP with grid resolution C24.

{COLLECTION}.conservative	
   For lat-lon grids only. Set to 1 to conservatively regrid from cubed-sphere to lat-lon upon output. Exclude or set to 0 to use bilinear interpolation instead (not recommended).

{COLLECTION}.frequency	
   The frequency at which output values are computed and archived, in format HHMMSS. For example, 010000 will calculate diagnostics every hour. The method of calculation is determined by the mode keyword. Unlike GEOS-Chem Classic, you cannot specify number of days, months, or years.

{COLLECTION}.duration	
   The frequency at which files are written, in format HHMMSS. For example, 240000 will output daily files. The number of times in the file are determined by the frequency keyword. Unlike GEOS-Chem Classic, you cannot specify number of days, months, or years.

{COLLECTION}.mode	
   Method of diagnostic calculation. Options are either instantaneous or time-averaged.

{COLLECTION}.fields	
   List of character string pairs including diagnostic name and gridded component. All GCHP diagnostics belong to the GCHPchem gridded component.

Diagnostic names have prefixes that determine where MAPL History will look for them. Prefixes Emis, Inv, and Hco are HEMCO diagnostics and must have definitions in config file :file:`HEMCO_Diagn.rc`. Prefixes Chem and Met are GEOS-Chem state variables stored in objects State_Chm and State_Met respectively. Prefix SPC corresponds to internal state species, meaning the same arrays that are output to the restart file. Prefix GEOS is reserved for use in the GEOS model. All other diagnostic name prefixes are interpreted as variables stored in the GEOS-Chem State_Diag object.