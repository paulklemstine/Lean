"""Numerical demonstration of clique counts in Latin square graphs.

For a Latin square M of order n, the Latin square graph L(M) has the n^2 cells
as vertices; two distinct cells are adjacent when they share a row, share a
column, or carry the same symbol. This script verifies, by direct enumeration:

  * Triangle count  = 3n * C(n,3) + n^2 (n-1) = n^3 (n-1) / 2   (independent of M)
  * Tetrahedron count (K4) = 3n * C(n,4) + I(M)
  * I(M) = number of intercalates (2x2 Latin subsquares)

It also exhibits the refutation of the previously proposed (and false) formulas
  triangles = n^2 (n-1)^2,   K4 = (n-1)^3 n^2 - 6 I(M).
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Callable, List, Tuple

Cell = Tuple[int, int]
Square = Callable[[int, int], int]


def cyclic_square(n: int) -> Square:
    """The cyclic Latin square of order n: M(i, j) = (i + j) mod n."""
    return lambda i, j: (i + j) % n


def is_latin(M: Square, n: int) -> bool:
    """Check that every row and every column of M is a permutation of 0..n-1."""
    for i in range(n):
        if len({M(i, j) for j in range(n)}) != n:
            return False
    for j in range(n):
        if len({M(i, j) for i in range(n)}) != n:
            return False
    return True


def cells(n: int) -> List[Cell]:
    """All n^2 cells (row, column) of the grid."""
    return [(i, j) for i in range(n) for j in range(n)]


def adjacent(M: Square, p: Cell, q: Cell) -> bool:
    """Adjacency in the Latin square graph: shared row, column, or symbol."""
    (i, j), (k, l) = p, q
    return i == k or j == l or M(i, j) == M(k, l)


def is_clique(M: Square, S: Tuple[Cell, ...]) -> bool:
    """Whether the cells in S are pairwise adjacent."""
    return all(adjacent(M, S[a], S[b]) for a in range(len(S)) for b in range(a + 1, len(S)))


def count_cliques(M: Square, n: int, k: int) -> int:
    """Brute-force count of k-vertex cliques of L(M)."""
    return sum(1 for S in combinations(cells(n), k) if is_clique(M, S))


def count_intercalates(M: Square, n: int) -> int:
    """Count 2x2 Latin subsquares: i<i', j<j', M(i,j)=M(i',j'), M(i,j')=M(i',j)."""
    total = 0
    for i in range(n):
        for ip in range(i + 1, n):
            for j in range(n):
                for jp in range(j + 1, n):
                    if M(i, j) == M(ip, jp) and M(i, jp) == M(ip, j):
                        total += 1
    return total


def triangle_formula(n: int) -> int:
    """Correct triangle count: 3n*C(n,3) + n^2(n-1) = n^3(n-1)//2."""
    return 3 * n * comb(n, 3) + n * n * (n - 1)


def tetra_formula(n: int, intercalates: int) -> int:
    """Correct K4 count: 3n*C(n,4) + I(M)."""
    return 3 * n * comb(n, 4) + intercalates


def demo() -> None:
    print("=" * 68)
    print("Clique counts in Latin square graphs")
    print("=" * 68)

    for n in [4, 5, 6]:
        M = cyclic_square(n)
        assert is_latin(M, n), f"cyclic square of order {n} is not Latin"

        tri = count_cliques(M, n, 3)
        tet = count_cliques(M, n, 4)
        I = count_intercalates(M, n)

        print(f"\nCyclic Latin square of order n = {n}")
        print(f"  intercalates I(M)         = {I}")
        print(f"  triangles (enumerated)    = {tri}")
        print(f"  triangles (formula)       = {triangle_formula(n)}"
              f"   [= n^3(n-1)/2 = {n**3 * (n-1) // 2}]")
        assert tri == triangle_formula(n) == n**3 * (n - 1) // 2
        print(f"  tetrahedra (enumerated)   = {tet}")
        print(f"  tetrahedra (formula)      = {tetra_formula(n, I)}"
              f"   [= 3n*C(n,4) + I(M)]")
        assert tet == tetra_formula(n, I)

    print("\n" + "=" * 68)
    print("Refutation of the previously proposed (false) formulas at n = 5")
    print("=" * 68)
    n = 5
    M = cyclic_square(n)
    I = count_intercalates(M, n)
    tri, tet = count_cliques(M, n, 3), count_cliques(M, n, 4)

    proposed_tri = n**2 * (n - 1) ** 2
    proposed_tet = (n - 1) ** 3 * n**2 - 6 * I
    print(f"  proposed triangles n^2(n-1)^2        = {proposed_tri}  (FALSE)")
    print(f"  true triangles                       = {tri}")
    assert tri != proposed_tri
    print(f"  proposed K4 (n-1)^3 n^2 - 6 I(M)      = {proposed_tet}  (FALSE)")
    print(f"  true K4                              = {tet}")
    assert tet != proposed_tet
    print("\n  The proposal also claimed the top boundary map vanishes, yet")
    print(f"  L(C_5) has {tet} tetrahedra, so over any field the boundary of a")
    print("  single tetrahedron (sum of its 4 faces) is already nonzero:")
    print("  rank(d_3) >= 1, contradicting rank(d_3) = 6 I(M) = 0.")

    print("\nAll assertions passed: enumerations match the corrected formulas.")


if __name__ == "__main__":
    demo()
