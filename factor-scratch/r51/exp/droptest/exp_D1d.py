"""
D1-D -- SCALING, AND AN HONEST ACCOUNT OF WHAT MY "SPARSE" ROUTE IS.

Three questions the wall clocks cannot answer, settled by counting.

Q-A.  WHAT IS THE GROWTH EXPONENT of the sparse fill, and is it Theta(b^2)?
      Measured on real Stange matrices only, over a wide b range, by fitting
      log(fill) against log(b).  If the exponent is ~2, the sparsity axis's
      asymptotic claim holds; the question is then what the CONSTANT is worth
      at b = 26-52.

Q-B.  HOW MUCH OF MY SPARSE ROUTE'S COST IS THE FULL ROW SWEEP?
      ⚠️ My `kernel_sparse_Q` runs `for i in range(m)` at every pivot, testing
      R[i].get(c).  That is Theta(b) dictionary probes PER PIVOT and Theta(b^2)
      probes TOTAL -- a structure-INDEPENDENT floor that no amount of sparsity
      can go below.  So the route's wall clock contains a Theta(b^2) term that
      has nothing to do with the matrix's defect.  I separate:
          probes  -- the Theta(b^2) full-sweep floor (structure-independent)
          updates -- the real arithmetic (fill-dependent, the defect's cost)
      Reporting only the sum, as the sparse agent's table did, attributes that
      floor to sparsity.

Q-C.  THE ARGMIN QUESTION, answered in the units that matter:
      at b = 26-52, what is the ABSOLUTE cost of the kernel, in operations,
      and what would an O(1)-defect matrix cost?  The answer decides whether
      the defect "binds in the regime claimed".

Writes D1_scaling.json.
"""
from __future__ import annotations

import json
import math
import random
import statistics
import sys
import time
from fractions import Fraction

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51/exp/droptest")
import dtcore as D  # noqa: E402

OUT = "/home/raver1975/lean/factor-scratch/r51/exp/droptest/D1_scaling.json"


def one_matrix(bits, b, seed):
    rng = random.Random(seed)
    n, p, q = D.stange.gen_semiprime(bits, rng)
    g = D.rand_g(n, rng)
    rels, _ = D.make_relations(n, g, b, 1, rng, "seq")
    return D.build_M(rels, b)


def sparse_split(rows):
    """Sparse exact Gauss-Jordan, counting PROBES and UPDATES separately.

    probes  = dictionary lookups, including the ones that MISS (the full row
              sweep).  This is the Theta(b^2) structure-independent floor.
    updates = actual arithmetic on stored nonzeros.  This is where fill lives.
    """
    rd = [dict((j, Fraction(int(x))) for j, x in enumerate(r) if x) for r in rows]
    m, ncols = len(rows), len(rows[0])
    R = [dict(r) for r in rd]
    probes = 0
    updates = 0
    fill = 0
    piv = []
    r = 0
    for c in range(ncols):
        pr = None
        for i in range(r, m):
            probes += 1
            if R[i].get(c, 0) != 0:
                pr = i
                break
        if pr is None:
            continue
        R[r], R[pr] = R[pr], R[r]
        pv = R[r][c]
        Rr = {j: v / pv for j, v in R[r].items()}
        R[r] = Rr
        updates += len(Rr)
        for i in range(m):
            probes += 1
            if i != r:
                f = R[i].get(c, 0)
                if f != 0:
                    Ri = R[i]
                    for j, v in Rr.items():
                        nv = Ri.get(j, 0) - f * v
                        probes += 1
                        updates += 1
                        if nv == 0:
                            Ri.pop(j, None)
                        else:
                            Ri[j] = nv
        fill += sum(len(x) for x in R)
        piv.append(c)
        r += 1
        if r == m:
            break
    return {"probes": probes, "updates": updates, "fill": fill,
            "rank": len(piv)}


