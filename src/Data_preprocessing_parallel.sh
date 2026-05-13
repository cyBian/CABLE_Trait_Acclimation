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
mloop=200
iloop=21

seq ${iloop} ${mloop} | parallel -j8 "
   cd ${DaPath}/out_2CO2_acc_{}/
   
   ncrcat -O out_cable_* out_cable_{}_1981-2013_2xCO2_acc.nc
   
   ncks -O -v GPP,NPP,LAI,NEE,RadT,Rainf,Tair,latitude,longitude out_cable_{}_1981-2013_2xCO2_acc.nc \
   ${DaPath}/out_proc/out_cable_{}_1981-2013_2xCO2_acc_tarVars.nc
   
   rm out_cable_{}_1981-2013_2xCO2_acc.nc
   cd ${DaPath}
   
   echo 'For mloop {}'
"


