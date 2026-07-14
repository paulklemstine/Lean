"""
Numerical demonstrations for:

    Higher Spectral Moments of the Seidel Matrix under Edge Flips

The Seidel matrix S of a finite simple graph has 0 on the diagonal, -1 on
adjacent pairs, and +1 on non-adjacent distinct pairs. This script verifies,
on concrete graphs, the main results of the paper:

  * tr(S)   = 0                              (first moment vanishes)
  * tr(S^2) = n(n-1)                         (second moment is graph-independent)
  * E_S >= sqrt(n(n-1))                      (universal energy floor)
  * deleting an edge {a,b}:
        - tr(S^2) is UNCHANGED
        - tr(S^3) changes by exactly 12 * (S^2)_{a,b}
  * complementing a graph negates S, so the Seidel energy is preserved.

Only the standard library and NumPy are used.
"""

from __future__ import annotations

from itertools import combinations
from typing import Iterable

import numpy as np


# ---------------------------------------------------------------------------
# Core constructions
# ---------------------------------------------------------------------------
def seidel_matrix(n: int, edges: Iterable[tuple[int, int]]) -> np.ndarray:
    """Return the n x n Seidel matrix of the simple graph with given edges.

    Entry (i, j) is 0 if i == j, -1 if {i, j} is an edge, and +1 otherwise.
    """
    edge_set = {frozenset(e) for e in edges}
    S = np.ones((n, n), dtype=float)
    for i in range(n):
        S[i, i] = 0.0
    for i in range(n):
        for j in range(i + 1, n):
            if frozenset((i, j)) in edge_set:
                S[i, j] = S[j, i] = -1.0
            else:
                S[i, j] = S[j, i] = 1.0
    return S


def spectral_moment(S: np.ndarray, k: int) -> float:
    """Return the k-th spectral moment tr(S^k) = sum of k-th powers of eigenvalues."""
    return float(np.trace(np.linalg.matrix_power(S, k)))


def seidel_energy(S: np.ndarray) -> float:
    """Return the Seidel energy: sum of absolute values of the eigenvalues."""
    eigenvalues = np.linalg.eigvalsh(S)  # S is real symmetric
    return float(np.sum(np.abs(eigenvalues)))


def complement_edges(n: int, edges: Iterable[tuple[int, int]]) -> list[tuple[int, int]]:
    """Return the edge list of the complement graph on n vertices."""
    edge_set = {frozenset(e) for e in edges}
    return [(i, j) for i, j in combinations(range(n), 2)
            if frozenset((i, j)) not in edge_set]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_moment_identities() -> None:
    print("=" * 70)
    print("First & second moment identities (tr S = 0, tr S^2 = n(n-1))")
    print("=" * 70)
    graphs = {
        "K3 (triangle)": (3, [(0, 1), (0, 2), (1, 2)]),
        "P3 (path)": (3, [(0, 1), (1, 2)]),
        "C5 (5-cycle)": (5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]),
        "K4 (complete)": (4, list(combinations(range(4), 2))),
        "Empty on 6": (6, []),
    }
    for name, (n, edges) in graphs.items():
        S = seidel_matrix(n, edges)
        m1, m2 = spectral_moment(S, 1), spectral_moment(S, 2)
        print(f"  {name:16s}: tr(S) = {m1:5.1f}   tr(S^2) = {m2:6.1f}   "
              f"n(n-1) = {n * (n - 1)}")
    print()


def demo_energy_floor() -> None:
    print("=" * 70)
    print("Universal energy floor  E_S >= sqrt(n(n-1))")
    print("=" * 70)
    graphs = {
        "K3": (3, [(0, 1), (0, 2), (1, 2)]),
        "C5": (5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]),
        "K5": (5, list(combinations(range(5), 2))),
        "Petersen": (10, [
            (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),
            (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),
            (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),
        ]),
    }
    for name, (n, edges) in graphs.items():
        S = seidel_matrix(n, edges)
        E = seidel_energy(S)
        floor = np.sqrt(n * (n - 1))
        print(f"  {name:10s}: E_S = {E:8.4f}   floor = {floor:8.4f}   "
              f"ratio = {E / floor:6.4f}   ok = {E >= floor - 1e-9}")
    print()


