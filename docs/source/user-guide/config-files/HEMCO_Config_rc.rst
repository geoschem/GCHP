
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

In the BASE EMISSIONS section and beyond, columns that are ignored include:

* sourceFile
* sourceVar
* sourceTime
* C/R/E
* SrcDim
* SrcUnit

All of the above information is specified in GCHP config file :file:`ExtData.rc` instead with the exception of diagnostic prefix and frequency. Unlike in the GEOS-Chem Classic, diagnostic filename and frequency information are specified in :file:`HISTORY.rc`.
