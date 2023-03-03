#!/usr/bin/bash
#SBATCH --job-name=s3-warp-pure
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --dependency=singleton
#SBATCH --partition=stackhpc
#SBATCH --account=stackhpc

# Check required env vars are set 
if [[ -z $WARP_HOST || -z $WARP_ACCESS_KEY || -z $WARP_SECRET_KEY ]]; then
    echo "The environment variables WARP_HOST, WARP_ACCESS_KEY and WARP_SECRET_KEY must be set."
    exit 1
fi

# Print a message about the git status of the checked out repo version
echo "Git repo local checkout status: heads/warp-s3-0-gf1be256-dirty"

# Pull in docker image and build singularity image from it
CONTAINER_FILENAME=warp.sif
if [[ ! -f $CONTAINER_FILENAME ]]; then
    singularity build $CONTAINER_FILENAME docker://ghcr.io/stackhpc/s3-warp-singularity:latest
fi

# Start a warp client on each job node
srun --spread-job singularity run warp.sif client --no-color &

#Unpack list of nodes which have a warp client running
CLIENT_NODES=$(scontrol show hostname $SLURM_JOB_NODELIST | paste -d, -s)
echo Client nodes: $CLIENT_NODES

# Trigger benchmark run on all clients
OUTPUT_FILE=./benchmark-runs/warp-results-full.mixed-1-1-1000-1KiB-5GiB-30m
singularity run warp.sif mixed \
    --concurrent 1 \
    --objects 1000 \
    --obj.size "1KiB,5GiB" \
    --obj.randsize \
    --benchdata $OUTPUT_FILE \
    --no-color \
    --duration 30m \
    --warp-client $CLIENT_NODES \

# Run warp analysis tool on output file
SUMMARY_FILE=./benchmark-runs/warp-results-summary.mixed-1-1-1000-1KiB-5GiB-30m
singularity run warp.sif analyze $OUTPUT_FILE.csv.zst --analyze.out $SUMMARY_FILE.csv > $SUMMARY_FILE.txt
