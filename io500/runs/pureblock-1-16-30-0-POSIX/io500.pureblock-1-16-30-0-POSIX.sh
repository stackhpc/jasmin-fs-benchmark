#!/usr/bin/env bash

#SBATCH --job-name=pureblock
#SBATCH --output="/home/azimuth/jasmin-fs-benchmark/io500/runs/pureblock-1-16-30-0-POSIX/slurm-%j.out"
#SBATCH --account=stackhpc
#SBATCH --partition=compute
# only mounted on this:
#SBATCH -w fs-perf-dev-compute-0
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --dependency=singleton
#SBATCH --time=4:0:0

set -euo pipefail

export IO500_CONTAINER_TAG="bb942db"


echo SLURM_JOB_ID: $SLURM_JOB_ID
echo dimensions: '{"nodes": 1, "ntasks_per_node": 16, "filesystem": {"name": "pureblock", "mountpoint": "/data"}, "stonewall": 30, "iters": 0, "time": "4:0:0", "ior_api": "POSIX"}'
echo SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST

mkdir -p /data/azimuth
module load gnu12 openmpi4
timestamp=$(date +%Y.%m.%d-%H.%M.%S)
mpirun singularity exec --bind /data:/data docker://ghcr.io/stackhpc/io500-singularity:${IO500_CONTAINER_TAG} /io500 /home/azimuth/jasmin-fs-benchmark/io500/runs/pureblock-1-16-30-0-POSIX/config.pureblock-1-16-30-0-POSIX.ini --timestamp $timestamp
