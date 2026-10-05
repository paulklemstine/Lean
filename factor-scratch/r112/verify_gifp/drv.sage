import sys
MODE = sys.argv[-2] if sys.argv[-2] != 'drv.sage' else 'c12'
LOG  = sys.argv[-1]
sys.argv = ['run_sweep.sage', MODE, LOG]
exec(compile(open('run_sweep.sage').read(), 'run_sweep.sage', 'exec'))
