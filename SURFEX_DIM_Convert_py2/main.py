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
#from mpl_toolkits.basemap import Basemap, addcyclic, shiftgrid
import get_configuration
import dim_convert
import os, sys

# Get some definitions
HCLIMEXP, SURFEXEXP, name_surfex_file_list = get_configuration.get_conf()

# dir_surfex_sim: the SURFEX run output (1D) directory
# dir_surfex_2d:  the 2D SURFEX forcing data directory
# file_surfex_2d: the 2D SURFEX forcing data file name

ntile = 2 # Number of tiles
dir_surfex_month='OUT_201807'
var_nature_tile_list = ['T2M_P', 'Q2M_P', 'HU2M_P', 'ZON10M_P', 'MER10M_P', 'LE_P', 'H_P', 'RN_P', 'SWD_P', 'SWU_P', 'LWD_P', 'LWU_P']
var_isba_list = ['T2M_ISBA', 'Q2M_ISBA', 'HU2M_ISBA', 'ZON10M_ISBA', 'MER10M_ISBA', 'LE_ISBA', 'H_ISBA', 'RN_ISBA', 'SWD_ISBA', 'SWU_ISBA', 'LWD_ISBA', 'LWU_ISBA']
var_isba_veg_evolution_list = ['LAI']
SIMYEAR_OF_EXP={'EV1_PGW1':'2017', 'EV1_PGW2':'2043', 'EV1_PGW3':'2072', \
          'EV2_PGW1':'2022', 'EV2_PGW2':'2043', 'EV2_PGW3':'2072', \
          'EV3_PGW1':'2018', 'EV3_PGW2':'2043', 'EV3_PGW3':'2072', \
          'zref_default':'2022', 'zref_default_90s':'2022'}

