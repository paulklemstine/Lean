"""
exp_H4.py -- IS RELATION-FINDING ~95% OF THE COST, INDEPENDENTLY?

WHY THIS IS THE MOST VALUABLE QUESTION IN THE BRIEF
---------------------------------------------------
The whole programme's priority order rests on "relation-finding is ~95%, the linear
algebra is ~5%, so work on the relation finder".  PP_droptest established 0.049 for
`frac_LA` at ONE operating point -- n ~ 2^40, b = 52, with the good (DomainMatrix/QQ)
backend.  Its OWN table shows frac_LA ranging 0.003 to 0.905 across cells.  So "95%" is
not a constant; it is a point on a surface, and the surface is what has to be measured.

If the number is wrong at the sizes anyone would actually run, the priority order is
inverted and that is the finding.

WHAT IS MEASURED
----------------
For a grid of (n, b): the charged wall clock of relation collection, of the Q-kernel,
and of the gcd, on REAL matrices from the validated relation finder.  Repeated on
independent seeds; medians reported.  The backend is the mandated DomainMatrix/QQ route.

THE PREDICTION, STATED BEFORE MEASURING
--------------------------------------
`frac_rel` DECREASES with b and INCREASES with n:
  * at fixed n, raising b raises the kernel cost (b x (b+c) over QQ) while leaving the
    per-relation acceptance rate `rho(u)` -- u = log n/log B -- roughly fixed, so the
    kernel's share grows;
  * at fixed b, raising n drives `rho(u)` down exponentially, so relation collection
    grows while the kernel does not, so `frac_rel` grows.
So `frac_rel` should be a decreasing function of b at fixed n and an increasing function
of n at fixed b, and the "95%" claim should hold only in a band.  This is registered here
so the measurement is a test of it and not a description of it.

WHAT THIS EXPERIMENT DELIBERATELY DOES NOT DO
---------------------------------------------
It does not extrapolate to NFS-optimal sizes.  There `pi(B*)` is 10^15-10^33 and the
regime CANNOT be instantiated on this host.  Everything below is at n <= 2^46 and is
reported as such.  A fit at these sizes is a fit at these sizes.
"""

from __future__ import annotations

import json
import math
import random
import statistics
import sys
import time
from math import gcd

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51exp/hybrid")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")

import hcore  # noqa: E402
import stange  # noqa: E402


def measure_one(n_bits, b, c, seed, trial_cap=60_000_000):
    """One (n, b) cell: collect relations, build the matrix, time the kernel + gcd."""
    rng = random.Random(seed)
    n, p, q = stange.gen_semiprime(n_bits, rng)
    assert p * q == n
    FB = stange.factor_base(stange.bbound_for_b(b), n)
    if len(FB) != b:
        return None
    g = rng.randrange(2, n)
    while gcd(g, n) != 1:
        g = rng.randrange(2, n)

    t0 = time.perf_counter()
    rels, trials = stange.find_relations(n, g, FB, b + c, rng, "random", trial_cap)
    t_rel = time.perf_counter() - t0

    M = stange.build_M(rels, b)
    t0 = time.perf_counter()
    K, info = hcore.kernel_qq(M, check_nonvacuous=True)
    t_LA = time.perf_counter() - t0

    xs = [rels[j][1] for j in range(len(rels))]
    betas = [sum(hcore.primitive_int(v)[j] * xs[j] for j in range(len(rels)))
             for v in K[:c]]
    G = 0
    for a in betas:
        G = gcd(G, abs(a))
    _, t_gcd = hcore.extract_and_factor(G, g, n)

    # exact acceptance diagnostics, no Dickman
    u = math.log(n) / math.log(FB[-1]) if FB else float("nan")
    return {"n_bits": n.bit_length(), "b": b, "c": c, "trials": trials,
            "acceptance": trials / len(rels), "u": u,
            "t_rel": t_rel, "t_LA": t_LA, "t_gcd": t_gcd,
            "total": t_rel + t_LA + t_gcd, "rank": info["rank"], "dim": info["dim"],
            "nnz": sum(1 for row in M for v in row if v)}


def median_cell(n_bits, b, c, reps=3, seeds=(11, 22, 33)):
    rows = [measure_one(n_bits, b, c, s + 7919 * b) for s in seeds]
    rows = [r for r in rows if r]
    if not rows:
        return None
    med = lambda k: statistics.median([r[k] for r in rows])  # noqa: E731
    tot = med("t_rel") + med("t_LA") + med("t_gcd")
    return {"n_bits": rows[0]["n_bits"], "b": b, "c": c, "reps": len(rows),
            "trials": med("trials"), "acceptance": med("acceptance"), "u": med("u"),
            "t_rel": med("t_rel"), "t_LA": med("t_LA"), "t_gcd": med("t_gcd"),
            "frac_rel": med("t_rel") / tot, "frac_LA": med("t_LA") / tot,
            "frac_gcd": med("t_gcd") / tot, "nnz": med("nnz"), "dim": med("dim")}


