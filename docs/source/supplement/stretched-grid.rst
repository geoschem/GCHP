

Stretched-Grid Simulation
=========================

.. note::
   Stretched-grid simulations are described in :cite:`Bindle_et_al._2021`. This paper also discusses related topics of consideration and offers guidance for choosing appropriate stretching parameters.

Overview
--------

A stretched-grid is a cubed-sphere grid that is "stretched" to enhance its resolution in a region. 
To set up a stretched-grid simulation you need to do the following:

#. Choose stretching parameters, including stretch factor and target latitude and longitude.
#. Create a stretched grid restart file for your simulation using your chosen stretch parameters.
#. Configure the GCHP run directory to specify stretched grid parameters in :file:`setCommonRunSettings.sh` and use your stretched grid restart file.

Choose stretching parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The :term:`target face` is the face of a stretched-grid that shrinks so that the grid resolution is
finer. The target face is centered on a target point, and the degree of stretching is controlled by
a parameter called the stretch-factor. Relative to a normal cubed-sphere, the resolution of the
target face is refined by approximately the stretch-factor. For example, a C60 stretched-grid with a
stretch-factor of 3.0 has approximately C180 (~50 km) resolution in the target face. The
enhancement-factor is approximate because (1) the stretching gradually changes with distance from
the target point, and (2) gnominic cubed-sphere grids are quasi-uniform with grid-boxes at face
edges being ~1.5x shorter than at face centers.

You can choose a stretch-factor and target point using the interactive figure below. You can reposition
the target face by changing the target longitude and target latitude. The domain of refinement can be
increased or decreased by changing the stretch-factor. Choose parameters so that the target face roughly
covers the refion that you want to refine.

.. raw:: html

   <iframe src="../_static/sg-interactive.html" height="900px" width="100%" frameBorder="0"></iframe>

.. note::

   The interactive figure above can be a bit fiddly. Refresh the page if the view gets messed up.
   If the figure above is not showing up properly, please :doc:`open an issue <reference/SUPPORT>`.

Next you need to choose a cubed-sphere size. The cubed-sphere size must be an even integer (e.g.,
C90, C92, C94, etc.). Remeber that the resolution of the target face is enhanced by approximately the
stretch-factor.


.. _sg_restart_file_regridding:

Create a restart file
^^^^^^^^^^^^^^^^^^^^^

A simulation restart file must have the same grid as the simulation. For example, a C180 simulation
requires a restart file with a C180 grid. Likewise, a stretched-grid simulation needs a restart
file with the same stretched-grid (i.e., an identical cubed-sphere size, stretch-factor, target longitude,
and target latitude).

You can regrid an existing restart file to a stretched-grid with GCPy's :program:`gcpy.file_regrid`
program. Below is an example of regridding a C90 cubed-sphere restart file to a C48 stretched-grid
with a stretch factor of 3, a target longitude of 260.0, and a target latitude of 40.0. See the
GCPy documentation for this program's exact usage, and for installation instructions.

.. code-block:: console

   $ python -m gcpy.file_regrid                                  \
                  -i GEOSChem.Restart.20190701_0000z.c90.nc4   \
                  --dim_format_in checkpoint                     \
                  -o sg_restart_c48_3_260_40.nc                  \
                  --cs_res_out 48                                \
                  --sg_params_out 3.0 260.0 40.0                 \
                  --dim_format_out checkpoint 

Description of arguments:

.. option:: -i GEOSChem.Restart.20190701_0000z.c90.nc

   Specifies the input restart file is :file:`GEOSChem.Restart.20190701_0000z.c90.nc4` (in the current working directory).


.. option:: --dim_format_in checkpoint

   Specifies that the input file is in the "checkpoint" format. GCHP restart files use the "checkpoint" format.

.. option:: -o sg_restart_c48_3_260_40.nc

   Specifies that the output file should be named :file:`sg_restart_c48_3_260_40.nc`.

.. option:: --cs_res_out 48 

   Specifies that the output grid has a cubed-sphere size 48 (C48).

.. option:: --sg_params_out 3.0 260.0 40.0

   Specifies that the output grid's stretched-grid parameters in the order stretch factor (3.0), target longitude (260.0), target latitude (40.0).

.. option:: --dim_format_out checkpoint 

   Specifies that the output file should be in the "checkpoint" format. GCHP restart files must be in the "checkpoint" format.

Once you have created a restart file for your simulation, you can move on to updating your
simulation's configuration files.