for surfex_exp in SURFEXEXP:
    if HCLIMEXP=='NorCP_ALADIN_ERAI':
        dir_surfex_sim='/nobackup/rossby18/rossby/joint_exp/harmony/MUMS/SURFEX_OUT/SURFEX73_MUMS_500m_ALADIN12km_' + str(surfex_exp)
        dir_surfex_2d='/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS'
        file_surfex_2d='HCLIM38_FORC_MUMS_ml_SCA_ZERO_201807.nc'

    elif HCLIMEXP=='NorCP_ERAI_ALD_AROME':
        dir_surfex_sim='/nobackup/rossby18/rossby/joint_exp/harmony/MUMS/SURFEX_OUT/SURFEX73_MUMS_500m_AROME3km_' + str(surfex_exp)
        dir_surfex_2d='/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS'
        file_surfex_2d='HCLIM38_FORC_MUMS_ml_SCA_ZERO_2018070100.nc'

    elif HCLIMEXP=='HCLIM38_Summer2018_STKHM_NEW' \
        	or HCLIMEXP=='HCLIM38_Summer2018_STKHM_NEW_defaultPhys':
        dir_surfex_sim='/nobackup/rossby24/users/sm_fuxwa/SURFEX_OUT/GreenWave/'+str(surfex_exp)
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

    elif HCLIMEXP=='HCLIM38_Summer2018_STKHM_NEWphys' \
	    or HCLIMEXP=='HCLIM38_Summer2018_STKHM_DEFphys'\
	    or HCLIMEXP=='HCLIM38_Summer2018_STKHM_2050phys':

        dir_surfex_sim='/nobackup/rossby26/users/sm_fuxwa/SURFEX_OUT/GreenWave/'+str(surfex_exp)
        dir_surfex_2d='/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave'
        file_surfex_2d='HCLIM38_FORC_GreenWave_mlL65_SCA_VARY_300m_2018070100.nc'

    elif HCLIMEXP=='HCLIM43_BRIGHT_Stockholm' or HCLIMEXP=='HCLIM43_BRIGHT_NorrLink':
        if HCLIMEXP=='HCLIM43_BRIGHT_Stockholm':
            dir_surfex_sim_1d='/home/sm_aital/projects/BRIGHT/data_SURFEX/highres/Stockholm/v3/'+str(surfex_exp)
            dir_surfex_sim_2d='/nobackup/rossby27/users/sm_fuxwa/SURFEX_OUT/BRIGHT/Stockholm/v3/'+str(surfex_exp)
            file_surfex_ref_2d='HCLIM43_ST_2017_PGW3.nc'
        elif HCLIMEXP=='HCLIM43_BRIGHT_NorrLink':
            dir_surfex_sim_1d='/home/sm_aital/projects/BRIGHT/data_SURFEX/highres/Norr_Link/v3/'+str(surfex_exp)
            dir_surfex_sim_2d='/nobackup/rossby27/users/sm_fuxwa/SURFEX_OUT/BRIGHT/NorrLink/v3/'+str(surfex_exp)
            file_surfex_ref_2d='HCLIM43_NL_2017_PGW1.nc'
            #dir_surfex_sim_1d='/nobackup/rossby27/users/sm_aital/analysis/SURFEX_TEB_forcing/'+str(surfex_exp)
            #dir_surfex_sim_2d='/nobackup/rossby27/users/sm_fuxwa/SURFEX_OUT/BRIGHT/NorrLink/'+str(surfex_exp)

        dir_surfex_ref_2d='/nobackup/rossby27/users/sm_fuxwa/SURFEX_FORCING/HCLIM43_FORC/BRIGHT'
        if not os.path.exists(dir_surfex_sim_2d):
            os.mkdir(dir_surfex_sim_2d)
        dir_surfex_month='OUT_' + SIMYEAR_OF_EXP[str(surfex_exp)]

    elif HCLIMEXP=='HCLIM43_G4E_Malmo':
        dir_surfex_sim_1d='/nobackup/rossby27/users/sm_aital/G4E/SURFEX_offline/'+str(surfex_exp)
        dir_surfex_sim_2d='/nobackup/rossby27/users/sm_fuxwa/SURFEX_OUT/G4E/Malmo/'+str(surfex_exp)

        dir_surfex_ref_2d='/nobackup/rossby27/users/sm_aital/G4E/SURFEX_offline/forcing/ori/'
        file_surfex_ref_2d='orog.nc'

        if not os.path.exists(dir_surfex_sim_2d):
            os.mkdir(dir_surfex_sim_2d)
        dir_surfex_month='OUT_' + SIMYEAR_OF_EXP[str(surfex_exp)]


    # Creat directory
    if not os.path.exists(dir_surfex_sim_2d + '/OUT_2D/'):
        os.mkdir(dir_surfex_sim_2d + '/OUT_2D/')

    for name_surfex_file in name_surfex_file_list:

        #nc_file_1D = dir_surfex_sim + '/' + dir_surfex_month + '/' + name_surfex_file + '.nc'  # Input nc filename
        #nc_file_2D = dir_surfex_2d + '/HCLIM38_SIM_2D/' + HCLIMEXP + '/' + file_surfex_2d  
        #nc_file_out = dir_surfex_sim + '/OUT_2D/' + name_surfex_file + '.2D.nc'

        nc_file_1D = dir_surfex_sim_1d + '/' + dir_surfex_month + '/' + name_surfex_file + '.nc'  # Input nc filename
        #BRIGHT
        #nc_file_2D = dir_surfex_ref_2d + '/HCLIM43_SIM_2D/' + HCLIMEXP + '/' + file_surfex_ref_2d  
        nc_file_2D = dir_surfex_ref_2d + '/' + file_surfex_ref_2d  
        nc_file_out = dir_surfex_sim_2d + '/OUT_2D/' + name_surfex_file + '.2D.nc'

        dim_convert.nc_1D_to_2D(name_surfex_file, nc_file_1D, nc_file_2D, nc_file_out, ntile, var_isba_list, var_isba_veg_evolution_list)


