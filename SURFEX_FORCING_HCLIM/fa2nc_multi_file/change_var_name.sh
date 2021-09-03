#!/bin/bash
#SBATCH -N 1
#SBATCH -t 0:30:00
#SBATCH -J change_time_axis
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt

# https://yidongwonyi.wordpress.com/linux-data-handling-netcdf-nc/cdo-enssum-sum-multiple-files/

#VAR_LIST_1=('tas' 'huss' 'uas' 'vas' 'rsds' 'rlds' 'ps' 'prrain' 'prsnow')
#VAR_LIST_2=('rsdsdir' 'taL65' 'husL65' 'uamL65' 'vamL65')
#varin_1='csn'
#varin_2='ssn'
#varout='prsnow'
varin_1='cr'
varin_2='sr'
varout='prrain'

DIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ALADIN_ERAI
FILEIN_1=${DIR}/${varin_1}_NorCP_ALADIN_ERAI_1997_2017_3H_201807.nc
FILEIN_2=${DIR}/${varin_2}_NorCP_ALADIN_ERAI_1997_2017_3H_201807.nc
FILEOUT=${DIR}/${varout}_NorCP_ALADIN_ERAI_1997_2017_3H_201807.nc

cdo enssum ${FILEIN_1}  ${FILEIN_2}  ${FILEOUT}.tmp
cdo chname,${varin_1},${varout} ${FILEOUT}.tmp ${FILEOUT}
rm -f ${FILEOUT}.tmp
