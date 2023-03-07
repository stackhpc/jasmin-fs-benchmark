#!/usr/bin/env bash

#SBATCH --job-name=io500
#SBATCH --account=stackhpc
#SBATCH --partition=stackhpc
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --dependency=singleton
#SBATCH --time=2:0:0

set -euo pipefail

export IO500_CONTAINER_TAG="bb942db"

echo git describe: heads/main-0-gfd48d0d-dirty
echo SLURM_JOB_ID: $SLURM_JOB_ID
echo dimensions: '{"nodes": 2, "ntasks_per_node": 8, "filesystem": {"name": "pansas", "mountpoint": "/gws/pw/j07/perf_testing/stackhpc"}, "stonewall": 30, "iters": 2, "time": "2:0:0", "git_describe": "heads/main-0-gfd48d0d-dirty", "ior_api": "MPIIO"}'
echo SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST

mkdir -p /gws/pw/j07/perf_testing/stackhpc/steveb
module load eb/OpenMPI/gcc/4.0.0
timestamp=$(date +%Y.%m.%d-%H.%M.%S)
mpirun singularity exec --bind /gws/pw/j07/perf_testing/stackhpc:/gws/pw/j07/perf_testing/stackhpc docker://ghcr.io/stackhpc/io500-singularity:${IO500_CONTAINER_TAG} /io500 /home/users/steveb/io500-lotus/io500/runs/pansas-2-8-30-2-MPIIO/config.pansas-2-8-30-2-MPIIO.ini --timestamp $timestamp
