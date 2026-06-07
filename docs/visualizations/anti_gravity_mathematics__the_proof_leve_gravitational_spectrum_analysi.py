#!/usr/bin/env python3
"""
Visualization: Gravitational Spectrum of Theorem DAGs

Generates plots showing the anti-gravity spectrum, weight distribution,
and anti-gravity set sizes across thresholds.
"""

import random
import math
from collections import defaultdict, deque

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def compute_reachable(adj, v):
    visited = {v}
    queue = deque([v])
    while queue:
        u = queue.popleft()
        for w in adj.get(u, []):
            if w not in visited:
                visited.add(w)
                queue.append(w)
    return visited


def build_random_dag(n, seed=42):
    """Build a random DAG with power-law proof lengths."""
    rng = random.Random(seed)
    adj = defaultdict(list)
    proof_length = {}
    
    for i in range(n):
        proof_length[i] = max(1, int(rng.paretovariate(1.5)))
        if i > 0:
            n_deps = min(i, max(1, int(rng.expovariate(0.2))))
            deps = rng.sample(range(i), min(n_deps, i))
            for d in deps:
                adj[d].append(i)
    
    return dict(adj), proof_length


def compute_anti_gravity_data(adj, proof_length, n):
    vertices = list(range(n))
    weights = {v: len(compute_reachable(adj, v)) for v in vertices}
    ag_indices = {v: weights[v] / proof_length[v] for v in vertices}
    return weights, ag_indices


def plot_gravitational_spectrum():
    """Main visualization: 2x2 panel of anti-gravity analysis."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 11))
    fig.suptitle('Gravitational Spectrum of Theorem Dependency Graphs',
                 fontsize=16, fontweight='bold')
    
    # Generate DAGs of different sizes
    configs = [
        (50, 42, "Small DAG (n=50)"),
        (200, 123, "Medium DAG (n=200)"),
        (500, 7, "Large DAG (n=500)"),
    ]
    
    # Panel 1: Anti-gravity spectrum comparison
    ax1 = axes[0, 0]
    for n, seed, label in configs:
        adj, pl = build_random_dag(n, seed)
        w, agi = compute_anti_gravity_data(adj, pl, n)
        spectrum = sorted(agi.values(), reverse=True)
        ax1.plot(range(len(spectrum)), spectrum, label=label, linewidth=1.5)
    ax1.set_xlabel('Rank')
    ax1.set_ylabel('Anti-Gravity Index (weight / proof_length)')
    ax1.set_title('Gravitational Spectrum')
    ax1.legend(fontsize=9)
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)
    
    # Panel 2: Weight vs Proof Length scatter
    ax2 = axes[0, 1]
    n, seed = 200, 123
    adj, pl = build_random_dag(n, seed)
    w, agi = compute_anti_gravity_data(adj, pl, n)
    
    weights_arr = np.array([w[v] for v in range(n)])
    pl_arr = np.array([pl[v] for v in range(n)])
    agi_arr = np.array([agi[v] for v in range(n)])
    
    scatter = ax2.scatter(pl_arr, weights_arr, c=agi_arr, cmap='RdYlGn',
                          s=20, alpha=0.7, edgecolors='k', linewidths=0.3)
    plt.colorbar(scatter, ax=ax2, label='Anti-Gravity Index')
    
    # Draw τ=1 line
    max_pl = max(pl_arr) + 1
    ax2.plot([0, max_pl], [0, max_pl], 'k--', alpha=0.5, label='τ=1 (weight=length)')
    ax2.plot([0, max_pl], [0, 2*max_pl], 'r--', alpha=0.3, label='τ=2')
    ax2.set_xlabel('Proof Length')
    ax2.set_ylabel('Gravitational Weight')
    ax2.set_title('Weight vs Proof Length (n=200)')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)
    
    # Panel 3: Anti-gravity set size vs threshold
    ax3 = axes[1, 0]
    taus = range(0, 20)
    for n, seed, label in configs:
        adj, pl = build_random_dag(n, seed)
        w, agi = compute_anti_gravity_data(adj, pl, n)
        sizes = []
        for tau in taus:
            ag_count = sum(1 for v in range(n) if w[v] >= tau * pl[v])
            sizes.append(ag_count / n * 100)
        ax3.plot(list(taus), sizes, 'o-', label=label, markersize=4)
    
    ax3.set_xlabel('Threshold τ')
    ax3.set_ylabel('Anti-Gravity Set Size (% of vertices)')
    ax3.set_title('Anti-Gravity Set Monotonicity (Theorem 8)')
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)
    ax3.axhline(y=10, color='red', linestyle=':', alpha=0.5, label='10% prediction')
    
    # Panel 4: Markov bound verification
    ax4 = axes[1, 1]
    n, seed = 200, 123
    adj, pl = build_random_dag(n, seed)
    w, agi = compute_anti_gravity_data(adj, pl, n)
    total_w = sum(w.values())
    
    thresholds = range(1, 50)
    actual_counts = []
    markov_bounds = []
    for thresh in thresholds:
        count = sum(1 for v in range(n) if w[v] >= thresh)
        actual_counts.append(count)
        markov_bounds.append(total_w / thresh if thresh > 0 else n)
    
    ax4.plot(list(thresholds), actual_counts, 'b-', label='Actual |{v: weight≥w}|', linewidth=2)
    ax4.plot(list(thresholds), markov_bounds, 'r--', label='Markov bound (totalWeight/w)', linewidth=1.5)
    ax4.fill_between(list(thresholds), actual_counts, markov_bounds,
                     alpha=0.1, color='red')
    ax4.set_xlabel('Weight Threshold w')
    ax4.set_ylabel('Count')
    ax4.set_title('Markov Bound Verification (Theorem 4)')
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('anti_gravity_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: anti_gravity_spectrum.png")


if __name__ == "__main__":
    plot_gravitational_spectrum()
