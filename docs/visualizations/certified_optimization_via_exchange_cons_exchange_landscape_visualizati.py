#!/usr/bin/env python3
"""
Visualization: Exchange Landscape and Certified Bounds

Visualizes the exchange graph of a small matroid, showing:
- All bases as nodes, colored by weight
- Exchange edges connecting bases that differ by one swap
- Exchange-local maxima highlighted
- Certified approximation bounds as annotations

This visualization makes tangible how the exchange constant K
controls the "roughness" of the optimization landscape.
"""

import itertools
import random
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import Normalize
from matplotlib.cm import ScalarMappable


def compute_exchange_graph(n, r, weight_fn):
    """Compute the exchange graph: nodes = bases, edges = single swaps."""
    bases = [frozenset(s) for s in itertools.combinations(range(n), r)]
    weights = {B: weight_fn(B) for B in bases}

    edges = []
    for i, B1 in enumerate(bases):
        for j, B2 in enumerate(bases):
            if i < j and len(B1 - B2) == 1:  # single swap
                edges.append((i, j))

    # Find local maxima
    local_maxima = set()
    for i, B in enumerate(bases):
        is_max = True
        for j, B2 in enumerate(bases):
            if (min(i,j), max(i,j)) in [(e[0],e[1]) for e in edges] or \
               (min(j,i), max(j,i)) in [(e[0],e[1]) for e in edges]:
                if i != j and len(B - B2) == 1 and weights[B2] > weights[B]:
                    is_max = False
                    break
        if is_max:
            local_maxima.add(i)

    return bases, weights, edges, local_maxima


def compute_exchange_constant(bases, weight_fn):
    """Compute K for the given bases and weight function."""
    K = 0.0
    for B1 in bases:
        for B2 in bases:
            for x in B1 - B2:
                min_gap = float('inf')
                for y in B2 - B1:
                    B1n = (B1 - {x}) | {y}
                    B2n = (B2 - {y}) | {x}
                    gap = weight_fn(B1) + weight_fn(B2) - weight_fn(B1n) - weight_fn(B2n)
                    min_gap = min(min_gap, gap)
                if min_gap != float('inf'):
                    K = max(K, min_gap)
    return max(K, 0.0)


def spring_layout(n_nodes, edges, iterations=200):
    """Simple spring layout for graph visualization."""
    pos = np.random.RandomState(42).randn(n_nodes, 2)

    for _ in range(iterations):
        # Repulsive forces
        forces = np.zeros_like(pos)
        for i in range(n_nodes):
            for j in range(n_nodes):
                if i != j:
                    diff = pos[i] - pos[j]
                    dist = max(np.linalg.norm(diff), 0.01)
                    forces[i] += diff / (dist ** 2) * 0.5

        # Attractive forces along edges
        for i, j in edges:
            diff = pos[j] - pos[i]
            dist = np.linalg.norm(diff)
            forces[i] += diff * dist * 0.01
            forces[j] -= diff * dist * 0.01

        pos += forces * 0.05
        # Center
        pos -= pos.mean(axis=0)

    return pos


def make_figure():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    random.seed(42)
    n, r = 5, 2

    wt = {0: 1.0, 1: 3.0, 2: 5.0, 3: 7.0, 4: 9.0}

    # Panel 1: Additive weight (K = 0)
    def w_add(B):
        return sum(wt[x] for x in B)

    bases, weights, edges, local_max = compute_exchange_graph(n, r, w_add)
    K_add = compute_exchange_constant(bases, w_add)
    pos = spring_layout(len(bases), edges)

    w_vals = [weights[B] for B in bases]
    norm = Normalize(vmin=min(w_vals), vmax=max(w_vals))
    cmap = plt.cm.YlOrRd

    ax = axes[0]
    ax.set_title(f'Additive Weight (K = {K_add:.1f})\nLocal opt = Global opt', fontsize=13, fontweight='bold')

    for i, j in edges:
        ax.plot([pos[i, 0], pos[j, 0]], [pos[i, 1], pos[j, 1]],
                'gray', alpha=0.3, linewidth=1)

    for i, B in enumerate(bases):
        color = cmap(norm(weights[B]))
        size = 400 if i in local_max else 200
        marker = '*' if i in local_max else 'o'
        edgecolor = 'red' if i in local_max else 'black'
        lw = 3 if i in local_max else 1
        ax.scatter(pos[i, 0], pos[i, 1], c=[color], s=size,
                   marker=marker, edgecolors=edgecolor, linewidth=lw, zorder=5)
        label = '{' + ','.join(str(x) for x in sorted(B)) + '}'
        ax.annotate(f'{label}\n{weights[B]:.0f}', (pos[i, 0], pos[i, 1]),
                    textcoords="offset points", xytext=(0, -20),
                    ha='center', fontsize=7)

    ax.set_xlim(pos[:, 0].min() - 0.5, pos[:, 0].max() + 0.5)
    ax.set_ylim(pos[:, 1].min() - 0.8, pos[:, 1].max() + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Panel 2: Quadratic weight (K > 0)
    def w_quad(B):
        return sum(wt[x] for x in B) ** 2

    bases2, weights2, edges2, local_max2 = compute_exchange_graph(n, r, w_quad)
    K_quad = compute_exchange_constant(bases2, w_quad)
    pos2 = spring_layout(len(bases2), edges2)

    w_vals2 = [weights2[B] for B in bases2]
    norm2 = Normalize(vmin=min(w_vals2), vmax=max(w_vals2))

    ax = axes[1]
    ax.set_title(f'Quadratic Weight (K = {K_quad:.1f})\nCertified bound: gap ≤ K × distance', fontsize=13, fontweight='bold')

    for i, j in edges2:
        ax.plot([pos2[i, 0], pos2[j, 0]], [pos2[i, 1], pos2[j, 1]],
                'gray', alpha=0.3, linewidth=1)

    for i, B in enumerate(bases2):
        color = cmap(norm2(weights2[B]))
        size = 400 if i in local_max2 else 200
        marker = '*' if i in local_max2 else 'o'
        edgecolor = 'red' if i in local_max2 else 'black'
        lw = 3 if i in local_max2 else 1
        ax.scatter(pos2[i, 0], pos2[i, 1], c=[color], s=size,
                   marker=marker, edgecolors=edgecolor, linewidth=lw, zorder=5)
        label = '{' + ','.join(str(x) for x in sorted(B)) + '}'
        ax.annotate(f'{label}\n{weights2[B]:.0f}', (pos2[i, 0], pos2[i, 1]),
                    textcoords="offset points", xytext=(0, -20),
                    ha='center', fontsize=7)

    ax.set_xlim(pos2[:, 0].min() - 0.5, pos2[:, 0].max() + 0.5)
    ax.set_ylim(pos2[:, 1].min() - 0.8, pos2[:, 1].max() + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Legend
    star = mpatches.Patch(color='red', label='Exchange-local maximum (★)')
    circle = mpatches.Patch(color='gray', label='Other bases (○)')
    fig.legend(handles=[star, circle], loc='lower center', ncol=2,
              fontsize=11, frameon=False)

    fig.suptitle('Exchange Landscape: How K Controls Optimization Quality',
                fontsize=15, fontweight='bold', y=0.98)

    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig('viz_exchange_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved viz_exchange_landscape.png")


if __name__ == "__main__":
    make_figure()
