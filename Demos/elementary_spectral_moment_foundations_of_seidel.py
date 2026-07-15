#!/usr/bin/env python3
"""Numerical demonstrations of Seidel moments and triangle holonomy.

The script uses only the Python standard library.  It constructs Seidel matrices,
computes exact traces by integer matrix arithmetic, enumerates triple parities,
checks switching invariance, and verifies the local cubic update after deleting
an edge.
"""

from __future__ import annotations

from itertools import combinations
from typing import Iterable, Sequence

Matrix = list[list[int]]
Edge = tuple[int, int]


def normalize_edges(edges: Iterable[Edge]) -> set[Edge]:
    """Return undirected edges as sorted endpoint pairs."""
    return {tuple(sorted((a, b))) for a, b in edges if a != b}


def seidel_matrix(n: int, edges: Iterable[Edge]) -> Matrix:
    """Construct the n-by-n Seidel matrix of a finite simple graph."""
    edge_set = normalize_edges(edges)
    return [
        [0 if i == j else (-1 if tuple(sorted((i, j))) in edge_set else 1)
         for j in range(n)]
        for i in range(n)
    ]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Multiply two square integer matrices."""
    n = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(n))
             for j in range(n)] for i in range(n)]


def trace(a: Matrix) -> int:
    """Return the trace of a square matrix."""
    return sum(a[i][i] for i in range(len(a)))


def spectral_moments(s: Matrix) -> tuple[int, int, int]:
    """Return the first three exact moments tr(S), tr(S^2), tr(S^3)."""
    s2 = matmul(s, s)
    s3 = matmul(s2, s)
    return trace(s), trace(s2), trace(s3)


def triangle_parity_counts(n: int, edges: Iterable[Edge]) -> tuple[int, int]:
    """Count unordered vertex triples with even and odd induced edge counts."""
    edge_set = normalize_edges(edges)
    even = odd = 0
    for i, j, k in combinations(range(n), 3):
        count = sum(
            tuple(sorted(pair)) in edge_set
            for pair in ((i, j), (j, k), (k, i))
        )
        if count % 2 == 0:
            even += 1
        else:
            odd += 1
    return even, odd


def switch_matrix(s: Matrix, signs: Sequence[int]) -> Matrix:
    """Apply diagonal sign switching S_ij -> d_i S_ij d_j."""
    if len(s) != len(signs) or any(d not in (-1, 1) for d in signs):
        raise ValueError("signs must contain one value in {-1,+1} per vertex")
    return [[signs[i] * s[i][j] * signs[j] for j in range(len(s))]
            for i in range(len(s))]


def delete_edge(edges: Iterable[Edge], edge: Edge) -> set[Edge]:
    """Delete one undirected edge from an edge set."""
    result = normalize_edges(edges)
    target = tuple(sorted(edge))
    if target not in result:
        raise ValueError(f"{target} is not an edge")
    result.remove(target)
    return result


def demonstrate_triangle_identity() -> None:
    """Compare cubic matrix traces with six times the parity imbalance."""
    examples = {
        "empty triangle": (3, set()),
        "complete triangle": (3, {(0, 1), (1, 2), (0, 2)}),
        "five-cycle": (5, {(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)}),
    }
    print("1. Cubic trace as signed triple parity")
    for name, (n, edges) in examples.items():
        moments = spectral_moments(seidel_matrix(n, edges))
        even, odd = triangle_parity_counts(n, edges)
        parity_value = 6 * (even - odd)
        assert moments[2] == parity_value
        assert moments[0] == 0 and moments[1] == n * (n - 1)
        print(f"   {name:18s}: moments={moments}, "
              f"(N_even,N_odd)=({even},{odd}), 6Δ={parity_value}")


def demonstrate_switching() -> None:
    """Show that triangle holonomy and the cubic trace survive switching."""
    n = 6
    edges = {(0, 1), (0, 2), (1, 3), (2, 4), (3, 4), (4, 5)}
    signs = (-1, 1, -1, 1, 1, -1)
    s = seidel_matrix(n, edges)
    switched = switch_matrix(s, signs)
    before = spectral_moments(s)
    after = spectral_moments(switched)
    for i, j, k in combinations(range(n), 3):
        lhs = switched[i][j] * switched[j][k] * switched[k][i]
        rhs = s[i][j] * s[j][k] * s[k][i]
        assert lhs == rhs
    assert before == after
    print("\n2. Switching invariance")
    print(f"   signs={signs}")
    print(f"   moments before={before}, after={after}")
    print("   every unordered triangle product is unchanged")


def demonstrate_edge_deletion_update() -> None:
    """Verify Δ tr(S^3) = 12(S^2)_ab for deletion of an existing edge."""
    n = 7
    edges = {(0, 1), (0, 2), (0, 3), (1, 4), (1, 5),
             (2, 3), (2, 6), (3, 5), (4, 6)}
    edge = (0, 1)
    s = seidel_matrix(n, edges)
    s2 = matmul(s, s)
    old_cube = spectral_moments(s)[2]
    reduced = seidel_matrix(n, delete_edge(edges, edge))
    new_cube = spectral_moments(reduced)[2]
    predicted = 12 * s2[edge[0]][edge[1]]
    observed = new_cube - old_cube
    assert observed == predicted
    print("\n3. Local cubic update under edge deletion")
    print(f"   deleted edge={edge}, (S^2)_ab={s2[edge[0]][edge[1]]}")
    print(f"   old trace={old_cube}, new trace={new_cube}")
    print(f"   observed change={observed}, predicted change={predicted}")


def main() -> None:
    demonstrate_triangle_identity()
    demonstrate_switching()
    demonstrate_edge_deletion_update()


if __name__ == "__main__":
    main()
