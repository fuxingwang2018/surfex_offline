#!/bin/bash
#SBATCH -N 1
#SBATCH -t 8:00:00
#SBATCH -J ch_nc_nam
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt

module load NCO/4.6.3-nsc1

HCLIMEXP=NorCP_AROME_ERAI_ALADIN_1997_2017
PROJECT=GreenWave

INDIR=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/${PROJECT}/SURFEX_FORC/${HCLIMEXP}
OUTDIR=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/${PROJECT}/SURFEX_FORC/${HCLIMEXP}
DT_START=2018050100
DT_END=2018053124
SCA=SCA_VARY
level=ml50m

#if [[ "${DT_END}" == "2018080100" ]]; then
#  OUTFILE=MUMS_FORCING_${level}_${SCA}_${DT_START}_2018073124.nc
#  mv ${INDIR}/${INFILE} ${OUTDIR}/${OUTFILE}
#fi

INFILE=${PROJECT}_FORCING_${level}_${SCA}_${DT_START}_${DT_END}.nc
OUTFILE=${PROJECT}_FORCING_3H_${level}_${SCA}_${DT_START}_${DT_END}.nc

mv ${INDIR}/${INFILE} ${INDIR}/${INFILE}.original
cdo settunits,hours -settaxis,2018-05-01,00:00:00,3hour ${INDIR}/${INFILE}.original ${OUTDIR}/${OUTFILE}.tmp
ncap2 -s 'FRC_TIME_STP=10800.0' ${OUTDIR}/${OUTFILE}.tmp ${OUTDIR}/${OUTFILE}
ncatted -a longname,FRC_TIME_STP,o,c,"Forcing_Time_Step" ${OUTDIR}/${OUTFILE}


#mv ${OUTDIR}/${OUTFILE} ${OUTDIR}/${INFILE}
rm ${OUTDIR}/${OUTFILE}.tmp
#rm ${OUTDIR}/${OUTFILE}


