Building GCHP's Dependencies
============================

This page has instructions for building the software libraries that are needed to build and run GCHP. 
These instructions are meant for users that need to build the GCHP :term:`dependencies` themself, because GCHP's :ref:`software_requirements` are not available on your cluster.

.. note::
    This is not the only way to build the GCHP dependencies. 
    It is possible to download and compile the source code for each library manually.
    Spack automates this process, thus it is the recommended method.

The general workflow is

#. Install Spack get it ready to be used
#. Install the recommended compiler
#. Build GCHP's dependencies
#. Generate a script that loads these dependencies (this is the script you will :literal:`source` before building/running GCHP in the future)


Step 1: Installing Spack and First-Time Setup
---------------------------------------------

Decide where you want to install Spack. A few details you should consider are:

* this directory will be ~5-20 GB (keep in mind that some clusters limit your :file:`$HOME` to a few GB)
* this directory cannot be moved (needs to be rebuilt if you need to move it in the future)
* if other people are going to use these dependencies, this directory should be in a shared location

The remainder of this tutorial will assume you are installing Spack in :file:`$HOME/gchp_deps`, but the commands are the same regardless of the location you choose.

.. code-block:: console

   gcuser:~$ git clone -c feature.manyFiles=true https://github.com/spack/spack.git  # download Spack
   gcuser:~$ source spack/share/spack/setup-env.sh  # load Spack
   gcuser:~$ spack external find  # find software that is already available

Next, download a copy of the GCHP source code. 
The version should not matter, but it is good practice to use the latest version available. 
The :file:`spack-manifests` subdirectory has files that configure recommended Spack settings for GCHP.

.. code-block:: console

   gcuser:~$ git clone https://github.com/geoschem/GCHP.git  # we need the GCHP/spack subdirectory

Step 2: Install the recommended compiler
----------------------------------------

Next, install the recommended compiler, :literal:`intel-oneapi-compilers`. Note that :file:`GCHP/spack` has files
that configure recommended Spack settings for GCHP.

.. code-block:: console

   gcuser:~$ spack -C GCHP/spack install intel-oneapi-compilers  # install the recommended compiler

This should take a few minutes. Once the package is installed, add it as a compiler.

.. code-block:: console

   gcuser:~$ spack compiler add $(spack location -i intel-oneapi-compilers)/compiler/latest/linux/bin/intel64  # register the compiler with spack

.. note::
    The command :literal:`spack find` list all the packages that are installed.

    The command :literal:`spack compiler list` list the compilers that are registered with Spack. You should see a compiler
    named :literal:`intel@XXXX.XX`, where :literal:`XXXX.XX` is the Intel compiler version that was installed.

Step 3: Build GCHP's dependencies
---------------------------------

The next step is actually building the GCHP dependencies. This will be done a :command:`spack install` command, which has the following syntax

.. code::

   spack <scope-arguments> install <install-spec>

:literal:`<scope-arguments>` is a placeholder for arguments like :literal:`-C GCHP/spack`, which configures recommended Spack settings for use with GCHP.
:literal:`<install-spec>` is a placeholder for the arguments that specify what package to install.

To install the GCHP dependencies, choose one of the following for :literal:`<install-spec>`:

* :literal:`esmf%intel` - **(Recommended)** Default GCHP dependencies, using Intel compilers and Intel MPI.
* :literal:`esmf%intel ^openmpi` - Default GCHP dependencies, using Intel compilers and OpenMPI.

For :literal:`<scope-arguments>`, you should always include :literal:`-C GCHP/spack`. This configures recommended Spack settings for the
GCHP dependencies. Note that :literal:`GCHP/spack` has subdirectories with platform-specific settings for certain platforms like AWS ParallelCluster. 
Check to see if any subdirectories look relevant to you.

The remainder of these instructions will use AWS ParallelCluster as an example, so the commands will use :literal:`-C GCHP/spack -C GCHP/spack/aws-parallelcluster-3.0.1` 
for the :literal:`<scope-arguments>` placeholder.

