#!/bin/bash

# HCLIM direct outputs are written in different formats (fa, lfi and nc) and in different files,
# while the same format (e.g., nc) of all variables in one single file is necesary to run create_forcing.
# This script integrates all the HCLIM output variables in one nc file.  
# The script aims to have the same variables format as  
#  /nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/sfx_ofl_forc_test_data/AROME_MetCoOp_06_fp.nc_20151231
# 
# Fuxing Wang, 29 May 2019, Rossby SMHI
#
module load NCO/4.8.1-nsc1
# Load the definations for the machine
. ./BiNSC.def
. ./forcing.def

# Definations the regridded files

if [[ "$HCLIMEXP" == HCLIM38_Summer2018_STKHM_NEW ]]; then 
    # Case of New physiography, CentOS6
    HCLIMARCH=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_NEW
    HCLIMNAME=GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_300m
elif [[ "$HCLIMEXP" == HCLIM38_Summer2018_STKHM_NEW_defaultPhys ]]; then
    # Case of default physiography, CentOS6
    HCLIMARCH=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_NEW_defaultPhys
    HCLIMNAME=GrW_STHLM3.0_GreenWave_HCLIM38_currentVmergedUrbSIS_NorCP_Summer2018_STKHM_NEW_defaultPhys_300m
elif [[ "$HCLIMEXP" == NorCP_AROME_ERAI_ALADIN_1997_2017 ]]; then
    # NorCP AROME 3km
    HCLIMARCH=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/${HCLIMEXP}
    HCLIMNAME=${HCLIMEXP}
elif [[ "$HCLIMEXP" == HCLIM38_Summer2018_STKHM_DEFphys ]]; then
    # Case of default physiography, CentOS7
    HCLIMARCH=/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_DEFphys
    HCLIMNAME=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_DEFphys
elif [[ "$HCLIMEXP" == HCLIM38_Summer2018_STKHM_NEWphys ]]; then
    # Case of default physiography, CentOS7
    HCLIMARCH=/nobackup/rossby26/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/HCLIM38_SIM_2D/HCLIM38_Summer2018_STKHM_NEWphys
    HCLIMNAME=GrW_STHLM3.0_GreenWave_HCLIM38_CentOS7_NEWphys
fi

OUTF_NAME_TMP=HCLIM38_FORC_${SURFEXEXP}_TMP_${HCLIMDTG}.nc

# Variables
VAR_Z=orog #zs
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
    VAR_TAIR=ta${mlevel}
    VAR_QAIR=hus${mlevel}
fi
if [[ "$UREF" == *"screen"* ]]; then 
    VAR_UAS=uasm #uas
    VAR_VAS=vasm #vas
elif [[ "$UREF" == *"ml"* ]]; then 
    if [[ "${mlevel}" == "L"* ]]; then 
        VAR_UAS=uam${mlevel}
        VAR_VAS=vam${mlevel}
    elif [[ "${mlevel}" == *"m" ]]; then
        VAR_UAS=ua${mlevel}
        VAR_VAS=va${mlevel}
    fi
fi


# The nc file for each variable

# ZS: "Surface_Orography" ;
IN_NC_ZS=/nobackup/rossby24/users/sm_fuxwa/SURFEX_FORCING/HCLIM38_FORC/GreenWave/PGD_lfi.nc

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
elif [[ "$UREF" == *"ml"* ]] ; then 
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
elif [[ "$ZREF" == *"ml"* ]] ; then 
    cdo chname,${VAR_TAIR},air_temperature_ml,${VAR_QAIR},specific_humidity_ml ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_6.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_7.nc
fi
ncrename -v lat,latitude -v lon,longitude  ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_7.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_8.nc

# Create a new dimension 'hybrid1'
# https://stackoverflow.com/questions/34536742/define-a-new-dimension-to-one-of-the-variables-in-netcdf-file
# https://sourceforge.net/p/nco/discussion/9830/thread/cee4e1ad/
# Change here
#level_para=0.987867270000000
#ncap2 -s 'defdim("hybrid0",1);hybrid0[hybrid0]=0.987867270000000;hybrid0@standard_name="atmosphere_hybrid_sigma_pressure_coordinate";hybrid0@formula="p(n,k,j,i) = ap(k) + b(k)*ps(n,j,i)";hybrid0@formula_terms="ap: ap1 b: b1 ps: surface_air_pressure p0: p01";hybrid0@long_name="atmosphere_hybrid_sigma_pressure_coordinate";hybrid0@positive="down"' -O ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_8.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_9.nc

# Add this new dimension to variable: air_temperature_ml, specific_humidity_ml, x_wind_ml, y_wind_ml
#ncap2 -s 'air_temperature_ml[$time, $hybrid0, $y, $x]=air_temperature_ml' -s 'specific_humidity_ml[$time, $hybrid0, $y, $x]=specific_humidity_ml' -s 'x_wind_ml[$time, $hybrid0, $y, $x]=x_wind_ml' -s 'y_wind_ml[$time, $hybrid0, $y, $x]=y_wind_ml' ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_9.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_10.nc

#ncap2 -s 'defdim("time",1);time[time]=74875.0;time@long_name="Time"; etc.etc.etc.' -O ~/nco/data/in.nc ~/foo.nc
#ncap2 -s 'specific_humidity_ml[$time, $hybrid1, $y, $x]=specific_humidity_ml' -s 'x_wind_ml[$time, $hybrid1, $y, $x]=x_wind_ml' HCLIM38_FORC_GreenWave_ml55_SCA_VARY_2018070100_test1.nc  HCLIM38_FORC_GreenWave_ml55_SCA_VARY_2018070100_test2.nc

mv ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_8.nc ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}.nc

# remove temporary files
rm -f ${HCLIM_FORC_OUT}/${OUTF_NAME_STANDARD}_*.nc
rm -f ${HCLIM_FORC_OUT}/${OUTF_NAME_TMP}
rm -f ${HCLIM_FORC_OUT}/${VAR_SCA_SWDOWN}_fp_${HCLIMNAME}_${HCLIMDTG}.nc

# split the nc file (whole month) to each time step (1 hour)
#cdo splitsel,1 ${HCLIMARCH}/${HCLIMTIME}/${IN_NC_TAIR} ${HCLIM_FORC_OUT}
