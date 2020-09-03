---
name: Report a GCHP bug or technical issue
about: Use this template to report bugs and technical issues encountered while using GCHP.
title: "[BUG/ISSUE]"
labels: bug
assignees: ''

---
<!--- STOP!  BEFORE YOU SUBMIT THIS ISSUE, PLEASE READ THE FOLLOWING: -->

## Describe the bug:

### Expected behavior: ###
<!--- Include a clear and concise description of what you expected to happen. -->

### Actual behavior: ###
<!--- Include a clear and concise description of the problematic behavior. -->

### Steps to reproduce: the bug:
<!--- Include the steps that must be done in order to reproduce the observed behavior:

**Compilation commands**
<!--- Please list all the steps you did to compile GCHP. -->

**Run commands**
<!--- Please list all the steps you did to run GCHP. -->

### Error messages
<!--- Please cut and paste any error message output where it says `add text here`. --->
```
add text here
```

## Required information:

### Your GCHP version and runtime environment:
<!--- Please supply the requested information in the spaces marked by `__`. -->
 - GCHPctm version (can be last commit hash): __
 - MPI type and version: __
 - Fortran cmpiler type and version: __
 - netCDF version: __
 - Are you using GCHP "out of the box" (i.e. unmodified): __
   - If you have modified GCHP, please list what was changed: __

### Input and log files to attach
<!--- Please supply the requested information in the spaces marked by `__` -->
<!--- For more info, see: http://wiki.geos-chem.org/Submitting_GEOS-Chem_support_requests -->
<!--- You can drag and drop files to this window and Github will upload them to this issue. --->
<!--- NOTES: --->
<!--- Any text files (*.F90, *.rc, input.geos, log files) must have the `.txt` suffix --->
<!--- or Github will not be able to display them. --->
<!--- If you have a compiler issue please create a verbose compile log with these commands: --->
<!---    cmake ../CodeDir > compile.txt --->
<!---    make -j verbose=1 >> compile.txt --->
 - runConfig.sh: __
 - input.geos: __
 - HEMCO_Config.rc: __
 - ExtData.rc: __
 - HISTORY.rc: __
 - GCHP compile log file: __
 - GCHP run log file: __
 - HEMCO.log: __
 - slurm.out or any other error messages from your scheduler: __
 - Any other error messages: __

### Additional context
<!--- Include any other context about the problem here. -->
