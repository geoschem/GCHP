.. _downloading_input_data:

###################
Download Input Data
###################

Input data for GEOS-Chem is available at the :ref:`GEOS-Chem Input
Data <gcid>` portal.  You may browse the contents of the data at this
link:  https://geos-chem.s3.amazonaws.com/index.html

The bashdatacatalog is the recommended method for downloading and
managing your GEOS-Chem input data. Refer to the bashdatacatalog's
`Instructions for GEOS-Chem Users
<https://github.com/geoschem/bashdatacatalog/wiki/Instructions-for-GEOS-Chem-Users>`_. Below
is a brief summary of using the bashdatacatalog for aquiring GCHP
input data.

===========================
Install the bashdatacatalog
===========================

Install the bashdatacatalog with the following command. Follow the
prompts and restart your console.

.. code-block:: console

   $ bash <(curl -s https://raw.githubusercontent.com/geoschem/bashdatacatalog/main/install.sh)

.. note:: You can rerun this command to upgrade to the latest version.

======================
Download Data Catalogs
======================

Catalog files can be downloaded from http://geoschemdata.wustl.edu/ExtData/DataCatalogs/.

The catalog files define the input data collections that GEOS-Chem needs. There are four catalogs files:

* :file:`MeteorologicalInputs.csv` -- Meteorological input data collections
* :file:`ChemistryInputs.csv` -- Chemistry input data collections
* :file:`EmissionsInputs.csv` -- Emissions input data collections
* :file:`InitialConditions.csv` -- Initial conditions input data
  collections (restart files)

The latter 3 are version specific, so you need to download the
catalogs for the version you intend to use (you can have catalogs for
multiple versions at the same time).

Create a directory to house your catalog files in the top-level of
your GEOS-Chem input data directory (commonly known as :file:`ExtData`).
You should create subdirectories for version-specific catalog files.

.. code-block:: console

   $ cd /ExtData                   # navigate to GEOS-Chem data
   $ mkdir InputDataCatalogs       # new directory for catalog files
   $ mkdir InputDataCatalogs/14.4  # for 14.4-*-specific catalogs (example)

Next, download the catalog for the appropriate version:

.. code-block:: console

   $ cd InputDataCatalogs
   $ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/MeteorologicalInputs.csv
   $ cd 14.4
   $ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/14.4/ChemistryInputs.csv
   $ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/14.4/EmissionsInputs.csv
   $ wget http://geoschemdata.wustl.edu/ExtData/DataCatalogs/14.4/InitialConditions.csv


Fetching Metadata and Downloading Input Data
--------------------------------------------

.. important::

   You should always run bashdatacatalog commands from the
   top-level of your GEOS-Chem data directory (the
   directory with :file:`HEMCO/`, :file:`CHEM_INPUTS/`, etc.).

Before you can run :command:`bashdatacatalog-list` commands, you need to
fetch the metadata of each collection.  This is done with the command
:command:`bashdatacatalog-fetch` whose arguments are catalog files:

.. code-block:: console

   $ cd /ExtData  # IMPORTANT: navigate to top-level of GEOS-Chem input data

   $ bashdatacatalog-fetch InputDataCatalogs/*.csv InputDataCatalogs/**/*.csv

Fetching downloads the latest metadata for every active collection in
your catalogs.  You should run :command:`bashdatacatalog-fetch`
whenever you add or modify a catalog, as well as periodically so you
get updates to your collections (e.g., new meteorological data that is
processed and added to the meteorological collections).
Now that you have fetched, you can run :command:`bashdatacatalog-list`
commands. You can tailor this command the generate various types of
file lists using its command-line arguments.
See :command:`bashdatacatalog-list -h` for details. A common use case
is generating a list of required input files that missing in your
local file system.

.. code-block:: console

   $ bashdatacatalog-list -am -r 2018-06-30,2018-08-01 InputDataCatalogs/*.csv InputDataCatalogs/**/*.csv


Here, :literal:`-a` means "all" files (temporal files and static
files), :literal:`-m` means "missing" (list files that are absent
locally), :literal:`-r START,END` is the date-range of your simulation
(you should add an extra day before/after your simulation), and the
remaining arguments are the paths to your catalog files.

The command can be easily modified so that it generates a list of
missing files that is compatible with xargs curl to download all the
files you are missing:

.. code-block:: console

   $ bashdatacatalog-list -am -r 2018-06-30,2018-08-01 -f xargs-curl InputDataCatalogs/*.csv InputDataCatalogs/**/*.csv | xargs curl

Here, :literal:`-f xargs-curl` means the output file list should be
formatted for piping into xargs curl.


See Also
--------

- `bashdatacatalog - Instructions for GEOS-Chem Users <https://github.com/geoschem/bashdatacatalog/wiki/Instructions-for-GEOS-Chem-Users>`_
- `bashdatacatalog - List of useful commands <https://github.com/geoschem/bashdatacatalog/wiki/3.-Useful-Commands>`_
- `GEOS-Chem Input Data Catalogs <http://geoschemdata.wustl.edu/ExtData/DataCatalogs>`_
