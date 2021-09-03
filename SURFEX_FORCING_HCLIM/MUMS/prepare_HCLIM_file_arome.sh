#!/bin/bash

# HCLIM direct outputs are written in different formats (fa, lfi and nc) and in different files,
# while the same format (e.g., nc) of all variables in one single file is necesary to run create_forcing.
# This script integrates all the HCLIM output variables in one nc file.  
# 
# Fuxing Wang, 29 May 2019, Rossby SMHI
#
# Load the definations for the machine
. ./BiNSC.def
. ./forcing.def

# Definations
# AROME 3km
# NorCP_AROME_ERAI_ALADIN_1997_2017_500m
HCLIMARCH=/nobackup/rossby21/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/MUMS/HCLIM38_SIM_2D/${HCLIMEXP}
HCLIMNAME=NORDIC3_HCLIM38h1_NORCP_ERAI_ALD_AROME_1997_2017_500m
#HCLIMSIM=/nobackup/rossby21/rossby/joint_exp/norcp/${HCLIMEXP}
OUTF_NAME_TMP=HCLIM38_FORC_${SURFEXEXP}_TMP_${HCLIMDTG}.nc

# Variables
VAR_Z=zs
VAR_SWDOWN=rsds
VAR_DIR_SWDOWN=rsdsdir
VAR_SCA_SWDOWN=rsdssca
VAR_LWDOWN=rlds
VAR_PSURF=ps
VAR_PRRAIN=prrain
VAR_PRSNOW=prsnow

if [[ "$ZREF" == *"screen"* ]]; then 
    VAR_TAIR=tas
    VAR_QAIR=huss
elif [[ "$ZREF" == *"ml"* ]]; then 
    VAR_TAIR=taL65
    VAR_QAIR=husL65
fi
if [[ "$UREF" == *"screen"* ]]; then 
    VAR_UAS=uas
    VAR_VAS=vas
elif [[ "$UREF" == *"ml"* ]]; then 
    VAR_UAS=uamL65
    VAR_VAS=vamL65
fi


# The nc file for each variable

# ZS: "Surface_Orography" ;
IN_NC_ZS=/home/sm_fuxwa/SURFEX_FORCING_HCLIM/Regrid/zs.nc

# Tair, tas_fp, "Near_Surface_Air_Temperature" ; units = "K" ; :measurement_height = "30m" ;
IN_NC_TAIR=${HCLIMARCH}/${HCLIMTIME}/${VAR_TAIR}_fp_${HCLIMNAME}_${HCLIMDTG}.nc

# Qair, huss_fp, "Near_Surface_Specific_Humidity" ; units = "Kg/Kg" ; measurement_height = "30m" ;
IN_NC_QAIR=${HCLIMARCH}/${HCLIMTIME}/${VAR_QAIR}_fp_${HCLIMNAME}_${HCLIMDTG}.nc

# Wind, uas_fp vas_fp, "Wind_Speed" ; units = "m/s" ; measurement_height = "30m" ;
IN_NC_UAS=${HCLIMARCH}/${HCLIMTIME}/${VAR_UAS}_fp_${HCLIMNAME}_${HCLIMDTG}.nc
IN_NC_VAS=${HCLIMARCH}/${HCLIMTIME}/${VAR_VAS}_fp_${HCLIMNAME}_${HCLIMDTG}.nc
# Wind_DIR "Wind_Direction" ; units = "deg" ;

# DIR_SWdown, rsdsdir: "Surface_Indicent_Direct_Shortwave_Radiation" ; units = "W/m2" ; 
IN_NC_DIR_SWDOWN=${HCLIMARCH}/${HCLIMTIME}/${VAR_DIR_SWDOWN}_fp_${HCLIMNAME}_${HCLIMDTG}.nc
# SWdown, rsds: "Surface_Indicent_Shortwave_Radiation" ; units = "W/m2" ; 
IN_NC_SWDOWN=${HCLIMARCH}/${HCLIMTIME}/${VAR_SWDOWN}_fp_${HCLIMNAME}_${HCLIMDTG}.nc

# SCA_SWdown, rsds-rsdsdir, "Surface_Incident_Diffuse_Shortwave_Radiation" ; units = "W/m2" ;
#cdo setname,rsdssca -sub ${IN_NC_SWDOWN} ${IN_NC_DIR_SWDOWN} ${HCLIM_FORC_OUT}/rsdssca_fp_${HCLIMNAME}_${HCLIMDTG}.nc
cdo sub ${IN_NC_SWDOWN} ${IN_NC_DIR_SWDOWN} ${HCLIM_FORC_OUT}/${VAR_SCA_SWDOWN}_fp_${HCLIMNAME}_${HCLIMDTG}_tmp.nc
cdo chname,${VAR_SWDOWN},${VAR_SCA_SWDOWN} ${HCLIM_FORC_OUT}/${VAR_SCA_SWDOWN}_fp_${HCLIMNAME}_${HCLIMDTG}_tmp.nc ${HCLIM_FORC_OUT}/${VAR_SCA_SWDOWN}_fp_${HCLIMNAME}_${HCLIMDTG}.nc
rm -f ${HCLIM_FORC_OUT}/${VAR_SCA_SWDOWN}_fp_${HCLIMNAME}_${HCLIMDTG}_tmp.nc
IN_NC_SCA_SWDOWN=${HCLIM_FORC_OUT}/${VAR_SCA_SWDOWN}_fp_${HCLIMNAME}_${HCLIMDTG}.nc

