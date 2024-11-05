.. |br| raw:: html

   <br />

.. _history-rc:

##########
HISTORY.rc
##########

:file:`HISTORY.rc` is the file that configures GCHP's output. It has
the following format.

.. code-block:: none

   EXPID:  OutputDir/GCHP
   EXPDSC: GEOS-Chem_devel
   CoresPerNode: 30
   VERSION: 1

   <DEFINE GRID LABELS>

   <DEFINE ACTIVE COLLECTIONS>

   <DEFINE COLLECTIONS>


.. option:: EXPID

   This is the file prefix for all collections. :literal:`OutputDir/GCHP`
   means that collections will be written to directory
   :file:`OutputDir/` with filename prefix :literal:`GCHP`.

.. option:: EXPDSC

   Optional description of your run to be included in output metadata.

.. option:: CoresPerNode

   The number of cores per node for your GCHP simulation. If using the
   auto-update diagnostics feature in :ref:`set-common-run-settings-sh`
   then this will automatically get updated based on settings in that
   file.

.. option:: VERSION

   Optional version number of to be included in output metadata.

   The format and description of :ref:`\<DEFINE GRID LABELS\>
   <defining-grid-labels>`,  :ref:`\<DEFINE ACTIVE COLLECTIONS\>
   <defining-active-collections>`, and and :ref:`\<DEFINE
   COLLECTIONS\> <defining-collections>` sections are given below.

.. _defining-grid-labels:

====================
Defining Grid Labels
====================

You can specify custom grids for your output. For example, a regional
0.05°x0.05° grid covering North America. This way your collections are
regridded online. There are two advantages to doing this:

#. It eliminates the need to regrid your simulation data in a
   post-processing step.
#. It saves disk space if you are interested in regional output.

Beware that outputting data on a different grid assumes the data is
independent of horizontal cell size. The regridding routines are
area-conserving and thus regridded values will only make sense for
data that is area-independent. Examples of data units that are
area-independent are mixing ratios (e.g. kg/kg or mol/mol) and
emissions rates per area (e.g. kg/m2/s). Examples of data units that
are NOT area-independent are kg/s and m2, or any other unit that
implicitly is per grid cell area. This sort of unit is most common in
the meteorology diagnostics, such as :literal:`Met_AREAM2` and
:literal:`Met_AD`. The values of these arrays will be incorrect in
non-native grid output.

You can define as many grids as you want. However, you should comment
out all grid labels in the :literal:`GRID_LABELS` list that you do not
intend to use. This is because MAPL creates all grids listed
regardless of whether they are used which increases the memory
requirement for the mode.

A collection can define :option:`grid_label` to select a custom grid. If
a collection does not define :option:`grid_label` the simulation's grid
is assumed.

Below is the format for the :literal:`<DEFINE GRID LABELS>` section in
:file:`HISTORY.rc`.

.. code-block:: none

   GRID_LABELS:   MY_FIRST_GRID       # My custom grid for C96 output
                  MY_SECOND_GRID      # My custom grid for global 0.5x0.625 output
                  MY_THIRD_GRID       # My custom grid for regional 0.05x0.05 output
   ::
      MY_FIRST_GRID.GRID_TYPE:   Cubed-Sphere
      MY_FIRST_GRID.IM_WORLD:    96
      MY_FIRST_GRID.JM_WORLD:    576      # 576=6x96

      MY_SECOND_GRID.GRID_TYPE:  LatLon
      MY_SECOND_GRID.IM_WORLD:   360
      MY_SECOND_GRID.JM_WORLD:   181
      MY_SECOND_GRID.POLE:       PC       # pole-centered
      MY_SECOND_GRID.DATELINE:   DC       # dateline-centered

      MY_THIRD_GRID.GRID_TYPE:   LatLon
      MY_THIRD_GRID.IM_WORLD:    80
      MY_THIRD_GRID.JM_WORLD:    40
      MY_THIRD_GRID.POLE:        XY
      MY_THIRD_GRID.DATELINE:    XY
      MY_THIRD_GRID.LON_RANGE:    0 80    # regional boundaries
      MY_THIRD_GRID.LAT_RANGE:  -30 10

SPEC NAMES

.. option:: GRID_TYPE

   The type of grid. Valid options are :literal:`Cubed-Sphere` or
   :literal:`LatLon`.

