Use GCHP Containers
===================

Containers are an effective method of packaging and delivering GCHP's source code and requisite libraries.
We offer up-to-date Docker images for GCHP `through Docker Hub <https://hub.docker.com/r/geoschem/gchp>`__.
These images contain pre-built GCHP source code and the tools for creating a GCHP run directory.
The instructions below show how to create a run directory and run GCHP using `Singularity <https://sylabs.io/guides/3.0/user-guide/installation.html>`__
, which can be installed using instructions at the previous link or through Spack.
Singularity is a container software that is preferred over Docker for many HPC applications due to security issues.
Singularity can automatically convert and use Docker images.
You can choose to use Docker or Singularity depending on the support of the cluster. 

The workflow for running GCHP using containers is

#. Pull an image (:ref:`described on this page <create_run_directory_using_singularity>`)
#. Create a run directory (:ref:`use pre-built tools <create_run_directory_using_singularity>` or follow :ref:`creating_a_run_directory`)
#. Download input data (:ref:`described on this page <download_data_using_dry_run>` and :ref:`downloading_input_data`)
#. Running GCHP (:ref:`use pre-built tools <setting_up_and_running_gchp_using_singularity>` or follow :ref:`running_gchp`)

Software requirements
---------------------

There are only two software requirements for running GCHP using a Singularity container:

* Singularity itself
* An MPI implementation that matches the type and major/minor version of the MPI implementation inside of the container


Performance
-----------

Because we do not include optimized infiniband libraries within the provided Docker images, container-based GCHP is currently not as fast as other setups. 
Container-based benchmarks deployed on Harvard's Cannon cluster using up to 360 cores at c90 (~1x1.25) resolution averaged 15% slower than equivalent non-container runs. Performance may worsen at a higher core count and resolution.
If this performance hit is not a concern, these containers are the quickest way to setup and run GCHP.

.. _create_run_directory_using_singularity:

Pulling an image and creating run directory using Singularity
---------------------------------------------

Available GCHP images are listed `on Docker Hub <https://hub.docker.com/r/geoschem/gchp/tags?page=1&ordering=last_updated>`__.
The following command pulls the image of GCHP 14.2.0 and converts it to a Singularity image named `gchp.sif` in your current directory.

.. code-block:: console

   $ singularity pull gchp.sif docker://geoschem/gchp:14.2.0


If you do not already have GCHP data directories, create a directory where you will later store data files.
We will call this directory `DATA_DIR` and your run directory destination `WORK_DIR` in these instructions.
Make sure to replace these names with your actual directory paths when executing commands from these instructions


The following command executes GCHP's run directory creation script. Within the container, your `DATA_DIR` and `WORK_DIR` directories
are visible as `/ExtData` and `/workdir`. Use `/ExtData` and `/workdir` when asked to specify your ExtData location and run directory target folder,
respectively, in the run directory creation prompts.

.. code-block:: console

   $ singularity exec -B DATA_DIR:/ExtData -B WORK_DIR:/workdir gchp.sif /bin/bash -c ". ~/.bashrc && /opt/geos-chem/bin/createRunDir.sh"


Once the run directory is created, it will be available at `WORK_DIR` on your host machine. ``cd`` to `WORK_DIR`.

.. _setting_up_and_running_gchp_using_singularity:

Setting up and running GCHP using Singularity
---------------------------------------------

To avoid having to specify the locations of your data and run directories (RUN_DIR) each time you execute a command in the singularity container,
we will add these to an environment file called `~/.container_run.rc` and point the `gchp.env` symlink to this environment file.
We will also load MPI in this environment file (edit the first line below as appropriate to your system).

.. code-block:: console

   $ echo "module load openmpi/4.0.3" > ~/.container_run.rc
   $ echo "export SINGULARITY_BINDPATH=\"DATA_DIR:/ExtData,RUN_DIR:/rundir\"" >> ~/.container_run.rc 
   $ ./setEnvironmentLink.sh ~/.container_run.rc
   $ source gchp.env
   

