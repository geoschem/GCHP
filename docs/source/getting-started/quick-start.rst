.. _quick-start:

################
Quickstart Guide
################

This quickstart guide assumes your environment satisfies the
requirements described in :ref:`System Requirements
<system_requirements>`.  This means you should load a compute
environment so that software like :program:`cmake` and a
fortran compiler are available before continuing. If you do not have
some of GCHP's software dependencies, you can find instructions for
installing GCHP's external dependencies in our `Spack instructions
<../supplement/spack.html>`__.  More detailed instructions on
downloading, compiling, and running GCHP can be found in the User
Guide.

=============
1. Clone GCHP
=============

Download the source code. The :literal:`--recurse-submodules` option
will automatically initialize and update all the submodules:

.. code-block:: console

   $ git clone --recurse-submodules https://github.com/geoschem/GCHP.git ~/GCHP
   $ cd ~/GCHP

Upon download you will have the most recently released version. You can check what this is by printing the last commit in the git log and scanning the output for tag.

.. code-block:: console

   $ git log -n 1

.. tip::

   To use an older GCHP version (e.g. 14.0.0), follow
   these additional steps:

   .. code-block:: console

      $ git checkout tags/14.0.0                  # Points HEAD to the tag "14.0.0"
      $ git branch version_14.0.0                 # Creates a new branch at tag "14.0.0"
      $ git checkout version_14.0.0               # Checks out the version_14.0.0 branch
      $ git submodule update --init --recursive   # Reverts submodules to the "14.0.0" tag

   You can do this for any tag in the version history.   For a list of
   all tags, type:

   .. code-block:: console

      $ git tag

   If you have any unsaved changes, make sure you commit those to a
   branch prior to updating versions.

=========================
2. Create a run directory
=========================

Navigate to the :file:`run/` subdirectory.
To create a run directory, run :file:`./createRunDir.sh` and answer
the prompts:

.. code-block:: console

   $ cd run/
   $ ./createRunDir.sh

.. important::

   The convection scheme used for GEOS-FP met generation changed
   from RAS to Grell-Freitas with impact on GEOS-FP meteorology
   files starting June 1, 2020, specifically enhanced vertical
   transport. If you plan to do simulations across this boundary
   consider using MERRA2 instead. For more information see
   `GEOS-Chem GitHub issue #1409 <https://github.com/geoschem/geos-chem/issues/1409/>`__.

=======================
3. Configure your build
=======================

Building GCHP will require 1.4G of storage space. You may build GCHP
from within the run directory or from anywhere else on your
system. Building from within the run directory is convenient because
it keeps all build files in close proximity to where you will run
GCHP. For this purpose the GCHP run directory includes a build
directory called :file:`build/`. However, you can create a build
directory elsewhere, such as within the GCHP source code. In this
guide we will do both, starting with building from the source code.

.. code-block:: console

   $ mkdir ~/GCHP/build
   $ cd ~/GCHP/build

Initialize your build directory by running :program:`cmake`, passing it the path to your source code.
Make sure you have loaded all libraries required for GCHP prior to this step.

.. code-block:: console

   $ cmake ~/GCHP

Now you can configure :ref:`build options <gchp_build_options>`.
These are persistent settings that are saved to your build directory.
A useful build option is :literal:`-DRUNDIR`.
This option lets you specify one or more run directories that GCHP is
"installed" to, meaning where the executable is copied, when you do
:command:`make install`.  Configure your build so it installs GCHP to
the run directory you created in Step 2.

.. code-block:: console

   $ cmake . -DRUNDIR="/path/to/your/run/directory"

.. note::
   The :literal:`.` in the :program:`cmake` command above is
   important. It tells CMake that your current working directory
   (i.e., :literal:`.`) is your build directory.

If you decide instead to build GCHP in your run directory you can do
all of the above in one step. This makes use of the :literal:`CodeDir`
symbolic link in the run directory:

.. code-block:: console

   $ cd /path/to/your/run/directory/build
   $ cmake ../CodeDir -DRUNDIR=..

GEOS-Chem has a number of optional compiler flags you can add
here. For example, to compile with RRTMG:

.. code-block:: console

   $ cmake ../CodeDir -DRUNDIR=.. -DRRTMG=y

A useful compiler option is to build in debug mode. Doing this is a
good idea if you encountered a segmentation fault in a previous run
and need more information about where the error happened and why.

.. code-block:: console

   $ cmake ../CodeDir -DRUNDIR=.. -DCMAKE_BUILD_TYPE=Debug

See the GEOS-Chem documentation for more information on compiler flags.

======================
4. Compile and install
======================

Compiling GCHP takes about 20 minutes, but it can vary depending on
your system, your compiler, and your compiler flags. To maximize build
speed you should compile GCHP in parallel using as many cores as are
available. Do this with the :literal:`-j` flag:

