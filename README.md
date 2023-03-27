
# Overview 

This repo, developed by [StackHPC](https://www.stackhpc.com) on behalf of the [JASMIN](https://jasmin.ac.uk) data analysis facility, provides a complete set of tools for performance benchmarking of HPC file systems and object storage services. The tooling is built atop a well-established software stack of [Slurm](https://slurm.schedmd.com), [Ansible](https://docs.ansible.com/ansible_community.html) and [Apptainer](https://github.com/apptainer/apptainer) (or Singularity).

The general structure of the tooling is as follows:
- Container images for the file system benchmarking tool (IO500) and object storage benchmarking tool ([MinIO/warp](https://github.com/minio/warp)) are built and hosted [here](https://github.com/stackhpc/io500-singularity) and [here](https://github.com/stackhpc/S3-warp-singularity)
- A custom ansible role ([smatrix](https://github.com/stackhpc/smatrix)) is used to generate templated slurm job scripts by iterating over lists of benchmark run parameters
- Example config files and job templates for the smatrix role are provided in this repo alongside jupyter notebooks and other python code for post-processing and analysis of benchmark results

# Installation

All benchmarks require an existing Slurm cluster with Singularity installed (or Apptainer aliased to `singularity`), plus access to the file systems and object stores to be benchmarked.

First, clone this repo to the cluster's login node, then run the following to install the required dependencies:

```
cd jasmin-fs-benchmark
python3.6 -m venv venv
. venv/bin/activate
pip install -U pip
pip install -r requirements.txt
ansible-galaxy role install -fr requirements.yml -p ansible/roles
```

# IO500

To run the IO500 benchmarks against a set of file systems, configure the relevant file system mount points and other IO500 run parameters in `io500/run.yml` then:

```
# from repo root:
. venv/bin/activate # if not already
# template and submit runs
ansible-playbook io500/run.yml

# once finished, postprocess:
python3 io500/read_summary.py 'io500/runs/*/result_summary.txt' > io500/all_summary.txt
```

A more interactive analysis with code for producing relevant summary plots can be found in `io500/Results-processing.ipynb`.

**Notes**:

- `sbatch` output goes to `io500/slurm-<jobid>*.out` (NB: From Slurm's point of view, the submission directory is the playbook directory, which is perhaps unexpected)
- Everything else (templates, outputs) goes to `/runs/<filesystem_name>/`. Probably this needs changing to add parameterisation into that subdirectory name.
- For summary of summary results, see `io500/table.txt`


# Object Storage

Configure the desired run parameters in `s3-warp/run-single-thread.yml` or `s3-warp/run-multi-thread.yml` then

```
# from repo root:
. venv/bin/activate # if not already
# template and submit runs
ansible-playbook s3-warp/run-single-thread.yml
# and / or
ansible-playbook s3-warp/run-multi-thread.yml
```

This will create 5 different output files per job (i.e. combination of benchmark parameters) in the `s3-warp/` directory:
- `slurm-<jobid>*.out` contains the stdout/stderr from the Slurm job
- `benchmark-runs/s3.<vendor>-<request-type>-<nodes>-<threads>-<obj_size>-<num_objs>-<other_params...>.sh` is the ansible-templated Slurm job script
- `benchmark-runs/s3-full.<...run_parameters_as_above...>.csv.zst` is the full results file from the warp benchmarking tool, containing stats for each API request made during the run
- `benchmark-runs/s3-summary.<...run_parameters_as_above...>.csv` is the summary csv output from the `warp analyze` command which is run after each run has completed
- `benchmark-runs/s3-summary.<...run_parameters_as_above...>.txt` is a convenient summary of the benchmarking scores

**Notes**:

- Access credentials for each object store are configured via the `creds` variable in each `run-*.yml` file, which should be an ansible lookup pointing to a file containing the relevant credentials. For example, to configure the benchmarking process to run against a storage system which we want to nickname `storage1`, the credentials file should contain
    ```
    STORAGE1_ENDPOINT=<url-without-'http(s)://'-prefix>
    STORAGE1_ACCESS_KEY=<access-key>
    STORAGE1_SECRET_KEY=<secret-key>
    ```
    and the `smatrix_dimensions.storage` parameter in `run-*.yml` should contain `["storage1"]`.

- If the `max_storage_capacity` parameter in `run-*.yml` is set correctly, the benchmarking process will pre-check that none of the proposed benchmark runs will breach the specified object store capacity (via the `sanity-checks.yml` playbook).

- The config for single-thread & multi-thread benchmarks is currently split into separate files (`run-{single,multi}-thread.yml`) due to the way in which warp's results analysis procedure works. Specifically, as explained in more detail in the [warp docs](https://github.com/minio/warp#analysis-data), the analysis process purposefully excludes any 'warm-up' or 'cool-down' sections of benchmark window. It does this by *only* using requests which start *after all threads have completed at least 1 full request* and also ignores requests which occur after any single thread has started it's final request of the benchmark run. This means that the benchmarks must be run for long enough that all threads complete at least a handful of requests (be preferably many more); however, since the `put` request benchmarks are based on a object count & size (rather than wall time), uploading the same number of (potentially large) objects for a single-threaded job as for a job running hundreds of parallel tasks is infeasible. Therefore, we provide sensible default parameters for small thread counts (i.e. fewer total objects to upload for `put` benchmarks and lower wall clock time for `get` benchmarks) in `run-single-thread.yml` and alternatives for highly-parallelised benchmarks in `run-multi-threaded.yml`.

- The `warp` container image (hosted [here](https://github.com/stackhpc/S3-warp-singularity) and built via apptainer/singularity as part of the slurm job script) is based on StackHPC's fork of warp which disables the `x-amz-bypass-governance-retention:true` header in the object storage API calls due to anecdotal evidence of certain S3 implementations not handling this header correctly which would result in failures when trying to delete test objects after a completed benchmark run.