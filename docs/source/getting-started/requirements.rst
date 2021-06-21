System Requirements
===================

.. _software_requirements:

Software Requirements
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

* HDF5
* NetCDF (with C, C++, and Fortran support)
* ESMF version ≥ 8.0.0

Your system administrator can tell you what software is available and how to activate it. 

If you need to install any of these software yourself, you can do that 
manually (build from source), but it is faster and easier to do it with Spack. See 
our guide on :ref:`installing GCHP's dependencies with Spack <installing_with_spack>`.

.. _hardware_requirements:

Hardware Requirements
---------------------

These are GCHP's hardware requirements. Note that high-end HPC infrastructure is not required to use
GCHP effectively. Gigabit Ethernet and 2 nodes is enough for returns on performance compared to
GEOS-Chem Classic.

Recommended Minimum Requirements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These recommended minimums are adequate to effectively use GCHP in scientific
applications:

* 2 nodes, preferably ≥24 cores per node
* Gigabit Ethernet (GbE) interconnect or better
* 100 GB memory per node
* 1 TB of storage

Bare Minimum Requirements
^^^^^^^^^^^^^^^^^^^^^^^^^

These bare minimum requirements are sufficient for running GCHP at C24. The are adequate 
for try GCHP out, and for learning purposes.

* 6 cores
* 32 GB of memory
* 100 GB of storage for input and output data

Big Compute Recommendations
^^^^^^^^^^^^^^^^^^^^^^^^^^^

These hardware recommendations are for users that are interested in tackling large bleeding-edge
computational problems:

* A high-performance-computing cluster (or a cloud-HPC service like AWS)

   * 1--50 nodes
   * >24 cores per node (the more the better), preferably Intel Xeon
   * High throughput and low-latency interconnect, preferably InfiniBand if using ≥500 cores

* Lots of storage. Several TB is sufficient, but tens or hundreds of TB is better.

