# ---------------------------------------------------------------------------
# exp_i2a_secp.sage -- I2-A (LCG with KNOWN multiplier) on the real curve
# secp256k1.  m = 253 so that 2^m < n (the nonce is never reduced mod n).
#
# Usage: sage exp_i2a_secp.sage [seeds per point] [seed1] [seed2]
# ---------------------------------------------------------------------------
from sage.all import *
import json
load('common.sage')

def P(*a): print(*a, flush=True)

NSEED = int(sys.argv[1]) if len(sys.argv) > 1 else 20
SEEDS = [int(sys.argv[2]) if len(sys.argv) > 2 else 20261014,
         int(sys.argv[3]) if len(sys.argv) > 3 else 909090]

C = SECP; n = C['n']
M = 253                 # LCG state size; 2^M < n
P("=== I2-A on secp256k1, m = %d ===" % M)
P("plain HNP floor at this size: t*ell >= 256")
P("%6s %6s %8s %16s %28s" % ("ell", "t", "t*ell", "LCG(known a)", "plain HNP same instances"))
res = {}
for (ell, t) in ((0, 4), (0, 5), (0, 6), (0, 8), (4, 4), (8, 4), (16, 4), (0, 3)):
    okA = okB = done = 0
    for s in SEEDS:
        set_random_seed(s)
        for _ in range(NSEED):
            d = Integer(randrange(1, n-1))
            a = int(randrange(2, 2**M - 1)) | 1
            b = int(randrange(0, 2**M - 1))
            sig = gen_lcg(C, d, t, ell, M, a, b)
            if sig['t'] < t:
                continue
            done += 1
            okA += int(trial(attack_lcg_a, sig))
            okB += int(trial(attack_plain_classical, sig))
    res[(ell, t)] = (okA, okB, done)
    P("%6d %6d %8d %8d/%-7d %14d/%-7d" % (ell, t, ell*t, okA, done, okB, done))

with open('logs/i2a_secp.json', 'w') as f:
    json.dump({'seeds': [int(x) for x in SEEDS], 'm': int(M),
               'points': [[int(k[0]), int(k[1])] + [int(v) for v in vv]
                          for k, vv in sorted(res.items())]}, f, indent=1)
P("wrote logs/i2a_secp.json")
