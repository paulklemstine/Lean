# ---------------------------------------------------------------------------
# exp_i2b.sage -- Axis I2, multiplier a SECRET: the bilinear case.
#
# The recurrence eps_{i+1} - a*eps_i - a*kbar_i - b = -kbar_{i+1} (mod 2^m) is
# BILINEAR in the unknowns (a, eps).  The only single-linear-lattice encoding
# available is gamma_i := a*eps_i with the link gamma_i = a*eps_i dropped.  We
# build exactly that lattice -- unknowns (eps, gamma, a, b, d), signature rows
# mod n, recurrence rows mod 2^m -- and measure it against the plain HNP
# baseline ON THE SAME INSTANCES with the same seeds.
#
# Usage: sage exp_i2b.sage [nseeds] [seed1] [seed2]
# ---------------------------------------------------------------------------
from sage.all import *
import json
load('common.sage')

def P(*a): print(*a, flush=True)

NSEED = int(sys.argv[1]) if len(sys.argv) > 1 else 20
SEEDS = [int(sys.argv[2]) if len(sys.argv) > 2 else 20261014,
         int(sys.argv[3]) if len(sys.argv) > 3 else 909090]

M = NB_TOY - 2
TWO_M = 2**M
C = TOY; n = C['n']

POINTS = []
for ell in (2, 4, 8, 16):
    tf = int(ceil(NB_TOY/float(ell)))
    for mult in (1.0, 2.0):
        POINTS.append((ell, int(ceil(tf*mult))))

P("=== I2-B : LCG nonces, multiplier a SECRET (toy curve, m=%d) ===" % M)
P("lattice unknowns (eps,gamma,a,b,d) dimension 2t+3; rows t (mod n) + t-1 (mod 2^m)")
P("info floor for the plain HNP: t*ell >= %d" % NB_TOY)
res = []
for s in SEEDS:
    P("--- seed %d ---" % s)
    set_random_seed(s)
    row = {}
    for (ell, t) in POINTS:
        okA = okB = done = 0
        for _ in range(NSEED):
            d = Integer(randrange(1, n-1))
            a = int(randrange(2, TWO_M - 1)) | 1
            b = int(randrange(0, TWO_M - 1))
            sig = gen_lcg(C, d, t, ell, M, a, b)
            if sig['t'] < t:
                continue
            done += 1
            okA += int(trial(attack_lcg_ab, sig))
            okB += int(trial(attack_plain_classical, sig))
        row[(ell, t)] = (okA, okB, done)
        P("  ell=%2d t=%3d (t*ell=%4d): linearised LCG %d/%d | plain HNP same instances %d/%d"
          % (ell, t, ell*t, okA, done, okB, done))
    res.append(row)

with open('logs/i2b.json', 'w') as f:
    json.dump({'seeds': [int(x) for x in SEEDS], 'nseeds': int(NSEED), 'm': int(M),
               'points': [[[int(x) for x in k] + [int(v) for v in vv]
                           for k, vv in sorted(r.items())] for r in res]}, f, indent=1)
P("wrote logs/i2b.json")
