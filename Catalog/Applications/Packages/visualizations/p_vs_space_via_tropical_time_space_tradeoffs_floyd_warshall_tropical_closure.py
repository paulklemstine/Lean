import numpy as np
INF = float('inf')

def tropical_closure(W):
    D = W.copy()
    n = D.shape[0]
    np.fill_diagonal(D, np.minimum(np.diag(D), 0.0))
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i,j] = min(D[i,j], D[i,k] + D[k,j])
    return D

W = np.array([[INF, 1, INF], [INF, INF, 2], [3, INF, INF]])
print("W* (all-pairs shortest paths):")
print(tropical_closure(W))
