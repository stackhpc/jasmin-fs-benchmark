
# Install

```
python3.6 -m venv venv
. venv/bin/activate
pip install -U pip
pip install -r requirements.txt
ansible-galaxy role install -fr requirements.yml -p ansible/roles
```

# Run

```
. venv/bin/activate # if not already
# template and submit runs
ansible-playbook run.yml

# once finished, postprocess:
python3 read_summary.py 'runs/*/result_summary.txt' > table.txt
```

# IO500

Everything goes to `runs/`, looks something like:
```
runs
├── pansas
│   ├── config.ini
│   ├── config-orig.ini
│   ├── config.pansas-1-2.ini # <- i500 file written by smatrix
│   ├── dimensions.pansas-1-2.json <- smatrix item file
│   ├── io500.pansas-1-2.sh <- smatrix sbatch script
│   ├── ior-easy-write.csv
│   ├── ior-easy-write.txt
│   ├── result_summary.txt <- summary of interest
│   └── result.txt
```
