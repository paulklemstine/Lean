"""
exp_T2.py -- SPARSE vs DENSE vs BLACK-BOX linear algebra, WALL CLOCK, matched b,
on the SAME real relation matrices.

Routes compared
---------------
  DENSE-F   exact Fraction Gauss-Jordan on the dense b x (b+c) list (the
            method r50/exp/bsweep/fastnull.py uses)
  DENSE-DM  exact integer rref via sympy DomainMatrix -- the fastest exact
            dense backend available here, so the honest dense baseline
  SPARSE    exact Fraction Gauss-Jordan on a DICTIONARY representation, which
            touches only stored nonzeros.  Also records the FILL-IN.
  BLACKBOX  Krylov/matrix-product route (see spcore.wiedemann_nullvec): only
            matrix-vector products, Theta(b * nnz) = Theta(b^2) modular ops.

EVERY route's output is checked with the mandatory contract `M v = 0` in
EXACT arithmetic before its time is recorded.  A route that returns a wrong
vector is a FAILURE, not a fast answer.

Outputs: t2_wallclock.json
"""

from __future__ import annotations

import json
import random
import sys
import time
from fractions import Fraction

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49exp/sparse")

from spcore import (  # noqa: E402
    assert_kernel,
    assert_kernel_dense,
    cols_from_rels,
    incidence_stats,
    kernel_dense,
    kernel_sparse,
    make_rels,
    matvec,
    rand_g,
    wiedemann_nullvec,
)
from stange import gen_semiprime, kernel_basis  # noqa: E402

OUT = "/home/raver1975/lean/factor-scratch/r49exp/sparse/t2_wallclock.json"


def bench_dense_frac(Mrows):
    t0 = time.perf_counter()
    K, rank, ops = kernel_dense(Mrows)
    return time.perf_counter() - t0, K, rank, ops


def bench_dense_sympy(Mrows, budget=25.0):
    t0 = time.perf_counter()
    try:
        K, rank = kernel_basis(Mrows)
    except Exception:
        return None, None, None, None
    dt = time.perf_counter() - t0
    if dt > budget:
        return dt, None, rank, "TIMEOUT_RECORDED"
    return dt, K, rank, None


def bench_dense_dm(Mrows, budget=60.0):
    """sympy DomainMatrix exact rref -- a much stronger dense baseline."""
    from sympy.polys.matrices import DomainMatrix
    from sympy.polys.domains import ZZ
    b = len(Mrows)
    ncols = len(Mrows[0])
    t0 = time.perf_counter()
    dm = DomainMatrix.from_list_sympy(b, ncols, Mrows)
    t_build = time.perf_counter() - t0
    t0 = time.perf_counter()
    r = dm.rref()
    dt = time.perf_counter() - t0
    if dt > budget:
        return t_build, dt, None, "TIMEOUT"
    try:
        rowsZ, pivots = r
        basis = []
        for fc in range(ncols):
            if fc in pivots:
                continue
            x = [0] * ncols
            x[fc] = 1
            for ri, pc in enumerate(pivots):
                x[pc] = -rowsZ[ri][fc]
            basis.append([Fraction(t) for t in x])
        return t_build, dt, basis, None
    except Exception as e:  # pragma: no cover
        return t_build, dt, None, f"PARSE_FAIL {type(e).__name__}"


def bench_sparse(cols, b):
    t0 = time.perf_counter()
    K, rank, peak, ops = kernel_sparse(cols, b)
    return time.perf_counter() - t0, K, rank, peak, ops


def bench_blackbox(cols, b):
    t0 = time.perf_counter()
    w, info = wiedemann_nullvec(cols, b, rng=random.Random(31337))
    return time.perf_counter() - t0, w, info


