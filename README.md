# GCHPctm
Wrapper for GEOS-Chem chemical-transport model to enable the high performance option (GCHP).

## Getting started

### 1. Set up your build environment
Requirements:
- CMake (version 3.13 or greater)
- NetCDF-C, NetCDF-CXX, NetCDF-Fortran
- MPI (C, C++, and Fortran)
- ESMF (version 8.0.0 or greater)

If you don't already have ESMF 8.0.0+, you will need to build it. Steps for this are at the end of this subsection.

Below is the rc file I use to set up my build environment. For the rest of this README, it is assumed that you have an environment set up appropriately. Whenever `/data10/bindle/gchp_ctm-gcc7.rc` is referred to in this document, this is the file being referred to.
> ```
> # file: gchp_ctm-gcc7.rc
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
> export ESMF_ROOT=/data10/bindle/ESMFv8/DEFAULTINSTALLDIR
> ```

#### 1.1 Building ESMF

You only need one copy of ESMF built per compiler and MPI configuration (this includes for ALL users on a cluster!). It is therefore worth building it somewhere stable and permanent, as almost no users of GCHP would be expected to need to modify or rebuild ESMF except when changing compiler or MPI.

To build ESMF, go to the parent directory of `ESMF_ROOT` (see above), in this case `\data10\bindle`, and run
```console
cd /data10/bindle
git clone https://git.code.sf.net/p/esmf/esmf ESMFv8
cd ESMFv8
git checkout -b ESMF_8_0_0
```

Instructions for building ESMF are then available at the [GCHP wiki](http://wiki.seas.harvard.edu/geos-chem/index.php/GCHP_Hardware_and_Software_Requirements).

### 2. Clone `gchp_ctm` and fill its submodules
```console
git clone git@github.com:geoschem/gchpctm.git Code.GCHPctm
cd Code.GCHPctm
git submodule update --init --recursive
```

### 3. First-time build
1. Create and initialize your build directory. I put my build directory in the root directory of `Code.GCHPctm` but you can put it anywhere.
    ```console
    mkdir build
    cd build
    cmake .. -DRUNDIR=IGNORE # the first argument must be the relative path to the root gchp_ctm directory
    ```
    
    Building with CMake is different to with gnumake (the "traditional" way of building GEOS-Chem). With CMake, there are two stops: a `cmake` command, and a `make` command. The `cmake` command is used to set major options, and is often run just once per build directory. Running this command with `-DCMAKE_BUILD_TYPE=Debug` will result in a GCHP build with bounds checking and other debug options; to explicitly build without those options, run the `cmake` command with `-DCMAKE_BUILD_TYPE=Release`. Once the `cmake` step has been performed once, only the `make` step (below) should be necessary each time you need to rebuild the code (either for the first time or after code modification).
  
    If the last few lines of output from `cmake` look similar to the following snippet then your build was configured successfully.
    ```
    ...
    -- Configuring done
    -- Generating done
    -- Build files have been written to: /data10/bindle/Code.GCHPctm/build
    ```

2. Build the `geos` executable for the first time (again, from the build directory).
    ```console
    make -j
    ```
    It should never be necessary to run `make clean`. The `make` command checks all components of the build for changes.
    
### 4. Making a run directory

1. Make a "master" run directory. This will contain all the run directories associated with this build. This should be somewhere with plenty of space, as all run output will be in subdirectories of this directory:

```
mkdir /data10/bindle/GCHPctm_runs
```

2. Enter the `run` directory in `Code.GCHPctm`. Do not edit this directory - this is the template for all other run directories! Instead, use the script there to create a new rundir, following the instructions given:
```
cd /data10/bindle/Code.GCHPctm # Navigate to root directory, NOT build directory
cd run
./createRunDir.sh
```

To create a standard (full-chemistry) run directory, choose (actual responses in brackets):
 - Standard simulation (`2`)
 - MERRA2 meteorology (`2`)
 - The directory you just created in step 1 (`/data10/bindle/GCHPctm_runs`)
 - A distinctive run directory name (`fullchem_first_test`)
 - Use git to track run directory changes (`y`)
 
This will create and set up a full-chemistry, MERRA-2, GCHP run directory in `/data10/bindle/GCHPctm_runs/fullchem_first_test`. Note that these options only affect the run directory contents, and NOT the build process - the same GCHP executable should be usable for almost all simulation types and supported met data options.

3. Navigate to your new run directory, and set it up for the first run:
```
cd /data10/bindle/GCHPctm_runs/fullchem_first_test
./setEnvironment /data10/bindle/gchp_ctm-gcc7.rc # This sets up the gchp.env symlink
source gchp.env # Set up build environment, if not already done
cp runScriptSamples/gchp.run . # Set up run script - your system is likely to be different!
cp CodeDir/build/bin/geos . # Get the compiled executable
```

4. Submit your first GCHP job using GCHPctm!
```
sbatch gchp.run
```
