from __future__ import annotations
from typing import List

def positive_p_energy(eigenvalues: List[float], p: float) -> float:
    """Positive p-energy E_p^+ = sum over positive eigenvalues of lambda**p."""
    return sum(lam ** p for lam in eigenvalues if lam > 0.0)

def negative_p_energy(eigenvalues: List[float], p: float) -> float:
    """Negative p-energy E_p^- = sum over negative eigenvalues of (-lambda)**p."""
    return sum((-lam) ** p for lam in eigenvalues if lam < 0.0)
