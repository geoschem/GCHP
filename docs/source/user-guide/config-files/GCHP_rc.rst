.. _gchp-rc:

#######
GCHP.rc
#######

:file:`GCHP.rc` is the resource configuration file for the
:program:`ROOT` component within GCHP.  The :program:`ROOT` gridded
component includes three children gridded components,
including one each for GEOS-Chem (:program:`GCHPchem`), FV3 advection
(:program:`DYNAMICS`), and the data utility environment needed to
support them (:program:`GCHPctmEnv`).

.. option:: NX
.. option:: NY

   Number of grid cells in the two MPI sub-domain dimensions. Each
   face of the cubed-sphere grid is divided into :literal:`NX * NY/6`
   subdomains. :literal:`NX * NY` must equal the number of CPUs and
   :literal:`NY` must be a multiple of 6. These values are set
   automatically by :ref:`set-common-run-settings-sh`.

   .. attention::

      If you are running GCHP using input mass fluxes then there are
      additional constraints on :literal:`NX` and :literal:`NY` due to
      MAPL constraints on horizontal regridding of
      fluxes. :literal:`NX` and :literal:`NY/6` must evenly divide
      into (1) the source resolution :literal:`N`
      (e.g. :literal:`N=180` if input mass flux resolution is
      C180), and (2) the target resolution   :literal:`N'`
      (e.g. :literal:`N'=90` if run resolution is C90). This
      limits the total number of cores you can use when running GCHP
      with input mass fluxes.

.. option:: GCHP.GRID_TYPE

   Type of grid GCHP will be run at. This should always be set to
   :literal:`Cubed-Sphere`.

.. option:: GCHP.GRIDNAME

   Descriptive horizontal grid label for the simulation. The default
   grid name format is :literal:`PE{N}x{N*6}-CF` where :literal:`N` is
   the number of grid cells per cubed-sphere face side,
   e.g. :literal:`24` for :literal:`C24`. The grid name also includes
   how the pole is treated and whether it is a cubed-sphere grid or
   lat/lon (for GCHP it must always be cubed-sphere). For example, the
   name :literal:`PE24x144-CF` indicates polar edge (PE), 24 cells
   along one face side, 144 for 24*6, and a cubed-sphere grid
   (:literal:`CF`). This setting is updated automatically by
   :ref:`set-common-run-settings-sh`.

.. option:: GCHP.NF

   Number of cubed-sphere faces. This must always be set to 6.

.. option:: GCHP.IM_WORLD

   Number of grid cells on the side of a single cubed sphere
   face. This is set automatically by
   :ref:`set-common-run-settings-sh` for your configured run
   resolution.

.. option:: GCHP.IM

   Number of grid cells on the side of a single cubed sphere
   face. This is set automatically by
   :ref:`set-common-run-settings-sh` for your configured run
   resolution.

.. option:: GCHP.JM

   Number of grid cells on one side of a cubed sphere face,
   times 6. This represents a second dimension if all six faces are
   stacked in a 2-dimensional array. Must be equal to
   :literal:`IM*6`. This is set automatically by
   :ref:`set-common-run-settings-sh` for your configured run
   resolution.

.. option:: GCHP.LM

   Number of vertical grid cells. This must be equal to the vertical
   resolution of the offline meteorological fields since MAPL cannot
   regrid vertically. It is set to 72 by default.

.. option:: GCHP.STRETCH_FACTOR

   Ratio of configured global resolution to resolution of targeted
   high resolution region if using stretched grid. This is set
   automatically by :ref:`set-common-run-settings-sh` based on
   configured stretched grid settings in that file.

.. option:: GCHP.TARGET_LON

   Target longitude for high resolution region if using stretched
   grid. This is set automatically by
   :ref:`set-common-run-settings-sh` based on configured stretched
   grid settings in that file. Negative values are acceptable for
   longitude.

.. option:: GCHP.TARGET_LAT

   Target latitude for high resolution region if using stretched
   grid. This is set automatically by
   :ref:`set-common-run-settings-sh` based on configured stretched
   grid settings in that file.

.. option:: IM

   Same as :option:`GCHP.IM` and :option:`GCHP.IM_WORLD`. This is set
   automatically by :ref:`set-common-run-settings-sh` for your
   configured run resolution.

.. option:: JM

   Same as :option:`GCHP.JM`. This is set automatically by
   :ref:`set-common-run-settings-sh` for your configured run
   resolution.

.. option:: LM

   Same as :option:`GCHP.LM`. This setting is set automatically by
   setCommonRunSettings.sh.

.. option:: GEOChem_CTM

   If set to :literal:`1`, tells FVdycore that it is operating as a
   transport  model rather than a prognostic model.

.. option:: METEOROLOGY_VERTICAL_INDEX_IS_TOP_DOWN

   If set to :literal:`.true.` then GCHP assumes all input met-fields
   have level 1 corresponding to top-of-atmosphere.  This field is set
   automatically when creating a run directory based on whether you
   choose to use  processed or raw met-fields. Raw met-fields are
   top-down, while processed met-fields are not (level 1 = surface).

