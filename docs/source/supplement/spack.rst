
.. _installing_with_spack:

Building Dependencies with Spack
================================

The `Spack Package Manager <https://spack.io/>`__ may be used to download and build GCHP and all of its required external software depenencies, including
CMake, MPI, ESMF, and NetCDF libraries. The only essential prerequisite for using Spack is a local C/C++/Fortran Compiler such as `GNU Compiler Collection <https://gcc.gnu.org/>`__.
You can use this local compiler to later install a different compiler version through Spack. **GCHP requires GNU Compilers version ≥ 8.3 or Intel compilers version ≥ 18.0.5**.
You must install a newer compiler through Spack if your pre-installed compiler does not meet these requirements.

There are three different ways to use Spack to setup GCHP and/or its dependencies:

* `install individual software dependencies <#installing-individual-dependencies-with-spack>`__
* `install all dependencies in one command <#one-line-install-of-gchp-dependencies-with-spack>`__
* `install both GCHP and all of its dependencies in one command <#one-line-install-of-gchp-and-its-dependencies-with-spack>`__


This page covers each of these options. For any of these options, first follow the instructions below about setting up Spack, configuring compilers in Spack,
and specifying dependencies you already have installed which you would like Spack to use for building GCHP or other dependencies (such as ESMF or Slurm).


Setting up Spack, installing new compilers, and specifying preinstalled dependencies
------------------------------------------------------------------------------------


To begin using Spack, clone the latest version by typing ``git clone https://github.com/spack/spack.git``.
Execute the following commands to initialize Spack's environment (replacing ``/path/to/spack`` with the path of your `spack` directory). 
Add these commands to an environment initialization script for easy reuse.

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


Make sure that spack recognizes your new compiler by typing ``spack compilers``, which should display a list of compilers including GCC 9.3.0.


Setting up and using Intel compilers
####################################

If you would like to use Intel compilers, whether pre-installed on your system or which you would like to install through Spack using an existing license,
follow the instructions for `pre-installed Intel compilers <https://spack.readthedocs.io/en/latest/build_systems/intelpackage.html#integration-of-intel-tools-installed-external-to-spack>`__
or for `Intel compilers you want to install through Spack <https://spack.readthedocs.io/en/latest/build_systems/intelpackage.html#installing-intel-tools-within-spack>`__ on the official Spack documentation site.
In the instructions below, simply replace ``%gcc@9.3.0`` with ``%intel`` to use your Intel compilers to build libraries.


Specifying preinstalled dependencies
************************************

Just as Spack can use an existing compiler on your system, it can also use your existing installations of dependencies for GCHP rather than building new copies.
**This is essential for interfacing your cluster's Slurm with a Spack-built GCHP and its dependencies**. For any preinstalled dependency you want Spack to always use, 
you must specify its path on your system and that you want Spack to always use this preinstalled package rather than building a new version.
The code below shows how to do this by editing ``$HOME/.spack/packages.yaml`` (you may need to create this file):

.. code-block:: yaml

   packages:
    slurm:
     paths:
      slurm: /path/to/slurm
     buildable: False



Installing individual dependencies with Spack
---------------------------------------------

This section describes how to use Spack to build GCHP's individual dependencies. While these dependencies can be used to then install GCHP directly using Spack,
this section is mainly intended for those looking to manually download and compile GCHP as described in the User Guide.


Installing basic dependencies
*****************************


You should now install Git and CMake using Spack:

.. code-block:: console


   $ spack install git@2.17.0%gcc@9.3.0
   $ spack install cmake@3.16.1%gcc@9.3.0


Installing without Slurm support
################################

If you do not intend to use a job scheduler like Slurm to run GCHP, use the following commands to install MPI and NetCDF-Fortran. 
Otherwise, scroll down to see necessary modifications you must make to include Slurm support.


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

 

Installing with Slurm support
#############################


**OpenMPI**

You need to tell Spack to build OpenMPI with Slurm support and to build NetCDF-Fortran with the correct OpenMPI version as a dependency:

