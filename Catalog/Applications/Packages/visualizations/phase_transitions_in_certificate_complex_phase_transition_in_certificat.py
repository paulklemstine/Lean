"""
Phase Transition Visualization: Certificate Complexity vs Edge Probability

Visualizes the sharp phase transition in certificate complexity for random
graphs G(n,p). The plot shows how the number of spanning trees (a proxy for
certificate complexity) jumps dramatically near the connectivity threshold
p* = ln(n)/n.

This visualization demonstrates the central theorem: below p*, certificates
are polynomial; above p*, they are exponential.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def kirchhoff_count(n, edges):
    """Count spanning trees via Kirchhoff's matrix-tree theorem."""
    if n <= 1:
        return 1
    L = np.zeros((n, n))
    for u, v in edges:
        L[u][u] += 1; L[v][v] += 1; L[u][v] -= 1; L[v][u] -= 1
    minor = L[:n-1, :n-1]
    det = np.linalg.det(minor)
    return max(0, round(det))


def connected_components_count(n, edges):
    """Count connected components."""
    adj = [[] for _ in range(n)]
    for u, v in edges:
        adj[u].append(v); adj[v].append(u)
    visited = [False] * n
    count = 0
    for s in range(n):
        if visited[s]: continue
        count += 1
        stack = [s]
        while stack:
            v = stack.pop()
            if visited[v]: continue
            visited[v] = True
            for u in adj[v]:
                if not visited[u]: stack.append(u)
    return count


def generate_gnp(n, p, seed=None):
    """Generate G(n,p) random graph."""
    if seed is not None:
        random.seed(seed)
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                edges.append((i, j))
    return edges


# Parameters
n_values = [8, 10, 12, 14]
p_values = np.linspace(0.05, 0.95, 25)
num_trials = 40

# Collect data
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Phase Transition in Certificate Complexity\nfor Random Graphs G(n, p)',
             fontsize=16, fontweight='bold')

colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

for idx, n in enumerate(n_values):
    ax = axes[idx // 2][idx % 2]
    threshold = math.log(n) / n

    avg_log_trees = []
    avg_connectivity = []

    for p in p_values:
        log_trees_sum = 0
        conn_sum = 0
        count = 0

        for trial in range(num_trials):
            edges = generate_gnp(n, p, seed=n * 10000 + int(p * 1000) + trial)
            num_trees = kirchhoff_count(n, edges)
            num_comps = connected_components_count(n, edges)

            if num_trees > 0:
                log_trees_sum += math.log2(num_trees)
            count += 1
            conn_sum += (1 if num_comps == 1 else 0)

        avg_log_trees.append(log_trees_sum / max(count, 1))
        avg_connectivity.append(conn_sum / num_trials)

    # Plot log(spanning trees)
    ax.plot(p_values, avg_log_trees, 'o-', color=colors[idx],
            markersize=4, linewidth=1.5, label=f'log₂(trees)')

    # Mark threshold
    ax.axvline(x=threshold, color='red', linestyle='--', linewidth=2,
               alpha=0.7, label=f'p* = ln({n})/{n} ≈ {threshold:.3f}')

    # Shade regions
    ax.axvspan(0, threshold, alpha=0.05, color='blue')
    ax.axvspan(threshold, 1, alpha=0.05, color='red')

    # Add connectivity on secondary axis
    ax2 = ax.twinx()
    ax2.plot(p_values, avg_connectivity, 's-', color='gray',
             markersize=3, linewidth=1, alpha=0.5, label='P(connected)')
    ax2.set_ylim(-0.05, 1.15)
    ax2.set_ylabel('P(connected)', color='gray', fontsize=10)

    ax.set_xlabel('Edge probability p', fontsize=11)
    ax.set_ylabel('log₂(spanning trees)', fontsize=11)
    ax.set_title(f'n = {n}', fontsize=13, fontweight='bold')
    ax.legend(loc='upper left', fontsize=9)
    ax.set_xlim(0, 1)
    ax.grid(True, alpha=0.3)

    # Annotate phases
    ax.text(threshold * 0.3, ax.get_ylim()[1] * 0.85, 'SPARSE\n(poly cert)',
            ha='center', fontsize=9, color='blue', alpha=0.7, fontweight='bold')
    ax.text(min(threshold + (1 - threshold) * 0.5, 0.85), ax.get_ylim()[1] * 0.85,
            'DENSE\n(exp cert)',
            ha='center', fontsize=9, color='red', alpha=0.7, fontweight='bold')

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")
