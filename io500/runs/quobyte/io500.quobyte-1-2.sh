#!/usr/bin/env bash

#SBATCH --job-name=io500
#SBATCH --account=stackhpc
#SBATCH --partition=stackhpc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --dependency=singleton
#SBATCH --time=2:0:0

set -euo pipefail

export IO500_CONTAINER_TAG="bb942db"

echo git describe: heads/main-0-g2162fa3-dirty
echo SLURM_JOB_ID: $SLURM_JOB_ID
echo dimensions: '{"template_file": "io500.sh.j2", "nodes": 1, "ntasks_per_node": 2, "filesystem": {"name": "quobyte", "mountpoint": "/work/scratch-nopw/"}, "stonewall": 30, "time": "2:0:0"}'
echo SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST

mkdir -p /work/scratch-nopw/steveb
module load eb/OpenMPI/gcc/4.0.0
timestamp=$(date +%Y.%m.%d-%H.%M.%S)
mpirun singularity exec --bind /work/scratch-nopw/:/work/scratch-nopw/ docker://ghcr.io/stackhpc/io500-singularity:${IO500_CONTAINER_TAG} /io500 /home/users/steveb/io500-lotus/io500/runs/quobyte/config.quobyte-1-2.ini --timestamp $timestamp
