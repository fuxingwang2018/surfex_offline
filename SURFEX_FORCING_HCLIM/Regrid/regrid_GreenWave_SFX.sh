#!/bin/bash

# Regrid of nc files (e.g., from 300m to 3km)
# Fuxing Wang, 26 Jan 2022, Rossby SMHI
#
module load NCO/4.8.1-nsc1
# Load the definations for the machine and some regrid parameters
. ./BiNSC.def
#. ./param.def

# Definations
DIR_SURFEX="/nobackup/rossby26/users/sm_fuxwa/SURFEX_OUT/GreenWave/"
#experiment="SURFEX73_GreenWave_300m_SCAY_ML_Summer2018_STKHM_NEWphs_HCLIMD_mlL65"  
experiment=("SURFEX73_GreenWave_300m_SCAY_ML_Summer2018_STKHM_NEWphs_HCLIMD_mlL65" \
	"SURFEX73_GreenWave_300m_SCAY_ML_Summer2018_STKHM_NEWphs_HCLIMR_mlL65" \
	"SURFEX73_GreenWave_300m_SCAY_ML_Summer2018_STKHM_NEWphs_HCLIMD_mlL62" \
	"SURFEX73_GreenWave_300m_SCAY_ML_Summer2018_STKHM_NEWphs_HCLIMR_mlL62" \
	"SURFEX73_GreenWave_300m_SCAY_ML_Summer2018_STKHM_NEWphs_HCLIMD_ml50m" \
	"SURFEX73_GreenWave_300m_SCAY_ML_Summer2018_STKHM_NEWphs_HCLIMR_ml50m" )  
NC_FILE="SURF_ATM_DIAGNOSTICS.OUT.2D.nc"

OUT_RES=3km
Freq='1H' #'3H'
mlevel=L65 #L65, L62, 50m


# Grid information
grid_info="/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/Grid/HCLIM38_Summer2018_STKHM_DEFphys/HCLIM_150X150/griddes_GreenWave_3km_150x150.txt"

for exp in ${experiment[@]} ; do
    DIR_IN=${DIR_SURFEX}/${exp}/OUT_2D
    DIR_OUT=${DIR_SURFEX}/${exp}/OUT_2D_3km

    if [ ! -e ${DIR_OUT} ] ; then
        mkdir -p ${DIR_OUT}
    fi

    # Interpolation
    NC_IN=${DIR_IN}/${NC_FILE}
    NC_OUT=${DIR_OUT}/${NC_FILE}
    echo 'NC_IN' ${NC_IN}
    echo 'NC_OUT' ${NC_OUT}
    cdo select,name=longitude,latitude,T2M ${NC_IN} ${NC_OUT}.T2M
    #cdo chname,longitude,lon,latitude,lat ${NC_OUT}.T2M ${NC_OUT}.chname
    ncatted -a coordinates,T2M,a,c,"longitude latitude" ${NC_OUT}.T2M ${NC_OUT}.coord
    cdo remapbil,${grid_info} ${NC_OUT}.coord ${NC_OUT}

done

# Backup
#########################
#cdo -r -remapbil,${grid_ref} ${in_file}.nc ${out_file}.nc
#cdo remapcon,${grid_info} ${in_file}.nc ${out_file}.nc
#cdo remapbil,${grid_info} ${in_file}.nc ${out_file}.nc
#cdo remap,${grid_info},${grid_ref} ${in_file}.nc ${out_file}.nc
#cdo -setgrid,${grid_info} ${in_file}.nc ${out_file}.nc

