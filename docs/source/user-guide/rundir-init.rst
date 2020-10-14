
Creating a run directory
========================

First, make a high-level directory to contain all the run directories associated with this version
of GCHP. This should be somewhere with plenty of space, as all run output will be in subdirectories
of this directory. You can optionally create one or more build directories here for storage and easy
access to GCHP builds specific to a certain version (see previous section on building GCHP).

.. code-block:: console

   $ mkdir /scratch/testruns/GCHP/13.0.0

Next, enter the :file:`run/` subdirectory in :file:`Code.GCHP`. Do not edit this directory - this is the template for
all other run directories! Instead, use the script there to create a new run directory, following
the instructions printed to the screen.


.. code-block:: console

   $ cd Code.GCHP
   $ cd run
   $ ./createRunDir.sh

For example, to create a standard (full-chemistry) run directory, choose (actual responses in brackets):

* Standard simulation (2)
* MERRA2 meteorology (2)
* The directory you just created in step 1 (:file:`/scratch/rundirs/GCHP/13.0.0`)
* A distinctive run directory name (fullchem_first_test)
* Use git to track run directory changes (y)

This will create and set up a full-chemistry, MERRA-2, GCHP run directory in
:file:`/scratch/testruns/GCHP/13.0.0/fullchem_first_test`. Note that these options only affect the run
directory contents, and NOT the build process - the same GCHP executable is usable for almost all
simulation types and supported met data options.

Navigate to your new run directory, and set it up for the first run:

.. code-block:: console

   $ cd /scratch/testruns/GCHP/13.0.0/fullchem_first_test
   $ ./setEnvironment /home/envs/gchpctm_ifort18.0.5_openmpi4.0.1.env # This sets up the gchp.env symlink
   $ source gchp.env # Set up build environment, if not already done
   $ cp runScriptSamples/gchp.run . # Set up run script - your system is likely to be different! See also gchp.local.run.
   $ cp CodeDir/build/bin/geos . # Get the compiled executable
