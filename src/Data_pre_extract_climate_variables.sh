#!/bin/bash

# This script used to merge all the output files and extract the target variables used to analysis
# Author: Chenyu Bian
# Data: May21,2024

# Define data paths
DaPath1=/home/bian_cy/case_unc/rand_acc_cov/Run_2CO2_acc/output/output_2xCO2
DaPath2=/home/bian_cy/case_unc/rand_acc/Run_2CO2_acc/output/output_2xCO2

# Create directory used to store processed files
mkdir -p ${DaPath1}/out_proc
mkdir -p ${DaPath2}/out_proc

#cd ${DaPath}

# for iteration times of mloops
mloop=200
iloop=1

seq ${iloop} ${mloop} | parallel -j16 "
   cd ${DaPath1}/out_2CO2_acc_cov_{}/
   
   ncrcat -O out_cable_* out_cable_{}_1981-2013_2xCO2_acc_cols
   
   ncks -O -v Rnet,Qair,Wind,PSurf,SoilMoist,SoilTemp,latitude,longitude out_cable_{}_1981-2013_2xCO2_acc_cov.nc \
   ${DaPath1}/out_proc/out_climates_{}_1981-2013_2xCO2_acc_cov.nc
   
   rm out_cable_{}_1981-2013_2xCO2_acc_cov.nc
   cd ${DaPath1}

   cd ${DaPath2}/out_2CO2_acc_{}/
   
   ncrcat -O out_cable_* out_cable_{}_1981-2013_2xCO2_acc.nc
   
   ncks -O -v Rnet,Qair,Wind,PSurf,SoilMoist,SoilTemp,latitude,longitude out_cable_{}_1981-2013_2xCO2_acc.nc \
   ${DaPath2}/out_proc/out_climates_{}_1981-2013_2xCO2_acc.nc
   
   rm out_cable_{}_1981-2013_2xCO2_acc.nc
   cd ${DaPath2}

   echo 'For mloop {}'
"


