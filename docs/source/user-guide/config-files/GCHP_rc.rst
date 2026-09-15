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

.. describe:: NX
.. describe:: NY

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

.. describe:: GCHP.GRID_TYPE

   Type of grid GCHP will be run at. This should always be set to
   :literal:`Cubed-Sphere`.

.. describe:: GCHP.GRIDNAME

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

.. describe:: GCHP.NF

   Number of cubed-sphere faces. This must always be set to 6.

.. describe:: GCHP.IM_WORLD

   Number of grid cells on the side of a single cubed sphere
   face. This is set automatically by
   :ref:`set-common-run-settings-sh` for your configured run
   resolution.

.. describe:: GCHP.IM

   Number of grid cells on the side of a single cubed sphere
   face. This is set automatically by
   :ref:`set-common-run-settings-sh` for your configured run
   resolution.

.. describe:: GCHP.JM

   Number of grid cells on one side of a cubed sphere face,
   times 6. This represents a second dimension if all six faces are
   stacked in a 2-dimensional array. Must be equal to
   :literal:`IM*6`. This is set automatically by
   :ref:`set-common-run-settings-sh` for your configured run
   resolution.

.. describe:: GCHP.LM

   Number of vertical grid cells. This must be equal to the vertical
   resolution of the offline meteorological fields since MAPL cannot
   regrid vertically. It is set to 72 by default.

.. describe:: GCHP.STRETCH_FACTOR

   Ratio of configured global resolution to resolution of targeted
   high resolution region if using stretched grid. This is set
   automatically by :ref:`set-common-run-settings-sh` based on
   configured stretched grid settings in that file.

.. describe:: GCHP.TARGET_LON

   Target longitude for high resolution region if using stretched
   grid. This is set automatically by
   :ref:`set-common-run-settings-sh` based on configured stretched
   grid settings in that file. Negative values are acceptable for
   longitude.

.. describe:: GCHP.TARGET_LAT

   Target latitude for high resolution region if using stretched
   grid. This is set automatically by
   :ref:`set-common-run-settings-sh` based on configured stretched
   grid settings in that file.

.. describe:: IM

   Same as :literal:`GCHP.IM` and :literal:`GCHP.IM_WORLD`. This is set
   automatically by :ref:`set-common-run-settings-sh` for your
   configured run resolution.

.. describe:: JM

   Same as :literal:`GCHP.JM`. This is set automatically by
   :ref:`set-common-run-settings-sh` for your configured run
   resolution.

.. describe:: LM

   Same as :literal:`GCHP.LM`. This setting is set automatically by
   setCommonRunSettings.sh.

.. describe:: GEOSChem_CTM

   Leave this set at :literal:`1`', which tells FVDycore that it is
   operating as a transport model rather than a prognostic model.


.. describe:: MET_WIND_IS_TOP_DOWN
.. describe:: MET_HUMIDITY_IS_TOP_DOWN
.. describe:: MET_NONADVECTION_IS_TOP_DOWN

   These fields are set automatically when creating a run directory
   based on whether you choose to use processed or raw met-fields. Raw
   met-fields are top-down, while processed met-fields are not (level
   1 = surface).
	      
   .. describe:: .true.

      GCHP assumes the corresponding category of input met-fields
      (winds, humidity, and all other non-advection met-fields,
      respectively) has level 1 corresponding to top-of-atmosphere.  
   
   .. describe:: .false.

      GCHP assumes the corresponding category of input met-fields
      (winds, humidity, and all other non-advection met-fields,
      respectively) has level 1 corresponding to the surface.
   
.. describe:: MET_MASS_FLUX_IS_TOP_DOWN

   Same as :literal:`MET_WIND_IS_TOP_DOWN`, but for mass flux fields.
   Only relevant if :literal:`IMPORT_MASS_FLUX_FROM_EXTDATA` is set to
   :literal:`.true.`; otherwise this setting is ignored.

.. describe:: IMPORT_MASS_FLUX_FROM_EXTDATA

   This setting is automatically set during run directory creation.
	      
   .. describe:: .true.

      Advection will use mass fluxes read from disk.

   .. describe:: .false.

      Advection will use mass fluxes derived online from input winds.

