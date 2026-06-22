from __future__ import annotations
from typing import List
import numpy as np

def mp_filter(L: np.ndarray, alphas: List[float]) -> np.ndarray:
    """Polynomial filter  prod_i (I - alpha_i L)  (Definition 5.1)."""
    out = np.eye(L.shape[0])
    for a in alphas:
        out = (np.eye(L.shape[0]) - a * L) @ out
    return out

def filter_scalar(alphas: List[float], nu: float) -> float:
    """p(nu) = prod_i (1 - alpha_i * nu)  (Theorem 5.3): the scalar a filter
    applies to the mode of eigenvalue nu."""
    p = 1.0
    for a in alphas:
        p *= (1.0 - a * nu)
    return p
