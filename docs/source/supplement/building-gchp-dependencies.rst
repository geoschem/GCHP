.. _building_gchp_dependencies:

Build Dependencies
==================

This page has instructions for building GCHP's :term:`dependencies`. 
These are the software libraries that are needed to compile and execute the GCHP program.
These instructions are meant for users that are working on a cluster where GCHP's :ref:`software_requirements` are not already available.


.. note::
    This is not the only way to build the GCHP dependencies. 
    It is possible to download and compile the source code for each library manually.
    Spack automates this process, thus it is the recommended method.

The general workflow is the following:

#. Install Spack and perform first-time setup
#. Install the recommended compiler
#. Build GCHP's dependencies
#. Generate a load script (a script that loads the GCHP dependencies in your environment)


1. Install Spack and do first-time setup
----------------------------------------

Decide where you want to install Spack. A few details you should consider are:

* this directory will be ~5-20 GB (keep in mind that some clusters limit :file:`$HOME` to a few GB)
* this directory cannot be moved (needs redo if you need to move it in the future)
* if other people are going to use these dependencies, this directory should be in a shared location

Once you choose an install location, proceed with the commands below. 
You can copy-paste these commands, but lookout for lines marked with a :literal:`# (modifiable) ...` comment as they might require modification.

.. important:: 
   All commands in this tutorial are executed in the same directory.

Install spack and perform the following first-time setup.

.. code-block:: console

   $ cd $HOME  # (modifiable) cd to the install location you chose
   $ git clone -c feature.manyFiles=true https://github.com/spack/spack.git  # download Spack
   $ source spack/share/spack/setup-env.sh  # load Spack
   $ spack external find  # find software that is already available

Next, download a copy of the GCHP source code. 
The GCHP source code has a :file:`spack/` subdirectory with important Spack settings.
The GCHP version should not matter, but it is good practice to use the latest version. 

.. code-block:: console

   $ git clone https://github.com/geoschem/GCHP.git  # we need the GCHP/spack subdirectory

2. Install the recommended compiler
-----------------------------------

Next, install the recommended compiler, :literal:`intel-oneapi-compilers`. 
Note the :literal:`-C GCHP/spack` argument---this specifies custom Spack setting for GCHP.

.. code-block:: console

   $ spack -C GCHP/spack install intel-oneapi-compilers  # install the recommended compiler

This should take a few minutes. Once the package is installed, add it as a compiler.

.. code-block:: console

   $ spack compiler add $(spack location -i intel-oneapi-compilers)/compiler/latest/linux/bin/intel64  # register the compiler with spack

.. note::
   You can run the command :literal:`spack find` to list all the packages that are installed.

   You can run the command :literal:`spack compiler list` to list the registered compilers. 
   After the :command:`spack compiler add` command above, you should see a compiler named :literal:`intel@XXXX.XX`, where :literal:`XXXX.XX` is the compiler version.

3. Build GCHP's dependencies
---------------------------------

The next step is building the GCHP dependencies. This will be done a :command:`spack install` command, which has the following syntax.

.. code::

   spack <scope-arguments> install <install-spec>

:literal:`<scope-arguments>` is a placeholder for arguments like :literal:`-C GCHP/spack`, which configures recommended Spack settings for use with GCHP.
:literal:`<install-spec>` is a placeholder for arguments that specify what package to install.

To install the GCHP dependencies, choose one of the following for :literal:`<install-spec>`:

* :literal:`esmf%intel ^intel-oneapi-mpi` - **(Recommended)** Default GCHP dependencies, using Intel compilers and Intel MPI.
* :literal:`esmf%intel ^openmpi` - Default GCHP dependencies, using Intel compilers and OpenMPI.

For :literal:`<scope-arguments>`, you should always include :literal:`-C GCHP/spack`. This configures settings for the
GCHP dependencies. Note that :literal:`GCHP/spack` has subdirectories with platform-specific settings for certain platforms (e.g., AWS ParallelCluster). 
Check to see if any subdirectories look relevant to you.

The remainder of these instructions use AWS ParallelCluster as an example, so the commands use :literal:`-C GCHP/spack -C GCHP/spack/aws-parallelcluster-3.0.1` for :literal:`<scope-arguments>`.
If no subdirectories are relevant to you, just use :literal:`-C GCHP/spack`.

.. note::
   You can see that packages that will be installed with the :command:`spack spec` command. For example,
   
   
   .. code-block:: console
   
      $ scope_args="-C GCHP/spack -C GCHP/spack/aws-parallelcluster-3.0.1"  # (modifiable) see description of <scope-arguments>
      $ install_spec="esmf%intel ^intel-oneapi-mpi"  # (modifiable) see description of <install-spec>
      $ spack ${scope_args} spec -I ${install_spec}
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
   
The following commands build the GCHP dependencies. Note that this may take several hours.

.. code-block:: console

   $ scope_args="-C GCHP/spack -C GCHP/spack/aws-parallelcluster-3.0.1" # (modifiable) see description of <scope-arguments>
   $ install_spec="esmf%intel ^intel-oneapi-mpi"  # (modifiable) see description of <install-spec>
   $ spack ${scope_args} install ${install_spec}


4. Generate a load script
------------------------------

The last step is generating a script that loads the these dependencies. 
This is a file that you will :literal:`source` before you build or run GCHP.
The following commands generate a script called :literal:`geoschem_deps-YYYY.MM` where :literal:`YYYY.MM` is the current year and month.

.. code-block:: console

   $ load_script_name="geoschem_deps-$(date +%Y.%m)"  # (modifiable) rename if you want to
   $ spack ${scope_args} module tcl refresh -y  # regenerate all the modulefiles
   $ spack ${scope_args} module tcl loads -r -p $(pwd)/spack/share/spack/modules/linux-*-x86_64/ intel-oneapi-compilers cmake > ${load_script_name}
   $ spack ${scope_args} module tcl loads -r -p $(pwd)/spack/share/spack/modules/linux-*-x86_64/ ${install_spec} >> ${load_script_name}

For me, this generated a load script named :file:`geoschem_deps-2022.03`.
In terminals or scripts you can load the GCHP dependencies by running:

.. code-block:: console

   $ source /YOUR_PATH_TO/geoschem_deps-2022.03  # loads the the dependencies (replace YOUR_PATH_TO)

You can copy or move the load script to other directories. At this point, you can remove the :file:`GCHP` directory as it is not needed.
The :file:`spack` directory needs to remain. 
