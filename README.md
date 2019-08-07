# gchp_ctm
Wrapper for GEOS-Chem chemical-transport model to enable the high performance option (GCHP).

## Build instructions

### Requirements
- CMake (version 3.13 or greater)
- ESMF (version 8.0.0-beta or greater)
- gFTL (version 1.0.1 or greater)
- NetCDF-C, NetCDF-CXX, NetCDF-Fortran
- MPI (C, C++, and Fortran)
- Intel MKL


### 1. Configure the build
1.1. Create a build directory and `cd` into it. I usually put this in the top level of `gchp_ctm/`.

  ```console
  liam:~> cd gchp_ctm
  liam:~/gchp_ctm> mkdir build
  ```

1.2. Initialize your build directory.

  ```console
  liam:~/gchp_ctm/build> cmake ..
  ```

1.3. Resolve unfound dependencies. Currently, you'll have to do this with the `CMAKE_PREFIX_PATH` variable. In the future, environment variables
will be added to make this easier. You can do this over mutliple `cmake` calls like

  ```console
  liam:~/gchp_ctm/build> cmake -DCMAKE_PREFIX_PATH="<path to dependencies' install prefixes>" .
  ```

The build is successfully configured when you don't see any more CMake errors. The last few lines will look something like this:
```
...
-- Configuring done
-- Generating done
-- Build files have been written to: /data10/bindle/gchp_ctm/build
```

### 2. Build your desired library
Once you've configured the build you can build specific targets like so:
```console
liam:~/gchp_ctm/build> make <target names>
```
For example to build the advection core you'd do
```console
liam:~/gchp_ctm/build> make -j FVdycoreCubed_GridComp
```

### 3. Installing targets
There aren't any installable targets at this point.