Configure run directory
^^^^^^^^^^^^^^^^^^^^^^^

Modify the section of :file:`setCommonRunSettings.sh` that controls the simulation grid. Turn
:envvar:`STRETCH_GRID` to :literal:`ON` and update :envvar:`CS_RES`, :envvar:`STRETCH_FACTOR`,
:envvar:`TARGET_LAT`, and :envvar:`TARGET_LON` for your specific grid.

.. code-block:: bash

   #------------------------------------------------                                                            
   #   GRID RESOLUTION                                                                                          
   #------------------------------------------------                                                            
   # Integer representing number of grid cells per cubed-sphere face side                                       
   CS_RES=24
   
   #------------------------------------------------                                                            
   #   STRETCHED GRID                                                                                           
   #------------------------------------------------                                                            
   # Turn stretched grid ON/OFF. Follow these rules if ON:                                                      
   #    (1) Minimum STRETCH_FACTOR value is 1.0001                                                              
   #    (2) TARGET_LAT and TARGET_LON are floats containing decimal                                             
   #    (3) TARGET_LON in range [0,360)                                                                         
   STRETCH_GRID=OFF
   STRETCH_FACTOR=3.0
   TARGET_LAT=40.0
   TARGET_LON=260.0

Execute :program:`./setCommonRunSettings.sh` to update to update your run directory's configuration files.

.. code-block:: console

   $ ./setCommonRunSettings.sh

You will also need to configure the run directory to use the stretched grid restart file. Update :file:`cap_restart` to match the date of your restart file. This will also be the start date of the run.
Copy or symbolically link to your restart file in the :literal:`Restarts` subdirectory with the proper filename format. The format includes global resolution but not stretched grid resolution so it is a good idea to symbolically link to the original if you want to preserve the original file's specification of stretched grid in its name. 
Run :literal:`setRestartLink.sh` to set symbolic link :file:`gchp_restart.nc4` to point to your restart file based on start date in :file:`cap_restart` and global grid resolution in :file:`setCommonRunSettings.sh`. This is also included as a pre-run step in all example run scripts provided in :file:`runScriptSamples`.

Tutorial: Eastern United States
-------------------------------

This tutorial walks you through setting up and running a stretched-grid simulation for ozone in the eastern United States. 
The grid parameters for this tutorial are:

=====================     ================
Parameter                 Value
=====================     ================
Stretch-factor            3.6
Cubed-sphere size         C60
Target latitude           37° N
Target longitude          275° E
=====================     ================

These parameters are chosen so that the target face covers the eastern United States. 
Some back-of-the-envelope resolution calculations are:

.. math::

    \mathrm{average\ resolution\ of\ target\ face = R_{tf} \approx \frac{10000\ km}{N \times S} = 46\ km}

.. math::

    \mathrm{coarsest\ resolution\ in\ target\ face\ (at\ the\ center) \approx R_{tf} \times 1.2 = 56\ km }

.. math::

    \mathrm{finest\ resolution\ in\ target\ face\ (at\ the\ edges) \approx R_{tf} \div 1.2 = 39\ km }

.. math::

    \mathrm{coarsest\ resolution\ globally\ (at\ target\ antipode) \approx R_{tf} \times S^2 \times 1.2 = 720\ km }


where :math:`\mathrm{N}` is the cubed-sphere size and :math:`\mathrm{S}` is the stretch-factor. 
The actual values of these, calculated from the grid-box areas, are 46 km, 51 km, 42 km, and 664 km respectively.

.. note::

    This tutorial uses a relatively large stretch-factor. A smaller stretch-factor, such as 2.0 rather than 3.6, would have a broader refinement and smaller range resolutions.

Requirements
^^^^^^^^^^^^

Before continuing with the tutorial check that you have all pre-requisites:

* You are able to run global GCHP simulations using MERRA2 data for July 2019
* You have python packages GCPy >= 1.0.0 and cartopy >= 0.19

Create run directory
^^^^^^^^^^^^^^^^^^^^^^^

Create a standard full chemistry run directory that uses MERRA2 meteorology. 
The rest of the tutorial assume that your current working directory is your run directory.


Create restart file
^^^^^^^^^^^^^^^^^^^

You will need to create a restart file with a horizontal resolution that matches your chosen stretched-grid resolution. 
Unlike other input data, GCHP ingests the restart file with no online regridding. Using a restart file with a horizontal grid that does not match the run grid will result in a run-time error. 
To create a restart file for a stretched-grid simulation you can regrid a restart file with a uniform grid using GCPy. Using one of the initial restart files that comes with the GCHP run directory is handy.

