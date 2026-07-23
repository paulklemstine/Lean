"""Test the conjectured extremal bounds for the signed resistance determinant
on small connected graphs using the Laplacian-pseudoinverse resistance matrix."""
from __future__ import annotations
from itertools import combinations
from typing import List, Sequence, Tuple


def laplacian(n: int, edges: Sequence[Tuple[int, int]]) -> List[List[float]]:
    L = [[0.0] * n for _ in range(n)]
    for u, v in edges:
        L[u][u] += 1.0; L[v][v] += 1.0; L[u][v] -= 1.0; L[v][u] -= 1.0
    return L


def inv(a: List[List[float]]) -> List[List[float]]:
    n = len(a)
    aug = [row[:] + [1.0 if i == j else 0.0 for j in range(n)] for i, row in enumerate(a)]
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(aug[r][c]))
        aug[c], aug[p] = aug[p], aug[c]
        d = aug[c][c]; aug[c] = [x / d for x in aug[c]]
        for r in range(n):
            if r != c:
                f = aug[r][c]; aug[r] = [x - f * y for x, y in zip(aug[r], aug[c])]
    return [row[n:] for row in aug]


def resistance_matrix(n: int, edges: Sequence[Tuple[int, int]]) -> List[List[float]]:
    L = laplacian(n, edges); jn = 1.0 / n
    shifted = [[L[i][j] + jn for j in range(n)] for i in range(n)]
    Lp_full = inv(shifted)
    Lp = [[Lp_full[i][j] - jn for j in range(n)] for i in range(n)]
    return [[Lp[i][i] + Lp[j][j] - 2.0 * Lp[i][j] for j in range(n)] for i in range(n)]


def det(m: List[List[float]]) -> float:
    n = len(m); a = [r[:] for r in m]; d = 1.0
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(a[r][c]))
        if abs(a[p][c]) < 1e-14:
            return 0.0
        if p != c:
            a[c], a[p] = a[p], a[c]; d = -d
        d *= a[c][c]
        for r in range(c + 1, n):
            f = a[r][c] / a[c][c]
            for k in range(c, n):
                a[r][k] -= f * a[c][k]
    return d


def signed_det(n: int, edges: Sequence[Tuple[int, int]]) -> float:
    return ((-1) ** (n - 1)) * det(resistance_matrix(n, edges))


def main() -> None:
    n = 5
    lo = (2 / n) ** n * (n - 1)
    hi = (n - 1) * 2 ** (n - 2)
    verts = list(range(n))
    all_edges = list(combinations(verts, 2))
    tree_edges = [(0, 1), (1, 2), (2, 3), (3, 4)]
    print(f"n={n}: bounds [{lo:.5f}, {hi}]")
    print("complete:", round(signed_det(n, all_edges), 5))
    print("path:    ", round(signed_det(n, tree_edges), 5))


if __name__ == "__main__":
    main()
