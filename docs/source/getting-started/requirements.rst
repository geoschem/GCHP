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

   * OpenMPI ≥ 3.0, or
   * IntelMPI, or
   * MVAPICH2, or
   * MPICH, or
   * other MPI libraries might work too

* HDF5
* NetCDF (with C, C++, and Fortran support)
* ESMF version ≥ 8.1.0

Your system administrator should be able to tell you if this software is already available on your cluster, and if so, how to activate it.
If it is not already available, they might be able to build it for you.

If you need to build GCHP's dependencies yourself, see :ref:`building_gchp_dependencies`.

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
* 1 TB of storage, depending on your input and output needs

Bare Minimum Requirements
^^^^^^^^^^^^^^^^^^^^^^^^^

These bare minimum requirements are sufficient for running GCHP at C24. They are adequate for trying GCHP out, and for learning purposes. Please note that we recommend running at C90 or greater for scientific applications.

* 6 cores
* 32 GB of memory
* 100 GB of storage for input and output data

Big Compute Recommendations
^^^^^^^^^^^^^^^^^^^^^^^^^^^

These hardware recommendations are for users that are interested in tackling large bleeding-edge computational problems:

* A high-performance-computing cluster (or a cloud-HPC service like AWS)

   * 1--50 nodes
   * >24 cores per node (the more the better), preferably Intel Xeon
   * High throughput and low-latency interconnect, preferably InfiniBand if using ≥500 cores

* Lots of storage. Several TB is sufficient, but tens or hundreds of TB is better.

General Hardware and Software Recommendations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Hyper-threading may improve simulation throughput, particularly at low core counts

* MPI process should be bound sequentially across cores and nodes (e.g., a simulation with 48-processes with 24 processes per node 
  should bind rank 0 to CPU L#0, rank 1 to CPU L#1, etc. on the first node, and rank 24 to CPU L#0, rank 1 to CPU L#1, etc. on the 
  second node). This should be the default, but it's worth checking if your performance is lower than expected. With OpenMPI the
  `--report-bindings` argument will show you how processes are ranked and binded.

* If using IntelMPI include the following your environment setup to avoid a run-time error:

.. code-block:: bash

    export I_MPI_ADJUST_GATHERV=3
    export I_MPI_ADJUST_ALLREDUCE=12

* If using OpenMPI and a large number of cores (>1000) we recommend setting :literal:`WRITE_RESTART_BY_OSERVER: YES` in config file :file:`GCHP.rc`. This enables the MAPL o-server functionality for writing restart files, thereby speeding up the mdoel. This is set automatically when executing :file:`setCommonRunSettings.sh`.
