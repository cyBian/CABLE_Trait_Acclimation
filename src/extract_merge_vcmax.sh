#!/bin/bash

# This script used to extract vcmax,ejmax and merge them to analysis
# Author: Chenyu Bian
# Data: July 31,2024

# Define data paths

# for 1xCO2
# DaPath=/home/bian_cy/case_unc/control/Run_1CO2_CK/output/output_1xCO2
# OutPath=/home/bian_cy/case_unc/control/Run_1CO2_CK/output

# # Template for the input files
# input_template="out_cable_1_%d_1CO2_CK_CN.nc"

# # Merge all files across all years
# merged_output_file=${OutPath}/out_cable_vcmax_ejmax_1981-2013_1xCO2.nc

# for 2xCO2
DaPath=/home/bian_cy/case_unc/control/Run_2CO2_CK/output/output_2xCO2
OutPath=/home/bian_cy/case_unc/control/Run_2CO2_CK/output

# Template for the input files
input_template="out_cable_1_%d_2xCO2_CK_CN.nc"

# Merge all files across all years
merged_output_file=${OutPath}/out_cable_vcmax_ejmax_1981-2013_2xCO2.nc

cd ${DaPath}

# Define the names of the variables to extract
variable_names=("vcmax" "ejmax")

# Define the range of years
start_year=1981
end_year=2013

# Templates for temporary file names
temp_file_template="temp_%d.nc"
time_file_template="%d_time.nc"

# List of merged temporary files
time_files=()

# Extract data for each variable and save it into separate files for each year
for year in $(seq $start_year $end_year); do
    input_file=$(printf "$input_template" $year)
    temp_file=$(printf "$temp_file_template" $year)
    time_file=$(printf "$time_file_template" $year)
    time_files+=($time_file)

    # Extract the specified variables data for the given year
    cdo selname,vcmax,ejmax $input_file $temp_file

    # Add a time axis
    cdo settaxis,$year-01-01,0:00:00,1year $temp_file $time_file

    # Remove the temporary file
    rm $temp_file
done

cdo mergetime ${time_files[@]} $merged_output_file

# Print information about the final merged file (optional)
#echo "Information for $merged_output_file:"
#cdo info $merged_output_file

# Clean up intermediate files (optional)
for time_file in "${time_files[@]}"; do
    rm $time_file
done
