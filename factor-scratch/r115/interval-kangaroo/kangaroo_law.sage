# =====================================================================
#  kangaroo_law.sage -- Axis K (r115): the short-interval ECDLP cost curve
#
#  CLAIM UNDER TEST (falsifiable)
#  ------------------------------
#  If the ECDSA private key d is known to lie in [a, b] of width w, then
#  Pollard's lambda ("kangaroo") solves Q = d*G on secp256k1 in
#        OPS(b)  ~=  C * sqrt(w)
#  group operations, i.e.  log2(OPS) = c + beta*log2(w)  with beta = 1/2,
#  instead of  ~C'*sqrt(n) ~ 2^128 for a uniform 256-bit key.
#
#  FALSIFIER: beta significantly different from 0.5 (e.g. beta ~ 1, i.e.
#  linear in w), OR a recovery rate of 0/12 at any measured size (which
#  would mean the harness measures nothing).
#
#  COUNTING DISCIPLINE
#  -------------------
#  * Every point doubling and point addition performed anywhere in this
#    file is counted by an explicit integer counter (class Ops).  No
#    library DLP routine is used for any counted number.
#  * Sage's native GF(p) elliptic-curve arithmetic is the arithmetic.
#  * Ground truth first: curve smoothness, cofactor 1, #E = n prime,
#    ord(G) = n, two hand-checked scalar multiplications.
#  * Every recovered d is verified with d*G == Q AND compared with the
#    planted d (the positive control knows d).
#  * The plant d*G (the input the attacker is GIVEN) uses Sage's fast
#    scalar multiplication and is NOT counted as attack cost.
#
#  TRIVIALITY RULE
#  ---------------
#  w = 2^8 .. 2^40 are CORRECTNESS / SCALING measurements, not a threat
#  model: nothing here breaks a real key.  The deliverable is the fitted
#  exponent beta and constant C, extrapolated (clearly labelled) to
#  b = 96..224.
#
#  SAGE TRAPS HIT AND FIXED DURING DEVELOPMENT (see RESULT.md)
#  -----------------------------------------------------------
#  (1) In a .sage file `^` is EXPONENTIATION, not XOR.  A "hash" written
#      as x ^ (x>>127) computes a 129-bit power and hangs the script.
#  (2) `python_int % Integer(2048)` returns a Sage Integer and is ~10x
#      slower; all hot-loop constants are forced to Python ints.
#  (3) The jump function must MIX the x-coordinate.  jump = 1 + (x mod
#      Mmax) (raw low bits) recovered only 12/40 plants while a mixed
#      slice recovered 40/40 on the same 40 plants.
# =====================================================================

import time, json, os, sys
from math import sqrt as pysqrt, log as pylog, ceil as pyceil
from random import Random as PyRandom

LOGDIR = "/home/raver1975/lean/factor-scratch/r115/interval-kangaroo/logs"
if not os.path.isdir(LOGDIR):
    os.makedirs(LOGDIR)

RUN      = os.environ.get("KRUN", "run1")
SEED     = int(os.environ.get("KSEED", "1150041"))
SIZES    = [int(x) for x in os.environ.get("KSIZES", "8,12,16,20,24,28,32,36,40").split(",")]
NSEED    = int(os.environ.get("KSEEDS", "12"))
KFAC     = float(os.environ.get("KKFAC", "3"))
MU_RATIO = float(os.environ.get("KMU", "1"))
POSITIONS = [float(x) for x in os.environ.get("KPOS", "").split(",") if x != ""]

# hot-loop constants forced to PYTHON ints (Sage Integers are slower and
# silently change the arithmetic types)
GOLD = int(0x9E3779B97F4A7C15)
MASK64 = int(0xFFFFFFFFFFFFFFFF)

# ---------------------------------------------------------------- ops

class Ops(object):
    """Explicit group-operation counter; threaded through everything."""
    __slots__ = ('n',)
    def __init__(self):
        self.n = 0

# ---------------------------------------------------------------- curve

P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
GG = EE(Gx, Gy)
NN = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

# ---- GROUND TRUTH FIRST ----------------------------------------------
assert EE.is_smooth()
assert GG.order() == NN
assert is_prime(NN)
assert EE.cardinality() == NN                 # cofactor 1
assert int(GG[0]) == Gx and int(GG[1]) == Gy
assert (NN - 1) * GG + GG == EE(0)
assert EE(0) + GG == GG and GG + (-GG) == EE(0)
assert GG.order() * GG == EE(0)
print("GROUND TRUTH: y^2 = x^3 + 7 over GF(2^256-2^32-977), smooth,")
print("  #E = n (cofactor 1), ord(G) = n, n prime with %d bits"
      % int(NN).bit_length())

