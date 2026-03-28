#!/usr/bin/env python3
"""
Demo 1 — Points ↔ Prime Ideals
===============================
Visualises the prime spectrum of ℤ (the integers).

Spec(ℤ) = { (0), (2), (3), (5), (7), (11), … }

The generic point (0) is dense; each (p) is a closed point.
We draw the Zariski topology: closed sets are finite unions
of individual primes plus possibly (0).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# --- Data ---
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
labels = [f"({p})" for p in primes]
generic = "(0)"

fig, ax = plt.subplots(figsize=(14, 5))
fig.patch.set_facecolor("#0d1117")
ax.set_facecolor("#0d1117")

# Draw generic point
ax.plot(0.5, 2.5, 'o', color='#FFD700', markersize=18, zorder=5)
ax.annotate(generic, (0.5, 2.5), fontsize=14, ha='center', va='bottom',
            color='#FFD700', fontweight='bold',
            xytext=(0, 15), textcoords='offset points')

# Draw closed points
xs = np.linspace(1, 10, len(primes))
for i, (x, label) in enumerate(zip(xs, labels)):
    ax.plot(x, 1.0, 'o', color='#58A6FF', markersize=14, zorder=5)
    ax.annotate(label, (x, 1.0), fontsize=11, ha='center', va='top',
                color='#C9D1D9', xytext=(0, -15), textcoords='offset points')
    # Arrow from generic point to each closed point (density)
    ax.annotate('', xy=(x, 1.15), xytext=(0.5, 2.35),
                arrowprops=dict(arrowstyle='->', color='#FFD70055',
                                lw=1.0, connectionstyle='arc3,rad=0.1'))

# Annotations
ax.text(5.5, 3.8, "Spec(ℤ) — The Prime Spectrum of the Integers",
        fontsize=18, ha='center', color='white', fontweight='bold')
ax.text(5.5, 3.3, "Row 1 of the Universal Translator: Points ↔ Prime Ideals",
        fontsize=12, ha='center', color='#8B949E')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#FFD700', label='Generic point (0) — dense in Spec(ℤ)'),
    mpatches.Patch(facecolor='#58A6FF', label='Closed points (p) — maximal ideals'),
]
ax.legend(handles=legend_elements, loc='lower right', fontsize=10,
          facecolor='#161B22', edgecolor='#30363D', labelcolor='#C9D1D9')

ax.set_xlim(-0.5, 11.5)
ax.set_ylim(0, 4.2)
ax.axis('off')
plt.tight_layout()
plt.savefig("demo_01_points_and_ideals.png", dpi=150, bbox_inches='tight',
            facecolor=fig.get_facecolor())
plt.show()
print("✓ Saved demo_01_points_and_ideals.png")
