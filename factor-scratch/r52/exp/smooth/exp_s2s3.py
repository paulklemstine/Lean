"""
BB / S2 and S3 -- structured candidate generation, and the intrinsic cost bound.

=============================== PREREGISTERED ===============================
(S2a) SQUARING WALK x = 1,2,4,8,... is DEGENERATE ON AXIS 2, not axis 1.  If
      r_k is FB-smooth then r_{k+1} = r_k^2 is too, so ONE hit yields a
      geometric run of 'relations' whose exponent vectors are all PROPORTIONAL
      (e_j = 2^j e_0).  Prediction: smoothness rate is fine, but rank(M) = 1 and
      every alpha_t is exactly 0.  The self-test ST5 constructs exactly this
      object; here it is produced by the sampler itself.

(S2b) SMOOTH-INDEX CONSTRUCTION DOES NOT WORK.  Choosing x to be a y-smooth
      integer (so that x has algebraic structure) does not force g^x mod n to be
      FB-smooth: g^x mod n is an equidistributed-looking residue whose
      arithmetic structure is unrelated to the structure of x.  Prediction:
      skew S in [0.7, 1.5], i.e. indistinguishable from `random`.

(S2c) ALGEBRAIC FORCING HAS EXACTLY ONE SOLUTION AND IT IS VACUOUS.  The family
      x = k*ord(g) forces g^x = 1, which is trivially FB-smooth (all exponents
      zero) -- and is a useless relation.  Computing ord(g) is itself the
      factoring problem.  No non-trivial forcing family is known; producing an
      x with g^x FB-smooth AND non-trivial IS the relation search, by
      definition.  Prediction: no experiment can do better than 1/density.

(S3)  INTRINSIC COST.  Claim, to be stated precisely in the notes and checked
      against the measurements:
        * lower bound: >= 1 multiplication per candidate (a candidate not
          already in hand cannot be produced for free), hence
          >= k / density(BB, n) multiplications per k relations;
        * upper bound: the stride sampler ACHIEVES it, at 1 mult/candidate;
      so the stride sampler is OPTIMAL among all samplers, and the only way to
      beat it is a candidate set that is NOT uniform -- i.e. a violation of
      the equidistribution of {g^x mod n}, which is a known open conjecture.
      Prediction: the measured best cost equals (b+c)/density within 20%.
==========================================================================
"""

from __future__ import annotations

import math
import random
import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r52/exp/smooth")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

from harness import (FbTest, hunt, kernel_diagnostics, skew, selftest,  # noqa
                     pow_counted, null_rate)
from exp_batch import psi_exact, psi_selftest, density                      # noqa
from stange import (factor_base, bbound_for_b, gen_semiprime, order_mod_n,   # noqa
                    kernel_basis, primitive, build_M)


# ---------------------------------------------------------------------------
# S2a -- the squaring walk
# ---------------------------------------------------------------------------

def s2a_squares(bits=30, b=12, c=6, n_inst=4, seed=880000):
    print("=" * 84)
    print(f"S2a -- squaring walk x = 1,2,4,8,... (n~2^{bits}, b={b}, c={c})")
    print("=" * 84)
    FB0 = factor_base(bbound_for_b(b), gen_semiprime(bits, random.Random(seed))[0])
    dens, _ = density(gen_semiprime(bits, random.Random(seed))[0], FB0)
    print(f"  exact density = {dens:.4e}  (1/density = {1/dens:,.0f})")
    print(f"{'inst':>5} {'rels':>5} {'trials/rel':>11} {'S':>6} {'rank/b':>7} "
          f"{'zero_frac':>10} {'all_zero':>9}")
    for i in range(n_inst):
        sd = seed + i
        rng = random.Random(sd)
        n, p, q = gen_semiprime(bits, rng)
        FB = factor_base(bbound_for_b(b), n)
        # the squaring walk needs a CACHE: it re-tests the same residues
        fb = FbTest(FB, cache=True)
        h = hunt(n, 2, fb, b + c, random.Random(sd + 1), "squares", cap=400000)
        if len(h["rels"]) < b + c:
            print(f"{i:>5} {len(h['rels']):>5}  -- stalled / fewer relations than needed")
            continue
        tpr = h["trials"] / len(h["rels"])
        dg = kernel_diagnostics(h["rels"], b, c)
        S = skew(tpr, dens)
        print(f"{i:>5} {len(h['rels']):>5} {tpr:>11.1f} {S:>6.2f} "
              f"{dg['rank']:>3}/{b:<3} {dg['zero_frac']:>10.2f} "
              f"{str(dg['all_zero']):>9}")
    print()
    print("  PREDICTION (S2a): rank(M) = 1 and all alpha_t = 0 -> the squaring")
    print("  walk cannot be used at all, no matter how cheap it is.")
    print()


