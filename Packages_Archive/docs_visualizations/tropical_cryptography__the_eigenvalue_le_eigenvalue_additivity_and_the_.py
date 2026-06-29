"""Visualize tropical eigenvalue additivity and the divisibility leak.

Requires matplotlib and numpy. Saves two PNG panels:
  - residual_growth.png : res(A^{(x)t}, v)_i = t * lambda grows linearly in the secret t.
  - divisibility_lattice.png : a heatmap of (m+1)|(k+1) recovered from public eigenvalues.
"""
from typing import List
import numpy as np
import matplotlib.pyplot as plt

Matrix = List[List[float]]
Vector = List[float]

def trop_mat_mul(A, B):
    n = len(A)
    return [[min(A[i][k] + B[k][j] for k in range(n)) for j in range(n)] for i in range(n)]

def trop_mat_vec(A, v):
    n = len(A)
    return [min(A[i][k] + v[k] for k in range(n)) for i in range(n)]

def trop_mat_pow(A, k):
    M = [row[:] for row in A]
    for _ in range(k):
        M = trop_mat_mul(A, M)
    return M

def eigen_matrix(v, lam):
    n = len(v)
    return [[v[i] - v[j] + lam for j in range(n)] for i in range(n)]

# Panel 1: linear residual growth for several eigenvalues
v = [0.0, 2.0, 5.0, 1.0]
ts = list(range(1, 13))
plt.figure(figsize=(7, 4))
for lam in (1.0, 2.0, 3.0):
    A = eigen_matrix(v, lam)
    res = []
    for t in ts:
        B = trop_mat_pow(A, t - 1)
        Bv = trop_mat_vec(B, v)
        res.append(Bv[0] - v[0])
    plt.plot(ts, res, marker="o", label=f"lambda = {lam}")
plt.xlabel("secret exponent t")
plt.ylabel("measured residual = t * lambda")
plt.title("Eigenvalue additivity: the residual counts the secret")
plt.legend()
plt.tight_layout()
plt.savefig("residual_growth.png", dpi=140)

# Panel 2: divisibility lattice recovered from public eigenvalues
N = 12
c = 3
M = np.zeros((N, N))
for m in range(1, N + 1):
    for k in range(1, N + 1):
        a_m, a_k = c * m, c * k
        M[m - 1, k - 1] = 1.0 if (a_k % a_m == 0) else 0.0
plt.figure(figsize=(5.5, 5))
plt.imshow(M, origin="lower", extent=[1, N, 1, N], cmap="Greens")
plt.xlabel("genuine exponent k+1")
plt.ylabel("genuine exponent m+1")
plt.title("Leaked divisibility: a(m+1) | a(k+1)")
plt.colorbar(label="divides (1) / not (0)")
plt.tight_layout()
plt.savefig("divisibility_lattice.png", dpi=140)
print("Saved residual_growth.png and divisibility_lattice.png")
