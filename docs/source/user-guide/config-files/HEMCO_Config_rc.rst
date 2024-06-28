
HEMCO_Config.rc
===============

:file:`HEMCO_Config.rc` is used in GCHP for masking and scaling within HEMCO. The input file and read frequency information is not used because MAPL ExtData handles file input rather than HEMCO in GCHP. Items at the top of the file that are ignored include:

* ROOT data directory path
* METDIR path
* DiagnPrefix
* DiagnFreq
* Wildcard

The ROOT data directory and METDIR paths are instead specified by the symbolic links in the run directory. Diagnostic filename and frequency information are specified in :file:`HISTORY.rc`. Emissions diagnostics in GCHP are output in the same way and with the same file format as other diagnostic collections in GCHP. Please note, however, that all emissions diagnostics are vertically flipped relative to other diagnostics, with level 1 corresponding to top-of-atmosphere.

In the BASE EMISSIONS section and beyond, columns that are ignored include:

* sourceFile
* sourceVar
* sourceTime
* C/R/E
* SrcDim
* SrcUnit

Because GCHP uses NASA MAPL code to read and regrid input files the file path, variable name, and data frequency are specified in GCHP config file :file:`ExtData.rc`. Input data dimensions and units are not needed since they are taken directly from the file during read.

Note that some GEOS-Chem simulations require that all species be present in the restart file. For GEOS-Chem Classic you can get around this by updating the :literal:`C/R/E` flags in :file:`HEMCO_Config.rc`. In GCHP that part of :file:`HEMCO_Config.rc` is not used. To configure your run to allow missing species in the restart file you instead need to flip a switch in config file :file:`setCommonRunSettings.sh`. Search for string :literal:`Require_Species_in_Restart` in the file. If set to 1 it will require species, and if set to 0 it will not.

Also beware that one entry in :file:`HEMCO_Config.rc` is changed when script :file:`setCommonRunSettings.sh` is executed in the run script prior to running GCHP. The online dust mass tuning factor gets replaced by a value specific to your configured grid resolution.

One entry also gets propagated to another configuration file by :file:`setCommonRunSettings.sh`. Lightning entries in :file:`ExtData.rc` get commented or uncommented depending on whether lightning climatology is turned on in :file:`HEMCO_Config.rc`.

Refer to the `GEOS-Chem ReadTheDocs page for this file <https://geos-chem.readthedocs.io/en/stable/gcclassic-user-guide/hemco-config.html>`_ for more detailed information about this file.
