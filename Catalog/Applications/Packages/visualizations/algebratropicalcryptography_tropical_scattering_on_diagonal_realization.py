import numpy as np

def diag_realize(T):
    m, n = T.shape
    M = np.max(np.abs(T))
    A = T.copy()
    B = np.full((n, n), 2*M + 1)
    np.fill_diagonal(B, 0)
    return A, B

T = np.array([[0, 3, 7], [2, 1, 4], [5, 8, 0]])
A, B = diag_realize(T)
# Verify
T2 = np.array([[min(A[i,v]+B[v,j] for v in range(3)) for j in range(3)] for i in range(3)])
print(f'Original: {T.tolist()}')
print(f'Realized: {T2.tolist()}')
print(f'Match: {np.allclose(T, T2)}')