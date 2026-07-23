"""Visualization: residue torus order p^f - 1 as a heatmap over (p, f)."""
import numpy as np
import matplotlib.pyplot as plt

primes = [2, 3, 5, 7, 11, 13]
degrees = list(range(1, 7))
Z = np.array([[np.log10(p ** f - 1) if p ** f - 1 > 0 else 0
               for f in degrees] for p in primes])

fig, ax = plt.subplots(figsize=(8, 5))
im = ax.imshow(Z, aspect="auto", cmap="viridis", origin="lower")
ax.set_xticks(range(len(degrees)), degrees)
ax.set_yticks(range(len(primes)), primes)
ax.set_xlabel("residue degree f")
ax.set_ylabel("residue characteristic p")
ax.set_title("log10 of residue torus order  |k^x| = p^f - 1")
for i, p in enumerate(primes):
    for j, f in enumerate(degrees):
        ax.text(j, i, str(p ** f - 1), ha="center", va="center",
                color="white", fontsize=7)
fig.colorbar(im, label="log10(p^f - 1)")
plt.tight_layout()
plt.savefig("torus_order_heatmap.png", dpi=150)
print("wrote torus_order_heatmap.png")
