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

ROOT=/home/bian_cy/CABLE_trait
WORKDIR=$ROOT/Run_CK_CN/
DRIVER=$ROOT/CABLE2.0/offline/cable-mpi
OUTDIR=$WORKDIR/output/output_CK_CN
mkdir -p ${OUTDIR}

cd ${WORKDIR}/run_C_N_cycle

Startyr=1981
Endyr=2013

#echo copy restart file
# for the first 10 5-yr loops
#cp -p ${WORKDIR}/output/output_initcasa/restart_out_trendy_1_1901_init.nc ./restart_in.nc
#cp -p ${WORKDIR}/restart/restart_out_trendy_300_1901_spingpp_CNP.nc  ./restart_in.nc
#cp -p ${WORKDIR}/restart/restart_out_trendy_1_1980_run_C_N_cycle.nc ./restart_in.nc
#cp -p ${WORKDIR}/restart/CABLE-restartfile/restart_out_C_spinup_wei_1901_run_C_N_cycle.nc ./restart_in.nc #added 6/22 
#cp -p ${WORKDIR}/restart/restart_out_trendy_1_1981_run_C_cycle.nc ./restart_in.nc   #added 6/23 by Bian
#cp -p ${WORKDIR}/restart/restart_out_trendy_1_1981_run_C_N_cycle.nc ./restart_in.nc #added 13 Nov,2019 by cybian from Ning
 cp -p ${WORKDIR}/restart/CABLE-restartfile/restart_out_CN_trendy_1_1981_run_CN_cycle.nc ./restart_in.nc # 2023-3-23

# Met data forcing
rm Trendy
ln -sf /home/bian_cy/force_cable/LLJ/ Trendy

# cable.nml
rm nml
ln -sf ../nml_C_N_cycle nml

# CABLE-AUX
rm CABLE-AUX
ln -sf ../CABLE-AUX CABLE-AUX
#################
i=1
while [ $i -le 1 ]
do
  yr=${Startyr}
  while [ ${yr} -le ${Endyr} ]
  do
    cp -p nml/${yr}/cable_run.nml  ./cable.nml
    cp -p $DRIVER  ./cable-mpi-run
    #mpirun  -np 2 ./cable-mpi-run
    /opt/envs/envs_cable/softwares/mpich_intel/bin/mpirun -np 16 ./cable-mpi-run
    mv out_cable.nc      ${OUTDIR}/out_cable_trendy_${i}_${yr}_run_CK_CN.nc
    cp -p restart_out.nc restart_in.nc
    mv restart_out.nc    ${OUTDIR}/restart_out_trendy_${i}_${yr}_run_CK_CN.nc
    echo "For year ${yr}"
    yr=`expr $yr + 1`
  done
  i=`expr $i + 1`
done
###############
