#!/bin/bash

# Convert from specific humidity to relative humidity
# Fuxing Wang, 14 June 2019, Rossby SMHI

# Definations
experiment="HCLIM500m"
#experiment="AROME3km"
#experiment="ALADIN12km"


if [[ "$experiment" == "HCLIM500m" ]]; then
    IN_DIR=/nobackup/rossby18/rossby/joint_exp/harmony/MUMS/HCLIM38_MUMS_AROME500_NorCP/archive/2018/07/01/00_Tstep10s
    OUT_DIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/MUMS_AROME500_NorCP
    FILENAME=2018070100
elif [[ "$experiment" == "AROME3km" ]]; then
    IN_DIR=/nobackup/rossby21/rossby/joint_exp/norcp/NorCP_AROME_ERAI_ALADIN_1997_2017/netcdf/1H
    OUT_DIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ERAI_ALD_AROME
    FILENAME=NorCP_AROME_ERAI_ALADIN_1997_2017_1H_201807
elif [[ "$experiment" == "ALADIN12km" ]]; then
    IN_DIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ALADIN_ERAI/from_NorCP_1H
    OUT_DIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ALADIN_ERAI/from_NorCP_1H
    FILENAME=NorCP_ALADIN_ERAI_1997_2017_1H_201807
fi


# Concrate all the 3 variables (specific humidity, air pressure, air temperature) into one nc file:
IN_NC_HUSS=${IN_DIR}/huss_${FILENAME}.nc
IN_NC_TAS=${IN_DIR}/tas_${FILENAME}.nc
IN_NC_PS=${IN_DIR}/ps_${FILENAME}.nc
MERGED_NC=${OUT_DIR}/huss_tas_ps_${FILENAME}.nc
cdo merge ${IN_NC_HUSS} ${IN_NC_TAS} ${IN_NC_PS} ${MERGED_NC}


# specific humidity to relative humidity
# Reference: https://code.mpimet.mpg.de/boards/2/topics/979 
# https://earthscience.stackexchange.com/questions/2360/how-do-i-convert-specific-humidity-to-relative-humidity
OUT_NC_HURS=${OUT_DIR}/hurs_${FILENAME}.nc
#cdo expr,'hurs=((ps/(8.314*tas))*(1/((1-huss)/(huss*0.02896)+(1/0.01802))))' ${MERGED_NC} ${OUT_NC_HURS}
cdo expr,'hurs=(0.01*(0.263*ps*huss)/(exp(17.67*(tas-273.15)/(tas-29.65))))' ${MERGED_NC} ${OUT_NC_HURS}