.. option:: IM_WORLD

   The number of grid boxes in the i-dimension. For a :literal:`LatLon`
   grid this is the number of longitude grid-boxes. For a
   :literal:`Cubed-Sphere` grid this is the cubed-sphere size (e.g., 48
   for C48).

.. option:: JM_WORLD

   The number of grid boxes in the j-dimension. For a
   :literal:`LatLon` grid this is the number of latitude
   grid-boxes. For a :literal:`Cubed-Sphere` grid this is six
   times the cubed-sphere size (e.g., 288 for C48).

.. option:: POLE

   Required if the grid type is :literal:`LatLon`. :literal:`POLE` defines
   the latitude coordinates of the grid. For global lat-lon grids the
   valid options are :literal:`PC` (pole-centered) or :literal:`PE`
   (polar-edge). Here, "center" or "edge" refers to whether the grid
   has boxes that are centered on the poles, or whether the grid has
   boxes with edges at the poles. For regional grids :literal:`POLE`
   should be set to :literal:`XY` and the grid will have boxes with edges
   at the regional boundaries.

.. option:: DATELINE

   Required if the grid type is :literal:`LatLon`. :literal:`DATELINE`
   defines the longitude coordinates of the grid. For global lat-lon
   grids the valid options are :literal:`DC` (dateline-centered),
   :literal:`DE` (dateline-edge), :literal:`GC` (grenwich-centered), or
   :literal:`GE` (Greenwich-edge). If :literal:`DC` or :literal:`DE`,
   then the longitude coordinates will span (-180°, 180°). If
   :literal:`GC` or :literal:`GE`, then the longitude coordinates will
   span (0°, 360°). Similar to :literal:`POLE`, "center" or "edge"
   refer to whether the grid has boxes that are centered at -180° or
   0°, or whether the grid has boxes with edges at -180° or 0°. For
   regional grids :literal:`DATELINE` should be set to :literal:`XY`
   and the grid will have boxes with edges at the regional
   boundaries.

.. option:: LON_RANGE

   Required for regional :literal:`LatLon` grids. :option:`LON_RANGE`
   defines the longitude bounds of the regional grid.

.. option:: LAT_RANGE

   Required for regional :literal:`LatLon` grids. :option:`LAT_RANGE`
   defines the latitude bounds of the regional grid.

.. _defining-active-collections:

===========================
Defining Active Collections
===========================

Collections are activated by defining them in the
:literal:`COLLECTIONS` list. For instructions on defining collections,
see :ref:`defining-collections`.

Below is the format for the :literal:`<DEFINE ACTIVE COLLECTIONS>`
section of :file:`HISTORY.rc`.

.. code-block:: none

   COLLECTIONS:   'MyCollection1',
                  'MyCollection2',
   ::

This example activates collections named :literal:`MyCollection1` and
:literal:`MyCollection2`.

.. _defining-collections:

====================
Defining Collections
====================

A collection is

.. code-block:: none

   MyCollection1.template:    '%y4%m2%d2_%h2%n2z.nc4',
   MyCollection1.format:      'CFIO',
   MyCollection1.frequency:   010000
   MyCollection1.duration:    240000
   MyCollection1.mode:        'time-averaged'
   MyCollection1.fields:      'SpeciesConc_O3  ',  'GCHPchem',
                              'SpeciesConc_NO  ',  'GCHPchem',
                              'SpeciesConc_NO2 ',  'GCHPchem',
                              'Met_BXHEIGHT    ',  'GCHPchem',
                              'Met_AIRDEN      ',  'GCHPchem',
                              'Met_AD          ',  'GCHPchem',
   ::
   <DEFINE MORE COLLECTIONS ...>



Output file configuration
-------------------------

.. option:: template

   This is the file name suffix for the collection. The path to the
   collection's files is obtained by concatenating :option:`EXPID`
   with the collection name and the value of :literal:`template`.

.. option:: format

   Defines the file format of the collection. Valid values are
   :literal:`'CFIO'` for CF compliant NetCDF (recommended), or
   :literal:`'flat'` for GrADS style flat files.

.. option:: duration

   Defines the frequency at which files are generated. The format is
   :literal:`HHMMSS`. For example, :literal:`1680000` means that a
   file is generated every 168 hours (7 days).

