from __future__ import annotations
import numpy as np

def hodge_message_passing(
    Delta: np.ndarray, x0: np.ndarray, epsilon: float = 1e-6
) -> tuple[np.ndarray, int, float]:
    """Run T = I - alpha*Delta at the optimal spectral step; return (x, depth, rho)."""
    eig = np.linalg.eigvalsh(Delta)
    lam_max = float(eig[-1])
    pos = eig[eig > 1e-9]
    if pos.size == 0:
        return x0.copy(), 0, 0.0       # Delta = 0: everything harmonic
    mu = float(pos.min())
    alpha = 1.0 / lam_max
    rho = 1.0 - mu / lam_max
    K = max(1, int(np.ceil(np.log(epsilon) / np.log(rho)))) if rho > 0 else 1
    x = x0.astype(float).copy()
    for _ in range(K):
        x = x - alpha * (Delta @ x)
    return x, K, rho
