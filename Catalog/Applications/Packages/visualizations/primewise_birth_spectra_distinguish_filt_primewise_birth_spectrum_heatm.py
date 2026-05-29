#!/usr/bin/env python3
"""
Visualization 1: Primewise Birth Spectrum Heatmap

Visualizes the primewise birth spectra of two filtration profiles (F and G)
side by side as heatmaps. Each cell (p, level) is colored if p-torsion is
born at that level. This shows at a glance how two profiles can share the
same row-marginal (global birth set) while differing in cell-level content
(primewise birth sets).

This is the visual analogue of the separation theorem: same column sums,
different cell values.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def p_torsion_birth_set(p, max_level, orders_at):
    """Compute p-torsion birth set from raw data."""
    result = set()
    for i in range(max_level + 1):
        if any(m > 1 and m % p == 0 for m in orders_at.get(i, [])):
            result.add(i)
    return result


def global_torsion_birth_set(max_level, orders_at):
    """Compute global torsion birth set."""
    return {i for i in range(max_level + 1) if any(m > 1 for m in orders_at.get(i, []))}


def make_heatmap_data(max_level, orders_at, primes):
    """Create a 2D array: rows = primes, cols = levels."""
    data = np.zeros((len(primes), max_level + 1))
    for pi, p in enumerate(primes):
        pbs = p_torsion_birth_set(p, max_level, orders_at)
        for lvl in pbs:
            data[pi, lvl] = 1.0
    return data


# Define the two witness profiles
F_orders = {1: [2], 3: [6]}
G_orders = {1: [3], 3: [6]}
max_level = 3
primes = [2, 3, 5]

fig, axes = plt.subplots(1, 2, figsize=(12, 4), sharey=True)

for ax, orders, name, color in [
    (axes[0], F_orders, "Profile F: orders {2} at level 1, {6} at level 3", "Blues"),
    (axes[1], G_orders, "Profile G: orders {3} at level 1, {6} at level 3", "Oranges"),
]:
    data = make_heatmap_data(max_level, orders, primes)
    im = ax.imshow(data, cmap=color, aspect='auto', vmin=0, vmax=1,
                   interpolation='nearest')

    ax.set_xticks(range(max_level + 1))
    ax.set_xticklabels([f"Level {i}" for i in range(max_level + 1)])
    ax.set_yticks(range(len(primes)))
    ax.set_yticklabels([f"p = {p}" for p in primes])
    ax.set_title(name, fontsize=10, pad=10)
    ax.set_xlabel("Filtration Level")

    # Annotate cells
    for pi in range(len(primes)):
        for lvl in range(max_level + 1):
            if data[pi, lvl] > 0:
                ax.text(lvl, pi, "✓", ha='center', va='center',
                        fontsize=14, fontweight='bold', color='white')

    # Mark global birth set
    gbs = global_torsion_birth_set(max_level, orders)
    for lvl in gbs:
        ax.axvline(x=lvl, color='red', linewidth=2, alpha=0.3, linestyle='--')

axes[0].set_ylabel("Prime Channel")

# Add global birth set legend
legend_elements = [
    mpatches.Patch(facecolor='red', alpha=0.3, label='Global birth level'),
    mpatches.Patch(facecolor='steelblue', label='p-torsion present (F)'),
    mpatches.Patch(facecolor='darkorange', label='p-torsion present (G)'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=3,
           bbox_to_anchor=(0.5, -0.05), fontsize=9)

fig.suptitle("Primewise Birth Spectrum Heatmap — Same Global, Different Primewise",
             fontsize=13, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig("viz_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")
