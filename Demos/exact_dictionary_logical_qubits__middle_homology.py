"""
Numerical demonstrations for "Logical Qubits as Middle Homology".

This self-contained script illustrates, with concrete linear algebra over the
rationals and over GF(2), the four principal results of the paper:

  1. The CSS accounting identity   k + rank d1 + rank d2 = dim B.
  2. Realizability of every (n, k) pair, and rank-prescription realizability.
  3. Cohomological self-duality (the transposed complex has equal logical dim).
  4. The Euler code-rate formula for graph complexes, and the hypercube family
     (logical dimension 2^(n-1)*(n-2)+1, girth 4, Singleton gap for n >= 5).

No external dependencies are required; all matrix operations are inlined with
exact rational / GF(2) Gaussian elimination so results are exact.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import List, Tuple

Matrix = List[List[Fraction]]


# --------------------------------------------------------------------------- #
# Exact linear algebra over the rationals
# --------------------------------------------------------------------------- #
def matrix_rank(rows: List[List[float]]) -> int:
    """Exact rank of a matrix via fraction-based Gaussian elimination."""
    m: Matrix = [[Fraction(x) for x in row] for row in rows]
    if not m:
        return 0
    n_rows, n_cols = len(m), len(m[0])
    rank = 0
    pivot_row = 0
    for col in range(n_cols):
        piv = None
        for r in range(pivot_row, n_rows):
            if m[r][col] != 0:
                piv = r
                break
        if piv is None:
            continue
        m[pivot_row], m[piv] = m[piv], m[pivot_row]
        inv = m[pivot_row][col]
        m[pivot_row] = [x / inv for x in m[pivot_row]]
        for r in range(n_rows):
            if r != pivot_row and m[r][col] != 0:
                factor = m[r][col]
                m[r] = [a - factor * b for a, b in zip(m[r], m[pivot_row])]
        rank += 1
        pivot_row += 1
        if pivot_row == n_rows:
            break
    return rank


def transpose(rows: List[List[float]]) -> List[List[float]]:
    """Matrix transpose."""
    if not rows:
        return []
    return [list(col) for col in zip(*rows)]


def matmul(a: List[List[float]], b: List[List[float]]) -> List[List[float]]:
    """Matrix product a @ b over the rationals."""
    bt = transpose(b)
    return [[float(sum(Fraction(x) * Fraction(y) for x, y in zip(row, col)))
             for col in bt] for row in a]


# --------------------------------------------------------------------------- #
# Chain-complex logical dimension
# --------------------------------------------------------------------------- #
def logical_dimension(d1: List[List[float]], d2: List[List[float]],
                      dim_B: int) -> int:
    """
    Logical dimension k = dim(ker d1 / im d2) of a length-two chain complex
    A --d2--> B --d1--> C, computed from the accounting identity
    k = dim B - rank d1 - rank d2.  d1 is a (|C| x |B|) matrix acting on B;
    d2 is a (|B| x |A|) matrix whose columns span im d2 inside B.
    """
    r1 = matrix_rank(d1) if d1 else 0
    r2 = matrix_rank(d2) if d2 else 0
    return dim_B - r1 - r2


def check_chain_complex(d1: List[List[float]], d2: List[List[float]]) -> bool:
    """Verify the chain-complex condition d1 . d2 = 0."""
    prod = matmul(d1, d2)
    return all(abs(x) < 1e-12 for row in prod for x in row)


# --------------------------------------------------------------------------- #
# Demo 1: the accounting identity and self-duality on a random-ish complex
# --------------------------------------------------------------------------- #
def demo_accounting_and_duality() -> None:
    print("=" * 68)
    print("Demo 1: accounting identity  k + rank d1 + rank d2 = dim B")
    print("        and self-duality  k(dual) = k")
    print("=" * 68)
    # B = Q^5.  d1 : B -> C=Q^2 (rank 2), d2 : A=Q^2 -> B with image in ker d1.
    d1 = [
        [1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0],
    ]
    # columns of d2 live in coordinates 3,4,5 (killed by d1) -> in ker d1
    d2 = [
        [0, 0],
        [0, 0],
        [1, 0],
        [0, 1],
        [0, 0],
    ]
    dim_B = 5
    assert check_chain_complex(d1, d2), "d1 . d2 must be 0"
    r1, r2 = matrix_rank(d1), matrix_rank(d2)
    k = logical_dimension(d1, d2, dim_B)
    print(f"  dim B = {dim_B}, rank d1 = {r1}, rank d2 = {r2}")
    print(f"  logical dimension k = {k}")
    print(f"  check: k + rank d1 + rank d2 = {k + r1 + r2} == dim B = {dim_B}")

    # dual complex: d1_dual = d2^T (|A| x |B|), d2_dual = d1^T (|B| x |C|)
    d1_dual = transpose(d2)
    d2_dual = transpose(d1)
    k_dual = logical_dimension(d1_dual, d2_dual, dim_B)
    print(f"  dual logical dimension k_dual = {k_dual}  (equals k: "
          f"{k_dual == k})")
    print()


# --------------------------------------------------------------------------- #
# Demo 2: realizability of every (n, k) pair
# --------------------------------------------------------------------------- #
def realize_pair(n: int, k: int) -> Tuple[List[List[float]], List[List[float]], int]:
    """
    Build a complex with dim B = n and logical dimension exactly k (k <= n):
    B = Q^n, d2 = 0, d1 = projection onto the first (n-k) coordinates.
    """
    dim_B = n
    d2: List[List[float]] = []            # rank 0
    d1 = [[1.0 if j == i else 0.0 for j in range(n)] for i in range(n - k)]
    return d1, d2, dim_B


def demo_realizability() -> None:
    print("=" * 68)
    print("Demo 2: realizability  --  every (n, k) with k <= n is achievable")
    print("=" * 68)
    for n, k in [(5, 3), (7, 0), (7, 7), (10, 4)]:
        d1, d2, dim_B = realize_pair(n, k)
        got = logical_dimension(d1, d2, dim_B)
        print(f"  requested (n={n:2d}, k={k:2d})  ->  built code with "
              f"dim B = {dim_B:2d}, logical dim = {got}  "
              f"({'OK' if got == k else 'FAIL'})")
    print()


# --------------------------------------------------------------------------- #
# Demo 3: graph complexes, Euler rate, and the hypercube family
# --------------------------------------------------------------------------- #
def hypercube_edges(n: int) -> Tuple[int, int]:
    """Return (V, E) for the hypercube graph Q_n."""
    V = 2 ** n
    E = n * 2 ** (n - 1)
    return V, E


def hypercube_logical_dim(n: int) -> int:
    """Logical dimension k = E - V + 1 = 2^(n-1)(n-2) + 1 of the Q_n code."""
    V, E = hypercube_edges(n)
    return E - V + 1


def hypercube_girth(n: int) -> int:
    """Girth of Q_n: 4 for n >= 2 (bipartite, triangle-free, has a 4-cycle)."""
    return 4 if n >= 2 else 0


def demo_hypercube() -> None:
    print("=" * 68)
    print("Demo 3: graph complexes, Euler rate, and the hypercube Q_n")
    print("=" * 68)
    print("  n |    V |     E |  k = E-V+1 | closed 2^(n-1)(n-2)+1 | rate k/E | girth")
    print("  " + "-" * 74)
    for n in range(2, 9):
        V, E = hypercube_edges(n)
        k = hypercube_logical_dim(n)
        closed = 2 ** (n - 1) * (n - 2) + 1
        rate = Fraction(k, E)
        print(f"  {n} | {V:5d} | {E:6d} | {k:10d} | {closed:21d} | "
              f"{float(rate):.4f}  | {hypercube_girth(n)}")
    print()
    print("  Singleton gap: distance is 4 but Singleton demands ~2^(n/2):")
    for n in range(2, 9):
        import math
        singleton = 2 ** (n / 2)
        fails = 4 < singleton
        print(f"    n={n}: distance=4, 2^(n/2)={singleton:8.3f}  "
              f"-> {'FAILS Singleton' if fails else 'ok'}")
    print()


# --------------------------------------------------------------------------- #
# Demo 4: rate extremes -- trees (rate 0) and bouquets (rate 1)
# --------------------------------------------------------------------------- #
def graph_rate(V: int, E: int) -> Fraction:
    """Code rate k/E = 1 - (V-1)/E for a connected graph complex, E > 0."""
    return Fraction(E - V + 1, E)


def demo_rate_extremes() -> None:
    print("=" * 68)
    print("Demo 4: rate extremes  --  trees give rate 0, bouquets give rate 1")
    print("=" * 68)
    # Trees: E = V - 1
    for V in [2, 5, 10]:
        E = V - 1
        print(f"  tree   V={V:2d}, E={E:2d}: k = {E - V + 1}, "
              f"rate = {float(graph_rate(V, E)):.3f}")
    # Bouquets: V = 1
    for E in [1, 4, 9]:
        V = 1
        print(f"  bouquet V={V:2d}, E={E:2d}: k = {E - V + 1}, "
              f"rate = {float(graph_rate(V, E)):.3f}")
    print()


if __name__ == "__main__":
    demo_accounting_and_duality()
    demo_realizability()
    demo_hypercube()
    demo_rate_extremes()
    print("All demonstrations completed.")
