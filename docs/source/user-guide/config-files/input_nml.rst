.. _input-nml:

#########
input.nml
#########

:file:`input.nml` controls specific aspects of the FV3 dynamical core
used for advection. Entries in input.nml are described below.

.. option:: &fms_nml

   Header for the FMS namelist which includes all variables directly
   below the header.

.. option:: print_memory_usage

   Toggles memory usage prints to log. However, in practice turning it
   on or off does not have any effect.

.. option:: domain_stack_size

   Domain stack size in bytes. This is set to :literal:`20000000` in
   GCHP to be large enough to use very few cores in a high resolution
   run. If the domain size is too small then you will get an

   .. code-block:: none

      mpp domain stack size overflow error

   in advection. If this happens, try increasing the domain stack size
   in this file.

.. option:: &fv_core_nml

   Header for the finite-volume dynamical core namelist. This is
   commented out by default unless running on a stretched grid. Due to
   the way the file is read, commenting out the header declaration
   requires an additional comment character within the string,
   e.g. :literal:`#&fv#_core_nml`.

.. option:: do_schmidt

   Logical for whether to use Schmidt advection. Set to :literal:`.true.` if
   using stretched grid; otherwise this entry is commented out.

.. option:: stretch_fac

   Stretched grid factor, equal to the ratio of grid resolution in
   targeted high resolution region to the configured run
   resolution. This is commented out if not using stretched grid. It
   is automatically updated based on settings in
   :ref:`set-common-run-settings-sh`.

.. option:: target_lat

   Target latitude of high resolution region if using stretched
   grid. This is commented out if not using stretched grid. It is
   automatically updated based on settings in
   :ref:`set-common-run-settings-sh`.

.. option:: target_lon

   Target longitude of high resolution region if using stretched
   grid. This is commented out if not using stretched grid. It is
   automatically updated based on settings in
   :ref:`set-common-run-settings-sh`.
