geoschem_config.yml
===================

Information about the :file:`geoschem_config.yml` file is the same as for GEOS-Chem Classic with a few exceptions. 
See the GEOS-Chem ReadTheDocs configuration files section for an overview of the file.

The :file:`geoschem_config.yml` file used in GCHP is different in the following ways:

* Start/End datetimes are ignored. Set this information in :file:`CAP.rc` instead.
* Root data directory is ignored. All data paths are specified in :file:`ExtData.rc` instead with the exception of the FAST-JX data directory which is still listed (and used) in :file:`geoschem_config.yml`.
* Met field is ignored. Met field source is described in file paths in :file:`ExtData.rc`.
* GC classic timers setting is ineffectual. GEOS-Chem Classic timers code is not compiled when building GCHP.

Other parts of the GEOS-Chem Classic :file:`geoschem_config.yml` file that are not relevant to GCHP are simply not included in the file that is copied to the GCHP run directory.
