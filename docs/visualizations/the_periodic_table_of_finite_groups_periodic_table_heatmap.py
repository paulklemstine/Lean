#!/usr/bin/env python3
"""
Visualization: The Periodic Table of Small Finite Groups

Creates a heatmap-style periodic table showing group invariants
(derived depth as row, order as position, valence as color intensity).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def omega(n):
    """Number of prime factors with multiplicity."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    while d * d <= n:
        while n % d == 0:
            count += 1
            n //= d
        d += 1
    if n > 1:
        count += 1
    return count


# Group data: (name, order, derived_depth, valence, center_order, is_nilpotent)
groups = [
    ("Z/1Z", 1, 0, 0, 1, True),
    ("Z/2Z", 2, 1, 1, 2, True),
    ("Z/3Z", 3, 1, 1, 3, True),
    ("Z/4Z", 4, 1, 1, 4, True),
    ("V₄", 4, 1, 3, 4, True),
    ("Z/5Z", 5, 1, 1, 5, True),
    ("Z/6Z", 6, 1, 2, 6, True),
    ("Z/7Z", 7, 1, 1, 7, True),
    ("Z/8Z", 8, 1, 1, 8, True),
    ("Z/2Z³", 8, 1, 7, 8, True),
    ("D₄", 8, 2, 1, 2, True),
    ("Q₈", 8, 2, 1, 2, True),
    ("S₃", 6, 2, 1, 1, False),
    ("D₅", 10, 2, 1, 1, False),
    ("A₄", 12, 2, 1, 1, False),
    ("D₆", 12, 2, 1, 2, False),
    ("S₄", 24, 3, 1, 1, False),
    # A5 is not solvable
]

fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Plot 1: Derived depth vs group order
ax1 = axes[0]
for name, order, dd, val, center, nilp in groups:
    color = 'royalblue' if nilp else 'crimson'
    size = 50 + val * 80
    ax1.scatter(order, dd, s=size, c=color, alpha=0.7, edgecolors='black', linewidth=0.5)
    ax1.annotate(name, (order, dd), textcoords="offset points",
                xytext=(5, 5), fontsize=7, alpha=0.8)

ax1.set_xlabel("Group Order |G|", fontsize=12)
ax1.set_ylabel("Derived Depth d(G)", fontsize=12)
ax1.set_title("Periodic Table: Derived Depth vs Order", fontsize=14)

# Add the Ω bound line
orders = np.arange(1, 30)
omegas = [omega(n) for n in orders]
ax1.plot(orders, omegas, 'k--', alpha=0.3, label="Ω(|G|) bound")
ax1.legend(handles=[
    mpatches.Patch(color='royalblue', label='Nilpotent'),
    mpatches.Patch(color='crimson', label='Non-nilpotent'),
    plt.Line2D([0], [0], color='k', linestyle='--', alpha=0.3, label='Ω(|G|) bound'),
], fontsize=9)

# Plot 2: Valence distribution
ax2 = axes[1]
valences = {}
for name, order, dd, val, center, nilp in groups:
    if val not in valences:
        valences[val] = []
    valences[val].append((name, order, dd, nilp))

colors_val = {0: '#cccccc', 1: '#4CAF50', 2: '#FF9800', 3: '#f44336', 7: '#9C27B0'}
for val in sorted(valences.keys()):
    entries = valences[val]
    orders_v = [e[1] for e in entries]
    depths_v = [e[2] for e in entries]
    c = colors_val.get(val, '#666666')
    ax2.scatter(orders_v, depths_v, s=100, c=c, alpha=0.7,
               edgecolors='black', linewidth=0.5, label=f'v={val}')
    for name, order, dd, nilp in entries:
        ax2.annotate(name, (order, dd), textcoords="offset points",
                    xytext=(5, 5), fontsize=7, alpha=0.8)

ax2.set_xlabel("Group Order |G|", fontsize=12)
ax2.set_ylabel("Derived Depth d(G)", fontsize=12)
ax2.set_title("Group Valence Distribution", fontsize=14)
ax2.legend(fontsize=9)

plt.tight_layout()
plt.savefig("periodic_table_groups.png", dpi=150, bbox_inches='tight')
print("Saved: periodic_table_groups.png")
