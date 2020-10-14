Requirements
============

Software requirements
---------------------

The following are GCHP's required dependencies:

* Git
* Fortran compiler (gfortran 8.3 or greater, ifort 18 or greater)
* CMake (version 3.13 or greater)
* NetCDF-C, NetCDF-CXX, NetCDF-Fortran
* MPI (C, C++, and Fortran)
* ESMF (version 8.0.0 or greater)

You must load your environment file prior to building and running GCHP.

.. code-block:: console

   $ source /home/envs/gchpctm_ifort18.0.5_openmpi4.0.1.env

If you don't already have ESMF 8.0.0+, you will need to download and build it. You only need to
build ESMF once per compiler and MPI configuration (this includes for ALL users on a cluster!). It
is therefore worth downloading and building somewhere stable and permanent, as almost no users of
GCHP would be expected to need to modify or rebuild ESMF except when adding a new compiler or MPI.
Instructions for downloading and building ESMF are available at the GCHP wiki.

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

**Environment file example 2**

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