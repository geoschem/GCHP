System Requirements
===================

.. _software_requirements:

Software requirements
---------------------

To use GCHP you will need a compute environment with the following:

* Git
* Make (or GNUMake)
* CMake version ≥ 3.13
* Compilers (C, C++, and Fortran):

   * Intel compilers version ≥ 18.0.5, or
   * GNU compilers version ≥ 8.3

* MPI (Message Passing Interface)

   * OpenMPI ≥ 3.0, or
   * IntelMPI, or
   * MVAPICH2, or
   * MPICH, or
   * other MPI libraries might work too

* NetCDF (with C, C++, and Fortran support)
* ESMF version ≥ 8.0.0

Your system administrator can tell you what software is available on your cluster and
how you access it. If you need to install any of these software yourself, you can do that 
manually (build from source), but a faster and easier way to do it is with Spack. See 
our guide on :ref:`installing GCHP's dependencies with Spack <installing_with_spack>`.

