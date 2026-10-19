.. _cap-rc:

######
CAP.rc
######

:ref:`cap-rc` is the configuration file for the top-level gridded
component called :program:`CAP`.  This gridded component can be
thought of as the primary driver of GCHP.  Its config file handles
general runtime settings for GCHP including time parameters,
performance profiling routines, and system-wide timestep (heartbeat).
Combined with output file :ref:`cap-restart`, :ref:`cap-rc`
configures the exact dates for the next GCHP run.

.. describe:: ROOT_NAME

   Sets the name MAPL uses to initialize the :program:`ROOT` child
   gridded component within :program:`CAP`. :program:`CAP`
   uses this name in all operations when querying and interacting with
   :program:`ROOT`. It is set to :literal:`GCHP`.

.. describe:: ROOT_CF

   Resource configuration file for the :program:`ROOT` component. It
   is set to :ref:`gchp-rc`.

.. describe:: HIST_CF

   Resource configuration file for the MAPL :program:`HISTORY` gridded
   component (another child gridded component of :program:`CAP`). It
   is set to :ref:`history-rc`.

.. describe:: BEG_DATE

   Simulation begin date in format YYYYMMDD hhmmss. This parameter is
   overridden in the presence of output file :ref:`cap-restart`
   containing a different start date.

.. describe:: END_DATE

   Simulation end date in format :literal:`YYYYMMDD hhmmss`. If
   :literal:`BEG_DATE` plus duration (:literal:`JOB_SGMT`) is before
   :literal:`END_DATE` then simulation will end at
   :literal:`BEG_DATE` + :literal:`JOB_SGMT`. If it is after then
   simulation will end at :literal:`END_DATE`.

.. describe:: JOB_SGMT

   Simulation duration in format :literal:`YYYYMMDD hhmmss`. The
   duration must be less than or equal to the difference between
   :literal:`BEG_DATE` and :literal:`END_DATE` or the model will crash.

.. describe:: HEARTBEAT_DT

   The timestep of the ESMF/MAPL internal clock, in seconds. All other
   timesteps in GCHP must be a multiple of :literal:`HEARTBEAT_DT`.
   ESMF queries all components at each heartbeat to determine if
   computation is needed. The result is based upon individual
   component timesteps defined in :ref:`gchp-rc`.

.. describe:: MAPL_ENABLE_TIMERS

   Toggles printed output of runtime MAPL timing profilers. This is
   set to :literal:`YES`. Timing profiles are output at the end of
   every GCHP run in output log file :literal:`allPEs.log`.

.. describe:: MAPL_ENABLE_MEMUTILS

   Enables runtime output of the program's memory usage. This is set
   to :literal:`YES`.

.. describe:: PRINTSPEC

   Allows an abbreviated model run limited to initialize and print of
   Import and Export state variable names. Options include:

   * :literal:`0`: Off (default value)
   * :literal:`1`: Imports and Exports only
   * :literal:`2`: Imports only
   * :literal:`3`: Exports only

.. describe:: USE_SHMEM

   This setting is deprecated but still has an entry in the file.

.. describe:: REVERSE_TIME

   Enables running time backwards in :program:`CAP`. Default is 0
   (off).

.. describe:: USE_EXTDATA2G

   Enables using the next generation of MAPL :program:`ExtData` (input
   component) which uses a yaml-format configuration file. Default is
   :literal:`.FALSE.` (off).
