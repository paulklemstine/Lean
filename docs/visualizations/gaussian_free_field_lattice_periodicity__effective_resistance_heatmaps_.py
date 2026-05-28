#!/usr/bin/env python3
"""
Visualization: Effective Resistance Heatmap on Cycle Graphs

Visualizes the effective resistance matrix R(i,j) for cycle graphs C_n
of increasing size, demonstrating the exact formula R(i,j) = d(i,j)(n-d(i,j))/n.
The heatmap reveals the beautiful circulant structure: resistance depends only
on the cyclic distance and achieves its maximum at diametrically opposite vertices.
"""

import numpy as np
import matplotlib.pyplot as plt


def cycle_laplacian(n):
    L = np.zeros((n, n))
    for k in range(n):
        i, j = k, (k + 1) % n
        L[i, i] += 1; L[j, j] += 1
        L[i, j] -= 1; L[j, i] -= 1
    return L


def effective_resistance_matrix(L):
    Lp = np.linalg.pinv(L)
    diag = np.diag(Lp)
    return diag[:, None] + diag[None, :] - 2 * Lp


fig, axes = plt.subplots(1, 4, figsize=(16, 4))
fig.suptitle("Effective Resistance on Cycle Graphs $C_n$\n"
             "$R(i,j) = d(i,j) \\cdot (n - d(i,j)) / n$",
             fontsize=14, fontweight='bold')

for idx, n in enumerate([5, 8, 12, 20]):
    ax = axes[idx]
    L = cycle_laplacian(n)
    R = effective_resistance_matrix(L)

    im = ax.imshow(R, cmap='YlOrRd', interpolation='nearest')
    ax.set_title(f"$C_{{{n}}}$", fontsize=13)
    ax.set_xlabel("Vertex $j$")
    if idx == 0:
        ax.set_ylabel("Vertex $i$")
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    # Mark maximum resistance
    max_r = R.max()
    ax.text(0.5, -0.15, f"max R = {max_r:.3f}",
            transform=ax.transAxes, ha='center', fontsize=9)

plt.tight_layout()
plt.savefig("viz_resistance_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_resistance_heatmap.png")
