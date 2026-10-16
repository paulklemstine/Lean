# ---------------------------------------------------------------------------
# exp_baseline.sage -- plain HNP reference lattice: threshold curve.
#
# This is the baseline every I2 / I6 number must be reported against.  Same
# harness, same seeds, same success criterion (d*G == Q).
#
# Usage: sage exp_baseline.sage [nseeds] [seed1] [seed2]
# ---------------------------------------------------------------------------
from sage.all import *
import json
load('common.sage')

def P(*a): print(*a, flush=True)

NSEED = int(sys.argv[1]) if len(sys.argv) > 1 else 20
SEEDS = [int(sys.argv[2]) if len(sys.argv) > 2 else 20261014,
         int(sys.argv[3]) if len(sys.argv) > 3 else 909090]

def curve_table(C, nlabel, points, nseeds, seed):
    n = C['n']; nb = nb_of(C)
    set_random_seed(seed)
    res = {}
    for (ell, t) in points:
        ok = 0
        for _ in range(nseeds):
            d = Integer(randrange(1, n-1))
            sig = gen_plain(C, d, t, ell)
            if sig['t'] < t:
                continue
            ok += int(trial(attack_plain_classical, sig))
        res[(ell, t)] = ok
    return res

TOY_POINTS = []
for ell in (3, 4, 6, 8, 12, 16):
    tf = int(ceil(NB_TOY/float(ell)))
    for mult in (1.0, 1.25, 1.5, 2.0):
        TOY_POINTS.append((ell, max(2, int(ceil(tf*mult)))))

P("=== plain HNP baseline, toy curve (n = %d, %d bits) ===" % (TOY['n'], NB_TOY))
P("info floor: t*ell >= log2(n) = %d" % NB_TOY)
P("%6s %6s %8s %10s %10s %10s" %
  ("ell", "t", "t*ell", "seed%d" % SEEDS[0], "seed%d" % SEEDS[1], "mean"))
toy = []
for s in SEEDS:
    toy.append(curve_table(TOY, 'toy', TOY_POINTS, NSEED, s))
for (ell, t) in TOY_POINTS:
    a, b = toy[0][(ell, t)], toy[1][(ell, t)]
    P("%6d %6d %8d %6d/%-4d %6d/%-4d %10.2f" %
      (ell, t, ell*t, a, NSEED, b, NSEED, (a+b)/2.0))

P("")
P("=== plain HNP baseline, secp256k1 (n = %d) ===" % SECP['n'])
SECP_POINTS = [(4, 80), (8, 40), (8, 64), (16, 24)]
secp = []
for s in SEEDS:
    secp.append(curve_table(SECP, 'secp', SECP_POINTS, min(NSEED, 20), s))
P("%6s %6s %8s %10s %10s %10s" %
  ("ell", "t", "t*ell", "seed%d" % SEEDS[0], "seed%d" % SEEDS[1], "mean"))
for (ell, t) in SECP_POINTS:
    a, b = secp[0][(ell, t)], secp[1][(ell, t)]
    P("%6d %6d %8d %6d/%-4d %6d/%-4d %10.2f" %
      (ell, t, ell*t, a, min(NSEED, 20), b, min(NSEED, 20), (a+b)/2.0))

with open('logs/baseline.json', 'w') as f:
    json.dump({'seeds': [int(x) for x in SEEDS], 'nseeds': int(NSEED),
               'toy': [[[int(x) for x in k] + [int(v)] for k, v in sorted(r.items())] for r in toy],
               'secp': [[[int(x) for x in k] + [int(v)] for k, v in sorted(r.items())] for r in secp]},
              f, indent=1)
P("wrote logs/baseline.json")
