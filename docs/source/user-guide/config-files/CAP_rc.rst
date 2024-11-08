.. _cap-rc:

######
CAP.rc
######

:ref:`cap-rc` is the configuration file for the top-level gridded
component called :program:`CAP`.  This gridded component can be
thought of as the primary driver of GCHP.  Its config file handles
general runtime settings for GCHP including time parameters,
performance profiling routines, and system-wide timestep (hearbeat).
Combined with output file :ref:`cap-restart`, :ref:`cap-rc`
configures the exact dates for the next GCHP run.

.. option:: ROOT_NAME

   Sets the name MAPL uses to initialize the :program:`ROOT` child
   gridded component component within :program:`CAP`. :program:`CAP`
   uses this name in all operations when querying and interacting with
   :program:`ROOT`. It is set to :literal:`GCHP`.

.. option:: ROOT_CF

   Resource configuration file for the :program:`ROOT` component. It
   is set to :ref:`gchp-rc`.

.. option:: HIST_CF

   Resource configuration file for the MAPL :program:`HISTORY` gridded
   component (another child gridded component of :program:`CAP`). It
   is set to :ref:`history-rc`.

.. option:: BEG_DATE

   Simulation begin date in format YYYYMMDD hhmmss. This parameter is
   overrided in the presence of output file :ref:`cap-restart`
   containing a different start date.

.. option:: END_DATE

   Simulation end date in format :literal:`YYYYMMDD hhmmss`. If
   :option:`BEG_DATE` plus duration (:option:`JOB_SGMT`) is before
   :option:`END_DATE` then simulation will end at
   :option:`BEG_DATE` + :option:`JOB_SGMT`. If it is after then
   simulation will end at :option:`END_DATE`.

.. option:: JOB_SGMT

   Simulation duration in format :literal:`YYYYMMDD hhmmss`. The
   duration must be less than or equal to the difference between
   :option:`BEG_DATE` and :option:`END_DATE` or the model will crash.

.. option:: HEARTBEAT_DT

   The timestep of the ESMF/MAPL internal clock, in seconds. All other
   timesteps in GCHP must be a multiple of :option:`HEARTBEAT_DT`.
   ESMF queries all components at each heartbeat to determine if
   computation is needed. The result is based upon individual
   component timesteps defined in :ref:`gchp-rc`.

.. option:: MAPL_ENABLE_TIMERS

   Toggles printed output of runtime MAPL timing profilers. This is
   set to :literal:`YES`. Timing profiles are output at the end of
   every GCHP run.

.. option:: MAPL_ENABLE_MEMUTILS

   Enables runtime output of the program's memory usage. This is set
   to :literal:`YES`.

.. option:: PRINTSPEC

   Allows an abbreviated model run limited to initialize and print of
   Import and Export state variable names. Options include:

   * :literal:`0`: Off (default value)
   * :literal:`1`: Imports and Exports only
   * :literal:`2`: Imports only
   * :literal:`3`: Exports only

.. option:: USE_SHMEM

   This setting is deprecated but still has an entry in the file.

.. option:: REVERSE_TIME

   Enables running time backwards in :program:`CAP`. Default is 0
   (off).

.. option:: USE_EXTDATA2G

   Enables using the next generation of MAPL :program:`ExtData` (input
   component) which uses a yaml-format configuration file. Default is
   :literal:`.FALSE.` (off).
