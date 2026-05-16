import numpy as np

def maximum_cycle_mean(A: np.ndarray) -> float:
    """Compute tropical eigenvalue via Karp's algorithm."""
    n = A.shape[0]
    D = np.full((n + 1, n), -np.inf)
    D[0, :] = 0.0
    for k in range(1, n + 1):
        for i in range(n):
            D[k, i] = np.max(A[:, i] + D[k-1, :])
    lambda_star = -np.inf
    for i in range(n):
        val = np.inf
        for k in range(n):
            if D[k, i] > -np.inf and D[n, i] > -np.inf:
                val = min(val, (D[n, i] - D[k, i]) / (n - k))
        if val < np.inf:
            lambda_star = max(lambda_star, val)
    return lambda_star

A = np.array([[0.0, 3.0, -1.0], [2.0, 0.0, 1.0], [1.0, 2.0, 0.0]])
print(f"Tropical eigenvalue = {maximum_cycle_mean(A)}")
