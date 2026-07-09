"""Visualization: heatmap of the Gaussian curvature K(x, y) of the split metric."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

def K_closed(x: float, y: float) -> float:
    cy2, cx2 = math.cosh(y) ** 2, math.cosh(x) ** 2
    return -cy2 + (2.0 - cy2) / (cx2 * cy2)

xs = np.linspace(-2.0, 2.0, 400)
ys = np.linspace(-2.0, 2.0, 400)
Z = np.array([[K_closed(x, y) for x in xs] for y in ys])

plt.figure(figsize=(7, 6))
vmax = np.max(np.abs(Z))
plt.pcolormesh(xs, ys, Z, cmap="RdBu", vmin=-vmax, vmax=vmax, shading="auto")
plt.colorbar(label="Gaussian curvature K(x, y)")
plt.contour(xs, ys, Z, levels=[0.0], colors="k", linewidths=1.5)
plt.title("Gaussian curvature of the split metric (K <= 0 everywhere on axes)")
plt.xlabel("x"); plt.ylabel("y")
plt.tight_layout()
plt.savefig("curvature_heatmap.png", dpi=150)
print("wrote curvature_heatmap.png")
