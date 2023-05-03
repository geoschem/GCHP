System Requirements
===================

.. _software_requirements:

Software Requirements
---------------------

To build and run GCHP your compute :term:`environment` needs the following software:

* Git
* Make (or GNUMake)
* CMake version ≥ 3.13
* Compilers (C, C++, and Fortran):

   * Intel compilers version ≥ 19, or
   * GNU compilers version ≥ 10

* MPI (Message Passing Interface)

   * OpenMPI ≥ 4.0, or
   * IntelMPI, or
   * MVAPICH2, or
   * MPICH, or
   * other MPI libraries might work too

* HDF5
* NetCDF (with C, C++, and Fortran support)
* Earth System Modeling Framework (ESMF) version ≥ 8.1.0

Your system administrator should be able to tell you if this software is already available on your cluster, and if so, how to activate it.
If it is not already available, they might be able to build it for you.
If you need to build GCHP's dependencies yourself, see the supplemental guide for building required software with Spack.

Installing ESMF
^^^^^^^^^^^^^^^

If you have all of the needed libraries except ESMF then you can download and build ESMF yourself.
The ESMF git repository is available to clone from `github.com/esmf-org/esmf <https://github.com/esmf-org/esmf>`_. Use :code:`git tag` to browse versions available and then :code:`git checkout tags/tag_name` to checkout the version. 

Once downloaded, browse file :file:`ESMF/README` for information about build requirements.
ESMF requires that you define environment variables :file:`ESMF_COMPILER`, :file:`ESMF_COMM`, and :file:`ESMF_DIR` (path to clone), and also export environment variables :file:`CC`, :file:`CXX`, :file:`FC`, and :file:`MPI_ROOT`.
Set up an environment file that loads the needed libraries and also defines these environment variables.
Here is an example of what the variable exports might look line in your environment file:

.. code-block:: console

   export CC=gcc
   export CXX=g++
   export FC=gfortran
   export MPI_ROOT=${MPI_HOME}
   export ESMF_COMPILER=gfortran
   export ESMF_COMM=openmpi
   export ESMF_DIR=/home/ESMF/ESMF_8_0_1

You can create multiple ESMF builds, for example if you want to try different compilers. To set yourself up to allow this also export environment variable :file:`ESMF_INSTALL_PREFIX` and define it as a subdirectory within :file:`ESMF_DIR`. For example:

.. code-block:: console

   export ESMF_INSTALL_PREFIX=${ESMF_DIR}/INSTALL_gfortran10.2_openmpi4.1

To prepare your environment file for use with GCHP as well simply add the following:

.. code-block:: console

   export ESMF_ROOT=${ESMF_INSTALL_PREFIX}

Once you are ready to build execute the following commands:

.. code-block:: console

   $ source path_to/your/env/file
   $ cd $ESMF_DIR
   $ make &> compile.log

Once compilation completes check the end of :file:`compile.log` to see if compilation was successful.
If it was a success then continue as follows:

.. code-block:: console

   $ make install &> install.log

Check the end of file :file:`install.log`.
A message that installation was complete should be there if ESMF installation was a success.

If all went well there should now be a folder in the top-level ESMF directory corresponding to what you defined as environment variable :file:`ESMF_INSTALL_PREFIX`.
Archive your compile and install logs to that directory.

.. code-block:: console

   $ mv compile.log $ESMF_INSTALL_PREFIX
   $ mv install.log $ESMF_INSTALL_PREFIX

Calling make builds ESMF and calling make install places the build into your install directory.
In that folder the build files are placed within subdirectories such as bin and lib, among others.
The install directory is not deleted when you clean ESMF source code with :code:`make distclean` in the top-level ESMF directory.
Therefore you can clean and rebuild ESMF with different combinations of libraries in advance of needing them to build and run GCHP.
Just remember to clean the source code and source the environment file you intend to use prior to creating a new build.
You also must specify a different :code:`${ESMF_INSTALL_PREFIX}` for each unique build so as not to overwrite others.

.. code-block:: console

$ cd $ESMF_DIR
$ make distclean
$ source path_to_your_env_file_with_unique_ESMF_INSTALL_PREFIX
$ make &> compile.log
$ install $> install.log
$ mv compile.log $ESMF_INSTALL_PREFIX
$ mv install.log $ESMF_INSTALL_PREFIX

.. _hardware_requirements:

Hardware Requirements
---------------------

High-end HPC infrastructure is not required to use GCHP effectively.
Gigabit Ethernet and two nodes is enough for returns on performance compared to
GEOS-Chem Classic.

Bare Minimum Requirements
^^^^^^^^^^^^^^^^^^^^^^^^^

* 6 cores
* 32 GB of memory
* 100 GB of storage for input and output data

Running GCHP on one node with as few as six cores is possible but we recommend this only for testing short low resolution runs such as running GCHP for the first time and for debugging.
These bare minimum requirements are sufficient for running GCHP at C24.
Please note that we recommend running at C90 or greater for scientific applications.

Recommended Minimum Requirements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* 2 nodes, preferably ≥24 cores per node
* Gigabit Ethernet (GbE) interconnect or better
* 100+ GB memory per node
* 1 TB of storage, depending on your input and output needs

These recommended minimums are adequate to effectively use GCHP in scientific
applications. These runs should be at grid resolutions at or above C90.


Big Compute Recommendations
^^^^^^^^^^^^^^^^^^^^^^^^^^^

* 5--50 nodes, or more if running at C720 (12 km grid)
* >24 cores per node (the more the better), preferably Intel Xeon
* High throughput and low-latency interconnect, preferably InfiniBand if using ≥500 cores
* 1 TB of storage, depending on your input and output needs

These requirements can be met by using a high-performance-computing cluster or a cloud-HPC service like AWS.


General Hardware and Software Recommendations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Hyper-threading may improve simulation throughput, particularly at low core counts

* MPI processes should be bound sequentially across cores and nodes. For example, a simulation using two nodes with 24 processes per node should bind ranks 0-23  on the first node and ranks 24-47 on the second node. This should be the default, but it's worth checking if your performance is lower than expected. With OpenMPI the
  `--report-bindings` argument will show you how processes are ranked and binded.

* If using IntelMPI include the following your environment setup to avoid a run-time error:

.. code-block:: bash

    export I_MPI_ADJUST_GATHERV=3
    export I_MPI_ADJUST_ALLREDUCE=12

* If using OpenMPI and a large number of cores (>1000) we recommend enabling the MAPL o-server functionality for writing restart files, thereby speeding up the model. This is set automatically when executing :file:`setCommonRunSettings.sh` if using over 1000 cores. You can also toggle whether to use it manually in that file.
