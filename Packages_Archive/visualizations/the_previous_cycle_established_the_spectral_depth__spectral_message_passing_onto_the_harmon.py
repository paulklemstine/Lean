from __future__ import annotations
import numpy as np

def mp_step(L: np.ndarray, alpha: float, x: np.ndarray) -> np.ndarray:
    """One linear message-passing layer  T(x) = x - alpha (L x)."""
    return x - alpha * (L @ x)

def harmonic_projection_by_mp(
    B: np.ndarray, x: np.ndarray, eps: float = 1e-8, tol: float = 1e-9
) -> np.ndarray:
    """Approximate the orthogonal projection of x onto ker(L), L = B^T B,
    by deep spectral message passing with the optimal step alpha = 1/lambda.

    Convergence: ||T^k x - proj x||^2 <= rho^k ||r||^2 with rho = 1 - mu/lambda,
    so depth N = ceil(log_rho(eps / ||x||^2)) layers reach energy tolerance eps.
    """
    L = B.T @ B
    vals = np.linalg.eigvalsh(L)
    vals = np.where(np.abs(vals) < tol, 0.0, vals)
    nonzero = vals[vals > tol]
    if nonzero.size == 0:
        return x.copy()                      # everything harmonic
    mu, lam = float(nonzero.min()), float(vals.max())
    alpha = 1.0 / lam                         # optimal step  (Theorem 4.9)
    rho = 1.0 - mu / lam                      # optimal factor (Theorem 4.9)
    energy0 = float(x @ x)
    if energy0 <= 0.0:
        return x.copy()
    N = max(0, int(np.ceil(np.log(eps / energy0) / np.log(rho))))  # depth
    y = x.copy()
    for _ in range(N):
        y = mp_step(L, alpha, y)
    return y