# ------------------------------------------------- scalar mult (counted)

def smul_ctr(Pt, k, ctr):
    """k*Pt by left-to-right double-and-add; every op counted."""
    k = int(k)
    if k == 0:
        return EE(0)
    R = EE(0)
    for bit in format(k, 'b'):
        R = R + R
        ctr.n += 1
        if bit == '1':
            R = R + Pt
            ctr.n += 1
    return R

# ------------------------------------------------- jump machinery

def build_jumps(Mmax, ctr):
    """J[j] = j*G for j = 1..Mmax; Mmax counted additions."""
    J = [None] * (Mmax + 1)
    cur = EE(0)
    for j in range(1, Mmax + 1):
        cur = cur + GG
        ctr.n += 1
        J[j] = cur
    return J

def jump_of(pt, Mmax):
    """Deterministic jump size in {1..Mmax} derived from the affine
    x-coordinate.  Must be well mixed: the raw low bits (x mod Mmax) are
    a degenerate jump function -- 12/40 vs 40/40 recovery on 40 plants
    (see jumpfn_compare.sage).  NOTE: in Sage `^` is POWER, not XOR, so
    no XOR is used here."""
    x = int(pt[0])
    h = ((x >> 64) * GOLD + (x >> 192)) & MASK64
    h = (h * GOLD + (h >> 31)) & MASK64
    return 1 + (h % Mmax)

# ------------------------------------------------- the solver

def kangaroo(aA, bB, Q, dplen, Mmax, kfac, ctr, cap_pad=6):
    """Pollard's lambda for Q = key*G, key in [aA, bB].

    dplen  : distinguished-point length (0 = keep every tame position)
    Mmax   : jump table size; jumps uniform on {1..Mmax}
    kfac   : tame length = kfac * mean_jump
    """
    w = bB - aA + 1
    meanjump = (Mmax + 1) // 2
    K = max(2, int(round(kfac * meanjump)))
    cap = int(pyceil(w / meanjump)) + K + int(round(cap_pad * meanjump))

    t0 = time.time()
    aG = smul_ctr(GG, aA, ctr)
    bG = smul_ctr(GG, bB, ctr)
    t1 = time.time()
    ops_setup = ctr.n

    J = build_jumps(Mmax, ctr)
    t2 = time.time()
    ops_table = ctr.n - ops_setup

    mask = (1 << int(dplen)) - 1
    # ---------------- tame: lay traps
    traps = {}
    cur = bG
    dist = 0
    tame_steps = 0
    for _ in range(K):
        j = jump_of(cur, Mmax)
        cur = cur + J[j]
        dist += j
        ctr.n += 1
        tame_steps += 1
        xv = int(cur[0])
        if ((xv >> 120) & mask) == 0:
            traps[xv] = dist
    t3 = time.time()
    ops_tame = ctr.n - ops_setup - ops_table

    # ---------------- wild: find a trap
    cur = Q
    dist = 0
    wild_steps = 0
    hit = None
    spurious = 0
    while wild_steps < cap:
        j = jump_of(cur, Mmax)
        cur = cur + J[j]
        dist += j
        ctr.n += 1
        wild_steps += 1
        xv = int(cur[0])
        if ((xv >> 120) & mask) == 0:
            dt = traps.get(xv)
            if dt is not None:
                cand = bB + dt - dist
                if aA <= cand <= bB:
                    hit = cand
                else:
                    spurious += 1
                break
    t4 = time.time()
    ops_wild = ctr.n - ops_setup - ops_table - ops_tame

    return dict(
        a=aA, b=bB, w=w, meanjump=meanjump, K=K, cap=cap, dplen=dplen, Mmax=Mmax,
        setup_ops=ops_setup, table_ops=ops_table, tame_ops=ops_tame,
        wild_ops=ops_wild, total_ops=ctr.n, alg_ops=ops_table + ops_tame + ops_wild,
        tame_steps=tame_steps, wild_steps=wild_steps, spurious=spurious,
        ntraps=len(traps),
        t_setup=t1 - t0, t_table=t2 - t1, t_tame=t3 - t2, t_wild=t4 - t3,
        t_total=t4 - t0, hit=hit, hit_steps=wild_steps,
    )

# ------------------------------------------------- driver

