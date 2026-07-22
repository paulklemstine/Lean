from __future__ import annotations
import numpy as np

def seidel_energy_from_adjacency(adjacency: np.ndarray) -> float:
    """Compute the Seidel energy E_S(G) = sum_i |lambda_i| of a simple graph.

    Forms S = J - I - 2A, diagonalizes the real symmetric matrix, and sums the
    absolute eigenvalues. Complexity is dominated by the symmetric eigenvalue
    decomposition: O(n^3) time, O(n^2) memory.
    """
    n: int = adjacency.shape[0]
    seidel: np.ndarray = np.ones((n, n)) - np.eye(n) - 2.0 * adjacency.astype(float)
    eigenvalues: np.ndarray = np.linalg.eigvalsh(seidel)
    return float(np.sum(np.abs(eigenvalues)))
