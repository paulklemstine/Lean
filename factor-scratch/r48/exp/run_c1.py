"""
C1 final: LLL vs BKZ vs EXACT SVP on the NFS relation lattice.

The relation lattice built from genuine GNFS smooth relations is small enough
(dimension ~ 2d+1 = 7 for d = 3) that the CERTIFIED exact SVP enumerator runs
on it directly.  That makes the experiment definitive rather than merely
comparative:

    LLL(b1) / exact_SVP   =   the TOTAL gain available to ANY block size.

If that ratio is 1.000, no beta can help, and that is a clean negative.
"""
import numpy as np

import nfs_lattice as NL
import run_c1_old as R
from lll_self_test import lll_reduce, bkz_reduce, is_lll_reduced
from exactsvp import enumerate_svp


def build_rows(rels, fc, d, ymax, width=2 * 3 + 1):
    """Rows = coefficient vectors of h_i(x) = prod_p prod_{r roots}(x-r)^{e_p},
    truncated to 2d+1 coefficients (the relation lattice before the
    Montgomery N*F^k subtraction)."""
    split = NL.split_primes(fc, ymax)
    rows = []
    for (a, b, e) in rels:
        h = [1]
        for p, ee in sorted(e.items()):
            for r in split[p]:
                for _ in range(ee):
                    new = [0] * (len(h) + 1)
                    for i, c in enumerate(h):
                        new[i + 1] += c
                        new[i] -= c * r
                    h = new
        rows.append([float(c) for c in h[:width]])
    w = max(len(r) for r in rows)
    A = np.array([r + [0.0] * (w - len(r)) for r in rows], dtype=float)
    A = A[np.any(A != 0, axis=1)]
    keep = [0]
    for i in range(1, len(A)):
        trial = A[keep + [i]]
        if np.linalg.matrix_rank(trial, tol=1e-6) == len(trial):
            keep.append(i)
    return A[keep]


def hermite(B):
    k = B.shape[0]
    v = abs(np.linalg.det(B))
    return float(np.linalg.norm(B[0])) / (v ** (1.0 / k))


def main():
    print("=" * 78)
    print("C1  LATTICE REDUCTION PAST LLL, ON THE ACTUAL NFS RELATION LATTICE")
    print("=" * 78)
    configs = [(32, 1000, 800), (40, 1000, 800), (40, 5000, 800),
               (45, 1000, 800), (50, 1000, 800)]
    ratios = []
    for (nb, ymax, box) in configs:
        N, p, q, m, P, fc, cost = R.build(nb, 3)
        rels, tot, npr = R.find_relations(fc, 3, m, N, ymax=ymax,
                                          Amax=box, Bmax=box, need=40)
        rows = build_rows(rels, fc, 3, ymax)
        n, dim = rows.shape
        L, _ = lll_reduce(rows)
        lll_b1 = float(np.linalg.norm(L[0]))
        ref = enumerate_svp(rows, cap=30_000_000)
        svp = ref[0] if ref is not None else None
        print(f"\nN = {N} ({N.bit_length()} bits), m = {m}, d = 3")
        print(f"f (x^3,x^2,x,1) = {fc}, coefficient mass = {cost}")
        print(f"relations = {len(rels)}, lattice = {n} x {dim}, "
              f"splitting primes <= {ymax}: {npr}")
        print("-" * 78)
        print(f"{'method':<9}{'||b1||':>16}{'LLL/this':>11}{'hermite':>11}{'/exact SVP':>13}")
        if svp:
            print(f"{'SVP':<9}{svp ** 0.5:>16.6e}{lll_b1 / svp ** 0.5:>11.4f}"
                  f"{'':>11}{1.0:>13.4f}")
        print(f"{'raw':<9}{float(np.linalg.norm(rows[0])):>16.6e}"
              f"{lll_b1 / float(np.linalg.norm(rows[0])):>11.4f}{hermite(rows):>11.5f}"
              + (f"{'':>13}" if svp else ""))
        ok, msg = is_lll_reduced(L)
        print(f"{'LLL':<9}{lll_b1:>16.6e}{1.0:>11.4f}{hermite(L):>11.5f}"
              + (f"{lll_b1 / svp ** 0.5:>13.4f}" if svp else ""))
        print(f"        LLL-reduced check: {ok} ({msg})")
        if svp:
            ratios.append(('LLL', nb, lll_b1 / svp ** 0.5))
        for beta in range(2, dim + 1):
            B = bkz_reduce(rows, beta)
            b1 = float(np.linalg.norm(B[0]))
            line = (f"{'BKZ' + str(beta):<9}{b1:>16.6e}{lll_b1 / b1:>11.4f}"
                    f"{hermite(B):>11.5f}")
            if svp:
                line += f"{b1 / svp ** 0.5:>13.4f}"
                ratios.append(('BKZ%d' % beta, nb, b1 / svp ** 0.5))
            print(line)
    print("\n" + "=" * 78)
    if ratios:
        lllr = [r for t, _, r in ratios if t == 'LLL']
        bkzr = [r for t, _, r in ratios if t != 'LLL']
        print(f"AGGREGATE over {len(ratios)} (config, beta) measurements, "
              f"{len(set(n for _, n, _ in ratios))} distinct N:")
        print(f"  LLL / exact SVP      : min {min(lllr):.6f}  max {max(lllr):.6f}")
        print(f"  BKZ / exact SVP      : min {min(bkzr):.6f}  max {max(bkzr):.6f}")
        print(f"  BEST improvement any BKZ beta achieved over LLL: "
              f"{max(lllr) / min(min(bkzr), max(lllr)):.6f}x")
    print("=" * 78)


if __name__ == "__main__":
    main()
