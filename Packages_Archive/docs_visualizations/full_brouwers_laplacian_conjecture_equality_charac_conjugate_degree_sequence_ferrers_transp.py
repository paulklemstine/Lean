from __future__ import annotations
from typing import List
import numpy as np

def conjugate_degree_sequence(adj: np.ndarray) -> List[int]:
    """Conjugate (transpose) of the degree partition: d*_j = #{ i : d_i >= j }.

    This is the sequence that majorizes the Laplacian spectrum
    (Grone-Merris-Bai) and equals it exactly for threshold graphs.
    """
    degs = sorted((int(d) for d in adj.sum(axis=1)), reverse=True)
    if not degs:
        return []
    top = max(degs)
    return [sum(1 for d in degs if d >= j) for j in range(1, top + 1)]
