import numpy as np
import matplotlib.pyplot as plt
from math import comb
from fractions import Fraction

def S(n, k):
    sign = -1 if (n + k) % 2 else 1
    return float(sign * Fraction((2 * k + 1) * comb(2 * n + 1, n - k), 2 * n + 1))

N = 9
M = np.zeros((N, N))
for n in range(N):
    for k in range(n + 1):
        M[n, k] = np.sign(S(n, k)) * np.log1p(abs(S(n, k)))

fig, ax = plt.subplots(figsize=(7, 6))
im = ax.imshow(M, cmap="coolwarm", vmin=-M.max(), vmax=M.max())
for n in range(N):
    for k in range(n + 1):
        v = S(n, k)
        ax.text(k, n, f"{int(v)}", ha="center", va="center", fontsize=8)
ax.set_title("Inverse Sprugnoli array  S = T^{-1}  (signed ballot numbers)")
ax.set_xlabel("k"); ax.set_ylabel("n")
fig.colorbar(im, label="signed log-magnitude")
plt.tight_layout()
plt.savefig("inverse_array_heatmap.png", dpi=150)
print("wrote inverse_array_heatmap.png")
