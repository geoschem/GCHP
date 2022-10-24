
HEMCO_Config.rc
===============

Like :file:`geoschem_config.yml`, information about the :file:`HEMCO_Config.rc` file is the same as for GEOS-Chem Classic with a few exceptions. 
Refer to the HEMCO documentation for an overview of the file.

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

All of the above information is specified in file :file:`ExtData.rc` instead with the exception of diagnostic prefix and frequency. Diagnostic filename and frequency information is specified in :file:`HISTORY.rc`.
