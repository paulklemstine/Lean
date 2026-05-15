import numpy as np

def project_to_rank1(A):
    row_means = A.mean(axis=1)
    col_means = A.mean(axis=0)
    grand_mean = A.mean()
    u = row_means
    v = col_means - grand_mean
    A_proj = u[:, None] + v[None, :]
    return A_proj, u, v

# Example
np.random.seed(42)
u0 = np.array([1, 3, -1, 4, 2], dtype=float)
v0 = np.array([2, -1, 3, 0], dtype=float)
A_rank1 = u0[:, None] + v0[None, :]
A_noisy = A_rank1 + 0.1 * np.random.randn(5, 4)
A_proj, u, v = project_to_rank1(A_noisy)
residual = np.linalg.norm(A_noisy - A_proj) / np.linalg.norm(A_noisy)
print(f"Relative residual: {residual:.4f}")