def main():
    print("=" * 104)
    print("D1-D.  SCALING, AND AN HONEST ACCOUNT OF THE SPARSE ROUTE")
    print("=" * 104)
    print()
    print("Q-B first, because it changes how everything else is read:")
    print("  ⚠️ `kernel_sparse_Q` probes R[i].get(c) for EVERY row i at every")
    print("     pivot: Theta(b^2) dictionary probes, INDEPENDENT of the matrix.")
    print("     That floor is attributed to sparsity unless it is separated out.")
    print()
    hdr = (f"{'b':>5} {'nnz':>6} {'defect':>7} {'probes':>10} {'probes/b^2':>11} "
           f"{'updates':>10} {'updates/b^2':>13} {'fill':>10} {'fill/b^2':>10} "
           f"{'upd/probe':>9}")
    print(hdr)
    print("-" * len(hdr))
    rows = []
    for b in (16, 26, 40, 52, 64, 100, 128, 160, 200, 256):
        acc = []
        for s in range(2):
            try:
                M = one_matrix(40, b, 9100 + 31 * s + b)
            except Exception:
                continue
            acc.append((M, sparse_split(M)))
        if not acc:
            continue
        g = lambda k: statistics.median([r[k] for _, r in acc])
        nn = statistics.median([D.incidence(M)["nnz"] for M, _ in acc])
        df = statistics.median([D.incidence(M)["defect"] for M, _ in acc])
        P, U, FI = g("probes"), g("updates"), g("fill")
        b2 = b * b
        print(f"{b:>5} {nn:>6.0f} {df:>7.1f} {P:>10.0f} {P/b2:>11.2f} "
              f"{U:>10.0f} {U/b2:>13.2f} {FI:>10.0f} {FI/b2:>10.2f} "
              f"{U/max(P,1):>9.3f}")
        rows.append({"b": b, "nnz": nn, "defect": df, "probes": P,
                     "updates": U, "fill": FI})
    print()
    print("  probes/b^2 flat  -> the Theta(b^2) full-sweep floor is confirmed")
    print("                     and is NOT a consequence of the defect.")
    print("  updates/b^2 flat -> the arithmetic is genuinely Theta(b^2).")

    # ---- Q-A: fit the exponent on real matrices ----
    print()
    print("Q-A.  GROWTH EXPONENT OF THE SPARSE FILL (real Stange matrices)")
    print()
    xs = [math.log(r["b"]) for r in rows]
    for key in ("updates", "fill"):
        ys = [math.log(max(r[key], 1)) for r in rows]
        n = len(xs)
        mx, my = sum(xs) / n, sum(ys) / n
        sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
        sxx = sum((x - mx) ** 2 for x in xs)
        slope = sxy / sxx
        # coefficient of determination
        pred = [my + slope * (x - mx) for x in xs]
        ssr = sum((y - p) ** 2 for y, p in zip(ys, pred))
        sst = sum((y - my) ** 2 for y in ys)
        r2 = 1 - ssr / sst if sst else float("nan")
        print(f"  log-log fit of {key:>8} vs b:  exponent = {slope:.3f}  "
              f"(R^2 = {r2:.4f})")
        RESULTS_A = {"key": key, "exponent": slope, "r2": r2}
    # also the defect's own exponent
    ys = [math.log(max(r["defect"], 1)) for r in rows]
    my = sum(ys) / len(ys)
    mx = sum(xs) / len(xs)
    slope_d = (sum((x - mx) * (y - my) for x, y in zip(xs, ys))
               / sum((x - mx) ** 2 for x in xs))
    print(f"  log-log fit of    defect vs b:  exponent = {slope_d:.3f}   "
          f"<- Theta(b) CONFIRMED" if abs(slope_d - 1) < 0.15 else
          f"  defect exponent = {slope_d:.3f}")

    # ---- Q-C: the argmin question in absolute units ----
    print()
    print("Q-C.  DOES THE DEFECT COST ANYTHING AT b = 26-52?  (absolute ops)")
    print()
    print("  O(1)-defect control at the SAME b, SAME nnz, SAME b^2 probe floor.")
    print("  If the updates ratio ~1, the defect buys nothing here.")
    print()
    hdr = (f"{'b':>5} {'nnz':>6} {'def real':>9} {'def ctrl':>9} "
           f"{'updates real':>13} {'updates ctrl':>13} {'ratio':>7} "
           f"{'ABS upd real':>13} {'factor b^3':>10}")
    print(hdr)
    print("-" * len(hdr))
    cc = []
    for b in (16, 26, 40, 52, 64, 100, 128, 200, 256):
        acc = []
        for s in range(2):
            try:
                M = one_matrix(40, b, 9200 + 37 * s + b)
            except Exception:
                continue
            C = D.bounded_defect_control(M, random.Random(700 + s))
            # tuple layout is (real_matrix, control_matrix, real_stats, ctrl_stats)
            acc.append((M, C, sparse_split(M), sparse_split(C)))
        if not acc:
            continue
        U = statistics.median([r[2]["updates"] for r in acc])
        UC = statistics.median([r[3]["updates"] for r in acc])
        nn = statistics.median([D.incidence(r[0])["nnz"] for r in acc])
        dr = statistics.median([D.incidence(r[0])["defect"] for r in acc])
        dc = statistics.median([D.incidence(r[1])["defect"] for r in acc])
        print(f"{b:>5} {nn:>6.0f} {dr:>9.1f} {dc:>9.1f} {U:>13.0f} "
              f"{UC:>13.0f} {U/max(UC,1):>7.2f} {U:>13.0f} {U/b**3:>10.2e}")
        cc.append({"b": b, "nnz": nn, "def_real": dr, "def_ctrl": dc,
                   "upd_real": U, "upd_ctrl": UC})
    with open(OUT, "w") as f:
        json.dump({"scaling": rows, "control": cc}, f, indent=1, default=str)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()