from itertools import combinations
from typing import FrozenSet, List, Sequence, Tuple
import numpy as np

Facet = FrozenSet[int]

def exact_spectral_radius(facets: Sequence[Facet]) -> float:
    """Largest eigenvalue q_{r-1} of the signless Laplacian Q = B B^T."""
    ridges: List[int] = sorted({r for f in facets for r in f})
    idx = {r: i for i, r in enumerate(ridges)}
    B = np.zeros((len(ridges), len(facets)))
    for j, f in enumerate(facets):
        for r in f:
            B[idx[r], j] = 1.0
    Q = B @ B.T
    return float(np.max(np.linalg.eigvalsh(Q))) if Q.size else 0.0
