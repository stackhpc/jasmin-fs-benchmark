#!/usr/bin/env bash

#SBATCH --job-name=quobyte
#SBATCH --output="/home/users/steveb/io500-lotus/io500/runs/quobyte-1-48-300-1-POSIX/slurm-%j.out"
#SBATCH --account=stackhpc
#SBATCH --partition=stackhpc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
#SBATCH --dependency=singleton
#SBATCH --time=4:0:0

set -euo pipefail

export IO500_CONTAINER_TAG="bb942db"


echo SLURM_JOB_ID: $SLURM_JOB_ID
echo dimensions: '{"nodes": 1, "ntasks_per_node": 48, "filesystem": {"name": "quobyte", "mountpoint": "/gws/nopw/j04/perf_testing3/stackhpc"}, "stonewall": 300, "iters": 1, "time": "4:0:0", "ior_api": "POSIX"}'
echo SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST

mkdir -p /gws/nopw/j04/perf_testing3/stackhpc/steveb
module load eb/OpenMPI/gcc/4.0.0
timestamp=$(date +%Y.%m.%d-%H.%M.%S)
mpirun singularity exec --bind /gws/nopw/j04/perf_testing3/stackhpc:/gws/nopw/j04/perf_testing3/stackhpc docker://ghcr.io/stackhpc/io500-singularity:${IO500_CONTAINER_TAG} /io500 /home/users/steveb/io500-lotus/io500/runs/quobyte-1-48-300-1-POSIX/config.quobyte-1-48-300-1-POSIX.ini --timestamp $timestamp
