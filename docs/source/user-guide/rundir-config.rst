Configure a run
===============

As noted earlier, the many configuration files in GCHP can be overwhelming but you should be able to accomplish most if not all of what you wish to configure from one place in :file:`setCommonRunSettings.sh`. Use this section to learn what to change in the run directory based on what you would like to do.

.. contents:: Table of contents
    :depth: 4

---------------------------------------------------------------------------------------------------

.. note::

   If there is topic not covered on this page that you would like to see added please create an issue on the `GCHP issues page <https://github.com/geoschem/GCHP/issues>`_ with your request.

Compute resources
-----------------

Set number of nodes and cores
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To change the number of nodes and cores for your run you must update settings in two places: (1) :file:`setCommonRunSettings.sh`, and (2) your run script. 
The :file:`setCommonRunSettings.sh` file contains detailed instructions on how to set resource parameter options and what they mean. 
Look for the Compute Resources section in the script. 
Update your resource request in your run script to match the resources set in :file:`setCommonRunSettings.sh`.

It is important to be smart about your resource allocation. 
To do this it is useful to understand how GCHP works with respect to distribution of nodes and cores across the grid. 
At least one unique core is assigned to each face on the cubed sphere, resulting in a constraint of at least six cores to run GCHP. 
The same number of cores must be assigned to each face, resulting in another constraint of total number of cores being a multiple of six. 
Communication between the cores occurs only during transport processes.

While any number of cores is valid as long as it is a multiple of six (although there is an upper limit per resolution), you will typically start to see negative effects due to excessive communication if a core is handling less than around one hundred grid cells or a cluster of grid cells that are not approximately square. 
You can determine how many grid cells are handled per core by analyzing your grid resolution and resource allocation. 
For example, if running at C24 with six cores each face is handled by one core (6 faces / 6 cores) and contains 576 cells (24x24). 
Each core therefore processes 576 cells. Since each core handles one face, each core communicates with four other cores (four surrounding faces). Maximizing squareness of grid cells per core is done automatically within :file:`setCommonRunSettings.sh` if variable :samp:`AutoUpdate_NXNY` is set to :samp:`ON` in the "DOMAIN DECOMPOSITON" section of the file.

Change domain stack size
^^^^^^^^^^^^^^^^^^^^^^^^

For runs at very high resolution or small number of processors you may run into a domains stack size error. 
This is caused by exceeding the domains stack size memory limit set at run-time.  The error will be apparent from the message in your log file. 
If this occurs you can increase the domains stack size in file :file:`input.nml`.

---------------------------------------------------------------------------------------------------

Basic run settings
------------------

Set cubed-sphere grid resolution
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
GCHP uses a cubed sphere grid rather than the traditional lat-lon grid used in GEOS-Chem Classic. 
While regular lat-lon grids are typically designated as ΔLat ⨉ ΔLon (e.g. 4⨉5), cubed sphere grids are designated by the side-length of the cube. 
In GCHP we specify this as CX (e.g. C24 or C180). 
The simple rule of thumb for determining the roughly equivalent lat-lon resolution for a given cubed sphere resolution is to divide the side length by 90. 
Using this rule you can quickly match C24 with about 4x5, C90 with 1 degree, C360 with quarter degree, and so on.

To change your grid resolution in the run directory edit :literal:`CS_RES` in the "GRID RESOLUTION" section of :file:`setCommonRunSettings.sh`. The paramter should be an integer value of the cube side length you wish to use. 
To use a uniform global grid resolution make sure :literal:`STRETCH_GRID` is set to :literal:`OFF` in the "STRETCHED GRID" section of the file. To use a stretched grid rather than a globally uniform grid see the section on this page for setting stretched grid parameters.

Set stretched grid parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

GCHP has the capability to run with a stretched grid, meaning one portion of the globe is stretched to fine resolution. 
Set stretched grid parameter in :file:`setCommonRunSettings.sh` section "STRETCHED GRID". 
See instructions in that section of the file. For more detailed information see the stretched grid section of the Supplemental Guides section of the GCHP ReadTheDocs.

