setCommonRunSettings.sh
=======================

This file is a bash script to specify run-time values for commonly changed settings and update other configuration files that set them. This is intended as a helper script to make configuring GCHP runs easier. There are four sections of the file: (1) configuration, (2) error checks, (3) helper functions, and (4) update files.

The commonly changed settings section at the very top of the file is usually the only part you need to look at and change. The configuration section itself is divided into two parts. The first part contains the most frequently changed settings. Categories are:

* Compute resources
* Grid resolution
* Stretched grid
* Simulation duration
* GEOS-Chem components
* Diagnostics
* Mid-run checkpoint files
* Requiring all species in the initial restart file
  
The second part contains settings that are less frequently changed but that are still convenient to update from one place. These include:

* Model phase (e.g. adjoint vs forward model)
* Timesteps
* Online dust mass tuning factor
* Domain decomposition

The entire configuration section contains many comments with instructions on how to change the settings and what the options are. Please see that file for more information.

The error checks section checks to make sure the run directory settings make sense and will not cause an early crash due to a simple mistake, such as a core count that is not divisible by 6 or a subdomain size that is less than the minimum 4x4 required by FV3 advection.

The helper functions section contains several functions to simplify updating configuration files based on the settings you specified in the configurations section earlier in the script. Some of the functions are general, such as printing a message during file update based on if the script was passed optional argument :literal:`--verbose`. Other functions are specialized, such as replacing met-field read frequency in :file:`ExtData.rc` based on the model timestep.

The update files section changes settings in other configuration files based on what you set in the configurables section. You can browse this section to see exactly what files are changed. You can also view this information by running the script with the :literal:`--verbose` option.

Using the :file:`setCommonRunSettings.sh` script is technically optional to run GCHP. However, we highly recommend using it to avoid mistakes in your run directory setup. Knowing which configuration files need to be changed for which run-time settings and then changing them all manually is cumbersome and error-prone. We hope that using this file will make it easier to use GCHP without making mistakes. It is included in all GCHP run scripts provided within the :file:`runScriptSamples` subdirectory that comes with the GCHP run directory.

For details about how to change settings please read the comments included within the file.
