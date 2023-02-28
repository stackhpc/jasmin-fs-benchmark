""" WIP result summarising for IO500

    Usage:
        python3 read_summary.py 'runs/*/result_summary.txt'

    NB: the quotes are important to avoid shell globbing.
"""

import sys, json, pprint, glob, os, json


def read_io500_summary(path):
    """ Read a result_summary.txt file and return a dict.
    
        For dict format see below.
    """

    data = {}
    with open(path) as f:
        for line in f:
            if line.startswith('[RESULT]'):
            #   [RESULT]       ior-easy-write        0.764612 GiB/s : time 34.035 seconds [INVALID]
                result = line.split()
                testname, value, unit, seconds = result[1], result[2], result[3], result[6]
                data[testname] = {
                    'value': float(value),
                    'unit': unit,
                    'seconds': float(seconds),
                }
            if line.startswith('[SCORE ]'):
            #   [SCORE ] Bandwidth 0.585873 GiB/s    : IOPS 4.148649 kiops     : TOTAL 1.559032 [INVALID]
                score = line.split()
                bw, bw_unit, iops, iops_unit, total = score[3], score[4], score[7], score[8], score[11]
                data['bandwidth-score'] = {
                    'value': float(bw),
                    'unit': bw_unit,
                }
                data['iops-score'] = {
                    'value': float(iops),
                    'unit': iops_unit,
                }
                data['total-score'] = {
                    'value': float(total),
                    'unit': '-',
                }

    return data

def transpose(rows):
    return [list(cols) for cols in zip(*rows)]

def tabulate(rows):
    # from https://stackoverflow.com/a/12065663/916373
    widths = [max(map(len, col)) for col in zip(*rows)]
    for row in rows:
        print("  ".join((val.ljust(width) for val, width in zip(row, widths))))

def summarise(pattern):

    rows = []
    for path in glob.glob(pattern):
        run_dir = os.path.dirname(path)
        results = read_io500_summary(path)
        
        header1 = ['run_dir', 'mountpoint'] + list(results.keys())
        header2 = ['-', '-'] + [v['unit'] for v in results.values()]
        if not rows:
            rows.extend([header1, header2])

        # have to convert back to strings!
        values = [run_dir, mountpoint] + [str(v['value']) for v in results.values()]
        rows.append(values)

    cols = transpose(rows)
    tabulate(cols)

if __name__ == '__main__':
    summarise(sys.argv[1])
