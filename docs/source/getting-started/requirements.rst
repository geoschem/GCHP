System Requirements
===================

Hardware requirements
---------------------

todo

.. _software_requirements:

Software requirements
---------------------

The following are GCHP's required dependencies:

* Git
* Fortran compiler (gfortran 8.3 or greater, ifort 18 or greater)
* CMake (version 3.13 or greater)
* NetCDF-C, NetCDF-CXX, NetCDF-Fortran
* MPI (C, C++, and Fortran)
* ESMF (version 8.0.0 or greater)


These dependencies can come from a number of sources, including from preinstalled modules on your computing cluster.
If you do not have access to preinstalled dependencies, or would like to try different versions of dependencies,
we recommend using the Spack package manager.




Downloading and Installing Software using Spack
-----------------------------------------------

The `Spack Package Manager <https://spack.io/>`__ may be used to download and build CMake, MPI, and NetCDF libraries needed for GCHP. 
You will need to have a C/C++/Fortran compiler such as `GNU Compiler Collection <https://gcc.gnu.org/>`__ available locally before you start. 
You can use this local compiler to later install a different compiler version through Spack. 
The following steps successfully create a GCHP environment using GCC 9.3.0 and OpenMPI 4.0.4 through Spack.
To install different versions of GCC and OpenMPI, simply change the version numbers used in the commands. 
Scroll down for additional info on using IntelMPI, Intel compilers, or MVAPICH2. IntelMPI and MVAPICH2 are free alternative MPI implementations,
while Intel compilers are a paid product for compiling libraries and GCHP.

To begin using Spack, clone the latest version by typing ``git clone https://github.com/spack/spack.git``.
Execute the following commands to initialize Spack's environment (replacing ``/path/to/spack`` with the path of your `spack` directory). Add these commands to an environment initialization script for easy reuse.

.. code-block:: console

   $ export SPACK_ROOT=/path/to/spack
   $ . $SPACK_ROOT/share/spack/setup-env.sh


If you do not already have a copy of your preferred text editor, you can use Spack to install and load one before proceeding (e.g. ``spack install emacs; spack load emacs``). 


Installing compilers
********************

Ensure Spack recognizes any existing compiler on your system by typing ``spack compilers``. You can use this compiler to build a new one. 

Setting up and using GNU compilers
##################################

GNU compilers are free, open source, and easily installable through Spack. Execute the following at the command prompt to install version 9.3.0 of the GNU Compiler Collection:


.. code-block:: console

   $ spack install gcc@9.3.0
   

The ``package@VERSION`` notation is common to all packages in Spack and can be customized to choose different versions. 

The installation of ``gcc`` may take a long time. Once it is complete, you'll need to add it to Spack's list of compilers using the following command:

.. code-block:: console


   $ spack compiler find $(spack location -i gcc@9.3.0)


Setting up and using Intel compilers
####################################

If you would like to use Intel compilers, whether pre-installed on your system or which you would like to install through Spack using an existing license,
follow the instructions for `pre-installed Intel compilers <https://spack.readthedocs.io/en/latest/build_systems/intelpackage.html#integration-of-intel-tools-installed-external-to-spack>`__
or for `Intel compilers you want to install through Spack <https://spack.readthedocs.io/en/latest/build_systems/intelpackage.html#installing-intel-tools-within-spack>`__ on the official Spack documentation site.
In the instructions below, simply replace ``%gcc@9.3.0`` with ``%intel`` to use your Intel compilers to build libraries.


Installing basic dependencies
*****************************

Make sure that spack recognizes your new compiler by typing ``spack compilers``, which should display a list of compilers including GCC 9.3.0.

You should now install Git and CMake using Spack:

.. code-block:: console


   $ spack install git@2.17.0%gcc@9.3.0
   $ spack install cmake@3.16.1%gcc@9.3.0


Installing without Slurm support
################################

If you do not intend to use a job scheduler like Slurm to run GCHP, use the following commands to install MPI and NetCDF-Fortran. Otherwise, scroll down to see necessary modifications you must make to include Slurm support.


**OpenMPI**

.. code-block:: console

      $ spack install openmpi@4.0.4%gcc@9.3.0
      $ spack install netcdf-fortran%gcc@9.3.0 ^netcdf-c^hdf5^openmpi@4.0.4


**Intel MPI**

