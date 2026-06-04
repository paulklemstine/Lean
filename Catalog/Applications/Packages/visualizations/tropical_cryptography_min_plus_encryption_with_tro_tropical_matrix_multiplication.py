def tropical_mat_mul(A, B):
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i,j] = min(C[i,j], A[i,k] + B[k,j])
    return C