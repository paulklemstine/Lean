from __future__ import annotations
import math
import numpy as np

def full_hodge(D: np.ndarray, E: np.ndarray) -> np.ndarray:
    """Full Hodge Laplacian L = D^T D + E E^T."""
    return D.T @ D + E @ E.T

def hodge_depth(rho: float, energy0: float, eps: float) -> int:
    """Explicit depth N = ceil(log_rho(eps / energy0)); 0 if already within tolerance."""
    if energy0 <= 0.0 or eps / energy0 >= 1.0:
        return 0
    return max(0, math.ceil(math.log(eps / energy0) / math.log(rho)))

def hodge_message_passing(D: np.ndarray, E: np.ndarray, x: np.ndarray,
                          alpha: float, rho: float, eps: float) -> np.ndarray:
    """Run Hodge message passing for the provably-sufficient logarithmic depth."""
    L = full_hodge(D, E)
    N = hodge_depth(rho, float(x @ x), eps)
    for _ in range(N):
        x = x - alpha * (L @ x)
    return x
