import numpy as np

def microscopic_weighting(D: np.ndarray) -> tuple[np.ndarray, float]:
    """Compute the microscopic weighting mu and constant lam of a symmetric
    distance matrix D via the closed form mu = D^{-1} 1 / (1^T D^{-1} 1).

    Returns (mu, lam) with D @ mu = lam * ones and sum(mu) = 1.
    Raises ValueError if 1^T D^{-1} 1 vanishes (degenerate configuration).
    Complexity: O(n^3) for the linear solve.
    """
    n = D.shape[0]
    ones = np.ones(n)
    u = np.linalg.solve(D, ones)      # u = D^{-1} 1
    s = float(u.sum())                # s = 1^T D^{-1} 1
    if abs(s) < 1e-12:
        raise ValueError("degenerate configuration: 1^T D^{-1} 1 = 0")
    return u / s, 1.0 / s
