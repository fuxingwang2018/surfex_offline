#!/bin/bash
#SBATCH -N 1
#SBATCH -t 1:30:00
#SBATCH -J sel_val
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt

# https://ryanstutorials.net/bash-scripting-tutorial/bash-loops.php

#VAR_LIST_1=('tas' 'huss' 'uas' 'vas' 'rsds' 'rlds' 'ps' 'prrain' 'prsnow')
# rsdsdir, ua50m, va50m, ta50m, hus50m are directly arome 3h NC output

#var_case='1H_to_3H'
#var_case='add_last_record'
var_case='add_first_record'

#EXPNAME=GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_2018070100
#EXPNAME=GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_defaultPhys_2018070100
#EXPNAME=NorCP_AROME_ERAI_ALADIN_1997_2017
EXPNAME=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_DEFphys_2018070100

if [[ "$EXPNAME" == "GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_2018070100" ]]; then
    # AROME 3km NEW Physiography
    DIR1=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_NEW
    DIR2=/nobackup/smhid13/sm_isari/hm_home/GreenWave/GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW/archive/2018/07/01/00

elif [[ "$EXPNAME" == "GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_defaultPhys_2018070100" ]]; then
    # AROME 3km default physiogrphy
    DIR1=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_NEW_defaultPhys
    DIR2=/nobackup/smhid13/sm_isari/hm_home/GreenWave/GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_defaultPhys/archive/2018/07/01/00

elif [[ "$EXPNAME" == "GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_DEFphys_2018070100" ]]; then
    # AROME 3km default physiogrphy
    DIR1=/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_DEFphys

elif [[ "$EXPNAME" == "NorCP_AROME_ERAI_ALADIN_1997_2017" ]]; then
    # NorCP_AROME_ERAI_ALADIN_1997_2017
    DIR1=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/${EXPNAME}
    DIR2=/nobackup/rossby21/rossby/joint_exp/norcp/NorCP_AROME_ERAI_ALADIN_1997_2017/netcdf/1H
fi


if [[ "$var_case" == "1H_to_3H" ]]; then
  if [[ "$EXPNAME" == "NorCP_AROME_ERAI_ALADIN_1997_2017" ]]; then
    #VAR_LIST=('pr' 'prsolid' 'rsds' 'rlds')
    VAR_LIST=('ps')
    DTG=201805
    DTGEND=201810 
  else
    VAR_LIST=('tas_fp' 'huss_fp' 'uas_fp' 'vas_fp' 'rsds_fp' 'rlds_fp' 'ps_fp' 'prrain_fp' 'prsnow_fp')
    DTG=201807
    DTGEND=201807 
  fi

  for ivar in ${VAR_LIST[@]} ; do
    for ((ym=${DTG}; ym<=${DTGEND}; ym++)); do
      echo var and year-month, $ivar, $ym
      IN_FILE=${DIR2}/${ivar}_${EXPNAME}_1H_${ym}.nc
      OUT_FILE=${DIR1}/${ivar}_${EXPNAME}_3H_${ym}.nc
      TMP_FILE=${DIR1}/${ivar}_${EXPNAME}_3H_${ym}_tmp.nc
      for hour in {1..745..3}; do
          echo hour, $hour
    	  cdo select,timestep=$hour ${IN_FILE} ${TMP_FILE}_$hour
      done
      cdo mergetime ${TMP_FILE}_* ${OUT_FILE}
      rm -f ${TMP_FILE}_*
    done
  done

elif [[ "$var_case" == "add_last_record" ]]; then
  VAR_LIST=('husL65' 'uamL65' 'vamL65')

  for ivar in ${VAR_LIST[@]} ; do
    IN_FILE_1=${DIR}/from_NorCP_fa/${ivar}_2018070100.nc
    IN_FILE_2=${DIR}/from_NorCP_fa/${ivar}_2018080100.nc
    TMP_FILE=${DIR}/${ivar}_tmp_2018070100.nc
    OUT_FILE=${DIR}/${ivar}_NorCP_ALADIN_ERAI_1997_2017_3H_201807.nc
    cdo select,timestep=1 ${IN_FILE_2} ${TMP_FILE}
    cdo mergetime ${IN_FILE_1} ${TMP_FILE} ${OUT_FILE}
    rm -f ${TMP_FILE}
  done

elif [[ "$var_case" == "add_first_record" ]]; then
  VAR_LIST=('rsdsdir')

  for ivar in ${VAR_LIST[@]} ; do
    IN_FILE_1=${DIR1}/${ivar}_fp_${EXPNAME}.nc
    TMP_FILE=${DIR1}/${ivar}_tmp_2018070100.nc
    OUT_FILE=${DIR1}/${ivar}_fp_${EXPNAME}_add0.nc
    cdo select,timestep=1 ${IN_FILE_1} ${TMP_FILE}
    ncap2 -s 'time(0)=7851' ${TMP_FILE} ${TMP_FILE}
    cdo mergetime ${TMP_FILE} ${IN_FILE_1} ${OUT_FILE}
    rm -f ${TMP_FILE}
    mv ${IN_FILE_1} ${IN_FILE_1}.time0_missed
    mv ${OUT_FILE} ${IN_FILE_1} 
  done
fi