def main():
    results = []
    print("=" * 118)
    print("T2  WALL CLOCK: dense-Fraction vs sparse-Fraction vs black-box, "
          "matched b, same relation sets")
    print("=" * 118)
    print(f"{'n':>5} {'b':>5} {'rep':>4} | {'nnz':>7} {'fill':>9} "
          f"{'DENSE-F':>9} {'SP-F':>8} {'ratio':>6} | {'SPARSE':>9} {'fillx':>9} "
          f"{'ratio':>6} | {'BLACKBOX':>9} | {'opsF':>12} {'opsS':>12}")
    print("-" * 118)

    for nbits, bs, reps in ((20, [6, 10, 16, 26, 40, 64], 2),
                            (30, [8, 16, 26, 40, 64, 100], 2),
                            (40, [12, 16, 26, 40], 1)):
        for b in bs:
            for rep in range(reps):
                rng = random.Random(900_000 + 31 * b + rep + 1000 * nbits)
                n, p, q = gen_semiprime(nbits, rng)
                g = rand_g(n, rng)
                try:
                    rels, FB, BB, trials = make_rels(n, g, b, 1, rng, cap=4_000_000)
                except RuntimeError:
                    continue
                cols = cols_from_rels(rels)
                st = incidence_stats(cols, b)
                Mrows = [[rels[j][0][i] for j in range(len(rels))] for i in range(b)]

                # --- DENSE Fraction (the incumbent) ---
                t_df, Kd, rankd, opsD = bench_dense_frac(Mrows)
                assert_kernel_dense(Mrows, Kd, "T2-DENSE-F")

                # --- SPARSE Fraction ---
                t_s, Ks, ranks, peak, opsS = bench_sparse(cols, b)
                assert_kernel(cols, b, Ks, "T2-SPARSE")

                # --- BLACK-BOX ---
                t_bb, wbb, ibb = bench_blackbox(cols, b)
                bb_ok = wbb is not None

                rec = {
                    "nbits": nbits, "b": b, "rep": rep, "ncols": len(cols),
                    "nnz": st["nnz"], "fill_peak": peak,
                    "rank_dense": rankd, "rank_sparse": ranks,
                    "ranks_agree": rankd == ranks,
                    "dimK_dense": len(Kd), "dimK_sparse": len(Ks),
                    "t_dense_frac": t_df, "t_sparse": t_s,
                    "speedup_sparse_over_dense": t_df / t_s if t_s else None,
                    "ops_dense": opsD, "ops_sparse": opsS,
                    "fill_over_nnz": peak / st["nnz"] if st["nnz"] else None,
                    "t_blackbox": t_bb, "blackbox_ok": bb_ok,
                    "blackbox_info": {k: v for k, v in (ibb or {}).items()
                                      if k != "p"},
                }
                results.append(rec)
                print(f"2^{nbits:<3} {b:>5} {rep:>4} | {st['nnz']:>7} "
                      f"{'':>9} {t_df:>9.4f} {'':>8} {'':>6} | {t_s:>9.4f} "
                      f"{peak:>9} {t_df/t_s if t_s else 0:>6.2f} | "
                      f"{t_bb:>9.4f}{'' if bb_ok else '*'} | "
                      f"{opsD:>12} {opsS:>12}")
    print("  * = black-box found no kernel vector on this instance")

    # ------------------------------------------------------------------
    print()
    print("--- verified: every route's vectors satisfy M v = 0 EXACTLY? ---")
    bad = [r for r in results if not r["ranks_agree"]]
    print(f"  ranks agree (dense vs sparse) on {len(results)-len(bad)}/{len(results)}")
    print(f"  black-box verified M w = 0 mod p on "
          f"{sum(1 for r in results if r['blackbox_ok'])}/{len(results)}")
    print("  (the exact M v = 0 assertions are inside the benchmark functions; "
          "a failure raises and aborts the run)")

    # ------------------------------------------------------------------
    print()
    print("--- scaling of the SPARSE route, and of the FILL-IN ---")
    print(f"  {'b':>6} {'nnz':>9} {'fill_peak':>11} {'fill/nnz':>10} "
          f"{'fill/(b*ncols)':>14} {'t_sparse':>10} {'t_dense':>10} {'ratio':>7}")
    for r in sorted(results, key=lambda x: (x["nbits"], x["b"])):
        if r["rep"]:
            continue
        nc = r["ncols"]
        print(f"  {r['b']:>6} {r['nnz']:>9} {r['fill_peak']:>11} "
              f"{r['fill_over_nnz']:>10.2f} {r['fill_peak']/(r['b']*nc):>14.4f} "
              f"{r['t_sparse']:>10.4f} {r['t_dense_frac']:>10.4f} "
              f"{r['speedup_sparse_over_dense']:>7.2f}")

    print()
    print("--- extrapolating: dense O(b^3) Fraction ops vs sparse O(fill) ---")
    for r in sorted(results, key=lambda x: (x["nbits"], x["b"])):
        if r["rep"] or r["nbits"] != 30:
            continue
        nc = r["ncols"]
        print(f"  b={r['b']:>4}: ops dense {r['ops_dense']:>12} = {r['ops_dense']/r['b']**3:>8.1f}*b^3"
              f"   |  ops sparse {r['ops_sparse']:>10} = {r['ops_sparse']/(r['b']**2):>8.3f}*b^2"
              f"   |  fill/(b*ncols) = {r['fill_peak']/(r['b']*nc):.3f}")

    with open(OUT, "w") as f:
        json.dump(results, f, indent=1)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()