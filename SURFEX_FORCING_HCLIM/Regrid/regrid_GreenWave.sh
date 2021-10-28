#!/bin/bash

# Regrid of nc files (e.g., from 3km to 500m)
# 
# Fuxing Wang, 14 June 2019, Rossby SMHI
#
# Load the definations for the machine and some regrid parameters
. ./BiNSC.def
#. ./param.def

HCLIMDTG='2018070100'  

# Definations
#experiment="HCLIM38_Summer2018_STKHM_NEW" # CentOS6, 2020, wrong
#experiment="HCLIM38_Summer2018_STKHM_NEW_defaultPhys" #CentOS6, 2020, wrong
#experiment="NorCP_AROME_ERAI_ALADIN_1997_2017"
#experiment="HCLIM38_Summer2018_STKHM_DEFphys"  #CentOS7, 2021, correct
experiment="HCLIM38_Summer2018_STKHM_NEWphys"  #CentOS7, 2021, correct

# Output resolution
OUT_RES=300m

# AROME 3km
# For GreenWave, if the variables are converted from fa to nc, we use from_fa_1H
# For variables in nc format from HCLIM output like *50m*, rsds, prrain ...  we use from_AROME_1H
# Choose: 'from_AROME_1H', 'from_AROME_3H', 'from_fa_1H', 'from_fa_3H'
var_type='from_fa_1H'

Freq='1H' #'3H'

mlevel=L62 #L65, L62, 50m

if [[ "$experiment" == "HCLIM38_Summer2018_STKHM_NEW" ]]; then
    EXPNAME=GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW
    HCLIMNAME_IN=GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW
    HCLIMNAME_OUT=GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW
    #EXPNAME=HCLIM38_GreenWave_URBAN_NewPhys_1hOUT
    #HCLIMNAME_IN=GrW_STHLM3.0_HCLIM38_GreenWave_URBAN_NewPhys_1hOUT
elif [[ "$experiment" == "HCLIM38_Summer2018_STKHM_NEW_defaultPhys" ]]; then
    EXPNAME=GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_defaultPhys
    HCLIMNAME_IN=GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_defaultPhys
    HCLIMNAME_OUT=GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_defaultPhys
    #EXPNAME=HCLIM38_GreenWave_URBAN_DefPhys_1hOUT
    #HCLIMNAME_IN=GrW_STHLM3.0_HCLIM38_GreenWave_URBAN_DefPhys_1hOUT
elif [[ "$experiment" == "NorCP_AROME_ERAI_ALADIN_1997_2017" ]]; then
    EXPNAME=NorCP_AROME_ERAI_ALADIN_1997_2017
    HCLIMNAME_IN=${experiment}
    HCLIMNAME_OUT=${experiment}
elif [[ "$experiment" == "HCLIM38_Summer2018_STKHM_DEFphys" ]]; then
    EXPNAME=GreenWave_HCLIM38_CentOS7_DEFphys_newcode_Optimized
    if [[ "$var_type" == "from_fa_1H" ]]; then
        HCLIMNAME_IN=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_DEFphys
    elif [[ "$var_type" != "from_fa_1H" ]]; then
        HCLIMNAME_IN=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_DEFphys_newcode_Optimized 
    fi
    HCLIMNAME_OUT=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_DEFphys
elif [[ "$experiment" == "HCLIM38_Summer2018_STKHM_NEWphys" ]]; then
    EXPNAME=GreenWave_HCLIM38_CentOS7_newCode_NEWphysJul2018_Optimized
    if [[ "$var_type" == "from_fa_1H" ]]; then
        HCLIMNAME_IN=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_NEWphys
    elif [[ "$var_type" != "from_fa_1H" ]]; then
        HCLIMNAME_IN=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_newCode_NEWphysJul2018_Optimized
    fi
    HCLIMNAME_OUT=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_NEWphys
fi

#OUT_DIR=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/${experiment}
OUT_DIR=/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/${experiment}

#VAR_LIST_arome=('tas_fp' 'huss_fp' 'uas_fp' 'vas_fp' 'rsds_fp' 'rlds_fp' 'ps_fp' 'prrain_fp' 'prsnow_fp')
if [[ "$var_type" == "from_AROME_1H" ]]; then 
    if [[ "$experiment" == "NorCP_AROME_ERAI_ALADIN_1997_2017" ]]; then
        HCLIMSIM=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/NorCP_AROME_ERAI_ALADIN_1997_2017
        #VAR_LIST_arome=('pr' 'prsolid' 'rsds' 'rlds')
        VAR_LIST_arome=('ps')
    else
        #HCLIMSIM=/nobackup/smhid13/sm_isari/hm_home/GreenWave/${EXPNAME}/archive/2018/07/01/00
        HCLIMSIM=/nobackup/smhid19/users/sm_isari/hm_home/GreenWave/${EXPNAME}/archive/2018/07/01/00
        #VAR_LIST_arome=('tas_fp' 'huss_fp')
        VAR_LIST_arome=('rsds_fp' 'rlds_fp' 'ps_fp' 'prrain_fp' 'prsnow_fp')
        #VAR_LIST_arome=('ua50m_fp' 'va50m_fp' 'ta50m_fp' 'hus50m_fp')
        #VAR=('tas_P01_sfx' 'tas_P02_sfx' 'tas_town_sfx' 'hurs_fp')
        #VAR_LIST_arome=('ts_sfx')
    fi