.. option:: IMPORT_MASS_FLUX_FROM_EXTDATA

   If set to :literal:`.true.` then input mass fluxes will be used in
   advection. If .false. mass flux will be derived online from input
   winds. This setting is automatically set during run directory
   creation.

.. option:: USE_TOTAL_AIR_PRESSURE_IN_ADVECTION

   If set to :literal:`0` then dry pressure will be used in advection
   (default). Using total air pressure in advection is currently
   experimental.

.. option:: CORRECT_MASS_FLUX_FOR_HUMIDITY

   If set to :literal:`1` then mass fluxes will be converted to dry
   air for use in advection. This switch is not used if using GMAO
   winds for advection.

.. option:: AdvCore_Advection

   Toggles offline advection. :literal:`0` is off, and :literal:`1` is
   on. This field is automatically updated by
   :ref:`set-common-run-settings-sh` based on whether you turn
   advection on or off in that file.

.. option:: DYCORE

   Should either be set to :literal:`OFF` (default) or
   :literal:`ON`. This value does nothing, but MAPL will crash if it
   is not declared.

.. option:: HEARTBEAT_DT

   The timestep in seconds that the DYCORE Component should be
   called. This must be a multiple of HEARTBEAT_DT in
   :ref:`cap-rc`. Note that this and all other timesteps are
   automatically set from :ref:`set-common-run-settings-sh` based
   on the configured grid resolution in that file.

.. option:: SOLAR_DT

   The timestep in seconds that the :program:`SOLAR` Component should
   be called. This must be a multiple of :option:`HEARTBEAT_DT` in
   :ref:`cap-rc`. GCHP does not have a :program:`SOLAR` component and
   this entry is therefore not used.

.. option:: IRRAD_DT

   The timestep in seconds that the :program:`IRRAD` Component should
   be called. ESMF checks this value during its timestep check. This
   must be a multiple of :option:`HEARTBEAT_DT` in :ref:`cap-rc`. GCHP
   does not have an :program:`IRRAD` component and this entry is
   therefore not used.

.. option:: RUN_DT

   The timestep in seconds that the :program:`RUN` Component should be
   called. This setting is set automatically by
   :ref:`set-common-run-settings-sh`.

.. option:: GCHPchem_DT

   The timestep in seconds that the :program:`GCHPchem` Component
   should be called. This must be a multiple of :option:`HEARTBEAT_DT`
   in :ref:`cap-rc`. This setting is set automatically by
   :ref:`set-common-run-settings-sh`.

.. option:: RRTMG_DT

   The timestep in seconds that :program:`RRTMG` should be
   called. This must be a multiple of :option:`HEARTBEAT_DT` in
   :ref:`cap-rc`. This setting is set automatically by
   :ref:`set-common-run-settings-sh`.

.. option:: DYNAMICS_DT

   The timestep in seconds that the :program:`FV3 advection Component`
   should be called. This must be a multiple of :option:`HEARTBEAT_DT` in
   :ref:`cap-rc`. This setting is set automatically by
   :ref:`set-common-run-settings-sh`.

.. option:: SOLARAvrg

   Default is :literal:`0`.

.. option:: IRRADAvrg

   Default is :literal:`0`.

.. option:: GCHPchem_REFERENCE_TIME

   :literal:`HHMMSS` reference time used for GCHPchem MAPL alarms
   which coordinate when subcomponents with different
   timesteps are executed, e.g. chemistry and dynamics. It is
   automatically set from :ref:`set-common-run-settings-sh`
   to be equal to the dynamic timestep.

.. option:: PRINTRC

   Specifies which resource values to print. Options include
   :literal:`0`: non-default values, and :literal:`1`: all
   values. Default setting is :literal:`0`.

.. option:: PARALLEL_READFORCING

   Enables or disables parallel I/O processes. Default value is
   :literal:`0` (disabled). This option does not impact reading or
   writing restart files and should be left as is.

.. option:: NUM_READERS

   Number of simultaneous readers for reading restart files. Default
   value is :literal:`1`. Try increasing this to anywhere from 6 to 24
   to improve restart read time. Whether this helps to reduce restart
   file I/O time depends on your file system and MPI stack.

.. option:: NUM_WRITERS

   Number of simultaneous writers for writing restart files. Default
   value is :literal:`1`. Increasing it to anywhere from 6 to 24 may
   increase restart write speed depending on your file system and MPI
   stack.

.. option:: BKG_FREQUENCY

   Active observer when desired. Default value is :literal:`0`. This
   option is not used in GCHP.

.. option:: MAPL_ENABLE_BOOTSTRAP

   When set to :literal:`YES` MAPL will initialize all entries of the
   internal state not in the restart file with zero values.  Note that
   missing species will later be set to the background value in the
   species database if this is allowed
   (see :option:`INITIAL_RESTART_SPECIES_REQUIRED`).

.. option:: INITIAL_RESTART_SPECIES_REQUIRED

   If set to :literal:`0` then the GCHP run will fail if any species
   is missing from the restart file. Set to :literal:`1` to allow
   missing species. Note that this is different from GC-Classic which
   requires updates to :ref:`cfg-hco-cfg` to allow missing
   species. That part of :ref:`cfg-hco-cfg` is ignored in GCHP.

