
HEMCO_Config.rc, HEMCO_Diagn.rc
==================================

HEMCO_Config.rc
-----------------------

Like :file:`input.geos`, information about the :file:`HEMCO_Config.rc` file is the same as for GEOS-Chem Classic with a few exceptions. 
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

---------------------------------

HEMCO_Diagn.rc
-----------------------

Like in GEOS-Chem Classic, the :file:`HEMCO_Diagn.rc` file is used to map between HEMCO containers and output file diagnostic names. 
However, while all uncommented diagnostics listed in :file:`HEMCO_Diagn.rc` are output as HEMCO diagnostics in GEOS-Chem Classic, only the subset also listed in :file:`HISTORY.rc` are output in GCHP. 
See the HEMCO documentation for an overview of the file.
