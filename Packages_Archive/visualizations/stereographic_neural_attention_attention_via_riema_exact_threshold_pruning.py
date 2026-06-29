import math
from typing import List, Sequence

Vector = Sequence[float]

def exact_threshold_pruning(
    q: Vector,
    keys: Sequence[Vector],
    tau: float,
) -> List[int]:
    """Return indices of keys with K(q,k) >= tau == metric ball of radius sqrt(1/tau-1)."""
    if not (0.0 < tau <= 1.0):
        raise ValueError("tau must satisfy 0 < tau <= 1")
    rho_sq: float = 1.0 / tau - 1.0
    active: List[int] = []
    for i, k in enumerate(keys):
        d2 = sum((qi - ki) ** 2 for qi, ki in zip(q, k))
        if d2 <= rho_sq:
            active.append(i)
    assert len(active) <= len(keys) / tau  # Markov sparsity bound
    return active
