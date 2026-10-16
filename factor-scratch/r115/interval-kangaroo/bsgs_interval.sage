# =====================================================================
#  bsgs_interval.sage -- Axis K (r115): baby-step/giant-step specialised
#  to a SHORT INTERVAL, as the memory/time counterpoint to kangaroo.
#
#  Solve Q = d*G with d known only to lie in [a, b], width w = b-a+1.
#
#      m    = ceil(sqrt(w))                       (one square root, exact)
#      baby : store  (a+j)*G    for j = 0 .. m-1  (m-1 counted additions)
#      giant: walk   Q - (a + i*m)*G  for i = 0,1,2,...   (1 addition each)
#
#  OPS   ~ 2*sqrt(w)  + O(log n) setup
#  MEMORY ~ sqrt(w) stored points  (vs. kangaroo's trap table)
#
#  OFF-BY-ONE / TIGHTEST CASE (campaign rule): the endpoint plants are
#  chosen so that an off-by-one in m is fatal:
#      d = a        -> giant index i = 0
#      d = a+m-1    -> baby index j = m-1, i = 0
#      d = a+m      -> j = 0, i = 1
#      d = a+m^2    -> j = 0, i = m (if still <= b)
#      d = b        -> the last giant step
# =====================================================================

import time, json, os, sys
from math import sqrt as pysqrt, ceil as pyceil, log as pylog
from random import Random as PyRandom

LOGDIR = "/home/raver1975/lean/factor-scratch/r115/interval-kangaroo/logs"

RUN   = os.environ.get("BRUN", "run1")
SEED  = int(os.environ.get("BSEED", "1150042"))
SIZES = [int(x) for x in os.environ.get("BSIZES", "8,12,16,20,24,28,32,36").split(",")]
NSEED = int(os.environ.get("BSEEDS", "12"))

P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
NN = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

# ---- GROUND TRUTH FIRST ----------------------------------------------
assert EE.is_smooth() and GG.order() == NN and is_prime(NN)
assert EE.cardinality() == NN
print("GROUND TRUTH: secp256k1, #E = n prime, %d bits, ord(G) = n" % int(NN).bit_length())

def smul_ctr(Pt, k, ctr):
    k = int(k)
    if k == 0:
        return EE(0)
    R = EE(0)
    for bit in format(k, 'b'):
        R = R + R; ctr.n += 1
        if bit == '1':
            R = R + Pt; ctr.n += 1
    return R

class Ops(object):
    """Explicit group-operation counter."""
    __slots__ = ('n',)
    def __init__(self):
        self.n = 0

def bsgs_interval(aA, bB, Q, ctr):
    """BSGS for Q = d*G, d in [aA, bB].  Returns dict with ops/times."""
    w = bB - aA + 1
    m = int(pyceil(pysqrt(w)))            # giant step size
    while m * m < w:                      # exactness guard: m^2 >= w
        m += 1
    t0 = time.time()
    aG = smul_ctr(GG, aA, ctr)
    big = smul_ctr(GG, m, ctr)             # m*G
    t1 = time.time()
    ops_setup = ctr.n
    # baby steps
    table = {}
    cur = aG
    table[int(cur[0])] = 0
    for j in range(1, m):
        cur = cur + GG
        ctr.n += 1
        table[int(cur[0])] = j
    t2 = time.time()
    ops_baby = ctr.n - ops_setup
    # giant steps
    negbig = -big
    gamma = Q + (-aG)
    ctr.n += 1
    i = 0
    found = None
    maxi = int(pyceil(w / m)) + 2
    while i <= maxi:
        jj = table.get(int(gamma[0]))
        if jj is not None:
            found = aA + i * m + jj
            break
        gamma = gamma + negbig
        ctr.n += 1
        i += 1
    t3 = time.time()
    ops_giant = ctr.n - ops_setup - ops_baby
    return dict(a=aA, b=bB, w=w, m=m, maxi=maxi,
                setup_ops=ops_setup, baby_ops=ops_baby, giant_ops=ops_giant,
                total_ops=ctr.n, alg_ops=ops_baby + ops_giant + 1,
                giant_steps=i, ntable=len(table),
                t_setup=t1 - t0, t_baby=t2 - t1, t_giant=t3 - t2, t_total=t3 - t0,
                hit=found, hit_giant=i)