.. code-block:: console

   $ python -m gcpy.file_regrid                           \
        -i GEOSChem.Restart.20190701_0000z.c48.nc4      \
        --dim_format_in checkpoint                        \
        --dim_format_out checkpoint                       \
        --cs_res_out 60                                   \
        --sg_params_out 3.6 275 37                        \
        -o initial_GEOSChem_rst.EasternUS_SG_fullchem.nc

This creates :file:`initial_GEOSChem_rst.EasternUS_SG_fullchem.nc`, which is the
new restart file for your simulation.

.. note::
   Regridding a C48 files using GCPy takes about a minute to run. If you regrid an even larger restart file (e.g., C180) it may take significantly longer.

Configure run directory
^^^^^^^^^^^^^^^^^^^^^^^

Make the following modifications to :file:`setCommonRunSettings.sh`:

* Change the simulation's duration to 7 days
* Turn on auto-update of diagnostics
* Set diagnostic frequency to 24 hours (daily)
* Set diagnostic duration to 24 hours (daily)
* Update the compute resources as you like. This simulation's computational
  demands are about :math:`1.5\times` that of a C48 or 2°x2.5° simulation.
* Change global grid resolutio to 60
* Change :literal:`STRETCH_GRID` to :literal:`ON`
* Change :literal:`STRETCH_FACTOR` to :literal:`3.6`
* Change :literal:`TARGET_LAT` to :literal:`37.0`
* Change :literal:`TARGET_LON` to :literal:`275.0`
  
.. note::
    In our tests this simulation took approximately 7 hours to run using 30 cores on 1 node. For comparison, it took 2 hours to run using 180 cores across 6 notes. You may choose your compute resources based on how long you are willing to wait for your run to end.

Next, execute :file:`setCommonRunSettings.sh` to apply the updates to the various configuration files:

.. code-block:: console

   $ ./setCommonRunSettings.sh

Before running GCHP you also need to configure the model to use your stretched-grid restart file. Move or copy your restart file to the :file:`Restarts` subdirectory. Then change the symbolic link :file:`GEOSChem.Restart.20190701_0000z.c48.nc4` to point to your stretched-grid restart file while keeping the name of the link the same. You could also rename your restart file to this format but this would remove valuable information about the content of the file from the filename. Symbolically linking is a better way to preserve the information to avoid errors. You can check that you did this correctly by running :file:`setRestartLink.sh` in the run directory.

Run GCHP
^^^^^^^^

To run GCHP you can use the example run script for running interactively located at :file:`runScriptSamples/gchp.local.run` as long as you have enough resources available locally, e.g. 30 cores on 1 node. Copy it to the main level of your run directory and then execute it. If you want to use more resources you can submit as a batch job to your schedule.

.. code-block:: console

   $ ./gchp.local.run

Log output of the run should be printed to both screen and log file :file:`gchp.20190701_000000z.log`. Check that your run was successful by inspecting the log and looking for output in the :file:`OutputDir` subdirectory.

.. _sg_plotting_example:

Plot the output
^^^^^^^^^^^^^^^

Append grid-box corners:


.. code-block:: console

   $ python -m gcpy.append_grid_corners \
        --sg_params 3.6 275 37 \
        OutputDir/GCHP.SpeciesConc.20190707_1200z.nc4

Plot ozone at model level 22:

.. code-block:: python

    import matplotlib.pyplot as plt
    import cartopy.crs as ccrs
    import xarray as xr

    # Load 24-hr average concentrations for 2019-07-07
    ds = xr.open_dataset('GCHP.SpeciesConc.20190707_1200z.nc4')

    # Get Ozone at level 22
    ozone_data = ds['SpeciesConc_O3'].isel(time=0, lev=22).squeeze()

    # Setup axes
    ax = plt.axes(projection=ccrs.EqualEarth())
    ax.set_global()
    ax.coastlines()

    # Plot data on each face
    for face_idx in range(6):
        x = ds.corner_lons.isel(nf=face_idx)
        y = ds.corner_lats.isel(nf=face_idx)
        v = ozone_data.isel(nf=face_idx)
        pcm = plt.pcolormesh(
            x, y, v, 
            transform=ccrs.PlateCarree(),
            vmin=20e-9, vmax=100e-9
        )
    
    plt.colorbar(pcm, orientation='horizontal')
    plt.show()

.. image:: /_static/stretched_grid_demo.png
   :width: 100%

