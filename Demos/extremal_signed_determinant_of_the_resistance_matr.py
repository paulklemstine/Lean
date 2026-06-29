"""Numerical demonstrations of the extremal signed resistance determinant results.

This self-contained script verifies, for the complete graph K_n and the path P_n
(a tree), the closed forms proved formally:

    Delta(K_n) = (-1)^(n-1) det R(K_n) = (2/n)^n (n-1)
    Delta(P_n) = (-1)^(n-1) det R(P_n) = (n-1) 2^(n-2)      [Graham-Pollak value]

It also computes the effective-resistance matrix of an arbitrary connected graph
from its Laplacian pseudoinverse and tests the conjectured extremal bounds

    2^n (n-1) / n^n  <=  Delta(G)  <=  2^(n-2) (n-1)

on small connected graphs. All linear algebra is done with the standard library
and `fractions.Fraction` for exact rational arithmetic where feasible; the
pseudoinverse step uses floating point.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Exact rational determinant (Bareiss / fraction-free Gaussian elimination).
# --------------------------------------------------------------------------- #
def det_exact(matrix: Sequence[Sequence[Fraction]]) -> Fraction:
    """Return the exact determinant of a square rational matrix."""
    n: int = len(matrix)
    a: List[List[Fraction]] = [[Fraction(x) for x in row] for row in matrix]
    det: Fraction = Fraction(1)
    for col in range(n):
        pivot: int = -1
        for r in range(col, n):
            if a[r][col] != 0:
                pivot = r
                break
        if pivot == -1:
            return Fraction(0)
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            det = -det
        det *= a[col][col]
        inv: Fraction = Fraction(1) / a[col][col]
        for r in range(col + 1, n):
            factor: Fraction = a[r][col] * inv
            if factor != 0:
                for c in range(col, n):
                    a[r][c] -= factor * a[col][c]
    return det


# --------------------------------------------------------------------------- #
# Complete graph K_n.
# --------------------------------------------------------------------------- #
def complete_resistance_matrix(n: int) -> List[List[Fraction]]:
    """Resistance matrix of K_n: off-diagonal 2/n, zero diagonal."""
    val: Fraction = Fraction(2, n)
    return [[Fraction(0) if i == j else val for j in range(n)] for i in range(n)]


def signed_det_complete(n: int) -> Fraction:
    """Delta(K_n) computed directly from the matrix determinant."""
    d: Fraction = det_exact(complete_resistance_matrix(n))
    return Fraction((-1) ** (n - 1)) * d


def signed_det_complete_formula(n: int) -> Fraction:
    """Closed form (2/n)^n (n-1)."""
    return Fraction(2, n) ** n * (n - 1)


# --------------------------------------------------------------------------- #
# Path P_n (canonical tree): distance matrix D_ij = |i - j|.
# --------------------------------------------------------------------------- #
def path_distance_matrix(n: int) -> List[List[Fraction]]:
    """Distance/resistance matrix of P_n: D_ij = |i - j|."""
    return [[Fraction(abs(i - j)) for j in range(n)] for i in range(n)]


def signed_det_path(n: int) -> Fraction:
    """Delta(P_n) computed directly from the matrix determinant."""
    d: Fraction = det_exact(path_distance_matrix(n))
    return Fraction((-1) ** (n - 1)) * d


def signed_det_path_formula(n: int) -> Fraction:
    """Graham-Pollak closed form (n-1) 2^(n-2). For n == 1 this is 0."""
    if n == 1:
        return Fraction(0)
    return Fraction((n - 1) * 2 ** (n - 2))


# --------------------------------------------------------------------------- #
# General connected graph: resistance matrix via Laplacian pseudoinverse.
# --------------------------------------------------------------------------- #
def laplacian(n: int, edges: Sequence[Tuple[int, int]]) -> List[List[float]]:
    """Combinatorial Laplacian L = D - A for unit-weight edges."""
    L: List[List[float]] = [[0.0] * n for _ in range(n)]
    for u, v in edges:
        L[u][u] += 1.0
        L[v][v] += 1.0
        L[u][v] -= 1.0
        L[v][u] -= 1.0
    return L


def _matmul(a: List[List[float]], b: List[List[float]]) -> List[List[float]]:
    n, m, p = len(a), len(b), len(b[0])
    out = [[0.0] * p for _ in range(n)]
    for i in range(n):
        for k in range(m):
            aik = a[i][k]
            if aik:
                for j in range(p):
                    out[i][j] += aik * b[k][j]
    return out


def _inv(a: List[List[float]]) -> List[List[float]]:
    n = len(a)
    aug = [row[:] + [1.0 if i == j else 0.0 for j in range(n)] for i, row in enumerate(a)]
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(aug[r][col]))
        aug[col], aug[piv] = aug[piv], aug[col]
        d = aug[col][col]
        aug[col] = [x / d for x in aug[col]]
        for r in range(n):
            if r != col:
                f = aug[r][col]
                aug[r] = [x - f * y for x, y in zip(aug[r], aug[col])]
    return [row[n:] for row in aug]


def pseudoinverse(L: List[List[float]]) -> List[List[float]]:
    """Moore-Penrose pseudoinverse of a symmetric Laplacian via the
    reduced-inverse trick: L^+ = (L + J/n)^{-1} - J/n."""
    n = len(L)
    jn = 1.0 / n
    shifted = [[L[i][j] + jn for j in range(n)] for i in range(n)]
    inv = _inv(shifted)
    return [[inv[i][j] - jn for j in range(n)] for i in range(n)]


def effective_resistance_matrix(n: int, edges: Sequence[Tuple[int, int]]) -> List[List[float]]:
    """R(i,j) = L^+_ii + L^+_jj - 2 L^+_ij."""
    Lp = pseudoinverse(laplacian(n, edges))
    return [[Lp[i][i] + Lp[j][j] - 2.0 * Lp[i][j] for j in range(n)] for i in range(n)]


def det_float(matrix: List[List[float]]) -> float:
    n = len(matrix)
    a = [row[:] for row in matrix]
    det = 1.0
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(a[r][col]))
        if abs(a[piv][col]) < 1e-14:
            return 0.0
        if piv != col:
            a[col], a[piv] = a[piv], a[col]
            det = -det
        det *= a[col][col]
        for r in range(col + 1, n):
            f = a[r][col] / a[col][col]
            for c in range(col, n):
                a[r][c] -= f * a[col][c]
    return det


def signed_det_graph(n: int, edges: Sequence[Tuple[int, int]]) -> float:
    return ((-1) ** (n - 1)) * det_float(effective_resistance_matrix(n, edges))


# --------------------------------------------------------------------------- #
# Demonstrations.
# --------------------------------------------------------------------------- #
def demo_endpoints() -> None:
    print("=== Signed resistance determinant at the two endpoints ===\n")
    print(f"{'n':>3} | {'Delta(K_n)':>14} | formula (2/n)^n(n-1) | "
          f"{'Delta(P_n)':>10} | formula (n-1)2^(n-2)")
    print("-" * 80)
    for n in range(2, 9):
        kd = signed_det_complete(n)
        kf = signed_det_complete_formula(n)
        pd = signed_det_path(n)
        pf = signed_det_path_formula(n)
        assert kd == kf, (n, kd, kf)
        assert pd == pf, (n, pd, pf)
        print(f"{n:>3} | {str(kd):>14} | {str(kf):>20} | "
              f"{str(pd):>10} | {str(pf):>18}")
    print("\nAll closed forms verified exactly.\n")


def demo_gap() -> None:
    print("=== The exponential gap Delta(tree)/Delta(K_n) = n^n / 4 ===\n")
    for n in range(2, 9):
        ratio = signed_det_path_formula(n) / signed_det_complete_formula(n)
        predicted = Fraction(n ** n, 4)
        assert ratio == predicted, (n, ratio, predicted)
        print(f"n={n}: ratio = {ratio}  =  n^n/4 = {predicted}")
    print()


def demo_conjecture() -> None:
    print("=== Testing the extremal bounds on small connected graphs ===\n")
    print("Bound:  Delta(K_n) <= Delta(G) <= Delta(P_n)\n")
    # A small zoo of connected graphs on n = 4 vertices.
    n = 4
    graphs = {
        "path P4":      [(0, 1), (1, 2), (2, 3)],
        "star K1,3":    [(0, 1), (0, 2), (0, 3)],
        "cycle C4":     [(0, 1), (1, 2), (2, 3), (3, 0)],
        "paw":          [(0, 1), (1, 2), (2, 0), (2, 3)],
        "diamond":      [(0, 1), (1, 2), (2, 0), (0, 3), (1, 3)],
        "complete K4":  [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)],
    }
    lo = float(signed_det_complete_formula(n))
    hi = float(signed_det_path_formula(n))
    print(f"  lower (K_4) = {lo:.6f},  upper (tree) = {hi:.6f}\n")
    for name, edges in graphs.items():
        val = signed_det_graph(n, edges)
        ok = lo - 1e-9 <= val <= hi + 1e-9
        print(f"  {name:<12}: Delta = {val:8.5f}   within bounds: {ok}")
    print()


def demo_arrowhead() -> None:
    print("=== Arrowhead reduction check for the path P_n ===\n")
    for n in range(1, 7):
        D = path_distance_matrix(n)
        det = det_exact(D)
        # closed form (n-1)(-2)^(n-1)/2
        formula = Fraction((n - 1) * (-2) ** (n - 1), 2) if n >= 1 else Fraction(0)
        print(f"n={n}: det D = {det}  vs  (n-1)(-2)^(n-1)/2 = {formula}")
        assert det == formula, (n, det, formula)
    print()


if __name__ == "__main__":
    demo_endpoints()
    demo_gap()
    demo_arrowhead()
    demo_conjecture()
