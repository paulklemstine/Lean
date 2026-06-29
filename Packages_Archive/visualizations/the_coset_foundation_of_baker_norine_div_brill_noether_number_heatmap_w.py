"""Visualize the Brill-Noether number rho(g,r,d) as a heatmap over (r,d),
highlighting the rho=0 Brill-Noether wall and the Serre-duality symmetry."""
import numpy as np
import matplotlib.pyplot as plt

def bn_number(g: int, r: int, d: int) -> int:
    return g - (r + 1) * (g - d + r)

g = 5
rs = range(0, 8)
ds = range(-2, 14)
M = np.array([[bn_number(g, r, d) for d in ds] for r in rs])

fig, ax = plt.subplots(figsize=(9, 5))
im = ax.imshow(M, origin="lower", aspect="auto", cmap="RdBu",
               extent=[min(ds) - 0.5, max(ds) + 0.5, min(rs) - 0.5, max(rs) + 0.5],
               vmin=-abs(M).max(), vmax=abs(M).max())
cs = ax.contour(list(ds), list(rs), M, levels=[0], colors="black", linewidths=2)
ax.clabel(cs, fmt="rho=0 (Brill-Noether wall)")
ax.set_xlabel("degree d")
ax.set_ylabel("rank r")
ax.set_title(f"Brill-Noether number rho({g}, r, d) = g - (r+1)(g-d+r)")
fig.colorbar(im, label="rho")
plt.tight_layout()
plt.savefig("brill_noether_heatmap.png", dpi=150)
print("Saved brill_noether_heatmap.png")
