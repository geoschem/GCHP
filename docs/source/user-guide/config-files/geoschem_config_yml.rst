geoschem_config.yml
===================

Information about the :file:`geoschem_config.yml` file is the same as for GEOS-Chem Classic with a few exceptions. 
See the `GEOS-Chem ReadTheDocs page for this file <https://geos-chem.readthedocs.io/en/stable/gcclassic-user-guide/geoschem-config.html>`_ for a detailed description of the file..

The :file:`geoschem_config.yml` file used in GCHP is different in the following ways:

* Start/End datetimes are excluded. Start time is section :file:`cap_restart` and duration is set in :file:`setCommonRunSettings.sh`.
* Root data directory is excluded. All data paths are specified in :file:`ExtData.rc` instead with the exception of the photolysis data directory which is still listed (and used) in :file:`geoschem_config.yml`.
* Met field is excluded. Met field source is described in file paths in :file:`ExtData.rc`.
* GC classic timers setting is excluded. GEOS-Chem Classic timers code is not compiled when building GCHP. MAPL handles timers in GCHP.

Other parts of the GEOS-Chem Classic :file:`geoschem_config.yml` file that are not relevant to GCHP are simply not included in the file that is copied to the GCHP run directory. Everything you see in the file handled the same as in GEOS-Chem Classic.
