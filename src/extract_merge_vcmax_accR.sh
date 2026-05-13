#!/bin/bash

# This script used to extract vcmax,ejmax and merge them to analysis
# Author: Chenyu Bian
# Data: July 31,2024

# for 2xCO2
DaPath=/home/bian_cy/case_unc/rand_acc_cov/Run_2CO2_acc/output/output_2xCO2
OutPath=${DaPath}/out_proc/vcmax

cd ${DaPath}

# Define the range of years
start_year=1981
end_year=2013

# Define the number of loops (200 loops)
num_loops=200

# Process each loop
for loop in $(seq 1 $num_loops); do
    echo "Processing loop $loop"

    # Create an array to store time files for the current loop
    time_files=()

    # Template for the input files
    input_template="out_cable_${loop}_%d_2xCO2_acc_cov.nc"
    cd ${DaPath}/out_2CO2_acc_cov_${loop}/

    # Templates for temporary file names
    temp_file_template="temp_%d.nc"
    time_file_template="%d_time.nc"

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

    # Merge all files for the current loop across all years
    merged_output_file=${OutPath}/out_${loop}_vcmax_ejmax_1981-2013_acc_cov.nc
    cdo mergetime ${time_files[@]} $merged_output_file

    # Clean up intermediate files (optional)
    for time_file in "${time_files[@]}"; do
        rm $time_file
    done
done
