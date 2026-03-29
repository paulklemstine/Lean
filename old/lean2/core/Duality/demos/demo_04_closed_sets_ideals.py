#!/usr/bin/env python3
"""
Demo 4 — Closed Sets ↔ Ideals (The V-I Galois Connection)
==========================================================
V(I) = {p ∈ Spec(R) | I ⊆ p} — the vanishing locus.

Shows V(6) = V(2) ∪ V(3) = {(2), (3)} in Spec(ℤ),
illustrating that V reverses inclusion and turns products into unions.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

primes = [2, 3, 5, 7, 11, 13]
xs = np.linspace(1, 6, len(primes))

fig, axes = plt.subplots(1, 3, figsize=(18, 5))
fig.patch.set_facecolor("#0d1117")

configs = [
    ("V(2) = {(2)}", [True, False, False, False, False, False]),
    ("V(3) = {(3)}", [False, True, False, False, False, False]),
    ("V(6) = V(2) ∪ V(3) = {(2),(3)}", [True, True, False, False, False, False]),
]

for ax, (title, closed_pts) in zip(axes, configs):
    ax.set_facecolor("#0d1117")
    for x, p, is_closed in zip(xs, primes, closed_pts):
        if is_closed:
            # Closed point — highlighted
            ax.plot(x, 1, 's', color='#DA3633', markersize=22, zorder=5,
                    markeredgecolor='#F85149', markeredgewidth=2)
            ax.text(x, 0.5, f"({p})", ha='center', fontsize=11,
                    color='#F85149', fontweight='bold')
        else:
            ax.plot(x, 1, 'o', color='#21262D', markersize=16, zorder=5,
                    markeredgecolor='#484F58', markeredgewidth=1.5)
            ax.text(x, 0.5, f"({p})", ha='center', fontsize=10, color='#484F58')
    ax.set_title(title, color='white', fontsize=12, pad=12)
    ax.set_xlim(0, 7)
    ax.set_ylim(0, 1.8)
    ax.axis('off')

fig.suptitle("Row 4: Closed Subspaces ↔ Ideals — Vanishing Loci in Spec(ℤ)",
             fontsize=16, color='white', fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("demo_04_closed_sets_ideals.png", dpi=150, bbox_inches='tight',
            facecolor=fig.get_facecolor())
plt.show()
print("✓ Saved demo_04_closed_sets_ideals.png")
