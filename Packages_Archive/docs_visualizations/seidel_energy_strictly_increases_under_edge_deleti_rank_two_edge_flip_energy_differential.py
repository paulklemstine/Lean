from __future__ import annotations
import numpy as np

def edge_flip_energy_change(adjacency: np.ndarray, a: int, b: int) -> float:
    """Energy change induced by flipping the edge {a, b} of a graph, viewed as
    the symmetric rank-two Seidel update  S -> S + 2(e_a e_b^T + e_b e_a^T).

    Deleting an existing edge sends the entry pair from -1 to +1 (a +2 update);
    adding a non-edge sends it from +1 to -1 (a -2 update). The function applies
    the corresponding sign automatically, recomputes the spectrum, and returns
    E_S(new) - E_S(old). The perturbation preserves tr S and tr S^2, so the whole
    change lives in the higher moments. Complexity O(n^3) via re-diagonalization.
    """
    n: int = adjacency.shape[0]
    def energy(adj: np.ndarray) -> float:
        s = np.ones((n, n)) - np.eye(n) - 2.0 * adj.astype(float)
        return float(np.sum(np.abs(np.linalg.eigvalsh(s))))
    before: float = energy(adjacency)
    flipped: np.ndarray = adjacency.copy()
    flipped[a, b] = flipped[b, a] = 1 - flipped[a, b]
    after: float = energy(flipped)
    return after - before
