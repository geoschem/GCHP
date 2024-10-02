.. _logging-yml:

###########
logging.yml
###########

The :file:`logging.yml` file is the configuration file for the
pFlogger logging package used in GCHP. This package is a Fortran
logger written and maintained by NASA Goddard. The pFlogger package is
based on python logging and contains functions and classes that enable
flexible event logging within GCHP components, including MAPL ExtData
which handles input read.

GCHP logging is not the same as GEOS-Chem and HEMCO prints that go to
the main GCHP log. It is hierarchical based on the severity of the
event, with the level of severity per component used as criteria to
print to the log file. The logging messages are sent to a separate
file from the main GCHP log. The filename is specified in
:file:`logging.yml` as :file:`allPEs.log` by default in the definition
of the :literal:`mpi_shared` file handler.

Like the python logger, there are five levels of severity used to
trigger messages. These are as follows, in order of most to least
severe:

#. CRITICAL
#. ERROR
#. WARNING
#. INFO
#. DEBUG

These levels are hierarchical, meaning each level triggers writing
messages for all events with greater or equal severity. For example,
if you specify :file:`CRITICAL` you will get only messages triggered
with that criteria since it is the most severe level. If you instead
specify :literal:`WARNING` then you will trigger all events
categorized as :literal:`WARNING`, :literal:`ERROR`, and
:literal:`CRITICAL`.

Different GCHP components can have different levels of severity. These
components are listed in the :literal:`loggers` section of the
file. This helps hone in on problems you are experiencing in a
specific component by allowing you to increase logger messages for one
component only. This is particularly useful for debugging the
component called :literal:`CAP.EXTDATA` in :file:`logging.yml` which
corresponds to the MAPL component that handles reading and regridding
input files. When you experience a problem reading input files we
recommend that you set the logger level for this component to
:file:`DEBUG`.

In addition to setting severity level per component you can also
specify severity level based on processor. There are two options: root
thread only and all threads. The root thread only option is
:file:`root_level` in the configuration file and will only trigger
messages if the event is executed by the root processor. Using
this option keeps the log file size down and can make reading
the file easier. We recommend setting this option to
:literal:`DEBUG` when investigating problems with input files.

The all threads option will log events for all processors. Each
message will be prefixed by the processor number, e.g. :literal:`0000`
for the root thread, :literal:`0001` for the next, and so on. Using
this option can make the file size very large and difficult to
read. However, you can grep the file for a processor number to isolate
events of just one thread of interest, such as the one that appears in
error message traceback.

For more information on the GCHP logger, including more advanced
features, see documentation at
`https://github.com/Goddard-Fortran-Ecosystem/pFlogger/
<https://github.com/Goddard-Fortran-Ecosystem/pFlogger/>`_.
