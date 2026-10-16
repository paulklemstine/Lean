# ---------------------------------------------------------------------------
# exp_i2.sage -- Axis I sub-axis I2: LCG-structured nonces.
#
# I2-A : nonces k_{i+1} = a*k_i + b (mod 2^m) with the multiplier a KNOWN,
#        increment b secret.  Single lattice over (eps, a, b, d) after b and d
#        are eliminated; the recurrence rows are mod 2^m, the signature rows
#        are mod n, combined as one kernel lattice with small quotients.
# I2-B : same but a SECRET.  The recurrence is bilinear in (a, eps); the only
#        linear encoding drops the link gamma_i = a*eps_i.  Measured against
#        the plain HNP baseline ON THE SAME INSTANCES, SAME SEEDS.
#
# Usage: sage exp_i2.sage [nseeds] [seed1] [seed2]
# ---------------------------------------------------------------------------
from sage.all import *
import json
load('common.sage')

def P(*a): print(*a, flush=True)

NSEED = int(sys.argv[1]) if len(sys.argv) > 1 else 20
SEEDS = [int(sys.argv[2]) if len(sys.argv) > 2 else 20261014,
         int(sys.argv[3]) if len(sys.argv) > 3 else 909090]

M = NB_TOY - 2          # LCG modulus 2^M, with 2^M < n so k is never reduced
TWO_M = 2**M

def make_d(C, n):
    return Integer(randrange(1, n-1))

# ---------------------------------------------------------------------------
def sweep(points, attack, nseeds, seed, include_baseline=True):
    C = TOY; n = C['n']
    set_random_seed(seed)
    out = {}
    for (ell, t) in points:
        okA = okB = okC = 0
        done = 0
        for _ in range(nseeds):
            d = make_d(C, n)
            a = int(randrange(2, TWO_M - 1)) | 1
            b = int(randrange(0, TWO_M - 1))
            sig = gen_lcg(C, d, t, ell, M, a, b)
            if sig['t'] < t:
                continue
            done += 1
            if attack == 'a':
                okA += int(trial(attack_lcg_a, sig))
            else:
                okA += int(trial(attack_lcg_ab, sig))
            if include_baseline:
                okB += int(trial(attack_plain_classical, sig))
        out[(ell, t)] = (okA, okB, done)
    return out

P("=== I2-A : LCG nonces, multiplier a KNOWN (toy curve, m = %d) ===" % M)
P("info floor for plain HNP: t*ell >= %d ; the recurrence supplies"
  " 2^%d-scaled rows, so the counting bound is t*(ell+m) >= 3m" %
  (NB_TOY, M))
A_POINTS = [(ell, t) for ell in (0, 1, 2, 4, 8, 16) for t in (3, 4, 5, 6, 8)]
resA = [sweep(A_POINTS, 'a', NSEED, s) for s in SEEDS]
P("%6s %6s %8s %12s %12s %14s" %
  ("ell", "t", "t*ell", "LCG(known a)", "plain HNP", "plain needs t>="))
for (ell, t) in A_POINTS:
    a1 = resA[0][(ell, t)]; a2 = resA[1][(ell, t)]
    need = "infinite" if ell == 0 else str(int(ceil(NB_TOY/float(ell))))
    P("%6d %6d %8d %5d/%-6d %5d/%-6d %14s" %
      (ell, t, ell*t, a1[0], a1[2], a1[1], a1[2], need))
P("second seed:")
for (ell, t) in A_POINTS:
    a2 = resA[1][(ell, t)]
    P("%6d %6d %8d %5d/%-6d %5d/%-6d" % (ell, t, ell*t, a2[0], a2[2], a2[1], a2[2]))

P("")
P("=== I2-B : LCG nonces, multiplier a SECRET (linearised single lattice) ===")
P("(run separately: sage exp_i2b.sage <nseeds> <seed1> <seed2>  --  the")
P(" linearised lattice is high-dimensional (2t+3 unknowns), so it gets its own")
P(" script and its own wall-clock budget.  This file deliberately stops here.)")

# ---------------------------------------------------------------------------
P("")
P("=== I2-A on secp256k1 (real parameters, m = 253) ===")
P("(run separately: sage exp_i2a_secp.sage <nseeds> <seed1> <seed2>)")
with open('logs/i2.json', 'w') as f:
    json.dump({'seeds': [int(x) for x in SEEDS], 'nseeds': int(NSEED),
               'm': int(M),
               'A': [[[int(x) for x in k] + [int(v) for v in vv]
                      for k, vv in sorted(r.items())] for r in resA]},
              f, indent=1)
P("wrote logs/i2.json")
