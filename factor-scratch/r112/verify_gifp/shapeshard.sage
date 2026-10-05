exec(compile(open('run_sweep.sage').read().replace('print(','sys.stdout.flush() or print('),'rs','exec'))
