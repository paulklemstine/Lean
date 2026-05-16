import numpy as np

def tropical_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A⊗B)[i,k] = max_j(A[i,j] + B[j,k])."""
    n = A.shape[0]
    C = np.empty((n, n))
    for i in range(n):
        for k in range(n):
            C[i, k] = np.max(A[i, :] + B[:, k])
    return C

A = np.array([[0.0, 3.0], [2.0, 0.0]])
B = np.array([[1.0, -1.0], [0.0, 2.0]])
print(f"A ⊗ B =
{tropical_mat_mul(A, B)}")