def cellrand(bit, idx, kind, pos=0):
    return PyRandom(int(SEED + 7919 * int(bit) + 104729 * int(idx)
                        + 13 * int(kind) + 977 * int(pos)))

def one_run(bv, d, kind, pos, idx):
    w = 2 ** int(bv)
    Mmax = max(4, int(round(2.0 * MU_RATIO * pysqrt(w))))
    ctr = Ops()
    t0 = time.time()
    Q = GG * d                       # given to the attacker: not counted
    tq = time.time() - t0
    r = kangaroo(0, w - 1, Q, 0, Mmax, KFAC, ctr)
    r['b'] = int(bv); r['seed'] = int(idx); r['plant'] = int(d)
    r['relpos'] = float(d) / float(w); r['t_plant'] = tq; r['kind'] = kind
    if r['hit'] is not None:
        r['ok'] = bool(GG * int(r['hit']) == Q)
        r['matches_plant'] = bool(int(r['hit']) == d)
    else:
        r['ok'] = False; r['matches_plant'] = False
    return r

def jclean(o):
    if isinstance(o, dict):
        return dict((str(k), jclean(v)) for k, v in o.items())
    if isinstance(o, (list, tuple)):
        return [jclean(v) for v in o]
    if isinstance(o, bool) or o is None or isinstance(o, (int, float, str)):
        return o
    try:
        return int(o)
    except Exception:
        pass
    try:
        return float(o)
    except Exception:
        return str(o)

def main():
    print("=" * 74)
    print("kangaroo_law.sage  RUN=%s SEED=%d" % (RUN, SEED))
    print("  interval [0,2^b), %d seeds/cell, KFAC=%s, mean_jump=%s*sqrt(w)" % (NSEED, KFAC, MU_RATIO))
    print("=" * 74)
    rows = []
    for bv in SIZES:
        w = 2 ** int(bv)
        for idx in range(NSEED):
            rng = cellrand(bv, idx, 0)
            d = rng.randrange(w)
            rows.append(one_run(bv, d, "uniform", d / float(w), idx))
        sub = [r for r in rows if r['b'] == bv]
        nr = int(sum(1 for r in sub if r['ok']))
        mo = int(sum(1 for r in sub if r['matches_plant']))
        meanops = sum(r['total_ops'] for r in sub) / float(len(sub))
        print("  b=%3d w=2^%d  M=%6d K=%7d  mean ops %.4g = 2^%.3f  recovery %d/%d (plant %d/%d)"
              % (bv, bv, sub[0]['Mmax'], sub[0]['K'], meanops,
                 pylog(meanops, 2.0), nr, len(sub), mo, len(sub)))
        for r in sub:
            print("      seed %2d d=%9d  tame %8d wild %8d tot %9d  t=%.2fs hit=%s ok=%s"
                  % (r['seed'], r['plant'], r['tame_ops'], r['wild_ops'], r['total_ops'],
                     r['t_total'], r['hit'], r['ok']))
        print("")

    if POSITIONS:
        print("-" * 74)
        print("POSITION SWEEP: cost vs. where d sits in the interval (tightest case first)")
        print("-" * 74)
        prow = []
        for bv in POSITIONS:
            w = 2 ** int(bv)
            for pi, f in enumerate([0.0, 0.25, 0.5, 0.75, 1.0]):
                for idx in range(NSEED):
                    d = min(w - 1, int(round(f * (w - 1))))
                    r = one_run(bv, d, "pos%d" % pi, f, idx)
                    r['posfrac'] = f
                    rows.append(r); prow.append(r)
                sub = [r for r in prow if r.get('posfrac') == f and r['b'] == bv]
                nr = int(sum(1 for r in sub if r['ok']))
                meanops = sum(r['total_ops'] for r in sub) / float(len(sub))
                print("  b=%3d d/w=%5.2f  mean ops 2^%.3f  recovery %d/%d"
                      % (bv, f, pylog(meanops, 2.0), nr, len(sub)))

    out = jclean(dict(
        meta=dict(kind="kangaroo_law", run=RUN, seed=SEED, sizes=SIZES, nseed=NSEED,
                  kfac=KFAC, mu_ratio=MU_RATIO, curve="secp256k1", order_n=int(NN),
                  sage_version=str(version())),
        rows=rows))
    fn = os.path.join(LOGDIR, "kangaroo_law_%s.json" % RUN)
    with open(fn, "w") as fh:
        json.dump(out, fh, indent=1)
    print("wrote", fn)

main()
