#!/bin/bash
#SBATCH -N 1
#SBATCH -t 2:00:00
#SBATCH -J cv_mlevs
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt

#----------------------------
#--- FIRST and LAST YEARS ---
#----------------------------
fy=(2018)   # first year
ly=(2018)   # last year

#----------------------------
#---        MONTHS        ---
#----------------------------
#mms=(01 02 03 04 05 06 07 08 09 10 11 12) # months
mms=(07) # months

PHYSIOGRAPHY="DEFAULT" #"2050" "NEW" #DEFAULT

if [[ "$PHYSIOGRAPHY" == "DEFAULT" ]]; then

    # AROME 3km default physiogrphy, old 2020
    #exp="GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_defaultPhys"
    #inpath="/nobackup/smhid13/sm_isari/hm_home/GreenWave/${exp}/archive"
    #outpath="/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_NEW_defaultPhys/"
    #EXPNAME=GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_defaultPhys_2018070100

    # AROME 3km default physiogrphy, new 2021-10
    exp="GreenWave_HCLIM38_CentOS7_DEFphys_newcode_NoGARDEN" #"GreenWave_HCLIM38_CentOS7_DEFphys_newcode_Optimized"
    inpath="/nobackup/smhid19/users/sm_isari/hm_home/GreenWave/${exp}/archive"
    outpath="/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_DEFphys/"
    #EXPNAME=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_DEFphys_newcode_Optimized_2018070100
    EXPNAME="GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_DEFphys_2018070100"

elif [[ "$PHYSIOGRAPHY" == "NEW" ]]; then

    # AROME 3km NEW Physiography, old 2020

    #exp="GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW"
    #inpath="/nobackup/smhid13/sm_isari/hm_home/GreenWave/${exp}/archive"
    #outpath="/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_NEW/"
    #EXPNAME=GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_2018070100

    # AROME 3km new physiogrphy, new 2021-10
    exp="GreenWave_HCLIM38_CentOS7_newCode_NEWphysJul2018_Optimized"
    inpath="/nobackup/smhid19/users/sm_isari/hm_home/GreenWave/${exp}/archive"
    outpath="/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_NEWphys/"
    #EXPNAME=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_newCode_NEWphysJul2018_Optimized_2018070100
    EXPNAME="GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_NEWphys_2018070100"

elif [[ "$PHYSIOGRAPHY" == "2050" ]]; then

    # AROME 3km 2050 Future physiogrphy, new 2021-11
    exp="GreenWave_HCLIM38_CentOS7_newCode_Phys2050_Jul2018_Opt"
    inpath="/nobackup/smhid19/users/sm_isari/hm_home/GreenWave/${exp}/archive"
    outpath="/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_2050phys/"
    #EXPNAME="GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_newCode_Phys2050_Jul2018_Opt_2018070100"
    EXPNAME="GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_2050phys_2018070100"

fi

# ---gl
gl="/nobackup/rossby26/proj/rossby/joint_exp/harmony/HCLIM43_Eval/HCLIM38_Evaluation_Install/bin/gl"

# 
# For GreenWave, we only need uamL, vamL, husL, taL, rsdsdir (3H netcdf available but we need to convert 1H from fa)
mlevel=L65 #L62, L65
var_list=('uam'${mlevel} 'vam'${mlevel} 'hus'${mlevel} 'ta'${mlevel}) # 'rsdsdir') 
#var_list=('rsdsdir') 

# -- namelist
#namelist="nam_utci"
#namelist="nam_clsvent"
#namelist="nam_rsdsdir"
#namelist="nam_mlevel"

# outputname
#var_name_out='utci_in_fp'
#var_name_out='uasm_fp'
#var_name_out='vasm_fp'
#var_name_out='clsvent'
#var_name_out='rsdsdir_fp'
#var_name_out="uamL${mlevel}_fp"
#var_name_out="vamL${mlevel}_fp"
#var_name_out="husL${mlevel}_fp"
#var_name_out="taL${mlevel}_fp"


#============= END USER INPUT ==============

# Creat outpath
if [ ! -e ${outpath} ] ; then
    mkdir -p  ${outpath}
fi

# --- Variable LOOP ---
for ivar in ${var_list[@]} ; do
  namelist=nam_${ivar}
  var_name_out=${ivar}_fp

  # --- YEAR LOOP ---
  for ((yy=fy;yy<=ly;yy++)); do
  # --- MONTH LOOP ---
    for mm in "${mms[@]}"; do
        #files=$(find ${inpath}/${yy}/${mm}/01/00 -name ICMSHHARM* | sort | grep -v "\.sfx" | head --lines=-1)

        if [[ "$namelist" != "name_utci" ]]; then
	    # for variables in ICMSHHARM file
       	    files=$(find ${inpath}/${yy}/${mm}/01/00 -name 'ICMSHHARM+?????' | sort | grep -v "\.sfx")
        elif [[ "$namelist" == "nam_utci" ]]; then
	    # for variables in ICMSHHARM*.sfx file
            files=$(find ${inpath}/${yy}/${mm}/01/00 -name ICMSHHARM+?????.sfx | sort )
	fi

        #files=$(find ${inpath} -name 'PFHARMMUMS_500m+?????' | sort | grep -v "\.sfx")
        #files=$(find ${inpath} -name 'ICMSHHARM+00156.sfxPFHARMMUMS_500m+?????' | sort | grep -v "\.sfx")
        for f in ${files} ; do
	    echo $f
	    ${gl} -nc $f -n ${namelist} -o ${outpath}/${var_name_out}_${EXPNAME}.nc
        done
    done # month loop
  done # year loop
done # variable loop
exit 0