.. option:: frequency

   Defines the time frequency of collection's data. Said another way,
   this defines the time separation (time step) of the time coordinate
   for the collection. The format is :literal:`HHMMSS`. For example,
   :literal:`010000` means that the collection's time coordinate will
   have a 1-hour time step. If :literal:`frequency` is less
   than :option:`duration` multiple time steps are written
   to each file.

.. option:: monthly

   **OPTIONAL**. Set to :literal:`1` for monthly output. One file per
   month is generated. If :literal:`mode` is :literal:`time-averaged`,
   the variables in the collection are 1-month time averages. Note
   that :option:`duration` and :option:`frequency` are not required
   if :option:`monthly` is set to :literal:`1`.

.. option:: timeStampStart

   **OPTIONAL**. Only used if :option:`mode` is
   :literal:`'time-averaged'`. If :literal:`.true.` the file is
   timestamped according to the start of the accumulation interval
   (which depends on :option:`frequency`, :option:`ref_date`, and
   :option:`ref_time`). If :literal:`.false.` the file is timestamped
   according to the middle of the accumulation interval. If
   :option:`timeStampStart` is not set then the default value is false.

Sampling configuration
--------------------------

.. option:: mode

   Defines the sampling method. Valid values are
   :literal:`'time-averaged'` or :literal:`'instantaneous'`.

.. option:: acc_interval

   **OPTIONAL**.  Only valid if :literal:`mode` is
   :literal:`'time-averaged'`. This specifies the length of the time
   average. By default it is equal to :literal:`frequency`.

.. option:: ref_date

   **OPTIONAL**. The reference date from which the frequency is
   based. The format is :literal:`YYYYMMDD`. For example, a frequency
   of :literal:`1680000` (7 days) with a reference date of `20210101`
   means that the time coordinate will be weeks since 2021-01-01. The
   default value is the simulation's start date.

.. option:: ref_time

   **OPTIONAL**. The reference time from which the frequency is
   based. The format is :literal:`HHMMSS`. The default value is
   :literal:`000000`. See :literal:`ref_date`.

.. option:: fields

   Defines the list of fields that this collection should use. The
   format (per-field) is :literal:`'FieldName', 'GridCompName',`. For
   example, :literal:`'SpeciesConcVV_O3', 'GCHPchem',` specifies that
   this collection should include the :literal:`SpeciesConcVV_O3`
   field from the `GCHPchem` gridded component.

   Fields from multiple gridded components can be included in the same
   collection. However, a collection must not mix fields that are
   defined at the center of vertical levels and the edges of vertical
   levels (e.g., :literal:`Met_PMID` and :literal:`Met_PEDGE` cannot
   be included in the same collection).

   Variables can be renamed in the output by adding
   :literal:`'your_custom_name',` at the end. For example,
   :literal:`'SpeciesConc_O3', 'GCHPchem',
   'ozone_concentration',` would rename the :literal:`SpeciesConc_O3`
   field to "ozone_concentration" in the output file.


Output grid configuration
-------------------------

.. option:: grid_label

   **OPTIONAL**. Defines the grid that this collection should be
   output on. The lable must match on of the grid labels defined in
   :ref:`\<DEFINE GRID LABELS\> <defining-grid-labels>`. If
   :option:`grid_label` isn't set then the collection uses the
   simulation's horizontal grid.

.. option:: conservative

   **OPTIONAL**. Defines whether or not regridding to the output grid
   should use ESMF's first-order conservative method. Valid values are
   :literal:`0` or :literal:`1`. It is recommended you set this to
   :literal:`1` if you are using :option:`grid_label`. The default
   value is :literal:`0`.

.. option:: levels:

   **OPTIONAL**. Defines the model levels that this collection should
   use (i.e., a subset of the simulation levels). The format is a
   space-separated list of values. The lowest layer is 1 and the
   highest layer is 72. For example, :literal:`1 2 5` would select the
   first, second, and fifth level of the simulation.

.. option:: track_file

   **OPTIONAL**. Defines the path to a 1D track file along which the
   collection is sampled. See :ref:`output-along-a-track` for more
   info.

.. option:: recycle_track

   **OPTIONAL**. Only valid if a :option:`track_file` is
   defined. Specifies that the track file should be reused every
   day. If :literal:`.true.` the dates in the track file are
   automatically forced to the simulation's current date. The default
   value is false.

