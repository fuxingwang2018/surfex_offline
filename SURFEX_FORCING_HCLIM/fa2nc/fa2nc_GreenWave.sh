#!/bin/bash

gl_c38='/nobackup/rossby26/proj/rossby/joint_exp/harmony/HCLIM43_Eval/HCLIM38_Evaluation_Install/bin/gl'

# Experiment name
#EXPNAMEIN=GreenWave_HCLIM38_CentOS7_DEFphys_newcode_Optimized
#EXPNAMEOUT=HCLIM38_Summer2018_STKHM_DEFphys
EXPNAMEIN=GreenWave_HCLIM38_CentOS7_newCode_NEWphysJul2018_Optimized
EXPNAMEOUT=HCLIM38_Summer2018_STKHM_NEWphys

Grid_name=HCLIM_150X150
#Grid_name=HCLIM_139X139

INDIR='/nobackup/smhid19/users/sm_isari/hm_home/GreenWave/'${EXPNAMEIN}'/climate/'
OUTDIR='/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/Grid/'${EXPNAMEOUT}'/'


if [[ "$Grid_name" == "HCLIM_150X150" ]]; then
    FAFILENAME=Const.Clim.sfx
    NCFILENAME=Const.Clim.nc
elif [[ "$Grid_name" == "HCLIM_139X139" ]]; then
    FAFILENAME=PGD.lfi
    NCFILENAME=PGD_lfi.nc
fi
#FAFILENAME=PGD_prel.fa ! did not use
#NCFILENAME=PGD_prel.nc ! did not use

FAFILE=${INDIR}/${FAFILENAME}
NCFILE=${OUTDIR}/${Grid_name}/${NCFILENAME}


#${gl_c38} -nc ${FAFILE} -n namelist -o  ${NCFILE} -ufn
${gl_c38} -nc ${FAFILE}  -o  ${NCFILE}  
