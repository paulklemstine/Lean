# See algorithms.py for full implementation
def soft_tropical_matvec(A, x, beta):
    import numpy as np
    n = A.shape[0]
    y = np.zeros(n)
    for i in range(n):
        vals = A[i, :] + x
        m = np.max(vals)
        y[i] = m + np.log(np.sum(np.exp(beta * (vals - m)))) / beta
    return y