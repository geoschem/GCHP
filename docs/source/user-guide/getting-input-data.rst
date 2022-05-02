.. _downloading_input_data:

Downloading Input Data
======================

Input data for GEOS-Chem is available at http://geoschemdata.wustl.edu/ExtData/.

The bashdatacatalog is the recommended for downloading and managing your GEOS-Chem input data. Refer to 
the bashdatacatalog's `Instructions for GEOS-Chem Users <https://github.com/LiamBindle/bashdatacatalog/wiki/Instructions-for-GEOS-Chem-Users>`_.
Below is a brief summary of using the bashdatacatalog for aquiring GCHP input data.

Install the bashdatacatalog
---------------------------

Install the bashdatacatalog with the following command. Follow the prompts and restart your console.

.. code-block:: console

   gcuser:~$ bash <(curl -s https://raw.githubusercontent.com/LiamBindle/bashdatacatalog/main/install.sh)

.. note:: You can rerun this command to upgrade to the latest version.

Download Data Catalogs
----------------------

Catalog files can be downloaded from http://geoschemdata.wustl.edu/ExtData/DataCatalogs/.

The catalog files define the input data collections that GEOS-Chem needs. There are four catalogs files:

* MeteorologicalInputs.csv -- Meteorological input data collections
* ChemistryInputs.csv -- Chemistry input data collections
* EmissionsInputs.csv -- Emissions input data collections
* InitialConditions.csv -- Initial conditions input data collections (restart files)

The latter 3 are version specific, so you need to download the catalogs for the version you intend to use (you can have catalogs
for multiple versions at the same time).

Create a directory to house your catalog files in the top-level of your GEOS-Chem input data directory (commonly known as "ExtData"). 
You should create subdirectories for version-specific catalog files.

.. code-block:: console

   gcuser:~$ cd /ExtData  # navigate to GEOS-Chem data
   gcuser:/ExtData$ mkdir InputDataCatalogs       # new directory for catalog files
   gcuser:/ExtData$ mkdir InputDataCatalogs/13.3  # " for 13.3-specific catalogs (example)

Next, download the catalog for the appropriate version:

.. code-block:: console

   gcuser:/ExtData$ cd InputDataCatalogs
   gcuser:/ExtData/InputDataCatalogs$ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/MeteorologicalInputs.csv
   gcuser:/ExtData/InputDataCatalogs$ cd 13.3
   gcuser:/ExtData/InputDataCatalogs/13.3$ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/13.3/ChemistryInputs.csv
   gcuser:/ExtData/InputDataCatalogs/13.3$ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/13.3/EmissionsInputs.csv
   gcuser:/ExtData/InputDataCatalogs/13.3$ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/13.3/InitialConditions.csv


Fetching Metadata and Downloading Input Data
--------------------------------------------

.. important:: You should always run bashdatacatalog commands from the top-level of your GEOS-Chem data directory (the directory with ``HEMCO/``, ``CHEM_INPUTS/``, etc.).

Before you can run ``bashdatacatalog-list`` commands, you need to fetch the metadata of each collection. 
This is done with the command ``bashdatacatalog-fetch`` whose arguments are catalog files:

.. code-block:: console

   gcuser:~$ cd /ExtData  # IMPORTANT: navigate to top-level of GEOS-Chem input data
   gcuser:/ExtData$ bashdatacatalog-fetch InputDataCatalogs/*.csv InputDataCatalogs/**/*.csv

Fetching downloads the latest metadata for every active collection in your catalogs. 
You should run ``bashdatacatalog-fetch`` whenever you add or modify a catalog, as well as periodically so you get updates to your collections
(e.g., new meteorological data that is processed and added to the meteorological collections).

Now that you have fetched, you can run ``bashdatacatalog-list`` commands. You can tailor this command the generate various types of file lists using its command-line arguments. 
See ``bashdatacatalog-list -h`` for details. A common use case is generating a list of required input files that missing in your local file system.

.. code-block:: console

   gcuser:/ExtData$ bashdatacatalog-list -am -r 2018-06-30,2018-08-01 InputDataCatalogs/*.csv InputDataCatalogs/**/*.csv


Here, ``-a`` means "all" files (temporal files and static files), ``-m`` means "missing" (list files that are absent locally), ``-r START,END`` is the date-range of your simulation 
(you should add an extra day before/after your simulation), and the remaining arguments are the paths to your catalog files.

The command can be easily modified so that it generates a list of missing files that is compatible with xargs curl to download all the files you are missing:

.. code-block:: console

   gcuser:/ExtData$ bashdatacatalog-list -am -r 2018-06-30,2018-08-01 -f xargs-curl InputDataCatalogs/*.csv InputDataCatalogs/**/*.csv | xargs curl

Here, ``-f xargs-curl`` means the output file list should be formatted for piping into xargs curl.


See Also
--------

* `bashdatacatalog - Instructions for GEOS-Chem Users <https://github.com/LiamBindle/bashdatacatalog/wiki/Instructions-for-GEOS-Chem-Users>`_
* `bashdatacatalog - List of useful commands <https://github.com/LiamBindle/bashdatacatalog/wiki/3.-Useful-Commands>`_
* `GEOS-Chem Input Data Catalogs <http://geoschemdata.wustl.edu/ExtData/DataCatalogs/>`_
