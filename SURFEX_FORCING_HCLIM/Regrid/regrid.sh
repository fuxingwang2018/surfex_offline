#!/bin/bash

# Regrid of nc files (e.g., from 3km to 500m)
# 
# Fuxing Wang, 14 June 2019, Rossby SMHI
#
# Load the definations for the machine and some regrid parameters
. ./BiNSC.def
. ./param.def

# Definations
experiment="AROME3km"
#experiment="ALADIN12km"

# Output resolution
OUT_RES=500m

# AROME 3km
# Choose: 'from_AROME1H', 'from_AROME3H', 'from_fa'
var_type='from_AROME1H'
#var_type='from_ALADIN1H'

if [[ "$experiment" == "AROME3km" ]]; then
    OUT_DIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ERAI_ALD_AROME
elif [[ "$experiment" == "ALADIN12km" ]]; then
    OUT_DIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ALADIN_ERAI
fi


# AROME3km
if [[ "$var_type" == "from_AROME1H" ]]; then 
    #HCLIMSIM=/nobackup/rossby21/rossby/joint_exp/norcp/NorCP_AROME_ERAI_ALADIN_1997_2017
    #HCLIMNAME=NorCP_AROME_ERAI_ALADIN_1997_2017_3H
    #VAR_LIST_arome=('tas_fp' 'huss_fp' 'uas_fp' 'vas_fp' 'rsds_fp' 'rlds_fp' 'ps_fp' 'prrain_fp' 'prsnow_fp')
    #HCLIMTIME='netcdf/1H'
    HCLIMSIM=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ERAI_ALD_AROME
    HCLIMNAME=NorCP_AROME_ERAI_ALADIN_1997_2017_1H
    VAR_LIST_arome=('hurs')
elif [[ "$var_type" == "from_AROME3H" ]]; then
    HCLIMSIM=/nobackup/rossby21/rossby/joint_exp/norcp/NorCP_AROME_ERAI_ALADIN_1997_2017
    HCLIMNAME=NorCP_AROME_ERAI_ALADIN_1997_2017_3H
    # Available from AROME 3km 3H output
    #VAR_LIST_arome=('tas_town')
    VAR_LIST_arome=('tas_ol' 'tas_fo')
    HCLIMTIME='netcdf/3H'
elif [[ "$var_type" == "from_fa" ]]; then
    HCLIMSIM=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ERAI_ALD_AROME
    HCLIMNAME=NORDIC3_HCLIM38h1_NORCP_ERAI_ALD_AROME_1997_2017
    # Converted from fa files
    #VAR_LIST_arome=('rsdsdir_fp' 'taL65_fp' 'husL65_fp' 'uamL65_fp' 'vamL65_fp')
    # Again, converted from fa files
    VAR_LIST_arome=('prrain_fp' 'prsnow_fp')
fi


# ALADIN 12km
if [[ "$var_type" == "from_ALADIN1H" ]] ; then
    HCLIMNAME=NorCP_ALADIN_ERAI_1997_2017_1H
    HCLIMSIM=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ALADIN_ERAI/from_NorCP_1H
    VAR_LIST_aladin=('hurs')
elif [[ "$var_type" == "from_ALADIN3H" ]]; then 
    HCLIMNAME=NorCP_ALADIN_ERAI_1997_2017_3H
    HCLIMSIM=/nobackup/rossby21/rossby/joint_exp/norcp/NorCP_ALADIN_ERAI_1997_2017
    VAR_LIST_aladin=('tas_fo' 'tas_ol')
    #VAR_LIST_aladin=('rsdsdir' 'rsds' 'rlds' 'ps'  'taL65' 'husL65' 'uamL65' 'vamL65' 'prrain' 'prsnow')
    #VAR_LIST_1=('tas' 'uas' 'vas')
    HCLIMTIME='netcdf/3H'
elif [[ "$var_type" == "from_fa" ]]; then
    HCLIMNAME=NorCP_ALADIN_ERAI_1997_2017_3H
    HCLIMSIM=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ALADIN_ERAI
    VAR_LIST_aladin=('taL65')
fi




# Grid information
#cdo griddes zs.nc > griddes_MUMS_500m.txt
#grid_info=/nobackup/rossby18/rossby/joint_exp/harmony/MUMS/HCLIM38_MUMS_AROME500_NorCP/climate/grid_MUMS_500m.txt
grid_info=griddes_MUMS_500m.txt
grid_ref=/nobackup/rossby18/rossby/joint_exp/harmony/MUMS/HCLIM38_MUMS_AROME500_NorCP/climate/zs.nc


# Interpolation

# AROME 3km
if [[ "$experiment" == "AROME3km" ]]; then
  
  if [[ "$var_type" == "from_AROME1H" ]] || [[ "$var_type" == "from_AROME3H" ]]; then
    for ivar in ${VAR_LIST_arome[@]} ; do
      echo 'variable:' ${ivar} 
      IN_NC=${HCLIMSIM}/${HCLIMTIME}/${ivar}_${HCLIMNAME}_${HCLIMDTG}.nc
      OUT_NC=${OUT_DIR}/${ivar}_${HCLIMNAME}_${OUT_RES}_${HCLIMDTG}.nc
      cdo remapbil,${grid_info} ${IN_NC} ${OUT_NC}
    done

  elif [[ "$var_type" == "from_fa" ]]; then
    for ivar in ${VAR_LIST_arome[@]} ; do
      echo 'variable:' ${ivar} 
      IN_NC=${OUT_DIR}/${ivar}_${HCLIMNAME}_${HCLIMDTG}.nc
      OUT_NC=${OUT_DIR}/${ivar}_${HCLIMNAME}_${OUT_RES}_${HCLIMDTG}.nc
      cdo remapbil,${grid_info} ${IN_NC} ${OUT_NC}
    done
  fi

# ALADIN 12km
elif [[ "$experiment" == "ALADIN12km" ]]; then
  for ivar in ${VAR_LIST_aladin[@]} ; do
    echo 'variable:' ${ivar} 
    IN_NC=${HCLIMSIM}/${HCLIMTIME}/${ivar}_${HCLIMNAME}_${HCLIMDTG}.nc
    #IN_NC=${HCLIMSIM}/${ivar}_${HCLIMNAME}_${HCLIMDTG}.nc
    OUT_NC=${OUT_DIR}/${ivar}_${HCLIMNAME}_${OUT_RES}_${HCLIMDTG}.nc
    cdo remapbil,${grid_info} ${IN_NC} ${OUT_NC}
  done
fi

# Backup
#########################
#cdo -r -remapbil,${grid_ref} ${in_file}.nc ${out_file}.nc
#cdo remapcon,${grid_info} ${in_file}.nc ${out_file}.nc
#cdo remapbil,${grid_info} ${in_file}.nc ${out_file}.nc
#cdo remap,${grid_info},${grid_ref} ${in_file}.nc ${out_file}.nc
#cdo -setgrid,${grid_info} ${in_file}.nc ${out_file}.nc



