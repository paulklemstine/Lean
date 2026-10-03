import random
import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
from smooth import _pari
import families as F

# Sample K class numbers for discriminants of DB bits and print them as JSON.
db = int(sys.argv[1])
k = int(sys.argv[2])
seed = int(sys.argv[3])
mode = sys.argv[4] if len(sys.argv) > 4 else "free"   # free | negN | posN

P = _pari()
try:
    P.allocatemem(1536 * 1024 * 1024)
except Exception:
    pass
rng = random.Random(seed)
res = []
t_all = time.time()
while len(res) < k:
    if mode == "free":
        D = F.fundamental_discount(1 << (db - 2), 1 << (db - 1), rng, P)
        t = time.time()
        h = int(P("qfbclassno(" + str(D) + ")"))
        dt = time.time() - t
        res.append((D, h, dt))
    else:
        # N a semiprime of db bits, D = sign*N ; keep only FIELD discriminants
        lo = 1 << (db // 2 - 1)
        while True:
            p = int(P("nextprime(" + str(rng.randrange(lo, 1 << (db // 2))) + ")"))
            q = int(P("nextprime(" +
                      str(rng.randrange(lo, 1 << (db - db // 2))) + ")"))
            if p == q:
                continue
            N = p * q
            sign = -1 if mode == "negN" else 1
            D = sign * N
            if int(P("core(" + str(D) + ")")) != D:
                continue
            t = time.time()
            h = int(P("qfbclassno(" + str(D) + ")"))
            res.append((N, h, time.time() - t))
            break
print("SAMPLES", repr(res), flush=True)
print("TOTAL", time.time() - t_all, flush=True)