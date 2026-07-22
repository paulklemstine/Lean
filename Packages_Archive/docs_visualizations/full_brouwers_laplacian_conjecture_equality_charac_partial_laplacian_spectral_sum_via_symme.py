from __future__ import annotations
import numpy as np

def partial_spectral_sum(adj: np.ndarray, k: int) -> float:
    """Sum of the k largest Laplacian eigenvalues of a simple graph.

    adj: symmetric 0/1 adjacency matrix.
    Returns s_k = lambda_1 + ... + lambda_k with eigenvalues in decreasing order.
    """
    degrees = adj.sum(axis=1)
    lap = np.diag(degrees) - adj                 # L = D - A
    eig = np.linalg.eigvalsh(lap)                # ascending, real (symmetric)
    eig_desc = np.sort(eig)[::-1]                # descending
    k = min(k, len(eig_desc))
    return float(eig_desc[:k].sum())
