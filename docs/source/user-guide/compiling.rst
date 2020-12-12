
Compiling GCHP
==============


Building with CMake is different than with GNU Make (the way to build GEOS-Chem versions prior to
13.0). With CMake, there are two steps: (1) a cmake command, and (2) a make command. The cmake
command is used to set major options, and is often run just once per build directory. Running this
command with :literal:`-DCMAKE_BUILD_TYPE=Debug` will result in a GCHP build with bounds checking and other
debug options. Additional compile options, such as :literal:`LUO_WETDEP`, can be appended with :literal:`-D`, e.g.
:literal:`-DLUO_WETDEP=y`.

Create your build directory
---------------------------

The build directory will contain all files related to building GCHP with a specific environment and
set of compiler flags. All source code directories outside of the build directory remain unchanged
during compilation, unlike in earlier versions of GCHP in which :literal:`*.o` files (for example) were
scattered throughout the source code tree. You can put your build directory in the root directory of
Code.GCHP or you can put it anywhere else.

For your very first built we recommend that you build from the source code for simplicity.

.. code-block:: console

   $ cd Code.GCHP
   $ mkdir build

As you get more advanced, you may wish to create your build directory in your run directory or in a
directory specific to GCHP version.

Configure CMake
---------------

The first argument passed to the cmake command must be the relative path to the root GCHP directory.
For the case of the build directory within source code directory, the root GCHP directory is one
level up.

.. code-block:: console

   $ cd build
   $ cmake ..

If you store your build directory in your run directory instead then the relative path would be
:file:`../CodeDir`, making use of the symbolic link to the source code that is automatically generated when
creating a run directory.

If the last few lines of output from :program:`cmake` look similar to the following snippet then your build was
configured successfully.

.. code-block:: none

   ...
   -- Configuring done
   -- Generating done
   -- Build files have been written to: /data10/bindle/Code.GCHP/build

Compile
-------

The full build does not occur until you run the :program:`make` command.

.. code-block:: console

   $ make -j


Recompiling
-----------

Once the above steps have been performed only the :program:`make` step should be necessary each time you need
to rebuild the code. The exceptions to this are if you change your environment or your compile
options. In all cases it should never be necessary to run :command:`make clean`. The :program:`make` command already
checks all components of the build for changes. If you want to rebuild from scratch because you
changed environments, simply delete all files from the :file:`build/` directory and recompile. You can also
create a new build directory (with a different name) and compile from there to preserve your
previous build.