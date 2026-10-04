"""
exp_T1.py -- SPARSITY AND DEFECT OF THE Stange b x (b+c) MATRIX.

The question T1 asks decides whether the whole sparse-linear-algebra axis is
viable, so this measures BEFORE optimising anything, on REAL relation sets
produced by r48's own (validated) relation finder.

Outputs: sparsity_T1.json
"""

from __future__ import annotations

import json
import random
import sys
import time
from math import gcd

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49exp/sparse")

from spcore import (  # noqa: E402
    bbound_for_b,
    cols_from_rels,
    defect_is_permutation_invariant,
    defect_of,
    factor_base,
    find_relations,
    gen_semiprime,
    incidence_stats,
    make_rels,
    psi_ratio_2,
    rand_g,
)
from stange import fb_exponents  # noqa: E402

OUT = "/home/raver1975/lean/factor-scratch/r49exp/sparse/sparsity_T1.json"


def run(nbits, b, c, reps, seed0, cap=6_000_000):
    rows = []
    for rep in range(reps):
        rng = random.Random(seed0 + 1000 * rep)
        n, p, q = gen_semiprime(nbits, rng)
        g = rand_g(n, rng)
        t0 = time.perf_counter()
        try:
            rels, FB, BB, trials = make_rels(n, g, b, c, rng, cap=cap)
        except RuntimeError as e:
            rows.append({"nbits": nbits, "b": b, "c": c, "rep": rep,
                         "error": str(e)})
            continue
        t_rel = time.perf_counter() - t0
        cols = cols_from_rels(rels)
        st = incidence_stats(cols, b)
        inv, vals = defect_is_permutation_invariant(cols, b, trials=5, rng=rng)
        rows.append({
            "nbits": nbits, "b": b, "c": c, "rep": rep, "n": n,
            "BB": BB, "rels": len(rels), "trials": trials,
            "t_rel": t_rel,
            "nnz": st["nnz"],
            "density": st["density"],
            "nnz_per_col_mean": st["nnz_per_col_mean"],
            "coldeg_max": st["coldeg_max"],
            "rowdeg_max": st["rowdeg_max"],
            "rowdeg_max_frac": st["rowdeg_max_frac"],
            "active_rows": st["active_rows"],
            "heavy_rows": st["heavy_rows"],
            "top_rows": st["top_rows"][:8],
            "defect": defect_of(st["rowdeg"], st["coldeg"]),
            "defect_perm_invariant": inv,
            "defect_values": vals,
            # rowdeg of the SMALLEST primes -- the mechanism, not just the max
            "rowdeg_first8": st["rowdeg"][:8],
        })
    return rows


def main():
    all_rows = []
    print("=" * 100)
    print("T1  SPARSITY AND DEFECT OF THE Stange RELATION MATRIX  (real relations, c=1)")
    print("=" * 100)

    for nbits, bs, reps in ((20, [6, 10, 16, 26, 40], 4),
                            (30, [6, 16, 26, 40, 64, 100, 128], 3),
                            (40, [16, 26, 40, 64, 100], 2)):
        for b in bs:
            t0 = time.perf_counter()
            rr = run(nbits, b, 1, reps, seed0=50_000 + 7 * b + 131 * nbits)
            all_rows.extend(rr)
            ok = [x for x in rr if "error" not in x]
            if not ok:
                print(f"  n~2^{nbits:<3d} b={b:<4d}  all {reps} reps CAPPED "
                      f"(relation finding too slow)  [{time.perf_counter()-t0:.1f}s]")
                continue
            nnz = sum(x["nnz"] for x in ok) / len(ok)
            dens = sum(x["density"] for x in ok) / len(ok)
            rpc = sum(x["nnz_per_col_mean"] for x in ok) / len(ok)
            rmx = sum(x["rowdeg_max"] for x in ok) / len(ok)
            rfr = sum(x["rowdeg_max_frac"] for x in ok) / len(ok)
            cdx = sum(x["coldeg_max"] for x in ok) / len(ok)
            act = sum(x["active_rows"] for x in ok) / len(ok)
            hv = sum(x["heavy_rows"] for x in ok) / len(ok)
            inv = all(x["defect_perm_invariant"] for x in ok)
            print(f"  n~2^{nbits:<3d} b={b:<4d} | nnz={nnz:9.1f}  density={dens:.5f}  "
                  f"nnz/col={rpc:5.2f}  coldeg_max={cdx:4.1f} | "
                  f"rowdeg_max={rmx:7.1f} ({rfr:5.1%} of ncols)  "
                  f"active_rows={act:6.1f}  heavy={hv:3.1f} | "
                  f"defect perm-invariant: {inv}  [{time.perf_counter()-t0:.1f}s]")

    # ------------------------------------------------------------------
    print()
    print("--- the mechanism: row degree of the SMALLEST primes, and (*) ---")
    # (*) Pr[row i nonzero] = Psi(n/p_i, B) / Psi(n, B), EXACTLY.
    # Checked by brute-force enumeration of ALL B-smooth integers up to n at a
    # size where that is possible.
    print("  EXACT check of (*): Pr[2 | r] over all B-smooth r <= n, by "
          "brute-force enumeration")
    print(f"  {'n':>8} {'B':>6} {'#B-smooth':>10} {'Pr[2|r]':>9}  "
          f"{'measured rowdeg_1/(b+c)':>26}")
    exact_checks = []
    for (n, B) in ((600, 20), (900, 20), (1500, 30), (2500, 30), (4000, 40)):
        FB = factor_base(B, n)
        rat, tot = psi_ratio_2(n, B, FB)
        exact_checks.append({"n": n, "B": B, "n_smooth": tot, "Pr2": rat})
        print(f"  {n:>8} {B:>6} {tot:>10} {rat:>9.4f}")
    all_rows.append({"exact_psi_checks": exact_checks})

    # ------------------------------------------------------------------
    print()
    print("--- defect: is it Theta(b)?  defect / (b+c) vs b ---")
    print(f"  {'n':>6} {'b':>5} {'ncols':>7} {'defect':>8} {'defect/ncols':>13} "
          f"{'nnz':>9} {'nnz/ncols':>10} {'active_rows':>12}")
    for r in all_rows:
        if "defect" not in r:
            continue
        nc = r["rels"]
        print(f"  2^{r['nbits']:<4} {r['b']:>5} {nc:>7} {r['defect']:>8} "
              f"{r['defect']/nc:>13.4f} {r['nnz']:>9} {r['nnz']/nc:>10.2f} "
              f"{r['active_rows']:>12}")

    # ------------------------------------------------------------------
    print()
    print("--- T1 VERDICT DATA: ratio nnz/(b*(b+c)) as b grows (the density) ---")
    print("  if density ~ 1/b the matrix is genuinely sparse;")
    print("  if the DEFECT stays Theta(b) the NFS sparse treatment cannot apply.")
    for nbits in (20, 30, 40):
        pts = [(r["b"], r["density"], r["defect"] / r["rels"], r["nnz"] / r["rels"])
               for r in all_rows if "density" in r and r["nbits"] == nbits]
        pts.sort()
        print(f"  n~2^{nbits}: " + "  ".join(
            f"b={b}:d={d:.4f},def/nc={df:.3f},nnz/nc={nn:.2f}" for b, d, df, nn in pts))

    with open(OUT, "w") as f:
        json.dump(all_rows, f, indent=1)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()