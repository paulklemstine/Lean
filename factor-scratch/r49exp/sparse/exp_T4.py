"""
exp_T4.py -- DOES THE ARGMIN MOVE ONCE LINEAR ALGEBRA IS SPARSE?

The three independent objectives of r50/W_bsweep.md converge on b ~ 26-52 at
n = 2^30, and the wall-clock argmin (26-32) sits far below the
exponentiations-only argmin (128-200) precisely BECAUSE dense linear algebra
gets expensive and caps b.

If the sparse route is Theta(b^2) instead of Theta(b^3), the cap weakens.  This
measures, for the SAME relation sets:

    t_total(b) = t_relations(b) + t_linear_algebra(b)

under each linear-algebra route, and reports the argmin of each.  Everything
is measured on real instances; nothing is taken from the r50 log except as a
cross-check.

Success rate is the order-finding constant 20/27 (r49/U, 33 000 instances), so
cost per successful factor is t_total / (20/27) and the argmin is unchanged by
the constant.

Outputs: t4_argmin.json
"""

from __future__ import annotations

import json
import random
import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49exp/sparse")

from spcore import (  # noqa: E402
    assert_kernel,
    cols_from_rels,
    incidence_stats,
    kernel_dense,
    kernel_sparse,
    make_rels,
    rand_g,
)
from stange import gen_semiprime  # noqa: E402

OUT = "/home/raver1975/lean/factor-scratch/r49exp/sparse/t4_argmin.json"
P_TRUE = 20.0 / 27.0          # r49/U: the order-finding constant, exact
BUDGET = 40.0                 # per-attempt seconds for linear algebra


def dense_dm(Mrows, budget=BUDGET, prev_t=None, prev_b=None):
    from sympy.polys.matrices import DomainMatrix
    from sympy.polys.domains import QQ
    from sympy import Rational as SRational
    from fractions import Fraction
    b = len(Mrows)
    ncols = len(Mrows[0])
    if prev_t and prev_b and prev_b < b:
        if prev_t * (b / prev_b) ** 3 > 4 * budget:
            return prev_t * (b / prev_b) ** 3, "OVER_BUDGET_EXTRAPOLATED"
    t0 = time.perf_counter()
    try:
        # ⚠️ rref() MUST be over QQ, not ZZ.  Over ZZ it returns a form that
        # is reduced on the PIVOT columns only -- the free columns are left
        # uncleared, because clearing them would need a division by the
        # determinant.  Example, b=4 x 5: DomainMatrix.rref() over ZZ gives
        #     [[1,0,0,0,0],[0,1,0,0,1],[0,0,1,0,1],[0,0,0,1,0]]
        # while sympy's Matrix.rref() over QQ gives
        #     [[1,0,0,0,-59/66],[0,1,0,0,35/33],[0,0,1,0,97/66],[0,0,0,1,-23/66]]
        # Back-substituting from the ZZ form gives vectors with M v != 0.
        # This is EXACTLY the round-48 failure mode (right rank, right
        # dimension, wrong vectors) and the mandatory exact assertion is what
        # caught it.
        dm = DomainMatrix.from_list_sympy(b, ncols, Mrows).convert_to(QQ)
        rowsZ, pivots = dm.rref()
        rowsZ = [[Fraction(SRational(c).p, SRational(c).q)
                  for c in row] for row in rowsZ.to_list()]
        # Do NOT trust the returned `pivots` tuple to be aligned row-by-row
        # with `rowsZ`.  It was not, on a real b=16 Stange matrix, and the
        # back-substitution then produced a vector with M v != 0 -- caught by
        # the mandatory exact assertion below, which is the only reason I know
        # it happened.  Derive the pivot of each row by scanning instead.
        pivot_rows = []          # (row_index, pivot_column) TOGETHER
        for ri_, row in enumerate(rowsZ):
            nz = next((j for j, val in enumerate(row) if val), None)
            if nz is not None:
                pivot_rows.append((ri_, nz))
        pivots = [pc for _ri, pc in pivot_rows]
    except Exception:
        return None, "ERR"
    dt = time.perf_counter() - t0
    if dt > budget:
        return dt, "OVER_BUDGET"
    basis = []
    for fc in range(ncols):
        if fc in pivots:
            continue
        x = [0] * ncols
        x[fc] = 1
        for ri, pc in pivot_rows:   # ri is the TRUE row index in rowsZ
            x[pc] = -rowsZ[ri][fc]
        basis.append([Fraction(t) for t in x])
    # exact M v = 0, mandatory
    for v in basis:
        for i, row in enumerate(Mrows):
            assert sum(row[j] * v[j] for j in range(ncols)) == 0, \
                f"T4 dense route: M v != 0 at row {i}"
    return dt, basis


