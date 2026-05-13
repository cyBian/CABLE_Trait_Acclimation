#!/bin/bash

# This script used to merge all the output files and extract the target variables used to analysis
# Author: Chenyu Bian
# Data: May21,2024

# Define data paths
DaPath=/home/bian_cy/case_unc/rand_acc/Run_2CO2_acc/output/output_2xCO2

# Create directory used to store processed files
mkdir -p ${DaPath}/out_proc

cd ${DaPath}

# for iteration times of mloops
mloop=10
iloop=3

while [ $iloop -le ${mloop} ]
do
  (
    cd ${DaPath}/out_2CO2_acc_${iloop}/

    ncrcat -O out_cable_${iloop}_* out_cable_${iloop}_1981-2013_2xCO2_acc.nc

    ncks -O -v GPP,NPP,LAI,NEE,RadT,Rainf,Tair,latitude,longitude out_cable_${iloop}_1981-2013_2xCO2_acc.nc \
    ${DaPath}/out_proc/out_cable_${iloop}_1981-2013_2xCO2_acc_tarVars.nc

    rm out_cable_${iloop}_1981-2013_2xCO2_acc.nc
    cd ${DaPath}

    echo "For mloop ${iloop}"

  ) &
    iloop=`expr $iloop + 1`
done

wait 


