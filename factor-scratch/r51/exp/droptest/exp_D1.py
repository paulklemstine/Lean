"""
D1 -- Is the permutation-similarity defect really Theta(b), and does the
unbounded defect actually COST anything at b ~ 26-52 (the measured argmin)?

Three things are measured, in order:

  A. THE DEFECT ITSELF, at the sizes that matter, on REAL Stange matrices.
     Independent re-derivation, plus an exact brute-force check of the
     mechanism Pr[p=2 | r] = Psi(n/2,B)/Psi(n,B) against enumeration of EVERY
     B-smooth integer <= n (no Dickman, no rho, no float cube roots).

  B. DOES IT BIND AT b ~ 26-52?  This is the question the brief actually asks,
     and the answer is NOT the one the sparsity result implies.  The defect is
     a RATIO (0.6 of the columns); the COST of a dense elimination is an
     ABSOLUTE number of operations, and at b=26..52 that absolute number is
     already tiny.  So: matched-shape, matched-nnz control with an O(1)
     defect (bounded_defect_control), both routes timed.

  C. WHERE IT WOULD BIND -- the honest extrapolation, labelled as such.

Writes D1_defect.json.
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

OUT = "/home/raver1975/lean/factor-scratch/r51/exp/droptest/D1_defect.json"
RESULTS = {}


def one_matrix(bits, b, seed):
    """A real Stange relation matrix, from r48's validated relation finder."""
    rng = random.Random(seed)
    n, p, q = D.stange.gen_semiprime(bits, rng)
    g = D.rand_g(n, rng)
    rels, trials = D.make_relations(n, g, b, 1, rng, "seq")
    M = D.build_M(rels, b)
    return {"n": n, "p": p, "q": q, "b": b, "bits": n.bit_length(),
            "M": M, "trials": trials, "B": D.stange.bbound_for_b(b)}


# ---------------------------------------------------------------------------
# A. the defect, measured
# ---------------------------------------------------------------------------


def part_A():
    print("=" * 90)
    print("A.  THE DEFECT, MEASURED ON REAL STANGE MATRICES")
    print("=" * 90)
    cells = []
    for bits in (30, 40):
        for b in (8, 16, 26, 40, 52, 64, 100, 128):
            reps = []
            for s in range(3):
                try:
                    inst = one_matrix(bits, b, 1000 * s + b + bits)
                except Exception as e:      # relation finding can stall
                    print(f"  skip b={b} bits={bits} seed={s}: {type(e).__name__}")
                    continue
                M = inst["M"]
                st = D.incidence(M)
                d0, dl = D.defect_under_permutations(M, trials=6)
                assert all(x == d0 for x in dl)
                # which ROW is the heavy one?  record the top few
                order = sorted(range(st["b"]), key=lambda i: -st["rowdeg"][i])
                reps.append({
                    "nnz": st["nnz"], "density": st["density"],
                    "max_rowdeg": st["max_rowdeg"],
                    "max_coldeg": st["max_coldeg"],
                    "defect": st["defect"],
                    "defect_frac": st["defect"] / st["ncols"],
                    "nnz_per_col": st["nnz"] / st["ncols"],
                    "heaviest_rows": order[:4],
                    "rowdeg_top": [st["rowdeg"][i] for i in order[:4]],
                    "row2_frac": st["rowdeg"][0] / st["ncols"],
                    "perm_invariant": True,
                })
            if reps:
                cells.append({"bits": bits, "b": b, "n": len(reps),
                              "reps": reps})
    # summary table
    hdr = (f"{'bits':>4} {'b':>4} {'reps':>4} {'nnz':>7} {'nnz/col':>8} "
           f"{'maxrow':>7} {'maxcol':>7} {'defect':>7} {'def/b+c':>9} "
           f"{'row(p=2)/b+c':>12}")
    print(hdr)
    print("-" * len(hdr))
    for c in cells:
        med = lambda k: statistics.median([r[k] for r in c["reps"]])
        print(f"{c['bits']:>4} {c['b']:>4} {c['n']:>4} {med('nnz'):>7.0f} "
              f"{med('nnz_per_col'):>8.2f} {med('max_rowdeg'):>7.1f} "
              f"{med('max_coldeg'):>7.1f} {med('defect'):>7.1f} "
              f"{med('defect_frac'):>9.3f} {med('row2_frac'):>12.3f}")
    RESULTS["A_defect"] = cells
    return cells


# ---------------------------------------------------------------------------
# A2. the mechanism, checked EXACTLY by brute-force enumeration
# ---------------------------------------------------------------------------


