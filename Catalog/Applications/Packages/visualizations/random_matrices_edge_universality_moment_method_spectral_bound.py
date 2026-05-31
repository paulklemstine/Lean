def spectral_bound(A, k=4):
    Ak = np.linalg.matrix_power(A, 2*k)
    return np.trace(Ak) ** (1.0/(2*k))