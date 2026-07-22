from __future__ import annotations
from itertools import combinations
from typing import Iterable
import numpy as np

def seidel_energy(S: np.ndarray) -> float:
    """Seidel energy = sum |eigenvalues|, via a symmetric eigensolver, O(n^3)."""
    return float(np.sum(np.abs(np.linalg.eigvalsh(S))))

def energy_floor(n: int) -> float:
    """Universal lower bound  E_S >= sqrt(n(n-1))."""
    return float(np.sqrt(n * (n - 1)))

def energy_ratio(n: int, edges: Iterable[tuple[int, int]]) -> float:
    """How far above the universal floor a given graph sits (>= 1)."""
    edge_set = {frozenset(e) for e in edges}
    S = np.ones((n, n)); np.fill_diagonal(S, 0.0)
    for i, j in combinations(range(n), 2):
        S[i, j] = S[j, i] = -1.0 if frozenset((i, j)) in edge_set else 1.0
    return seidel_energy(S) / energy_floor(n)
