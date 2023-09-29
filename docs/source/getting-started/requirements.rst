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
* Earth System Modeling Framework (ESMF) version 8.4.2 recommended. Problems with 8.1 and prior have been reported.

Your system administrator should be able to tell you if this software is already available on your cluster, and if so, how to activate it.
If it is not already available, they might be able to build it for you.
If you need to build GCHP's dependencies yourself, see the supplemental guide for building required software with Spack.

Installing ESMF
^^^^^^^^^^^^^^^

If you have all of the needed libraries except ESMF then you can download and build ESMF yourself.
The ESMF git repository is available to clone from `github.com/esmf-org/esmf <https://github.com/esmf-org/esmf>`_. Use :code:`git tag` to browse versions available and then :code:`git checkout tags/tag_name` to checkout the version. 

.. code-block:: console

   git clone https://github.com/esmf-org/esmf ESMF
   cd ESMF
   git tag
   git checkout tags/v8.4.1

If you have previously downloaded ESMF you can use your same clone to checkout and build a new ESMF version. Use the same steps as above minus the first step of cloning.

Once you have downloaded ESMF and checked out the version you would like to build, browse the file
:file:`ESMF/README.md` to familiarize yourself with ESMF documentation. You do not need to visit the documentation
for doing a basic build of ESMF following this tutorial. However, if you are interested in learning more about
ESMF and its options then you can use this guide.

ESMF requires that you define environment variables :file:`ESMF_COMPILER`, :file:`ESMF_COMM`, and :file:`ESMF_DIR`,
and also export environment variables :file:`CC`, :file:`CXX`, :file:`FC`, and :file:`MPI_ROOT`.
Set up an environment file that loads the needed libraries and also defines these environment variables.
If you already have a GEOS-Chem environment file set up then you can copy it or repurpose it by including
the environment variables needed for ESMF. Here is an example of what the library load and variable exports
might look line in your environment file. This example uses GNU compilers and OpenMPI, but there are notes in
the comments on how to use Intel instead.

.. code-block:: console

   module purge
   module load gcc/10.2.0-fasrc01             # GNU compiler collection (C, C++, Fortran)
   module load openmpi/4.1.0-fasrc01          # MPI
   module load netcdf-c/4.8.0-fasrc01         # Netcdf-C
   module load netcdf-fortran/4.5.3-fasrc01   # Netcdf-Fortran
   module load cmake/3.25.2-fasrc01           # CMake

   export CC=gcc                         # C compiler (use icx for Intel)
   export CXX=g++                        # C++ compiler (se icx for Intel)
   export FC=gfortran                    # Fortran compiler (use ifort for Intel)
   export MPI_ROOT=${MPI_HOME}           # Path to MPI library
   export ESMF_COMPILER=gfortran         # Fortran compiler (use intel for Intel)
   export ESMF_COMM=openmpi              # MPI (use intelmpi for IntelMPI)
   export ESMF_DIR=/home/ESMF/ESMF       # Path to ESMF repository within a generic directory called ESMF

You can create multiple ESMF builds. This is useful if you want to use different libraries for the same
version of ESMF, or if you want to build different ESMF versions. To set yourself up to allow multiple builds
you should also export environment variable :file:`ESMF_INSTALL_PREFIX` and define it as a subdirectory
within :file:`ESMF_DIR`. Include details about that particular build to distinguish it from others. For example:

.. code-block:: console

   export ESMF_INSTALL_PREFIX=${ESMF_DIR}/INSTALL_ESMF8.4.1_gfortran10.2_openmpi4.1

Using this install in GCHP will require setting :file:`ESMF_ROOT` to the install directory. Add the following
line to your ESMF environment file if you plan on repurposing it for use with GCHP. Otherwise remember to add
it to your GCHP environment file along with the assignment of :file:`ESMF_INSTALL_PREFIX`. 

.. code-block:: console

   export ESMF_ROOT=${ESMF_INSTALL_PREFIX}

Once you are ready to build execute the following commands:

.. code-block:: console

   $ source path/to/your/env/file
   $ cd $ESMF_DIR
   $ make -j &> compile.log

Once compilation completes check the end of :file:`compile.log` to see if compilation was successful.
You may run into known errors with compiling certain ESMF versions with GNU and Intel compilers. If you
run into a problem with GNU you can try adding this to your environment file, resourcing it, and then
rebuilding.

.. code-block:: console

   # ESMF may not build with GCC without the following work-around
   # for a type mismatch error (https://trac.macports.org/ticket/60954)
   if [[ "x${ESMF_COMPILER}" == "xgfortran" ]]; then
      export ESMF_F90COMPILEOPTS="-fallow-argument-mismatch -fallow-invalid-boz"
   fi

If you run into a problem with Intel compilers then try the following.

.. code-block:: console

   # Make sure /usr/bin comes first in the search path, so that the build
   # will find /usr/bin/gcc compiler, which ESMF uses for preprocessing.
   # Also unset the ESMF_F90COMPILEOPTS variable, which is only needed for GNU.
   if [[ "x${ESMF_COMPILER}" == "xintel" ]]; then
      export PATH="/usr/bin:${PATH}"
      unset ESMF_F90COMPILEOPTS
   fi

Once you have a successful run then install ESMF using this command:

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
Therefore you can clean and rebuild ESMF with different combinations of libraries and versions in advance of needing them to build and run GCHP.
Just remember to clean the source code and source the environment file you intend to use prior to creating a new build.
Make sure you specify a different :code:`${ESMF_INSTALL_PREFIX}` for each unique build so as not to overwrite others.

Below is a complete summary of build steps, including cleanup at the end and moving logs files and your environment
file to the install directory for archiving. This is a complete list of command line steps assuming you have a functional
environment file with correct install path and have checked out the version of ESMF you wish to build.

.. code-block:: console

   $ cd $ESMF_DIR
   $ make distclean
   $ source path/to/env/file/with/unique/ESMF_INSTALL_PREFIX
   $ make &> compile.log
   $ install $> install.log
   $ mv compile.log $ESMF_INSTALL_PREFIX
   $ mv install.log $ESMF_INSTALL_PREFIX
   $ cp /path/to/your/env/file $ESMF_INSTALL_PREFIX

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
