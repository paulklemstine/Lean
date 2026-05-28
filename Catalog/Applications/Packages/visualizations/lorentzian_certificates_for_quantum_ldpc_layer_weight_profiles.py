"""
Visualization: Layer Weight Profiles and Log-Concavity

Visualizes how the layer weight distribution a_0, a_1, ..., a_n differs
across code families. Good codes should show a clean bell-shaped profile
with vanishing low layers, while poor codes have mass concentrated near
the origin. The log-concavity condition a_k^2 ≥ a_{k-1}*a_{k+1} is shown
at each layer.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


# === Inline all needed functions ===

def layer_weight(mu, n, k):
    return sum(v for s, v in mu.items() if len(s) == k)

def all_layer_weights(mu, n):
    return [layer_weight(mu, n, k) for k in range(n + 1)]

def make_hypergraph_product(n):
    target_k = int(n * 0.5)
    sigma = max(1, n * 0.1)
    dist_gap = max(2, n // 4)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def make_repetition(n):
    mu = {}
    total = 0.0
    for k in range(min(3, n + 1)):
        w = (n + 1 - k) * comb(n, k)
        for s in combinations(range(n), k):
            mu[frozenset(s)] = w / comb(n, k)
        total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def make_punctured_surface(n):
    dist_gap = max(1, int(np.sqrt(n)))
    target_k = n // 2
    sigma = max(1, n * 0.15)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu


# === Computation ===

n = 8
families = {
    'Hypergraph Product (good distance)': make_hypergraph_product,
    'Repetition Code (poor distance)': make_repetition,
    'Punctured Surface (√n distance)': make_punctured_surface,
}

colors = ['#2196F3', '#F44336', '#FF9800']

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for idx, (name, gen) in enumerate(families.items()):
    mu = gen(n)
    weights = all_layer_weights(mu, n)
    ax = axes[idx]

    layers = list(range(n + 1))
    ax.bar(layers, weights, color=colors[idx], alpha=0.7, edgecolor='black', linewidth=0.5)

    # Mark log-concavity at each interior layer
    for k in range(1, n):
        denom = weights[k - 1] * weights[k + 1]
        if denom > 1e-15:
            ratio = weights[k] ** 2 / denom
            marker_color = '#4CAF50' if ratio >= 1 - 1e-10 else '#F44336'
            ax.plot(k, weights[k] + 0.01, 'v', color=marker_color, markersize=6)

    ax.set_xlabel('Layer k', fontsize=11)
    ax.set_ylabel('Layer weight a_k', fontsize=11)
    ax.set_title(name, fontsize=11)
    ax.set_xticks(layers)
    ax.grid(True, alpha=0.3, axis='y')

# Legend for log-concavity markers
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='v', color='w', markerfacecolor='#4CAF50',
           markersize=8, label='Log-concave (a_k² ≥ a_{k-1}a_{k+1})'),
    Line2D([0], [0], marker='v', color='w', markerfacecolor='#F44336',
           markersize=8, label='NOT log-concave'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=2,
           fontsize=10, bbox_to_anchor=(0.5, -0.05))

plt.suptitle(f'Layer Weight Profiles (n={n}): Distance Signature in Polynomial Geometry',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('layer_weights.png', dpi=150, bbox_inches='tight')
print("Saved layer_weights.png")
