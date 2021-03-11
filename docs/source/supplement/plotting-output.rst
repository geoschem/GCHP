
Plotting GCHP Output
====================

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
    
    To get rid of the missing value bands along face edges, turn interpolation off in the :guilabel:`Array(s)` tab of your plot settings.

Python
------

Todo: see the :ref:`stretched-grid tutorial's plotting section <sg_plotting_example>` in the meantime.

Some notes:

* `xarray <http://xarray.pydata.org/en/stable/>`_ and `cartopy <https://scitools.org.uk/cartopy/docs/latest/>`_ are the fundamental tools
* cartopy > 0.18 fixes the "streaking" of grid-boxes crossing the antimeridian with :code:`pcolormesh()`. As of writing, cartopy 0.19 is not yet released. In the
  meatime you can install it from GitHub with
  
  .. code-block:: console 
     
     $ pip install git+https://github.com/SciTools/cartopy.git

* The cubed-sphere grid is a curvilinear grid, so you need grid-box corners to plot cubed-sphere data with :code:`pcolormesh()`. 
  See the stretched-grid tutorial for an example.