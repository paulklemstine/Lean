"""
Numerical demonstrations for:

    Seidel Energy, Spectral Moments, and the Edge-Deletion Phenomenon
    on Turan Graphs

This standalone script illustrates the core results of the accompanying paper:

  * The Seidel matrix  S = J - I - 2A  of a finite simple graph.
  * First spectral moment vanishes:      tr(S) = sum(lambda_i) = 0.
  * Second spectral moment is fixed:     tr(S^2) = sum(lambda_i^2) = n(n-1).
  * Universal Seidel energy lower bound:  E_S(G) >= sqrt(n(n-1)).
  * Switching invariance:                 conjugation by a +-1 diagonal
                                          preserves the entire spectrum.
  * Edge-deletion on Turan graphs:        deleting an edge from T(n, r)
                                          strictly increases Seidel energy,
                                          while leaving the first two moments
                                          unchanged.

Only the Python standard library and NumPy are required.
"""

from __future__ import annotations

import itertools
from typing import Iterable

import numpy as np


# ---------------------------------------------------------------------------
# Core linear-algebra objects
# ---------------------------------------------------------------------------
def seidel_matrix(adjacency: np.ndarray) -> np.ndarray:
    """Return the Seidel matrix  S = J - I - 2A  of a simple graph.

    Parameters
    ----------
    adjacency:
        A symmetric 0/1 numpy array with zero diagonal (the adjacency matrix A).

    Returns
    -------
    The n x n real Seidel matrix: 0 on the diagonal, -1 on adjacent pairs,
    +1 on non-adjacent pairs.
    """
    n = adjacency.shape[0]
    ones = np.ones((n, n), dtype=float)
    identity = np.eye(n, dtype=float)
    return ones - identity - 2.0 * adjacency.astype(float)


def seidel_spectrum(adjacency: np.ndarray) -> np.ndarray:
    """Return the sorted real eigenvalues (Seidel spectrum) of a graph."""
    s = seidel_matrix(adjacency)
    # S is real symmetric, so eigvalsh gives the real spectrum.
    return np.sort(np.linalg.eigvalsh(s))


def seidel_energy(adjacency: np.ndarray) -> float:
    """Return the Seidel energy  E_S(G) = sum |lambda_i|."""
    return float(np.sum(np.abs(seidel_spectrum(adjacency))))


def first_moment(adjacency: np.ndarray) -> float:
    """First spectral moment  tr(S) = sum lambda_i  (theoretically 0)."""
    return float(np.trace(seidel_matrix(adjacency)))


def second_moment(adjacency: np.ndarray) -> float:
    """Second spectral moment  tr(S^2) = sum lambda_i^2  (theoretically n(n-1))."""
    s = seidel_matrix(adjacency)
    return float(np.trace(s @ s))


# ---------------------------------------------------------------------------
# Graph constructions
# ---------------------------------------------------------------------------
def turan_graph(n: int, r: int) -> np.ndarray:
    """Adjacency matrix of the Turan graph T(n, r).

    Vertices are split into r parts of sizes as equal as possible; two vertices
    are adjacent iff they lie in different parts (complete r-partite graph).
    """
    # part[i] = which part vertex i belongs to, filling parts round-robin so
    # sizes differ by at most one.
    part = [i % r for i in range(n)]
    adjacency = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if part[i] != part[j]:
                adjacency[i, j] = adjacency[j, i] = 1
    return adjacency


def delete_edge(adjacency: np.ndarray, a: int, b: int) -> np.ndarray:
    """Return a copy of the graph with edge {a, b} deleted."""
    result = adjacency.copy()
    result[a, b] = result[b, a] = 0
    return result


def edges(adjacency: np.ndarray) -> Iterable[tuple[int, int]]:
    """Yield the edges {i, j} (i < j) of the graph."""
    n = adjacency.shape[0]
    for i in range(n):
        for j in range(i + 1, n):
            if adjacency[i, j] == 1:
                yield (i, j)


