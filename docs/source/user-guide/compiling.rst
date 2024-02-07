.. note::
   Compiling GCHP and creating a run directory are independent steps, and their order doesn't matter. A small exception
   is the :ref:`RUNDIR <build_setting_rundir>` build option, which controls the behaviour of :command:`make install` which copies the GCHP executable to the run directory;
   however, this setting can be reconfigured at any time (e.g., after compiling and creating a run directory). 
   
   Here in the User Guide we describe compiling GCHP before we describe creating a run directory. This is
   so that conceptually the instructions have a linear flow. The Quickstart Guide, on the other hand, shows how to make a run directory prior to compiling.

.. note::
   Another resource for GCHP build instructions is our `YouTube tutorial <https://www.youtube.com/watch?v=G_DMCv-mJ2k>`_.

.. _building_gchp:

Compile
=======

There are three steps to building GCHP. The first is configuring your build, which is done with :program:`cmake`; 
the second step is compiling, which is done with :program:`make`. The third step is install, which is also done with :program:`make`.

In the first step (build configuration), :program:`cmake` finds GCHP's :ref:`software dependencies <software_requirements>`
on your system, and you can set :ref:`build options <gchp_build_options>` like
enabling/disabling components (such as RRTMG), setting paths to run directories, picking between debug or speed-optimizing compiler
flags, etc. The second step (running :program:`make`) compiles GCHP according your build configuration. The third step copies GCHP executable to an appropriate location, such as one or more run directories if you specify them.

.. important::
   These instructions assume you have loaded a computing environment that satisfies
   :ref:`GCHP's software requirements <software_requirements>` You can find instructions for building GCHP's
   dependencies yourself in the `Spack instructions <../supplement/spack.html>`__.

Create a build directory
------------------------

A build directory is the working directory for a "build". Conceptually, a "build" is a case/instance of
you compiling GCHP. A build directory stores configuration files and intermediate files related to the build. 
These files and generated and used by CMake, Make, and compilers. You can think a 
build directory like the blueprints for a construction project.

Create a new directory and initialize it as a build directory by running CMake.
When you initialize a build directory, the path to the source code is a required
argument:

.. code-block:: console
   
   gcuser:~$ cd ~/Code.GCHP
   gcuser:~/Code.GCHP$ mkdir build              # create a new directory
   gcuser:~/Code.GCHP$ cd build
   gcuser:~/Code.GCHP/build$ cmake ~/Code.GCHP  # initialize the current dir as a build dir
   -- The Fortran compiler identification is GNU 9.2.1
   -- The CXX compiler identification is GNU 9.2.1
   -- The C compiler identification is GNU 9.2.1
   -- Check for working Fortran compiler: /usr/bin/f95
   -- Check for working Fortran compiler: /usr/bin/f95  -- works
   ...
   -- Configuring done
   -- Generating done
   -- Build files have been written to: /src/build
   gcuser:~/Code.GCHP/build$ 

If your :program:`cmake` output is similar to the snippet above, and it says configuring &
generating done, then your configuration was successful and you can move on to :ref:`compiling
<compiling_gchp>` or :ref:`modifying build settings <modify_build_settings>`. If you got an error,
don't worry, that just means the automatic configuration failed. To fix the error you might need
to tweak settings with more :program:`cmake` commands, or you might need to modify your
environment and run :program:`cmake` again to retry the automatic configuration. 


If you want to restart configuring your build from scratch, delete your build directory.
Note that the name and location of your build directory doesn't matter, but a good
name is :file:`build/`, and a good place for it is the top-level of your source code.

Resolving initialization errors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your last step was successful, :ref:`skip this section <compiling_gchp>`. 

Even if you got a :program:`cmake` error, your build directory was initialized. This means
from now on, you can check if the configuration is fixed by running 

.. code-block:: console
   
   gcuser:~/Code.GCHP/build$ cmake .    # "." because the cwd is the build dir

To resolve your errors, you might need to modify your environment (e.g., load different software modules),
or give CMake a hint about where some software is installed. Once you identify the problem and make 
the appropriate update, run :program:`cmake .` to see if the error is fixed.

To start troubleshooting, read the :program:`cmake` output in full. It is human-readable, and
includes important information about how the build was set up on your system, and specifically what
error is preventing a successful configuration (e.g., a dependency that wasn't found, or a compiler
that is broken). To begin troubleshooting you should check that:

* check that the compilers are what you expect (e.g., GNU 9.2, Intel 19.1, etc.)
* check that dependencies like MPI, HDF5, NetCDF, and ESMF were found
* check for obvious errors/incompatibilities in the paths to "Found" dependencies

.. note::
    F2PY and ImageMagick are not required. You can safely ignore warnings about them not being
    found.


