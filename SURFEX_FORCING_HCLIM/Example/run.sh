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
#SBATCH --time=1:00:00
##SBATCH -t 1:00:00

# set name of job
#SBATCH --job-name=SFX_FORC
##SBATCH -J SFX_FORC

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
OFFLINE_HOME=/home/sm_fuxwa/SURFEX_FORCING_HCLIM/Example
OUTPUT_DIR=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/${SURFEXEXP}/SURFEX_FORC

# Define configurations
#config="-c config_forcing.cfg"
config="-c config.yml.test"
time_step=3600
[ -f $OFFLINE_HOME/$SURFEXEXP/user_$DTG.yml ] && config="-c $OFFLINE_HOME/$SURFEXEXP/user_$DTG.yml"

#converters=" --zsoro_converter phi2m --sca_sw constant --uval constant --wind_converter windspeed --wind_dir_converter winddir"
#opts=" --zval constant --uval constant --zref ml --sca_sw constant --uval constant --uref ml --co2 constant"
if [[ "$SW_METHOD" == *"SCA_ZERO"* ]]; then 
    converters=" --zsoro_converter phi2m --wind_converter windspeed --wind_dir_converter winddir"
    #opts=" --zval constant --uval constant --zref screen --uref screen --sca_sw constant --co2 constant"
    opts=" --zval ${zval_opt} --uval ${uval_opt} --zref ${ZREF} --uref ${UREF} --sca_sw constant --co2 constant"
elif [[ "$SW_METHOD" == *"SCA_VARY"* ]]; then 
    converters=" --zsoro_converter phi2m --wind_converter windspeed --wind_dir_converter winddir"
    #opts=" --zval constant --uval constant --zref screen --uref screen"
    opts=" --zval ${zval_opt} --uval ${uval_opt} --zref ${ZREF} --uref ${UREF} --co2 constant"
fi

# area grid information
area_def=../$SURFEXEXP/area.yml.$SURFEXEXP

# input file format to run create_forcing
input_format=netcdf
# output file format to be used as forcing of SURFEX offline
output_format=netcdf

# Input data
if [[ "$SURFEXEXP" == *"Svalbard"* ]]; then 
    #forcing_pattern="-p http://thredds.met.no/thredds/dodsC/aromearcticarchive/@YYYY@/@MM@/@DD@/arome_arctic_extracted_2_5km_@YYYY@@MM@@DD@T@HH@Z.nc"
    forcing_pattern="-p ${HCLIM_FORC_OUT}/arome_arctic_extracted_2_5km_20151021T15Z_test.nc"
elif [[ "$SURFEXEXP" == *"MetCoOp"* ]]; then 
    forcing_pattern="-p http://thredds.met.no/thredds/dodsC/meps25epsarchive/@YYYY@/@MM@/@DD@/meps_mbr0_extracted_2_5km_@YYYY@@MM@@DD@T@HH@Z.nc"
elif [[ "$SURFEXEXP" == *"MUMS"* ]]; then
    #forcing_pattern="-p /nobackup/rossby21/sm_fuxwa/hm_home/hm38ref_soilinit_long/archive/@YYYY@/@MM@/@DD@/@HH@/"
    forcing_pattern="-p ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}.nc"
    #$adir/fc@YYYY@@MM@@DD@@HH@+@LLL@grib_fp
fi 
[ "$FORCING_PATTERN" != "" ] && forcing_pattern=$FORCING_PATTERN
echo 'here2'

# Run create_forcing
#create_forcing $DTG $NEXT_DTG $area_def -m conf_proj_domain $forcing_pattern -i ${input_format} $config ${converters} ${opts} -o ${output_format} || exit 1
#mv FORCING.nc ${OUTPUT_DIR}/${SURFEXEXP}_FORCING_${ZREF}${mlevel}_${SW_METHOD}_${DTG}_${NEXT_DTG}.nc 

create_forcing $DTG $NEXT_DTG $area_def -m conf_proj_domain $forcing_pattern -t ${time_step} -i ${input_format} $config ${converters} ${opts} -o ${output_format} -of ${OUTPUT_DIR}/${SURFEXEXP}_FORCING_${ZREF}${mlevel}_${SW_METHOD}_${DTG}_${NEXT_DTG}.nc || exit 1
# Need to change the time format for SURFEX (e.g., 2018070100_2018080100 -> 2018070100_2018073124)
#mv ${OUTPUT_DIR}/${SURFEXEXP}_FORCING_${ZREF}${mlevel}_${SW_METHOD}_${DTG}_${NEXT_DTG}.nc ${OUTPUT_DIR}/${SURFEXEXP}_FORCING_${ZREF}${mlevel}_${SW_METHOD}_${DTG}_${NEXT_DTG_for_SURFEX}.nc

echo 'here3'
#create_forcing $DTG $NEXT_DTG $area_def -m conf_proj_domain $forcing_pattern -i netcdf $config --zsoro_converter phi2m --sca_sw constant --uval constant --wind_converter windspeed --wind_dir_converter winddir --zval constant --uval constant --zref ml --sca_sw constant --uval constant --uref ml --co2 constant -o netcdf || exit 1
