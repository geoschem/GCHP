.. _creating_a_run_directory:

######################
Create a Run Directory
######################

Run directories are created with the :file:`createRunDir.sh` script in
the :file:`run/` subdirectory of the source code. Run directories are
version-specific, so you need to create new run directories for every
GEOS-Chem version. The gist of creating a run directory is simple:
navigate to the :file:`run/` subdirectory, run
:file:`./createRunDir.sh`, and answer the prompts:

.. code-block:: console

   gcuser:~$ cd GCHP/run
   gcuser:~/GCHP/run$ ./createRunDir.sh
   ... <answer the prompts> ...

.. important::
   Use :term:`absolute paths <absolute path>` when responding to prompts.

If you are unsure what a prompt is asking, see their explanations below, or ask a question
on GitHub. After following all prompts a run directory should be created for you with a confirmation message, and, you can move on to the next section.

.. _create_rundir_prompts:

=======================
Explanations of Prompts
=======================

Below are detailed explanations of the prompts in :file:`./createRunDir.sh`.

Enter ExtData path
------------------

The first time you create a GCHP run directory on your system you will
be prompted to register as a GEOS-Chem user. Please provide this
information so that we can track GEOS-Chem user groups around the
world and get to know what GEOS-Chem is used for.

Following registration you will be prompted for a path to GEOS-Chem
shared data directories. The path should include the name of your
:file:`ExtData/` directory and should not contain symbolic links.  The
path you enter will be stored in file :file:`.geoschem/config`
in your home directory as environment variable
:envvar:`GC_DATA_ROOT`.  If that file does not already exist it will
be created for you.  When creating additional run directories you will
only be prompted again if the file is missing or if the path within it
is not valid.

.. code-block:: none

   -----------------------------------------------------------
   Enter path for ExtData:
   -----------------------------------------------------------

Choose a simulation type
------------------------

Enter the integer number that is next to the simulation type you want to use.

.. code-block:: none

     -----------------------------------------------------------
     Choose simulation type:
     -----------------------------------------------------------
       1. Full chemistry
       2. TransportTracers
       3. CO2 w/ CMS-Flux emissions
       4. Tagged O3
       5. Carbon
     >>>

If creating a full chemistry run directory you will be given
additional options. Enter the integer number that is next to the
simulation option you want to run.

.. code-block:: none

   -----------------------------------------------------------
   Choose additional simulation option:
   -----------------------------------------------------------
     1. Standard
     2. Benchmark
     3. Complex SOA
     4. Marine POA
     5. Acid uptake on dust
     6. TOMAS
     7. APM
     8. RRTMG
   >>>

Choose meteorology source
-------------------------

Enter the integer number that is next to the input meteorology source
you would like to use. Note that choosing GEOS-FP or GEOS-IT will
result in additional questions to refine the meteorology inputs you
would like to use from the dataset.

.. code-block:: none

   -----------------------------------------------------------
   Choose meteorology source:
   -----------------------------------------------------------
     1. MERRA-2 (Recommended)
     2. GEOS-FP
     3. GEOS-IT
   >>>

.. attention::

   The convection scheme used to generate archived GEOS-FP meteorology
   files changed from RAS to Grell-Freitas starting 01 June 2020 with
   impact on vertical transport. Discussion and analysis of the impact
   is available at
   https://github.com/geoschem/geos-chem/issues/1409.

   To fix this issue, different GEOS-Chem convection schemes are
   called based on simulation start time. This ensures comparability
   in GEOS-Chem runs using GEOS-FP fields generated using the RAS
   convection scheme and fields generated using Grell-Freitas, but
   only if the simulation does not cross the 01 June 2020 boundary. We
   therefore recommend splitting up GEOS-FP runs in time such that a
   single simulation does not span this date. For example, configure
   one run to end on 01 June 2020 and then use  its output restart to
   start another run on 01 June 2020.. Alternatively consider using
   MERRA2 which was entirely generated with RAS, or GEOS-IT which was
   entirely generated with Grell-Freitas. If you wish to use a GEOS-FP
   meteorology year different from your simulation year please create
   a GEOS-Chem GitHub issue for assistance to avoid accidentally using
   zero convective precipitation flux.

Enter run directory path
------------------------

Enter the target path where the run directory will be stored. You will
be prompted to enter a new path if the one you enter does not exist.

.. code-block:: none

   -----------------------------------------------------------
   Enter path where the run directory will be created:
   -----------------------------------------------------------
   >>>

Enter run directory name
------------------------

Enter the run directory name, or accept the default. You will be
prompted for a new name if a run directory of the same name already
exists at the target path.

.. code-block:: none

   -----------------------------------------------------------
   Enter run directory name, or press return to use default:

   NOTE: This will be a subfolder of the path you entered above.
   -----------------------------------------------------------
   >>>

Enable version control (optional)
---------------------------------

Enter whether you would like your run directory tracked with git
version control.  With version control you can keep track of exactly
what you changed relative to the original settings. This is useful for
trouble-shooting as well as tracking run directory feature changes you
wish to migrate back to the standard model.

.. code-block:: none

   -----------------------------------------------------------
   Do you want to track run directory changes with git? (y/n)
   -----------------------------------------------------------
   >>>

You will then see a message printed to screen about the run directory
created and brief instructions for us. For example:

.. code-block:: none

   Initialized empty Git repository in /n/home/gchp_merra2_fullchem/.git/


   -----------------------------------------------------------
   Created /n/home/gchp_merra2_fullchem

     -- This run directory is set up for simulation start date 20190701
     -- Restart files for this date at different grid resolutions are in the
        Restarts subdirectory
     -- To update start time, edit configuration file cap_restart and
        add or symlink file Restarts/GEOSChem.Restart.YYYYMMDD_HHmmz.cN.nc
        where YYYYMMDD_HHmm is start date and time
     -- Edit other commonly changed run settings in setCommonRunSettings.sh
     -- See build/README for compilation instructions
     -- Example run scripts are in the runScriptSamples subdirectory
     -- For more information visit the GCHP user guide at
        https://readthedocs.org/projects/gchp/


Build KPP-Standalone Box Model (optional)
-----------------------------------------

If you are creating a run directory for a fullchem simulation, the
next (and final) menu will aks you:

.. code-block:: console

   -----------------------------------------------------------
   Do you want to build the KPP-Standalone Box Model? (y/n)
   -----------------------------------------------------------
   >>>

Type :program:`y` and then :command:`ENTER` you wish to build the
:program:`KPP-Standalone Box Model`, or :program:`n` then
:program:`ENTER` to skip this step. If you choose to build
KPP-Standalone, you will be given this reminder:

.. code-block:: console

   >>>> REMINDER: You must compile with options: -DKPPSA=y <<<<

Please see the Supplemental Guide entitled :ref:`kppsa-guide`
for further usage instructions.
