'''
Objective:
    To convert the SURFEX outputs from 1D (Number_of_points) to 2D (lon, lat)

Author:
    Fuxing Wang, 11 June, 2019

Updated:
    Fuxing Wang, 6 July, 2020, add GreenWave options

References:
    http://schubert.atmos.colostate.edu/~cslocum/netcdf_example.html#code
    netcdf4-python -- http://code.google.com/p/netcdf4-python/
'''

import datetime as dt  # Python standard library datetime  module
import numpy as np
from netCDF4 import Dataset  # http://code.google.com/p/netcdf4-python/
import ncdump as nd
import os, sys

#########################################################

def nc_1D_to_2D(name_surfex_file, nc_file_1D, nc_file_2D, nc_file_out, ntile, var_isba_list):
  #
  # Read 1D netcdf file
  #
  nc_file_1D_id = Dataset(nc_file_1D, 'r')  # Dataset is the class behavior to open the file, and create an instance of the ncCDF4 class
  nc_attrs_1d, nc_dims_1d, nc_vars_1d = nd.ncdump(nc_file_1D_id)

  # only for ISBA_DIAGNOSTICS.OUT, because its 1D file is too big, we select few variables to convert to 2D!!!
  if name_surfex_file == 'ISBA_DIAGNOSTICS.OUT':  
    nc_vars_1d = list(set(nc_vars_1d).intersection(set(var_isba_list)))

  # Extract data from NetCDF file
  time_1d = nc_file_1D_id.variables['time'][:]
  #xx_1d = nc_file_1D_id.variables['xx'][:]  # extract/copy the data
  #yy_1d = nc_file_1D_id.variables['yy'][:]
  #nb_point = nc_file_1D_id.variables['Number_of_points'][:]  # extract/copy the data

  #
  # Read 2D netcdf file
  #
  nc_file_2D_id = Dataset(nc_file_2D, 'r')  
  nc_attrs_2d, nc_dims_2d, nc_vars_2d = nd.ncdump(nc_file_2D_id)

  # Extract data from NetCDF file
  #lon_2d = nc_file_2D_id.variables['longitude'][:]  # extract/copy the data
  #lat_2d = nc_file_2D_id.variables['latitude'][:]
  x = nc_file_2D_id.variables['x'][:]
  y = nc_file_2D_id.variables['y'][:] 

  #
  # Write NetCDF files
  #
  # Open a new NetCDF file to write the data to. 
  # Choose format from 'NETCDF3_CLASSIC', 'NETCDF3_64BIT', 'NETCDF4_CLASSIC', and 'NETCDF4'
  w_nc_file_out_id = Dataset(nc_file_out, 'w', format='NETCDF4')
  w_nc_file_out_id.description = "Convert SURFEX output from 1D (landpoint) to 2D (lon, lat)." 

  # Using our previous dimension info, we can create the new time dimension
  # Even though we know the size, we are going to set the size to unknown
  data_dim = {}
  for dim in nc_dims_2d:
    print 'dim:', dim
    w_nc_file_out_id.createDimension(dim, None)
    if dim in nc_file_2D_id.variables:
        data_dim[dim] = w_nc_file_out_id.createVariable(dim, nc_file_2D_id.variables[dim].dtype,\
                                   (dim,)) 
        # You can do this step yourself but someone else did the work for us.
        for ncattr in nc_file_2D_id.variables[dim].ncattrs():
            data_dim[dim].setncattr(ncattr, nc_file_2D_id.variables[dim].getncattr(ncattr))

  if 'Number_of_Tile' in nc_dims_1d:
    w_nc_file_out_id.createDimension('Number_of_Tile', ntile)
    data_dim['Number_of_Tile'] = w_nc_file_out_id.createVariable('Number_of_Tile', 'i4', ('Number_of_Tile',)) 

  # Assign the dimension data to the new NetCDF file.
  w_nc_file_out_id.variables['time'][:] = time_1d
  w_nc_file_out_id.variables['y'][:] = y
  w_nc_file_out_id.variables['x'][:] = x

  # Time varied variables
  data_var={}

  #print 'nc_file_2D_id.variables[var].dimensions:', nc_file_1D_id.variables['xx'].dimensions == ('Number_of_points', )
  #print 'nc_file_2D_id.variables[var].dimensions:', nc_file_1D_id.variables['LE'].dimensions # == ('time', 'Number_of_points')

  # Constant variable
  for var in nc_vars_2d:
    if 'longitude' in var or 'latitude' in var:
	data_var[var] = w_nc_file_out_id.createVariable(var, nc_file_2D_id.variables[var].dtype,\
                                   nc_file_2D_id.variables[var].dimensions)
        for ncattr in nc_file_2D_id.variables[var].ncattrs():
            data_var[var].setncattr(ncattr, nc_file_2D_id.variables[var].getncattr(ncattr))
        w_nc_file_out_id.variables[var][:] = nc_file_2D_id.variables[var][:]

  for var in nc_vars_1d:
    if nc_file_1D_id.variables[var].dimensions != ('time', 'Number_of_Tile', 'Number_of_points'):
      if var != 'time' and var != 'Projection_Type' and var != 'FRC_TIME_STP':
  	var_1D = nc_file_1D_id.variables[var][:]  # shape is time, Number_of_points
  	print 'shape of var_1D:', np.shape(var_1D), var

        if nc_file_1D_id.variables[var].dimensions == ('time', 'Number_of_points'):
            # Convert variables from 1D to 2D
            var_2D = np.reshape(var_1D, (len(time_1d), len(y), len(x))) # Shape is time, y, x
            print 'shape of var_2D:', np.shape(var_2D)

            # Create variable
            data_var[var] = w_nc_file_out_id.createVariable(var, nc_file_1D_id.variables[var].dtype, \
							('time', 'y', 'x')) 	

        elif nc_file_1D_id.variables[var].dimensions == ('Number_of_points',):
            var_2D = np.reshape(var_1D, (len(y), len(x)))
            data_var[var] = w_nc_file_out_id.createVariable(var, nc_file_1D_id.variables[var].dtype, \
							('y', 'x'))

        elif nc_file_1D_id.variables[var].dimensions == ('Number_of_Tile', 'Number_of_points'):
            var_2D = np.reshape(var_1D, (ntile, len(y), len(x))) 
            data_var[var] = w_nc_file_out_id.createVariable(var, nc_file_1D_id.variables[var].dtype, \
							('Number_of_Tile', 'y', 'x'))
        # Attributes:
        for ncattr in nc_file_1D_id.variables[var].ncattrs():
            data_var[var].setncattr(ncattr, nc_file_1D_id.variables[var].getncattr(ncattr))

        # Assign values to variables
        w_nc_file_out_id.variables[var][:] = var_2D

    elif nc_file_1D_id.variables[var].dimensions == ('time', 'Number_of_Tile', 'Number_of_points'):
      # Only some variables are converted to save time
      #if var in var_nature_tile_list:
  	var_1D = nc_file_1D_id.variables[var][:]  # shape is time, Number_of_points
  	print 'shape of var_1D:', np.shape(var_1D), var

    	for i_tile in range(ntile):
	    var_tile = var + '_P' + str(i_tile+1)
            var_2D = np.reshape(var_1D, (len(time_1d), ntile, len(y), len(x))) 
            #data_var[var] = w_nc_file_out_id.createVariable(var, nc_file_1D_id.variables[var].dtype, \
	    #					('time', 'Number_of_Tile', 'y', 'x'))
            data_var[var_tile] = w_nc_file_out_id.createVariable(var_tile, nc_file_1D_id.variables[var].dtype, \
							('time', 'y', 'x'))
            # Attributes:
            for ncattr in nc_file_1D_id.variables[var].ncattrs():
                data_var[var_tile].setncattr(ncattr, nc_file_1D_id.variables[var].getncattr(ncattr))
            # Assign values to variables
            w_nc_file_out_id.variables[var_tile][:] = var_2D[:,i_tile,:,:]

  #
  # Close NetCDF files.
  #
  nc_file_1D_id.close()
  nc_file_2D_id.close()
  w_nc_file_out_id.close()  

