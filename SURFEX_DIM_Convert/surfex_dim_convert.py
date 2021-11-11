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
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap, addcyclic, shiftgrid
import ncdump as nd
import os, sys
import get_configuration


# Get some definitions
HCLIMEXP, SURFEXEXP, name_surfex_file = get_configuration.get_conf()

# dir_surfex_sim: the SURFEX run output (1D) directory
# dir_surfex_2d:  the 2D SURFEX forcing data directory
# file_surfex_2d: the 2D SURFEX forcing data file name

ntile = 2 # Number of tiles
dir_surfex_month='OUT_201807'
if HCLIMEXP=='NorCP_ALADIN_ERAI':
    dir_surfex_sim='/nobackup/rossby18/rossby/joint_exp/harmony/MUMS/SURFEX_OUT/SURFEX73_MUMS_500m_ALADIN12km_' + str(SURFEXEXP)
    dir_surfex_2d='/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS'
    file_surfex_2d='HCLIM38_FORC_MUMS_ml_SCA_ZERO_201807.nc'

elif HCLIMEXP=='NorCP_ERAI_ALD_AROME':
    dir_surfex_sim='/nobackup/rossby18/rossby/joint_exp/harmony/MUMS/SURFEX_OUT/SURFEX73_MUMS_500m_AROME3km_' + str(SURFEXEXP)
    dir_surfex_2d='/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS'
    file_surfex_2d='HCLIM38_FORC_MUMS_ml_SCA_ZERO_2018070100.nc'

elif HCLIMEXP=='HCLIM38_Summer2018_STKHM_NEW':
    dir_surfex_sim='/nobackup/rossby24/users/sm_fuxwa/SURFEX_OUT/GreenWave/'+str(SURFEXEXP)
    dir_surfex_2d='/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave'
    file_surfex_2d='HCLIM38_FORC_GreenWave_ml_SCA_VARY_2018070100.nc'

elif HCLIMEXP=='HCLIM38_Summer2018_STKHM_NEW_defaultPhys':
    dir_surfex_sim='/nobackup/rossby24/users/sm_fuxwa/SURFEX_OUT/GreenWave/'+str(SURFEXEXP)
    dir_surfex_2d='/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave'
    file_surfex_2d='HCLIM38_FORC_GreenWave_ml_SCA_VARY_2018070100.nc'

elif HCLIMEXP=='MUMS_TEST_3km':
    dir_surfex_sim='/nobackup/rossby21/sm_fuxwa/SURFEX_OUT/EXP2D_MUMS2'
    dir_surfex_2d='/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS_TEST'
    file_surfex_2d='HCLIM38_FORC_MUMS_SCA_ZERO_2015010100.nc'
    dir_surfex_month='OUT_201501'

elif HCLIMEXP=='MUMS_Forcing_500m':
    dir_surfex_sim='/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS'
    dir_surfex_2d='/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS'
    file_surfex_2d='HCLIM38_FORC_MUMS_ml_SCA_ZERO_2018070100.nc'
    dir_surfex_month='SURFEX_FORC'

elif HCLIMEXP=='HCLIM38_Summer2018_STKHM_NEWphys':
    dir_surfex_sim='/nobackup/rossby26/users/sm_fuxwa/SURFEX_EXP/GreenWave/'+str(SURFEXEXP)
    dir_surfex_2d='/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave'
    file_surfex_2d='HCLIM38_FORC_GreenWave_mlL65_SCA_VARY_300m_2018070100.nc'

elif HCLIMEXP=='HCLIM38_Summer2018_STKHM_DEFphys':
    dir_surfex_sim='/nobackup/rossby26/users/sm_fuxwa/SURFEX_OUT/GreenWave/'+str(SURFEXEXP)
    dir_surfex_2d='/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave'
    file_surfex_2d='HCLIM38_FORC_GreenWave_mlL65_SCA_VARY_300m_2018070100.nc'

var_nature_tile_list = ['T2M_P', 'Q2M_P', 'HU2M_P', 'ZON10M_P', 'MER10M_P', 'LE_P', 'H_P', 'RN_P', 'SWD_P', 'SWU_P', 'LWD_P', 'LWU_P']
var_isba_list = ['T2M_ISBA', 'Q2M_ISBA', 'HU2M_ISBA', 'ZON10M_ISBA', 'MER10M_ISBA', 'LE_ISBA', 'H_ISBA', 'RN_ISBA', 'SWD_ISBA', 'SWU_ISBA', 'LWD_ISBA', 'LWU_ISBA']


# Creat directory
if not os.path.exists(dir_surfex_sim + '/OUT_2D/'):
    os.mkdir(dir_surfex_sim + '/OUT_2D/')

nc_file_1D = dir_surfex_sim + '/' + dir_surfex_month + '/' + name_surfex_file + '.nc'  # Input nc filename
nc_file_2D = dir_surfex_2d + '/HCLIM38_SIM_2D/' + HCLIMEXP + '/' + file_surfex_2d  
nc_file_out = dir_surfex_sim + '/OUT_2D/' + name_surfex_file + '.2D.nc'


#########################################################
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

