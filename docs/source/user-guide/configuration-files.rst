

Configuration files
===================

All GCHP run directories have default simulation-specific run-time settings that are set in the configuration files. This section gives an high-level overview of all run directory configuration files used at run-time in GCHP, as well as links to detailed descriptions if you wish to learn more.

.. note::
   The many configuration files in GCHP can be overwhelming. However, you should be able to accomplish most if not all of what you wish to configure from one place in :file:`setCommonRunSettings.sh`. That file is a bash script used to configure settings in other files from one place.

-------------------------------------------

Configuration files
-------------------

Detailed information about most of GCHP's configuration file can be found in the following pages..
You can also reach these pages by continuing with the "next" button in this user guide.
See further down on this page for a high-level summary of all configuration files.

.. toctree::
   :maxdepth: 1
   
   config-files/setCommonRunSettings_sh.rst
   config-files/GCHP_rc.rst
   config-files/CAP_rc.rst
   config-files/ExtData_rc.rst
   config-files/geoschem_config_yml.rst
   config-files/HEMCO_Config_rc.rst
   config-files/input_nml.rst
   config-files/logging_yml.rst
   config-files/HISTORY_rc.rst
   config-files/HEMCO_Diagn_rc.rst

-------------------------------------------

High-level summary
------------------

This high-level summary of GCHP configuration files gives a short description of each file. 

:file:`CAP.rc`
   Controls parameters used by the highest level gridded component (CAP). 
   This includes simulation run time information, name of the Root gridded component (GCHP),
   config filenames for Root and History, and toggles for certain MAPL logging utilities
   (timers, memory, and import/export name printing). Values are automatically set from
   settings in :file:`setCommonRunSetting.sh`.

:file:`ESMF.rc`
   Controls the logging level of ESMF.
   By default this file specifies no log output for ESMF. See the file for available options you can set at run-time.

:file:`ExtData.rc`
   Config file for the MAPL ExtData component. 
   Specifies input variable information, including name, regridding method, read frequency, offset, scaling, and file path.
   All GCHP imports must be specified in this file. 
   Toggles at the top of the file enable MAPL ExtData debug prints and using most recent year if current year of data is unavailable. 
   Default values may be used by specifying file path :file:`/dev/null`.

:file:`GCHP.rc`
   Controls high-level aspects of the simulation, including grid type and resolution, core distribution,
   stretched-grid parameters, timesteps, and restart filename. Values are automatically set from
   settings in :file:`setCommonRunSettings.sh`.

:file:`geoschem_config.yml`
   Primary config file for GEOS-Chem. Same file format as in GEOS-Chem Classic but containing only options relevant to GCHP.
   Some fields are automatically updated from settings in :file:`setCommonRunSettings.sh`.

:file:`HEMCO_Config.rc`
   Contains emissions information used by HEMCO. 
   Same function as in GEOS-Chem Classic except only HEMCO name, species, scale IDs, category, and hierarchy are used. 
   Diagnostic frequency, file path, read frequency, and units are ignored, and are instead stored in
   GCHP config file :file:`ExtData.rc`. 
   All HEMCO variables listed in :file:`HEMCO_Config.rc` for enabled emissions must also have an entry in :file:`ExtData.rc`.

:file:`HEMCO_Diagn.rc`
   Contains information mapping :file:`HISTORY.rc` diagnostic names to HEMCO containers. 
   Same function as in GEOS-Chem Classic except that not all items in :file:`HEMCO_Diagn.rc` will be output; only
   emissions listed in :file:`HISTORY.rc` will be included in diagnostics. 
   All GCHP diagnostics listed in :file:`HISTORY.rc` that start with Emis, Hco, or Inv must have a corresponding entry in :file:`HEMCO_Diagn.rc`.

:file:`HISTORY.rc`
   Config file for the MAPL History component. 
   It configures diagnostic output from GCHP. There is an option in :file:`setCommonRunSettings.sh` to auto-update this
   file based on settings configured there, including duration, frequency, and which collections to update.

:file:`input.nml`
   Namelist used in advection for domain stack size and stretched grid parameters. Users should not need to update this.

:file:`logging.yml`
   Config file for the NASA MAPL logger package included in GCHP for logging. 
   This package uses a hierarchy of loggers, such as info, warnings, error, and debug, to extract non-GEOS-Chem information about GCHP runs and print it to log file :file:`allPEs.log`. Use this file to debug problems with data inputs.

:file:`setCommonRunSettings.sh`
   This file is a bash script where you can set commonly changed run settings. 
   It makes it easier to manage configuring GCHP since settings can be changed from one file rather than across multiple configuration files. 
   When this file is executed it updates settings in other configuration files, overwriting what is there. 
   Please get very familiar with the options in :file:`setCommonRunSettings.sh` and be conscientious about not updating the same setting elsewhere.




