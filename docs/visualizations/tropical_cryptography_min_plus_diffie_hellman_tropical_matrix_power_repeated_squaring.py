def trop_mat_pow(A, k):
    n = A.shape[0]
    result = np.full((n,n), float('inf'))
    np.fill_diagonal(result, 0)
    base = A.copy()
    while k > 0:
        if k % 2 == 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        k //= 2
    return result