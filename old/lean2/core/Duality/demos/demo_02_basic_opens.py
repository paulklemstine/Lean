#!/usr/bin/env python3
"""
Demo 2 — Open Sets ↔ Ring Elements (Basic Opens)
=================================================
Visualises D(a) = {p ∈ Spec(R) | a ∉ p} for R = ℤ.

D(6) = D(2·3) = D(2) ∩ D(3):  all primes except (2) and (3).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

primes = [2, 3, 5, 7, 11, 13, 17, 19]
xs = np.linspace(1, 8, len(primes))

fig, axes = plt.subplots(1, 3, figsize=(18, 5))
fig.patch.set_facecolor("#0d1117")

titles = ["D(2): primes not containing 2", "D(3): primes not containing 3",
          "D(6) = D(2) ∩ D(3)"]
# Which primes are in each basic open
in_D2 = [p != 2 for p in primes]
in_D3 = [p != 3 for p in primes]
in_D6 = [p not in (2, 3) for p in primes]
sets = [in_D2, in_D3, in_D6]
colors_in = ['#3FB950', '#DA3633', '#A371F7']
colors_out = '#21262D'

for ax, title, membership, col in zip(axes, titles, sets, colors_in):
    ax.set_facecolor("#0d1117")
    for i, (x, p, inside) in enumerate(zip(xs, primes, membership)):
        c = col if inside else colors_out
        edge = col if inside else '#484F58'
        ax.plot(x, 1, 'o', color=c, markersize=20, zorder=5,
                markeredgecolor=edge, markeredgewidth=2)
        ax.text(x, 0.55, f"({p})", ha='center', fontsize=10, color='#C9D1D9')
    ax.set_title(title, color='white', fontsize=13, pad=12)
    ax.set_xlim(0, 9)
    ax.set_ylim(0, 1.8)
    ax.axis('off')

fig.suptitle("Row 2: Open Sets ↔ Elements — Basic Opens D(a) in Spec(ℤ)",
             fontsize=16, color='white', fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("demo_02_basic_opens.png", dpi=150, bbox_inches='tight',
            facecolor=fig.get_facecolor())
plt.show()
print("✓ Saved demo_02_basic_opens.png")
