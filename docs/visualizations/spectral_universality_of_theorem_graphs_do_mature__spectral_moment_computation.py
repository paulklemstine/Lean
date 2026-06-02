def spectral_moment(adj, k):
    A = adj.astype(float)
    Ak = np.linalg.matrix_power(A, k)
    return float(np.trace(Ak)) / len(adj)