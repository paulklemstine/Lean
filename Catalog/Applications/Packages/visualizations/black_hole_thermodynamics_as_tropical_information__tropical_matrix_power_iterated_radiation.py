def tropical_matrix_power(K, p):
    """Compute K^p in the tropical (min-plus) semiring."""
    import numpy as np
    n = K.shape[0]
    R = K.copy()
    for _ in range(p - 1):
        R_new = np.full((n, n), np.inf)
        for k in range(n):
            R_new = np.minimum(R_new, R[:, k:k+1] + K[k:k+1, :])
        R = R_new
    return R