def switch_diagonal(n: int, subset: Iterable[int]) -> np.ndarray:
    """Diagonal +-1 matrix D with D_ii = -1 iff i in subset (a switching)."""
    d = np.ones(n, dtype=float)
    for i in subset:
        d[i] = -1.0
    return np.diag(d)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_moments() -> None:
    """Verify the two moment identities on a spread of graphs."""
    print("=" * 70)
    print("Spectral moment identities:  tr(S) = 0   and   tr(S^2) = n(n-1)")
    print("=" * 70)
    rng = np.random.default_rng(2026)
    for n in (5, 6, 8, 10):
        # A random simple graph on n vertices.
        upper = np.triu(rng.integers(0, 2, size=(n, n)), k=1)
        adjacency = upper + upper.T
        m1 = first_moment(adjacency)
        m2 = second_moment(adjacency)
        eigs = seidel_spectrum(adjacency)
        print(
            f"n={n:2d} | tr(S)={m1:+.2e} (=0) | "
            f"tr(S^2)={m2:7.3f} | n(n-1)={n * (n - 1):4d} | "
            f"sum lambda^2={np.sum(eigs ** 2):7.3f}"
        )
    print()


def demo_energy_lower_bound() -> None:
    """Check the universal lower bound  E_S(G) >= sqrt(n(n-1))."""
    print("=" * 70)
    print("Universal lower bound:  E_S(G) >= sqrt(n(n-1))")
    print("=" * 70)
    rng = np.random.default_rng(7)
    for n in (4, 6, 8, 12):
        floor = np.sqrt(n * (n - 1))
        best = np.inf
        for _ in range(400):
            upper = np.triu(rng.integers(0, 2, size=(n, n)), k=1)
            adjacency = upper + upper.T
            best = min(best, seidel_energy(adjacency))
        print(
            f"n={n:2d} | sqrt(n(n-1))={floor:7.4f} | "
            f"min observed E_S={best:7.4f} | bound holds: {best + 1e-9 >= floor}"
        )
    print()


def demo_switching_invariance() -> None:
    """Show that switching preserves the entire Seidel spectrum (hence energy)."""
    print("=" * 70)
    print("Switching invariance:  D S D has the same spectrum as S")
    print("=" * 70)
    rng = np.random.default_rng(11)
    n = 8
    upper = np.triu(rng.integers(0, 2, size=(n, n)), k=1)
    adjacency = upper + upper.T
    s = seidel_matrix(adjacency)
    subset = [1, 3, 4, 6]
    d = switch_diagonal(n, subset)
    s_switched = d @ s @ d
    spec = np.sort(np.linalg.eigvalsh(s))
    spec_switched = np.sort(np.linalg.eigvalsh(s_switched))
    print(f"switching subset X = {subset}")
    print(f"max eigenvalue difference: {np.max(np.abs(spec - spec_switched)):.2e}")
    print(
        f"energy before = {np.sum(np.abs(spec)):.6f} | "
        f"energy after = {np.sum(np.abs(spec_switched)):.6f}"
    )
    print()


def demo_edge_deletion_turan() -> None:
    """Central demo: deleting an edge from T(n, r) strictly raises Seidel energy,
    while the first two moments stay put."""
    print("=" * 70)
    print("Edge deletion on Turan graphs:  E_S(T(n,r) - e) > E_S(T(n,r))")
    print("(first two moments are unchanged by the deletion)")
    print("=" * 70)
    # The theorem requires r >= 4 and n >= 4r. The first row (n=8, r=4) is
    # BELOW the threshold n >= 4r = 16 and is included to show the hypothesis
    # is genuinely needed; the remaining rows satisfy it and increase strictly.
    for (n, r) in ((8, 4), (16, 4), (20, 4), (20, 5)):
        adjacency = turan_graph(n, r)
        base_energy = seidel_energy(adjacency)
        base_m1 = first_moment(adjacency)
        base_m2 = second_moment(adjacency)
        increases = 0
        total = 0
        min_gap = np.inf
        for (a, b) in edges(adjacency):
            total += 1
            deleted = delete_edge(adjacency, a, b)
            gap = seidel_energy(deleted) - base_energy
            if gap > 1e-9:
                increases += 1
            min_gap = min(min_gap, gap)
            # Confirm the moments do not move.
            assert abs(first_moment(deleted) - base_m1) < 1e-9
            assert abs(second_moment(deleted) - base_m2) < 1e-9
        meets = "yes" if (r >= 4 and n >= 4 * r) else "NO "
        print(
            f"T({n:2d},{r}) [n>=4r? {meets}] | E_S={base_energy:8.4f} | "
            f"edges tested={total:3d} | strictly increased={increases:3d} | "
            f"min gap={min_gap:+.4f}"
        )
    print()


def main() -> None:
    demo_moments()
    demo_energy_lower_bound()
    demo_switching_invariance()
    demo_edge_deletion_turan()


if __name__ == "__main__":
    main()
