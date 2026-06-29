"""Numerical demonstrations for:

    Extremal L1 mass of normalized 1-Lipschitz grid height functions.

For every nonempty m x n rectangular grid, an integer height function
f : {0,...,m-1} x {0,...,n-1} -> Z with f(0,0) = 0 and |f(p)-f(q)| <= 1 on
every grid edge has total absolute mass

    gridMass(f, m, n) = sum_{i<m} sum_{j<n} |f(i,j)|
                      <= triBound(m, n) = n*m(m-1)/2 + m*n(n-1)/2.

The bound is sharp, attained by the staircase f(i,j) = i+j and by -(i+j).
Dropping the anchor f(0,0)=0 makes the mass unbounded (constant functions).

This script is self-contained (standard library only) and uses type hints.
Run:  python demo.py
"""

from __future__ import annotations

import itertools
import random
from typing import Callable, List, Tuple

HeightFn = Callable[[int, int], int]


# --------------------------------------------------------------------------- #
# Core quantities (mirroring the formal definitions gridMass / triBound).
# --------------------------------------------------------------------------- #
def grid_mass(f: HeightFn, m: int, n: int) -> int:
    """Total absolute L1 mass of f over the m x n grid: sum_{i,j} |f(i,j)|."""
    return sum(abs(f(i, j)) for i in range(m) for j in range(n))


