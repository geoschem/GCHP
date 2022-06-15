
Plotting GCHP Output
====================

With the exception of the restart file, all GCHP output netCDF files may be viewed with Panoply software freely available from NASA GISS. In addition, python works very well with all GCHP output.

Panoply
-------

Panoply is useful for quick and easy viewing of GCHP output. 
Panoply is a grahpical program for plotting geo-referenced data like GCHP's output. 
It is an intuitive program and it is easy to set up.

.. image:: /_static/panoply_example.png
   :width: 100%

You can read more about Panoply, including how to install it, `here <https://www.giss.nasa.gov/tools/panoply/>`_.

Some suggestions
  * If you can mount your cluster's filesystem as a Network File System (NFS) on your local machine, you can install Panoply on your local machine and view your GCHP data through the NFS. 
  * If your cluster supports a graphical interface, you could install Panoply (administrative priviledges not necessary, provided Java is installed) yourself. 
  * Alternatively, you could install Panoply on your local machine and use :program:`scp` or similar to transfer files back and forth when you want to view them.


.. note::
    
    To get rid of the missing value bands along face edges, **uncheck 'Interpolate'** (turn interpolation off) in the :guilabel:`Array(s)` tab.

Python
------

To plot GCHP data with Python you will need the following libraries:

* cartopy >= 0.19 (0.18 won't work -- see `cartopy#1622 <https://github.com/SciTools/cartopy/pull/1622>`_)
* xarray 
* netcdf4

If you use `conda <https://docs.conda.io/en/latest/>`_ you can install these packages like so 

.. code-block:: console

    $ conda activate your-environment-name
    $ conda install cartopy>=0.19 xarray netcdf4 -c conda-forge

Here is a basic example of plotting cubed-sphere data:

* Sample data: :download:`GCHP.SpeciesConc.20210508_0000z.nc4 <http://geoschemdata.wustl.edu/ExternalShare/GCST/GCHP-SampleOutput/13.2.1/GCHP.SpeciesConc.20210508_0000z.nc4>`

.. code-block:: python

    import matplotlib.pyplot as plt
    import cartopy.crs as ccrs  # cartopy must be >=0.19
    import xarray as xr
    
    ds = xr.open_dataset('GCHP.SpeciesConc.20210508_0000z.nc4')  # see note below for download instructions

    plt.figure()
    ax = plt.axes(projection=ccrs.EqualEarth())
    ax.coastlines()
    ax.set_global()

    norm = plt.Normalize(1e-8, 7e-8)
    
    for face in range(6):
        x = ds.corner_lons.isel(nf=face)
        y = ds.corner_lats.isel(nf=face)
        v = ds.SpeciesConc_O3.isel(time=0, lev=23, nf=face)
        ax.pcolormesh(x, y, v, norm=norm, transform=ccrs.PlateCarree())
    
    plt.show()

.. image:: /_static/sample_gchp_output.png
   :width: 100%

.. note:: 
   
   The grid-box corners should be used with :code:`pcolormesh()` because the grid-boxes are not regular (it's a curvilinear grid).
   This is why we use :code:`corner_lats` and :code:`corner_lons` in the example above.
