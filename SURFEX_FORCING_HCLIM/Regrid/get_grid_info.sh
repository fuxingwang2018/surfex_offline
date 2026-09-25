#!/bin/bash

# Grid information
DIR=/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/Grid/HCLIM38_Summer2018_STKHM_DEFphys/HCLIM_150X150
grid_ref=${DIR}/Const.Clim.nc
grid_info=${DIR}/griddes_GreenWave_3km_150x150.txt
cdo griddes ${grid_ref} > ${grid_info}
