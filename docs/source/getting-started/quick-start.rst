

Quick start
===========

This page gives a brief description of downloading, building, and running GCHP. This quickstart
guide assumes that your environment already satisfies :ref:`GCHP's requirements
<software_requirements>`. This means it assumes you have already loaded software modules
etc. so programs like :program:`cmake` and :program:`mpirun` are available
(along with the rest of GCHP's requirements).

Refer to the user guide for more detailed instructions.

1. Clone GCHP
-------------

Download the GCHP source code.

.. code-block:: console

   $ git clone https://github.com/geoschem/GCHPctm.git ~/GCHPctm
   $ cd ~/GCHPctm

Checkout the version that you want to use.

.. code-block:: console

   $ git checkout 13.0.0

Initialize and update all the submodules.

.. code-block:: console

   $ git submodule update --init --recursive


2. Create a run directory
-------------------------

Navigate to the :file:`run/` subdirectory of the source code. To create a run directory,
use :program:`createRunDir.sh` and follow the prompts.

.. code-block:: console

   $ cd ~/GCHPctm/run
   $ ./createRunDir.sh

3. Configure your build
-----------------------

Create a build directory and :command:`cd` into it. The name doesn't matter but :file:`build/` is a
good choice. A good place to put this directory is in the top-level of the source code.

.. code-block:: console

   $ mkdir ~/GCHPctm/build
   $ cd ~/GCHPctm/build

Configure your build with :program:`cmake`. Pass :program:`cmake` the path to the source code.

.. code-block:: console

   $ cmake ~/GCHPctm

Configure your build to install :program:`geos` to your run directory. You can specify multiple
run directories with a semicolon-separated list.

.. code-block:: console

   $ cmake . -DRUNDIR="/path/to/your/run/directory"


4. Compile and install
----------------------

Compile GCHP with the :program:`make` command.

.. code-block:: console

   $ make -j

Install :program:`geos` to your run directory (or directories). This step copies :file:`bin/geos` to
the directories listed in the :literal:`RUNDIR` CMake variable.

.. code-block:: console

   $ make install

5. Configure your run directory
-------------------------------

Navigate to your run directory. Most simulation settings are configured in the :program:`runConfig.sh` 
script. You edit this file, and others in the directory, to configure
your simulation. Once you have updated these files, run the :program:`runConfig.sh` script.

.. code-block:: console

   $ cd path/to/your/run/directory
   $ vim runConfig.sh               # edit simulation settings here
   $ ./runConfig.sh

6. Run GCHP
-----------

Running GCHP is slightly different depending on your MPI library (e.g., OpenMPI, Intel MPI,
MVAPICH2, etc.) and scheduler (e.g., SLURM, LSF, etc.). If you aren't familiar with running MPI
programs on your system, see :ref:`Running GCHP <running_gchp>` in the user guide, or ask your
system administrator.

Your MPI library and scheduler will have a command for launching MPI programs---it is usually
something like :program:`mpirun`, :program:`mpiexec`, or :program:`srun`. Refer to its documentation
for its usage, but this is the command you use to launch the :program:`geos` executable in your run
directory. For example, with OpenMPI you might do

.. code-block:: console

   $ mpirun -np 6 ./geos   # example for OpenMPI with 6 slots

It's recommended you run GCHP as a batch job. This means that you will write a script that runs GCHP,
and then you will submit that script to your scheduler.

.. note::
   When GCHP runs, either partially or to completion, it outputs a number of files including
   :file:`cap_restart` and :file:`gcchem_internal_checkpoint`. If these files exist when you
   start GCHP, it won't overwrite these, and instead it will exit with an error. Because of this,
   it's common to do

   .. code-block:: console

      $ rm -f cap_restart gcchem_internal_checkpoint

   before starting a GCHP simulation.


Those are the basics of using GCHP! See the user guide, step-by-step guides, and reference pages
for more detailed instructions.