Other configuration
-------------------

.. option:: end_date

   **OPTIONAL**. A date at which the collection is deactivated (turned
   off). By default there is no end date.

.. option:: end_time

   **OPTIONAL**. Time at which the collection is deactivated (turned
   off) on the :literal:`end_date`.

========================================
Example :file:`HISTORY.rc` configuration
========================================

Below is an example :file:`HISTORY.rc` that configures two output collection

#. 30-min instantaneous concentrations of O3, NO, NO2, and some
   meteorological parameters for the lowest 10 model levels on a
   0.1°x0.1° covering the US. Each file contains one day of data. |br|
   |br|

#. 24-hour time averages of O3, NO, and NO2 concentrations, NO
   emissions, and some meteorological parameters. The horizontal grid
   is the simulation's grid. All vertical levels are use. Each file
   contains one week worth of data, and files are generated relative
   to 2017-01-01.

.. code-block:: none

   EXPID:  OutputDir/GCHP
   EXPDSC: GEOS-Chem_devel
   CoresPerNode: 6
   VERSION: 1

   GRID_LABELS: RegionalGrid_US
   ::
      RegionalGrid_US.GRID_TYPE: LatLon
      RegionalGrid_US.IM_WORLD:   640
      RegionalGrid_US.JM_WORLD:   290
      RegionalGrid_US.POLE:        XY
      RegionalGrid_US.DATELINE:    XY
      RegionalGrid_US.LON_RANGE: -127 -63
      RegionalGrid_US.LAT_RANGE:   23  52

   COLLECTIONS: 'Inst30minGases',
         'DailyAvgGasesAndNOEmissions',
   ::
   Inst30minGases.template:    '%y4%m2%d2_%h2%n2z.nc4',
   Inst30minGases.format:      'CFIO',
   Inst30minGases.frequency:   003000
   Inst30minGases.duration:    240000
   Inst30minGases.mode:        'instantaneous'
   Inst30minGases.grid_label:  RegionalGrid_US
   Inst30minGases.levels:      1 2 3 4 5 6 7 8 9 10 11 12 13 14
   Inst30minGases.fields:     'SpeciesConc_O3  ',  'GCHPchem',
                              'SpeciesConc_NO  ',  'GCHPchem',
                              'SpeciesConc_NO2 ',  'GCHPchem',
                              'Met_BXHEIGHT    ',  'GCHPchem',
                              'Met_AIRDEN      ',  'GCHPchem',
                              'Met_AD          ',  'GCHPchem',
                              'Met_PS1WET      ',  'GCHPchem',
   ::
   DailyAvgGasesAndNOEmissions.template:     '%y4%m2%d2_%h2%n2z.nc4',
   DailyAvgGasesAndNOEmissions.format:       'CFIO',
   DailyAvgGasesAndNOEmissions.ref_date:     20170101
   DailyAvgGasesAndNOEmissions.frequency:    240000
   DailyAvgGasesAndNOEmissions.duration:    1680000
   DailyAvgGasesAndNOEmissions.mode:         'time-averaged'
   DailyAvgGasesAndNOEmissions.fields:       'SpeciesConc_O3  ',  'GCHPchem',
                                             'SpeciesConc_NO  ',  'GCHPchem',
                                             'SpeciesConc_NO2 ',  'GCHPchem',
                                             'EmisNO_Total    ',  'GCHPchem',
                                             'EmisNO_Aircraft ',  'GCHPchem',
                                             'EmisNO_Anthro   ',  'GCHPchem',
                                             'EmisNO_BioBurn  ',  'GCHPchem',
                                             'EmisNO_Lightning',  'GCHPchem',
                                             'EmisNO_Ship     ',  'GCHPchem',
                                             'EmisNO_Soil     ',  'GCHPchem',
                                             'EmisNO2_Anthro  ',  'GCHPchem',
                                             'EmisNO2_Ship    ',  'GCHPchem',
                                             'EmisO3_Ship     ',  'GCHPchem',
                                             'Met_BXHEIGHT    ',  'GCHPchem',
                                             'Met_AIRDEN      ',  'GCHPchem',
                                             'Met_AD          ',  'GCHPchem',
   ::