.. option:: RECORD_FREQUENCY

   Frequency of periodic restart file write in format
   :literal:`HHMMSS`. This is set automatically by
   :ref:`set-common-run-settings-sh` based on mid-run
   checkpoint settings configured in that file.

.. option:: RECORD_REF_DATE

   Reference date(s) used to determine when to write periodic restart
   files. This is set automatically by
   :ref:`set-common-run-settings-sh`
   based on mid-run checkpoint settings configured in that file.

.. option:: RECORD_REF_TIME

   Reference time(s) used to determine when to write periodic restart
   files. This is set automatically by
   :ref:`set-common-run-settings-sh` based on mid-run checkpoint
   settings configured in that file.

.. option:: GCHPchem_INTERNAL_RESTART_FILE

   The filename of the internal restart file to be written. For GCHP
   we always use the name of the symbolic link in the run directory
   that points to the restart file. Use a sample run script to get the
   functionality of setting the symbolic link based on run start
   date. Note that the restart file includes all variables stored in
   the MAPL internal state.

.. option:: GCHPchem_INTERNAL_RESTART_TYPE

   The format of the internal restart file. Valid types include
   :literal:`pbinary` and :literal:`pnc4`. Only use :literal:`pnc4` with GCHP.

.. option:: GCHPchem_INTERNAL_CHECKPOINT_FILE

   The filename of the internal checkpoint file to be written. By
   default this does not include date-time. Use a sample GCHP run
   script to get the functionality to rename it to include date and
   time post-run.

.. option:: GCHPchem_INTERNAL_CHECKPOINT_TYPE

   The format of the internal checkstart file. Valid types include
   :literal:`pbinary` and :literal:`pnc4`. Only use pnc4 with GCHP.

.. option:: GCHPchem_INTERNAL_HEADER

   Only needed when the file type is set to
   :literal:`pbinary`. Specifies if a binary file is
   self-describing. This feature is not used in GCHP.

.. option:: DYN_INTERNAL_RESTART_FILE

   The filename of the :program:`DYNAMICS` internal restart file to be
   written. Please note that FV3 is not configured in GCHP to use an
   internal state and therefore will not have a restart file.

.. option:: DYN_INTERNAL_RESTART_TYPE

   The format of the :program:`DYNAMICS` internal restart file. Valid
   types include pbinary and pnc4. Please note that FV3 is not
   configured in GCHP to use an internal state and therefore will not
   have a restart file.

.. option:: DYN_INTERNAL_CHECKPOINT_FILE

   The filename of the :program:`DYNAMICS` internal checkpoint file to
   be written. Please note that FV3 is not configured in GCHP to use
   an internal state and therefore will not have a restart file.

.. option:: DYN_INTERNAL_CHECKPOINT_TYPE

   The format of the :program:`DYNAMICS` internal checkpoint
   file. Valid types include pbinary and pnc4. Please note that FV3 is
   not configured in GCHP to use an internal state and therefore will
   not have a restart file.

.. option:: DYN_INTERNAL_HEADER

   Only needed when the file type is set to
   :literal:`pbinary`. Specifies if a binary file is self-describing.

.. option:: RUN_PHASES

   GCHP uses only one run phase. The GCHP gridded component for
   chemistry, however, has the capability of two. The two-phase
   feature is used only in GEOS.

.. option:: HEMCO_CONFIG

   Name of the HEMCO configuration file. Default is :ref:`cfg-hco-cfg` in GCHP.

.. option:: STDOUT_LOGFILE

   Log filename template. Default is
   :file:`PET%%%%%.GEOSCHEMchem.log`. This file is not actually used
   for primary standard output and not helpful for  debugging. You may
   ignore it.

.. option:: STDOUT_LOGLUN

   Logical unit number for stdout. Default value is :literal:`700`.

.. option:: MEMORY_DEBUG_LEVEL

   Toggle for memory debugging. Default is :literal:`0`
   (off). Changing to :literal:`1` will print memory usage between
   each GCHP gridcomp run (:program:`advection`,
   :program:`GCHPctmEnv`, and :program:`GEOS-Chem`) as well as between
   major GEOS-Chem components. Using the default will result
   in memory usage print once per timestep only.

.. option:: WRITE_RESTART_BY_OSERVER

   Determines whether MAPL restart write should use a dedicated node
   (:program:`O-server`). For some MPI stacks we find that this must
   be set to YES for high core count (>1000) runs to avoid hanging
   during file write. It is NO by default. If you run into problems
   with writing restart files with the O-server off you can try to
   switch this setting to on. In previous versions we have
   automatically turned this on for core counts but we no longer do
   this because whether it works varies with your system.

.. option:: MODEL_PHASE

   Use :literal:`FORWARD` for the forward model. :literal:`ADJOINT` is
   used for adjoint runs (experimental). Other entries in this section
   that are commented out are reserved for adjoint development and
   testing.