def primerange_list(bound):
    from sympy import primerange
    return list(primerange(2, bound + 1))


def s2b2_full_size_smooth_index(bits=26, b=12, need=300, seed=881100, y=64,
                                lo_frac=0.25, hi_frac=0.5):
    """S2b REVISED.  The first version compared a semigroup walk (which starts at
    x = 1, 2, 4, 6, 8 -- TINY, the same small-x corner that makes `seq` degenerate)
    against `random`.  Its S = 0.23 therefore says nothing about whether the
    ARITHMETIC STRUCTURE of x matters; it just re-found the small-x corner.

    This version removes that confound entirely: BOTH candidate sets have x
    restricted to the full-size window [lo, hi) = [n/4, n/2).  The only
    difference is whether x is y-smooth or lies on an arithmetic progression.
    Both cost one `pow` per candidate, so only the RATE is compared.

    REVISED PREREGISTRATION: S in [0.7, 1.5] -- forcing x to be smooth does NOT
    force g^x mod n to be FB-smooth, because g^x mod n is equidistributed in
    [1,n) regardless of how structured x is.  S < 0.7 would be a genuine finding.
    """
    import heapq
    print("=" * 84)
    print(f"S2b(2) -- FULL-SIZE x only: is y-smooth x smoother than an AP? "
          f"(n~2^{bits}, b={b}, y={y})")
    print("=" * 84)
    agg = {}
    dens = None
    for sd in (seed, seed + 1):
        rng = random.Random(sd)
        n, p, q = gen_semiprime(bits, rng)
        FB = factor_base(bbound_for_b(b), n)
        dens, _ = density(n, tuple(primerange_list(bound=bbound_for_b(b))))
        lo, hi = int(n * lo_frac), int(n * hi_frac)
        # all y-smooth x in the window
        h, seen = [1], set()
        xs = []
        while h:
            m = heapq.heappop(h)
            if m >= hi:
                break
            # BUG (fixed): only pushing v inside [lo,hi) starved the walk --
            # every product below lo was discarded, so nothing could ever grow
            # into the window.  Push everything below hi, collect on the way.
            for py in range(2, y + 1):
                v = m * py
                if v < hi and v not in seen:
                    seen.add(v)
                    heapq.heappush(h, v)
            if lo <= m < hi:
                xs.append(m)
        # a matched arithmetic progression in the SAME window
        span = hi - lo
        s = max(1, span // max(len(xs), 1))
        xs_ap = list(range(lo, hi, s))[:len(xs)]
        print(f"  n=2^{n.bit_length()}  window [{lo:.3g},{hi:.3g}) : "
              f"{len(xs)} y-smooth x, {len(xs_ap)} AP x (stride {s})")
        fb = FbTest(FB)
        for label, Xs in (("smooth-index", xs), ("arithmetic-prog", xs_ap)):
            hits = 0
            mults = 0
            for x in Xs:
                r, m = pow_counted(2, x, n)
                mults += m
                if fb(r)[1] == 1:
                    hits += 1
            a = agg.setdefault(label, {"cand": 0, "hit": 0, "mult": 0})
            a["cand"] += len(Xs)
            a["hit"] += hits
            a["mult"] += mults
    print()
    print(f"{'x-set':>18} {'cands':>9} {'hits':>6} {'rate':>11} {'S':>6} "
          f"{'mults/hit':>10}")
    for label, a in agg.items():
        tpr = a["cand"] / a["hit"]
        S = skew(tpr, dens)
        print(f"{label:>18} {a['cand']:>9,} {a['hit']:>6} {a['hit']/a['cand']:>11.4e} "
              f"{S:>6.2f} {a['mult']/a['hit']:>10.0f}")
    print()
    print("  PREDICTION (revised): S(smooth-index) in [0.7, 1.5], i.e. the")
    print("  arithmetic structure of x is IRRELEVANT once x is full size.")
    print()


# ---------------------------------------------------------------------------
# S2b -- smooth-index construction
# ---------------------------------------------------------------------------

def s2b_smooth_index(bits=26, b=12, need=25, seeds=(881001, 881002), y=None):
    print("=" * 84)
    print(f"S2b -- smooth-INDEX construction (x itself y-smooth) (n~2^{bits}, b={b})")
    print("=" * 84)
    if y is None:
        y = max(4, int(round(bits // 3)))
    agg = {}
    dens = None
    for sd in seeds:
        rng = random.Random(sd)
        n, p, q = gen_semiprime(bits, rng)
        FB = factor_base(bbound_for_b(b), n)
        dens, _ = density(n, tuple(primerange_list(bound=bbound_for_b(b))))
        for sname, kw in (("random", {}),
                          ("smoothidx", dict(y=y)),
                          ("stride", dict(x0=n // 4,
                                          stride=random.Random(sd + 2).randrange(
                                              n // 4, n // 2) | 1))):
            h = hunt(n, 2, FB, need, random.Random(sd + 3), sname, cap=8_000_000, **kw)
            if len(h["rels"]) < 5:
                print(f"  !! {sname} stalled ({len(h['rels'])} rels)")
                continue
            a = agg.setdefault(sname, {"rel": 0, "tr": 0, "mu": 0})
            a["rel"] += len(h["rels"])
            a["tr"] += h["trials"]
            a["mu"] += h["mults"]
    print(f"  x chosen y-smooth with y = {y}  (density of such x in [1,n) is "
          f"tiny, so these are a very structured exponent set)")
    print(f"{'sampler':>12} {'rels':>5} {'trials/rel':>11} {'1/dens':>10} "
          f"{'mults/rel':>11} {'S':>6} {'flag':>7}")
    for key, a in agg.items():
        tpr = a["tr"] / a["rel"]
        S = skew(tpr, dens)
        flag = "DEGEN" if S < 0.7 else ("ok" if S <= 1.5 else "RICH")
        print(f"{key:>12} {a['rel']:>5} {tpr:>11.1f} {1/dens:>10.1f} "
              f"{a['mu']/a['rel']:>11.1f} {S:>6.2f} {flag:>7}")
    print()
    print("  PREDICTION (S2b): S(smoothidx) within [0.7, 1.5] -- forcing x to be")
    print("  smooth does NOT force g^x mod n to be FB-smooth.  REFUTED if not.")
    print()


# ---------------------------------------------------------------------------
# S2c -- the only algebraic forcing, and why it is vacuous
# ---------------------------------------------------------------------------

def s2c_forcing(bits=26, seed=882000):
    print("=" * 84)
    print("S2c -- algebraic forcing: the only closed-form family, and why it is vacuous")
    print("=" * 84)
    n, p, q = gen_semiprime(bits, random.Random(seed))
    g = 2
    o = order_mod_n(g, n, p, q)
    print(f"  n = 2^{n.bit_length()}, ord(g) = {o}  ({o.bit_length()} bits)")
    print(f"  x = ord(g)      ->  g^x mod n = {pow(g, o, n)}   (FB-smooth: YES, trivially)")
    print(f"  x = 2*ord(g)    ->  g^x mod n = {pow(g, 2*o, n)}")
    print()
    print("  Both are FB-smooth because g^x = 1 has an ALL-ZERO exponent vector.")
    print("  That is the zero relation: it contributes a column of zeros to M,")
    print("  which does not raise rank(M) and does not move G = gcd(alpha_t).")
    print("  And x = ord(g) is only computable IF YOU HAVE ALREADY FACTORED n:")
    print(f"    ord(g) = lcm(ord_p(g), ord_q(g)); with p = {p}, q = {q} you need p and q.")
    print("  ==> There is no non-vacuous forcing family.  Producing an x with")
    print("      g^x mod n FB-smooth and a NON-TRIVIAL exponent vector IS the")
    print("      relation search; S2c is the statement that S2 has no content.")
    print()


# ---------------------------------------------------------------------------
# S3 -- the intrinsic cost, and the optimal (b, BB)
# ---------------------------------------------------------------------------

def s3_cost_model(bits_ladder=(26, 30, 34, 40, 44), bmax=110, c=1):
    print("=" * 92)
    print("S3 -- intrinsic cost of producing FB-smooth residues from a cyclic group")
    print("=" * 92)
    print("  cost per successful factor for the STRIDE sampler (1 mult/candidate)")
    print("    generation only : (b + c) / density(n, BB(b))          multiplications")
    print("    + smoothness    : (b + c)(1 + b) / density(n, BB(b))   ops")
    print("  The SECOND column is the honest one: at b = 12 the smoothness test is")
    print("  14 reductions against ~50-80 multiplications (negligible), but at b = 100")
    print("  it is 100 reductions against 1 multiplication -- it becomes the cost.")
    print("  [c = 1, the bounded-stripper variant of U_stange_improve.md 7.1]")
    print()
    bests = []
    for bits in bits_ladder:
        nn, _, _ = gen_semiprime(bits, random.Random(883000 + bits))
        rows = []
        for b in range(4, bmax + 1):
            BB = bbound_for_b(b)
            FB = tuple(primerange_list(bound=BB))
            dens, st = density(nn, FB)
            if dens is None:
                continue
            rows.append((b, BB, 1 / dens, (b + c) / dens, (b + c) * (1 + b) / dens))
        if not rows:
            print(f"  n~2^{bits}: Psi out of budget for every b -- skipped")
            continue
        bg = min(rows, key=lambda r: r[3])
        bo = min(rows, key=lambda r: r[4])
        bests.append((bits, bg, bo))
        print(f"  n ~ 2^{bits}  (c = {c})")
        print(f"      {'b':>4} {'BB':>5} {'exp/relation':>14} {'MULTS/factor':>14} "
              f"{'OPS/factor':>14}")
        show = [r for r in rows if r[0] % max(1, len(rows) // 22) == 0] or rows[::7]
        for b, BB, tpr, cm, co in show:
            star = (" <== best gen" if (b, BB, tpr, cm, co) == bg else "") + \
                   (" <== best OPS" if (b, BB, tpr, cm, co) == bo else "")
            print(f"      {b:>4} {BB:>5} {tpr:>14,.0f} {cm:>14,.0f} {co:>14,.0f}{star}")
        print(f"      BEST generation-only : b = {bg[0]}, BB = {bg[1]}, "
              f"{bg[3]:,.0f} mults/factor  ({bg[2]:,.0f} exp/relation)")
        print(f"      BEST incl. smoothness: b = {bo[0]}, BB = {bo[1]}, "
              f"{bo[4]:,.0f} ops/factor    ({bo[2]:,.0f} exp/relation)")
        print()
    print("  SUMMARY  (n ~ 2^bits)      best gen-only        best incl. smoothness")
    for bits, bg, bo in bests:
        print(f"    2^{bits:<3} b={bg[0]:>3} BB={bg[1]:>4} {bg[3]:>14,.0f} mults"
              f"   |  b={bo[0]:>3} BB={bo[1]:>4} {bo[4]:>14,.0f} ops")
    print()
    return bests


if __name__ == "__main__":
    if not selftest():
        sys.exit(1)
    if not psi_selftest():
        sys.exit(1)
    print()
    which = sys.argv[1] if len(sys.argv) > 1 else "abc"
    if "a" in which:
        s2a_squares()
    if "b" in which:
        s2b_smooth_index()
    if "c" in which:
        s2c_forcing()
    if "d" in which:
        s3_cost_model()