.. note::
   You can see that packages that will be installed with the :command:`spack spec` command. For example,
   
   
   .. code-block:: console
   
      gcuser:~$ scope_args="-C GCHP/spack -C GCHP/spack/aws-parallelcluster-3.0.1"
      gcuser:~$ install_spec="esmf%intel"
      gcuser:~$ spack ${scope_args} spec -I ${install_spec}
      Input spec
      --------------------------------
       -   esmf%intel
      
      Concretized
      --------------------------------
       -   esmf@8.0.1%intel@2021.5.0~debug~external-lapack+mpi+netcdf~pio~pnetcdf~xerces arch=linux-amzn2-x86_64
       -       ^intel-oneapi-mpi@2021.5.1%gcc@7.3.1+external-libfabric~ilp64 arch=linux-amzn2-x86_64
       -           ^libfabric@1.13.0%gcc@7.3.1~debug~kdreg fabrics=efa,mrail,rxd,rxm,shm,sockets,tcp,udp arch=linux-amzn2-x86_64
       -       ^libxml2@2.9.12%intel@2021.5.0~python arch=linux-amzn2-x86_64
       -           ^libiconv@1.16%intel@2021.5.0 libs=shared,static arch=linux-amzn2-x86_64
       -           ^pkgconf@1.8.0%intel@2021.5.0 arch=linux-amzn2-x86_64
       -           ^xz@5.2.5%intel@2021.5.0~pic libs=shared,static arch=linux-amzn2-x86_64
       -           ^zlib@1.2.11%intel@2021.5.0+optimize+pic+shared arch=linux-amzn2-x86_64
       -       ^netcdf-c@4.8.1%intel@2021.5.0~dap~fsync~hdf4~jna~mpi~parallel-netcdf+pic+shared arch=linux-amzn2-x86_64
       -           ^hdf5@1.12.1%intel@2021.5.0~cxx~fortran+hl~ipo~java~mpi+shared~szip~threadsafe+tools api=default build_type=RelWithDebInfo patches=ee351eb arch=linux-amzn2-x86_64
       -               ^cmake@3.22.2%intel@2021.5.0~doc~ncurses+openssl+ownlibs~qt build_type=Release arch=linux-amzn2-x86_64
       -                   ^openssl@1.0.2k-fips%intel@2021.5.0~docs certs=system arch=linux-amzn2-x86_64
       -           ^m4@1.4.16%intel@2021.5.0+sigsegv arch=linux-amzn2-x86_64
       -       ^netcdf-fortran@4.5.3%intel@2021.5.0~doc+pic+shared arch=linux-amzn2-x86_64
   
   The :command:`spack spec` command is not necessary, but it can be helpful to see exactly what packages will be installed.
   
Run the following command to build all of GCHP dependencies. Note that this may take several hours.

.. code-block:: bash

   gcuser:~$ scope_args="-C GCHP/spack -C GCHP/spack/aws-parallelcluster-3.0.1"
   gcuser:~$ install_spec="esmf%intel"
   gcuser:~$ spack ${scope_args} install ${install_spec}


Step 4: Generate load scripts
---------------------------------

The last step is generating a script that loads the these dependencies. 
This is the file you will :literal:`source` before you build or run GCHP.

.. code-block:: bash

   gcuser:~$ spack ${scope_args} module tcl refresh -y  # regenerate all the modulefiles
   gcuser:~$ spack ${scope_args} module tcl loads -r -p $(pwd)/spack/share/spack/modules/linux-*-x86_64/ intel-oneapi-compilers cmake ${install_spec} > geoschem_deps-$(date +%Y.%m)

You can now load the GCHP dependencies you just built by running

.. code-block:: bash

   gcuser:~$ source geoschem_deps-2022.03  # this loads the the dependencies, you can copy/move this files 

You can copy or move this file to anywhere you want. You do not need the :file:`GCHP` directory any more. The :file:`spack` directory needs to remain where it is. 
