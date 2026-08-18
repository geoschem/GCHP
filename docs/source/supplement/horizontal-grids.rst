.. _gchp_hgrids:

#####################
GCHP horizontal grids
#####################

GCHP uses cubed-sphere horizontal grids instead of the traditional
cartesian grids.  For a good general description of cubed sphere
grids, please see our `Cubed-sphere grid illustrations
<https://geoschem.github.io/cube-sphere.html>`_ page at `geos-chem.org
<https://geoschem.github.io>`_.

Cubed-sphere grid resolutions are denoted using the number of grid
cells along each face, which must be divisible by 6.  At present GCHP
uses :ref:`grids with 72 vertical layers <gchp-vgrids>`, but this may
increase to 132 layers in the near future.

The table below shows some common cubed-sphere configurations.

.. list-table::
   :header-rows: 1

   * - Grid
     - # cells per face
     - # cells at surface
     - # layers
     - # cells total
     - # Equiv. lat-lon grid
   * - C24
     - 24
     - 3456
     - 72
     - 248,832
     - 4° x 5°
   * - C30
     - 30
     - 5400
     - 72
     - 388,800
     - 4° x 5°
   * - C48
     - 48
     - 13,824
     - 72
     - 995,328
     - 2° x 2.5°
   * - C90
     - 90
     - 48,600
     - 72
     - 3,499,200
     - 1° x 1.25°
   * - C180
     - 180
     - 194,400
     - 72
     - 13,996,800
     - 0.5° x 0.625°
   * - C360
     - 360
     - 777,600
     - 72
     - 55,987,200
     - 0.25° x 0.3125°
   * - C720
     - 720
     - 3,110,400
     - 72
     - 223,948,800
     - 0.125° x 0.15625°

The default GCHP grid resolution is C90. Users are encouraged to 
think carefully about their run's needs and available resources when choosing a 
grid resolution. Higher-resolution simulations provide a more faithful
representation of transport :cite:`Strahan_Polansky._2006`, as the model can better
resolve nonlinearities and heterogeneity, albeit at greater computational expense. 
Current GCHP applications commonly span within C48 to C360. Determing a
"sufficient" model resolution is highly dependent on your exact research question. 

Switching from C24/30/48 to C90 or higher will require some changes to your run 
configuration, as the computational cost of running GCHP increases with grid 
resolution. 

See our :ref:`stretched-grid` chapter for information about how
you can stretch one of the grid faces to achieve extra-fine resolution
over a target location.

**Reference**: :cite:t:`Eastham_et_al._2018`