.. code-block:: console

   $ cd ~/GCHP/build   # Skip if you are already here
   $ make -j

Upon successful compilation, install the compiled executable to your
run directory (or directories):

.. code-block:: console

   $ make install

This copies :file:`bin/gchp` and supplemental files to your run directory.

.. note::
   You can update build settings at any time:

   1. Navigate to your build directory.
   2. Update your build settings with :program:`cmake` (only if they
      differ since your last execution of cmake)
   3. Recompile with :command:`make -j`. Note that the build system
      automatically figures out what (if any) files need to be
      recompiled.
   4. Install the rebuilt executable with :command:`make install`.

If you do not install the executable to your run directory you can
always get the executable from the directory :command:`build/bin`.

===============================
5. Configure your run directory
===============================

Now, navigate to your run directory:

.. code-block:: console

   $ cd /path/to/your/run/directory

Commonly changed simulation settings, such as grid resolution, run
duration, and number of cores, are set in
:file:`setCommonRunSettings.sh`. You should review this file as it
explains most settings. Note that :file:`setCommonRunSettings.sh` is
actually a helper script that updates other configuration files.
You therefore need to run it to actually apply the settings:

.. code-block:: console

   $ vim setCommonRunSettings.sh           # edit simulation settings here
   $ ./setCommonRunSettings.sh             # applies the updated settings

Simulation start date is set in :file:`cap_restart`.  Run directories
come with this file filled in based on date of the initial restart
file in subdirectory :file:`Restarts`.  You can change the start date
only if you have a restart file for the new date in :file:`Restarts`.
A symbolic link called :file:`gchp_restart.nc4` points to the restart
file for the date in :file:`cap_restart` and the grid resolution in
:file:`setCommonRunSettings.sh`.  You need to set this symbolic link
before running:

.. code-block:: console

   $ ./setRestartLink.sh                   # sets symbolic link to target file in Restarts

If you used an environment file to load libraries prior to building
GCHP then you should load that file prior to running. A simple way to
make sure you always use the correct combination of libraries is to
set the GCHP environment symbolic link :file:`gchp.env` in the run
directory:

.. code-block:: console

   $ ./setEnvironment.sh /path/to/env/file # sets symbolic link gchp.env
   $ source gchp.env                       # applies the environment settings

===========
6. Run GCHP
===========

GCHP requires a minimum of 6 processors to run. How to run GCHP is
slightly different depending on your MPI library
(e.g., OpenMPI, Intel MPI, MVAPICH2, etc.) and scheduler (e.g., SLURM,
LSF, etc.). If you aren't familiar with running MPI programs on your
system, see :ref:`Running GCHP <running_gchp>` in the user guide, or
ask your system administrator.

Your MPI library and scheduler will have a command for launching MPI
programs---it's usually something like :program:`mpirun`,
:program:`mpiexec`, or :program:`srun`. This is the command that you
will use to launch the :program:`gchp` executable.  You'll have to
refer to your system's documentation for specific instructions on
running MPI programs, but generally it looks something like this to
run GCHP with the minimum number of processors allowed:

.. code-block:: console

   $ mpirun -np 6 ./gchp   # example of running GCHP with 6 slots with OpenMPI

It's recommended you run GCHP as a batch job.  This means that you
write a script (usually bash) that configures and runs your GCHP
simulation, and then you submit that script to your local job
scheduler (SLURM, LSF, etc.). Example job scripts are provided in
subdirectory :literal:`./runScriptSamples` in the run directory.  That
folder also includes an example script for running GCHP interactively,
meaning without a job scheduler.

Several steps beyond running GCHP are included in the example run
scripts. These include loading the environment, updating commonly
changed run settings, and setting the restart file based on start time
and grid resolution.  In addition, the output restart file is moved to
the :file:`Restarts` subdirectory and renamed to include start date
and grid resolution upon successful completion of the run.

.. note::
   File :file:`cap_restart` is over-written to contain the run end
   date upon successful completion of a GCHP run. This is done within
   GCHP and not by the run script. You can then easily submit a new
   GCHP run starting off where your last run left off. In addition,
   GCHP outputs a restart file to your Restarts directory called
   :file:`gcchem_internal_checkpoint`. This file is renamed by the
   run script (not GCHP) to include the date and grid resolution.
   Since this is done by the run script it is technically is optional.
   However, we recommend doing this since it avoids overwriting your
   restart file upon consecutive runs, is useful for archiving, and
   enables use of the :file:`./setRestartLink.sh` script to set the
   :file:`gchp_restart.nc4` symbolic link, something that is done
   by the run script prior to executing GCHP.

Those are the basics of using GCHP!  See the user guide, step-by-step
guides, and reference pages for more detailed instructions.
