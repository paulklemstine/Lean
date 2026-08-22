"""
Rigidity gap for shallow product coins: numerical demonstrations.

Pure-Python (standard library only), fully self-contained.

Setting
-------
A *resonance set* R lives inside a finite state space X.  A *coin* is a weight
function psi : X -> R with sum_x psi(x)^2 = 1, and its *resonance amplitude*
against R is A_R(psi) = sum_{x in R} psi(x).  Cauchy-Schwarz gives
A_R(psi)^2 <= |R|, with equality exactly for psi proportional to the indicator
of R.

A *product coin* on X = A x B is psi(a, b) = f(a) g(b) with ||f|| = ||g|| = 1.
A resonance set R is a *combinatorial box* when it is closed under the
rectangle rule: (a,b), (a',b') in R  ==>  (a,b') in R; equivalently R is the
product of its two projections.

Main facts demonstrated here
----------------------------
1. The exact Cauchy-Schwarz defect identity
       |R| - A_R(psi)^2 = |R| * sum_x (psi(x) - (A/|R|) 1_R(x))^2 .
2. The product-coin defect identity
       || M - t f g^T ||_F^2 = |R| - t^2 ,  t = A_R(f (x) g),
   so that the best product amplitude squared is sigma_1(M)^2 and the true gap
   is the singular tail sum_{k>=2} sigma_k(M)^2.
3. Boxes attain the optimum exactly: A_R^2 = |R|.
4. Every non-box loses at least the golden constant
       gamma = (3 - sqrt 5) / 2 = 1/phi^2 = 0.381966...,
   verified exhaustively over all subsets of 2x2, 3x3 and 4x3 grids.
5. The L-shape {(0,0),(0,1),(1,0)} has exact product optimum
       (3 + sqrt 5)/2 = phi^2 = 2.618034... = 3 - gamma,
   so the golden constant is optimal.
6. The crude bound |R| - 1/(9|R|) is valid but far from sharp.
7. Depth-n: a full box in D^3 is matched exactly, a non-full-box is not.
"""

from __future__ import annotations

from itertools import combinations, product
from math import cos, hypot, sin, sqrt
from typing import Dict, Iterable, List, Sequence, Tuple

Matrix = List[List[float]]
Cell = Tuple[int, int]

GOLDEN_GAP: float = (3.0 - sqrt(5.0)) / 2.0        # gamma = 1/phi^2 = 0.381966...
GOLDEN_OPT: float = (3.0 + sqrt(5.0)) / 2.0        # phi^2      = 2.618034...


# ----------------------------------------------------------------------------
# Linear algebra: symmetric eigenvalues by cyclic Jacobi, singular values from
# the eigenvalues of M^T M.  Self-contained, no external dependencies.
# ----------------------------------------------------------------------------

