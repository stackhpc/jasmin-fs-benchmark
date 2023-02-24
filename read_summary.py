""" WIP result summarising for IO500

    Usage:
        python3 read_summary.py 'runs/*/result_summary.txt'

    NB: the quotes are important to avoid shell globbing.
"""

import sys, json, pprint, glob


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
                data['score'] = {
                    'bandwidth': float(bw),
                    'iops': float(iops),
                    'bandwidth_unit': bw_unit,
                    'iops_unit': iops_unit,
                    'total': float(total),
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
        fsname = path.split('/')[1]
        results = read_io500_summary(path)
        no_score = dict(((k, v) for (k, v) in results.items() if k != 'score'))
        score_keys = ['bandwidth', 'iops', 'total']
        
        header1 = ['fsname', 'path'] + list(no_score.keys()) + [s + '-score' for s in score_keys]
        header2 = ['-', '-'] + [v['unit'] for v in no_score.values()] + ['GiB/s', 'kiops', '-']
        if not rows:
            rows.extend([header1, header2])

        # have to convert back to strings!
        scores = [str(results['score'][k]) for k in score_keys]
        values = [fsname, path] + [str(v['value']) for v in no_score.values()] + scores
        rows.append(values)

    cols = transpose(rows)
    tabulate(cols)

if __name__ == '__main__':
    summarise(sys.argv[1])
