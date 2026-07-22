from __future__ import annotations
from itertools import combinations
from typing import Iterable
import numpy as np

def seidel_matrix(n: int, edges: Iterable[tuple[int, int]]) -> np.ndarray:
    """Build the Seidel matrix in O(n^2)."""
    edge_set = {frozenset(e) for e in edges}
    S = np.ones((n, n)); np.fill_diagonal(S, 0.0)
    for i, j in combinations(range(n), 2):
        S[i, j] = S[j, i] = -1.0 if frozenset((i, j)) in edge_set else 1.0
    return S

def spectral_moments(S: np.ndarray, kmax: int = 3) -> list[float]:
    """Return [tr(S^1), ..., tr(S^kmax)] by iterated matmul, O(kmax * n^3)."""
    moments: list[float] = []
    P = np.eye(S.shape[0])
    for _ in range(kmax):
        P = P @ S
        moments.append(float(np.trace(P)))
    return moments