.. describe:: USE_TOTAL_AIR_PRESSURE_IN_ADVECTION

   .. describe:: 0

      Advection will use dry air pressure. **(Default setting)**

   .. describe:: 1
		 
      Advection will use moist air pressure.  This is currently experimental.
   experimental.

.. describe:: CORRECT_MASS_FLUX_FOR_HUMIDITY

   This switch is not used if using GMAO winds for advection.
	      
   .. describe:: 1

      Mass fluxes will be converted to dry air for use in advection.
      **(Default setting)**
  
   .. describe:: 0

      Mass fluxes will be kept as-is.  

.. describe:: PRINT_MASS_IN_ADVECTION

   .. describe:: 0

      No extra printout. **(Default option)**

   .. describe:: 1

      Prints a time series of total mass during advection, which can
      be useful for checking mass conservation.

.. describe:: USE_EXTDATA2G

   This field is automatically updated by
   :ref:`set-common-run-settings-sh` from the :envvar:`Use_ExtData2G`
   setting in that file.

   .. describe:: .false.

      Will use the original MAPL ExtData component to read and regrid
      data. **(Default option)**

   .. describe:: .true.

      Will use the next-generation MAPL ExtData component
      (:ref:`extdata2g`) to read and regrid input data.

.. describe:: IMPORT_DYN_HEATING

   Used when running a perturbation scenario with RRTMG's
   :literal:`FDH` or :literal:`SEFDH` options.

   .. note::

      This setting is only read when GCHP has been built with
      :literal:`-DRRTMG=y`.  In all other builds the dynamical heating
      rates are always calculated, whatever this field says.

   .. describe:: 0

      Calculate dynamical heating rates. **(Default option)**

   .. describe:: 1

      Read dynamical heating rates that were archived from the
      reference scenario.

.. describe:: AdvCore_Advection

   Toggles offline advection. This field is automatically updated by
   :ref:`set-common-run-settings-sh` based on whether you turn
   advection on or off in that file.

   .. describe:: 1

      Enables offline advection. **(Default option in setCommonRunSettings.sh)**

  .. describe:: 0

      Disables offline advection.

.. describe:: DYCORE

   This value does nothing, but MAPL will crash if it is not declared.

   .. describe:: OFF

      Placeholder value. **(Default setting)**

   .. describe:: ON

      Placeholder value.

.. describe:: HEARTBEAT_DT

   The timestep in seconds that the DYCORE Component should be
   called. This must be a multiple of HEARTBEAT_DT in
   :ref:`cap-rc`. Note that this and all other timesteps are
   automatically set from :ref:`set-common-run-settings-sh` based
   on the configured grid resolution in that file.

.. describe:: SOLAR_DT

   The timestep in seconds that the :program:`SOLAR` Component should
   be called. This must be a multiple of :literal:`HEARTBEAT_DT` in
   :ref:`cap-rc`. GCHP does not have a :program:`SOLAR` component and
   this entry is therefore not used.

.. describe:: IRRAD_DT

   The timestep in seconds that the :program:`IRRAD` Component should
   be called. ESMF checks this value during its timestep check. This
   must be a multiple of :literal:`HEARTBEAT_DT` in :ref:`cap-rc`. GCHP
   does not have an :program:`IRRAD` component and this entry is
   therefore not used.

.. describe:: RUN_DT

   The timestep in seconds that the :program:`RUN` Component should be
   called. This setting is set automatically by
   :ref:`set-common-run-settings-sh`.

.. describe:: GCHPchem_DT

   The timestep in seconds that the :program:`GCHPchem` Component
   should be called. This must be a multiple of :literal:`HEARTBEAT_DT`
   in :ref:`cap-rc`. This setting is set automatically by
   :ref:`set-common-run-settings-sh`.

.. describe:: RRTMG_DT

   The timestep in seconds that :program:`RRTMG` should be
   called. This must be a multiple of :literal:`HEARTBEAT_DT` in
   :ref:`cap-rc`. This setting is set automatically by
   :ref:`set-common-run-settings-sh`.

