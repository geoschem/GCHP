# gchp_ctm
Wrapper for GEOS-Chem chemical-transport model to enable the high performance option (GCHP).

## Getting started
### 1. Clone this repo
```console
liam:~> git clone git@github.com:geoschem/gchp_ctm.git
liam:~> cd gchp_ctm
liam:~/gchp_ctm> git checkout dev/gchp
liam:~/gchp_ctm> git submodule update --init --recursive
```

### 2. Set up your environment
GCHP_CTM has the following build-environment requirements:
- CMake (version 3.13 or greater)
- ESMF (version 8.0.0-beta-snapshot40 or greater)
  - ESMF v8.0.0-beta-snapshot40 was released on July 3, 2019
- gFTL (version 1.0.1 or greater)
- NetCDF-C, NetCDF-CXX, NetCDF-Fortran
- MPI (C, C++, and Fortran)
- Intel MKL

The following snippet is the rc file I used to initialize my build environment on stetson.

```
# Start fresh
module --force purge

# Fix PATH and LD_LIBRARY_PATH since stetson is broken
export PATH=/usr/local/bin:/usr/bin:/bin
export LD_LIBRARY_PATH=
export SPACK_ROOT=/data10/bindle/spack
. ${SPACK_ROOT}/share/spack/setup-env.sh
export MODULEPATH=$MODULEPATH:/stetson-home/bindle/local_software/gcc-7.4.0-install

# Load modules
module load gcc-7.4.0
spack load cmake
spack load openmpi%gcc@7.4.0
spack load intel-mkl%gcc@7.4.0
spack load hdf5%gcc@7.4.0
spack load netcdf%gcc@7.4.0
spack load netcdf-fortran%gcc@7.4.0
spack load parallel-netcdf%gcc@7.4.0

# Set environment variables
export CC=gcc
export CXX=g++
export FC=gfortran
export ESMF_ROOT=/data10/bindle/gchp_ctm/ESMF/DEFAULTINSTALLDIR
export gFTL_ROOT=/data10/bindle/gchp_ctm/gFTL/install
```

### 3. Building gchp_ctm
1. Create and initialize your build directory. I put my build directory in the root `gchp_ctm` directory but you can put it anywhere.
  ```console
  liam:~/gchp_ctm> mkdir build
  liam:~/gchp_ctm> cd build
  liam:~/gchp_ctm/build> cmake .. # relative path to the root gchp_ctm directory
  ```

  If you get errors from unfound dependencies you will have to use the `CMAKE_PREFIX_PATH` variable to resolve them. Don't hesitate to message me on slack for help with this.

  If the last few lines of output from `cmake` look similar to the following snippet, then your build was configured successfully.
  ```
  ...
  -- Configuring done
  -- Generating done
  -- Build files have been written to: /data10/bindle/gchp_ctm/build
  ```

2. Build the `geos` executable (I haven't set up the `all` target yet).
  ```console
  liam:~/gchp_ctm/build> make -j geos
  ```

3. The `geos` executable is installed to `CMAKE_PREFIX_PATH`. So install `geos` to `~/gchp_standard` you would do
  ```console
  liam:~/gchp_ctm/build> cmake -DCMAKE_PREFIX_PATH=/home/liam/gchp_standard .
  liam:~/gchp_ctm/build> make install
  ```
