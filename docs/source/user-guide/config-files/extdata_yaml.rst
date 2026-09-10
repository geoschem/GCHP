.. _extdata2g:

#############
extdata.yaml
#############

:file:`extdata.yaml` is the configuration file for the
next-generation MAPL :program:`ExtData` component, usually referred to
as **ExtData2G**.  It serves the same purpose as :ref:`extdata-rc` ---
telling GCHP which input variables to read, from which files, and how
to regrid and time-interpolate them --- but uses a YAML format with a
simpler interface.  ExtData2G will replace :ref:`extdata-rc` in GCHP
v15.0, when MAPL version 3 is integrated into GCHP.

.. attention::

   ExtData2G is a **beta** feature.  It is off by default, and
   :file:`extdata.yaml` is only provided for the simulations listed
   below.

Availability
============

:file:`extdata.yaml` is copied into the run directory only for the
TransportTracers and TagO3 simulations.  Other simulations have no
:file:`extdata.yaml` template yet and must use :ref:`extdata-rc`.

The file that is installed is configured for MERRA-2 meteorology at
grid resolutions of C180 or coarser.  If you wish to use another
meteorology source, use mass fluxes, or run at a resolution finer than
C180, you will need to edit :file:`extdata.yaml` yourself so that it
matches the corresponding changes you would have made in
:ref:`extdata-rc`.

Enabling ExtData2G
==================

Set :envvar:`Use_ExtData2G` to :literal:`true` in the
:literal:`MAPL ExtData versions` section of
:ref:`set-common-run-settings-sh`:

.. code-block:: bash

   #------------------------------------------------
   #   MAPL ExtData versions
   #------------------------------------------------
   # Set to true to use ExtData2G in MAPL (requires yaml input file)

   Use_ExtData2G=false

and then execute the script so that it propagates the setting:

.. code-block:: console

   $ ./setCommonRunSettings.sh

This sets :ref:`gchp-rc`'s :literal:`USE_EXTDATA2G` field and
:ref:`cap-rc`'s :literal:`USE_EXTDATA2G` field to :literal:`.true.`,
which is what causes MAPL to read :file:`extdata.yaml` instead of
:ref:`extdata-rc`.  Any value other than :literal:`true` or
:literal:`false` causes :program:`setCommonRunSettings.sh` to exit
with an error.

.. note::

   Enabling ExtData2G also changes where top-down meteorology gets
   flipped.  MAPL itself flips all "top-down" meteorological data to
   "bottom-up" when ExtData2G is in use, so :program:`GCHPctmEnv`
   skips the vertical flip it would otherwise apply.

Further reading
===============

GMAO/NASA documentation for the file format is maintained on the
`ExtData Next Generation User Guide
<https://github.com/GEOS-ESM/MAPL/wiki/ExtData-Next-Generation---User-Guide>`__.
