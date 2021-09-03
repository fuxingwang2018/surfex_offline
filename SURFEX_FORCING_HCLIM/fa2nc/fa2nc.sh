#!/bin/bash

# Experiment name
EXPNAME=MUMS
INDIR=@YYYY@@MM@@DD@@HH

#FAFILENAME=PGD_prel.fa
#NCFILENAME=PGD_prel.nc
FAFILENAME=PGD.lfi
NCFILENAME=PGD_lfi.nc
#FAFILENAME=Const.Clim.sfx
#NCFILENAME=Const.Clim.nc

#FAFILE=/home/sm_fuxwa/SURFEX_FORCING_HCLIM/MUMS/${FAFILENAME}
#NCFILE=/home/sm_fuxwa/SURFEX_FORCING_HCLIM/MUMS/${NCFILENAME}
#FAFILE=/nobackup/rossby21/rossby/joint_exp/norcp/NorCP_ALADIN_ConstClim/${FAFILENAME}
#NCFILE=/nobackup/rossby24/users/sm_fuxwa/norcp_tile/NorCP_ALADIN_ConstClim/${NCFILENAME}
FAFILE=/nobackup/smhid13/sm_isari/hm_home/GreenWave/GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW/climate/${FAFILENAME}
NCFILE=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/Grid/HCLIM38_Summer2018_STKHM_NEW/HCLIM_139X139/${NCFILENAME}
#gl_c38='/nobackup/rossby21/sm_fuxwa/hm_home/hm38ref_soilinit/bin/gl'
gl_c38='/nobackup/rossby18/rossby/joint_exp/harmony/HCLIM38h1_NORCP_ALADIN_ECE_commit/bin/gl'
#${gl_c38} -nc ${FAFILE} -n namelist -o  ${NCFILE} -ufn
${gl_c38} -nc ${FAFILE}  -o  ${NCFILE}  