.. describe:: DYNAMICS_DT

   The timestep in seconds that the :program:`FV3 advection Component`
   should be called. This must be a multiple of :literal:`HEARTBEAT_DT` in
   :ref:`cap-rc`. This setting is set automatically by
   :ref:`set-common-run-settings-sh`.

.. describe:: SOLARAvrg

   Default is :literal:`0`.

.. describe:: IRRADAvrg

   Default is :literal:`0`.

.. describe:: GCHPchem_REFERENCE_TIME

   :literal:`HHMMSS` reference time used for GCHPchem MAPL alarms
   which coordinate when subcomponents with different
   timesteps are executed, e.g. chemistry and dynamics. It is
   automatically set from :ref:`set-common-run-settings-sh`
   to be equal to the dynamic timestep.

.. describe:: PRINTRC

   Specifies which resource values to print.

   .. describe:: 0

      Print non-default resource values **(Default setting)**

   .. describe:: 1

      Print all values.

.. describe:: PARALLEL_READFORCING

   Enables or disables parallel I/O processes. Default value is
   :literal:`0` (disabled). This option does not impact reading or
   writing restart files and should be left as is.

.. describe:: NUM_READERS

   Number of simultaneous readers for reading restart files. Default
   value is :literal:`1`. Try increasing this to anywhere from 6 to 24
   to improve restart read time. Whether this helps to reduce restart
   file I/O time depends on your file system and MPI stack.

.. describe:: NUM_WRITERS

   Number of simultaneous writers for writing restart files. Default
   value is :literal:`1`. Increasing it to anywhere from 6 to 24 may
   increase restart write speed depending on your file system and MPI
   stack.

.. describe:: BKG_FREQUENCY

   Active observer when desired. Default value is :literal:`0`. This
   option is not used in GCHP.

.. describe:: MAPL_ENABLE_BOOTSTRAP

   When set to :literal:`YES` MAPL will initialize all entries of the
   internal state not in the restart file with zero values.  Note that
   missing species will later be set to the background value in the
   species database if this is allowed
   (see :literal:`INITIAL_RESTART_SPECIES_REQUIRED`).

.. describe:: INITIAL_RESTART_SPECIES_REQUIRED

   If set to :literal:`0` then the GCHP run will fail if any species
   is missing from the restart file. Set to :literal:`1` to allow
   missing species. Note that this is different from GC-Classic which
   requires updates to :ref:`cfg-hco-cfg` to allow missing
   species. That part of :ref:`cfg-hco-cfg` is ignored in GCHP.

.. describe:: RECORD_FREQUENCY

   Frequency of periodic restart file write in format
   :literal:`HHMMSS`. This is set automatically by
   :ref:`set-common-run-settings-sh` based on mid-run
   checkpoint settings configured in that file.

.. describe:: RECORD_REF_DATE

   Reference date(s) used to determine when to write periodic restart
   files. This is set automatically by
   :ref:`set-common-run-settings-sh`
   based on mid-run checkpoint settings configured in that file.

.. describe:: RECORD_REF_TIME

   Reference time(s) used to determine when to write periodic restart
   files. This is set automatically by
   :ref:`set-common-run-settings-sh` based on mid-run checkpoint
   settings configured in that file.

.. describe:: GCHPchem_INTERNAL_RESTART_FILE

   The filename of the internal restart file to be written. For GCHP
   we always use the name of the symbolic link in the run directory
   that points to the restart file. Use a sample run script to get the
   functionality of setting the symbolic link based on run start
   date. Note that the restart file includes all variables stored in
   the MAPL internal state.

.. describe:: GCHPchem_INTERNAL_RESTART_TYPE

   The format of the internal restart file. Valid types include
   :literal:`pbinary` and :literal:`pnc4`. Only use :literal:`pnc4` with GCHP.

.. describe:: GCHPchem_INTERNAL_CHECKPOINT_FILE

   The filename of the internal checkpoint file to be written. By
   default this does not include date-time. Use a sample GCHP run
   script to get the functionality to rename it to include date and
   time post-run.

