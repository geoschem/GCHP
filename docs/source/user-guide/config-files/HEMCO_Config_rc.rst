
HEMCO_Config.rc
===============

Like :file:`geoschem_config.yml`, information about the :file:`HEMCO_Config.rc` file is the same as for GEOS-Chem Classic with a few exceptions. 
Refer to the `GEOS-Chem ReadTheDocs page for this file <https://geos-chem.readthedocs.io/en/stable/gcclassic-user-guide/hemco-config.html>`_ for more detailed information.

Some content of the :file:`HEMCO_Config.rc` file is ignored by GCHP. 
This is because MAPL ExtData handles file input rather than HEMCO in GCHP.

Items at the top of the file that are ignored include:

* ROOT data directory path
* METDIR path
* DiagnPrefix
* DiagnFreq
* Wildcard

The ROOT data directory and METDIR paths are instead specified by the symbolic links in the run directory.
Unlike in GEOS-Chem Classic, diagnostic filename and frequency information are specified in :file:`HISTORY.rc`.
Also unlike GEOS-Chem Classic, emissions diagnostics in GCHP are output in the same way and with the same file format as other diagnostic collections in GCHP.

In the BASE EMISSIONS section and beyond, columns that are ignored include:

* sourceFile
* sourceVar
* sourceTime
* C/R/E
* SrcDim
* SrcUnit

GCHP uses NASA MAPL code to read and regrid input files.
File path, variable name, and data frequency are specified in GCHP config file :file:`ExtData.rc`.
Input data dimensions and units are not needed since they are taken directly from the file during read.

Note that some GEOS-Chem simulations require that all species be present in the restart file.
For GEOS-Chem Classic you can get around this by updating the :literal:`C/R/E` flags in :file:`HEMCO_Config.rc`.
In GCHP that part of :file:`HEMCO_Config.rc` is not used.
To configure your run to allow missing species in the restart file you instead need to flip a switch in
config file :file:`setCommonRunSettings.sh`.
Search for string :literal:`Require_Species_in_Restart` in the file.
If set to 1 it will require species, and if set to 0 it will not.

Also beware that one entry in :file:`HEMCO_Config.rc` is changed when script
:file:`setCommonRunSettings.sh` is executed in the run script prior to running GCHP.
The online dust mass tuning factor gets replaced by a value specific to your
configured grid resolution.

One entry also gets propagated to another configuration file by :file:`setCommonRunSettings.sh`.
Lightning entries in :file:`ExtData.rc` get commented or uncommented depending on whether lightning
climatology is turned on in :file:`HEMCO_Config.rc`.
