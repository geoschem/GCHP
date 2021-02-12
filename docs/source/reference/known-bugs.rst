Known Bugs
==========

This page links to known bugs in GCHP. See the GitHub issues for updates on their status.

Known bugs in GEOS-Chem
-----------------------

These are known bugs in specific versions of GEOS-Chem. See the associated issue on GitHub for
the recommended solution/workaround.

Version 13.0
   * Crash because of incorrect timestamps at start/end of year in OFFLINE_BIOVOC/v2019-10. 
     See https://github.com/geoschem/GCHP/issues/84 for workaround.
   * Segmentation fault at runtime with Intel 2021.1 compilers. 
     See https://github.com/geoschem/GCHP/issues/87 for workaround.

Version 12.9
   * Crash because of incorrect timestamps at start/end of year in OFFLINE_BIOVOC/v2019-10. 
     See https://github.com/geoschem/GCHP/issues/84 for workaround.

Version 12.8
   * Crash because of incorrect timestamps at start/end of year in OFFLINE_BIOVOC/v2019-10. 
     See https://github.com/geoschem/GCHP/issues/84 for workaround.

Version 12.7
   * Crash because of incorrect timestamps at start/end of year in OFFLINE_BIOVOC/v2019-10. 
     See https://github.com/geoschem/GCHP/issues/84 for workaround.


Known bugs in external software affecting GEOS-Chem
---------------------------------------------------

These are known bugs in external dependencies that affect GEOS-Chem.

Intel MPI & Compilers
   * Intel 2021.1 (or similar) might require CMake 3.19 or newer:  https://github.com/geoschem/GCHP/issues/85