.. describe:: GCHPchem_INTERNAL_CHECKPOINT_TYPE

   The format of the internal checkstart file. Valid types include
   :literal:`pbinary` and :literal:`pnc4`. Only use pnc4 with GCHP.

.. describe:: GCHPchem_INTERNAL_HEADER

   Only needed when the file type is set to
   :literal:`pbinary`. Specifies if a binary file is
   self-describing. This feature is not used in GCHP.

.. describe:: DYN_INTERNAL_RESTART_FILE

   The filename of the :program:`DYNAMICS` internal restart file to be
   written. Please note that FV3 is not configured in GCHP to use an
   internal state and therefore will not have a restart file.

.. describe:: DYN_INTERNAL_RESTART_TYPE

   The format of the :program:`DYNAMICS` internal restart file. Valid
   types include pbinary and pnc4. Please note that FV3 is not
   configured in GCHP to use an internal state and therefore will not
   have a restart file.

.. describe:: DYN_INTERNAL_CHECKPOINT_FILE

   The filename of the :program:`DYNAMICS` internal checkpoint file to
   be written. Please note that FV3 is not configured in GCHP to use
   an internal state and therefore will not have a restart file.

.. describe:: DYN_INTERNAL_CHECKPOINT_TYPE

   The format of the :program:`DYNAMICS` internal checkpoint
   file. Valid types include pbinary and pnc4. Please note that FV3 is
   not configured in GCHP to use an internal state and therefore will
   not have a restart file.

.. describe:: DYN_INTERNAL_HEADER

   Only needed when the file type is set to
   :literal:`pbinary`. Specifies if a binary file is self-describing.

.. describe:: RUN_PHASES

   GCHP uses only one run phase. The GCHP gridded component for
   chemistry, however, has the capability of two. The two-phase
   feature is used only in GEOS.

.. describe:: HEMCO_CONFIG

   Name of the HEMCO configuration file. Default is :ref:`cfg-hco-cfg` in GCHP.

.. describe:: STDOUT_LOGFILE

   Log filename template. Default is
   :file:`PET%%%%%.GEOSCHEMchem.log`. This file is not actually used
   for primary standard output and not helpful for  debugging. You may
   ignore it.

.. describe:: STDOUT_LOGLUN

   Logical unit number for stdout. Default value is :literal:`700`.

.. describe:: MEMORY_DEBUG_LEVEL

   Toggle for memory debugging.

   .. describe:: 0

      Turn off memory debugging. **(Default value)**  This will print
      memory usage only once per timestep.

   .. describe:: 1

      Will print memory usage between each GCHP gridcomp run
      (:program:`advection`, :program:`GCHPctmEnv`, and
      :program:`GEOS-Chem`) as well as between major GEOS-Chem
      components.

.. describe:: EXCLUDE_ADVECTION_TRACERS

   Controls whether the species listed in the companion
   :literal:`EXCLUDE_ADVECTION_TRACERS_LIST:` field are held back from
   advection.  Accepted values are:

   .. describe:: NO

      Advect all species.  This is the value shipped in the run
      directory template.

   .. describe:: ALWAYS

      Exclude the listed species on every advection step.  This is the
      value assumed if the field is absent from :file:`GCHP.rc`
      altogether.

   .. describe:: PREDICTOR

      Exclude the listed species only on predictor steps.

.. describe:: WRITE_RESTART_BY_OSERVER

   Determines whether MAPL restart write should use a dedicated node
   (:program:`O-server`). For some MPI stacks we find that this must
   be set to YES for high core count (>1000) runs to avoid hanging
   during file write. It is NO by default. If you run into problems
   with writing restart files with the O-server off you can try to
   switch this setting to on. In previous versions we have
   automatically turned this on for core counts but we no longer do
   this because whether it works varies with your system.

.. describe:: MODEL_PHASE

   .. describe:: FORWARD

      Denotes that GCHP is running in forward-model mode. **(Default
      setting)**

   .. describe:: ADJOINT

      Denotes that GCHP is running in adjoint mode (experimental).

   Other entries in this section that are commented out are reserved
   for adjoint development and testing.
