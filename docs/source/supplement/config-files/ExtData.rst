ExtData.rc
==================

:file:`ExtData.rc` contains input variable and file read information for GCHP. 
Explanatory information about the file is located at the top of the configuration file in all run directories. 
The file format is the same as that used in the GEOS model, and GMAO/NASA documentation for it can be found at the ExtData component page on the GEOS-5 wiki.

The following two parameters are set at the top of the file:

Ext_AllowExtrat	
   Logical toggle to use data from nearest year available. This is set to true for GCHP. Note that GEOS-Chem Classic accomplishes the same effect but with more flexibility in :file:`HEMCO_Config.rc`. That functionality of :file:`HEMCO_Config.rc` is ignored in GCHP.

DEBUG_LEVEL	
   Turns MAPL ExtData debug prints on/off. This is set to 0 in GCHP (off), but may be set to 1 to enable. Beware that turning on ExtData debug prints greatly slows down the model, and prints are only done from the root thread. Use this when debugging problems with input files.

The rest of the file contains space-delimited lines, one for each variable imported to the model from an external file. 
Columns are as follows in order as they appear left to right in the file:

Export Name	
   Name of imported met field (e.g. ALBD) or HEMCO emissions container name (e.g. GEIA_NH3_ANTH).

Units	
   Unit string nested within single quotes. '1' indicates there is no unit conversion from the native units in the netCDF file.
Clim	
   Enter Y if the file is a 12 month climatology, otherwise enter N. If you specify it is a climatology ExtData the data can be on either one file or 12 files if they are templated appropriately with one per month.
Conservative	
   Enter Y the data should be regridded in a mass conserving fashion through a tile file. :literal:`F;{VALUE}` can also be used for fractional regridding. Otherwise enter N to use the non-conervative bilinear regridding.

Refresh 
   Time Template	Possible values include:
   
   * -: The field will only be updated once the first time ExtData runs
   * 0: Update the variable at every step. ExtData will do a linear interpolation to the current time using the available data.
   * %y4-%m2-%h2T%h2:%n2:00: Set the recurring time to update the file. The file will be updated when the evaluated template changes. For example, a template in the form %y4-%m2-%d2T12:00:00 will cause the variable to be updated at the start of a new day (i.e. when the clock hits 2007-08-02T00:00:00 it will update the variable but the time it will use for reading and interpolation is 2007-08-02T12:00:00).

Offset Factor	
   Factor the variable will be shifted by. Use none for no shifting.

Scale Factor	
   Factor the variable will be scaled by. Use none for no scaling.
   
External File Variable	
   The name of the variable in the netCDF data file, e.g. ALBEDO in met fields.

External File Template	
   Path to the netCDF data file. If not using the data, specify :file:`/dev/null` to reduce processing time. If there are no tokens in the template name ExtData will assume that all the data is on one file. Note that if the data on file is at a different resolution that the application grid, the underlying I/O library ExtData uses will regrid the data to the application grid.
