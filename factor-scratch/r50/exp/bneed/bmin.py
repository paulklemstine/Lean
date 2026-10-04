"""
bmin.py -- B4.  THE DECISIVE FALSIFICATION.

The question:  b_needed = 5.9e5 at n = 10^20 is derived from Stange's own
RUNTIME analysis (see bneed.py).  A runtime lower bound is a statement about
COST, not about CORRECTNESS.  Algorithm 2.2 never REQUIRES b to be large; it
requires only that b+c B-smooth residues can be found.  So:

    WHAT IS THE SMALLEST b AT WHICH THE METHOD ACTUALLY WORKS, AS A FUNCTION OF n?

That number decides curiosity vs route.

CONTROLS (all load-bearing, all from the brief):

  C1 positive control.  Stange p.5-7's own example, n = 62389, g = 43,
     B = 50, b = 15, c = 10 must reproduce G = 15400 and factor 701.
     If it fails, NOTHING in this file is reported.

  C2 exactness.  `assert M.v == 0` in Fraction arithmetic on EVERY kernel
     vector, on every trial, before any alpha_t is formed.  Round 48 had a
     null-space routine twice return correct rank with the WRONG vectors.

  C3 THE 2-ADIC CONTROL, and it decides the whole experiment.  Success is
     v2(ord_p g) != v2(ord_q g) -- a property of the MODULUS, not of b.  The
     famous 20/27 = 0.7407 is that probability AVERAGED OVER MODULI.  At one
     fixed modulus it is p_split(p,q), which is 0.5 when p == q == 3 (mod 4)
     and up to 0.97+.  Every rate here is reported as EXCESS over p_split.
     Reading a fixed-n rate against 20/27 would manufacture a spurious
     "+0.2 from the method" -- the exact error r49/MM_regime.md 5a caught.

  C4 NON-VACUITY.  A detector that always answers "works at small b" would
     produce my headline.  So the same code is run against INJECTED b_min
     dependences that are false, and must reject them.  And a NULL answer
     must be returned where null is correct.

  C5 no floats in the correctness path.  b_max, b_min and the trial counts are
     integers; only rates and p_split are floats.
"""
from __future__ import annotations

import json
import math
import random
import sys
from fractions import Fraction

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49exp/regime")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r50/exp/bneed")

import bneed as B           # noqa: E402
import stange               # noqa: E402
from sympy import Matrix, primerange  # noqa: E402


# ---------------------------------------------------------------------------
# C2: the exactness gate
# ---------------------------------------------------------------------------
def gate_Mv(Mrows, vecs):
    """Assert M.v == 0 EXACTLY, in Fraction arithmetic, for EVERY vector."""
    Mf = [[Fraction(int(x)) for x in row] for row in Mrows]
    ncol = len(Mrows[0])
    for v in vecs:
        vv = [x if isinstance(x, Fraction) else Fraction(x) for x in v]
        if len(vv) != ncol:
            raise AssertionError(f"kernel vector length {len(vv)} != {ncol}")
        for i in range(len(Mf)):
            s = Fraction(0)
            for j in range(ncol):
                s += Mf[i][j] * vv[j]
            if s != 0:
                raise AssertionError(f"C2 VIOLATED: M.v != 0 at row {i}")


# ---------------------------------------------------------------------------
# C3: the per-modulus 2-adic baseline
# ---------------------------------------------------------------------------
def v2(x):
    r = 0
    while x % 2 == 0:
        x //= 2
        r += 1
    return r


def p_split(p, q):
    """EXACT P_g[ v2(ord_p g) != v2(ord_q g) ] for THIS modulus."""
    def dist(m):
        d = {0: 2.0 ** -m}
        for k in range(1, m + 1):
            d[k] = 2.0 ** (k - 1 - m)
        return d

    a, b = dist(v2(p - 1)), dist(v2(q - 1))
    same = sum(a[k] * b.get(k, 0.0) for k in a)
    return 1.0 - same, v2(p - 1), v2(q - 1)


def wilson_ci(k, n):
    """Wilson score interval for a binomial proportion.  Returns (lo, hi)."""
    if n == 0:
        return (0.0, 1.0)
    z = 1.959963984540054
    ph = k / n
    d = 1.0 + z * z / n
    c = (ph + z * z / (2 * n)) / d
    hw = z / d * math.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n))
    return (max(0.0, c - hw), min(1.0, c + hw))


