def trop_mul(A, B):
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})"""
    import numpy as np
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = min(A[i, k] + B[k, j] for k in range(n))
    return C

def trop_pow(A, k):
    """Tropical matrix power via repeated multiplication."""
    import numpy as np
    n = A.shape[0]
    if k == 0:
        I = np.full((n, n), np.inf)
        np.fill_diagonal(I, 0)
        return I
    result = A.copy()
    for _ in range(k - 1):
        result = trop_mul(result, A)
    return result

# Example
import numpy as np
G = np.array([[0, 3, 7], [1, 0, 5], [2, 4, 0]], dtype=float)
print("G^2 =", trop_pow(G, 2))
print("G^3 =", trop_pow(G, 3))
