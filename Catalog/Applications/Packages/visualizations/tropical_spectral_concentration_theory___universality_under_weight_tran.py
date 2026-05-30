"""
Visualization 3: Universality of the Tropical Spectrum

Visualizes the universality theorem: applying different weight
transformations preserves the cycle-birth classification (flags).
The topology depends only on the ORDER of edge insertions, not
on the specific weight values.

What it shows:
- A fixed graph (K5) with various weight transformations
- The flags (merge vs cycle) remain identical across all monotone transforms
- Non-monotone transforms may change the flags
"""

import matplotlib.pyplot as plt
import numpy as np
import math


class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True


def extract_flags(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    flags = []
    for u, v, w in sorted_edges:
        if uf.union(u, v):
            flags.append(0)  # merge
        else:
            flags.append(1)  # cycle birth
    return flags, sorted_edges


n = 5
base_weights = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
edge_list = [(i, j) for i in range(n) for j in range(i+1, n)]
base_edges = [(u, v, w) for (u, v), w in zip(edge_list, base_weights)]

transforms = [
    ("Identity: x", lambda x: x),
    ("Linear: 2x + 5", lambda x: 2*x + 5),
    ("Quadratic: x²", lambda x: x**2),
    ("Square root: √x", lambda x: math.sqrt(x)),
    ("Logarithmic: ln(x+1)", lambda x: math.log(x + 1)),
    ("Exponential: eˣ", lambda x: math.exp(x/5)),
    ("Affine: 100 - 3x", lambda x: 100 - 3*x),  # monotone decreasing
    ("Sinusoidal: sin(x)", lambda x: math.sin(x)),  # non-monotone
]

fig, axes = plt.subplots(2, 4, figsize=(18, 8))
fig.suptitle('Universality: Weight Transforms Preserve Topology (K₅)',
             fontsize=16, fontweight='bold')

base_flags, base_sorted = extract_flags(n, base_edges)

for idx, (name, phi) in enumerate(transforms):
    ax = axes[idx // 4][idx % 4]

    new_edges = [(u, v, phi(w)) for u, v, w in base_edges]
    new_flags, new_sorted = extract_flags(n, new_edges)

    # Plot weights as bars colored by flag
    weights = [e[2] for e in new_sorted]
    colors = ['#e74c3c' if f == 1 else '#2ecc71' for f in new_flags]

    bars = ax.bar(range(len(weights)), weights, color=colors, alpha=0.8,
                  edgecolor='white', linewidth=0.5)

    # Check if flags match
    flags_match = new_flags == base_flags
    is_monotone = name not in ["Sinusoidal: sin(x)"]

    title_color = '#27ae60' if flags_match else '#c0392b'
    match_text = "✓ Flags preserved" if flags_match else "✗ Flags changed"
    cycle_count = sum(new_flags)
    base_cycle_count = sum(base_flags)
    cc_match = "✓" if cycle_count == base_cycle_count else "✗"

    ax.set_title(name, fontsize=11, fontweight='bold')
    ax.text(0.5, 0.95, match_text, transform=ax.transAxes, fontsize=9,
            ha='center', va='top', color=title_color, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

    ax.text(0.5, 0.85, f'Cycles: {cycle_count} {cc_match}',
            transform=ax.transAxes, fontsize=8, ha='center', va='top',
            color='#555')

    ax.set_xlabel('Edge (sorted by new weight)', fontsize=8)
    ax.set_ylabel('Transformed weight', fontsize=8)
    ax.tick_params(labelsize=7)

import matplotlib.patches as mpatches
merge_patch = mpatches.Patch(color='#2ecc71', alpha=0.8, label='Merge')
cycle_patch = mpatches.Patch(color='#e74c3c', alpha=0.8, label='Cycle birth')
fig.legend(handles=[merge_patch, cycle_patch], loc='lower center',
           ncol=2, fontsize=11, frameon=True, fancybox=True)

plt.tight_layout(rect=[0, 0.06, 1, 0.94])
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
