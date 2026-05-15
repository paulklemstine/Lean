import numpy as np

def tropical_matrix_multiply(A, B):
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C

# Example
A = np.array([[0, 3, np.inf], [2, 0, 4], [np.inf, 1, 0]])
B = np.array([[0, 1, 5], [np.inf, 0, 2], [3, np.inf, 0]])
C = tropical_matrix_multiply(A, B)
print("A ⊗ B =")
print(C)