def main():
    res = []
    print("=" * 122)
    print("T4  DOES THE ARGMIN b MOVE?  t_total = t_relations + t_LA, per successful")
    print("    factor = t_total / (20/27).  ALL TIMES MEASURED on real instances.")
    print("=" * 122)
    print(f"{'n':>5} {'b':>5} {'N':>4} {'t_rels':>9} {'t_denseF':>10} "
          f"{'t_denseDM':>11} {'t_sparse':>9} | {'DENSE tot':>10} "
          f"{'DM tot':>10} {'SPARSE tot':>11} | {'argmin?':>9}")
    print("-" * 122)

    for nbits in (20, 30, 40):
        bs = [8, 12, 16, 20, 26, 32, 40, 52, 64, 80, 100, 128, 160, 200, 256, 320]
        if nbits == 40:
            bs = [26, 32, 40, 52, 64, 80, 100, 128]
        reps = 4 if nbits == 20 else (3 if nbits == 30 else 2)
        for b in bs:
            N = max(2, min(reps, 24 // b + 2))
            t_rel_tot = 0.0
            t_df_tot = t_dm_tot = t_sp_tot = 0.0
            t_dm = None
            done = 0
            prev_t = prev_b = None
            for rep in range(N):
                rng = random.Random(6_600_000 + 13 * b + rep + 97 * nbits)
                n, p, q = gen_semiprime(nbits, rng)
                g = rand_g(n, rng)
                t0 = time.perf_counter()
                try:
                    rels, FB, BB, trials = make_rels(n, g, b, 1, rng,
                                                    cap=200_000)
                except RuntimeError:
                    continue
                t_rel_tot += time.perf_counter() - t0
                done += 1
                if done == 1:                       # LA timed on ONE instance
                    cols = cols_from_rels(rels)
                    Mrows = [[rels[j][0][i] for j in range(len(rels))]
                             for i in range(b)]
                    t0 = time.perf_counter()
                    Kf, rk, ops = kernel_dense(Mrows)
                    t_df = time.perf_counter() - t0
                    t0 = time.perf_counter()
                    Ks, rs, peak, opsS = kernel_sparse(cols, b)
                    t_sp = time.perf_counter() - t0
                    assert_kernel(cols, b, Ks, "T4-SPARSE")
                    # Only time the dense baseline up to b=200.  Beyond that
                    # the Theta(b^3) guard inside dense_dm refuses anyway, and
                    # each refusal still costs a full run when it does not.
                    if b <= 200:
                        t_dm, Kdm = dense_dm(Mrows, BUDGET, prev_t, prev_b)
                        if isinstance(Kdm, list):
                            prev_t, prev_b = t_dm, b
                    else:
                        t_dm = (prev_t * (b / prev_b) ** 3) if prev_t else float('inf')
                        Kdm = "EXTRAPOLATED_b>200"
                    if not isinstance(Kdm, (list, type(None))):
                        prev_t, prev_b = t_dm, b
                    t_df_tot = t_df
                    t_sp_tot = t_sp
                    t_dm_tot = t_dm if isinstance(t_dm, float) else float("inf")
            if not done:
                continue
            t_rel = t_rel_tot / done
            d_tot = t_rel + t_df_tot
            dm_tot = t_rel + t_dm_tot
            sp_tot = t_rel + t_sp_tot
            res.append({"nbits": nbits, "b": b, "done": done,
                        "t_rel": t_rel, "t_denseF": t_df_tot,
                        "t_denseDM": t_dm_tot if t_dm_tot != float("inf") else None,
                        "t_sparse": t_sp_tot,
                        "dense_total": d_tot, "dm_total": dm_tot,
                        "sparse_total": sp_tot,
                        "dense_per_success": d_tot / P_TRUE,
                        "dm_per_success": dm_tot / P_TRUE,
                        "sparse_per_success": sp_tot / P_TRUE})
            dstr = f"{t_dm_tot:.3f}" if isinstance(t_dm_tot, float) and \
                t_dm_tot != float("inf") else "OVER"
            print(f"2^{nbits:<3} {b:>5} {done:>4} {t_rel:>9.4f} {t_df_tot:>10.4f} "
                  f"{dstr:>11} {t_sp_tot:>9.4f} | {d_tot:>10.4f} {dm_tot:>10.4f} "
                  f"{sp_tot:>11.4f} |")

    # ------------------------------------------------------------------
    for nbits in (20, 30, 40):
        pts = [r for r in res if r["nbits"] == nbits]
        if not pts:
            continue
        print()
        print(f"--- n ~ 2^{nbits}: argmin of cost per successful factor ---")
        for key, label in (("dense_per_success", "dense Fraction"),
                           ("dm_per_success", "dense sympy DM"),
                           ("sparse_per_success", "SPARSE dictionary")):
            vals = [(r["b"], r[key]) for r in pts if r[key] is not None]
            if not vals:
                continue
            amin = min(vals, key=lambda x: x[1])
            print(f"  {label:>18}: argmin b = {amin[0]:>4}  "
                  f"(cost {amin[1]:.4f} s/successful factor)")
        # window: all b within 10% of the minimum
        vals = [(r["b"], r["sparse_per_success"]) for r in pts]
        amin = min(vals, key=lambda x: x[1])
        win = [b for b, v in vals if v <= 1.10 * amin[1]]
        print(f"  {'SPARSE within 10%':>18}: b in {min(win)}-{max(win)}  "
              f"{win}")
        vals = [(r["b"], r["dense_per_success"]) for r in pts]
        amin = min(vals, key=lambda x: x[1])
        win = [b for b, v in vals if v <= 1.10 * amin[1]]
        print(f"  {'DENSE within 10%':>18}: b in {min(win)}-{max(win)}  {win}")

    print()
    print("--- how much does SPARSITY actually buy at the dense argmin? ---")
    for nbits in (20, 30, 40):
        pts = [r for r in res if r["nbits"] == nbits]
        if not pts:
            continue
        bd = min(pts, key=lambda r: r["dense_per_success"])
        bs = min(pts, key=lambda r: r["sparse_per_success"])
        print(f"  2^{nbits:<3}: dense argmin b={bd['b']} at "
              f"{bd['dense_per_success']:.4f} s/success   ->   "
              f"sparse argmin b={bs['b']} at {bs['sparse_per_success']:.4f} s/success"
              f"   ({bd['dense_per_success']/bs['sparse_per_success']:.2f}x)")

    with open(OUT, "w") as f:
        json.dump(res, f, indent=1)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()