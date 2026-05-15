import numpy as np

def tropical_matrix_multiply(A, B):
    """Tropical (min-plus) matrix multiplication."""
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C

# Example: shortest paths
INF = float('inf')
M = np.array([[0, 3, INF], [3, 0, 1], [INF, 1, 0]])
D = tropical_matrix_multiply(M, M)
print("One-step costs:")
print(M)
print("Two-step shortest paths:")
print(D)