#!/usr/bin/env python3
"""
Demo 5 — Dimension ↔ Krull Dimension
=====================================
Visualises chains of prime ideals for different rings.

k (field):  only (0)                          → dim 0
ℤ:          (0) ⊂ (p)                         → dim 1
k[x,y]:    (0) ⊂ (x) ⊂ (x,y)                → dim 2
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(18, 7))
fig.patch.set_facecolor("#0d1117")

chains = [
    ("Field k", ["(0)"], 0, '#3FB950'),
    ("ℤ", ["(0)", "(p)"], 1, '#58A6FF'),
    ("k[x, y]", ["(0)", "(x)", "(x, y)"], 2, '#A371F7'),
]

for ax, (ring_name, ideals, dim, color) in zip(axes, chains):
    ax.set_facecolor("#0d1117")
    n = len(ideals)
    ys = np.linspace(1, 1 + (n - 1) * 1.5, n)

    for i, (y, label) in enumerate(zip(ys, ideals)):
        ax.plot(3, y, 'o', color=color, markersize=24, zorder=5)
        ax.text(3, y, label, fontsize=11, ha='center', va='center',
                color='white', fontweight='bold')
        if i > 0:
            ax.annotate('', xy=(3, ys[i] - 0.2), xytext=(3, ys[i - 1] + 0.2),
                         arrowprops=dict(arrowstyle='->', color=color, lw=2.5))
            ax.text(3.8, (ys[i] + ys[i - 1]) / 2, "⊂",
                    fontsize=16, color=color, va='center')

    ax.set_title(f"{ring_name}\nKrull dim = {dim}",
                 fontsize=14, color='white', pad=15)
    ax.set_xlim(0, 6)
    ax.set_ylim(0, 5)
    ax.axis('off')

fig.suptitle("Row 5: Dimension ↔ Krull Dimension — Chain Lengths of Primes",
             fontsize=16, color='white', fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("demo_05_krull_dimension.png", dpi=150, bbox_inches='tight',
            facecolor=fig.get_facecolor())
plt.show()
print("✓ Saved demo_05_krull_dimension.png")