.. code-block:: console

   $ spack install intel-mpi%gcc@9.3.0
   $ spack install netcdf-fortran%gcc@9.3.0 ^intel-mpi



 **MVAPICH2**

.. code-block:: console

   $ spack install mvapich2%gcc@9.3.0
   $ spack install netcdf-fortran%gcc@9.3.0 ^netcdf-c^hdf5^mvapich2

 
Configuring libraries with Slurm support
########################################
 
If you know the install location of Slurm, edit your spack packages settings at ``$HOME/.spack/packages.yaml`` (you may need to create this file) with the following:

.. code-block:: yaml

   packages:
    slurm:
     paths:
      slurm: /path/to/slurm
     buildable: False

This will ensure that when your MPI library is built with Slurm support requested, Spack will correctly use your preinstalled Slurm rather than trying to install a new version.


**OpenMPI**


You may also run into issues building OpenMPI if your cluster has preexisting versions of PMIx that are newer than OpenMPI's internal version. 
OpenMPI will search for and use the newest version of PMIx installed on your system, which will likely cause a crash during build because OpenMPI requires you to build with the same libevent library as was used to build PMIx. 
This information may not be readily available to you, in which case you can tweak the build arguments for OpenMPI to always use OpenMPI's internal version of PMIx. 
Open ``$SPACK_ROOT/var/spack/repos/builtin/packages/openmpi/package.py`` and navigate to the ``configure_args()`` function. In the body of this function, place the following line:

.. code-block:: python

      config_args.append('--with-pmix=internal')


Building libraries with Slurm support
#####################################


**OpenMPI**

You need to tell Spack to build OpenMPI with Slurm support and to build NetCDF-Fortran with the correct OpenMPI version as a dependency:

.. code-block:: console

   $ spack install openmpi@4.0.4%gcc@9.3.0 +pmi schedulers=slurm
   $ spack install netcdf-fortran%gcc@9.3.0  ^netcdf-c^hdf5^openmpi@4.0.4+pmi schedulers=slurm


**Intel MPI**

No build-time tweaks need to be made to install Intel MPI with Slurm support. 

.. code-block:: console

   $ spack install intel-mpi%gcc@9.3.0
   $ spack install netcdf-fortran%gcc@9.3.0 ^intel-mpi


Scroll down to find environment variables you need to set when running GCHP with Intel MPI, including when using Slurm.

**MVAPICH2**

Like OpenMPI, you must specify that you want to build MVAPICH2 with Slurm support and build NetCDF-Fortran with the correct MVAPICH2 version.

.. code-block:: console

   $ spack install mvapich2%gcc@9.3.0 process_managers=slurm
   $ spack install netcdf-fortran%gcc@9.3.0 ^netcdf-c^hdf5^mvapich2


Loading Spack libraries for use with GCHP and ESMF
**************************************************

After installing the necessary libraries, place the following in a script that you will run before building/running GCHP (such as ``$HOME/.bashrc`` or a separate environment script)
to initialize Spack and load requisite packages for building ESMF and GCHP:


**OpenMPI**

.. code-block:: bash

    export SPACK_ROOT=$HOME/spack #your path to Spack
    source $SPACK_ROOT/share/spack/setup-env.sh
    if [[ $- = *i* ]] ; then
     echo "Loading Spackages, please wait ..."
    fi
    #==============================================================================
    %%%%% Load Spackages %%%%%
    #==============================================================================
    # List each Spack package that you want to load
    pkgs=(gcc@9.3.0            \
     git@2.17.0           \
     netcdf-fortran@4.5.2 \
     cmake@3.16.1         \
     openmpi@4.0.4        )

    # Load each Spack package
    for f in ${pkgs[@]}; do
      echo "Loading $f"
      spack load $f
    done
	
    export MPI_ROOT=$(spack location -i openmpi)
    export ESMF_COMPILER=gfortran #intel for intel compilers
    export ESMF_COMM=openmpi

**IntelMPI**

