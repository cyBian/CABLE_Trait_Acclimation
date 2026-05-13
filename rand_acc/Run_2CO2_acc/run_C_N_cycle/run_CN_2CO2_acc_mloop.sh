#!/bin/bash
#PBS -l ncpus=8
#PBS -l mem=20gb
#PBS -l walltime=40:00:00
#module rm netcdf
#module add netcdf/4.2.1.1 openmpi/1.6.3
#export LD_LIBRARY_PATH=/home/Lei_lj/Softwares/netcdf-intel/lib:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/opt/starman_docs/starman_installs/icc_17.0.6/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/envs/envs_cable/softwares/netcdf_intel/lib:$LD_LIBRARY_PATH

ulimit -s unlimited

ROOT=/home/bian_cy/case_unc/rand_acc
WORKDIR=$ROOT/Run_2CO2_acc
DRIVER=$ROOT/CABLE2.0/offline/cable-mpi
OUTDIR=$WORKDIR/output/output_2xCO2
mkdir -p ${OUTDIR}

cd ${WORKDIR}/run_C_N_cycle

Startyr=1981
Endyr=2013

# for iteration times of mloops, added by Bian 18Apr2024 
mloop=300

original_dir=$(pwd)
echo "original running dir: ${original_dir}"

#echo copy restart file
# for the first 10 5-yr loops
cp -p ${WORKDIR}/restart/CABLE-restartfile/restart_out_CN_trendy_1_1981_run_CN_cycle.nc ./restart_in.nc # 2023-3-23

# Met data forcing
rm Trendy
ln -sf /home/bian_cy/force_cable/LLJ/ Trendy

# CABLE-AUX
rm CABLE-AUX
ln -sf ../CABLE-AUX CABLE-AUX

#################
i=201
while [ $i -le ${mloop} ]
do

  # use the same restart file for each loop (Bian, 18Apr2024)
  cp -p ${WORKDIR}/restart/CABLE-restartfile/restart_out_CN_trendy_1_1981_run_CN_cycle.nc ./restart_in.nc  
  
  # update nml for each loop (Bian,18Apr2024)
  rm nml
  cd ${WORKDIR}/nml_mloop/
  ./mknml_2CO2_acc.bash ${i}
  cd ${original_dir}
  ln -sf ../nml_mloop nml

  # generate the outdir for each loop (Bian,18Apr2024)
  OUTDIR_loop=${OUTDIR}/out_2CO2_acc_$i
  mkdir -p ${OUTDIR_loop}
  echo "OUTDIR_loop: ${OUTDIR_loop}"

  yr=${Startyr}
  while [ ${yr} -le ${Endyr} ]
  do
    cp -p nml/${yr}/cable_run.nml  ./cable.nml
    cp -p $DRIVER  ./cable-mpi-run
    
    /opt/envs/envs_cable/softwares/mpich_intel/bin/mpirun -np 16 ./cable-mpi-run
    mv out_cable.nc      ${OUTDIR_loop}/out_cable_${i}_${yr}_2xCO2_acc.nc
    cp -p restart_out.nc restart_in.nc
    mv restart_out.nc    ${OUTDIR_loop}/restart_out_${i}_${yr}_2xCO2_acc.nc

    echo "For year ${yr}"
    yr=`expr $yr + 1`
  done
  echo "For mloop $i"
  i=`expr $i + 1`
done
###############
