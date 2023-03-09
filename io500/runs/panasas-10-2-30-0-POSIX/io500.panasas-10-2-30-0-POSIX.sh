#!/usr/bin/env bash

#SBATCH --job-name=panasas
#SBATCH --account=stackhpc
#SBATCH --partition=stackhpc
#SBATCH --nodes=10
#SBATCH --ntasks-per-node=2
#SBATCH --dependency=singleton
#SBATCH --time=4:0:0
#SBATCH --begin=18:00
set -euo pipefail

export IO500_CONTAINER_TAG="bb942db"


echo SLURM_JOB_ID: $SLURM_JOB_ID
echo dimensions: '{"nodes": 10, "ntasks_per_node": 2, "filesystem": {"name": "panasas", "mountpoint": "/gws/pw/j07/perf_testing3"}, "stonewall": 30, "iters": 0, "time": "4:0:0", "git_describe": "heads/main-0-g1f83e4c-dirty", "ior_api": "POSIX"}'
echo SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST

mkdir -p /gws/pw/j07/perf_testing3/steveb
module load eb/OpenMPI/gcc/4.0.0
timestamp=$(date +%Y.%m.%d-%H.%M.%S)
mpirun singularity exec --bind /gws/pw/j07/perf_testing3:/gws/pw/j07/perf_testing3 docker://ghcr.io/stackhpc/io500-singularity:${IO500_CONTAINER_TAG} /io500 /home/users/steveb/io500-lotus/io500/runs/panasas-10-2-30-0-POSIX/config.panasas-10-2-30-0-POSIX.ini --timestamp $timestamp
