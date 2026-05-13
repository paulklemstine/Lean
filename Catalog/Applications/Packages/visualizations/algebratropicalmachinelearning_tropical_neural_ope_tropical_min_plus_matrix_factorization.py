import numpy as np

def tropical_matmul(A, B):
    """Tropical (min-plus) matrix product."""
    n, r = A.shape
    result = np.full((n, B.shape[1]), np.inf)
    for j in range(r):
        result = np.minimum(result, A[:, j:j+1] + B[j:j+1, :])
    return result

def tropical_factorization(M):
    """Compute tropical factorization M = L ⊗ R."""
    n, m = M.shape
    B = 1 + 2 * int(np.max(np.abs(M)))
    L = np.full((n, n), B, dtype=np.int64)
    np.fill_diagonal(L, 0)
    R = M.copy().astype(np.int64)
    return L, R

# Example
M = np.array([[1, 3, 2], [4, 2, 5], [3, 1, 4]])
L, R = tropical_factorization(M)
M_check = tropical_matmul(L.astype(float), R.astype(float))
print(f"Original: {M.tolist()}")
print(f"Reconstructed: {M_check.astype(int).tolist()}")
print(f"Correct: {np.allclose(M, M_check)}")
