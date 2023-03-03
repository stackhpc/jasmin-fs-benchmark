#!/usr/bin/env bash

#SBATCH --job-name=io500
#SBATCH --account=stackhpc
#SBATCH --partition=stackhpc
#SBATCH --nodes=10
#SBATCH --ntasks-per-node=8
#SBATCH --dependency=singleton
#SBATCH --time=2:0:0

set -euo pipefail

export IO500_CONTAINER_TAG="bb942db"

echo git describe: heads/main-0-gcbf28c2-dirty
echo SLURM_JOB_ID: $SLURM_JOB_ID
echo dimensions: '{"nodes": 10, "ntasks_per_node": 8, "filesystem": {"name": "pure", "mountpoint": "/work/stackhpc-pure/"}, "stonewall": 300, "iters": 1, "time": "2:0:0", "git_describe": "heads/main-0-gcbf28c2-dirty", "ior_api": "POSIX"}'
echo SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST

mkdir -p /work/stackhpc-pure/steveb
module load eb/OpenMPI/gcc/4.0.0
timestamp=$(date +%Y.%m.%d-%H.%M.%S)
mpirun singularity exec --bind /work/stackhpc-pure/:/work/stackhpc-pure/ docker://ghcr.io/stackhpc/io500-singularity:${IO500_CONTAINER_TAG} /io500 /home/users/steveb/io500-lotus/io500/runs/pure-10-8-300-1-POSIX/config.pure-10-8-300-1-POSIX.ini --timestamp $timestamp
