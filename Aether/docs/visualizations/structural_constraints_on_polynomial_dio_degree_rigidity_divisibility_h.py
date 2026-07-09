import numpy as np
import matplotlib.pyplot as plt

ks = np.arange(2, 11)
ds = np.arange(1, 11)
grid = np.array([[1 if (2 * d) % k == 0 else 0 for d in ds] for k in ks])

fig, ax = plt.subplots(figsize=(7, 6))
ax.imshow(grid, cmap="RdYlGn", aspect="auto", origin="lower",
          extent=[ds[0] - 0.5, ds[-1] + 0.5, ks[0] - 0.5, ks[-1] + 0.5])
ax.set_xlabel("common degree d")
ax.set_ylabel("exponent k")
ax.set_title("Same-degree feasibility: green = k | 2d allowed, red = forbidden")
ax.set_xticks(ds)
ax.set_yticks(ks)
plt.tight_layout()
plt.savefig("degree_rigidity_heatmap.png", dpi=150)
print("wrote degree_rigidity_heatmap.png")
