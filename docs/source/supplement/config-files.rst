Configuration Files
===================


GCHP is controlled using a set of resource configuration files that are included in the GCHP run directory, most of which are denoted by suffix :file:`.rc`. 
These files contain all run-time information required by GCHP. Files include:


.. toctree::
   :maxdepth: 1
   
   config-files/HISTORY.rst
   config-files/HEMCO.rst
   config-files/ExtData.rst
   config-files/input_geos.rst
   config-files/others.rst

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

