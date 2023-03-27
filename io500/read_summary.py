""" WIP result summarising for IO500

    Usage:
        python3 read_summary.py 'runs/*/result_summary.txt'

    NB: the quotes are important to avoid shell globbing.
"""

import sys, json, pprint, glob, os, json
import pandas

def read_io500_summary(path):
    """ Read a result_summary.txt file and return a dict.
    
        Returns a dict with keys test name (or 'score-*') and value a tuple of (number, str unit).
    """

    data = {}
    with open(path) as f:
        for line in f:
            if line.startswith('[RESULT]'):
            #   [RESULT]       ior-easy-write        0.764612 GiB/s : time 34.035 seconds [INVALID]
                result = line.split()
                testname, value, unit, seconds = result[1], result[2], result[3], result[6]
                data[testname] = (float(value), unit)
            if line.startswith('[SCORE ]'):
            #   [SCORE ] Bandwidth 0.585873 GiB/s    : IOPS 4.148649 kiops     : TOTAL 1.559032 [INVALID]
                score = line.split()
                bw, bw_unit, iops, iops_unit, total = score[3], score[4], score[7], score[8], score[11]
                data['bandwidth-score'] = (float(bw), bw_unit)
                data['iops-score'] = (float(iops), iops_unit)
                data['total-score'] = (float(total), None)
    # print(data)
    return data

def transpose(rows):
    return [list(cols) for cols in zip(*rows)]

def tabulate(rows):
    # from https://stackoverflow.com/a/12065663/916373
    widths = [max(map(len, col)) for col in zip(*rows)]
    for row in rows:
        print("  ".join((val.ljust(width) for val, width in zip(row, widths))))

def load_run_dimensions(dir_path):
    """ Load a dimensions.*.json file from a specified directory.

        Returns a dict in same format as read_io500_summary() - nested dicts are transformed to flattened
        dotted keys.
    """
    
    dim_paths = glob.glob(os.path.join(dir_path, 'dimensions.*.json'))
    if len(dim_paths) != 1:
        raise ValueError('Found %i dimension files in %s, expected 1' % (len(dim_paths), dir_path))
    dims = {}
    with open(dim_paths[0]) as f:
        data = json.load(f)
    for k, v in data.items():
        if isinstance(v, dict):
            for subkey, subvalue in v.items():
                dims['%s.%s' % (k, subkey)] = (subvalue, None)
        else:
            dims[k] = (v, None)
    return dims

def df_from_summary(path):
    """ Return (df, units) from a path to a result_summary.txt file, where ...
            df: dataframe with values
            units: dict with keys = df.columns and values = str giving column unit.
    """
    outputs = read_io500_summary(path)
    colnames = list(outputs.keys())
    unitnames = [v[1] for v in results.values()]
    rows.append([v[0] for v in results.values()])
    run_df = pandas.DataFrame(data=rows, columns=colnames)
    run_units = dict(zip(colnames, unitnames))
    return run_df, run_units

def df_from_pattern(pattern):
    """ Returns (DataFrame, units) where units is a dict of strs keyed by DataFrame.column """
    # NB: assumes each file found has the same columns!
    
    df = None
    units = {}
    for path in glob.glob(pattern):
        # print('loading %s' % path)
        rows = []
        run_dir = os.path.dirname(path)
        results = load_run_dimensions(run_dir)
        outputs = read_io500_summary(path)
        results.update(outputs)
        colnames = list(results.keys())
        unitnames = [v[1] for v in results.values()]
        rows.append([v[0] for v in results.values()])
        run_df = pandas.DataFrame(data=rows, columns=colnames)
        run_units = dict(zip(colnames, unitnames))
        if df is None:
            df = run_df
        else:
            df = pandas.concat([df, run_df], ignore_index=True)
        units.update(run_units)
    return (df, units)

def summarise(pattern):

    rows = []
    for path in glob.glob(pattern):
        # print('path:', path)
        run_dir = os.path.dirname(path)
        dims = load_run_dimensions(run_dir)
        outputs = read_io500_summary(path)
        results = dims
        results.update(outputs)
        header1 = list(results.keys())
        header2 = [v[1] for v in results.values()]
        if not rows:
            rows.extend([header1, header2])
        
        # have to convert back to strings!
        values = [str(v[0]) for v in results.values()]
        rows.append(values)

    tabulate(rows)
    # cols = transpose(rows)
    # tabulate(cols)

if __name__ == '__main__':
    summarise(sys.argv[1])
