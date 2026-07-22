from __future__ import annotations
import numpy as np
from typing import Iterable

Matrix = np.ndarray


def max_commutator_norm(P: Matrix, A: Matrix,
                        test_ops: Iterable[Matrix]) -> float:
    """Largest ||[P A P, P B P]|| over test operators B.

    For a detectable A this is ~0 (centrality, Theorem 5.1); for a
    non-detectable A on a non-trivial code it is generically positive.
    """
    LA = P @ A @ P
    worst = 0.0
    for B in test_ops:
        LB = P @ B @ P
        comm = LA @ LB - LB @ LA
        worst = max(worst, float(np.linalg.norm(comm)))
    return worst
