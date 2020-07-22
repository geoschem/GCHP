# GCHPctm
Wrapper for GEOS-Chem chemical-transport model to enable the high performance option (GCHP).

## CI statuses

Pipeline | Status
:---|:---
Build Matrix (main) | [![Build Status](https://dev.azure.com/geoschem/gchp_ctm/_apis/build/status/Build%20Matrix?branchName=main)](https://dev.azure.com/geoschem/gchp_ctm/_build/latest?definitionId=7&branchName=main)
Quick Build (dev/gchp_13.0.0) | [![Build Status](https://dev.azure.com/geoschem/gchp_ctm/_apis/build/status/Quick%20Build?branchName=dev%2Fgchp_13.0.0)](https://dev.azure.com/geoschem/gchp_ctm/_build/latest?definitionId=6&branchName=dev%2Fgchp_13.0.0)

## Getting started

### 1. Set up your environment
Requirements:
- CMake (version 3.13 or greater)
- NetCDF-C, NetCDF-CXX, NetCDF-Fortran
- Fortran compiler (gfortran 8.3+, ifort 18+)
- MPI (C, C++, and Fortran)
- ESMF (version 8.0.0 or greater)

You must load your environment file prior to building and running GCHP.
    ```console
    source /home/envs/gchpctm_ifort18.0.5_openmpi4.0.1.env
    ```

If you don't already have ESMF 8.0.0+, you will need to download and build it. You only need to build ESMF once per compiler and MPI configuration (this includes for ALL users on a cluster!). It is therefore worth downloading and building somewhere stable and permanent, as almost no users of GCHP would be expected to need to modify or rebuild ESMF except when adding a new compiler or MPI. Instructions for downloading and building ESMF are available at the [GCHP wiki](http://wiki.seas.harvard.edu/geos-chem/index.php/GCHP_Hardware_and_Software_Requirements).

It is good practice to store your environment setup in a text file for reuse. Below are a couple examples that load libraries and export the necessary environment variables for building and running GCHP. Note that library version information is included in the filename for easy reference. Be sure to use the same libraries that were used to create the ESMF build install directory stored in environment variable ESMF_ROOT.

#### Environment file example 1:
> ```
> # file: gchpctm_ifort18.0.5_openmpi4.0.1.env
> 
> # Start fresh
> module --force purge
>
> # Load modules (some include loading other libraries such as netcdf-C and hdf5)
> module load intel/18.0.5
> module load openmpi/4.0.1
> module load netcdf-fortran/4.5.2
> module load cmake/3.16.1
> 
> # Set environment variables
> export CC=gcc
> export CXX=g++
> export FC=ifort
>
> # Set location of ESMF
> export ESMF_ROOT=/n/lab_shared/libraries/ESMF/ESMF_8_0_1/INSTALL_ifort18_openmpi4
> ```

#### Environment file example 2:
> ```
> # file: gchpctm_gcc7.4_openmpi.rc
> 
> # Start fresh
> module --force purge
>
> # Load modules
> module load gcc-7.4.0
> spack load cmake
> spack load openmpi%gcc@7.4.0
> spack load hdf5%gcc@7.4.0
> spack load netcdf%gcc@7.4.0
> spack load netcdf-fortran%gcc@7.4.0
> 
> # Set environment variables
> export CC=gcc
> export CXX=g++
> export FC=gfortran
>
> # Set location of ESMF
> export ESMF_ROOT=/n/home/ESMFv8/DEFAULTINSTALLDIR
> ```


### 2. Clone the `gchpctm` repository and fill its submodules
When cloning GCHP you will get the `main` branch by default.
    ```console
    git clone https://github.com/geoschem/gchpctm.git Code.GCHP
    cd Code.GCHP
    git submodule update --init --recursive
    ```

If you would like a different version of GCHP you can checkout the branch or tag from the top-level directory. Beware that you must always then update the submodules again to checkout the compatible submodule versions. If you have any unsaved changes in a submdodule, such as local GEOS-Chem development, make sure you commit those to a branch prior to updating versions.
    ```console
    cd Code.GCHP
    git checkout tags/13.0.0-alpha.6
    git submodule update --init --recursive
    ```


### 3. First-time build

Building with CMake is different than with GNU Make (the way to build GEOS-Chem versions prior to 13.0). With CMake, there are two steps: (1) a `cmake` command, and (2) a `make` command. The `cmake` command is used to set major options, and is often run just once per build directory. Running this command with `-DCMAKE_BUILD_TYPE=Debug` will result in a GCHP build with bounds checking and other debug options. Additional compile options, such as LUO_WETDEP, can be appended with `-D`, e.g. `-DLUO_WETDEP=y`.

#### a. Create your build directory
The build directory will contain all files related to building GCHP with a specific environment and set of compiler flags. All source code directories outside of the build directory remain unchanged during compilation, unlike in earlier versions of GCHP in which *.o files (for example) were scattered throughout the source code tree. You can put your build directory in the root directory of `Code.GCHP` or you can put it anywhere else.

For your very first built we recommend that you build from the source code for simplicity. 
    ```console
    cd Code.GCHP
    mkdir build
    ```

As you get more advanced, you may wish to create your build directory in your run directory or in a directory specific to GCHP version.
    
#### b. Configure with CMake
  The first argument passed to the cmake command must be the relative path to the root GCHP directory. For the case of the build directory within source code directory, the root GCHP directory is one level up.
    ```console
    cd build
    cmake ..
    ```

If you store your build directory in your run directory instead then the relative path would be `../CodeDir`, making use of the symbolic link to the source code that is automatically generated when creating a run directory.

If the last few lines of output from `cmake` look similar to the following snippet then your build was configured successfully.
    ```
    ...
    -- Configuring done
    -- Generating done
    -- Build files have been written to: /data10/bindle/Code.GCHP/build
    ```

#### c. Build the executable `geos`
The full build does not occur until you run the `make` command.
    ```console
    make -j
    ```

#### d. How to recompile

Once the above steps have been performed only the `make` step should be necessary each time you need to rebuild the code. The exceptions to this are if you change your environment or your compile options. In all cases it should never be necessary to run `make clean`. The `make` command already checks all components of the build for changes. If you want to rebuild from scratch because you changed environments, simply delete all files from the `build` directory and recompile. You can also create a new build directory (with a different name) and compile from there to preserve your previous build.

### 4. Create a run directory

First, make a high-level directory to contain all the run directories associated with this version of GCHP. This should be somewhere with plenty of space, as all run output will be in subdirectories of this directory. You can optionally create one or more build directories here for storage and easy access to GCHP builds specific to a certain version (see previous section on building GCHP).

```
mkdir /scratch/testruns/GCHP/13.0.0
```

Next, enter the `run` directory in `Code.GCHP`. Do not edit this directory - this is the template for all other run directories! Instead, use the script there to create a new run directory, following the instructions printed to the screen.
    ```console
    cd Code.GCHP
    cd run
    ./createRunDir.sh
    ```

For example, to create a standard (full-chemistry) run directory, choose (actual responses in brackets):
 - Standard simulation (`2`)
 - MERRA2 meteorology (`2`)
 - The directory you just created in step 1 (`/scratch/rundirs/GCHP/13.0.0`)
 - A distinctive run directory name (`fullchem_first_test`)
 - Use git to track run directory changes (`y`)
 
This will create and set up a full-chemistry, MERRA-2, GCHP run directory in `/scratch/testruns/GCHP/13.0.0/fullchem_first_test`. Note that these options only affect the run directory contents, and NOT the build process - the same GCHP executable is usable for almost all simulation types and supported met data options.

### 5. Configure your run directory
Navigate to your new run directory, and set it up for the first run:
    ```console
    cd /scratch/testruns/GCHP/13.0.0/fullchem_first_test
    ./setEnvironment /home/envs/gchpctm_ifort18.0.5_openmpi4.0.1.env # This sets up the gchp.env symlink
    source gchp.env # Set up build environment, if not already done
    cp runScriptSamples/gchp.run . # Set up run script - your system is likely to be different! See also gchp.local.run.
    cp CodeDir/build/bin/geos . # Get the compiled executable
    ```

### 6. Submit your first GCHP job using GCHP!
    ```console
    sbatch gchp.run
    ```

For more information about GCHP, see the following resources:
[GCHP wiki](http://wiki.seas.harvard.edu/geos-chem/index.php/GCHP_Main_Page).
[GCHP issues on GitHub](https://github.com/geoschem/gchpctm/issues)

