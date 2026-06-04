def dual_bound(A, b, c):
    import numpy as np
    return np.min([b[i] + np.max(c - A[i,:]) for i in range(A.shape[0])])