Most errors are caused by one or more of the following issues:

* The wrong compilers were chosen. Fix this by explicitly setting the compilers.
* The compiler's version is too old. Fix this by using newer compilers.
* A software dependency is missing. Fix this by loading the appropriate software. Some hints:

   * If HDF5 is missing, does :program:`h5cc -show` or :program:`h5pcc -show` work?
   * If NetCDF is missing, do :program:`nc-config --all` and :program:`nf-config --all` work?
   * If MPI is missing, does :program:`mpiexec --help` work?
  
* A software dependency is loaded but it wasn't found automatically. Fix this by pointing CMake to the
  missing software/files with :program:`cmake . -DCMAKE_PREFIX_PATH=/path/to/missing/files`.

   * If ESMF is missing, point CMake to your ESMF install with :option:`-DCMAKE_PREFIX_PATH`

* Software modules that are not compatible. Fix this by loading compatible modules/dependencies/compilers. Some hints:
   
   * This often shows as an error message saying a compiler is "broken" or "doesn't work"
   * E.g. incompatibility #1: you're using GNU compilers but HDF5 is built for Intel compilers
   * E.g. incompatibility #2: ESMF was compiled for a different compiler, MPI, or HDF5

If you are stumped, don't hesitate to open an issue on GitHub. Your system administrators might 
also be able to help. Be sure to include :file:`CMakeCache.txt` from your build directory, as it contains 
useful information for troubleshooting.

.. note:: 
   If you get a CMake error saying "Could not find XXXX" (where XXXX is a dependency like
   ESMF, NetCDF, HDF5, etc.), the problem is that CMake can't automatically find where that library 
   is installed. You can add custom paths to CMake's default search list by setting the 
   :literal:`CMAKE_PREFIX_PATH` variable.

   For example, if you got an error saying "Could not find ESMF", and ESMF is installed
   to :file:`/software/ESMF`, you would do

   .. code-block:: console
      
      gcuser:~/Code.GCHP/build$ cmake . -DCMAKE_PREFIX_PATH=/software/ESMF
      ...
      -- Found ESMF: /software/ESMF/include (found version "8.1.0")
      ...
      -- Configuring done
      -- Generating done
      -- Build files have been written to: /src/build
      gcuser:~/Code.GCHP/build$ 
    
   See the next section for details on setting variables like :literal:`CMAKE_PREFIX_PATH`.

.. note::
   You can explicitly specify compilers by setting the :envvar:`CC`, :envvar:`CXX`, and :envvar:`FC` environment
   variables. If the auto-selected compilers are the wrong ones, create a brand new build directory, 
   and set these variables before you initialize it. E.g.:

   .. code-block:: console
      
      gcuser:~/Code.GCHP/build$ cd ..
      gcuser:~/Code.GCHP$ rm -rf build   # build dir initialized with wrong compilers
      gcuser:~/Code.GCHP$ mkdir build    # make a new build directory
      gcuser:~/Code.GCHP$ cd build
      gcuser:~/Code.GCHP/build$ export CC=icc      # select "icc" as C compiler
      gcuser:~/Code.GCHP/build$ export CXX=icpc    # select "icpc" as C++ compiler
      gcuser:~/Code.GCHP/build$ export FC=icc      # select "ifort" as Fortran compiler
      gcuser:~/Code.GCHP/build$ cmake ~/Code.GCHP  # initialize new build dir
      -- The Fortran compiler identification is Intel 19.1.0.20191121
      -- The CXX compiler identification is Intel 19.1.0.20191121
      -- The C compiler identification is Intel 19.1.0.20191121
      ...

.. _modify_build_settings:   

Configure your build
--------------------

Build settings are controlled by :program:`cmake` commands like:

.. code-block:: none

    $ cmake . -D<NAME>="<VALUE>"

where :literal:`<NAME>` is the name of the setting, and :literal:`<VALUE>` is the
value you are assigning it. These settings are persistent and saved in your build directory.
You can set multiple variables in the same command, and you can run :program:`cmake` as many times
as needed to configure your desired settings.

.. note:: 
   The :literal:`.` argument is important. It is the path to your build directory which
   is :literal:`.` here.

No build settings are required. You can find the complete list of :ref:`GCHP's build settings here <gchp_build_options>`.
The most common setting is :literal:`RUNDIR`, which lets you specify one or more run directories
to install GCHP to. Here, "install" refers to copying the compiled executable, and some supplemental files
with build settings, to your run directory/directories.

.. note::
    You can update build settings after you compile GCHP. Simply rerun :program:`make` and
    (optionally) :program:`make install`, and the build system will automatically figure out
    what needs to be recompiled.