Turn on/off model components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can toggle most primary GEOS-Chem components that are set in :file:`geoschem_config.yml` from the "GEOS-CHEM COMPONENTS" section of :file:`setCommonRunSettings.sh`. The settings in that file will update :file:`geoschem_config.yml` automatically so be sure to check that the settings there are as you intend. For emissions you should directly edit :file:`HEMCO_Config.rc`.

Change model timesteps
^^^^^^^^^^^^^^^^^^^^^^

Model timesteps, including chemistry, dynamic, and RRTMG, are configured within the "TIMESTEPS" section of :file:`setCommonRunSettings.sh`. 
By default, the RRTMG timestep is set to 3 hours. All other GCHP timesteps are automatically set based on grid resolution. Chemistry and dynamic timesteps are 20 and 10 minutes respectively for grid resolutions coarser than C180, and 10 and 5 minutes for C180 and higher. Meteorology read frequency for PS2, SPHU2, and TMPU2 are automatically updated in :file:`ExtData.rc` accordingly. To change the default timesteps settings edit the "TIMESTEPS" section of :file:`setCommonRunSettings.sh`.


Set simulation start date and duration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Unlike GEOS-Chem Classic, GCHP uses a start date and run duration rather than start and end dates. Set simulation start date in :file:`cap_restart` using string format :literal:`YYYYMMDD HHmmSS`. Set simulation duration in section "SIMULATION DURATION" in :file:`setCommonRunSettings.sh` using the same format as start date. For example, a 1-year run starting 15 January 2019 would have :literal:`20190115 000000` in :file:`cap_restart` and :literal:`00010000 000000` in :file:`setCommonRunSettings.sh`.

Under the hood :file:`cap_restart` is used directly by the MAPL software in GCHP, and :file:`setCommonRunSettings.sh` auto-updates the run duration in GCHP config file :file:`CAP.rc`. Please be aware that MAPL overwrites :file:`cap_restart` at the end of the simulation to contain the new start date (end of last run) so be sure to check it every time you run GCHP.

If you poke around the GCHP configuration files you may notice that file :file:`CAP.rc` contains entries for :literal:`BEG_DATE` and :literal:`END_DATE`. You can ignore these fields for most cases. :file:`BEG_DATE` is not used for start date if :file:`cap_restart` is present. However, it must be prior to your start date for use in GEOS-Chem's "ELAPSED_TIME" variable. We set it to year 1960 to be safe. :file:`BEG_DATE` can also be ignored as long as it is the same as or later than your start date plus run duration. For safety we set it to year 2200. The only time you would need to adjust these settings is for simulations way in the past or way into the future. 

---------------------------------------------------------------------------------------------------

Inputs
------

Change restart file
^^^^^^^^^^^^^^^^^^^

All GCHP run directories come with symbolic links to initial restart files for commonly used cubed sphere resolutions. These are located in the :file:`Restarts` directory in the run directory. All initial restart files contain start date and grid resolution in the filename using the start date in :file:`cap_restart`. Prior to running GCHP, either you or your run script will execute :file:`setRestartLink.sh` to create a symbolic link :file:`gchp_restart.nc4` to point to the appropriate restart file given configured start date and grid resolution. :file:`gchp_restart.nc4` will always be used as the restart file for all runs since it is specified as the restart file in :file:`GCHP.rc`.

If you want to change the restart file then you should put the restart file you want to use in the :file:`Restarts` directory using the expected filename format with the start date you configure in :file:`cap_restart` and the grid resolution you configure in :file:`setCommonRunSettings.sh`. The expected format is :literal:`GEOSChem.Restarts.YYYYMMDD_HHmmz.cN.nc4`. Running :file:`setRestartLink.sh` will update :file:`gchp_restart.nc4` to use it.

If you do not want to rename your restart file then you can create a symbolic link in the :file:`Restarts` folder that points to it.

Please note that unlike GC-Classic, GCHP does not use a separate HEMCO restart file. All HEMCO restart variables are included in the main GCHP restart.

Enable restart file to have missing species
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Most simulations by default do not allow missing species in the restart file.
The model will exit with an error if species are not found.
However, there is a switch in :file:`setCommonRunSetting.sh` to disable this behavior.
This toggle is located in the section on infrequently changed settings under the header :file:`REQUIRE ALL SPECIES IN INITIAL RESTART FILE`.
Setting the switch to :file:`NO` will use background values set in :file:`species_database.yml` as initial values for species that are missing. 

