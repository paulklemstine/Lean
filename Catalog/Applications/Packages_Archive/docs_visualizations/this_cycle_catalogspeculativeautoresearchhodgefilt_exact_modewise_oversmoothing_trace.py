from __future__ import annotations
from typing import List
import numpy as np

def mp_step(L: np.ndarray, alpha: float) -> np.ndarray:
    """One message-passing layer  I - alpha * L."""
    return np.eye(L.shape[0]) - alpha * L

def oversmoothing_trace(L: np.ndarray, alpha: float, v: np.ndarray,
                        nu: float, depth: int) -> List[tuple]:
    """Return [(k, measured_energy, predicted_energy)] verifying
    <T^k v, T^k v> = (1 - alpha*nu)^(2k) <v, v>  (Theorem 3.3)."""
    T = mp_step(L, alpha)
    e0 = float(np.dot(v, v))
    x = v.copy()
    out = [(0, e0, e0)]
    for k in range(1, depth + 1):
        x = T @ x
        meas = float(np.dot(x, x))
        pred = (1.0 - alpha * nu) ** (2 * k) * e0
        out.append((k, meas, pred))
    return out
