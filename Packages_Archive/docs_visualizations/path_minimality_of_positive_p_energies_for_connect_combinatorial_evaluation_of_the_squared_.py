from __future__ import annotations
from typing import List

def squared_spectral_energy(adj: List[List[int]]) -> int:
    """sum_i lambda_i^2 = 2|E|, computed by counting edges (no eigensolver)."""
    n: int = len(adj)
    edges: int = sum(adj[i][j] for i in range(n) for j in range(i + 1, n))
    return 2 * edges
