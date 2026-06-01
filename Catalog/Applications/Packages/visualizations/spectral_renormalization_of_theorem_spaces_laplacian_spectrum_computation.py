import numpy as np
def laplacian_spectrum(n, adj):
    A = np.zeros((n, n))
    for u in range(n):
        for v in adj[u]:
            A[u, v] = 1.0
    A_sym = (A + A.T) / 2.0
    D = np.diag(A_sym.sum(axis=1))
    L = D - A_sym
    return np.sort(np.linalg.eigvalsh(L))