

Quickstart Guide
================

This quickstart guide assumes your environment satisfies :ref:`GCHP's requirements <software_requirements>`. 
This means you should load a compute environment so that programs like :program:`cmake` and :program:`mpirun`
are available before continuing. If you do not have some of GCHP's software dependencies,
you can find instructions for installing GCHP's external dependencies in our `Spack instructions <../supplement/spack.html>`__.
More detailed instructions on downloading, compiling, and running GCHP can be found in the User Guide.

1. Clone GCHP
-------------

Download the source code:

.. code-block:: console

   gcuser:~$ git clone https://github.com/geoschem/GCHP.git ~/GCHP
   gcuser:~$ cd ~/GCHP

Checkout the GEOS-Chem version that you want to use:

.. code-block:: console

   gcuser:~/GCHP$ git checkout 14.0.0

Initialize and update all the submodules:

.. code-block:: console

   gcuser:~/GCHP$ git submodule update --init --recursive

2. Create a run directory
-------------------------

Navigate to the :file:`run/` subdirectory. 
To create a run directory, run :file:`./createRunDir.sh` and answer the prompts:

.. code-block:: console

   gcuser:~/GCHP$ cd run/
   gcuser:~/GCHP$ ./createRunDir.sh

3. Configure your build
-----------------------

Create a build directory and :command:`cd` into it. 
A good name for this directory is :file:`build/`, and you may put this directory anywhere on your system, such as in the top-level of the source code or in your run directory. 
The GCHP build directory will require 1.4G of storage space. 
In this guide we put it in the source code:

.. code-block:: console

   gcuser:~/GCHP$ mkdir ~/GCHP/build
   gcuser:~/GCHP$ cd ~/GCHP/build

Initialize your build directory by running :program:`cmake`, passing it the path to your source code. 
Make sure you have loaded all libraries required for GCHP prior to this step.

.. code-block:: console

   gcuser:~/GCHP/build$ cmake ~/GCHP

Now you can configure :ref:`build options <gchp_build_options>`. 
These are persistent settings that are saved to your build directory.
A common build option is :literal:`-DRUNDIR`. 
This option lets you specify one or more run directories that GCHP is "installed" to, meaning where the executable is copied, when you do :command:`make install`. 
Configure your build so it installs GCHP to the run directory you created in Step 2:

.. code-block:: console

   gcuser:~/GCHP/build$ cmake . -DRUNDIR="/path/to/your/run/directory"

.. note::
   The :literal:`.` in the :program:`cmake` command above is important. It tells CMake that your current working directory (i.e., :literal:`.`) is your build directory.

If you decide instead to build GCHP in your run directory you can do all of the above in one step making use of the :literal:`CodeDir` symbolic link in the run directory:

.. code-block:: console

   gcuser:/path/to/your/run/directory/build$ cmake ../CodeDir -DRUNDIR=..


4. Compile and install
----------------------

Compiling GCHP takes about 20 minutes, but it can vary depending on your system. 
Next, compile GCHP in parallel using as many cores as are available:

.. code-block:: console

   gcuser:~/GCHP/build$ make -j

Upon successful compilation, install the compiled executable to your run directory (or directories):

.. code-block:: console

   gcuser:~/GCHP/build$ make install

This copies :file:`bin/gchp` and supplemental files to your run directory. 

.. note::
   You can update build settings at any time:
   
   1. Navigate to your build directory.
   2. Update your build settings with :program:`cmake`.
   3. Recompile with :command:`make -j`. Note that the build system automatically figures out what (if any) files need to be recompiled.
   4. Install the rebuilt executable with :command:`make install`.


5. Configure your run directory
-------------------------------

Now, navigate to your run directory:

.. code-block:: console

   $ cd path/to/your/run/directory

Commonly changed simulation settings, such as grid resolution, run duration, and number of cores, are set in :file:`setCommonRunSettings.sh`. 
You should review this file as it explains most settings.
Note that :file:`setCommonRunSettings.sh` is actually a helper script that updates other configuration files. 
You therefore need to run it to actually apply the settings:

.. code-block:: console

   $ vim setCommonRunSettings.sh           # edit simulation settings here
   $ ./setCommonRunSettings.sh             # applies the updated settings

Simulation start date is set in :file:`cap_restart`. 
Run directories come with this file filled in based on date of the initial restart file in subdirectory :file:`Restarts`. 
You can change the start date only if you have a restart file for the new date in :file:`Restarts`. 
A symbolic link called :file:`gchp_restart.nc4` points to the restart file for the date in :file:`cap_restart` and the grid resolution in :file:`setCommonRunSettings.sh`.  
You need to set this symbolic link before running:

.. code-block:: console

   $ ./setRestartLink.sh                   # sets symbolic link to target file in Restarts

If you used an environment file to load libraries prior to building GCHP then you should load that file prior to running. A simple way to make sure you always use the correct combination of libraries is to set the GCHP environment symbolic link :file:`gchp.env` in the run directory:

.. code-block:: console

   $ ./setEnvironment.sh /path/to/env/file # sets symbolic link gchp.env
   $ source gchp.env                       # applies the environment settings


6. Run GCHP
-----------

Running GCHP is slightly different depending on your MPI library (e.g., OpenMPI, Intel MPI, MVAPICH2, etc.) and scheduler (e.g., SLURM, LSF, etc.). 
If you aren't familiar with running MPI programs on your system, see :ref:`Running GCHP <running_gchp>` in the user guide, or ask your system administrator.

Your MPI library and scheduler will have a command for launching MPI programs---it's usually something like :program:`mpirun`, :program:`mpiexec`, or :program:`srun`. 
This is the command that you will use to launch the :program:`gchp` executable.
You'll have to refer to your system's documentation for specific instructions on running MPI programs, but generally it looks something like this:

.. code-block:: console

   $ mpirun -np 6 ./gchp   # example of running GCHP with 6 slots with OpenMPI 

It's recommended you run GCHP as a batch job. 
This means that you write a script (usually bash) that configures and runs your GCHP simulation, and then you submit that script to your local job scheduler (SLURM, LSF, etc.). 
Example job scripts are provided in subdirectory :literal:`./runScriptSamples` in the run directory. 
That folder also includes an example script for running GCHP from the command line.

Several steps beyond running GCHP are included in the example run scripts. These include loading the environment, updating commonly changed run settings, and setting the restart file based on start time and grid resolution.  In addition, the output restart file is moved to the :file:`Restarts` subdirectory and renamed to include start date and grid resolution upon successful completion of the run.

.. note::
   File :file:`cap_restart` is over-written to contain the run end date upon successful completion of a GCHP run. This is done within GCHP and not by the run script. You can then easily submit a new GCHP run starting off where your last run left off. In addition, GCHP outputs a restart file to your run directory called :file:`gcchem_internal_checkpoint`. This file is moved to subdirectory :literal:`Restarts` and renamed to include the date and grid resolution. This is done by the run script and technically is optional. We recommend doing this since it is is good for archiving (restart files will contain date and grid res) and enables use of the :file:`./setRestartLink.sh` script to set the :file:`gchp_restart.nc4` symbolic link.

Those are the basics of using GCHP! 
See the user guide, step-by-step guides, and reference pages for more detailed instructions.