.. code-block:: console

   $ spack install openmpi@4.0.4%gcc@9.3.0 +pmi schedulers=slurm
   $ spack install netcdf-fortran%gcc@9.3.0  ^netcdf-c^hdf5^openmpi@4.0.4+pmi schedulers=slurm



You may run into issues building OpenMPI if your cluster has preexisting versions of PMIx that are newer than OpenMPI's internal version. 
OpenMPI will search for and use the newest version of PMIx installed on your system, which will likely cause a crash during build because OpenMPI requires you to build with the same libevent library as was used to build PMIx. 
This information may not be readily available to you, in which case you can tweak the build arguments for OpenMPI to always use OpenMPI's internal version of PMIx. 
Open ``$SPACK_ROOT/var/spack/repos/builtin/packages/openmpi/package.py`` and navigate to the ``configure_args()`` function. In the body of this function, place the following line:

.. code-block:: python

      config_args.append('--with-pmix=internal')




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



Once you've installed all of your dependencies, you can follow the GCHP instructions for downloading, compiling, and setting up a run directory in the User Guide
section of this Read The Docs site.

One-line install of GCHP dependencies with Spack
------------------------------------------------


Rather than using Spack to install individual dependencies, you can use the ``spack install --only dependencies gchp`` command to install every
dependency for GCHP in a single command. The ``--only dependencies`` option tells Spack to build GCHP's dependencies without building GCHP itself.


Spack is smart about choosing compatible versions for all of GCHP's different dependencies. You can further specify which package versions or MPI
implementations (OpenMPI, Intel MPI, or MVAPICH2) you wish to use by appending options to ``spack install --only dependencies gchp``, such as ``^openmpi@4.0.4`` or ``^intel-mpi``.
If you wish to use Slurm with GCHP and want Spack to install a new version of OpenMPI or MVAPICH2, you need to specify ``+pmi schedulers=slurm`` (for OpenMPI) or ``process_managers=slurm``
(for MVAPICH2). A full install line for all of GCHP's dependencies, including Slurm-enabled OpenMPI, would look like ``spack install --only dependencies gchp ^openmpi +pmi schedulers=slurm``.


Once you've installed all of your dependencies, you can follow the GCHP instructions for downloading, compiling, and setting up a run directory in the User Guide
section of this Read The Docs site.

One-line install of GCHP and its dependencies with Spack
--------------------------------------------------------


You can use Spack to install all of GCHP's dependencies and GCHP itself in a single line: ``spack install gchp``. Just as when installing only GCHP's dependencies, you
can modify this command with further options for GCHP's dependencies (and should do so if you intend to use a job scheduler like Slurm).

Spack is smart about choosing compatible versions for all of GCHP's different dependencies. You can further specify which package versions or MPI
implementations (OpenMPI, Intel MPI, or MVAPICH2) you wish to use by appending options to ``spack install gchp``, such as ``^openmpi@4.0.4`` or ``^intel-mpi``.
If you wish to use Slurm with GCHP and want Spack to install a new version of OpenMPI or MVAPICH2, you need to specify ``+pmi schedulers=slurm`` (for OpenMPI) or ``process_managers=slurm``
(for MVAPICH2). A full install line for GCHP and all of its dependencies, including Slurm-enabled OpenMPI, would look like ``spack install gchp ^openmpi +pmi schedulers=slurm``.

In addition to specifying options for GCHP's dependencies, GCHP also has its own options you can specify in your ``spack install gchp`` command. The available options 
(which you can view for yourself using ``spack info gchp``) include:


* ``apm``          - APM Microphysics (Experimental) (Default: off)
* ``build_type``   - Choose CMake build type (Default: RelWithDebInfo)
* ``ipo``          - CMake interprocedural optimization (Default: off)
* ``luo``          - Luo et al 2019 wet deposition scheme (Default: off)
* ``omp``          - OpenMP parallelization (Default: off)
* ``real8``        - REAL\*8 precision (Default: on)
* ``rrtmg``        - RRTMG radiative transfer model (Default: off)
* ``tomas``        - TOMAS Microphysics (Experimental) (Default: off)


To specify any of these options, place it directly after ``gchp`` with a ``+`` to enable it or a ``~`` to disable it (e.g. ``spack install gchp ~real8 +rrtmg``).


