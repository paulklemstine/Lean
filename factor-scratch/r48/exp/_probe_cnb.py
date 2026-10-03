import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
from smooth import _pari
import families as F

db = int(sys.argv[1])
flag = int(sys.argv[2])
P = _pari()
try:
    P.allocatemem(2 * 1024 * 1024 * 1024)
except Exception:
    pass
rng = __import__("random").Random(123)
D = F.fundamental_discount(1 << (db - 2), 1 << (db - 1), rng, P)
t = time.time()
h = int(P("qfbclassno(" + str(D) + "," + str(flag) + ")"))
dt = time.time() - t
print("RESULT", dt, h, flush=True)