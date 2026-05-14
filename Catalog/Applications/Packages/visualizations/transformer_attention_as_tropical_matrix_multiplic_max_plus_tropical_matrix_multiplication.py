def tropical_max_plus_multiply(A, B):
    import numpy as np
    m, n = A.shape
    _, p = B.shape
    C = np.full((m, p), -np.inf)
    for i in range(m):
        for k in range(p):
            for j in range(n):
                C[i, k] = max(C[i, k], A[i, j] + B[j, k])
    return C