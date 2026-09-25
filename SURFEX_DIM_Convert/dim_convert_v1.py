import numpy as np
from netCDF4 import Dataset  # http://code.google.com/p/netcdf4-python/
import ncdump as nd

# BRIGHT
extension_x = 11
extension_y = 11

#########################################################

def _create_var_like(nc_out_id, name, src_var, dimensions):
    """
    Create a variable in nc_out_id matching src_var's dtype and attributes,
    handling _FillValue correctly (netCDF4 requires it to be passed via the
    fill_value keyword at creation time, not set afterward with setncattr).
    """
    fill_value = None
    if '_FillValue' in src_var.ncattrs():
        fill_value = src_var.getncattr('_FillValue')

    new_var = nc_out_id.createVariable(name, src_var.dtype, dimensions, fill_value=fill_value)

    for ncattr in src_var.ncattrs():
        if ncattr == '_FillValue':
            continue  # already set via fill_value= above
        new_var.setncattr(ncattr, src_var.getncattr(ncattr))

    return new_var


def nc_1D_to_2D(name_surfex_file, nc_file_1D, nc_file_2D, nc_file_out, ntile,
                 var_isba_list, var_isba_veg_evolution_list):

    #
    # Read 1D netcdf file
    #
    nc_file_1D_id = Dataset(nc_file_1D, 'r')  # Dataset is the class behavior to open the file, and create an instance of the ncCDF4 class
    nc_attrs_1d, nc_dims_1d, nc_vars_1d = nd.ncdump(nc_file_1D_id)

    # only for ISBA_DIAGNOSTICS.OUT, because its 1D file is too big, we select few variables to convert to 2D!!!
    if name_surfex_file == 'ISBA_DIAGNOSTICS.OUT':
        nc_vars_1d = list(set(nc_vars_1d).intersection(set(var_isba_list)))

    elif name_surfex_file == 'ISBA_VEG_EVOLUTION.OUT':
        nc_vars_1d = list(set(nc_vars_1d).intersection(set(var_isba_veg_evolution_list)))

    # Extract data from NetCDF file
    time_1d = nc_file_1D_id.variables['time'][:]

    #
    # Read 2D netcdf file
    #
    nc_file_2D_id = Dataset(nc_file_2D, 'r')
    nc_attrs_2d, nc_dims_2d, nc_vars_2d = nd.ncdump(nc_file_2D_id)

    x = nc_file_2D_id.variables['x'][:-extension_x]
    y = nc_file_2D_id.variables['y'][:-extension_y]

    print('x, y', len(x), len(y))

    #
    # Write NetCDF files
    #
    w_nc_file_out_id = Dataset(nc_file_out, 'w', format='NETCDF4')
    w_nc_file_out_id.description = "Convert SURFEX output from 1D (landpoint) to 2D (lon, lat)."

    # Using our previous dimension info, we can create the new time dimension
    data_dim = {}
    print('nc_dims_2d:', nc_dims_2d)
    for dim in nc_dims_2d:
        w_nc_file_out_id.createDimension(dim, None)
        if dim in nc_file_2D_id.variables:
            data_dim[dim] = _create_var_like(w_nc_file_out_id, dim, nc_file_2D_id.variables[dim], (dim,))

    if 'Number_of_Tile' in nc_dims_1d:
        w_nc_file_out_id.createDimension('Number_of_Tile', ntile)
        data_dim['Number_of_Tile'] = w_nc_file_out_id.createVariable('Number_of_Tile', 'i4', ('Number_of_Tile',))

    # Assign the dimension data to the new NetCDF file.
    w_nc_file_out_id.variables['time'][:] = time_1d
    w_nc_file_out_id.variables['y'][:] = y
    w_nc_file_out_id.variables['x'][:] = x

    # Time varied variables
    data_var = {}

    print('nc_vars_2d', nc_vars_2d)

    # Constant variable
    for var in nc_vars_2d:
        if 'longitude' in var or 'latitude' in var or 'lon' in var or 'lat' in var:
            data_var[var] = _create_var_like(
                w_nc_file_out_id, var, nc_file_2D_id.variables[var], nc_file_2D_id.variables[var].dimensions)
            w_nc_file_out_id.variables[var][:] = nc_file_2D_id.variables[var][:-extension_y, :-extension_x]

        elif 'Lambert_Conformal' in var:
            data_var[var] = _create_var_like(
                w_nc_file_out_id, var, nc_file_2D_id.variables[var], nc_file_2D_id.variables[var].dimensions)
            w_nc_file_out_id.variables[var][:] = nc_file_2D_id.variables[var][:]

    for var in nc_vars_1d:
        if nc_file_1D_id.variables[var].dimensions != ('time', 'Number_of_Tile', 'Number_of_points'):
            if var != 'time' and var != 'Projection_Type' and var != 'FRC_TIME_STP':
                var_1D = nc_file_1D_id.variables[var][:]  # shape is time, Number_of_points
                print('shape of var_1D:', np.shape(var_1D), var)

                if nc_file_1D_id.variables[var].dimensions == ('time', 'Number_of_points'):
                    var_2D = np.reshape(var_1D, (len(time_1d), len(y), len(x)))  # Shape is time, y, x
                    print('shape of var_2D:', np.shape(var_2D))
                    data_var[var] = _create_var_like(
                        w_nc_file_out_id, var, nc_file_1D_id.variables[var], ('time', 'y', 'x'))

                elif nc_file_1D_id.variables[var].dimensions == ('Number_of_points',):
                    var_2D = np.reshape(var_1D, (len(y), len(x)))
                    data_var[var] = _create_var_like(
                        w_nc_file_out_id, var, nc_file_1D_id.variables[var], ('y', 'x'))

                elif nc_file_1D_id.variables[var].dimensions == ('Number_of_Tile', 'Number_of_points'):
                    var_2D = np.reshape(var_1D, (ntile, len(y), len(x)))
                    data_var[var] = _create_var_like(
                        w_nc_file_out_id, var, nc_file_1D_id.variables[var], ('Number_of_Tile', 'y', 'x'))

                # Assign values to variables
                w_nc_file_out_id.variables[var][:] = var_2D

        elif nc_file_1D_id.variables[var].dimensions == ('time', 'Number_of_Tile', 'Number_of_points'):
            var_1D = nc_file_1D_id.variables[var][:]  # shape is time, Number_of_points
            print('shape of var_1D:', np.shape(var_1D), var)

            var_2D = np.reshape(var_1D, (len(time_1d), ntile, len(y), len(x)))
            for i_tile in range(ntile):
                var_tile = var + '_P' + str(i_tile + 1)
                data_var[var_tile] = _create_var_like(
                    w_nc_file_out_id, var_tile, nc_file_1D_id.variables[var], ('time', 'y', 'x'))
                w_nc_file_out_id.variables[var_tile][:] = var_2D[:, i_tile, :, :]

    #
    # Close NetCDF files.
    #
    nc_file_1D_id.close()
    nc_file_2D_id.close()
    w_nc_file_out_id.close()
