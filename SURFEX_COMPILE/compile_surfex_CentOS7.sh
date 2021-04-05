#!/bin/bash

export OMP_NUM_THREADS=1
module load buildenv-intel/2018a-eb
module load netCDF/4.4.1.1-HDF5-1.8.19-nsc1-intel-2018a-eb
module load grib_api/1.24.0-nsc1-intel-2018a-eb


curdir=$PWD

#export ARCH=${ARCH=LXgfortran}
export ARCH=${ARCH=LXifort}

#export VER_MPI=${VER_MPI=NOMPI}
export VER_MPI=${VER_MPI=MPIAUTO}

#export OPTLEVEL=${OPTLEVEL=DEBUG}
export OPTLEVEL=${OPTLEVEL=O2}

#export VER_USER=${VER_USER=""}
#export VER_USER=${VER_USER="ASSIM_Sodankyla"}
#export VER_USER=${VER_USER="FORC"}
export VER_USER=${VER_USER="MYSRC_ncode_r18798_bugcorr_utci_test_20210324"}
#export VER_USER=${VER_USER="MYSRCPIXEL"}


export VER_OASIS=mct

#For bi@NSC (SMHI) use already installed netcdf and grib_api
export VER_CDF=CDFBINSC
export VER_GRIBAPI=GRIBAPIBINSC

export XYZ=""
source configure
export SRC_SURFEX=""

rm -fr dir_obj-${ARCH}-SFX-V7-3-0-${VER_MPI}-${OPTLEVEL}/${VER_USER}

cd $curdir
source ../conf/profile_surfex-${XYZ}

cd $curdir

if [[ $VER_USER = "" ]]; then
  make
  make installmaster
else
  make user
  make installuser
fi

exit
