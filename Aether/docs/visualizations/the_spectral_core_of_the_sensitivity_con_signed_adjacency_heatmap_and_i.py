"""Heatmap of the signed adjacency matrix A_n and its square (= n I)."""
import numpy as np
import matplotlib.pyplot as plt

def signed_adjacency(n: int) -> np.ndarray:
    if n == 0:
        return np.zeros((1, 1), dtype=np.int64)
    a = signed_adjacency(n - 1); s = a.shape[0]; i = np.eye(s, dtype=np.int64)
    return np.vstack([np.hstack([a, i]), np.hstack([i, -a])])

n = 4
a = signed_adjacency(n)
fig, ax = plt.subplots(1, 2, figsize=(11, 5))
im0 = ax[0].imshow(a, cmap="bwr", vmin=-1, vmax=1)
ax[0].set_title(f"$A_{{{n}}}$  (signed adjacency, entries in {{-1,0,1}})")
fig.colorbar(im0, ax=ax[0], fraction=0.046)
im1 = ax[1].imshow(a @ a, cmap="viridis")
ax[1].set_title(f"$A_{{{n}}}^2 = {n}\,I$")
fig.colorbar(im1, ax=ax[1], fraction=0.046)
plt.tight_layout()
plt.savefig("signed_adjacency_heatmap.png", dpi=150)
print("saved signed_adjacency_heatmap.png")
