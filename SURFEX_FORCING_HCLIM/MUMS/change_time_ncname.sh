#!/bin/bash
#SBATCH -N 1
#SBATCH -t 8:00:00
#SBATCH -J ch_nc_nam
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt

HCLIMEXP=NorCP_ALADIN_ERAI
#HCLIMEXP=NorCP_ERAI_ALD_AROME

INDIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/SURFEX_FORC/${HCLIMEXP}
OUTDIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/SURFEX_FORC/${HCLIMEXP}
DT_START=2018070100
DT_END=2018073124
SCA=SCA_VARY
level=ml

#if [[ "${DT_END}" == "2018080100" ]]; then
#  OUTFILE=MUMS_FORCING_${level}_${SCA}_${DT_START}_2018073124.nc
#  mv ${INDIR}/${INFILE} ${OUTDIR}/${OUTFILE}
#fi

INFILE=MUMS_FORCING_${level}_${SCA}_${DT_START}_${DT_END}.nc
OUTFILE=MUMS_FORCING_${level}_${SCA}_${DT_START}_${DT_END}_3H.nc

#mv ${INDIR}/${INFILE} ${INDIR}/${INFILE}.original
cdo settunits,hours -settaxis,2018-07-01,00:00:00,3hour ${INDIR}/${INFILE}.original ${OUTDIR}/${OUTFILE}.tmp
ncap2 -s 'FRC_TIME_STP=10800.0' ${OUTDIR}/${OUTFILE}.tmp ${OUTDIR}/${OUTFILE}
ncatted -a longname,FRC_TIME_STP,o,c,"Forcing_Time_Step" ${OUTDIR}/${OUTFILE}


mv ${OUTDIR}/${OUTFILE} ${OUTDIR}/${INFILE}
rm ${OUTDIR}/${OUTFILE}.tmp
#rm ${OUTDIR}/${OUTFILE}