# LWdown, rlds: "Surface_Incident_Longwave_Radiation" ; units = "W/m2" ;
IN_NC_LWDOWN=${HCLIMARCH}/${HCLIMTIME}/${VAR_LWDOWN}_fp_${HCLIMNAME}_${HCLIMDTG}.nc

# PSurf, ps_fp: "Surface_Pressure" ; units = "Pa" ;
IN_NC_PSURF=${HCLIMARCH}/${HCLIMTIME}/${VAR_PSURF}_fp_${HCLIMNAME}_${HCLIMDTG}.nc

# Rainf, prrain: "Rainfall_Rate" ; units = "Kg/m2/s" ;
IN_NC_PRRAIN=${HCLIMARCH}/${HCLIMTIME}/${VAR_PRRAIN}_fp_${HCLIMNAME}_${HCLIMDTG}.nc

# Snowf, prsnow: "Snowfall_Rate" ; units = "Kg/m2/s" ;
IN_NC_PRSNOW=${HCLIMARCH}/${HCLIMTIME}/${VAR_PRSNOW}_fp_${HCLIMNAME}_${HCLIMDTG}.nc

# CO2air, "Near_Surface_CO2_Concentration" ; units = "Kg/m3" ;

# To merge all variables in one nc file
cdo merge ${IN_NC_TAIR}       ${IN_NC_QAIR}       ${IN_NC_UAS}    ${IN_NC_VAS} \
          ${IN_NC_DIR_SWDOWN} ${IN_NC_SCA_SWDOWN} ${IN_NC_SWDOWN} ${IN_NC_LWDOWN} \
          ${IN_NC_PSURF}      ${IN_NC_PRRAIN}     ${IN_NC_PRSNOW} ${IN_NC_ZS} \
          ${HCLIM_FORC_OUT}/${OUTF_NAME_TMP}

# change variable names in the netcdf file
cdo chname,${VAR_Z},surface_geopotential ${HCLIM_FORC_OUT}/${OUTF_NAME_TMP} ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_1.nc

if [[ "$UREF" == *"screen"* ]]; then 
    cdo chname,${VAR_UAS},x_wind_10m,${VAR_VAS},y_wind_10m ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_1.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_2.nc
elif [[ "$UREF" == *"ml"* ]]; then 
    cdo chname,${VAR_UAS},x_wind_ml,${VAR_VAS},y_wind_ml ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_1.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_2.nc
fi

#cdo chname,prrain,rainfall_amount,prsnow,snowfall_amount ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_2.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_3.nc
cdo chname,${VAR_PRRAIN},precipitation_amount_acc,${VAR_PRSNOW},snowfall_amount_acc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_2.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_3.nc
cdo chname,${VAR_PSURF},surface_air_pressure ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_3.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_4.nc

if [[ "$SW_METHOD" == *"SCA_ZERO"* ]]; then 
    cdo chname,${VAR_SWDOWN},integral_of_surface_downwelling_shortwave_flux_in_air_wrt_time, ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_4.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_5.nc
elif [[ "$SW_METHOD" == *"SCA_VARY"* ]]; then 
    cdo chname,${VAR_DIR_SWDOWN},integral_of_surface_downwelling_shortwave_flux_in_air_wrt_time,${VAR_SCA_SWDOWN},scattered_short_wave_radiation ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_4.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_5.nc
fi

cdo chname,${VAR_LWDOWN},integral_of_surface_downwelling_longwave_flux_in_air_wrt_time ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_5.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_6.nc

if [[ "$ZREF" == *"screen"* ]]; then 
    cdo chname,${VAR_TAIR},air_temperature_2m,${VAR_QAIR},specific_humidity_2m ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_6.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_7.nc
elif [[ "$ZREF" == *"ml"* ]]; then 
    cdo chname,${VAR_TAIR},air_temperature_ml,${VAR_QAIR},specific_humidity_ml ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_6.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_7.nc
fi
ncrename -v lat,latitude -v lon,longitude  ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_7.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_8.nc

mv ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_8.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}.nc

# remove temporary files
rm -f ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_*.nc
rm -f ${HCLIM_FORC_OUT}/${OUTF_NAME_TMP}
rm -f ${HCLIM_FORC_OUT}/${VAR_SCA_SWDOWN}_fp_${HCLIMNAME}_${HCLIMDTG}.nc

# split the nc file (whole month) to each time step (1 hour)
#cdo splitsel,1 ${HCLIMARCH}/${HCLIMTIME}/${IN_NC_TAIR} ${HCLIM_FORC_OUT}