Turn on/off emissions inventories
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Because file I/O impacts GCHP performance it is a good idea to turn off file read of emissions that you do not need. 
You can turn individual emissions inventories on or off the same way you would in GEOS-Chem Classic, by setting the inventories to true or false at the top of configuration file :file:`HEMCO_Config.rc`. 
All emissions that are turned off in this way will be ignored when GCHP uses :file:`ExtData.rc` to read files, thereby speeding up the model.

For emissions that do not have an on/off toggle at the top of the file, you can prevent GCHP from reading them by commenting them out in :file:`HEMCO_Config.rc`.
No updates to :file:`ExtData.rc` would be necessary. 
If you alternatively comment out the emissions in :file:`ExtData.rc` but not :file:`HEMCO_Config.rc` then GCHP will fail with an error when looking for the file information.

Another option to skip file read for certain files is to replace the file path in :file:`ExtData.rc` with :literal:`/dev/null`. 
However, if you want to turn these inputs back on at a later time you should preserve the original path by commenting out the original line.

Change input meteorology
^^^^^^^^^^^^^^^^^^^^^^^^

Input meteorology source and grid resolution are set in config file :file:`ExtData.rc` during run directory creation. You will be prompted to choose between MERRA2 and GEOS-FP, and grid resolution is automatically set to the native grid lat-lon resolution. If you would like to change the meteorology inputs, for example using a different grid resolution, then you would need to change the met-field entries in run directory file :file:`ExtData.rc` after creating a run directory. Simply open the file, search for the meteorology section, and edit file paths as needed. Please note that while MAPL will automatically regrid met-fields to the run resolution you specify in :file:`setCommonRunSettings.sh`, you will achieve best performance using native resolution inputs. 

Add new emissions files
^^^^^^^^^^^^^^^^^^^^^^^

There are two steps for adding new emissions inventories to GCHP. They are (1) add the inventory information to :file:`HEMCO_Config.rc`, and (2) add the inventory information to :file:`ExtData.rc`.

To add inventory information to :file:`HEMCO_Config.rc`, follow the same rules as you would for adding a new emission inventory to GEOS-Chem Classic. 
Note that not all information in :file:`HEMCO_Config.rc` is used by GCHP. 
This is because HEMCO is only used by GCHP to handle emissions after they are read, e.g. scaling and applying hierarchy. 
All functions related to HEMCO file read are skipped. 
This means that you could put garbage for the file path and units in :file:`HEMCO_Config.rc` without running into problems with GCHP, as long as the syntax is what HEMCO expects. 
However, we recommend that you fill in :file:`HEMCO_Config.rc` in the same way you would for GEOS-Chem Classic for consistency and also to avoid potential format check errors.

To add inventory information to :file:`ExtData.rc` follow the guidelines listed at the top of the file and use existing inventories as examples. 
Make sure that you stay consistent with the information you put into :file:`HEMCO_Config.rc`. 
You can ignore all entries in :file:`HEMCO_Config.rc` that are copies of another entry (i.e. mostly filled with dashes). Putting these in :file:`ExtData.rc` would result in reading the same variable in the same file twice. 

A few common errors encountered when adding new input emissions files to GCHP are:

1. Your input file contains integer values. 
   Beware that the MAPL I/O component in GCHP does not read or write integers. 
   If your data contains integers then you should reprocess the file to contain floating point values instead.
2. Your data latitude and longitude dimensions are in the wrong order. 
   Lat must always come before lon in your inputs arrays, a requirement true for both GCHP and GEOS-Chem Classic. 
3. Your 3D input data are mapped to the wrong levels in GEOS-Chem (silent error). 
   If you read in 3D data and assign the resulting import to a GEOS-Chem state variable such as :literal:`State_Chm` or :literal:`State_Met`, then you must flip the vertical axis during the assignment. 
   See files :file:`Includes_Before_Run.H` and setting :literal:`State_Chm%Species` in :file:`Chem_GridCompMod.F90` for examples.
