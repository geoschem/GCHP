

Output along a track
====================

HISTORY collections can define a :literal:`track_file` that specifies a 1D timeseries of coordinates
that the model is sampled at. The collection output has the same coordinates as the track file. This
feature can be used to sample GCHP along a satellite track or a flight path. A track file is a
NetCDF file with the following format

.. code-block:: console

   $ ncdump -h example_track.nc
   netcdf example_track.nc {
   dimensions:
      time = 1234 ;
   variables:
      float time(time) ;
         time:_FillValue = NaNf ;
         time:long_name = "time" ;
         time:units = "hours since 2020-06-01 00:00:00" ;
      float longitude(time) ;
         longitude:_FillValue = NaNf ;
         longitude:long_name = "longitude" ;
         longitude:units = "degrees_east" ;
      float latitude(time) ;
         latitude:_FillValue = NaNf ;
         latitude:long_name = "latitude" ;
         latitude:units = "degrees_north" ;
   }

To configure 1D output, you can add the following attributes to any collection in 
:file:`HISTORY.rc`.

:track_file:
   Path to a track file. The associated collection will be sampled from the model along this track.
   A track file is a 1-dimensional timeseries of latitudes and longitudes that the model is be
   sampled at (nearest neighbor).

:recycle_track:
   Either :literal:`0` (default) or :literal:`1`. When enabled, HISTORY replaces the date of the
   :literal:`time` coordinate in the track file with the simulation's current day. This lets you use
   the same track file for every day of your simulation.


.. note::  
   1D output is only valid for instantaneous sampling.


Creating a satellite track file
-------------------------------

GCPy includes a command line tool, :program:`gcpy.1D_raveller`, for generating track files
for polar orbiting satellites. These track files will sample model grid-boxes at the times that correspond
to the satellite's overpass time. You can also use this tool to "unravel" the resulting 1D output back
to a cubed-sphere grid. Below is an example of using :program:`gcpy.1D_raveller` to create a track
file for a C180 simulation for TROPOMI, which is in ascending sun-synchronous orbit with 14 orbits
per day and an overpass time of 13:30. Please see the GCPy documentation for this program's exact
usage, and for installation instructions.

.. code-block:: console

   $ python -m gcpy.1D_raveller create_track --cs_res 180 --overpass_time 13:30 --direction ascending --orbits_per_day 14 -o tropomi_overpass.nc

The resulting track file, :file:`tropomi_overpass_c24.nc`, looks like so

.. code-block:: console

   $ ncdump -h tropomi_overpass_c24.nc
   netcdf tropomi_overpass_c24 {
   dimensions:
      time = 3456 ;
   variables:
      float time(time) ;
         time:_FillValue = NaNf ;
         time:long_name = "time" ;
         time:units = "hours since 1900-01-01 00:00:00" ;
      float longitude(time) ;
         longitude:_FillValue = NaNf ;
         longitude:long_name = "longitude" ;
         longitude:units = "degrees_east" ;
      float latitude(time) ;
         latitude:_FillValue = NaNf ;
         latitude:long_name = "latitude" ;
         latitude:units = "degrees_north" ;
      float nf(time) ;
         nf:_FillValue = NaNf ;
      float Ydim(time) ;
         Ydim:_FillValue = NaNf ;
      float Xdim(time) ;
         Xdim:_FillValue = NaNf ;
   }

.. note::
   Track files do not require the :literal:`nf`, :literal:`Ydim`, :literal:`Xdim` variables.
   The are used for post-process "ravelling" with :program:`gcpy.1D_raveller` (changing the 1D output's
   coordinates to a cubed-sphere grid).

Updating HISTORY
----------------

To configure HISTORY to sample along the TROPOMI track you need to add the :literal:`track_file`
and :literal:`recycle_track` attributes to your desired colleciton. For example, to sample
the SpeciesConc collection along the :file:`tropomi_overpass_c24.nc` track, you would add
the following lines to the SpeciesConc collection in :file:`HISTORY.rc`:

.. code-block:: none

   SpeciesConc.track_file: /path/to/tropomi_overpass_c24.nc
   SpeciesConc.recycle_track: 1


Unravelling 1D overpass timeseries
----------------------------------

To covert the 1D timeseries back to a cubed-sphere grid, you can use :program:`gcpy.1D_raveller`.
Below is an example of changing the 1D output back to model grid. Again, see the GCPy documentation
for this program's exact usage, and for installation instructions.


.. code-block:: console

   $ python -m gcpy.1D_raveller unravel --track tropomi_overpass_c24.nc -i OutputDir/GCHP.SpeciesConc.20180101_1330z.nc4 -o OutputDir/GCHP.SpeciesConc.20180101_1330z.TROPOMI.nc4

The resulting dataset, :file:`GCHP.SpeciesConc.20180101_1330z.TROPOMI.nc4`, are simulated concentration on the model grid, sampled
at the times that correspond to TROPOMI's overpass.