def tri_bound(m: int, n: int) -> int:
    """Closed-form extremal bound n*m(m-1)/2 + m*n(n-1)/2 (an integer)."""
    return n * (m * (m - 1) // 2) + m * (n * (n - 1) // 2)


def staircase(i: int, j: int) -> int:
    """Diagonal staircase height function f(i,j) = i + j."""
    return i + j


# --------------------------------------------------------------------------- #
# Admissibility checks (anchor + 1-Lipschitz on grid edges).
# --------------------------------------------------------------------------- #
def is_admissible(f: HeightFn, m: int, n: int) -> bool:
    """True iff f(0,0)=0 and |f(p)-f(q)| <= 1 on every horizontal/vertical edge."""
    if m == 0 or n == 0:
        return True
    if f(0, 0) != 0:
        return False
    for i in range(m):
        for j in range(n):
            if i + 1 < m and abs(f(i + 1, j) - f(i, j)) > 1:
                return False
            if j + 1 < n and abs(f(i, j + 1) - f(i, j)) > 1:
                return False
    return True


def cell_slack(f: HeightFn, m: int, n: int) -> List[List[int]]:
    """Per-cell slack (i+j) - |f(i,j)| >= 0 from the domination lemma |f|<=i+j."""
    return [[(i + j) - abs(f(i, j)) for j in range(n)] for i in range(m)]


# --------------------------------------------------------------------------- #
# A random admissible height function, built by a 1-Lipschitz random walk.
# --------------------------------------------------------------------------- #
def random_admissible(m: int, n: int, seed: int) -> HeightFn:
    """Construct a random admissible f in row-major order. Each new cell value is
    chosen uniformly from the interval forced by its already-set left and below
    neighbours, [max(nbrs)-1, min(nbrs)+1], which is always nonempty by the
    triangle inequality. This guarantees the 1-Lipschitz property on every grid
    edge and f(0,0)=0."""
    rng = random.Random(seed)
    table = [[0] * n for _ in range(m)]
    for i in range(m):
        for j in range(n):
            if i == 0 and j == 0:
                table[i][j] = 0
                continue
            nbrs = []
            if j > 0:
                nbrs.append(table[i][j - 1])
            if i > 0:
                nbrs.append(table[i - 1][j])
            lo, hi = max(nbrs) - 1, min(nbrs) + 1
            table[i][j] = rng.randint(lo, hi)
    return lambda i, j: table[i][j]


# --------------------------------------------------------------------------- #
# Exhaustive verification of the MAIN theorem on small grids.
# --------------------------------------------------------------------------- #
def brute_force_max_mass(m: int, n: int) -> int:
    """Exhaustively maximize grid_mass over ALL admissible integer height
    functions on the m x n grid. Since |f(i,j)| <= i+j, each cell ranges over a
    finite set, so the search is finite. Returns the true maximum mass."""
    cells: List[Tuple[int, int]] = [(i, j) for i in range(m) for j in range(n)]
    ranges = [range(-(i + j), (i + j) + 1) for (i, j) in cells]
    best = 0
    for values in itertools.product(*ranges):
        table = {cells[k]: values[k] for k in range(len(cells))}
        f: HeightFn = lambda i, j, t=table: t[(i, j)]
        if is_admissible(f, m, n):
            best = max(best, grid_mass(f, m, n))
    return best


def main() -> None:
    print("=" * 70)
    print("Extremal L1 mass of 1-Lipschitz grid height functions")
    print("=" * 70)

    # 1. Closed form vs. staircase attainment (Theorems 1 & 2).
    print("\n[1] triBound vs. staircase mass (sharpness, gridMass_staircase):")
    print(f"{'m':>3}{'n':>3}{'triBound':>12}{'staircase':>12}{'match':>8}")
    for m, n in [(1, 1), (2, 2), (3, 3), (4, 3), (5, 7), (10, 10)]:
        tb = tri_bound(m, n)
        sm = grid_mass(staircase, m, n)
        print(f"{m:>3}{n:>3}{tb:>12}{sm:>12}{str(tb == sm):>8}")

    # 2. The 3x3 worked example from the article.
    print("\n[2] 3x3 staircase heights (bottom-left = (0,0) = 0):")
    m = n = 3
    for i in reversed(range(m)):
        print("    " + "  ".join(f"{staircase(i, j):2d}" for j in range(n)))
    print(f"    total mass = {grid_mass(staircase, m, n)}, triBound = {tri_bound(m, n)}")

    # 3. Negative branch also attains the bound (Theorem 3).
    neg = lambda i, j: -staircase(i, j)
    print("\n[3] negative staircase mass (gridMass_neg_staircase):")
    for m, n in [(3, 3), (4, 5)]:
        print(f"    m={m} n={n}: mass={grid_mass(neg, m, n)} triBound={tri_bound(m, n)}")

    # 4. Random admissible functions obey the bound (Theorem 1).
    print("\n[4] random admissible functions satisfy gridMass <= triBound:")
    m, n = 6, 5
    for seed in range(5):
        f = random_admissible(m, n, seed)
        mass = grid_mass(f, m, n)
        bound = tri_bound(m, n)
        assert is_admissible(f, m, n)
        assert mass <= bound
        print(f"    seed={seed}: mass={mass:4d} <= triBound={bound}  OK")

    # 5. Per-cell domination |f(i,j)| <= i+j (Lemma 2) -- slack is non-negative.
    print("\n[5] per-cell slack (i+j)-|f| for a random admissible f (all >= 0):")
    f = random_admissible(4, 4, seed=42)
    for row in reversed(cell_slack(f, 4, 4)):
        print("    " + " ".join(f"{s:2d}" for s in row))

    # 6. Exhaustive confirmation that triBound is the TRUE maximum (Theorem 1+2).
    print("\n[6] brute-force max over ALL admissible f equals triBound:")
    for m, n in [(1, 1), (2, 2), (2, 3), (3, 3)]:
        bf = brute_force_max_mass(m, n)
        tb = tri_bound(m, n)
        print(f"    m={m} n={n}: brute-force max={bf}  triBound={tb}  match={bf == tb}")

    # 7. The anchor is load-bearing (Theorem 4): constant functions are unbounded.
    print("\n[7] dropping the anchor: constant f == C is 1-Lipschitz, mass=m*n*|C|:")
    m, n = 3, 3
    for C in [0, 5, 100, 10_000]:
        const = lambda i, j, c=C: c
        assert is_admissible(const, m, n) == (C == 0)  # admissible only if anchored
        print(f"    C={C:>6}: mass={grid_mass(const, m, n):>9} (= m*n*|C| = {m * n * abs(C)})")

    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
