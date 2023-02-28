
# Install

```
python3.6 -m venv venv
. venv/bin/activate
pip install -U pip
pip install -r requirements.txt
ansible-galaxy role install -fr requirements.yml -p ansible/roles
```

# IO500


```
# from repo root:
. venv/bin/activate # if not already
# template and submit runs
ansible-playbook io500/run.yml

# once finished, postprocess:
python3 io500/read_summary.py 'io500/runs/*/result_summary.txt' > io500/table.txt
```

- `sbatch` output goes to `io500/slurm-<jobid>*.out` (NB: From Slurm's point of view, the submission directory is the playbook directory, which is perhaps unexpected)
- Everything else (templates, outputs) goes to `/runs/<filesystem_name>/`. Probably this needs changing to add parameterisation into that subdirectory name.
- For summary of summary results, see `io500/table.txt`
