
Compiling GCHP
==============

There are two steps to building GCHP. The first is configuring your build, which is done with :program:`cmake`; 
the second step is compiling, which is done with :program:`make`.

In the first step (build configuration), :program:`cmake` finds where GCHP's :ref:`software dependencies <software_requirements>`
are located on your system, and you can set :ref:`build options <gchp_build_options>` like
enabling/disabling components, setting run directories for installing GCHP to, and whether to compile in
Debug mode. The second step (running :program:`make`) compiles GCHP according your build configuration.

The instructions for building GCHP are below.

.. note::
   Another resource for GCHP build instructions is our `YouTube tutorial <https://www.youtube.com/watch?v=G_DMCv-mJ2k>`_.

.. important::
   These instructions assume you have loaded a computing environment that satisfies
   :ref:`GCHP's software requirements <software_requirements>`.

Create a build directory
------------------------

Create a build directory. This is going to be the working directory
for your build. The configuration and compile steps generate a 
bunch of files, and this directory is going to house those. You can
think of a build directory as representing a GCHP build. It stores configuration
settings, information about your system, and intermediate files from the compiler.

A build directory is self-contained, so you can delete it at any point (erasing its configuration and state) to start over.
Most users will only have one build directory, but you can have multiple. 
If, for example, you were building GCHP with Intel and GNU compilers to compare performance, you would need two build directories: one for the Intel build and one for the GNU build.
You can choose the name and location of your build directories, but a good name is :file:`build/` and 
a good place is the top-level of the source code (i.e., a subdirectory in the code called :file:`build/`).
There is one rule for build directories: **a build directory should be a new directory**.

Create a build directory and initialize it. You initialize a build directory by
running :program:`cmake`; the first time you run :program:`cmake`, you need to pass it the path to GCHP's source code. 
Here is an example of creating a build directory:

.. code-block:: console
   
   gcuser:~$ cd ~/GCHP.Code
   gcuser:~/GCHP.Code$ mkdir build                # create the build dir
   gcuser:~/Code.GCHP$ cd build
   gcuser:~/Code.GCHP/build$ cmake ~/Code.GCHP    # initialize the build
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

.. note::
   You can explicitly specify compilers by setting the :envvar:`CC`, :envvar:`CXX`, and :envvar:`FC` environment
   variables. If autodetected compilers (see the output above) are the wrong compilers, create a new build directory
   (delete the old one), and make sure these variables are set before you initialize the build directory.

.. note:: 
   If you get a CMake error saying "Could not find XXXX" (where XXXX is a dependency like
   ESMF, NetCDF, HDF5, etc.), the problem is that CMake can't automatically find where that library 
   is installed on your system. You can add custom paths to CMake's default list of search paths with the
   :literal:`CMAKE_PREFIX_PATH` variable.

   For example, if you got an error saying "Could not find ESMF", and ESMF were installed
   at :file:`/software/ESMF`, you would do

   .. code-block:: console
      
      gcuser:~/Code.GCHP/build$ cmake . -DCMAKE_PREFIX_PATH=/software/ESMF
    
   See the next section for details on setting build variables like :literal:`CMAKE_PREFIX_PATH`.
   

Configure your build
--------------------

Build settings are controlled by subsequent :program:`cmake` commands with the following
form:

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

Compile GCHP
------------

You compile GCHP with:

.. code-block:: console
   
   gcuser:~/Code.GCHP/build$ make -j   # -j enables compiling in parallel

.. note::
   You can add :literal:`VERBOSE=1` to see all the compiler commands.

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

------------

.. _gchp_build_options:

GCHP build options
------------------

These are persistent build setting that are set with :program:`cmake` commands
with the following form

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
    One or more directories that are searched for external libraries like NetCDF or MPI. You 
    can specify multiple paths with a semicolon separated list.

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
    Switch to enable/disable the RRTMG component.

OMP
   Switch to enable/disable OpenMP multithreading. As is standard in CMake (see `if documentation <https://cmake.org/cmake/help/latest/command/if.html>`_) valid values are :literal:`ON`, :literal:`YES`, :literal:`Y`, :literal:`TRUE`, or :literal:`1` (case-insensitive) and valid
   false values are their opposites.

INSTALLCOPY
    Similar to :literal:`RUNDIR`, except the directories do not need to be run directories.
