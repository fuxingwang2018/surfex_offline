#!/bin/bash
#SBATCH -N 1
#SBATCH -t 0:30:00
#SBATCH -J change_time_axis
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt

#Rename the dimension z to time
#ncrename -O -d z,time -v z,time $infile tmp.nc

#Change attributes of time
#ncatted -O -a units,time,o,c,"days since 1997-01-01 00:00:00.0" -a long_name,time,o,c,"Time"  -a standard_name,time,o,c,"time"  -a calendar,time,o,c,"standard" -a _CoordinateAxisType,time,o,c,"Time"  hus_S065_201807.cp.nc hus_S065_201807.tmp.nc

#Now, let CDO do the correct settings for time (e.g. calendar attribute)
#cdo settaxis,1997-01-01-00,00:00:00,1hour hus_S065_201807.tmp.nc outfile.nc

VAR_LIST_1=('tas' 'huss' 'uas' 'vas' 'rsds' 'rlds' 'ps' 'prrain' 'prsnow')
VAR_LIST_2=('rsdsdir' 'taL65' 'husL65' 'uamL65' 'vamL65')
VAR_LIST=('prrain' 'prsnow')

HCLIMDTG='2018070100'
HCLIMDTG0='2018060100'
HCLIMNAME=NORDIC3_HCLIM38h1_NORCP_ERAI_ALD_AROME_1997_2017
OUT_DIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D

for ivar in ${VAR_LIST[@]} ; do
    echo 'variable:' ${ivar} 
    cdo cat ${ivar}_${HCLIMDTG0}.nc ${ivar}_${HCLIMDTG}.nc ${ivar}_${HCLIMDTG0}_${HCLIMDTG}.nc
    mv ${ivar}_${HCLIMDTG0}_${HCLIMDTG}.nc ${OUT_DIR}/${ivar}_fp_${HCLIMNAME}_${HCLIMDTG}.nc
done
