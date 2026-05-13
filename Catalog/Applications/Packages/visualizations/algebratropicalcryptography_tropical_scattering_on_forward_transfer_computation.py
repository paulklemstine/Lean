import numpy as np

def compute_transfer(A, B):
    """Compute tropical transfer matrix T(i,j) = min_v (A[i,v] + B[v,j])."""
    m, k = A.shape
    _, n = B.shape
    T = np.zeros((m, n))
    for i in range(m):
        for j in range(n):
            T[i, j] = min(A[i, v] + B[v, j] for v in range(k))
    return T

# Example
A = np.array([[0, 10, 5], [10, 0, 5]])
B = np.array([[0, 10], [10, 0], [2, 2]])
print('Transfer matrix:')
print(compute_transfer(A, B))