ExtData.rc
==========

:file:`ExtData.rc` contains input variable and file read information for GCHP. 
Explanatory information about the file is located at the top of the configuration file in all run directories. 
The file format is the same as that used in the GEOS model, and GMAO/NASA documentation for it can be found at the ExtData component page on the GEOS-5 wiki.
Note that this file will be retired in GCHP v15.0 when MAPL version 3 is integrated into GCHP. It will be replaced with a YAML format file with a
simplified and easier to understand interface.

The ins and outs of :file:`ExtData.rc` can be hard to grasp, particular with regards to variable data
updating, time interpolation, and file read. Reach out on the GCHP GitHub Issues page if you need help. See also the GCHP ReadTheDocs page on enabling
ExtData prints for debugging. Enabling ExtData debug prints is the best way to determine what MAPL is doing for file I/O per import.

The following parameter is set at the top of the file:

Ext_AllowExtrap
   Logical toggle to use data from nearest year available, including meteorology if files for the simulation year are not found. This is set to true for GCHP. Note that GEOS-Chem Classic accomplishes the same effect but with more flexibility in :file:`HEMCO_Config.rc`, and the entries of :file:`HEMCO_Config.rc` which do this are ignored in GCHP.

The rest of the file contains whitespace-delimited lines. Each line describes one data variable imported to the model from an external file. 
Columns are as follows in order from left to right:

Name	
   Name of the field stored in the MAPL Imports container. This is independent of the name of the data field in the input file. For the case of entries that also appear in :file:`HEMCO_Config.rc` it is also the name of the HEMCO emissions container (left-most column in that file). For those fields it is used to match scaling and masking information in :file:`HEMCO_Config.rc` with file I/O information in :file:`ExtData.rc`. All file I/O information :file:`HEMCO_Config.rc`, including filename, units, dimensions, regridding, and read frequency are ignored by GCHP.

Units	
   Unit string of the import. This entry is informational only.

Clim	
   Whether the data is climatology. Enter :file:`Y` if the data is a 12 month climatology, enter year if the data is daily climatology (i.e. :file:`2019`), :file:`D` if the file is monthly day-of-week scale factors (7 values for each of 12 months), or :file:`N` for all other cases. If you specify monthly climatology then the data must be stored in either 1 or 12 files.

Conservative	
   Method to regrid the input data to the simulation grid. Enter :file:`Y` to use mass conserving regridding, :literal:`F;{VALUE}` for fractional regridding, or :file:`N` to use non-conervative bilinear regridding.

Refresh 
   Time template for updating data. This tells MAPL when to look for new data values. It stores previous and next time data in what are called left and right brackets. There are several options for specifying refresh:
   
   * :file:`-` : Update variable data only once. Use this if the data is constant in time.
   * :file:`0` : Update variable data at every timestep using linear interpolation. For example, if the data is hourly then MAPL will linearly interpolate between the previous and next hour's data for every timestep.
   * :file:`0:003000` (or other HHMMSS specification for hours, minutes, seconds) : Use specified time offset (i.e. 30 minutes in this example) for setting previous and next time, and interpolate every timestep between the two. This is useful if, for example, you have time-averaged hourly data and you want the previous and next times to update half-way between the hour. This format is used for meteorology fields that are interpolated every timestep, specifically temperature and surface pressure.
   * :file:`F0:003000` (or other HHMMSS specification for hours, minutes, seconds) : Like the previous option except there is no time interpolation. This format is used for meteorology fields that are not time-interpolated, such as cloud fraction.
   * :file:`%y4-%m2-%h2T%h2:%n2:00` (or other combination of time tokens) : Update variable data when time tokens change. Interpreting this entry gets a little tricky. The data will be updated when the time tokens change, not the hard-coded times. For example, a template in the form :file:`%y4-%m2-%d2T12:00:00` changes at the start of each day because that is when the evaluation of :file:`%y4-%m2-%d2` changes. While the variable will be updated at the start of a new day (e.g. at time 2019-01-02 00:00:00), the time used for reading and interpolation is hour 12 of that day. You can similar hard-code year, month, day, or hour if you always want to use a constant value for that field.
   * :file:`F%y4-%m2-%h2T%h2:%n2:00` (or other combination of time tokens) : Like the previous option except that there is no time interpolation.

Offset Factor	
   Value the data will be shifted by upon read. Use :file:`none` for no shifting.

Scale Factor	
   Value the data will be scaled by upon read. This is useful if you want to convert units upon read, such as from :file:`Pa` to :file:`hPa`. Use :file:`none` for no scaling.
   
External File Variable	
   Name of the variable to read in the netCDF data file.

External File Template	
   Path to the netCDF data file, including time tokens as needed (:file:`%y4` for year, :file:`%m2` for month, :file:`%d2` for day, :file:`%h2` for hour, :file:`%n2` for minutes). If there are no time tokens in the template name then ExtData will assume that all the data is in one file. If you wish to ignore an entry in :file:`ExtData.rc` (i.e. not read the data at all since you will not use it) then put :file:`/dev/null`. This will save processing time.

Reference Time and Period (optional)
   Period of data with reference time. This optional entry is useful if you have data frequency that is offset from midnight. For example, 3-hourly data available for times 1:30, 4:30, 7:30, etc. The reference time could be specified as :file:`2000-01-01T01:30:00P03:00`. The first part (before :file:`P`) is the reference date (must be on or before your simulation start), and the second part (after :file:`P`) is the period of data availability (in this case 3 hours). This can be used in combination with the file template containing hours and minutes. It tells MAPL to only read the file at times that are regular 3 hr intervals from the reference date and time. Not including this would cause MAPL to read the file every minute if the file template contains the :file:`n2` time token. 