.. code-block:: bash

    export SPACK_ROOT=$HOME/spack #your path to Spack
    source $SPACK_ROOT/share/spack/setup-env.sh
    if [[ $- = *i* ]] ; then
     echo "Loading Spackages, please wait ..."
    fi
    #==============================================================================
    %%%%% Load Spackages %%%%%
    #==============================================================================
    # List each Spack package that you want to load
    pkgs=(gcc@9.3.0            \
     git@2.17.0           \
     netcdf-fortran@4.5.2 \
     cmake@3.16.1         \
     intel-mpi        )

    # Load each Spack package
    for f in ${pkgs[@]}; do
      echo "Loading $f"
      spack load $f
    done
	
    export MPI_ROOT=$(spack location -i intel-mpi)
    export ESMF_COMPILER=gfortran #intel for intel compilers
    export ESMF_COMM=intelmpi
	
    # Environment variables only needed for Intel MPI
    export I_MPI_CC=gcc #icc for intel compilers
    export I_MPI_CXX=g++ #icpc for intel compilers
    export I_MPI_FC=gfortran #ifort for intel compilers
    export I_MPI_F77=gfortran #ifort for intel compilers
    export I_MPI_F90=gfortran #ifort for intel compilers

    export I_MPI_PMI_LIBRARY=/path/to/slurm/libpmi2.so #when using srun through Slurm
    #unset I_MPI_PMI_LIBRARY #when using mpirun


**MVAPICH2**

.. code-block:: bash

    export SPACK_ROOT=$HOME/spack #your path to Spack
    source $SPACK_ROOT/share/spack/setup-env.sh
    if [[ $- = *i* ]] ; then
     echo "Loading Spackages, please wait ..."
    fi
    #==============================================================================
    %%%%% Load Spackages %%%%%
    #==============================================================================
    # List each Spack package that you want to load
    pkgs=(gcc@9.3.0            \
     git@2.17.0           \
     netcdf-fortran@4.5.2 \
     cmake@3.16.1         \
     mvapich2        )

    # Load each Spack package
    for f in ${pkgs[@]}; do
      echo "Loading $f"
      spack load $f
    done
	
    export MPI_ROOT=$(spack location -i mvapich2)
    export ESMF_COMPILER=gfortran #intel for intel compilers
    export ESMF_COMM=mvapich2
	

You can also add other packages you've installed with Spack like ``emacs`` to the ``pkgs`` lists above.

ESMF and your environment file
------------------------------

You must load your environment file prior to building and running GCHP.

.. code-block:: console

   $ source /home/envs/gchpctm_ifort18.0.5_openmpi4.0.1.env

If you don't already have ESMF 8.0.0+, you will need to download and build it. You only need to
build ESMF once per compiler and MPI configuration (this includes for ALL users on a cluster!). It
is therefore worth downloading and building somewhere stable and permanent, as almost no users of
GCHP would be expected to need to modify or rebuild ESMF except when adding a new compiler or MPI.
Instructions for downloading and building ESMF are available at the GCHP wiki. ESMF may be installable
through Spack in the future.

It is good practice to store your environment setup in a text file for reuse. Below are a couple
examples that load libraries and export the necessary environment variables for building and running
GCHP. Note that library version information is included in the filename for easy reference. Be sure
to use the same libraries that were used to create the ESMF build install directory stored in
environment variable :envvar:`ESMF_ROOT`.

**Environment file example 1**

.. code-block:: bash

   # file: gchpctm_ifort18.0.5_openmpi4.0.1.env

   # Start fresh
   module --force purge

   # Load modules (some include loading other libraries such as netcdf-C and hdf5)
   module load intel/18.0.5
   module load openmpi/4.0.1
   module load netcdf-fortran/4.5.2
   module load cmake/3.16.1

   # Set environment variables
   export CC=gcc
   export CXX=g++
   export FC=ifort

   # Set location of ESMF
   export ESMF_ROOT=/n/lab_shared/libraries/ESMF/ESMF_8_0_1/INSTALL_ifort18_openmpi4

**Environment file example 2 (Spack libraries built with a pre-installed compiler)**

.. code-block:: bash

   # file: gchpctm_gcc7.4_openmpi.rc

   # Start fresh
   module --force purge

   # Load modules
   module load gcc-7.4.0
   spack load cmake
   spack load openmpi%gcc@7.4.0
   spack load hdf5%gcc@7.4.0
   spack load netcdf%gcc@7.4.0
   spack load netcdf-fortran%gcc@7.4.0

   # Set environment variables
   export CC=gcc
   export CXX=g++
   export FC=gfortran

   # Set location of ESMF
   export ESMF_ROOT=/n/home/ESMFv8/DEFAULTINSTALLDIR