def cellrand(bit, idx):
    return PyRandom(int(SEED + 7919 * int(bit) + 104729 * int(idx)))

def main():
    print("=" * 74)
    print("bsgs_interval.sage  RUN=%s SEED=%d  (%d seeds/cell)" % (RUN, SEED, NSEED))
    print("=" * 74)
    rows = []
    for bv in SIZES:
        w = 2 ** int(bv)
        for idx in range(NSEED):
            rng = cellrand(bv, idx)
            d = rng.randrange(w)
            ctr = Ops = None
            class C(object):
                pass
            c = C(); c.n = 0
            t0 = time.time()
            Q = GG * d                     # given to the attacker
            tq = time.time() - t0
            r = bsgs_interval(0, w - 1, Q, c)
            r['b'] = int(bv); r['seed'] = int(idx); r['plant'] = int(d); r['t_plant'] = tq
            if r['hit'] is not None:
                r['ok'] = bool(GG * int(r['hit']) == Q)
                r['matches_plant'] = bool(int(r['hit']) == d)
            else:
                r['ok'] = False; r['matches_plant'] = False
            rows.append(r)
        sub = [r for r in rows if r['b'] == bv]
        nr = int(sum(1 for r in sub if r['ok']))
        mo = int(sum(1 for r in sub if r['matches_plant']))
        meanops = sum(r['total_ops'] for r in sub) / float(len(sub))
        print("  b=%3d m=2^%d  mean ops %.4g = 2^%.3f  mean giant steps %8.0f"
              "  table %d  recovery %d/%d (plant %d/%d)"
              % (bv, sub[0]['m'].bit_length() - 1, meanops, pylog(meanops, 2.0),
                 sum(r['giant_steps'] for r in sub) / float(len(sub)),
                 sub[0]['ntable'], nr, len(sub), mo, len(sub)))
        for r in sub:
            print("      seed %2d d=%9d  baby %8d giant %8d tot %9d  t=%.2fs hit=%s ok=%s"
                  % (r['seed'], r['plant'], r['baby_ops'], r['giant_ops'], r['total_ops'],
                     r['t_total'], r['hit'], r['ok']))
        print("")

    # ---- TIGHTEST-CASE / OFF-BY-ONE ENDPOINT TEST ---------------------
    print("-" * 74)
    print("ENDPOINT (tightest-case) TEST: off-by-one in m must be fatal here")
    print("-" * 74)
    for bv in (16, 24, 32):
        w = 2 ** int(bv)
        m = int(pyceil(pysqrt(w)))
        while m * m < w:
            m += 1
        cands = [0, 1, m - 1, m, m * m - 1, m * m, w - 1 - m, w - 1]
        cands = sorted(set(c for c in cands if 0 <= c < w))
        print("  b=%d  m=%d  m^2=%d  w=%d" % (bv, m, m * m, w))
        for d in cands:
            c = C(); c.n = 0
            Q = GG * d
            r = bsgs_interval(0, w - 1, Q, c)
            ok = (r['hit'] is not None and GG * int(r['hit']) == Q and int(r['hit']) == d)
            print("     plant d=%-12d giant i=%-6d  recovered=%s  verified=%s"
                  % (d, r['hit_giant'], r['hit'], ok))
            if not ok:
                print("     *** ENDPOINT FAILURE ***")
    print("")

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

    out = jclean(dict(
        meta=dict(kind="bsgs_interval", run=RUN, seed=SEED, sizes=SIZES, nseed=NSEED,
                  curve="secp256k1", order_n=int(NN), sage_version=str(version())),
        rows=rows))
    fn = os.path.join(LOGDIR, "bsgs_interval_%s.json" % RUN)
    with open(fn, "w") as fh:
        json.dump(out, fh, indent=1)
    print("wrote", fn)

main()
