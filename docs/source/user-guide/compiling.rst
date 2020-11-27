
Compiling GCHP
==============

.. note::
    This user guide assumes you have loaded a computing environment that satisfies
    :ref:`GCHP's software requirements <software_requirements>`.

There are two steps to build GCHP. The first step is configuring your build. 
To configure your build you use :program:`cmake` to configure build settings. 
Build settings cover options like enabling or disabling components like 
RRTMG, specifying run directories to install GCHP to, or whether GCHP should be compiled in Debug mode. 

The second step is compiling. To compile GCHP you use :program:`make`. This
compiles GCHP according to your configuration from the first step.


Create a build directory
------------------------

Create a build directory. This directory is going to be the working directory
for your build. The configuration and compile steps generate a 
bunch of build files, and this directory is going to store those. You can
think of a build directory as representing a GCHP build. It stores configuration
settings, information about your system, and intermediate files from the compiler.

A build directory is self contained, so you can delete it at any point to erase 
the build and its configuration. You can have as many build directories as you 
would like. Most users only need one build directory, since they only build GCHP
once; but, for example, if you were building GCHP with Intel and GNU compilers to
compare performance, you would have two build directories: one for the Intel build,
and one for the GNU build. You can name your build directories whatever you want, but a good choice is :file:`build/`.
There is one rule for build directories: **a build directory should be a new directory**.

Create a build directory and initialize it. You initialize a build directory by
running :program:`cmake` with the path to the GCHP source code. Here is an example
of creating a build directory in the top-level of the GCHP source code:

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

Configure your build
--------------------

Build settings are controlled by :program:`cmake` commands with the following
form:

.. code-block:: none

    $ cmake . -D<NAME>="<VALUE>"

where :literal:`<NAME>` is the name of the setting, and :literal:`<VALUE>` is the
value that you are assigning it. These settings are persistent and saved in your build directory.
You can set multiple variables in a single command, and you can run :program:`cmake` as many times
as you need to configure your desired settings.

.. note:: 
   The :literal:`.` argument is important. It is the path to your build directory which
   is :literal:`.` here.

GCHP has no required build settings. You can find the complete list of GCHP's build settings `here <Build options for GCHP>`_.
The most frequently used build setting is :literal:`RUNDIR` which lets you specify one or more run directories
to install GCHP to. Here, "install" refers to copying the compiled executable, and some supplemental files
with build settings, to your run directories.

.. note::
    You can even update build settings after you compile GCHP. Simply rerun :program:`make` and
    (optionally) :program:`make install`, and the build system will automatically figure out
    what needs to be recompiled.

Since there are no required build settings, for this tutorial we will stick with the
default settings. 

You should notice that when you run :program:`cmake` it ends with:

.. code-block:: console
   
   ...
   -- Configuring done
   -- Generating done
   -- Build files have been written to: /src/build

This tells you the configuration was successful, and that you are ready to compile. 

Compile
-------

You compile GCHP with:

.. code-block:: console
   
   gcuser:~/Code.GCHP/build$ make -j   # -j enables compiling in parallel

Optionally, you can use the :literal:`VERBOSE=1` argument to see the compiler commands.

This step creates :file:`./bin/gchp` which is the compiled executable. You can copy
this executable to your run directory manually, or you can do

.. code-block:: console
   
   gcuser:~/Code.GCHP/build$ make install

which copies :file:`./bin/gchp` (and some supplemental files) to 
the run directories specified in :ref:`RUNDIR <build_setting_rundir>`.

Now you have compiled GCHP, and you are ready to move on to creating a run directory!

------------

Recompiling
-----------

You need to recompile GCHP if you update a build setting or make a modification to the source code.
However, with CMake, you don't need to clean before recompiling. The build system automatically 
figure out which files need to be recompiled based on your modification. This is known as incremental compiling.

To recompile GCHP, simply do 

.. code-block:: console
   
   gcuser:~/Code.GCHP/build$ make -j   # -j enables compiling in parallel

and optionally, do :command:`make install`.

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
   Switch to enable/disable OpenMP multithreading. As is standard in CMake (see `here <https://cmake.org/cmake/help/latest/command/if.html>`_) valid values are :literal:`ON`, :literal:`YES`, :literal:`Y`, :literal:`TRUE`, or :literal:`1` (case-insensitive) and valid
   false values are their opposites.

INSTALLCOPY
    Similar to :literal:`RUNDIR`, except the directories do not need to be run directories.
