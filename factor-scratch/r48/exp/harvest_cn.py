"""
Harvest class numbers at the largest scale where qfbclassno is usable on this
host, into a JSON file, so the smoothness comparison can run without holding
PARI open.

Mode 'free' : D fundamental negative, free.      (best order distribution,
                                                  but D is NOT a function of N)
Mode 'negN' : D = -N for N a random SEMIPRIME.   (the Schnorr-Lenstra slice:
                                                  reachable from N, no freedom)
"""
import json
import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
from _robust_cn import _batch

DB = int(sys.argv[1])
MODE = sys.argv[2]
TARGET = int(sys.argv[3])
OUT = sys.argv[4]
CAP = int(sys.argv[5]) if len(sys.argv) > 5 else 12

out = []
seed = 0
t0 = time.time()
# batch size 1: qfbclassno cost is wildly D-dependent (ms to >20 s), so a
# batch of 6 lets ONE slow discriminant burn the whole batch budget.
while len(out) < TARGET and time.time() - t0 < 3600:
    g = _batch(DB, 1, seed, MODE, CAP)
    seed += 1
    if g:
        out.extend((a, b) for a, b, _t in g)
        with open(OUT, "w") as fh:
            json.dump(out, fh)
    if seed % 50 == 0:
        print(f"seed={seed} collected={len(out)}/{TARGET} "
              f"({time.time()-t0:.0f}s)", flush=True)

print(f"DONE {len(out)}/{TARGET} in {time.time()-t0:.0f}s", flush=True)
with open(OUT, "w") as fh:
    json.dump(out, fh)