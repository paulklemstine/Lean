import numpy as np
INF = float('inf')

def tropical_mul(A, B):
    """Min-plus matrix multiplication: C[i,j] = min_k(A[i,k] + B[k,j])"""
    n, p, m = A.shape[0], A.shape[1], B.shape[1]
    C = np.full((n, m), INF)
    for i in range(n):
        for j in range(m):
            for k in range(p):
                C[i,j] = min(C[i,j], A[i,k] + B[k,j])
    return C

# Example
A = np.array([[0, 3, INF], [INF, 0, 1], [2, INF, 0]])
print("A ="); print(A)
print("A^2 ="); print(tropical_mul(A, A))
