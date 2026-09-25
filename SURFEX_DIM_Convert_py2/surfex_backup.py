'''
NAME
    NetCDF with Python
PURPOSE
    To demonstrate how to read and write data with NetCDF files using
    a NetCDF file from the NCEP/NCAR Reanalysis.
    Plotting using Matplotlib and Basemap is also shown.
PROGRAMMER(S)
    Chris Slocum
REVISION HISTORY
    20140320 -- Initial version created and posted online
    20140722 -- Added basic error handling to ncdump
                Thanks to K.-Michael Aye for highlighting the issue
REFERENCES
    netcdf4-python -- http://code.google.com/p/netcdf4-python/
    NCEP/NCAR Reanalysis -- Kalnay et al. 1996
        http://dx.doi.org/10.1175/1520-0477(1996)077<0437:TNYRP>2.0.CO;2
'''

import datetime as dt  # Python standard library datetime  module
import numpy as np
from netCDF4 import Dataset  # http://code.google.com/p/netcdf4-python/
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap, addcyclic, shiftgrid


def ncdump(nc_fid, verb=True):
    '''
    ncdump outputs dimensions, variables and their attribute information.
    The information is similar to that of NCAR's ncdump utility.
    ncdump requires a valid instance of Dataset.

    Parameters
    ----------
    nc_fid : netCDF4.Dataset
        A netCDF4 dateset object
    verb : Boolean
        whether or not nc_attrs, nc_dims, and nc_vars are printed

    Returns
    -------
    nc_attrs : list
        A Python list of the NetCDF file global attributes
    nc_dims : list
        A Python list of the NetCDF file dimensions
    nc_vars : list
        A Python list of the NetCDF file variables
    '''
    def print_ncattr(key):
        """
        Prints the NetCDF file attributes for a given key

        Parameters
        ----------
        key : unicode
            a valid netCDF4.Dataset.variables key
        """
        try:
            print "\t\ttype:", repr(nc_fid.variables[key].dtype)
            for ncattr in nc_fid.variables[key].ncattrs():
                print '\t\t%s:' % ncattr,\
                      repr(nc_fid.variables[key].getncattr(ncattr))
        except KeyError:
            print "\t\tWARNING: %s does not contain variable attributes" % key

    # NetCDF global attributes
    nc_attrs = nc_fid.ncattrs()
    if verb:
        print "NetCDF Global Attributes:"
        for nc_attr in nc_attrs:
            print '\t%s:' % nc_attr, repr(nc_fid.getncattr(nc_attr))
    nc_dims = [dim for dim in nc_fid.dimensions]  # list of nc dimensions
    # Dimension shape information.
    if verb:
        print "NetCDF dimension information:"
        for dim in nc_dims:
            print "\tName:", dim 
            print "\t\tsize:", len(nc_fid.dimensions[dim])
            print_ncattr(dim)
    # Variable information.
    nc_vars = [var for var in nc_fid.variables]  # list of nc variables
    if verb:
        print "NetCDF variable information:"
        for var in nc_vars:
            if var not in nc_dims:
                print '\tName:', var
                print "\t\tdimensions:", nc_fid.variables[var].dimensions
                print "\t\tsize:", nc_fid.variables[var].size
                print_ncattr(var)
    return nc_attrs, nc_dims, nc_vars

# Read netcdf file: 1D
nc_file_1D = '/nobackup/rossby21/sm_fuxwa/SURFEX_OUT/EXP2D_MUMS_V73_SRC_VARY/OUT_201501/SURF_ATM_DIAGNOSTICS.OUT.nc'  # Input nc filename
nc_file_1D_id = Dataset(nc_file_1D, 'r')  # Dataset is the class behavior to open the file
                             # and create an instance of the ncCDF4 class
nc_attrs, nc_dims, nc_vars = ncdump(nc_file_1D_id)
# Extract data from NetCDF file

#npoint = nc_file_1D_id.variables['Number_of_points'][:]  # extract/copy the data

xxs = nc_file_1D_id.variables['xx'][:]  # extract/copy the data
yys = nc_file_1D_id.variables['yy'][:]

#lats = nc_file_1D_id.variables['lat'][:]  # extract/copy the data
#lons = nc_file_1D_id.variables['lon'][:]
time = nc_file_1D_id.variables['time'][:]
time_idx = 2  # some random day in 2012

LE = nc_file_1D_id.variables['LE'][:]  # shape is time, Number_of_points as shown above

# Python and the renalaysis are slightly off in time so this fixes that problem
offset = dt.timedelta(hours=0)
# List of all times in the file as datetime objects
dt_time = [dt.date(1, 1, 1) + dt.timedelta(hours=t) - offset\
           for t in time]
cur_time = dt_time[time_idx]


# Read netcdf file: 2D
nc_file_2D = '/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/HCLIM38_FORC_MUMS_SCA_VARY_2015010100.nc'  # Input nc filename
nc_file_2D_id = Dataset(nc_file_2D, 'r')  # Dataset is the class behavior to open the file
                             # and create an instance of the ncCDF4 class
nc2d_attrs, nc2d_dims, nc2d_vars = ncdump(nc_file_2D_id)

