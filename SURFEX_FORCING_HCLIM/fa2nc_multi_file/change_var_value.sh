#!/bin/bash
#SBATCH -N 1
#SBATCH -t 8:00:00
#SBATCH -J cv_mlevs
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt
#EXP=MUMS
EXP=GreenWave
#DTG=2018070100_3H
DTG=2018070100

if [[ "$EXP" == "MUMS" ]]; then
  #NorCP_ERAI_ALD_AROME
  HCLIMEXP=NorCP_ERAI_ALD_AROME
  INDIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/${HCLIMEXP}
  OUTDIR=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/${HCLIMEXP}
  # ml, screen
  level=screen

  #INFILE=rsdsdir_fp_NORDIC3_HCLIM38h1_NORCP_ERAI_ALD_AROME_1997_2017_500m_2018070100.nc
  #OUTFILE=rsdsdir_fp_NORDIC3_HCLIM38h1_NORCP_ERAI_ALD_AROME_1997_2017_500m_2018070100_test.nc
  #ncap2 -s 'rsdsdir(0,:,:)=0.0' ${INDIR}/${INFILE} ${OUTDIR}/${OUTFILE}

  INFILE=HCLIM38_FORC_MUMS_${level}_SCA_VARY_2018070100.nc
  OUTFILE1=HCLIM38_FORC_MUMS_${level}_SCA_VARY_2018070100_tmp.nc
  OUTFILE2=HCLIM38_FORC_MUMS_${level}_SCA_VARY_2018070100.nc
  mv ${INDIR}/${INFILE} ${INDIR}/${INFILE}.original
  ncap2 -s 'scattered_short_wave_radiation(0,:,:)=0.0' ${INDIR}/${INFILE}.original ${OUTDIR}/${OUTFILE1}
  ncap2 -s 'integral_of_surface_downwelling_shortwave_flux_in_air_wrt_time(0,:,:)=0.0' ${INDIR}/${OUTFILE1} ${OUTDIR}/${OUTFILE2}
  rm ${OUTDIR}/${OUTFILE1}

elif [[ "$EXP" == "GreenWave" ]]; then

  HCLIMEXP=HCLIM38_Summer2018_STKHM_NEW_defaultPhys
  INDIR=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/${HCLIMEXP}
  OUTDIR=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/${HCLIMEXP}
  # ml, screen
  level=ml50m

  INFILE=HCLIM38_FORC_GreenWave_${level}_SCA_VARY_${DTG}.nc
  OUTFILE1=HCLIM38_FORC_GreenWave_${level}_SCA_VARY_${DTG}_tmp.nc
  OUTFILE2=HCLIM38_FORC_GreenWave_${level}_SCA_VARY_${DTG}_changed.nc
  cp ${INDIR}/${INFILE} ${INDIR}/${INFILE}.original
  ncatted -O -a units,time,o,c,"days since 1997-01-01 00:00:00.0" ${INDIR}/${INFILE}.original ${OUTDIR}/${OUTFILE1}
  ncap2 -s 'time=time+7851' ${INDIR}/${OUTFILE1} ${OUTDIR}/${OUTFILE2}
  rm ${OUTDIR}/${OUTFILE1}

fi
