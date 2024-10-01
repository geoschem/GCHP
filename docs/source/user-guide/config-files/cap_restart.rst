.. _cap-restart:

###########
cap_restart
###########

This file contains a single datetime in :literal:`YYYYMMDD hhmmss`
format.  The datetime specifies the restart file that will be read
from disk at the start of the GCHP simulation.

Let's consider an example.  Say you are going to run a 1-day GCHP
simulation starting at 00 GMT on 2019-07-01.  The
:ref:`set-common-run-settings-sh` script---when run manually, or
called your GCHP run script---will set the datetime in
:file:`cap_restart` to:

.. code-block:: none

   20190701 000000

as this is the starting datetime for the simulation.

GCHP will update the :file:`cap_restart` file upon sucessful
completion so that it now contains the date when the restart file was
last written:

.. code-block:: none

   20190702 000000

This assumes that the next job segment will start on date 2019-07-02.

If you wish to re-run for 2019-07-01, you must change the datetime in
:file:`cap_restart` back to :literal:`20190701 000000`.  Otherwise it
will read the restart file for 2019-07-02.
