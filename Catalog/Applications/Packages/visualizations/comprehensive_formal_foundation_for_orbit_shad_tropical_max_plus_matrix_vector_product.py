def trop_mv(A, x):
    n = A.shape[0]
    return np.array([np.max(A[i, :] + x) for i in range(n)])