4. You have a typo in either :file:`HEMCO_Config.rc` or :file:`ExtData.rc`. Errors in :file:`HEMCO_Config.rc` typically result in the model crashing right away. 
   Errors in :file:`ExtData.rc` typically result in a problem later on during ExtData read. 
   Always try a short run with all debug prints enabled when first implementing new emissions. 
   See the debugging section of the user manual for more information. 
   Another useful strategy is to find config file entries for similar input files and compare them against the entry for your new file. 
   Directly comparing the file metadata may also lead to insights into the problem.

---------------------------------------------------------------------------------------------------

Outputs
-------

Output diagnostics data on a lat-lon grid
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

See documentation in the :file:`HISTORY.rc` config file for instructions on how to output diagnostic collection on lat-lon grids, as well as the configuration files section at the top of this page for more information on that file. If outputting on a lat-lon grid you may also output regional data instead of global. Make sure that whatever grid you choose is listed under :file:`GRID_LABELS` and is not commented out in :file:`HISTORY.rc`.

Output restart files at regular frequency
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The MAPL component in GCHP has the option to output restart files (also called checkpoint files) prior to run end. These periodic restart files are output to the main level of the run directory with filename :literal:`gcchem_internal_checkpoint.YYYYMMDD_HHssz.nc4`. 

Outputting restart files beyond the end of the run is a good idea if you plan on doing a long simulation and you are not splitting your run into multiple jobs. 
If the run crashes unexpectedly then you can restart mid-run rather than start over from the beginning.
Update settings for checkpoint restart outputs in :file:`setCommonRunSettings.sh` section "MID-RUN CHECKPOINT FILES". 
Instructions for configuring restart frequency are included in the file. 


Turn on/off diagnostics
^^^^^^^^^^^^^^^^^^^^^^^

To turn diagnostic collections on or off, comment ("#") collection names in the "COLLECTIONS" list at the top of file :file:`HISTORY.rc`. 
Collections cannot be turned on/off from :file:`setCommonRunSettings.sh`.

Set diagnostic frequency, duration, and mode
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All diagnostic collections that come with the run directory have frequency and duration auto-set within :file:`setCommonRunSettings.sh`. 
The file contains a list of time-averaged collections and instantaneous collections, and allows setting a frequency and duration to apply to all collections listed for each. Time-avraged collections also have a monthly mean option (see separate section on this page about monthly mean). 
To avoid auto-update of a certain collection, remove it from the list in :file:`setCommonRunSettings.sh`, or set "AutUpdate_Diagnostics" to :literal:`OFF`. 
See section "DIAGNOSTICS" within :file:`setCommonRunSettings.sh` for examples. 

Add a new diagnostics collection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Adding a new diagnostics collection in GCHP is the same as for GEOS-Chem Classic netcdf diagnostics. 
You must add your collection to the collection list in :file:`HISTORY.rc` and then define it further down in the file. 
Any 2D or 3D arrays that are stored within GEOS-Chem objects :literal:`State_Met`, :literal:`State_Chm`, or :literal:`State_Diag`, may be included as fields in a collection. 
:literal:`State_Met` variables must be preceded by "Met\_", :literal:`State_Chm` variables must be preceded by "Chem\_", and :literal:`State_Diag` variables should not have a prefix. 
Collections may have a combination of 2D and 3D variables, but all 3D variables must have the same number of levels.
See the :file:`HISTORY.rc` file for examples.

Generate monthly mean diagnostics
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can toggle monthly mean diagnostics on/off from within :file:`setCommonRunSettings.sh` in the "DIAGNOSTICS" section if you also set auto-update of diagnostics it that file to on. All time-averaged diagnostic collections will then automatically be configured to compute monthly mean. Alternatively, you can edit :file:`HISTORY.rc` directly and set the "monthly" field to value 1 for each collection you wish to output monthly diagnostics for. 

Prevent overwriting diagnostic files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By default all GCHP run directories are configured to allow overwriting diagnostics files present in :file:`OutputDir` over the course a simulation.
You may disable this feature by setting :file:`Allow_Overwrite=.false.` at the top of configuration file :file:`HISTORY.rc`.


