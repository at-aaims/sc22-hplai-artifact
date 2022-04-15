#!/bin/bash
#SBATCH -A stf018
#SBATCH -J hplai
#SBATCH -p batch
#SBATCH -N 128
#SBATCH -t 1:00:00
#SBATCH -o crusher_example_32x32.out

module load PrgEnv-cray/8.2.0
module load rocm/4.5.2
module load cray-mpich/8.1.12
module load cray-libsci/21.08.1.2
module load craype-x86-trento
module load craype-network-ofi
module load craype-accel-host

export LD_LIBRARY_PATH=/opt/rocm-4.5.2/llvm/lib:${LD_LIBRARY_PATH}
export OMP_NUM_THREADS=8
export MPIR_CVAR_GPU_EAGER_DEVICE_MEM=0
export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_SMP_SINGLE_COPY_MODE=CMA

echo "JobID          : $SLURM_JOB_ID"
echo "Number of Nodes: $SLURM_JOB_NUM_NODES"

export NOTE="HPL-AI 32x32 with rocm 4.5.2"

export CMD="srun -N 128 -n 1024 -c 8 --unbuffered --ntasks-per-node=8 --gpus-per-task=1 --gpu-bind=closest  ../build/driver.x86_64.rocm4.5.2 3833856 3072 32 -log 1 -comm 4 -gdirect --numa 0 -sys \"Crusher\""

$CMD
