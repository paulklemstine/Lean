#!/usr/bin/env python3
"""
Visualization: Affected Derivative Nodes Heatmap

Visualizes the affected derivative profile for rank-1 updates. Shows how the
number of affected certificate nodes varies with derivative depth and update
exponent structure, illustrating the sparsity that enables dynamic certification.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def affected_count(alpha, k):
    """Count affected multiindices at depth k bounded by alpha."""
    n = len(alpha)
    count = [0]

    def backtrack(pos, remaining):
        if pos == n:
            if remaining == 0:
                count[0] += 1
            return
        for val in range(min(remaining, alpha[pos]) + 1):
            backtrack(pos + 1, remaining - val)

    backtrack(0, k)
    return count[0]


def total_multiindices(n, k):
    """Total number of multiindices of order k in n variables (stars and bars)."""
    from math import comb
    return comb(n + k - 1, k) if n > 0 else (1 if k == 0 else 0)


# Parameters
n = 6  # number of variables

# Different update patterns
patterns = {
    'Dense: α=(2,2,1,1,1,0)': (2, 2, 1, 1, 1, 0),
    'Sparse: α=(3,0,0,0,0,0)': (3, 0, 0, 0, 0, 0),
    'Squarefree: α=(1,1,1,0,0,0)': (1, 1, 1, 0, 0, 0),
    'Uniform: α=(1,1,1,1,1,1)': (1, 1, 1, 1, 1, 1),
}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Affected Derivative Nodes: Sparsity of Certificate Updates',
             fontsize=14, fontweight='bold')

for ax, (label, alpha) in zip(axes.flat, patterns.items()):
    d = sum(alpha)
    max_k = d

    depths = list(range(max_k + 1))
    aff_counts = [affected_count(alpha, k) for k in depths]
    total_counts = [total_multiindices(n, k) for k in depths]
    fractions = [a / max(t, 1) for a, t in zip(aff_counts, total_counts)]

    # Bar chart
    x = np.arange(len(depths))
    width = 0.35

    bars1 = ax.bar(x - width/2, total_counts, width, label='Total nodes',
                   color='lightcoral', alpha=0.7)
    bars2 = ax.bar(x + width/2, aff_counts, width, label='Affected nodes',
                   color='steelblue', alpha=0.9)

    ax.set_xlabel('Derivative Depth k')
    ax.set_ylabel('Number of Nodes')
    ax.set_title(label, fontsize=11)
    ax.set_xticks(x)
    ax.set_xticklabels(depths)
    ax.legend(fontsize=8)

    # Add fraction labels
    for i, (a, t) in enumerate(zip(aff_counts, total_counts)):
        if t > 0:
            frac = a / t
            ax.text(i, max(a, t) * 1.05, f'{frac:.0%}',
                    ha='center', va='bottom', fontsize=7, color='darkgreen')

plt.tight_layout()
plt.savefig('viz_affected_nodes.png', dpi=150, bbox_inches='tight')
print("Saved viz_affected_nodes.png")

# Second figure: scaling comparison
fig2, ax2 = plt.subplots(1, 1, figsize=(10, 6))

ns = [4, 5, 6, 7, 8, 9, 10]
rebuild_costs = []
dynamic_costs = []

for nv in ns:
    ne = nv * (nv - 1) // 2  # complete graph edges
    deg = nv - 1
    # Squarefree update: spanning tree monomial
    alpha = tuple([1] * (nv - 1) + [0] * (ne - nv + 1))

    rebuild = ne ** deg
    dynamic = ne**2 * sum(affected_count(alpha, k) for k in range(deg - 1))

    rebuild_costs.append(rebuild)
    dynamic_costs.append(dynamic)

ax2.semilogy(ns, rebuild_costs, 'ro-', linewidth=2, markersize=8, label='Full Rebuild Cost')
ax2.semilogy(ns, dynamic_costs, 'bs-', linewidth=2, markersize=8, label='Dynamic Update Cost')
ax2.set_xlabel('Number of Vertices (Complete Graph $K_n$)', fontsize=12)
ax2.set_ylabel('Certificate Cost (log scale)', fontsize=12)
ax2.set_title('Dynamic vs Rebuild Certificate Cost: Exponential Savings', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Add ratio annotations
for i, nv in enumerate(ns):
    ratio = dynamic_costs[i] / rebuild_costs[i]
    ax2.annotate(f'{ratio:.1e}', (nv, dynamic_costs[i]),
                textcoords="offset points", xytext=(15, 5), fontsize=8, color='blue')

plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")
