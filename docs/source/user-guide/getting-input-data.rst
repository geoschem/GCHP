
Downloading Input Data
======================

Input data for GEOS-Chem is available from the following FTP servers:

* http://geoschemdata.computecanada.ca/ExtData/ (preferred)
* http://ftp.as.harvard.edu/gcgrid/data/ExtData/

Notably, you will need four types of input data to run GCHP:

Restart file (initial conditions)
   These are initial conditions for the simulation. You can find some reasonable default initial conditions
   in the :file:`GEOSCHEM_RESTARTS/` directory. Default run directories have symlinks to these default restart files.

Meteorological data
   GCHP is driven by meteorological data from GEOS-FP or MERRA2. The GEOS-FP data is in :file:`GEOS_0.5x0.625/MERRA2/`
   and the MERRA2 data is in :file:`GEOS_0.25x0.3125/GEOS_FP/`. Default run directories have a symlink 
   (:file:`./MetDir`) to the local copy of this data.

Emissions data
   Emissions data is in the :file:`HEMCO/` directory. In this directory are :file:`INVENTORY/vYYYY-MM/` subdirectories, where
   :literal:`INVENTORY` is the name of the inventory, and :literal:`vYYYY-MM` is the date of the inventory version.
   Default run directories have a symlink (:file:`./HcoDir`) to the local copy of this data.

Chemistry inputs
   These are miscellaneous data files for GEOS-Chem. They are in the :file:`CHEM_INPUTS/` directory.
   Default run directories have a symlink (:file:`./ChemDir`) to the local copy of this data.

You can get a url list for the input data for a simulation by running (in your run directory)

.. code-block:: console
   
   $ ./utils/listInputDataFiles 20190101 20190108 --wget-urls > urls.txt
   ... <answer prompts> ...

Replace :literal:`20190101` with your desired start date and :literal:`20190108` with your desired end date.
For climatological data you will be asked to select a year. If the climatology covers your simulation period, you can
leave it blank (hit enter). If the climatology doesn't cover your simulation period, pick the closest year. Note that
this script does not include restart files, and it's a "best effort" estimation of the input data for your simulation.
At runtime you might encounter errors due from missing data files (download these yourself).

You can download the files in :file:`urls.txt` like so (replace :file:`/ExtData` with the path to your local copy of GEOS-Chem input data)

.. code-block:: console
   
   $ cp urls.txt /ExtData/urls.txt  # copy url list to local /ExtData directory
   $ cd /ExtData                    # cd to root of local /ExtData directory
   $ wget -i urls.txt -cxnH --cut-dirs=1   # download all the data
