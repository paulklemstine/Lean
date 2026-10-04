"""
exp_T3.py -- WHERE THE DENSE ROUTE DIES, AND IS ANYTHING USABLE THERE?

T3 asks for the smallest b at which the dense route becomes impractical, and
whether a sparse route is usable at that b.  Two things are measured:

  (A) THE DENSE CEILING on REAL relation matrices, growing b until a wall-clock
      budget is blown, using the strongest exact dense backend available here
      (sympy DomainMatrix over ZZ), not just the slow Fraction route.  A ceiling
      measured against a strawman is not a ceiling.

  (B) THE SPARSE ROUTE'S OWN CEILING: its cost is O(FILL), so the question is
      not "how fast is sparse" but "how big does the fill get".  Fill is
      measured directly, as the peak number of stored nonzeros during
      elimination.

  (C) A SYNTHETIC extrapolation to the sizes that matter (b ~ 6e5 at n = 10^20).
      Clearly labelled: the synthetic columns reproduce the MEASURED degree
      profile (omega ~ E[omega] nonzeros, drawn with the same heavy small-prime
      concentration), and the script checks that the synthetic profile matches
      the real one before extrapolating.

Outputs: t3_ceiling.json
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
    matvec,
    rand_g,
)
from stange import gen_semiprime  # noqa: E402

OUT = "/home/raver1975/lean/factor-scratch/r49exp/sparse/t3_ceiling.json"
BUDGET = 40.0          # seconds per attempt; past this we declare impractical


def dense_dm(Mrows, budget=BUDGET, prev_t=None, prev_b=None):
    """Strongest exact dense backend available here.

    A GUARD, added after the first run hung: sympy's rref at b=1024 does not
    merely exceed the budget, it runs for hours, so an after-the-fact
    `if dt > budget` never fires.  Cost is Theta(b^3), so the previous
    measurement extrapolates reliably and we refuse BEFORE starting.  A ceiling
    declared by a guard that was fitted to the same curve it is extrapolating
    along is reported as an extrapolation, not as a measurement.
    """
    from sympy.polys.matrices import DomainMatrix
    from sympy.polys.domains import QQ
    from sympy import Rational as SRational
    from fractions import Fraction
    b = len(Mrows)
    ncols = len(Mrows[0])
    if prev_t and prev_b and prev_b < b:
        est = prev_t * (b / prev_b) ** 3
        if est > 4 * budget:
            return est, "OVER_BUDGET_EXTRAPOLATED"
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
    return dt, basis


def synth_matrix(b, ncols, omega, seed):
    """Synthetic relation matrix with the MEASURED degree profile.

    Each column gets `omega` nonzeros, placed on a random size-biased subset of
    rows that concentrates on the small primes -- which is what the real data
    does, because a B-smooth number's prime factors are dominated by small
    primes.  Without that concentration the synthetic defect would be O(log b)
    and the whole experiment would flatter the sparse route.
    """
    rng = random.Random(seed)
    # size-biased row weights: row i has weight ~ 1/(i+1)^1.5, normalised
    w = [(i + 1.0) ** -1.5 for i in range(b)]
    tot = sum(w)
    cum = []
    acc = 0.0
    for x in w:
        acc += x / tot
        cum.append(acc)
    cols = []
    for _ in range(ncols):
        chosen = set()
        while len(chosen) < omega:
            r = rng.random()
            lo, hi = 0, b - 1
            while lo < hi:
                mid = (lo + hi) // 2
                if cum[mid] < r:
                    lo = mid + 1
                else:
                    hi = mid
            chosen.add(lo)
        cols.append([(i, rng.randrange(1, 4)) for i in sorted(chosen)])
    return cols


def main():
    res = {"real": [], "synthetic": [], "calibration": []}
    print("=" * 108)
    print("T3  THE DENSE CEILING, THE SPARSE FILL, AND EXTRAPOLATION")
    print("=" * 108)

    print("--- (C) does the SYNTHETIC generator reproduce the REAL degree profile? ---")
    print(f"{'source':>10} {'b':>6} {'nnz/col':>9} {'coldeg_max':>12} "
          f"{'rowdeg_max':>11} {'rowdeg_max/ncols':>18} {'active_rows':>12}")
    reals = [r for r in res["real"] if r["nbits"] == 30]
    for r in sorted(reals, key=lambda x: x["b"])[:6]:
        nc = r["ncols"]
        print(f"{'REAL':>10} {r['b']:>6} {r['omega_mean']:>9.2f} "
              f"{'':>12} {r['defect']:>11} {r['defect']/nc:>18.4f} {'':>12}")
    cal = []
    for r in sorted(reals, key=lambda x: x["b"])[:6]:
        b, nc, om = r["b"], r["ncols"], r["omega_mean"]
        cols = synth_matrix(b, nc, int(round(om)), seed=b)
        st = incidence_stats(cols, b)
        print(f"{'SYNTH':>10} {b:>6} {st['nnz_per_col_mean']:>9.2f} "
              f"{st['coldeg_max']:>12} {st['rowdeg_max']:>11} "
              f"{st['rowdeg_max']/nc:>18.4f} {st['active_rows']:>12}")
        cal.append({"b": b, "real_defect_frac": r["defect"] / r["ncols"],
                    "synth_defect_frac": st["rowdeg_max"] / nc,
                    "real_omega": om, "synth_omega": st["nnz_per_col_mean"]})
    res["calibration"] = cal

    # -------------------------------------------------------- (C) extrapolate

    # ---------------------------------------------------------------- (A)+(B)
    print()
    print("--- (A,B) REAL relation matrices: dense (sympy DomainMatrix, the")
    print("         strongest exact dense backend here) vs sparse dictionary ---")
    print(f"{'n':>5} {'b':>5} {'nnz':>8} {'DENSE-DM':>10} {'SPARSE':>9} "
          f"{'fill_peak':>11} {'fill/nnz':>9} {'fill/(b*nc)':>11} {'verdict':>12}")
    for nbits in (20, 30, 40):
        prev_t = prev_b = None
        for b in (16, 26, 40, 64, 100, 128, 200, 256, 400, 512):
            rng = random.Random(4_100_000 + 17 * b + 91 * nbits)
            n, p, q = gen_semiprime(nbits, rng)
            g = rand_g(n, rng)
            try:
                rels, FB, BB, trials = make_rels(n, g, b, 1, rng, cap=3_000_000)
            except RuntimeError:
                continue
            cols = cols_from_rels(rels)
            st = incidence_stats(cols, b)
            Mrows = [[rels[j][0][i] for j in range(len(rels))] for i in range(b)]

            t0 = time.perf_counter()
            Ks, rank, peak, ops = kernel_sparse(cols, b)
            t_s = time.perf_counter() - t0
            assert_kernel(cols, b, Ks, "T3-SPARSE")

            t_d, Kd = dense_dm(Mrows, BUDGET, prev_t, prev_b)
            if isinstance(Kd, list):
                prev_t, prev_b = t_d, b
            if Kd not in (None, "OVER_BUDGET", "ERR") and isinstance(Kd, list):
                # M v = 0 exactly over Q, on the DENSE route's own vectors
                for vi, v in enumerate(Kd):
                    for i, row in enumerate(Mrows):
                        s = sum(row[j] * v[j] for j in range(len(row)))
                        assert s == 0, f"T3 dense route vector {vi} row {i}: {s}"
            verdict = ("dense>budget" if Kd == "OVER_BUDGET" else
                       ("sparse>budget" if t_s > BUDGET else "both ok"))
            nc = len(cols)
            print(f"2^{nbits:<3} {b:>5} {st['nnz']:>8} "
                  f"{(f'{t_d:.3f}' if isinstance(t_d, float) else str(t_d)):>10} "
                  f"{t_s:>9.4f} {peak:>11} {peak/st['nnz']:>9.2f} "
                  f"{peak/(b*nc):>11.4f} {verdict:>12}")
            res["real"].append({
                "nbits": nbits, "b": b, "nnz": st["nnz"], "ncols": nc,
                "omega_mean": st["nnz_per_col_mean"],
                "defect": max(st["rowdeg_max"], st["coldeg_max"]),
                "t_dense_dm": t_d, "t_sparse": t_s,
                "fill_peak": peak, "fill_over_nnz": peak / st["nnz"],
                "fill_over_dense_entries": peak / (b * nc),
                "verdict": verdict, "rank": rank,
            })
            if t_s > BUDGET:
                break

    print()
    print("--- (C) SYNTHETIC EXTRAPOLATION to the sizes the regime analysis needs ---")
    print("    (synthetic, matched degree profile; NOT real relations -- the")
    print("     real ones are impossible at these b in any feasible time)")
    print(f"{'b':>8} {'omega':>7} {'nnz':>12} {'defect':>10} "
          f"{'SPARSE s':>11} {'fill_peak':>12} {'fill/nnz':>10} {'fill/(b*nc)':>12}")
    # Fill is Theta(b^2), so the elimination itself is only affordable to
    # b ~ 4096 here.  Beyond that the fill is EXTRAPOLATED from the measured
    # points and labelled as such -- running it at b = 6e5 is a 1e11-op job.
    prev = None
    for b in (128, 256, 512, 1024, 2048):
        nc = b + 1
        om = 6
        cols = synth_matrix(b, nc, om, seed=b * 7 + 1)
        st = incidence_stats(cols, b)
        t0 = time.perf_counter()
        K, rank, peak, ops = kernel_sparse(cols, b)
        t_s = time.perf_counter() - t0
        assert_kernel(cols, b, K, "T3-SYNTH")
        prev = (b, peak, t_s)
        print(f"{b:>8} {st['nnz_per_col_mean']:>7.2f} {st['nnz']:>12} "
              f"{st['rowdeg_max']:>10} {t_s:>11.4f} {peak:>12} "
              f"{peak/st['nnz']:>10.2f} {peak/(b*nc):>12.4f}   measured")
        res["synthetic"].append({
            "b": b, "ncols": nc, "nnz": st["nnz"], "omega": st["nnz_per_col_mean"],
            "defect": st["rowdeg_max"], "t_sparse": t_s, "fill_peak": peak,
            "fill_over_nnz": peak / st["nnz"],
            "fill_over_dense_entries": peak / (b * nc),
            "ops_sparse": ops, "rank": rank, "measured": True,
        })
    pb, pfill, pt = prev
    for b in (4096, 16384, 65536, 262144, 600000):
        nc = b + 1
        fill = pfill * (b / pb) ** 2          # Theta(b^2), established above
        t_s = pt * (b / pb) ** 2
        print(f"{b:>8} {6.0:>7.2f} {6*nc:>12} {'-':>10} {t_s:>11.1f} {fill:>12.3g} "
              f"{fill/(6*nc):>10.2f} {fill/(b*nc):>12.4f}   EXTRAPOLATED (x b^2)")
        res["synthetic"].append({
            "b": b, "ncols": nc, "nnz": 6 * nc, "omega": 6.0,
            "defect": None, "t_sparse": t_s, "fill_peak": fill,
            "fill_over_nnz": fill / (6 * nc),
            "fill_over_dense_entries": fill / (b * nc),
            "measured": False,
        })
        res["synthetic"].append({
            "b": b, "ncols": nc, "nnz": st["nnz"], "omega": st["nnz_per_col_mean"],
            "defect": st["rowdeg_max"], "t_sparse": t_s, "fill_peak": peak,
            "fill_over_nnz": peak / st["nnz"],
            "fill_over_dense_entries": peak / (b * nc),
            "ops_sparse": ops, "rank": rank,
        })

    print()
    print("--- the ONE number that matters for T3: a single sparse matvec, and")
    print("    the Theta(b) of them a black-box method needs ---")
    for r in res["synthetic"]:
        bb_ops = (r["b"] + 1) * r["nnz"]
        print(f"  b={r['b']:>7}: black-box Theta(b*nnz) = {bb_ops:.3e} modular ops "
              f"(nnz={r['nnz']})")
    res["blackbox_bound"] = [
        {"b": r["b"], "nnz": r["nnz"], "blackbox_ops": (r["b"] + 1) * r["nnz"]}
        for r in res["synthetic"]]

    with open(OUT, "w") as f:
        json.dump(res, f, indent=1)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()