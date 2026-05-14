def lse_multiply(A, B, tau):
    import numpy as np
    m, n = A.shape
    _, p = B.shape
    C = np.zeros((m, p))
    for i in range(m):
        for k in range(p):
            vals = A[i, :] + B[:, k]
            max_val = np.max(vals)
            C[i, k] = max_val + tau * np.log(np.sum(np.exp((vals - max_val) / tau)))
    return C