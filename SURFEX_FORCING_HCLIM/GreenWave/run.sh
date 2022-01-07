#!/bin/bash

# To run create_forcing which is installed from 
# https://github.com/metno/offline-surfex-forcing
# Fuxing Wang, 29 May 2019, Rossby SMHI
#
# set the number of nodes and processes per node
#SBATCH --nodes=1
##SBATCH -N1 ##number of cores

# set the number of tasks (processes) per node.
#SBATCH --ntasks-per-node=2
##SBATCH -n 2  ##number of processors/cores

# set max wallclock time
#SBATCH --time=6:00:00
##SBATCH -t 3:00:00

# set name of job
#SBATCH --job-name=SFX_FORC
##SBATCH -J SFXFORC

# mail alert at start, end and abortion of execution
###SBATCH --mail-type=ALL

# send mail to this address
###SBATCH --mail-user=fuxing.wang@smhi.se

#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt

# Load the definations for the machine
. ./BiNSC.def
# Load the definations for the forcing
. ./forcing.def

#
#OFFLINE_HOME=/home/sm_fuxwa/SURFEX_FORCING_HCLIM/${SURFEXEXP}
#OUTPUT_DIR=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/${SURFEXEXP}/SURFEX_FORC/${HCLIMEXP}
OFFLINE_HOME=/home/sm_fuxwa/surfex_offline/SURFEX_FORCING_HCLIM/${SURFEXEXP}
OUTPUT_DIR=/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/${SURFEXEXP}/SURFEX_FORC/${HCLIMEXP}

# Define configurations
# time step: by default 3600s (1H)
#if [[ "${HCLIMEXP}" == "HCLIM38_Summer2018_STKHM_NEW" ]] || [[ "${HCLIMEXP}" == "HCLIM38_Summer2018_STKHM_NEW_defaultPhys" ]] || [[ "${HCLIMEXP}" == "HCLIM38_Summer2018_STKHM_DEFphys" ]]; then
if [[ "${HCLIMEXP}" == "HCLIM38_Summer2018_STKHM"* ]]; then
    config="-c config.yml.${ZREF}${mlevel}"
    time_step=3600
    #time_step=10800
elif [[ "${HCLIMEXP}" == "NorCP_AROME_ERAI_ALADIN_1997_2017" ]]; then
    config="-c config.yml.${ZREF}${mlevel}.${TSTEP}"
    time_step=10800
fi

[ -f $OFFLINE_HOME/user_$DTG.yml ] && config="-c $OFFLINE_HOME/user_$DTG.yml"

#converters=" --zsoro_converter phi2m --sca_sw constant --uval constant --wind_converter windspeed --wind_dir_converter winddir"
#opts=" --zval constant --uval constant --zref ml --sca_sw constant --uval constant --uref ml --co2 constant"
if [[ "$SW_METHOD" == *"SCA_ZERO"* ]]; then 
    converters=" --zsoro_converter phi2m --wind_converter windspeed --wind_dir_converter winddir"
    #opts=" --zval constant --uval constant --zref ${ZREF} --uref ${UREF} --sca_sw constant --co2 constant"
    opts=" --zval ${zval_opt} --uval ${uval_opt} --zref ${ZREF} --uref ${UREF} --sca_sw constant --co2 constant"
elif [[ "$SW_METHOD" == *"SCA_VARY"* ]]; then 
    converters=" --zsoro_converter phi2m --wind_converter windspeed --wind_dir_converter winddir"
    #opts=" --zval constant --uval constant --zref ${ZREF} --uref ${UREF} --co2 constant"
    opts=" --zval ${zval_opt} --uval ${uval_opt} --zref ${ZREF} --uref ${UREF} --co2 constant"
fi

# area grid information
area_def=area.yml.$SURFEXEXP

# input file format to run create_forcing
input_format=netcdf
# output file format to be used as forcing of SURFEX offline
output_format=netcdf