# Extract data from NetCDF file
lons = nc_file_2D_id.variables['longitude'][:]  # extract/copy the data
lats = nc_file_2D_id.variables['latitude'][:]
y = nc_file_2D_id.variables['y'][:] 
x = nc_file_2D_id.variables['x'][:]
#time = nc_file_2D_id.variables['time'][:]
print 'y=', y
#LE = nc_file_2D_id.variables['LE'][:]  # shape is time, lat, lon as shown above

time_idx = 2  # some random day in 2012



# Convert 1D to 2D
print 'LE:', type(LE), len(LE), np.shape(LE)
LE_2D = np.reshape(LE, (len(time), len(y), len(x)))



# Python and the renalaysis are slightly off in time so this fixes that problem
offset = dt.timedelta(hours=0)
# List of all times in the file as datetime objects
dt_time = [dt.date(1, 1, 1) + dt.timedelta(hours=t) - offset\
           for t in time]
cur_time = dt_time[time_idx]


'''
# Plot of global temperature on our random day
fig = plt.figure()
fig.subplots_adjust(left=0., right=1., bottom=0., top=0.9)
# Setup the map. See http://matplotlib.org/basemap/users/mapsetup.html
# for other projections.
m = Basemap(projection='moll', llcrnrlat=-90, urcrnrlat=90,\
            llcrnrlon=0, urcrnrlon=360, resolution='c', lon_0=0)
m.drawcoastlines()
m.drawmapboundary()
# Make the plot continuous
air_cyclic, lons_cyclic = addcyclic(air[time_idx, :, :], lons)
# Shift the grid so lons go from -180 to 180 instead of 0 to 360.
air_cyclic, lons_cyclic = shiftgrid(180., air_cyclic, lons_cyclic, start=False)
# Create 2D lat/lon arrays for Basemap
lon2d, lat2d = np.meshgrid(lons_cyclic, lats)
# Transforms lat/lon into plotting coordinates for projection
x, y = m(lon2d, lat2d)
# Plot of air temperature with 11 contour intervals
cs = m.contourf(x, y, air_cyclic, 11, cmap=plt.cm.Spectral_r)
cbar = plt.colorbar(cs, orientation='horizontal', shrink=0.5)
cbar.set_label("%s (%s)" % (nc_file_1D_id.variables['air'].var_desc,\
                            nc_file_1D_id.variables['air'].units))
plt.title("%s on %s" % (nc_file_1D_id.variables['air'].var_desc, cur_time))
'''

# Writing NetCDF files
# For this example, we will create two NetCDF4 files. One with the global air
# temperature departure from its value at Darwin, Australia. The other with
# the temperature profile for the entire year at Darwin.
darwin = {'name': 'Darwin, Australia', 'lat': -12.45, 'lon': 130.83}

# Find the nearest latitude and longitude for Darwin
#lat_idx = np.abs(lats - darwin['lat']).argmin()
#lon_idx = np.abs(lons - darwin['lon']).argmin()

# Simple example: temperature profile for the entire year at Darwin.
# Open a new NetCDF file to write the data to. For format, you can choose from
# 'NETCDF3_CLASSIC', 'NETCDF3_64BIT', 'NETCDF4_CLASSIC', and 'NETCDF4'
w_nc_file_out_id = Dataset('SURFEX_1Dto2D_test.nc', 'w', format='NETCDF4')
#w_nc_file_out_id.description = "Reanalysis %s from its value at %s. %s" %\
#                      (nc_file_out_id.variables['LE'].var_desc.lower(),\
#                       darwin['name'], nc_file_out_id.description)
# Using our previous dimension info, we can create the new time dimension
# Even though we know the size, we are going to set the size to unknown
w_nc_file_out_id.createDimension('time', None)
w_nc_file_out_id.createDimension('y', None)
w_nc_file_out_id.createDimension('x', None)
w_nc_dim = w_nc_file_out_id.createVariable('time', nc_file_1D_id.variables['time'].dtype,\
                                   ('time',))
w_nc_dim = w_nc_file_out_id.createVariable('y', nc_file_2D_id.variables['y'].dtype,\
                                   ('y',))
w_nc_dim = w_nc_file_out_id.createVariable('x', nc_file_2D_id.variables['x'].dtype,\
                                   ('x',))
# You can do this step yourself but someone else did the work for us.
for ncattr in nc_file_1D_id.variables['time'].ncattrs():
    print 'ncattr.', ncattr
    #w_nc_dim.setncattr(ncattr, nc_file_1D_id.variables['time'].getncattr(ncattr))
# Assign the dimension data to the new NetCDF file.
w_nc_file_out_id.variables['time'][:] = time
w_nc_file_out_id.variables['y'][:] = y
w_nc_file_out_id.variables['x'][:] = x

w_nc_var = w_nc_file_out_id.createVariable('LE', 'f8', ('time', 'y', 'x'))
w_nc_var = w_nc_file_out_id.createVariable('latitude', nc_file_2D_id.variables['latitude'].dtype,\
                                   ('y', 'x'))
w_nc_var = w_nc_file_out_id.createVariable('longitude', nc_file_2D_id.variables['longitude'].dtype,\
                                   ('y', 'x'))
