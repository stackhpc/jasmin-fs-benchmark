#!/usr/bin/env bash

#SBATCH --account=stackhpc
#SBATCH --partition=stackhpc
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --dependency=singleton
#SBATCH --time=00:30:00

set -euo pipefail

export IO500_CONTAINER_TAG="59e2967" # has mpitests in it

echo SLURM_JOB_ID: $SLURM_JOB_ID
echo SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST

module load eb/OpenMPI/gcc/4.0.0
timestamp=$(date +%Y.%m.%d-%H.%M.%S)
mpirun singularity exec docker://ghcr.io/stackhpc/io500-singularity:${IO500_CONTAINER_TAG} mpitests-IMB-MPI1 pingpong
