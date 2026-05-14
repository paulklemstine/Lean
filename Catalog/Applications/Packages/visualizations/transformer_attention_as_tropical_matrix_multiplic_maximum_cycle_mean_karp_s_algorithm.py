def maximum_cycle_mean(A):
    import numpy as np
    n = A.shape[0]
    D = np.full((n + 1, n), -np.inf)
    D[0, :] = 0.0
    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                if D[k-1][j] > -np.inf and A[j][i] > -np.inf:
                    D[k][i] = max(D[k][i], D[k-1][j] + A[j][i])
    rho = -np.inf
    for i in range(n):
        if D[n][i] == -np.inf: continue
        min_val = np.inf
        for k in range(n):
            if D[k][i] > -np.inf:
                val = (D[n][i] - D[k][i]) / (n - k)
                min_val = min(min_val, val)
        rho = max(rho, min_val)
    return rho