def transpose(m: Matrix) -> Matrix:
    """Matrix transpose."""
    return [list(col) for col in zip(*m)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Ordinary matrix product."""
    bt = transpose(b)
    return [[sum(x * y for x, y in zip(row, col)) for col in bt] for row in a]


def symmetric_eigenvalues(a: Matrix, sweeps: int = 100, tol: float = 1e-14) -> List[float]:
    """Eigenvalues of a real symmetric matrix by the cyclic Jacobi method."""
    n = len(a)
    s = [row[:] for row in a]
    for _ in range(sweeps):
        off = sqrt(sum(s[i][j] ** 2 for i in range(n) for j in range(n) if i != j))
        if off < tol:
            break
        for p in range(n - 1):
            for q in range(p + 1, n):
                if abs(s[p][q]) < tol:
                    continue
                theta = (s[q][q] - s[p][p]) / (2.0 * s[p][q])
                sign = 1.0 if theta >= 0.0 else -1.0
                t = sign / (abs(theta) + sqrt(theta * theta + 1.0))
                c = 1.0 / sqrt(t * t + 1.0)
                sn = t * c
                rot = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
                rot[p][p], rot[q][q] = c, c
                rot[p][q], rot[q][p] = sn, -sn
                s = matmul(matmul(transpose(rot), s), rot)
    return sorted((s[i][i] for i in range(n)), reverse=True)


def singular_values(m: Matrix) -> List[float]:
    """Singular values of a real matrix, in decreasing order."""
    gram = matmul(transpose(m), m)
    return [sqrt(max(0.0, lam)) for lam in symmetric_eigenvalues(gram)]


# ----------------------------------------------------------------------------
# Resonance sets, coins, amplitudes
# ----------------------------------------------------------------------------

def indicator_matrix(cells: Iterable[Cell], rows: int, cols: int) -> Matrix:
    """0/1 indicator matrix of a resonance set inside a rows x cols grid."""
    m = [[0.0] * cols for _ in range(rows)]
    for (i, j) in cells:
        m[i][j] = 1.0
    return m


def is_box(cells: Sequence[Cell]) -> bool:
    """True iff the resonance set is closed under the rectangle rule."""
    s = set(cells)
    return all((a, bp) in s for (a, _b) in s for (_ap, bp) in s)


def product_amplitude(cells: Iterable[Cell], f: Sequence[float], g: Sequence[float]) -> float:
    """Resonance amplitude A_R(f (x) g) = sum_{(a,b) in R} f(a) g(b)."""
    return sum(f[a] * g[b] for (a, b) in cells)


def general_amplitude(cells: Iterable[Cell], psi: Dict[Cell, float]) -> float:
    """Resonance amplitude of an arbitrary coin given as a dictionary."""
    return sum(psi.get(c, 0.0) for c in cells)


def best_product_amplitude_sq(cells: Sequence[Cell], rows: int, cols: int) -> float:
    """max over unit product coins of A_R(f (x) g)^2 = sigma_1(M)^2."""
    m = indicator_matrix(cells, rows, cols)
    return singular_values(m)[0] ** 2


def true_gap(cells: Sequence[Cell], rows: int, cols: int) -> float:
    """|R| - best product amplitude squared = the singular tail of M."""
    return len(cells) - best_product_amplitude_sq(cells, rows, cols)


# ----------------------------------------------------------------------------
# Demonstration 1: the exact Cauchy-Schwarz defect identity
# ----------------------------------------------------------------------------

def demo_defect_identity() -> None:
    print("=" * 74)
    print("1.  Exact Cauchy-Schwarz defect identity")
    print("=" * 74)
    rows, cols = 3, 3
    cells: List[Cell] = [(0, 0), (0, 1), (1, 0), (2, 2)]
    # an arbitrary (deliberately non-optimal) unit coin
    raw = {(i, j): sin(1.0 + 2.7 * i + 0.9 * j) + 0.3 * cos(0.5 * i * j)
           for i in range(rows) for j in range(cols)}
    norm = sqrt(sum(v * v for v in raw.values()))
    psi = {k: v / norm for k, v in raw.items()}

    card = float(len(cells))
    amp = general_amplitude(cells, psi)
    lhs = card - amp ** 2
    c = amp / card
    rhs = card * sum((psi[(i, j)] - c * (1.0 if (i, j) in set(cells) else 0.0)) ** 2
                     for i in range(rows) for j in range(cols))
    print(f"  |R| = {card:.0f},  A_R(psi) = {amp:+.6f}")
    print(f"  |R| - A^2                       = {lhs:.12f}")
    print(f"  |R| * dist(psi, span 1_R)^2     = {rhs:.12f}")
    print(f"  agreement to {abs(lhs - rhs):.2e}   (Cauchy-Schwarz is a Pythagoras theorem)")
    print()


# ----------------------------------------------------------------------------
# Demonstration 2: boxes attain the optimum exactly
# ----------------------------------------------------------------------------

def demo_box_attainment() -> None:
    print("=" * 74)
    print("2.  Boxes attain the Cauchy-Schwarz optimum |R| exactly")
    print("=" * 74)
    rows, cols = 4, 4
    s_rows, t_cols = [0, 2, 3], [1, 3]
    cells: List[Cell] = [(a, b) for a in s_rows for b in t_cols]
    f = [1.0 / sqrt(len(s_rows)) if a in s_rows else 0.0 for a in range(rows)]
    g = [1.0 / sqrt(len(t_cols)) if b in t_cols else 0.0 for b in range(cols)]
    amp = product_amplitude(cells, f, g)
    print(f"  R = {s_rows} x {t_cols},  |R| = {len(cells)},  is_box = {is_box(cells)}")
    print(f"  normalised-indicator product coin:  A^2 = {amp ** 2:.12f}")
    print(f"  spectral optimum sigma_1(M)^2      = {best_product_amplitude_sq(cells, rows, cols):.12f}")
    print(f"  Cauchy-Schwarz optimum |R|         = {len(cells)}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 3: the L-shape and the golden ratio
# ----------------------------------------------------------------------------

def demo_lshape() -> None:
    print("=" * 74)
    print("3.  The L-shape: exact product optimum (3 + sqrt 5)/2 = phi^2")
    print("=" * 74)
    cells: List[Cell] = [(0, 0), (0, 1), (1, 0)]
    print("  R = {(0,0), (0,1), (1,0)},  indicator matrix  [[1,1],[1,0]]")
    print(f"  is_box = {is_box(cells)},  |R| = {len(cells)}")

    # the explicit optimal factors
    u = (sqrt(5.0) - 1.0) / 2.0
    n = sqrt((5.0 - sqrt(5.0)) / 2.0)
    ell = sqrt((3.0 + sqrt(5.0)) / 2.0)
    f = [1.0 / n, u / n]
    g = [(1.0 + u) / (n * ell), 1.0 / (n * ell)]
    print(f"  ||f||^2 = {f[0] ** 2 + f[1] ** 2:.12f},  ||g||^2 = {g[0] ** 2 + g[1] ** 2:.12f}")
    amp_sq = product_amplitude(cells, f, g) ** 2
    print(f"  explicit coin:            A^2 = {amp_sq:.12f}")
    print(f"  spectral optimum:  sigma_1(M)^2 = {best_product_amplitude_sq(cells, 2, 2):.12f}")
    print(f"  golden value       (3+sqrt5)/2 = {GOLDEN_OPT:.12f}")
    print(f"  true gap  3 - phi^2            = {3.0 - amp_sq:.12f}")
    print(f"  golden constant (3-sqrt5)/2    = {GOLDEN_GAP:.12f}")
    print(f"  crude general bound  1/(9|R|)  = {1.0 / 27.0:.12f}   (valid, ~10x too small)")
    print()

    # brute-force confirmation by dense search over the unit circles
    best = 0.0
    steps = 2000
    for i in range(steps):
        th = 2.0 * 3.141592653589793 * i / steps
        f2 = [cos(th), sin(th)]
        # optimal g for fixed f is the normalised vector (M^T f)
        v = [f2[0] * 1.0 + f2[1] * 1.0, f2[0] * 1.0 + f2[1] * 0.0]
        nv = hypot(v[0], v[1])
        if nv == 0.0:
            continue
        g2 = [v[0] / nv, v[1] / nv]
        best = max(best, product_amplitude(cells, f2, g2) ** 2)
    print(f"  brute-force maximisation over the unit circle: A^2_max = {best:.10f}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 4: exhaustive verification of the golden gap
# ----------------------------------------------------------------------------

def exhaustive_min_gap(rows: int, cols: int) -> Tuple[float, List[Cell]]:
    """Minimum true gap over all non-box subsets of a rows x cols grid."""
    all_cells: List[Cell] = [(i, j) for i in range(rows) for j in range(cols)]
    best_gap = float("inf")
    best_set: List[Cell] = []
    for size in range(2, len(all_cells) + 1):
        for subset in combinations(all_cells, size):
            cs = list(subset)
            if is_box(cs):
                continue
            gap = true_gap(cs, rows, cols)
            if gap < best_gap - 1e-12:
                best_gap, best_set = gap, cs
    return best_gap, best_set


def demo_exhaustive_sharpness() -> None:
    print("=" * 74)
    print("4.  Exhaustive check: every non-box loses at least (3-sqrt5)/2")
    print("=" * 74)
    for (rows, cols) in [(2, 2), (3, 2), (3, 3), (4, 3)]:
        gap, witness = exhaustive_min_gap(rows, cols)
        flag = "OK" if gap >= GOLDEN_GAP - 1e-9 else "VIOLATION"
        print(f"  grid {rows}x{cols}:  min gap over non-boxes = {gap:.10f}   [{flag}]")
        print(f"              extremal set = {sorted(witness)}")
    print(f"  golden constant (3-sqrt5)/2 = {GOLDEN_GAP:.10f}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 5: the gap does not decay with |R|
# ----------------------------------------------------------------------------

def demo_gap_does_not_decay() -> None:
    print("=" * 74)
    print("5.  A single defect in a large box: the loss is an absolute constant")
    print("=" * 74)
    print("     n   |R|      true gap    golden bound    crude bound 1/(9|R|)")
    print("    ---------------------------------------------------------------")
    for n in range(2, 9):
        # the full n x n box with one cell deleted: the smallest possible defect
        cells: List[Cell] = [(i, j) for i in range(n) for j in range(n)
                             if not (i == n - 1 and j == n - 1)]
        gap = true_gap(cells, n, n)
        print(f"    {n:2d}  {len(cells):4d}   {gap:11.7f}   {GOLDEN_GAP:11.7f}"
              f"     {1.0 / (9 * len(cells)):11.7f}")
    print("    the true gap stays above the golden constant, while the crude")
    print("    bound 1/(9|R|) collapses towards zero.")
    print()


# ----------------------------------------------------------------------------
# Demonstration 6: depth 3
# ----------------------------------------------------------------------------

def depth_amplitude(cells: Sequence[Tuple[int, ...]], factors: Sequence[Sequence[float]]) -> float:
    """Amplitude of a depth-n product coin psi(x) = prod_i f_i(x_i)."""
    total = 0.0
    for x in cells:
        term = 1.0
        for i, xi in enumerate(x):
            term *= factors[i][xi]
        total += term
    return total


def demo_depth_three() -> None:
    print("=" * 74)
    print("6.  Depth 3 in {0,1}^3: full boxes are matched, others are not")
    print("=" * 74)
    # (a) a full box S0 x S1 x S2
    supports = [[0, 1], [1], [0, 1]]
    box_cells = [tuple(x) for x in product(*supports)]
    factors = [[1.0 / sqrt(len(s)) if d in s else 0.0 for d in range(2)] for s in supports]
    amp_sq = depth_amplitude(box_cells, factors) ** 2
    print(f"  full box  {supports}:  |R| = {len(box_cells)},  A^2 = {amp_sq:.12f}")

    # (b) delete one point: no longer a full box
    broken = [c for c in box_cells if c != (1, 1, 1)]
    # split off coordinate 0 and use the depth-2 spectral optimum
    rows = 2
    cols = 4

    def flatten(x: Tuple[int, ...]) -> Cell:
        return (x[0], 2 * x[1] + x[2])

    flat = [flatten(x) for x in broken]
    best = best_product_amplitude_sq(flat, rows, cols)
    print(f"  broken box (one point deleted): |R| = {len(broken)}")
    print(f"     best two-block product amplitude^2 = {best:.12f}")
    print(f"     loss = {len(broken) - best:.12f}  >=  golden {GOLDEN_GAP:.12f}")
    print("     (a depth-3 product coin is in particular a two-block product coin,")
    print("      so it cannot do better than this.)")
    print()


def main() -> None:
    print()
    print("RIGIDITY GAP FOR SHALLOW PRODUCT COINS")
    print("golden constant gamma = (3 - sqrt 5)/2 = {:.12f}".format(GOLDEN_GAP))
    print("golden optimum      phi^2 = (3 + sqrt 5)/2 = {:.12f}".format(GOLDEN_OPT))
    print()
    demo_defect_identity()
    demo_box_attainment()
    demo_lshape()
    demo_exhaustive_sharpness()
    demo_gap_does_not_decay()
    demo_depth_three()


if __name__ == "__main__":
    main()