We will now move the pre-built `gchp` executable and example run scripts to the run directory.


.. code-block:: console

   $ rm runScriptSamples # remove broken link
   $ singularity exec ../gchp.sif cp /opt/geos-chem/bin/gchp /rundir
   $ singularity exec ../gchp.sif cp -rf /gc-src/run/runScriptSamples/ /rundir


Before running GCHP in the container, we need to create an execution script to tell the container to load its internal environment before running GCHP.
We'll call this script `internal_exec`.


.. code-block:: console

   $ echo -e "if [ -e \"/init.rc\" ] ; then\n\t. /init.rc\nfi" > ./internal_exec # no need for versions after 13.4.1
   $ echo "cd /rundir" >> ./internal_exec
   $ echo "./gchp" >> ./internal_exec
   $ chmod +x ./internal_exec


The last change you need to make to run GCHP in a container is to edit your run script (whether from `runScriptSamples/` or otherwise).
Replace the typical execution line in the script (where ``mpirun`` or ``srun`` is called) with the following:

.. code-block:: console

   $ time mpirun singularity exec ../gchp.sif /rundir/internal_exec >> ${log}
   

You can now setup your run configuration as normal using `setCommonRunSettings.sh` and tweak Slurm parameters in your run script.


If you already have GCHP data directories, congratulations! You've completed all the steps you need to run GCHP in a container.
If you still need to download data directories, read on.

.. _download_data_using_dry_run:

Downloading data directories using GEOS-Chem Classic's dry-run option
---------------------------------------------------------------------

GCHP does not currently support automated download of requisite data directories, `unlike GEOS-Chem Classic <http://wiki.seas.harvard.edu/geos-chem/index.php/Downloading_data_with_the_GEOS-Chem_dry-run_option>`__.
Luckily we can use a GC Classic container to execute a dry-run that matches the parameters of our GCHP run to download data files.

.. code-block:: console

   $ #get GC Classic image from https://hub.docker.com/r/geoschem/gcclassic
   $ singularity pull gcc.sif docker://geoschem/gcclassic:13.0.0-alpha.13-7-ge472b62
   $ #create a GC Classic run directory (GC_CLASSIC_RUNDIR) in WORK_DIR that matches 
   $ #your GCHP rundir (72-level, standard vs. benchmark vs. transport tracers, etc.)
   $ singularity exec -B WORK_DIR:/workdir gcc.sif /opt/geos-chem/bin/createRunDir.sh
   $ cd GC_CLASSIC_RUNDIR
   $ #get pre-compiled GC Classic executable
   $ singularity exec -B .:/classic_rundir ../gcc.sif cp /opt/geos-chem/bin/gcclassic /classic_rundir

Make sure to tweak dates of run in geoschem_config.yml as needed, following info `here <http://wiki.seas.harvard.edu/geos-chem/index.php/Downloading_data_with_the_GEOS-Chem_dry-run_option#Executing_GEOS-Chem_in_dry-run_mode>`__.

.. code-block:: console

   $ #create an internal execute script for your container
   $ echo ". /init.rc" > ./internal_exec
   $ echo "cd /classic_rundir" >> ./internal_exec
   $ echo "./gcclassic --dryrun" >> ./internal_exec
   $ chmod +x ./internal_exec
   $ #run the model, outputting requisite file info to log.dryrun
   $ singularity exec -B .:/classic_rundir ../gcc.sif /classic_rundir/internal_exec > log.dryrun

Follow instructions `here <http://wiki.seas.harvard.edu/geos-chem/index.php/Downloading_data_with_the_GEOS-Chem_dry-run_option#Downloading_data_from_dry-run_output>`__ for downloading your relevant data. 
Note that you will still need a restart file for your GCHP run which will not be automatically retrieved by this download script.
