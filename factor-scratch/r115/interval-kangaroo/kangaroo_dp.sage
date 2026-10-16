# =====================================================================
#  kangaroo_dp.sage -- Axis K (r115): the MEMORY/TIME tradeoff of the
#  distinguished-point (DP) kangaroo, versus the full-trap-table
#  kangaroo and versus interval-BSGS.
#
#  Pollard's lambda has two storage policies:
#
#   (A) FULL TABLE   dplen = 0 : keep EVERY tame position.
#       ops  ~ K + W    memory = K entries
#   (B) DP TABLE     dplen = L : keep only positions whose x-coordinate
#       clears L chosen bits (a length-L distinguished point).
#       ops  ~ K + W    memory = K * 2^-L entries
#
#  The practical choice (memory-constrained attacker) is exactly the
#  (ops, memory) frontier this script traces.  The headline law
#  log2(ops) = c + beta*log2(w) uses the FULL-TABLE runs (dplen = 0);
#  this script supplies the memory counterpoint required by the brief.
#
#  Note: with dplen > 0 the wild kangaroo can step PAST a trap it would
#  otherwise have found, so its length grows; that is the point.
# =====================================================================

import time, json, os
from math import sqrt as pysqrt, log as pylog, ceil as pyceil
from random import Random as PyRandom

LOGDIR = "/home/raver1975/lean/factor-scratch/r115/interval-kangaroo/logs"
RUN   = os.environ.get("DRUN", "run1")
SEED  = int(os.environ.get("DSEED", "1150043"))
SIZES = [int(x) for x in os.environ.get("DSIZES", "12,16,20,24,28").split(",")]
NSEED = int(os.environ.get("DSEEDS", "12"))
DPLENS = [int(x) for x in os.environ.get("DPLENS", "0,2,4,6,8,10,12").split(",")]

P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
NN = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

assert EE.is_smooth() and GG.order() == NN and is_prime(NN) and EE.cardinality() == NN
print("GROUND TRUTH: secp256k1, #E = n prime, ord(G) = n, %d bits" % int(NN).bit_length())

class Ops(object):
    """Explicit group-operation counter."""
    __slots__ = ('n',)
    def __init__(self):
        self.n = 0

GOLD = int(0x9E3779B97F4A7C15)
MASK64 = int(0xFFFFFFFFFFFFFFFF)

def jump_of(pt, Mmax):
    x = int(pt[0])
    h = ((x >> 64) * GOLD + (x >> 192)) & MASK64
    h = (h * GOLD + (h >> 31)) & MASK64
    return 1 + (h % Mmax)

def build_jumps(Mmax, ctr):
    J = [None] * (Mmax + 1)
    cur = EE(0)
    for j in range(1, Mmax + 1):
        cur = cur + GG; ctr.n += 1; J[j] = cur
    return J

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

def kangaroo_dp(aA, bB, Q, Mmax, kfac, dplen, ctr, cap_pad=6):
    """as kangaroo_law.sage but with a DP filter of length dplen.
    Returns ops/times/memory.  The DP criterion is applied to bits
    120..120+dplen of the affine x-coordinate (the same mixed slice the
    jump function uses, to avoid the degenerate low-bit slice)."""
    w = bB - aA + 1
    meanjump = (Mmax + 1) // 2
    K = max(2, int(round(kfac * meanjump)))
    cap = int(pyceil(w / meanjump)) + K + int(round(cap_pad * meanjump))
    aG = smul_ctr(GG, aA, ctr)
    bG = smul_ctr(GG, bB, ctr)
    J = build_jumps(Mmax, ctr)
    mask = (1 << int(dplen)) - 1
    traps = {}
    cur = bG; dist = 0
    for _ in range(K):
        j = jump_of(cur, Mmax)
        cur = cur + J[j]; dist += j; ctr.n += 1
        xv = int(cur[0])
        if ((xv >> 120) & mask) == 0:
            traps[xv] = dist
    cur = Q; dist = 0; hit = None
    ws = 0
    while ws < cap:
        j = jump_of(cur, Mmax)
        cur = cur + J[j]; dist += j; ctr.n += 1; ws += 1
        xv = int(cur[0])
        if ((xv >> 120) & mask) == 0:
            dt = traps.get(xv)
            if dt is not None:
                cand = bB + dt - dist
                if aA <= cand <= bB:
                    hit = cand
                break
    return dict(w=w, Mmax=Mmax, K=K, dplen=dplen, ntraps=len(traps),
                total_ops=ctr.n, tame_ops=K, wild_ops=ws, hit=hit)

