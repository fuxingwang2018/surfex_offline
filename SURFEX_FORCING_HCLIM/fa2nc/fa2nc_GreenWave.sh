#!/bin/bash

# Experiment name
EXPNAME=GreenWave
INDIR=@YYYY@@MM@@DD@@HH

#FAFILENAME=PGD_prel.fa
#NCFILENAME=PGD_prel.nc
#FAFILENAME=PGD.lfi
#NCFILENAME=PGD_lfi.nc
FAFILENAME=Const.Clim.sfx
NCFILENAME=Const.Clim.nc

FAFILE=/nobackup/smhid13/sm_isari/hm_home/GreenWave/GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_defaultPhys_ForSURFEXoffline/climate/${FAFILENAME}
NCFILE=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/${NCFILENAME}
gl_c38='/nobackup/rossby21/sm_fuxwa/hm_home/hm38ref_soilinit/bin/gl'

#${gl_c38} -nc ${FAFILE} -n namelist -o  ${NCFILE} -ufn
${gl_c38} -nc ${FAFILE}  -o  ${NCFILE}  
