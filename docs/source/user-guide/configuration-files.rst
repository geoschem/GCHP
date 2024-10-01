###################
Configuration files
###################

All GCHP run directories have default simulation-specific run-time
settings that are set in the configuration files. This section gives
an high-level overview of all run directory configuration files used
at run-time in GCHP, as well as links to detailed descriptions if you
wish to learn more.

.. note::

   The many configuration files in GCHP can be overwhelming. However,
   you should be able to accomplish most if not all of what you wish
   to configure from one place in
   :file:`setCommonRunSettings.sh`. That file is a bash script used to
   configure settings in other files from one place.  Please get
   very familiar with the options in :file:`setCommonRunSettings.sh`
   by reading through the configuration section of the file.
   Be conscientious about not updating the same setting elsewhere.

================================
List of GCHP configuration files
================================

Detailed information about most of GCHP's configuration file can be
found in the following pages.  You can also reach these pages by
continuing with the "next" button in this user guide. See further down
on this page for a high-level summary of all configuration files.

.. toctree::
   :maxdepth: 1

   config-files/setCommonRunSettings_sh.rst
   config-files/GCHP_rc.rst
   config-files/CAP_rc.rst
   config-files/cap_restart.rst
   config-files/ExtData_rc.rst
   ../../geos-chem-shared-docs/doc/geoschem-config.rst
   ../../geos-chem-shared-docs/doc/hemco-config.rst
   config-files/input_nml.rst
   config-files/logging_yml.rst
   config-files/HISTORY_rc.rst
   ../../geos-chem-shared-docs/doc/hemco-diagn.rst
   ../../geos-chem-shared-docs/doc/spec-db.rst
   ../../geos-chem-shared-docs/doc/phot-chem.rst

==================
High-level summary
==================

This high-level summary of GCHP configuration files gives a short description of each file.

:ref:`cap-rc`
   Controls parameters used by the highest level gridded component
   (:program:`CAP`). This includes simulation run time information,
   name of the Root gridded component (:program:`GCHP`), config
   filenames for :program:`ROOT` and :program:`HISTORY`, and toggles
   for certain MAPL logging utilities (timers, memory, and
   import/export name printing). Values are automatically set from
   settings in :ref:`set-common-run-settings-sh`.

:ref:`cap-restart`
   Contains the datetime (in :literal:`YYYYMMDD hhmmss` format) of the
   restart file that will be read by GCHP at simulation startup.

:file:`ESMF.rc`
   Controls the logging level of ESMF. By default this file specifies
   no log output for ESMF. See the file for available options you can
   set at run-time.

:ref:`extdata-rc`
   Config file for the MAPL :program:`ExtData` component. Specifies input
   variable information, including name, regridding method, read
   frequency, offset, scaling, and file path. All GCHP imports must be
   specified in this file.  Toggles at the top of the file enable MAPL
   ExtData debug prints and using most recent year if current year of
   data is unavailable.  Default values may be used by specifying file
   path :file:`/dev/null`.

:ref:`gchp-rc`
   Controls high-level aspects of the simulation, including grid type
   and resolution, core distribution, stretched-grid parameters,
   timesteps, and restart filename. Values are automatically set from
   settings in :ref:`set-common-run-settings-sh`.

:ref:`cfg-gc-yml`
   Primary config file for GEOS-Chem. Same file format as in GEOS-Chem
   Classic but containing only options relevant to GCHP.  Some fields
   are automatically updated from settings in
   :ref:`set-common-run-settings-sh`.

:ref:`cfg-hco-cfg`
   Contains emissions information used by `HEMCO
   <https://hemco.readthedocs.io>`_. Same function as in `GEOS-Chem
   Classic <https://geos-chem.readthedocs.io>`_ except only HEMCO
   name, species, scale IDs, category, and hierarchy are
   used. Diagnostic frequency, file path, read frequency, and units
   are ignored, and are instead stored in  GCHP config file
   :ref:`extdata-rc`. All HEMCO variables listed in
   :file:`cfg-hco-cfg` for enabled emissions must also have an entry
   in :file:`extdata-rc`.

:ref:`cfg-hco-diagn`
   Contains information mapping :ref:`history-rc` diagnostic names to
   HEMCO containers.  Same function as in GEOS-Chem Classic except
   that not all items in :ref:`cfg-hco-cfg` will be output;
   only emissions listed in :ref:`history-rc` will be included in
   diagnostics.  All GCHP diagnostics listed in :ref:`history-rc` that
   start with :literal:`Emis`, :literal:`Hco`, or :literal:`Inv` must
   have a corresponding entry in :ref:`cfg-hco-diagn`.

:ref:`history-rc`
   Config file for the MAPL :program:`HISTORY` component. It
   configures diagnostic output from GCHP. There is an option in
   :ref:`set-common-run-settings-sh` to auto-update this file based on
   settings configured there, including duration, frequency, and
   which collections to update.

   Please see our :ref:`history-diag-guide` supplemental guide for a
   list of GEOS-Chem diagnostic collections.

:ref:`input-nml`
   Namelist used in advection for domain stack size and stretched grid
   parameters. Users should not need to update this.

:ref:`logging-yml`
   Config file for the NASA MAPL logger package included in GCHP for
   logging.  This package uses a hierarchy of loggers, such as info,
   warnings, error, and debug, to extract non-GEOS-Chem information
   about GCHP runs and print it to log file :file:`allPEs.log`. Use
   this file to debug problems with data inputs.

:ref:`set-common-run-settings-sh`
   This file is a bash script where you can set commonly changed run
   settings.  It auto-updates other configuration files when it is
   sourced.  It makes it easier to manage configuring GCHP since
   settings can be changed from one file rather than across multiple
   configuration files.

:ref:`cfg-spec-db`
   The GEOS-Chem Species Database, a YAML file containing species
   metadata.  You will not need to modify this unless you add or
   remove species from one of the GEOS-Chem chemistry mechanisms.
