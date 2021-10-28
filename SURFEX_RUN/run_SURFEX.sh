#!/bin/bash

#https://slurm.schedmd.com/sbatch.html
#https://www.nsc.liu.se/support/batch-jobs/introduction/

#SBATCH -N 1 --exclusive ##number of cores
#SBATCH -J SFX_OFL
###SBATCH -n 4  ##ntasks
###SBATCH --ntasks-per-core=2 ##Request the maximum ntasks be invoked on each core. Meant to be used with the --ntasks option.
###SBATCH -C fat # only needed when running pgd.exe
#SBATCH -t 24:00:00
###SBATCH --mem-per-cpu=20000
# for OpenMP:
#SBATCH --cpus-per-task=1
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt

# Needed for /nobackup/smhid13/sm_psamu/hm_home/cy43_climate_SFX81_svn/bin  :
#export LD_LIBRARY_PATH=/software/apps/hdf5/1.8.14/i1501/lib

export OMP_NUM_THREADS=1

#2021-02-23
module purge

# Do not change here
OUTPUTPREFIX='OUT'
DEBUGNAME='DEBUG'
EXPNAME=${PWD##*/}

# Load the definations for the machine and the simulations
. ./BiNSC.def
. ./simulation.def

# Remove useless files from the old simulations
${RM} log*
#${RM} slurm_*.txt
#${RM} PREP.txt PGD.txt
${RM} ISBA_DIAG_CUMUL.OUT.nc
${RM} ISBA_DIAGNOSTICS.OUT.nc
${RM} ISBA_VEG_EVOLUTION.OUT.nc
${RM} ISBA_PROGNOSTIC.OUT.nc
${RM} TEB_CANOPY.OUT.nc
${RM} TEB_DIAGNOSTICS.OUT.nc
${RM} TEB_PROGNOSTIC.OUT.nc
${RM} WATFLUX_DIAGNOSTICS.OUT.nc
${RM} WATFLUX_PROGNOSTIC.OUT.nc
${RM} SEAFLUX_DIAG_CUMUL.OUT.nc
${RM} SEAFLUX_DIAGNOSTICS.OUT.nc
${RM} SEAFLUX_PROGNOSTIC.OUT.nc
${RM} SURF_ATM_DIAGNOSTICS.OUT.nc
${RM} SURF_ATM.OUT.nc
${RM} lai.* f_* F_*
${RM} ecoclimap* ECOCLIMAP*
${RM} GlobalLake*
${RM} BLD* LAKE*
${RM} FRAC_* WALL_*
${RM} clay* sand*
${RM} soc_* gtopo30*
${RM} Z0_TOWN.dat D*_DIF.dat GARDEN_FRAC.dat 
${RM} *.bin

# Use correct OPTIONS.nam for default and new Physiography (use 'default Physiography' by default)
ln -sf OPTIONS.nam.defaultPhysiography OPTIONS.nam  
if [ $SURFEX_URBAN_SPEC = "urban" ] ; then
    ln -sf OPTIONS.nam.newPhysiography OPTIONS.nam  
fi

#The simulation domain (grid) information
#ln -s $FORCDIR'/grid_file.txt' .
#${CP} ${FORCDIR}/grid_file.txt ${SRC_SURFEX}/MY_RUN/KTEST/${EXPNAME}

# The pysiography data
. ./Prepare_pgd

# The pysiography maps from Isabel R. Not used anymore, but keep it for a period in case needed until deleted. 
 ##ln -sf /home/sm_isari/INPUT_files/UrbanSis_physiography/PGD/* .
 #ln -sf /nobackup/smhid13/sm_esbol/harmonie_climate/40h1.1_test/PGD/* .
 ##ln -sf /nobackup/smhid13/sm_uandr/HARMONIE/data/harmonie_climate/40h1/PGD/* .
 ##ln -sf /nobackup/smhid13/sm_uandr/HARMONIE/data/climate/PGD/* .
 #ln -sf /nobackup/smhid13/sm_uandr/HARMONIE/data/harmonie_climate/ECOCLIMAP/7.3/* .

# The input files for PGD and PREP (usually from HCLIM run) 
# 2021 Oct: use common names PREPINI.lfi and PGDINI.lfi to avoid confusion.
if [ $INIT_FILE = "ICMSHFULL" ] ; then
    ln -sf ${INFILE_ICMSHHARM} ICMSHFULL+00000.sfx
    ##ln -sf ${INFILE_ICMSHFULL} .
    ln -sf ${INFILE_PGD} Const.Clim.sfx
    # Convert FA to LFI, because CTYPE in &NAM_PREP_SEAFLUX does not accept FA.
    SFXTOOLS='/nobackup/rossby26/proj/rossby/joint_exp/harmony/HCLIM43_Eval/HCLIM38_Evaluation_Install/bin/SFXTOOLS'
    ${SFXTOOLS} sfxfa2lfi --sfx-fa--file ICMSHFULL+00000.sfx --sfx-lfi-file ICMSHFULL+00000.lfi
    ${SFXTOOLS} sfxfa2lfi --sfx-fa--file Const.Clim.sfx --sfx-lfi-file Const.Clim.lfi
    ln -sf ICMSHFULL+00000.lfi PREPINI.lfi
    ln -sf Const.Clim.lfi      PGDINI.lfi
elif [ $INIT_FILE = "SURFXINI" ] ; then
    #ln -sf ${INFILE_PREP} .
    #ln -sf ${INFILE_PGD} PGD.lfi
    ln -sf ${INFILE_PREP} PREPINI.lfi
    ln -sf ${INFILE_PGD}  PGDINI.lfi
fi



# The executables
ln -sf ${PGD_PATH} pgd.exe
ln -sf ${PREP_PATH} prep.exe

if [ ${RUNEXE} == 'PGDPREP' ] ; then
  # PGD ("The physiographic fields") 
  ./pgd.exe 
  # PREP ("Initialization of the prognostic fields")
  ./prep.exe
fi


# Simulation outputs
EXPOUTDIR=$OUTPUTDIR/${EXPNAME}/
if [ ! -e ${EXPOUTDIR} ] ; then
    ${MKDIR} ${EXPOUTDIR}
fi

# Debug files
DEBUGDIR=$OUTPUTDIR/${EXPNAME}/${DEBUGNAME}/
if [ ! -e ${DEBUGDIR} ] ; then
    ${MKDIR} ${DEBUGDIR}
else
    ${RM} ${DEBUGDIR}/LISTING_OFFLINE*.txt
fi

# Initial conditions 
${CP} PGD.txt  ${DEBUGDIR}/PGD0.txt
${CP} PREP.txt ${DEBUGDIR}/PREP0.txt


if [ ${RUNEXE} == 'PGDPREP' ] ; then
  exit
elif [ ${RUNEXE} == 'OFFLINE' ] ; then
  ln -sf ${PGD_PREP_DIR}/PGD0.txt  PGD.txt  
  ln -sf ${PGD_PREP_DIR}/PREP0.txt PREP.txt 
fi

yy=${FIRST_YEAR}
while [  ${yy} -le ${LAST_YEAR} ]; do

  mm=${FIRST_MONTH}
  while [  ${mm} -le ${LAST_MONTH} ]; do

    if  [[ ${mm} -eq 1 || ${mm} -eq 3 || ${mm} -eq 5 || ${mm} -eq 7 || ${mm} -eq 8 || ${mm} -eq 10 || ${mm} -eq 12 ]]; then
        NDAY=31
    elif  [[ ${mm} -eq 4 || ${mm} -eq 6 || ${mm} -eq 9 || ${mm} -eq 11 ]]; then
        NDAY=30
    elif  [[ ${mm} -eq 2 ]]; then
        if [[ $(( ${yy} % 4 )) -eq 0 && ( $(( ${yy} % 100)) -ne 0 || $((${yy} % 400)) -eq 0 ) ]]; then
            NDAY=29
        else
            NDAY=28
    	fi
    fi

    if [[ ${#mm} -lt 2 ]] ; then
	mm2d="0${mm}"
    else
	mm2d="${mm}"
    fi
    echo The current year-month-total day is: $yy $mm2d, ${NDAY}

    ${RM} -rf FORCING.nc
    DEBR=$DEBUGDIR/${EXPNAME}"_modelstdout_"${yy}${mm2d}".log"
    if [ -e ${DEBR} ] ; then
        echo "File " ${DEBR} "exists. Removing it ..."
        ${RM} -rf ${DEBR}
    fi

# Link to the RCA output forcing files:
    #forcingfile='FORCING_'$yy$mm2d'.nc'
    forcingfile=${FORCPREFIX}'_'${yy}${mm2d}${FIRST_DAY}${FIRST_HOUR}'_'${yy}${mm2d}${NDAY}${LAST_HOUR}'.nc'
    echo 'forcingfile', $FORCDIR/$forcingfile
    #forcingfile='MUMS_FORCING_2015010100_2015011000.nc'
    ln -s $FORCDIR/$forcingfile FORCING.nc

    #current_date_time="`date +%Y%m%d%H%M%S`";
    current_date_time="`date`";
    echo The simulation starts from $current_date_time
    
    # Need to change the number of CPUs here
    #${MPIRUN} -n 16 ${MODEL} >> ${DEBR}
    # mpprun/srun does not require the number of ranks to be specified at thempprun command line
    # https://www.nsc.liu.se/support/tutorials/mpprun/
    ${MPPRUN} ${MODEL} >> ${DEBR}
    #${SRUN} ${MODEL} >> ${DEBR}

    #mpprun SURFEX_Bi
    current_date_time="`date`";
    echo The simulation ends at $current_date_time 
    echo ""

# Make a directory for ecah month and move SURFEX output NetCDF files there
    ${MKDIR} -p $EXPOUTDIR/$OUTPUTPREFIX'_'$yy$mm2d
    ${MV} *.OUT.nc $EXPOUTDIR/$OUTPUTPREFIX'_'$yy$mm2d/
# Move the restart file SURFOUT.txt to new initial state file PREP.txt
    ${CP} SURFOUT.txt $EXPOUTDIR/$OUTPUTPREFIX'_'$yy$mm2d/
    ${MV} SURFOUT.txt PREP.txt
# Move txt files to DEBUG 
    ${MV} LISTING*.txt $DEBUGDIR

    let mm=mm+1
    #while [[ ${#mm} -lt 2 ]] ; do
    #  mm="0${mm}"
    #done

  done

  let yy=yy+1 
done

exit
