import random
import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
from smooth import _pari

db = int(sys.argv[1])
reps = int(sys.argv[2])
P = _pari()
try:
    P.allocatemem(2 * 1024 * 1024 * 1024)
except Exception:
    pass
rng = random.Random(5)
lo = 1 << (db - 1)
t = time.time()
m = None
for _ in range(reps):
    p = int(P("nextprime(" + str(rng.randrange(lo, 1 << db)) + ")"))
    a1 = rng.randrange(1 << 20) % p
    a2 = rng.randrange(1 << 40) % p
    a3 = (rng.randrange(1 << 40) % p) or 7
    m = int(P("ellcard(ellinit([" + str(a1) + "," + str(a2) + "," +
                 str(a3) + ",0,0]," + str(p) + "))"))
dt = (time.time() - t) / reps
print("RESULT", dt, m, flush=True)