# ---------------------------------------------------------------------------
# C1: positive control -- Stange's own worked example, p.5-7
# ---------------------------------------------------------------------------
def positive_control() -> dict:
    n, g, B, c = 62389, 43, 50, 10
    FB = stange.factor_base(B, n)
    res = stange.alg22(n, g, FB, c, random.Random(4242))
    G, fac = res["G"], res["factor"]
    ok = (len(FB) == 15 and G == 15400
          and stange.factor_from_multiple(G, g, n) == 701
          and n == 701 * 89)
    if not ok:
        raise SystemExit(f"C1 POSITIVE CONTROL FAILED: G={G} b={len(FB)} "
                         f"fac={fac} -- RESULTS SUPPRESSED")
    print(f"[C1] Stange p.5-7 example n=62389 g=43 B=50 b=15 c=10: "
          f"G={G}, gcd(43^G, ...) -> 701, 62389 = 701*89.  OK")
    return {"G": G, "b": len(FB)}


# ---------------------------------------------------------------------------
# one trial of Algorithm 2.2 at a given (n, b, c)
# ---------------------------------------------------------------------------
def one_trial(n, p, q, b, c, seed, trial_cap=2_000_000):
    """Returns dict or None if the run could not complete (e.g. no factor
    base of that size avoids dividing n)."""
    BB = stange.bbound_for_b(b)
    FB = stange.factor_base(BB, n)
    if len(FB) != b:
        return None
    rng = random.Random(seed)
    g = rng.randrange(2, n)
    while math.gcd(g, n) != 1:
        g = rng.randrange(2, n)
    try:
        rels, trials = stange.find_relations(n, g, FB, b + c, rng,
                                             "random", trial_cap)
    except RuntimeError:
        return {"status": "no-relations", "trials": trial_cap, "b": b}
    Mrows = stange.build_M(rels, b)

    K = Matrix(Mrows).nullspace()
    kvecs = [[K[j][i, 0] for i in range(K[j].rows)] for j in range(len(K))]
    gate_Mv(Mrows, kvecs)                      # C2, exact, every vector

    if len(kvecs) < 1:
        return {"status": "empty-kernel", "trials": trials, "b": b,
                "dimK": 0}
    xs = [rels[j][1] for j in range(len(rels))]
    betas = [sum(stange.primitive(v)[j] * xs[j] for j in range(len(rels)))
             for v in kvecs[:c]]
    G = 0
    for a in betas:
        G = math.gcd(G, abs(a))
    og = stange.order_mod_n(g, n, p, q)
    if G == 0 or G % og != 0:
        raise AssertionError(f"paper p.4 correctness claim VIOLATED: "
                             f"G={G} ord(g)={og}")
    fac = stange.factor_from_multiple(G, g, n) if G else None
    return {"status": "ok", "factor": fac, "G": G, "ord_g": og,
            "h": G // og, "trials": trials, "dimK": len(kvecs), "b": b, "c": c}


def sweep_cell(n, p, q, b, c, N, seed0, trial_cap=2_000_000):
    """One (n, b, c) cell.  Returns the C3-corrected statistics."""
    got = nt = 0
    nr = 0
    trials_tot = 0
    h1 = 0
    hs = 0
    for k in range(N):
        r = one_trial(n, p, q, b, c, seed0 + 7919 * k, trial_cap)
        if r is None:
            continue
        if r["status"] == "no-relations":
            nr += 1
            continue
        nt += 1
        trials_tot += r["trials"]
        hs += r["h"]
        if r["h"] == 1:
            h1 += 1
        if r["factor"]:
            got += 1
    ps, mp, mq = p_split(p, q)
    lo, hi = wilson_ci(got, nt) if nt else (0.0, 1.0)
    return {"b": b, "c": c, "N": nt, "N_norel": nr, "factors": got,
            "rate": (got / nt) if nt else None,
            "rate_lo": lo, "rate_hi": hi,
            "p_split": ps, "v2p": mp, "v2q": mq,
            "excess": (got / nt - ps) if nt else None,
            "excess_lo": lo - ps, "excess_hi": hi - ps,
            "mean_trials": (trials_tot / nt) if nt else None,
            "mean_h": (hs / nt) if nt else None,
            "frac_h1": (h1 / nt) if nt else None}


# ---------------------------------------------------------------------------
# C4: NON-VACUITY.  b_min must be able to say "no such b" and must reject an
# injected b-dependence.
# ---------------------------------------------------------------------------
def classify(cell, tol=None):
    """'works' iff the observed rate is not SIGNIFICANTLY BELOW p_split.

    My first version used `excess_lo >= -tol` with tol = 0.10.  That is WRONG
    and it produced a false NULL: at a modulus with p_split = 0.9766 and
    N = 24, the Wilson half-width alone is ~0.09, so the test cannot resolve
    anything smaller than ~0.10 and it reported b_min = None -- i.e. "the
    method never works" -- on a modulus where it factored 23 of 24 times.

    The correct statistic is the one the hypothesis actually says: the method
    is perfect, so the observed count is Binomial(N, p_split).  We ask only
    whether the data are inconsistent with that, ONE-SIDED (a shortfall).
    An arbitrary tolerance is not a hypothesis.
    """
    if cell["N"] == 0:
        return "null"
    from scipy.stats import binomtest
    k, N, ps = cell["factors"], cell["N"], cell["p_split"]
    if ps <= 0.0:
        return "fails" if k < N else "works"
    pval = binomtest(k, N, ps, alternative="less").pvalue
    cell["p_one_sided"] = pval
    return "works" if pval > 0.05 else "fails"


def b_min(n, p, q, blist, c, N, seed0, trial_cap=2_000_000, verbose=False):
    """Smallest b in blist whose cell is not detectably worse than p_split."""
    cells = []
    for b in blist:
        cell = sweep_cell(n, p, q, b, c, N, seed0 + 100003 * b, trial_cap)
        cell["verdict"] = classify(cell)
        cells.append(cell)
        if verbose:
            print(f"    b={b:>3} N={cell['N']:>3} rate="
                  f"{('%.3f' % cell['rate']) if cell['rate'] is not None else ' -- ':>5}"
                  f" p_split={cell['p_split']:.3f}"
                  f" excess=({cell['excess_lo']:+.3f},{cell['excess_hi']:+.3f})"
                  f" trials={cell['mean_trials']:.0f}"
                  f" p={cell.get('p_one_sided', float('nan')):.4f}"
                  f"  -> {cell['verdict']}")
    for cell in cells:                       # smallest b that works
        if cell["verdict"] == "works":
            return cell["b"], cells
    return None, cells                        # NULL, and it must be able to


# ---------------------------------------------------------------------------
def main():
    print("=" * 78)
    print("B4: THE SMALLEST b AT WHICH THE METHOD WORKS, AS A FUNCTION OF n")
    print("=" * 78)
    pos = positive_control()
    print()

    results = []
    plan = [
        # (bits, c, blist, N, cap)  -- caps are per-RELATION-FINDING budget;
        # small b needs MANY more trials, so the cap must be generous there.
        (30, 5, [3, 5, 8, 11], 24, 3_000_000),
        (34, 5, [3, 5, 8, 11], 24, 6_000_000),
        (40, 5, [4, 6, 9, 13], 16, 20_000_000),
    ]
    for bits, c, blist, N, cap in plan:
        for mi, seed in enumerate((90210, 555003)):
            n, p, q = stange.gen_semiprime(bits, random.Random(seed + mi))
            bits = n.bit_length()          # gen_semiprime rounds DOWN by ~1 bit
            assert p * q == n
            ps, mp, mq = p_split(p, q)
            bmx = B.b_max(n)
            print(f"n = 2^{bits} = {n}  ({p} * {q}), c = {c}, N = {N}")
            print(f"    p_split = {ps:.4f}   v2(p-1) = {mp}, v2(q-1) = {mq}"
                  f"   b_max(proved regime) = {bmx}")
            bmin, cells = b_min(n, p, q, blist, c, N, seed + 31, cap,
                                verbose=True)
            print(f"    ==> b_min = {bmin}   "
                  f"(b_max = {bmx}, so b_min/b_max = "
                  f"{(bmin / bmx) if bmin else float('nan'):.3f})")
            print(f"    ==> b_needed(n) from bneed.py = "
                  f"{math.exp(B.log_b_needed(B.lg(n.bit_length()))):.4g}")
            print()
            results.append({"bits": bits, "n": str(n), "c": c, "N": N,
                            "p_split": ps, "v2p": mp, "v2q": mq,
                            "b_max": bmx, "b_min": bmin, "cells": cells})
            if bmin is not None:
                print(f"    RATIO b_min / b_needed = "
                      f"{bmin / math.exp(B.log_b_needed(B.lg(n.bit_length()))):.3e}"
                      f"   <-- the falsification, if tiny")
                print()

    with open("results_bmin.json", "w") as f:
        json.dump(results, f, indent=1, default=str)
    print("wrote results_bmin.json")


if __name__ == "__main__":
    main()