def part_A2():
    print()
    print("=" * 90)
    print("A2.  MECHANISM: Pr[2 | r] = Psi(n/2,B)/Psi(n,B), EXACTLY")
    print("     (brute-force enumeration of EVERY B-smooth integer <= n)")
    print("=" * 90)
    print("  ⚠️ Enumeration runs over the FULL prime set <= B.  stange.factor_base")
    print("     DROPS primes dividing n, which deletes 2 for even n and returns")
    print("     Pr[2|r] = 0.0000 -- a clean, confident, completely wrong number.")
    print()
    hdr = f"{'n':>8} {'B':>5} {'#smooth<=n':>11} {'exact Psi(n/2,B)/Psi(n,B)':>26} {'measured row(p=2) frac':>24} {'z':>7}"
    print(hdr)
    print("-" * len(hdr))
    rows = []
    for (n, B) in [(997, 20), (1009, 30), (2003, 30), (5003, 50),
                   (8009, 70), (20011, 120)]:
        Psi_n = D.psi_exact(n, B)
        Psi_h = D.psi_exact(n // 2, B)
        pred = Psi_h / Psi_n
        # measure on a real Stange matrix at this n and b = #primes<=B
        b = sum(1 for _ in D.stange.primerange(2, B + 1))
        try:
            rng = random.Random(4242 + b)
            g = D.rand_g(n, rng)
            rels, _ = D.make_relations(n, g, b, 1, rng, "seq")
            M = D.build_M(rels, b)
            st = D.incidence(M)
            meas = st["rowdeg"][0] / st["ncols"]
        except Exception as e:
            meas = float("nan")
        # binomial z for the row-degree count
        try:
            k = st["rowdeg"][0]
            nn = st["ncols"]
            exp = pred * nn
            sd = math.sqrt(nn * pred * (1 - pred))
            z = (k - exp) / sd if sd > 0 else float("nan")
        except Exception:
            z = float("nan")
        print(f"{n:>8} {B:>5} {Psi_n:>11} {pred:>26.4f} {meas:>24.4f} {z:>7.2f}")
        rows.append({"n": n, "B": B, "psi": Psi_n, "pred": pred,
                     "meas": meas, "z": z, "b": b})
    RESULTS["A2_mechanism"] = rows


# ---------------------------------------------------------------------------
# B. DOES THE DEFECT COST ANYTHING AT b ~ 26-52?
# ---------------------------------------------------------------------------


def part_B():
    print()
    print("=" * 90)
    print("B.  DOES THE Theta(b) DEFECT COST ANYTHING AT THE ARGMIN (b ~ 26-52)?")
    print("=" * 90)
    print("  Matched-shape, matched-nnz control: SAME b, SAME ncols=b+c, SAME nnz,")
    print("  but row degrees flattened to ~nnz/b, so defect is O(1) not Theta(b).")
    print("  If the defect were what costs the time at these b, the O(1)-defect")
    print("  matrix would be much faster.  Both timed with the SAME exact route.")
    print()
    hdr = (f"{'b':>4} {'nnz':>6} {'defect(real)':>12} {'defect(ctrl)':>12} "
           f"{'dense real (ms)':>15} {'dense ctrl (ms)':>15} {'ratio':>7} "
           f"{'sparse real (ms)':>16} {'sparse ctrl (ms)':>16} {'ratio':>7}")
    print(hdr)
    print("-" * len(hdr))
    rows = []
    for b in (16, 26, 40, 52, 64, 100, 128):
        reps = []
        for s in range(3):
            try:
                inst = one_matrix(40, b, 7000 + 100 * s + b)
            except Exception:
                continue
            M = inst["M"]
            C = D.bounded_defect_control(M, random.Random(99 + s))
            stM, stC = D.incidence(M), D.incidence(C)
            assert stM["nnz"] == stC["nnz"], (stM["nnz"], stC["nnz"])
            assert (stM["b"], stM["ncols"]) == (stC["b"], stC["ncols"])

            def timeit(fn, A, reps_n=3):
                ts = []
                for _ in range(reps_n):
                    r = fn(A)
                    ts.append(r["time"])
                return min(ts)

            dM = timeit(D.kernel_dense_F, M)
            dC = timeit(D.kernel_dense_F, C)
            sM = timeit(D.kernel_sparse_Q, M)
            sC = timeit(D.kernel_sparse_Q, C)
            reps.append({
                "b": b, "nnz": stM["nnz"],
                "defect_real": stM["defect"], "defect_ctrl": stC["defect"],
                "defect_frac_real": stM["defect_frac"],
                "defect_frac_ctrl": stC["defect_frac"],
                "dense_real": dM, "dense_ctrl": dC,
                "sparse_real": sM, "sparse_ctrl": sC,
                "ops_dense_real": dM, "ops_sparse_real": sM,
            })
        if not reps:
            continue
        g = lambda k: statistics.median([r[k] for r in reps])
        print(f"{b:>4} {g('nnz'):>6.0f} {g('defect_real'):>12.1f} "
              f"{g('defect_ctrl'):>12.1f} {g('dense_real')*1e3:>15.3f} "
              f"{g('dense_ctrl')*1e3:>15.3f} "
              f"{g('dense_real')/max(g('dense_ctrl'),1e-12):>7.2f} "
              f"{g('sparse_real')*1e3:>16.3f} {g('sparse_ctrl')*1e3:>16.3f} "
              f"{g('sparse_real')/max(g('sparse_ctrl'),1e-12):>7.2f}")
        rows.append({"b": b, "reps": reps, "summary":
                     {k: g(k) for k in reps[0] if k != "b"}})
    RESULTS["B_defect_cost"] = rows
    return rows


def main():
    t0 = time.time()
    part_A()
    part_A2()
    part_B()
    RESULTS["elapsed_s"] = time.time() - t0
    with open(OUT, "w") as f:
        json.dump(RESULTS, f, indent=1, default=str)
    print()
    print(f"wrote {OUT}  ({time.time()-t0:.1f}s)")


if __name__ == "__main__":
    main()