def demo_edge_flip() -> None:
    print("=" * 70)
    print("Third-moment edge-flip law:  delta tr(S^3) = 12 * (S^2)_{a,b}")
    print("=" * 70)
    n = 6
    base_edges = [(0, 1), (0, 2), (1, 2), (1, 3), (2, 4), (3, 4), (4, 5), (0, 5)]
    S = seidel_matrix(n, base_edges)
    S2 = S @ S
    m2_before, m3_before = spectral_moment(S, 2), spectral_moment(S, 3)
    for (a, b) in base_edges:
        remaining = [e for e in base_edges if frozenset(e) != frozenset((a, b))]
        S_del = seidel_matrix(n, remaining)
        m2_after = spectral_moment(S_del, 2)
        m3_after = spectral_moment(S_del, 3)
        predicted = 12.0 * S2[a, b]
        actual = m3_after - m3_before
        print(f"  delete {(a, b)}: (S^2)_ab = {S2[a, b]:4.0f}  "
              f"predicted d(tr S^3) = {predicted:6.1f}  actual = {actual:6.1f}  "
              f"| d(tr S^2) = {m2_after - m2_before:4.1f}  "
              f"match = {abs(predicted - actual) < 1e-9}")
    print(f"  (baseline: tr(S^2) = {m2_before}, tr(S^3) = {m3_before})")
    print()


def demo_K3_vs_P3() -> None:
    print("=" * 70)
    print("Minimal witness:  K3  vs  K3 - e = P3")
    print("=" * 70)
    S_K3 = seidel_matrix(3, [(0, 1), (0, 2), (1, 2)])
    S_P3 = seidel_matrix(3, [(0, 1), (0, 2)])  # edge (1,2) deleted
    print(f"  tr(S^2):  K3 = {spectral_moment(S_K3, 2):.0f}   "
          f"P3 = {spectral_moment(S_P3, 2):.0f}   (unchanged)")
    print(f"  tr(S^3):  K3 = {spectral_moment(S_K3, 3):.0f}   "
          f"P3 = {spectral_moment(S_P3, 3):.0f}   (jump of "
          f"{spectral_moment(S_P3, 3) - spectral_moment(S_K3, 3):.0f})")
    S2 = S_K3 @ S_K3
    print(f"  predicted jump = 12 * (S^2)_(1,2) = 12 * {S2[1, 2]:.0f} = "
          f"{12 * S2[1, 2]:.0f}")
    print()


def demo_complement_energy() -> None:
    print("=" * 70)
    print("Complementation preserves Seidel energy  E_S(G) = E_S(complement G)")
    print("=" * 70)
    graphs = {
        "P3 (2 edges)": (3, [(0, 1), (1, 2)]),
        "path P4 (3 edges)": (4, [(0, 1), (1, 2), (2, 3)]),
        "C5 (5 edges)": (5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]),
    }
    for name, (n, edges) in graphs.items():
        S = seidel_matrix(n, edges)
        Sc = seidel_matrix(n, complement_edges(n, edges))
        ne, nc = len(edges), len(complement_edges(n, edges))
        print(f"  {name:18s}: edges G = {ne}, edges compl = {nc};  "
              f"E_S(G) = {seidel_energy(S):8.4f}  "
              f"E_S(compl) = {seidel_energy(Sc):8.4f}  "
              f"S(compl) = -S? {np.allclose(Sc, -S)}")
    print()


if __name__ == "__main__":
    demo_moment_identities()
    demo_energy_floor()
    demo_edge_flip()
    demo_K3_vs_P3()
    demo_complement_energy()