# Input data
if [[ "$SURFEXEXP" == *"Svalbard"* ]]; then 
    forcing_pattern="-p http://thredds.met.no/thredds/dodsC/aromearcticarchive/@YYYY@/@MM@/@DD@/arome_arctic_extracted_2_5km_@YYYY@@MM@@DD@T@HH@Z.nc"
elif [[ "$SURFEXEXP" == *"MetCoOp"* ]]; then 
    forcing_pattern="-p http://thredds.met.no/thredds/dodsC/meps25epsarchive/@YYYY@/@MM@/@DD@/meps_mbr0_extracted_2_5km_@YYYY@@MM@@DD@T@HH@Z.nc"
elif [[ "$SURFEXEXP" == *"MUMS"* ]]; then
    #forcing_pattern="-p /nobackup/rossby21/sm_fuxwa/hm_home/hm38ref_soilinit_long/archive/@YYYY@/@MM@/@DD@/@HH@/"
    forcing_pattern="-p ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}.nc"
    #$adir/fc@YYYY@@MM@@DD@@HH@+@LLL@grib_fp
elif [[ "$SURFEXEXP" == *"GreenWave"* ]]; then
    forcing_pattern="-p ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}.nc"
fi 
[ "$FORCING_PATTERN" != "" ] && forcing_pattern=$FORCING_PATTERN

# Creat OUTPUT_DIR
if [ ! -e ${OUTPUT_DIR} ] ; then
    mkdir -p  ${OUTPUT_DIR}
fi

# Run create_forcing
create_forcing $DTG $NEXT_DTG $area_def -m conf_proj_domain $forcing_pattern -t ${time_step} -i ${input_format} $config ${converters} ${opts} -o ${output_format} -of ${OUTPUT_DIR}/${SURFEXEXP}_FORCING_${ZREF}${mlevel}_${SW_METHOD}_${DTG}_${NEXT_DTG}.nc || exit 1
# Need to change the time format for SURFEX (e.g., 2018070100_2018080100 -> 2018070100_2018073124)
mv ${OUTPUT_DIR}/${SURFEXEXP}_FORCING_${ZREF}${mlevel}_${SW_METHOD}_${DTG}_${NEXT_DTG}.nc ${OUTPUT_DIR}/${SURFEXEXP}_FORCING_${ZREF}${mlevel}_${SW_METHOD}_${DTG}_${NEXT_DTG_for_SURFEX}.nc
#mv FORCING.nc ${OUTPUT_DIR}/${SURFEXEXP}_FORCING_${ZREF}_${SW_METHOD}_${DTG}_${NEXT_DTG}.nc 

#create_forcing $DTG $NEXT_DTG $area_def -m conf_proj_domain $forcing_pattern -i netcdf $config --zsoro_converter phi2m --sca_sw constant --uval constant --wind_converter windspeed --wind_dir_converter winddir --zval constant --uval constant --zref ml --sca_sw constant --uval constant --uref ml --co2 constant -o netcdf || exit 1


if [[ "${TSTEP}" == "3H" ]]; then

    module load NCO/4.6.3-nsc1

    FILE_ORIGINAL=${OUTPUT_DIR}/${SURFEXEXP}_FORCING_${ZREF}${mlevel}_${SW_METHOD}_${DTG}_${NEXT_DTG_for_SURFEX}.nc
    FILE_CHANGED=${OUTPUT_DIR}/${SURFEXEXP}_FORCING_3H_${ZREF}${mlevel}_${SW_METHOD}_${DTG}_${NEXT_DTG_for_SURFEX}.nc
    mv ${FILE_ORIGINAL} ${FILE_ORIGINAL}.original

    cdo settunits,hours -settaxis,${YEAR}-${MONTH}-${DAYSTART},00:00:00,3hour ${FILE_ORIGINAL}.original  ${FILE_CHANGED}.tmp
    ncap2 -s 'FRC_TIME_STP=10800.0' ${FILE_CHANGED}.tmp ${FILE_CHANGED}
    ncatted -a longname,FRC_TIME_STP,o,c,"Forcing_Time_Step" ${FILE_CHANGED}

    rm ${FILE_ORIFINAL}.tmp
    rm ${FILE_CHANGED}.tmp

fi


