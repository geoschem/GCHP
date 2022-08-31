.. _caching_input_data:

Cache Input Data on Fast Drives
===============================

This page describes how to set up a cache of GEOS-Chem input data.
This is useful if you want to temporarily transfer a simulation's input data to a performant hard drive.
This can improve the speed of your GCHP simulation by reducing the time spent reading input data.
Caching input data is also useful if the file system that stores your GEOS-Chem input data repository has issues that are causing simulations to crash (i.e., you can transfer the data 
for your simulation to more stable hard drives).


Install the bashdatacatalog
---------------------------

Install the bashdatacatalog with the following command. Follow the prompts and restart your console.

.. code-block:: console

   gcuser:~$ bash <(curl -s https://raw.githubusercontent.com/LiamBindle/bashdatacatalog/main/install.sh)

.. note:: You can rerun this command to upgrade to the latest version.

Set Up the ExtDataCache Directory
---------------------------------

Next, we are going to set up the :file:`ExtDataCache` directory. 
You should put this directory in the appropriate path so that desired hard drives are used.
For example, if you have performance hard drives at :file:`/scratch/`, create a directory like :file:`/scratch/ExtDataCache/`.
We are going to use :file:`ExtDataCache/` to temporarily store the input data for simulations.

In the future, the idea is that you will copy the prerequisite input data to :file:`ExtDataCache/` before you run a simulation.
Since :file:`ExtDataCache/` is temporary data, you can delete it periodically to "purge" it.
Alternatively, you can use bashdatacatalog commands to selectively remove files. 
If you are running long simulations, you can keep a few years of data in :file:`ExtDataCache/`, sort of like a moving window tracking the progress of your simulation.

Create a subdirectory in :file:`ExtDataCache/` to store catalog files.
You need a set of four catalog files for each simulation: 

* MeteorologicalInputs.csv -- Specifies the simulation's meteorological input data
* ChemistryInputs.csv -- Specifies the simulation's chemistry input data
* EmissionsInputs.csv -- Specifies the simulation's emissions input data
* InitialConditions.csv -- Specifies the default restart files for the simulation

A good directory structure for catalog files is :file:`ExtDataCache/CatalogFiles/SIMULATION_ID` where :literal:`SIMULATION_ID` is a placeholder for a unique identifier for your simulation.
These instructions will put a demo set of catalog files in :file:`ExtDataCache/CatalogFiles/DemoSimulation`:

.. code-block:: console

   gcuser:~$ cd /scratch
   gcuser:/scratch$ mkdir ExtDataCache  # for storing input data for simulations
   gcuser:/scratch$ mkdir ExtDataCache/CatalogFiles  # for storing catalog files
   gcuser:/scratch$ mkdir ExtDataCache/CatalogFiles/DemoSimulation  # for storing catalog files for a specific simulation


Next, download the catalog files for the appropriate version of GEOS-Chem. You can find the GEOS-Chem catalog files `here <http://geoschemdata.wustl.edu/ExtData/DataCatalogs>`_.

.. code-block:: console

   gcuser:/scratch$ cd ExtDataCache/CatalogFiles/DemoSimulation
   gcuser:/scratch/ExtDataCache/CatalogFiles/DemoSimulation$
   gcuser:/scratch/ExtDataCache/CatalogFiles/DemoSimulation$ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/MeteorologicalInputs.csv
   gcuser:/scratch/ExtDataCache/CatalogFiles/DemoSimulation$ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/13.3/ChemistryInputs.csv
   gcuser:/scratch/ExtDataCache/CatalogFiles/DemoSimulation$ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/13.3/EmissionsInputs.csv
   gcuser:/scratch/ExtDataCache/CatalogFiles/DemoSimulation$ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/13.3/InitialConditions.csv

Edit the catalog files according to your simulation configuration. You can enable/disable data collections by editing column 3 (:literal:`1` to enable a collection, :literal:`0` to disable a collection).
If you are not sure if your simulation needs a collection, it is better to err on the side of inclusion.
The meteorological data collections are the largest by volume.
Only one meteorological data collection in :file:`MeteorologicalInputs.csv` needs to be enabled.

Update the Collection URLs
--------------------------

The default collection URLs in the catalog files point to http://geoschemdata.wustl.edu/ExtData.
To copy data from your primary ExtData repository, edit column 2 of the catalog files.
For example, if your primary ExtData repository is at :file:`/storage/ExtData` you would replace :literal:`http://geoschemdata.wustl.edu/ExtData` with :literal:`file:///storage/ExtData`
in column 2 of the catalog files. 
Below is a :command:`sed` command that will do the replacement.

.. code-block:: console

   gcuser:/scratch/ExtDataCache/CatalogFiles/DemoSimulation$ export FIND_STR="http://geoschemdata.wustl.edu/ExtData"
   gcuser:/scratch/ExtDataCache/CatalogFiles/DemoSimulation$ export REPLACE_STR="file:///storage/ExtData"   # replace '/storage/ExtData' with the path to your ExtData
   gcuser:/scratch/ExtDataCache/CatalogFiles/DemoSimulation$ sed -i "s#${FIND_STR}#${REPLACE_STR}#g" *.csv  # do url find/replace

Copy Data to ExtDataCache
-------------------------

Navigate to :file:`ExtDataCache/`. 
One you are there, run :command:`bashdatacatalog-fetch` to fetch metadata from ExtData.
The arguments to :command:`bashdatacatalog-fetch` are catalog files.
This metadata includes the file list for each data collection, and the details to classify each file as a temporal or static file.

.. code-block:: console

   gcuser:/scratch/ExtDataCache/CatalogFiles/DemoSimulation$ cd ../..
   gcuser:/scratch/ExtDataCache$ bashdatacatalog-fetch CatalogFiles/DemoSimulation/*.csv

Now you can run :command:`bashdatacatalog-list` commands to generate file lists. 
The output of :command:`bashdatacatalog-list` is controlled using flags. 
For example, add the :literal:`-s` to list "static" files (input files that are always required regardless of the simulation period).
You can list "temporal" files with the :literal:`-t` flag.
You can filter temporal files according to a date range with the :literal:`-r START,END` argument.
You can filter out files that exist using the :literal:`-m` flag (lists files that are missing).
You can specify different file list formats using the `-f FORMAT` argument. 
Below is a command that lists all the files in ExtDataCache that are missing for a simulation starting on 2017-01-01 and ending on 2017-12-31.

.. code-block:: console

   gcuser:/scratch/ExtDataCache$ bashdatacatalog-list -stm -r 2016-12-31,2018-01-01 CatalogFiles/DemoSimulation/*.csv

.. note:: 
    You need to subtract/add one day to the period of your simulation.
    The example above uses :literal:`-r 2016-12-31,2018-01-01` because the simulation period is 2017-01-01 to 2017-12-31.

To copy the missing files to ExtDataCache, you can use the argument :literal:`-f xargs-curl` to specify the output list should be formatted as input to :literal:`xargs curl`.
You can use a command similar to the one below to copy all the missing files for your simulation to ExtDataCache.


.. code-block:: console

   gcuser:/scratch/ExtDataCache$ bashdatacatalog-list -stm -r 2016-12-31,2018-01-01 -f xargs-curl CatalogFiles/DemoSimulation/*.csv | xargs -P 4 curl

.. note::
    The :literal:`-P 4` argument to :command:`xargs` allows for 4 parallel copies at a time.

Update Run Directory to use ExtDataCache
----------------------------------------

To update a run directory to use ExtDataCache, you can run the following commands.
Make sure to set :literal:`FIND_PATH` to ExtData and :literal:`REPLACE_PATH` to ExtDataCache.

.. code-block:: console

   gcuser:/scratch/ExtDataCache$ cd /MyRunDirectory  # cd to your run directory
   gcuser:/MyRunDirectory$ export FIND_PATH=/storage/ExtData         # replace path to your primary ExtData
   gcuser:/MyRunDirectory$ export REPLACE_PATH=/scratch/ExtDataCache # replace with the path to your ExtDataCache
   gcuser:/MyRunDirectory$ function swap_extdata_link { ln -sfn $(readlink $1 | sed "s#${FIND_PATH}/*#${REPLACE_PATH}/#") $1; }
   gcuser:/MyRunDirectory$ swap_extdata_link ChemDir
   gcuser:/MyRunDirectory$ swap_extdata_link HcoDir
   gcuser:/MyRunDirectory$ swap_extdata_link MetDir
   gcuser:/MyRunDirectory$ sed -i "s#${FIND_PATH}#${REPLACE_PATH}#g" HEMCO_Config.rc geoschem_config.yml

Now your GCHP simulation will use input data from ExtDataCache.

See Also
--------

* `bashdatacatalog - Instructions for GEOS-Chem Users <https://github.com/LiamBindle/bashdatacatalog/wiki/Instructions-for-GEOS-Chem-Users>`_
* `bashdatacatalog - List of useful commands <https://github.com/LiamBindle/bashdatacatalog/wiki/3.-Useful-Commands>`_
* `GEOS-Chem Input Data Catalogs <http://geoschemdata.wustl.edu/ExtData/DataCatalogs/>`_
