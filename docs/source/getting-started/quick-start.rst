

Quick Start
===========

This quickstart guide assumes your environment satisfies :ref:`GCHP's requirements <software_requirements>`. 
This means you should load a compute environment such that programs like :program:`cmake` and :program:`mpirun`
are available, before continuing. You can find more detailed instructions in the user guide.

1. Clone GCHP
-------------

Download the source code:

.. code-block:: console

   gcuser:~$ git clone https://github.com/geoschem/GCHP.git ~/GCHP
   gcuser:~$ cd ~/GCHP

Checkout the GEOS-Chem version that you want to use:

.. code-block:: console

   gcuser:~/GCHP$ git checkout 13.0.0-beta.1

.. note::
   Version 13 is not officially released yet. Until then, the most recent
   commit to :literal:`main` is the most stable version of GCHP. Therefore,
   we recommend you checkout :literal:`main`, rather than a version
   like :literal:`13.0.0-beta.1`. E.g.:

   .. code-block:: console

      $ git checkout main   # recommended until version 13 is officially released

   Once version 13 is released, we will resume recommending users checkout
   a specific version.

Initialize and update all submodules:

.. code-block:: console

   gcuser:~/GCHP$ git submodule update --init --recursive

2. Create a run directory
-------------------------

Navigate to the :file:`run/` subdirectory. 
Create a run directory by running :file:`./createRunDir.sh` and answering the prompts:

.. code-block:: console

   gcuser:~/GCHP$ cd run/
   gcuser:~/GCHP$ ./createRunDir.sh

3. Configure your build
-----------------------

Create a build directory and :command:`cd` into it. 
A good name for this directory is :file:`build/`, and a good place for it is in the 
top-level of the source code:

.. code-block:: console

   gcuser:~/GCHP$ mkdir ~/GCHP/build
   gcuser:~/GCHP$ cd ~/GCHP/build

Initialize your build directory by running :program:`cmake` and passing it the path to your source code:

.. code-block:: console

   gcuser:~/GCHP/build$ cmake ~/GCHP

Now you can configure :ref:`build options <gchp_build_options>`. 
These are persistent settings that are saved to your build directory.
A common build option is :literal:`-DRUNDIR`. 
This option lets you specify one or more run directories that GCHP is "installed" to when you do :command:`make install`. 
Configure your build so it installs GCHP to the run directory you created in Step 2:

.. code-block:: console

   gcuser:~/GCHP/build$ cmake . -DRUNDIR="/path/to/your/run/directory"

.. note::
   The :literal:`.` in the :program:`cmake` command above is important. It tells CMake that your 
   current working directory (i.e., :literal:`.`) is your build directory.

4. Compile and install
----------------------

Compiling GCHP takes about 20 minutes, but it can varry depending on your system. 
Next, compile GCHP:

.. code-block:: console

   gcuser:~/GCHP/build$ make -j

Next, install the compiled executable to your run directory (or directories):

.. code-block:: console

   gcuser:~/GCHP/build$ make install

This copies :file:`bin/gchp` and supplemental files to your run directory. 

.. note::
   You can update build settings at any time:
   
   1. Navigate to your build directory.
   2. Update your build settings with :program:`cmake`. See 
   3. Recompile with :command:`make -j`. Note that the build system automatically figures out what (if any) files
      need to be recompiled.
   4. Install the rebuilt executable with :command:`make install`.


5. Configure your run directory
-------------------------------

Now, navigate to your run directory:

.. code-block:: console

   $ cd path/to/your/run/directory

Most simulation settings are configured in :file:`./runConfig.sh`. 
You should review this file as it explains how to configure most simulation settings.
Note that :file:`./runConfig.sh` is actually a helper script that updates other configuration files. 
Therefore, you need to run it to actually apply the updates:

.. code-block:: console

   $ vim runConfig.sh               # edit simulation settings here
   $ ./runConfig.sh                 # applies the updated settings

6. Run GCHP
-----------

Running GCHP is slightly different depending on your MPI library (e.g., OpenMPI, Intel MPI,
MVAPICH2, etc.) and scheduler (e.g., SLURM, LSF, etc.). If you aren't familiar with running MPI
programs on your system, see :ref:`Running GCHP <running_gchp>` in the user guide, or ask your
system administrator.

Your MPI library and scheduler will have a command for launching MPI programs---it's usually something like :program:`mpirun`, :program:`mpiexec`, or :program:`srun`. 
This is the command you use to launch the :program:`gchp` executable that is in your run directory. 
You'll need to refer to your system's documentation for specific instructions on running MPI programs,
but generally it looks something like this:

.. code-block:: console

   $ mpirun -np 6 ./gchp   # example of running GCHP with 6 slots with OpenMPI 

It's recommended you run GCHP as a batch job. This means that you will write a script that runs GCHP,
and then you will submit that script to your scheduler.

.. note::
   When GCHP runs, partially or to completion, it generates several files including
   :file:`cap_restart` and :file:`gcchem_internal_checkpoint`. Subsequent runs won't
   overwrite these files, and instead the run will exit with an error. Because of this it is
   common to do

   .. code-block:: console

      $ rm -f cap_restart gcchem_internal_checkpoint

   before starting a GCHP simulation.


Those are the basics of using GCHP! See the user guide, step-by-step guides, and reference pages
for more detailed instructions.