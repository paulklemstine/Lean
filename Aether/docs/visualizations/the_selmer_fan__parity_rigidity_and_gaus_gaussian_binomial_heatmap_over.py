"""Heatmap of log Gaussian binomials [n,k]_q over the (n,k) grid."""
import matplotlib.pyplot as plt
import numpy as np


def gauss_binom(q, n, k):
    if k < 0 or k > n:
        return 0
    row = [1] + [0] * n
    for m in range(1, n + 1):
        new = [1] + [0] * n
        for j in range(1, m + 1):
            new[j] = row[j - 1] + (q ** j) * row[j]
        row = new
    return row[k]


q = 2
N = 12
M = np.zeros((N + 1, N + 1))
for n in range(N + 1):
    for k in range(N + 1):
        v = gauss_binom(q, n, k)
        M[n, k] = np.log10(v) if v > 0 else np.nan
plt.figure(figsize=(7, 6))
plt.imshow(M, origin="lower", aspect="auto", cmap="viridis")
plt.colorbar(label="log10 [n,k]_q")
plt.title(f"Gaussian binomial fan (q={q}): symmetric ridge at k=n/2")
plt.xlabel("k")
plt.ylabel("n")
plt.tight_layout()
plt.savefig("gauss_heatmap.png", dpi=150)
print("wrote gauss_heatmap.png")
