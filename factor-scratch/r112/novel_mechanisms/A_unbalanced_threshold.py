#!/usr/bin/env python3
"""
CANDIDATE A -- Unbalanced-RSA known-bits Coppersmith threshold.

THE GAP.  The closed axis (memory: coppersmith-threshold-to-the-bit) measured
the threshold ONLY at BALANCED N = 2^128, where it came out at X = N^(1/4)
= 2^32 unknown bits (31 works / 32 fails).  But N = p*q with |p| != |q| is
explicitly flagged in FANOUT_BRIEF sec 5 as not covered, and there the two
standard statements of the Coppersmith-for-unknown-divisor bound DISAGREE:

  PRED-A  Coppersmith (unknown divisor):  X < N^(b^2),  b = log p / log N.
          => unknown bits = b^2 * log2(N);  as a FRACTION of p's b*log2(N)
          bits that is b.  Unbalanced RSA is WORSE to attack: at b=1/3 you
          must already know 2/3 of p.
  PRED-B  Howgrave-Graham phrasing in terms of the factor itself:
          X < p^(1/2).  => unknown bits = (b/2)*log2(N), a b/2 fraction.
          Unbalanced RSA is EASIER to attack.

At b = 1/2 the two coincide exactly (N^(1/4) = p^(1/2)), which is WHY the
balanced measurement cannot separate them.  At b=1/3 they differ by a factor
N^(1/18) ~ 2^7 -- easily separable.  So this is a real discriminating test.

FALSIFIER.  PRED-A dies if the measured threshold tracks (b/2)*log2 N.
PRED-B dies if it tracks b^2*log2 N.  Both die if it tracks neither.

CONTROL (mandatory, brief sec 1.2).  (a) The balanced cell b=1/2 must
reproduce the closed axis: 31 unknown bits WORKS, 32 FAILS, N=2^128.  If it
does not, this harness does not measure what the closed axis measured and
every other cell is void.  (b) Every recovered factor is multiplied back to N.
(c) Every (b, X) cell carries a known-GOOD sibling well below threshold.
"""
import sys, json, time, math, argparse
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r112/novel_mechanisms")

from coppersmith import (univariate_lattice, integer_roots, poly_eval,
                         poly_trim)
from reduce import reduce_fpylll
from common112 import gen_semiprime, verified_factor

# (m, t) grid.  dim = m + t for degree 1.  The closed axis needed dim 52
# (m=t=26) at the N=2^128 boundary, so the grid must REACH there.
GRID = [(10, 10), (14, 14), (18, 18), (22, 22), (26, 26),
        (26, 34), (30, 30), (30, 40), (34, 34), (34, 46),
        (38, 38), (38, 50), (42, 42), (46, 46), (26, 60), (50, 50)]
MAXVEC = 8


def cell(N, p, unk, budget_s):
    """Try to recover x0 = p - a with 0 <= x0 < 2^unk, a = p aligned down.

    Returns dict with found / x0 / factor / nvec / seconds.  `factor` is
    ground-truth verified by multiplication back to N."""
    nb = p.bit_length()
    if unk <= 0 or unk >= nb:
        return dict(unk=unk, err="range")
    a = (p >> unk) << unk                      # ALIGNED (closed-axis defect)
    x0 = p - a
    assert 0 <= x0 < (1 << unk), "leak alignment defect"
    f = poly_trim([int(a), 1])
    X = 1 << unk
    t0 = time.time()
    for (m, t) in GRID:
        if time.time() - t0 > budget_s:
            return dict(unk=unk, found=False, budget_out=True,
                        seconds=round(time.time() - t0, 1), tried=(m, t))
        rows, scale = univariate_lattice(f, N, X, m, t)
        R = reduce_fpylll(rows, delta=0.99)
        for row in R[:MAXVEC]:
            pv = [row[c] // scale[c] for c in range(len(row))]
            for r in integer_roots(pv, -X, X):
                val = poly_eval(f, r)
                # GROUND TRUTH: val is a candidate factor of N
                if val and verified_factor(N, p, N // p, val):
                    return dict(unk=unk, found=True, x0=r, factor=val,
                                dim=len(rows), mm=(m, t),
                                seconds=round(time.time() - t0, 1))
    return dict(unk=unk, found=False, seconds=round(time.time() - t0, 1))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bits", type=int, default=128)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--budget", type=float, default=900.0)
    ap.add_argument("--tag", default="run")
    a = ap.parse_args()

    Nbits = a.bits
    # exact-integer thresholds from both predictions -- NOT floats
    logN = Nbits
    out = dict(tag=a.tag, bits=Nbits, seed=a.seed, cells=[])
    # beta = log2(p)/log2(N) enforced via exact bit lengths
    for pb in sorted({Nbits // 2, (2 * Nbits) // 5, Nbits // 3, Nbits // 4}):
        qb = Nbits - pb
        beta = pb / float(Nbits)
        p, q, N = gen_semiprime(Nbits, a.seed * 1000 + pb, beta=pb / Nbits)
        assert p.bit_length() == pb and q.bit_length() == qb, \
            "bit budget not met: %d %d" % (p.bit_length(), q.bit_length())
        assert N.bit_length() == Nbits and p * q == N
        predA = beta ** 2 * logN                 # unknown bits, PRED-A
        predB = (beta / 2.0) * logN             # unknown bits, PRED-B
        # candidate unknowns bracketing both predictions, integers only
        lo = int(math.floor(min(predA, predB))) - 2
        hi = int(math.ceil(max(predA, predB))) + 2
        unknowns = sorted({u for u in range(max(1, lo), min(pb - 1, hi) + 1)})
        # CONTROL sibling: far below BOTH thresholds, must work
        known_good = max(1, int(math.floor(min(predA, predB))) - 6)
        grid = [known_good] + unknowns
        for unk in grid:
            r = cell(N, p, unk, a.budget)
            r.update(pb=pb, qb=qb, beta=round(beta, 4),
                     predA_bits=round(predA, 2), predB_bits=round(predB, 2),
                     is_control=(unk == known_good))
            out["cells"].append(r)
            print("pb=%d unk=%d found=%s dim=%s %.0fs (ctrl=%s)" %
                  (pb, unk, r.get("found"), r.get("dim"), r.get("seconds", 0),
                   r.get("is_control")), flush=True)
    fn = "/home/raver1975/lean/factor-scratch/r112/novel_mechanisms/out_A_%s_%d_%d.json" % (
        a.tag, Nbits, a.seed)
    json.dump(out, open(fn, "w"), indent=1)
    print("wrote", fn)


if __name__ == "__main__":
    main()