def cellrand(bit, idx, dplen):
    return PyRandom(int(SEED + 7919 * int(bit) + 104729 * int(idx) + 13 * int(dplen)))

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
    print("kangaroo_dp.sage  RUN=%s SEED=%d  dplens=%s" % (RUN, SEED, DPLENS))
    print("=" * 74)
    rows = []
    for bv in SIZES:
        w = 2 ** int(bv)
        Mmax = max(4, int(round(2.0 * pysqrt(w))))
        Jt = None
        for dplen in DPLENS:
            Jt = None
            for idx in range(NSEED):
                rng = cellrand(bv, idx, dplen)
                d = rng.randrange(w)
                c = Ops(); c.n = 0
                Q = GG * d
                r = kangaroo_dp(0, w - 1, Q, Mmax, 3.0, dplen, c)
                r['b'] = int(bv); r['seed'] = int(idx); r['plant'] = int(d)
                if r['hit'] is not None:
                    r['ok'] = bool(GG * int(r['hit']) == Q)
                    r['matches_plant'] = bool(int(r['hit']) == d)
                else:
                    r['ok'] = False; r['matches_plant'] = False
                rows.append(r)
            sub = [r for r in rows if r['b'] == bv and r['dplen'] == dplen]
            nr = int(sum(1 for r in sub if r['ok']))
            mo = sum(r['ntraps'] for r in sub) / float(len(sub))
            mops = sum(r['total_ops'] for r in sub) / float(len(sub))
            print("  b=%3d dplen=%2d  traps=%8.0f  mean ops %9.0f = 2^%.2f  recovery %2d/%d"
                  % (bv, dplen, mo, mops, pylog(mops, 2.0), nr, len(sub)))
        print("")

    # ---- frontier: ops vs memory, for the two largest sizes
    print("-" * 74)
    print("FRONTIER (tame-walk ops K vs stored traps) at b=28")
    print("-" * 74)
    bv = 28
    w = 2 ** bv
    Mmax = max(4, int(round(2.0 * pysqrt(w))))
    for dplen in DPLENS:
        sub = [r for r in rows if r['b'] == bv and r['dplen'] == dplen]
        if not sub:
            continue
        nr = int(sum(1 for r in sub if r['ok']))
        mo = sum(r['ntraps'] for r in sub) / float(len(sub))
        mops = sum(r['total_ops'] for r in sub) / float(len(sub))
        K = sub[0]['K']
        # memory in BYTES: one dict entry + one 256-bit int key
        mem = mo * 61.0
        print("   dplen=%2d : K=%7d  traps=%8.0f  memory=%10.1f MB   ops=2^%.2f  rec %2d/%d"
              % (dplen, K, mo, mem / 1048576.0, pylog(mops, 2.0), nr, len(sub)))

    out = jclean(dict(
        meta=dict(kind="kangaroo_dp", run=RUN, seed=SEED, sizes=SIZES, nseed=NSEED,
                  dplens=DPLENS, curve="secp256k1", order_n=int(NN)),
        rows=rows))
    fn = os.path.join(LOGDIR, "kangaroo_dp_%s.json" % RUN)
    with open(fn, "w") as fh:
        json.dump(out, fh, indent=1)
    print("wrote", fn)

main()
