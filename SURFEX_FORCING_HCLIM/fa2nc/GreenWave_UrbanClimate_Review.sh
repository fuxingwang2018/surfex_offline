#!/bin/bash
#SBATCH -N 1
#SBATCH -t 6:00:00
#SBATCH -J fa2nc
shopt -s extglob

# Default
#EXPNAME="GreenWave_HCLIM38_CentOS7_DEFphys_newcode_NoGARDEN"
# Refine
EXPNAME="GreenWave_HCLIM38_CentOS7_newCode_NEWphysJul2018_Optimized" 

CLIMATE_FILE="Const.Clim.sfx"
IN_EXP_PATH="/nobackup/smhid19/users/sm_isari/hm_home/GreenWave/${EXPNAME}"

OUT_PATH="/nobackup/rossby27/users/sm_fuxwa/SURFEX_OUT/GreenWave/${EXPNAME}"

# ---gl
#gl="/nobackup/rossby27/users/sm_fuxwa/hm_home/hclim43/CORDEX6/CORDEX6_output_test_402ca0f_Install/bin/gl"
#gl="/nobackup/rossby26/users/sm_fuxwa/hm_home/hclim43/Aerosol/HCLIM43_aerosol_fb1bd2_Install/bin/gl"
gl_c38='/nobackup/rossby26/proj/rossby/joint_exp/harmony/HCLIM43_Eval/HCLIM38_Evaluation_Install/bin/gl'

# -- namelist
namelist="/home/sm_fuxwa/Script/fa2nc/namelist_GreenWave_UrbanClimate_Review"

#============= END USER INPUT ==============

FA_FILE=${IN_EXP_PATH}/climate/${CLIMATE_FILE}
#ln -s ${FA_FILE} ${OUT_YYMM}/
cp -f ${FA_FILE} ${OUT_PATH}/${CLIMATE_FILE}
#${gl_c38} -nc ${OUT_PATH}/${CLIMATE_FILE} -n ${namelist} -o ${OUT_PATH}/test.nc
${gl_c38} -nc ${OUT_PATH}/${CLIMATE_FILE}  -o ${OUT_PATH}/test.nc

exit 0
