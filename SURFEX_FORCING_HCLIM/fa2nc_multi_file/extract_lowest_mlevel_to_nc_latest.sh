#!/bin/bash
#SBATCH -N 1
#SBATCH -t 8:00:00
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
mms=(08) # months

#exp="NorCP_AROME_ERAI_ALADIN_1997_2017"
#inpath="/nobackup/rossby21/rossby/joint_exp/norcp/${exp}"

# HCLIM 500m
#exp="HCLIM38h1_NORCP_ERAI_ALD_AROME_1997_2017"
#inpath="/nobackup/rossby18/rossby/joint_exp/harmony/MUMS/HCLIM38_MUMS_AROME500_NorCP/archive/2018/07/01/00_Tstep10s"
 
# AROME 3km
#exp="NorCP_AROME_ALADIN_ERAI"
#inpath="/nobackup/rossby18/rossby/joint_exp/harmony/MUMS/${exp}"
#outpath="/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/"

# ALADIN 12km
exp="NorCP_ALADIN_ERAI_1997_2017"
inpath="/nobackup/rossby21/rossby/joint_exp/norcp/${exp}/archive"
outpath="/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/NorCP_ALADIN_ERAI/"


# ---gl
#gl="/home/sm_davli/dev/gl_HCLIM38h1_SMHI/bifrost/bin/gl"
gl="/nobackup/rossby21/sm_fuxwa/hm_home/hm38ref_soilinit/bin/gl"

# -- namelist
namelist="nam_s065"

#============= END USER INPUT ==============

# --- YEAR LOOP ---
for ((yy=fy;yy<=ly;yy++)); do
# --- MONTH LOOP ---
    for mm in "${mms[@]}"; do
        files=$(find ${inpath}/${yy}/${mm}/01/00 -name ICMSHHARM* | sort | grep -v "\.sfx" | head --lines=-1)
        #files=$(find ${inpath}/${yy}/${mm} -name 'ICMSHHARM+?????' | sort | grep -v "\.sfx")
        #files=$(find ${inpath} -name 'PFHARMMUMS_500m+?????' | sort | grep -v "\.sfx")
        #files=$(find ${inpath} -name 'ICMSHHARM+00156.sfxPFHARMMUMS_500m+?????' | sort | grep -v "\.sfx")
        for f in ${files} ; do
            ${gl} -nc $f -n ${namelist} 
        done
    done # month loop
done # year loop
exit 0
