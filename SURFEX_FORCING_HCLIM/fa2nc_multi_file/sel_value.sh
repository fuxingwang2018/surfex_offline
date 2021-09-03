#!/bin/bash
#SBATCH -N 1
#SBATCH -t 0:30:00
#SBATCH -J change_time_axis
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt

# https://ryanstutorials.net/bash-scripting-tutorial/bash-loops.php

#VAR_LIST_1=('tas' 'huss' 'uas' 'vas' 'rsds' 'rlds' 'ps' 'prrain' 'prsnow')
# rsds, rsdsdir, rlds are directly aldain 3h NC output

#var_case='1H_to_3H'
var_case='add_last_record'

DIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ALADIN_ERAI

if [[ "$var_case" == "1H_to_3H" ]]; then
  VAR_LIST=('cr' 'csn' 'sr' 'ssn' 'ps' 'taL65')

  for ivar in ${VAR_LIST[@]} ; do
    IN_FILE=${DIR}/from_NorCP_1H/${ivar}_NorCP_ALADIN_ERAI_1997_2017_1H_201807.nc
    OUT_FILE=${DIR}/${ivar}_NorCP_ALADIN_ERAI_1997_2017_3H_201807.nc
    TMP_FILE=${DIR}/${ivar}_csn_tmp_NorCP_ALADIN_ERAI_1997_2017_3H_201807.nc
    for value in {1..745..3}; do
    	echo $value
    	cdo select,timestep=$value ${IN_FILE} ${TMP_FILE}_$value
    done
    cdo mergetime ${TMP_FILE}_* ${OUT_FILE}
    rm -f ${TMP_FILE}_*
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

fi
