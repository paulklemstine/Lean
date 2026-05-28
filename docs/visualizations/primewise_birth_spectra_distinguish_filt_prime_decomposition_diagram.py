#!/usr/bin/env python3
"""
Visualization: Prime Decomposition of the Global Birth Set

Shows how the global torsion birth set decomposes as a union of primewise
birth sets. Illustrates the structural theorem: globalTorsionBirthSet =
⋃_p pTorsionBirthSet(p, F), and how two profiles can have the same union
but different individual components.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ---------- Inline functions ----------

def p_birth_set(p, orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 and m % p == 0 for m in orders)}

def global_birth_set(orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 for m in orders)}


# ---------- Data ----------

F_orders = {0: set(), 1: {2}, 2: set(), 3: {6}}
G_orders = {0: set(), 1: {3}, 2: set(), 3: {6}}

primes = [2, 3]
levels = list(range(5))  # 0 through 4 for display

profiles = {
    'Profile F\n(2 at level 1, 6 at level 3)': F_orders,
    'Profile G\n(3 at level 1, 6 at level 3)': G_orders,
}

colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71'}  # prime colors
prime_names = {2: 'p=2', 3: 'p=3', 5: 'p=5'}

# ---------- Plot ----------

fig, axes = plt.subplots(2, 1, figsize=(12, 7), gridspec_kw={'hspace': 0.4})

for idx, (name, orders) in enumerate(profiles.items()):
    ax = axes[idx]

    # Draw level axis
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, len(primes) + 1.5)
    ax.set_xticks(levels)
    ax.set_xticklabels([str(l) for l in levels], fontsize=11)
    ax.set_xlabel('Filtration Level', fontsize=11)

    # Global birth set row
    gbs = global_birth_set(orders)
    y_global = len(primes) + 0.5
    for l in levels:
        if l in gbs:
            ax.add_patch(plt.Rectangle((l - 0.35, y_global - 0.3), 0.7, 0.6,
                                        facecolor='#f39c12', edgecolor='black',
                                        linewidth=1.5, zorder=3))
            ax.text(l, y_global, '✓', ha='center', va='center',
                    fontsize=14, fontweight='bold', zorder=4)
        else:
            ax.add_patch(plt.Rectangle((l - 0.35, y_global - 0.3), 0.7, 0.6,
                                        facecolor='#ecf0f1', edgecolor='gray',
                                        linewidth=0.5, zorder=3))

    ax.text(-0.45, y_global, 'Global', ha='right', va='center',
            fontsize=10, fontweight='bold', color='#f39c12')

    # Prime rows
    for pi, p in enumerate(primes):
        y = len(primes) - pi - 0.5
        pbs = p_birth_set(p, orders)
        for l in levels:
            if l in pbs:
                ax.add_patch(plt.Rectangle((l - 0.35, y - 0.3), 0.7, 0.6,
                                            facecolor=colors[p], edgecolor='black',
                                            linewidth=1.5, alpha=0.8, zorder=3))
                ax.text(l, y, '●', ha='center', va='center',
                        fontsize=16, color='white', zorder=4)
            else:
                ax.add_patch(plt.Rectangle((l - 0.35, y - 0.3), 0.7, 0.6,
                                            facecolor='#ecf0f1', edgecolor='gray',
                                            linewidth=0.5, zorder=3))
                ax.text(l, y, '○', ha='center', va='center',
                        fontsize=12, color='lightgray', zorder=4)

        ax.text(-0.45, y, prime_names[p], ha='right', va='center',
                fontsize=10, fontweight='bold', color=colors[p])

    # Draw union arrows
    for l in levels:
        if l in gbs:
            # Draw arrow from prime rows to global row
            active_primes = [pi for pi, p in enumerate(primes)
                             if l in p_birth_set(p, orders)]
            if active_primes:
                y_from = len(primes) - active_primes[0] - 0.5 + 0.35
                y_to = y_global - 0.35
                ax.annotate('', xy=(l, y_to), xytext=(l, y_from),
                            arrowprops=dict(arrowstyle='->', color='gray',
                                            lw=1, alpha=0.5))

    ax.set_title(name, fontsize=12, fontweight='bold', pad=10)
    ax.set_yticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)

# Add annotation
fig.text(0.5, -0.02,
         'The global row (union of prime rows) is identical for F and G,\n'
         'but the prime-by-prime decomposition differs — '
         'this is the separation theorem.',
         ha='center', fontsize=11, style='italic',
         bbox=dict(boxstyle='round,pad=0.4', facecolor='lightyellow',
                   edgecolor='orange', alpha=0.9))

plt.suptitle('Prime Decomposition of the Global Birth Set',
             fontsize=14, fontweight='bold')
plt.savefig('prime_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved: prime_decomposition.png")
