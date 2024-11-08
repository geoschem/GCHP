.. _cap-restart:

###########
cap_restart
###########

This file contains a single datetime in :literal:`YYYYMMDD hhmmss`
format.  The datetime specifies the restart file that will be read
from disk at the start of the GCHP simulation.  It also overrides the
value of :option:`BEG_DATE` specified in :ref:`cap-rc`.

Let's consider an example.  Say you are going to run a 1-day GCHP
simulation starting at 00 GMT on 2019-07-01.  The
:ref:`set-common-run-settings-sh` script  will set the datetime in
:file:`cap_restart` to:

.. code-block:: none

   20190701 000000

as this is the starting datetime for the simulation.

Upon successful completion of the GCHP simulation, the
:file:`cap_restart` file is updated to contains the date when the
restart was last written (which is the same as the end date of the
previous simulation):

.. code-block:: none

   20190702 000000

If you wish to re-run for 2019-07-01, you must change the datetime in
:file:`cap_restart` back to :literal:`20190701 000000`.  Otherwise,
GCHP will read the restart file for 2019-07-02 once the next
simulation starts.
