from __future__ import annotations
from typing import List, Tuple

def mean_relaxation_witness(beta: float) -> Tuple[List[float], List[float], float, float]:
    """Two-point law: mass beta at d=1, mass 1-beta at d=0 (Thm 6.1).

    Returns (support, masses, mean, avg_f); mean == beta and avg_f == 0."""
    support: List[float] = [1.0, 0.0]
    masses: List[float] = [beta, 1.0 - beta]
    mean: float = sum(p * d for p, d in zip(masses, support))
    avg_f: float = sum(p * (d * d * (1.0 - d)) for p, d in zip(masses, support))
    return support, masses, mean, avg_f
