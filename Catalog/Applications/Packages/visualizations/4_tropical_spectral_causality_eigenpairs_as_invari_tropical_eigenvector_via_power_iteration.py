def find_eigenvector(A, max_iter=1000, tol=1e-12):
    import numpy as np
    n = A.shape[0]
    v = np.zeros(n)
    for _ in range(max_iter):
        v_new = np.min(A + v[np.newaxis, :], axis=1)
        d = v_new[0] - v[0]
        v_new_norm = v_new - d
        if np.max(np.abs(v_new_norm - v)) < tol:
            v = v_new_norm
            break
        v = v_new_norm
    d = np.min(A + v[np.newaxis, :], axis=1)[0] - v[0]
    return d, v