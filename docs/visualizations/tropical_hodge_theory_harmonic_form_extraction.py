def harmonic_forms(laplacian):
    _, S, Vt = np.linalg.svd(laplacian)
    tol = 1e-10 * max(S) if len(S) > 0 and max(S) > 0 else 1e-10
    return Vt[S < tol]