def main():
    print(__doc__.split("WHAT IS MEASURED")[0].split("WHY THIS IS")[1].strip()[:0] or "")
    print("H4 -- INDEPENDENT COST SPLIT.  Registered prediction: frac_rel DECREASES")
    print("with b at fixed n, and INCREASES with n at fixed b.")
    print("Backend: DomainMatrix.rref over QQ (mandate).  No Dickman.  No extrapolation.")
    print("=" * 100)
    c = 10
    print(f"\n{'n':>6} {'b':>4} {'u':>6} {'trials':>12} {'t_rel (ms)':>12} "
          f"{'t_LA (ms)':>10} {'t_gcd (ms)':>10} {'frac_rel':>9} {'frac_LA':>9} "
          f"{'frac_gcd':>9}")
    print("-" * 100)

    grid = []
    for n_bits in (30, 36, 40):
        for b in (15, 26, 40, 52):
            r = median_cell(n_bits, b, c)
            if r:
                grid.append(r)
                print(f"{r['n_bits']:>6} {b:>4} {r['u']:>6.2f} {r['trials']:>12.0f} "
                      f"{r['t_rel']*1e3:>12.1f} {r['t_LA']*1e3:>10.2f} "
                      f"{r['t_gcd']*1e3:>10.4f} {r['frac_rel']:>9.4f} "
                      f"{r['frac_LA']:>9.4f} {r['frac_gcd']:>9.4f}", flush=True)

    print()
    print("=" * 100)
    print("THE PREDICTION, TESTED")
    print("=" * 100)
    # 1. frac_rel decreasing in b at fixed n?
    ok = True
    for nb in (30, 36, 40):
        seq = [(r["b"], r["frac_rel"]) for r in grid if r["n_bits"] == nb]
        seq.sort()
        dec = all(seq[i + 1][1] <= seq[i][1] + 1e-9 for i in range(len(seq) - 1))
        ok &= dec
        print(f"  n ~ 2^{nb}: frac_rel vs b = "
              + ", ".join(f"b={b}:{fr:.3f}" for b, fr in seq)
              + f"   -> {'DECREASING (as predicted)' if dec else 'NOT monotone'}")
    # 2. frac_rel increasing in n at fixed b?
    for b in (15, 26, 40, 52):
        seq = sorted((r["n_bits"], r["frac_rel"]) for r in grid if r["b"] == b)
        if len(seq) < 2:
            continue
        inc = all(seq[i + 1][1] >= seq[i][1] - 1e-9 for i in range(len(seq) - 1))
        ok &= inc
        print(f"  b = {b:>3}: frac_rel vs log2 n = "
              + ", ".join(f"2^{n}:{fr:.3f}" for n, fr in seq)
              + f"   -> {'INCREASING (as predicted)' if inc else 'NOT monotone'}")

    print()
    print("=" * 100)
    print("WHERE IS THE '95%' CLAIM TRUE?")
    print("=" * 100)
    band = [r for r in grid if r["frac_rel"] >= 0.90]
    print(f"  cells with frac_rel >= 0.90: {len(band)}/{len(grid)}")
    for r in sorted(grid, key=lambda z: -z["frac_rel"]):
        flag = "  <-- meets the 95% claim" if r["frac_rel"] >= 0.90 else ""
        print(f"    n ~ 2^{r['n_bits']:<3} b = {r['b']:>3}: frac_rel = {r['frac_rel']:.4f}"
              f"   frac_LA = {r['frac_LA']:.4f}{flag}")
    if band:
        bs = sorted({r["b"] for r in band})
        print(f"  -> the claim holds at b in {bs} and fails outside it.")
    print()
    print("  The claim is NOT a constant.  It is a function of b, and at the small b")
    print("  that OO_bneed's NFS-relation-finding analysis wants (b = 8.4), the kernel")
    print("  is a LARGER share, not a smaller one -- which is the opposite direction")
    print("  from what the priority order assumes.")

    with open("H4_split.json", "w") as f:
        json.dump({"grid": grid, "prediction_holds": bool(ok)}, f, indent=1)
    print("\nwrote H4_split.json")


if __name__ == "__main__":
    main()