

Stretched-grid simulations
==========================

A stretched-grid is a cubed-sphere grid that is "stretched" to enhance its resolution in a region.
To set up a stretched-grid simulation you need to do two things:

#. Create a restart file for your simulation.
#. Update :file:`runConfig.sh` to specify the grid and restart file.

Before setting up your stretched-grid simulation, you will need to choose stretching parameters.

Choose stretching parameters
----------------------------

The :term:`target face` is face of a stretched-grid that shrinks so that the grid resolution is
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

   <iframe src="_static/sg-interactive.html" height="900px" width="100%" frameBorder="0"></iframe>

.. note::

   The interactive figure above can be a bit fiddly. Refresh the page if the view gets messed up.
   If the figure above is not showing up properly, please :doc:`open an issue <reference/SUPPORT>`.

Next you need to choose a cubed-sphere size. The cubed-sphere size must be an even integer (e.g.,
C90, C92, C94, etc.). Remeber that the resolution of the target face is enhanced by approximately the
stretch-factor.


.. _sg_restart_file_regridding:

Create a restart file
---------------------

A simulation restart file must have the same grid as the simulation. For example, a C180 simulation
requires a restart file with a C180 grid. Likewise, a stretched-grid simulation needs a restart
file with the same stretched-grid (i.e., an identical cubed-sphere size, stretch-factor, target longitude,
and target latitude).

You can regrid an existing restart file to a stretched-grid with GCPy's :program:`gcpy.file_regrid`
program. Below is an example of regridding a C90 cubed-sphere restart file to a C48 stretched-grid
with a stretch factor of 3, a target longitude of 260.0, and a target latitude of 40.0. See the
GCPy documentation for this program's exact usage, and for installation instructions.

.. code-block:: console

   $ python -m gcpy.file_regrid                             \
                  -i initial_GEOSChem_rst.c90_standard.nc   \
                  --dim_format_in checkpoint                \
                  -o sg_restart_c48_3_260_40.nc             \
                  --cs_res_out 48                           \
                  --sg_params_out 3.0 260.0 40.0            \
                  --dim_format_out checkpoint 

Description of arguments:

.. option:: -i initial_GEOSChem_rst.c90_standard.nc

   Specifies the input restart file is :file:`initial_GEOSChem_rst.c90_standard.nc` (in the current working directory).


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

Update your configuration files
-------------------------------

Modify the section of :file:`runConfig.sh` that controls the simulation grid. Turn
:envvar:`STRETCH_GRID` to :literal:`ON` and update :envvar:`CS_RES`, :envvar:`STRETCH_FACTOR`,
:envvar:`TARGET_LAT`, and :envvar:`TARGET_LON` for your specific grid.

.. code-block:: bash

   #------------------------------------------------
   #   Internal Cubed Sphere Resolution
   #------------------------------------------------

   # Primary resolution is an integer value. Set stretched grid to ON or OFF.
   #   24 ~ 4x5, 48 ~ 2x2.25, 90 ~ 1x1.25, 180 ~ 1/2 deg, 360 ~ 1/4 deg
   CS_RES=24
   STRETCH_GRID=ON

   # Stretched grid parameters
   # Rules and notes:
   #    (1) Minimum STRETCH_FACTOR is 1.0001
   #    (2) Target lat and lon must be floats (contain decimal)
   #    (3) Target lon must be in range [0,360)
   STRETCH_FACTOR=3.0
   TARGET_LAT=40.0
   TARGET_LON=260.0

Next, modify the section of :file:`runConfig.sh` that specifies the simulation restart file.
Set :envvar:`INITIAL_RESTART` to the restart file we created in the :ref:`previous step <sg_restart_file_regridding>`.

.. code-block:: bash

   #------------------------------------------------
   #    Initial Restart File
   #------------------------------------------------
   # By default the linked restart files in the run directories will be 
   # used. Please note that HEMCO restart variables are stored in the same
   # restart file as species concentrations. Initial restart files available 
   # on gcgrid do not contain HEMCO variables which will have the same effect
   # as turning the HEMCO restart file option off in GC classic. However, all 
   # output restart files will contain HEMCO restart variables for your next run.
   # INITIAL_RESTART=initial_GEOSChem_rst.c${CS_RES}_TransportTracers.nc

   # You can specify a custom initial restart file here to overwrite:
   INITIAL_RESTART=sg_restart_c48_3_260_40.nc

Lastly, execute :program:`./runConfig.sh` to update to update your run directory's 
configuration files.

.. code-block:: console

   $ ./runConfig.sh