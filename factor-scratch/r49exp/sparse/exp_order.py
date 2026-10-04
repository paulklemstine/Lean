"""
exp_order.py -- does a FILL-REDUCING ORDERING beat the natural one?

spcore.kernel_sparse eliminates columns in their natural order.  A fair
question, and one that decides whether my Theta(b^2) fill claim is a property of
the MATRIX or an artefact of my ORDERING, is: what happens under a decent
minimum-degree column ordering?

This matters for the honesty of the T2 conclusion.  If AMD gives Theta(b) fill,
the sparse route is much better than I claim and the axis is only half-closed.
If it still gives Theta(b^2), the fill is forced by the matrix -- which is what
the Theta(b)-defect argument predicts -- and the conclusion is solid.

Ordering used: greedy approximate minimum degree on the COLUMN INTERACTION
graph.  Two columns interact if they share a row.  Repeatedly pick the column of
smallest current interaction-degree and move it to the front.  This is the
standard AMD heuristic for sparse elimination and is O(nnz^2)-ish, fine at the
sizes tested.

Outputs: order_fill.json
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
    cols_from_rels,
    incidence_stats,
    kernel_sparse,
    make_rels,
    rand_g,
)
from stange import gen_semiprime  # noqa: E402

OUT = "/home/raver1975/lean/factor-scratch/r49exp/sparse/order_fill.json"


def amd_column_order(cols, b, ncols):
    """Greedy approximate minimum degree on the column-interaction graph."""
    sets = [set(i for i, _e in col) for col in cols]
    remaining = list(range(ncols))
    order = []
    degcache = {}
    for k in range(ncols):
        best, bestd = None, None
        for j in remaining:
            sj = sets[j]
            d = 0
            for i in sj:
                d += degcache.get(i, 0)
            d = max(d, 1)
            if bestd is None or d < bestd:
                best, bestd = j, d
        remaining.remove(best)
        order.append(best)
        sb = sets[best]
        for i in sb:
            degcache[i] = degcache.get(i, 0) + 1
    return order


def kernel_sparse_ordered(cols, b, order):
    """kernel_sparse but eliminating columns in `order`.  Same arithmetic,
    same exactness; only the pivot sequence changes."""
    ncols = len(cols)
    A = [dict() for _ in range(b)]
    for j, col in enumerate(cols):
        for i, e in col:
            if e:
                A[i][j] = Fraction(e)
    nnz_now = sum(len(r) for r in A)
    peak = nnz_now
    ops = 0
    piv = []
    r = 0
    perm = list(order)
    for c in perm:
        if r >= b:
            break
        p = None
        for i in range(r, b):
            if A[i].get(c):
                p = i
                break
        if p is None:
            continue
        A[r], A[p] = A[p], A[r]
        pv = A[r][c]
        Ar = A[r]
        for j in list(Ar):
            Ar[j] = Ar[j] / pv
            ops += 1
        for i in range(b):
            if i == r:
                continue
            Ai = A[i]
            f = Ai.get(c)
            if not f:
                Ai.pop(c, None)
                continue
            for j, v in list(Ar.items()):
                if j == c:
                    continue
                nv = Ai.get(j)
                if nv is None:
                    w = -f * v
                    if w:
                        Ai[j] = w
                        nnz_now += 1
                else:
                    nv -= f * v
                    if nv == 0:
                        del Ai[j]
                        nnz_now -= 1
                    else:
                        Ai[j] = nv
                ops += 1
            del Ai[c]
            nnz_now -= 1
        peak = max(peak, nnz_now)
        piv.append(c)
        r += 1
    pivset = set(piv)
    free = [j for j in range(ncols) if j not in pivset]
    basis = []
    for fc in free:
        x = [Fraction(0)] * ncols
        x[fc] = Fraction(1)
        for i in range(len(piv) - 1, -1, -1):
            pc = piv[i]
            s = Fraction(0)
            Ai = A[i]
            for j, v in Ai.items():
                if j != pc and x[j]:
                    s += v * x[j]
                    ops += 1
            x[pc] = -s
        basis.append(x)
    return basis, r, max(peak, sum(len(x) for x in A)), ops


def main():
    res = []
    print("=" * 96)
    print("Does an AMD (minimum-degree) column ordering reduce the FILL below")
    print("Theta(b^2)?  If not, the Theta(b^2) fill is forced by the matrix.")
    print("=" * 96)
    print(f"{'n':>5} {'b':>5} {'nnz':>7} {'nat fill':>10} {'AMD fill':>10} "
          f"{'ratio':>7} {'nat ops':>11} {'AMD ops':>11} {'nat ops/b^2':>12} "
          f"{'AMD ops/b^2':>12}")
    for nbits in (20, 30, 40):
        for b in (16, 26, 40, 64, 100):
            rng = random.Random(2_500_000 + 11 * b + 3 * nbits)
            n, p, q = gen_semiprime(nbits, rng)
            g = rand_g(n, rng)
            try:
                rels, FB, BB, trials = make_rels(n, g, b, 1, rng, cap=2_500_000)
            except RuntimeError:
                continue
            cols = cols_from_rels(rels)
            nc = len(cols)
            st = incidence_stats(cols, b)
            t0 = time.perf_counter()
            Kn, rn, peakn, opsn = kernel_sparse(cols, b)
            tn = time.perf_counter() - t0
            assert_kernel(cols, b, Kn, "ORDER-NAT")
            t0 = time.perf_counter()
            order = amd_column_order(cols, b, nc)
            Ka, ra, peaka, opsa = kernel_sparse_ordered(cols, b, order)
            ta = time.perf_counter() - t0
            assert_kernel(cols, b, Ka, "ORDER-AMD")
            assert rn == ra, (rn, ra)
            print(f"2^{nbits:<3} {b:>5} {st['nnz']:>7} {peakn:>10} {peaka:>10} "
                  f"{peaka/peakn:>7.3f} {opsn:>11} {opsa:>11} "
                  f"{opsn/b**2:>12.3f} {opsa/b**2:>12.3f}")
            res.append({"nbits": nbits, "b": b, "nnz": st["nnz"], "ncols": nc,
                        "fill_natural": peakn, "fill_amd": peaka,
                        "ratio": peaka / peakn, "ops_natural": opsn,
                        "ops_amd": opsa, "ops_natural_over_b2": opsn / b ** 2,
                        "ops_amd_over_b2": opsa / b ** 2,
                        "t_natural": tn, "t_amd_total": ta})
    print()
    print("Read: if ops_amd/b^2 is still O(1) (not falling), the fill is Theta(b^2)")
    print("under BOTH orderings, i.e. forced by the matrix, not by my pivot choice.")
    with open(OUT, "w") as f:
        json.dump(res, f, indent=1)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()