When you run ``spack install gchp``, Spack will build all of GCHP's dependencies and then download and build GCHP itself. The overall process may take a very long time if you
are installing fresh copies of many dependencies, particularly MPI or ESMF. Once the install is completed, Spack will leave you with a built ``gchp`` executable and a copy of GCHP's
source code at ``spack location -i gchp``. 


You can use Spack's included copy of the source code to create a run directory. Navigate to the directory returned by ``spack location -i gchp``, and then ``cd`` to ``source_code/run``.
Run ``./createRunDir.sh`` to generate a GCHP run directory. Once you've created a run directory, follow the `instructions on Running GCHP in the User Guide <../user-guide/running.html>`__.

You can find information on loading your environment for running GCHP below.



Loading Spack libraries for use with GCHP and/or ESMF
-----------------------------------------------------

After installing the necessary libraries, place the following in a script that you will run before building/running GCHP (such as ``$HOME/.bashrc`` or a separate environment script)
to initialize Spack and load requisite packages for building ESMF and/or building/running GCHP.


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
    # NOTE: Only needed if you did not install GCHP directly through Spack
    pkgs=(gcc@9.3.0            \
     git@2.17.0           \
     netcdf-fortran@4.5.2 \
     cmake@3.16.1         \
     openmpi@4.0.4        \
     esmf@8.0.1           )

    # Load each Spack package
    for f in ${pkgs[@]}; do
      echo "Loading $f"
      spack load $f
    done
    
    # If you installed GCHP directly through Spack,comment out the above code after "Load Spackages"
    # and uncomment the following line
    #spack load gchp
    
    export MPI_ROOT=$(spack location -i openmpi)
    
    # These lines only needed for building ESMF outside of Spack
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
    # NOTE: Only needed if you did not install GCHP directly through Spack
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
    
    # If you installed GCHP directly through Spack,comment out the above code after "Load Spackages"
    # and uncomment the following line
    #spack load gchp

    # Environment variables only needed for Intel MPI
    export I_MPI_CC=gcc #icc for intel compilers
    export I_MPI_CXX=g++ #icpc for intel compilers
    export I_MPI_FC=gfortran #ifort for intel compilers
    export I_MPI_F77=gfortran #ifort for intel compilers
    export I_MPI_F90=gfortran #ifort for intel compilers
    export MPI_ROOT=$(spack location -i intel-mpi)

    export I_MPI_PMI_LIBRARY=/path/to/slurm/libpmi2.so #when using srun through Slurm
    #unset I_MPI_PMI_LIBRARY #when using mpirun

    # These lines only needed for building ESMF outside of Spack
    export ESMF_COMPILER=gfortran #intel for intel compilers
    export ESMF_COMM=intelmpi
    
    


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
    # NOTE: Only needed if you did not install GCHP directly through Spack
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
    
    # If you installed GCHP directly through Spack,comment out the above code after "Load Spackages"
    # and uncomment the following line
    #spack load gchp
    
    export MPI_ROOT=$(spack location -i mvapich2)
    
    # These lines only needed for building ESMF outside of Spack
    export ESMF_COMPILER=gfortran #intel for intel compilers
    export ESMF_COMM=mvapich2
    

You can also add other packages you've installed with Spack like ``emacs`` to the ``pkgs`` lists above.


ESMF and your environment file
------------------------------

The following gives some information on building ESMF separately from Spack and provides more environment file examples.


You must load your environment file prior to building and running GCHP.

.. code-block:: console

   $ source /home/envs/gchpctm_ifort18.0.5_openmpi4.0.1.env

If you don't already have ESMF 8.0.0+, you will need to download and build it. You only need to
build ESMF once per compiler and MPI configuration (this includes for ALL users on a cluster!). It
is therefore worth downloading and building somewhere stable and permanent, as almost no users of
GCHP would be expected to need to modify or rebuild ESMF except when adding a new compiler or MPI.
ESMF is available through Spack, and will already be installed if you chose the
``spack install gchp --only dependencies`` or ``spack install gchp`` routes above.
Instructions for manually downloading and building ESMF are available at the GCHP wiki.

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