Since there are no required build settings, so here, we will stick with the default settings. 

You should notice that when you run :program:`cmake` it ends with:

.. code-block:: console
   
   ...
   -- Configuring done
   -- Generating done
   -- Build files have been written to: /src/build

This tells you that the configuration was successful, and that you are ready to compile. 

.. _compiling_gchp:

Compile GCHP
------------

You compile GCHP with:

.. code-block:: console
   
   gcuser:~/Code.GCHP/build$ make -j   # -j enables compiling in parallel

.. note::
   You can add :literal:`VERBOSE=1` to see all the compiler commands.

.. note::
    If you run out of memory while compiling, restrict the number of processes that can
    run concurrently (e.g., use :option:`-j20` to restrict to 20 processes)

Compiling GCHP creates :file:`./bin/gchp` (the GCHP executable). You can copy
this executable to your run directory manually, or if you set the :ref:`RUNDIR <build_setting_rundir>` build option,
you can do

.. code-block:: console
   
   gcuser:~/Code.GCHP/build$ make install  # Requires that RUNDIR build option is set

to copy the executable (and supplemental files) to your run directories.

Now you have compiled GCHP! You can move on to creating a run directory!

------------

Recompiling
-----------

You need to recompile GCHP if you update a build setting or modify the source code.
With CMake, you do not need to clean before recompiling. The build system automatically 
figures out which files need to be recompiled (it's usually a small subset). This is known as incremental compiling.

To recompile GCHP, simply do 

.. code-block:: console
   
   gcuser:~/Code.GCHP/build$ make -j   # -j enables compiling in parallel

and then optionally, :command:`make install`.

.. note::
    GNU compilers recompile GCHP faster than Intel compilers. This is because of how :program:`gfortran`
    formats Fortran modules files (:file:`*.mod` files). Therefore, if you want to be able to recompile quickly, consider 
    using GNU compilers.

------------

.. _gchp_build_options:

GCHP build options
------------------

These are persistent build setting that are set with :program:`cmake` commands
like

.. code-block:: none

    $ cmake . -D<NAME>="<VALUE>"

where :literal:`<NAME>` is the name of the build setting, and :literal:`<VALUE>` is the value you 
are assigning it. Below is the list of build settings for GCHP.

.. _build_setting_rundir: 

RUNDIR
   Paths to run directories where :command:`make install` installs GCHP. Multiple
   run directories can be specified by a semicolon separated list. A warning is 
   issues if one of these directories does not look like a run directory.

   These paths can be relative paths or absolute paths. Relative paths are interpreted as relative to your build directory.

CMAKE_BUILD_TYPE
    The build type. Valid values are :literal:`Release`, :literal:`Debug`, and :literal:`RelWithDebInfo`.
    Set this to :literal:`Debug` if you want to build in debug mode.

CMAKE_PREFIX_PATH
    Extra directories that CMake will search when it's looking for dependencies. Directories in 
    :literal:`CMAKE_PREFIX_PATH` have the highest precedence when CMake is searching for dependencies.
    Multiple directories can be specified with a semicolon-separated list.

GEOSChem_Fortran_FLAGS_<COMPILER_ID>
    Compiler options for GEOS-Chem for all build types. Valid values for :literal:`<COMPILER_ID>` are :literal:`GNU` and
    :literal:`Intel`.
    
GEOSChem_Fortran_FLAGS_<BUILD_TYPE>_<COMPILER_ID>
    Additional compiler options for GEOS-Chem for build type :literal:`<BUILD_TYPE>`.

HEMCO_Fortran_FLAGS_<COMPILER_ID>
    Same as :literal:`GEOSChem_Fortran_FLAGS_<COMPILER_ID>`, but for HEMCO.
    
HEMCO_Fortran_FLAGS_<BUILD_TYPE>_<COMPILER_ID>
    Same as :literal:`GEOSChem_Fortran_FLAGS_<BUILD_TYPE>_<COMPILER_ID>`, but for HEMCO.

RRTMG
    Switch to enable the RRTMG component. Set value to :literal:`y` to turn on.

FASTJX
    Switch to enable the legacy FAST-JX v7.0 photolysis mechanism. Set value :literal:`y` to turn on FAST-JX and turn off Cloud-J.

OMP
   Switch to enable/disable OpenMP multithreading. As is standard in CMake (see `if documentation <https://cmake.org/cmake/help/latest/command/if.html>`_) valid values are :literal:`ON`, :literal:`YES`, :literal:`Y`, :literal:`TRUE`, or :literal:`1` (case-insensitive) and valid
   false values are their opposites.

INSTALLCOPY
    Similar to :literal:`RUNDIR`, except the directories do not need to be run directories.
