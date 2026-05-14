import numpy as np

def trop_mul(A, B):
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = min(A[i, k] + B[k, j] for k in range(n))
    return C

def trop_pow(A, k):
    n = A.shape[0]
    if k == 0:
        I = np.full((n, n), np.inf)
        np.fill_diagonal(I, 0)
        return I
    result = A.copy()
    for _ in range(k - 1):
        result = trop_mul(result, A)
    return result

# KEM Demo
G = np.array([[0, 3, 7], [1, 0, 5], [2, 4, 0]], dtype=float)
sk = 4  # secret key
pk = trop_pow(G, sk)  # public key

r = 3  # randomness
c1 = trop_pow(G, r)
c2 = trop_pow(pk, r)

# Decryption
shared = trop_pow(c1, sk)
print("Correctness:", np.allclose(shared, c2))
print("Shared key:", shared)
