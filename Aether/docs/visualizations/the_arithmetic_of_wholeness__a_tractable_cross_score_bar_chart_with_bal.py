"""Heatmap of cross-score |A|*|B| = k(n-k) vs balanced-split optimum."""
import matplotlib.pyplot as plt
import numpy as np

n = 12
ks = np.arange(1, n)
products = ks * (n - ks)
opt_k = ks[np.argmax(products)]

fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.bar(ks, products, color="steelblue")
bars[np.argmax(products)].set_color("crimson")
ax.axhline(max(products), ls="--", color="crimson", alpha=0.6,
           label=f"max = floor(n^2/4) = {max(products)} at k={opt_k}")
ax.set_xlabel("size of first part $k=|A|$ (with $|B|=n-k$)")
ax.set_ylabel("cross-score $k(n-k)$")
ax.set_title(f"Cross-score of a bipartition (complete co-activation, n={n})")
ax.legend()
ax.grid(alpha=0.3, axis="y")
plt.tight_layout()
plt.savefig("cross_score.png", dpi=150)
print("wrote cross_score.png")