w_nc_var.setncatts({'long_name': u"mean Daily Air temperature",\
                    'units': u"degK", 'level_desc': u'Surface',\
                    'var_desc': u"Air temperature",\
                    'statistic': u'Mean\nM'})
w_nc_file_out_id.variables['LE'][:] = LE_2D
w_nc_file_out_id.variables['latitude'][:] = lats
w_nc_file_out_id.variables['longitude'][:] = lons
w_nc_file_out_id.close()  # close the new file

'''
# A plot of the temperature profile for Darwin in 2012
fig = plt.figure()
plt.plot(dt_time, air[:, lat_idx, lon_idx], c='r')
plt.plot(dt_time[time_idx], air[time_idx, lat_idx, lon_idx], c='b', marker='o')
plt.text(dt_time[time_idx], air[time_idx, lat_idx, lon_idx], cur_time,\
         ha='right')
fig.autofmt_xdate()
plt.ylabel("%s (%s)" % (nc_file_1D_id.variables['air'].var_desc,\
                        nc_file_1D_id.variables['air'].units))
plt.xlabel("Time")
plt.title("%s from\n%s for %s" % (nc_file_1D_id.variables['air'].var_desc,\
                                  darwin['name'], cur_time.year))
'''

# Complex example: global temperature departure from its value at Darwin
departure = air[:, :, :] - air[:, lat_idx, lon_idx].reshape((time.shape[0],\
                                                             1, 1))

# Open a new NetCDF file to write the data to. For format, you can choose from
# 'NETCDF3_CLASSIC', 'NETCDF3_64BIT', 'NETCDF4_CLASSIC', and 'NETCDF4'
w_nc_file_1D_id = Dataset('air.departure.sig995.2012.nc', 'w', format='NETCDF4')
w_nc_file_1D_id.description = "The departure of the NCEP/NCAR Reanalysis " +\
                      "%s from its value at %s. %s" %\
                      (nc_file_1D_id.variables['air'].var_desc.lower(),\
                       darwin['name'], nc_file_1D_id.description)
# Using our previous dimension information, we can create the new dimensions
data = {}
for dim in nc_dims:
    w_nc_file_1D_id.createDimension(dim, nc_file_1D_id.variables[dim].size)
    data[dim] = w_nc_file_1D_id.createVariable(dim, nc_file_1D_id.variables[dim].dtype,\
                                        (dim,))
    # You can do this step yourself but someone else did the work for us.
    for ncattr in nc_file_1D_id.variables[dim].ncattrs():
        data[dim].setncattr(ncattr, nc_file_1D_id.variables[dim].getncattr(ncattr))
# Assign the dimension data to the new NetCDF file.
w_nc_file_1D_id.variables['time'][:] = time
w_nc_file_1D_id.variables['lat'][:] = lats
w_nc_file_1D_id.variables['lon'][:] = lons

# Ok, time to create our departure variable
w_nc_var = w_nc_file_1D_id.createVariable('air_dep', 'f8', ('time', 'lat', 'lon'))
w_nc_var.setncatts({'long_name': u"mean Daily Air temperature departure",\
                    'units': u"degK", 'level_desc': u'Surface',\
                    'var_desc': u"Air temperature departure",\
                    'statistic': u'Mean\nM'})
w_nc_file_1D_id.variables['air_dep'][:] = departure
w_nc_file_1D_id.close()  # close the new file

# Rounded maximum absolute value of the departure used for contouring
max_dep = np.round(np.abs(departure[time_idx, :, :]).max()+5., decimals=-1)

'''
# Generate a figure of the departure for a single day
fig = plt.figure()
fig.subplots_adjust(left=0., right=1., bottom=0., top=0.9)
m = Basemap(projection='moll', llcrnrlat=-90, urcrnrlat=90,\
            llcrnrlon=0, urcrnrlon=360, resolution='c', lon_0=0)
m.drawcoastlines()
m.drawmapboundary()
dep_cyclic, lons_cyclic = addcyclic(departure[time_idx, :, :], lons)
dep_cyclic, lons_cyclic = shiftgrid(180., dep_cyclic, lons_cyclic, start=False)
lon2d, lat2d = np.meshgrid(lons_cyclic, lats)
x, y = m(lon2d, lat2d)
levels = np.linspace(-max_dep, max_dep, 11)
cs = m.contourf(x, y, dep_cyclic, levels=levels, cmap=plt.cm.bwr)
x, y = m(darwin['lon'], darwin['lat'])
plt.plot(x, y, c='c', marker='o')
plt.text(x, y, 'Darwin,\nAustralia', color='r', weight='semibold')
cbar = plt.colorbar(cs, orientation='horizontal', shrink=0.5)
cbar.set_label("%s departure (%s)" % (nc_file_1D_id.variables['air'].var_desc,\
                            nc_file_1D_id.variables['air'].units))
plt.title("Departure of Global %s from\n%s for %s" %\
          (nc_file_1D_id.variables['air'].var_desc, darwin['name'], cur_time))
plt.show()
'''

# Close original NetCDF file.
nc_file_1D_id.close()
