#!/usr/bin/env python3
"""
Visualization: Phase Diagram of Edge-Size Disorder

Shows the structural phase diagram: uniform hypergraphs (collision index = 1,
heterogeneity = 0) occupy a single point in invariant space, while increasing
disorder traces a path through lower collision index and higher heterogeneity.
This visualizes the "phase transition" from ordered to disordered regimes.
"""

import random
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import Counter


def edge_heterogeneity(edges):
    if not edges:
        return 0.0
    sizes = [len(e) for e in edges]
    mean_size = sum(sizes) / len(sizes)
    return sum((s - mean_size) ** 2 for s in sizes) / len(sizes)


def collision_index(edges):
    if not edges:
        return 1.0
    sizes = [len(e) for e in edges]
    counts = Counter(sizes)
    n = len(edges)
    return sum((c / n) ** 2 for c in counts.values())


def support_width(edges):
    if not edges:
        return 0
    sizes = [len(e) for e in edges]
    return max(sizes) - min(sizes)


def generate_random_hypergraph(n_vertices, n_edges, edge_sizes):
    vertices = list(range(n_vertices))
    edges = set()
    attempts = 0
    while len(edges) < n_edges and attempts < n_edges * 100:
        k = random.choice(edge_sizes)
        if k <= n_vertices:
            edge = tuple(sorted(random.sample(vertices, k)))
            edges.add(edge)
        attempts += 1
    return vertices, list(edges)


random.seed(42)
np.random.seed(42)

# Generate data points across different disorder regimes
data = {'het': [], 'ci': [], 'sw': [], 'regime': []}

# Regime 1: Uniform (single edge size)
for _ in range(80):
    k = random.choice([2, 3, 4, 5])
    n_edges = random.randint(4, 15)
    _, edges = generate_random_hypergraph(15, n_edges, [k])
    data['het'].append(edge_heterogeneity(edges))
    data['ci'].append(collision_index(edges))
    data['sw'].append(support_width(edges))
    data['regime'].append('Uniform')

# Regime 2: Two sizes (mild disorder)
for _ in range(120):
    a, b = sorted(random.sample([2, 3, 4, 5], 2))
    n_edges = random.randint(4, 15)
    _, edges = generate_random_hypergraph(15, n_edges, [a, b])
    data['het'].append(edge_heterogeneity(edges))
    data['ci'].append(collision_index(edges))
    data['sw'].append(support_width(edges))
    data['regime'].append('Two sizes')

# Regime 3: Three sizes (moderate disorder)
for _ in range(120):
    sizes = sorted(random.sample([2, 3, 4, 5], 3))
    n_edges = random.randint(4, 15)
    _, edges = generate_random_hypergraph(15, n_edges, sizes)
    data['het'].append(edge_heterogeneity(edges))
    data['ci'].append(collision_index(edges))
    data['sw'].append(support_width(edges))
    data['regime'].append('Three sizes')

# Regime 4: All four sizes (maximum disorder)
for _ in range(120):
    n_edges = random.randint(4, 15)
    _, edges = generate_random_hypergraph(15, n_edges, [2, 3, 4, 5])
    data['het'].append(edge_heterogeneity(edges))
    data['ci'].append(collision_index(edges))
    data['sw'].append(support_width(edges))
    data['regime'].append('Four sizes')

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

colors_map = {
    'Uniform': '#2ecc71',
    'Two sizes': '#3498db',
    'Three sizes': '#e67e22',
    'Four sizes': '#e74c3c',
}

# Plot 1: Collision Index vs Heterogeneity
ax = axes[0]
for regime in ['Uniform', 'Two sizes', 'Three sizes', 'Four sizes']:
    idx = [i for i, r in enumerate(data['regime']) if r == regime]
    ax.scatter([data['ci'][i] for i in idx],
               [data['het'][i] for i in idx],
               c=colors_map[regime], label=regime, alpha=0.6, s=25,
               edgecolors='none')
ax.set_xlabel('Collision Index (Σ pₖ²)', fontsize=12)
ax.set_ylabel('Heterogeneity (σ²)', fontsize=12)
ax.set_title('Phase Diagram: Disorder Invariants', fontsize=13)
ax.legend(fontsize=9)
ax.annotate('ORDERED\nPHASE', xy=(0.95, 0.05), fontsize=10, color='green',
            ha='center', alpha=0.7)
ax.annotate('DISORDERED\nPHASE', xy=(0.35, 1.0), fontsize=10, color='red',
            ha='center', alpha=0.7)

# Plot 2: Support Width histogram by regime
ax = axes[1]
for i, regime in enumerate(['Uniform', 'Two sizes', 'Three sizes', 'Four sizes']):
    idx = [j for j, r in enumerate(data['regime']) if r == regime]
    sws = [data['sw'][j] for j in idx]
    ax.hist(sws, bins=range(0, 5), alpha=0.6, color=colors_map[regime],
            label=regime, align='left')
ax.set_xlabel('Support Width', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Support Width Distribution by Regime', fontsize=13)
ax.legend(fontsize=9)

# Plot 3: Heterogeneity distribution by regime
ax = axes[2]
for regime in ['Uniform', 'Two sizes', 'Three sizes', 'Four sizes']:
    idx = [i for i, r in enumerate(data['regime']) if r == regime]
    hets = [data['het'][i] for i in idx]
    ax.hist(hets, bins=20, alpha=0.5, color=colors_map[regime],
            label=regime, density=True)
ax.set_xlabel('Heterogeneity (σ²)', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Heterogeneity Distribution by Regime', fontsize=13)
ax.legend(fontsize=9)

plt.tight_layout()
plt.savefig('viz_phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_diagram.png")