elif [[ "$var_type" == "from_AROME_3H" ]]; then 
    if [[ "$experiment" == "NorCP_AROME_ERAI_ALADIN_1997_2017" ]]; then
        HCLIMSIM=/nobackup/rossby21/rossby/joint_exp/norcp/NorCP_AROME_ERAI_ALADIN_1997_2017/netcdf/3H
        VAR_LIST_arome=('rsdsdir' 'ua50m' 'va50m' 'ta50m' 'hus50m')
    else
        HCLIMSIM=/nobackup/smhid13/sm_isari/hm_home/GreenWave/${EXPNAME}/archive/2018/07/01/00
        VAR_LIST_arome=('rsdsdir_fp' 'ua50m_fp' 'va50m_fp' 'ta50m_fp' 'hus50m_fp')
    fi

elif [[ "$var_type" == "from_fa_1H" ]]; then
    # Converted from fa files
    #HCLIMSIM=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/${experiment}
    HCLIMSIM=/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/${experiment}
    VAR_LIST_arome=("hus${mlevel}_fp" "ta${mlevel}_fp" "uam${mlevel}_fp" "vam${mlevel}_fp")
    #VAR_LIST_arome=('rsdsdir_fp')

elif [[ "$var_type" == "from_fa_3H" ]]; then
    # Converted from fa files
    HCLIMSIM=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/${experiment}
    VAR_LIST_arome=('tas_fp' 'huss_fp' 'uas_fp' 'vas_fp' 'rsds_fp' 'rlds_fp' 'ps_fp' 'prrain_fp' 'prsnow_fp')
fi


# Grid information
#grid_ref=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/PGD_lfi.nc
grid_info=griddes_GreenWave_300m.txt
#cdo griddes ${grid_ref} > ${grid_info}


# Interpolation
# AROME 3km
if [[ "$experiment" == "HCLIM38_Summer2018_STKHM"* ]] ; then
  if [[ "$var_type" == "from_AROME_1H" ]]; then
    for ivar in ${VAR_LIST_arome[@]} ; do
      echo 'variable:' ${ivar} 
      IN_NC=${HCLIMSIM}/${ivar}_${HCLIMNAME_IN}_${HCLIMDTG}.nc
      OUT_NC=${OUT_DIR}/${ivar}_${HCLIMNAME_OUT}_${OUT_RES}_${HCLIMDTG}.nc
      echo 'IN_NC' ${IN_NC}
      cdo remapbil,${grid_info} ${IN_NC} ${OUT_NC}
    done

  elif [[ "$var_type" == "from_AROME_3H" ]]; then
    for ivar in ${VAR_LIST_arome[@]} ; do
      echo 'variable:' ${ivar} 
      IN_NC=${HCLIMSIM}/${ivar}_${HCLIMNAME_IN}_${HCLIMDTG}.nc
      OUT_NC=${OUT_DIR}/${ivar}_${HCLIMNAME_OUT}_${OUT_RES}_${HCLIMDTG}_3H.nc
      echo 'IN_NC' ${IN_NC}
      cdo remapbil,${grid_info} ${IN_NC} ${OUT_NC}
    done

  elif [[ "$var_type" == "from_fa_1H" ]]; then
    for ivar in ${VAR_LIST_arome[@]} ; do
      echo 'variable:' ${ivar} 
      IN_NC=${OUT_DIR}/${ivar}_${HCLIMNAME_IN}_${HCLIMDTG}.nc
      OUT_NC=${OUT_DIR}/${ivar}_${HCLIMNAME_OUT}_${OUT_RES}_${HCLIMDTG}.nc
      cdo remapbil,${grid_info} ${IN_NC} ${OUT_NC}
    done

  elif [[ "$var_type" == "from_fa_3H" ]]; then
    for ivar in ${VAR_LIST_arome[@]} ; do
      echo 'variable:' ${ivar} 
      IN_NC=${OUT_DIR}/${ivar}_${HCLIMNAME_IN}_${HCLIMDTG}_3H.nc
      OUT_NC=${OUT_DIR}/${ivar}_${HCLIMNAME_OUT}_${OUT_RES}_${HCLIMDTG}_3H.nc
      cdo remapbil,${grid_info} ${IN_NC} ${OUT_NC}
    done
  fi

# NorCP
elif [[ "$experiment" == "NorCP_AROME_ERAI_ALADIN_1997_2017" ]]; then
  DTG=201805
  DTGEND=201810
  for ivar in ${VAR_LIST_arome[@]} ; do
    for ((ym=${DTG}; ym<=${DTGEND}; ym++)); do
      echo 'variable, ym:' ${ivar}, ${ym}
      IN_NC=${HCLIMSIM}/${ivar}_${HCLIMNAME_IN}_${Freq}_${ym}.nc
      OUT_NC=${OUT_DIR}/${ivar}_${HCLIMNAME_OUT}_${Freq}_${OUT_RES}_${ym}.nc
      echo 'IN_NC' ${IN_NC}
      cdo remapbil,${grid_info} ${IN_NC} ${OUT_NC}
    done
  done

# ALADIN 12km
elif [[ "$experiment" == "ALADIN12km" ]]; then
  for ivar in ${VAR_LIST_aladin[@]} ; do
    echo 'variable:' ${ivar} 
    IN_NC=${HCLIMSIM}/${HCLIMTIME}/${ivar}_${HCLIMNAME_IN}_${HCLIMDTG}.nc
    #IN_NC=${HCLIMSIM}/${ivar}_${HCLIMNAME}_${HCLIMDTG}.nc
    OUT_NC=${OUT_DIR}/${ivar}_${HCLIMNAME_OUT}_${OUT_RES}_${HCLIMDTG}.nc
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

