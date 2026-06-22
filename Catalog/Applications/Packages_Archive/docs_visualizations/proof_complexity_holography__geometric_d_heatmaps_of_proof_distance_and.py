"""Visualization: proof distance under the doubling translation.

Renders, side by side, the source chain metric d(a,b)=b-a and the doubled
target metric d(2a,2b), showing the exact factor-2 scaling (Theorem 7.2).
Requires matplotlib. Run: python viz_doubling.py"""
import matplotlib.pyplot as plt
import numpy as np

N = 12
src = np.array([[max(b - a, 0) if a <= b else np.nan for b in range(N + 1)]
                for a in range(N + 1)])
tgt = np.array([[max(2 * b - 2 * a, 0) if a <= b else np.nan for b in range(N + 1)]
                for a in range(N + 1)])

fig, axs = plt.subplots(1, 3, figsize=(15, 4.5))
for ax, M, title in [
    (axs[0], src, "source: d(a,b) = b - a"),
    (axs[1], tgt, "target: d(2a, 2b)"),
    (axs[2], tgt - 2 * src, "d(2a,2b) - 2*d(a,b)  (identically 0)"),
]:
    im = ax.imshow(M, origin="lower", cmap="viridis")
    ax.set_title(title)
    ax.set_xlabel("b"); ax.set_ylabel("a")
    fig.colorbar(im, ax=ax, fraction=0.046)
axs[2].set_title("zero slack: bound attained exactly")
plt.suptitle("Holographic exactness of the doubling translation (stretch L = 2)")
plt.tight_layout()
plt.savefig("doubling_isometry.png", dpi=130)
print("wrote doubling_isometry.png")
