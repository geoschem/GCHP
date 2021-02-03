System Requirements
===================

.. _software_requirements:

Software requirements
---------------------

To use GCHP you need a compute environment with the following software:

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

Your system administrator can tell you what software is available and how to activate it. 

If you need to install any of these software yourself, you can do that 
manually (build from source), but it is faster and easier to do it with Spack. See 
our guide on :ref:`installing GCHP's dependencies with Spack <installing_with_spack>`.

.. _hardware_requirements:

Hardware requirements
---------------------

Minimum requirements (C24):

* 6 cores 
* 32 GB of memory
* 100 GB of storage for input and output data

Recommended requirements:

* A high-performance-computing cluster (or a cloud-HPC service like AWS)

   * 1--50 nodes
   * >24 cores per node (the more the better), preferably Intel Xeon
   * High throughput and low-latency interconnect, preferably InfiniBand if using >500 cores

* Lots of storage. Several TB is sufficient, but tens or hundreds of TB is better.

