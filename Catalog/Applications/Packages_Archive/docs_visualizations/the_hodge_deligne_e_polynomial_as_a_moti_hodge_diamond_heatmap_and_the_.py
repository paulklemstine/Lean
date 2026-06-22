"""Visualize the Hodge diamond and the palindromic Poincaré polynomial of a K3.

Renders the K3 Hodge diamond as a heatmap and the coefficient sequence of its
Poincaré polynomial P(X;t)=E(X;t,t), highlighting the left-right (palindromic)
symmetry forced by Serre duality.  Requires matplotlib + numpy.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

# K3 surface Hodge numbers (dim 2)
table = {(0, 0): 1, (2, 2): 1, (1, 1): 20, (2, 0): 1, (0, 2): 1}
dim = 2

grid = np.zeros((dim + 1, dim + 1), dtype=int)
for (p, q), v in table.items():
    grid[p, q] = v

# Poincaré polynomial coefficients of degree d = p + q (with sign).
coeffs = np.zeros(2 * dim + 1)
for p in range(dim + 1):
    for q in range(dim + 1):
        coeffs[p + q] += ((-1) ** (p + q)) * grid[p, q]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))

im = ax1.imshow(grid, cmap="viridis", origin="lower")
ax1.set_title("K3 Hodge diamond  h^{p,q}")
ax1.set_xlabel("q"); ax1.set_ylabel("p")
for p in range(dim + 1):
    for q in range(dim + 1):
        ax1.text(q, p, str(grid[p, q]), ha="center", va="center", color="white")
fig.colorbar(im, ax=ax1, shrink=0.8)

deg = np.arange(2 * dim + 1)
ax2.bar(deg, coeffs, color="#3b6ea5")
ax2.set_title("Poincaré coefficients  P(X;t) = t^{2n} P(X;1/t)")
ax2.set_xlabel("degree d = p + q"); ax2.set_ylabel("coefficient")
ax2.axvline(dim, color="crimson", ls="--", label="center of symmetry")
ax2.legend()

plt.tight_layout()
plt.savefig("k3_epolynomial.png", dpi=150)
print("wrote k3_epolynomial.png")