import numpy as np

NEGINF = float("-inf")

def trop_mat_mul(A, B):
    m, p = A.shape
    _, n = B.shape
    C = np.full((m, n), NEGINF)
    for i in range(m):
        for j in range(n):
            for k in range(p):
                if A[i,k] != NEGINF and B[k,j] != NEGINF:
                    C[i,j] = max(C[i,j], A[i,k] + B[k,j])
    return C

def trop_mat_pow(A, n):
    m = A.shape[0]
    R = np.full((m, m), NEGINF)
    np.fill_diagonal(R, 0.0)
    for _ in range(n):
        R = trop_mat_mul(R, A)
    return R

# Demo: scalar diagonal
lam = 2.5
m = 3
G = np.full((m, m), NEGINF)
np.fill_diagonal(G, lam)

for n in range(1, 6):
    Gn = trop_mat_pow(G, n)
    print(f"(G^{n})_00 = {Gn[0,0]:.1f}, expected n*λ = {n*lam:.1f}")
