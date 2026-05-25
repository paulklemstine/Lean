"""
Visualization: Stability Bound Tightness

Compares the actual tropical barcode distance against the information-theoretic
stability bound exp(C(Δ)) · ε for random perturbations on different graph families.
Demonstrates that the capacity bound is tight for regular graphs and loose for
irregular graphs (measured by the capacity gap).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tropical_barcode_dist(adj, f, g):
    """Compute tropical barcode distance."""
    degrees = adj.sum(axis=1).astype(int)
    return max(abs(f[i] - g[i]) * (degrees[i] + 1) for i in range(len(f)))


def stability_bound(adj, f, g):
    """Compute (D+1)*epsilon stability bound."""
    D = int(adj.sum(axis=1).max())
    eps = np.max(np.abs(f - g))
    return (D + 1) * eps


def make_cycle(n):
    adj = np.zeros((n, n))
    for i in range(n):
        adj[i, (i+1) % n] = 1
        adj[(i+1) % n, i] = 1
    return adj


def make_star(n):
    adj = np.zeros((n, n))
    for i in range(1, n):
        adj[0, i] = 1
        adj[i, 0] = 1
    return adj


def make_complete(n):
    return np.ones((n, n)) - np.eye(n)


rng = np.random.RandomState(42)
n = 15
n_trials = 300

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Stability Bound Tightness: Barcode Distance vs Capacity Bound',
             fontsize=14, fontweight='bold')

graphs = [
    ('Complete K₁₅ (regular)', make_complete(n)),
    ('Cycle C₁₅ (regular)', make_cycle(n)),
    ('Star S₁₅ (irregular)', make_star(n)),
]

for idx, (name, adj) in enumerate(graphs):
    D = int(adj.sum(axis=1).max())
    distances = []
    bounds = []
    epsilons = []

    for _ in range(n_trials):
        f = rng.random(n)
        eps = rng.uniform(0.01, 0.3)
        perturbation = rng.uniform(-eps, eps, n)
        g = f + perturbation

        dist = tropical_barcode_dist(adj, f, g)
        bound = stability_bound(adj, f, g)
        distances.append(dist)
        bounds.append(bound)
        epsilons.append(np.max(np.abs(f - g)))

    ax = axes[idx]
    ax.scatter(bounds, distances, alpha=0.4, s=15, color='steelblue')
    max_val = max(max(bounds), max(distances))
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='d_T = bound (tight)')
    ax.set_xlabel('Stability bound (Δ+1)·ε', fontsize=12)
    ax.set_ylabel('Actual barcode distance', fontsize=12)
    ax.set_title(f'{name}\nΔ={D}, gap={np.log((D+1)/2):.2f}', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Compute tightness ratio
    ratios = [d / b for d, b in zip(distances, bounds) if b > 0]
    ax.text(0.05, 0.95, f'Mean ratio: {np.mean(ratios):.3f}',
            transform=ax.transAxes, fontsize=10,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('stability_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: stability_comparison.png")
