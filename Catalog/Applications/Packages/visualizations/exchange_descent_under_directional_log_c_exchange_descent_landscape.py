#!/usr/bin/env python3
"""
Visualization 1: Exchange Descent Landscape

Visualizes the objective function landscape over an exchange family (uniform
matroid bases), showing the descent trajectory and local-to-global structure.
Each basis is a node, connected by exchange moves. Node color represents
objective value; the descent path is highlighted.

Self-contained — all functions defined inline.
"""

import itertools
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import LineCollection


def make_uniform_matroid_bases(n, r):
    bases = []
    for subset in itertools.combinations(range(n), r):
        v = tuple(1 if i in subset else 0 for i in range(n))
        bases.append(v)
    return bases


def are_exchange_neighbors(x, y, n):
    """Check if y = x + e_i - e_j for some i, j."""
    diff = tuple(y[k] - x[k] for k in range(n))
    plus_one = sum(1 for d in diff if d == 1)
    minus_one = sum(1 for d in diff if d == -1)
    zero = sum(1 for d in diff if d == 0)
    return plus_one == 1 and minus_one == 1 and zero == n - 2


def exchange_descent_trace(bases_set, bases_list, n, f, x0):
    x = x0
    path = [x]
    while True:
        best = None
        best_val = f(np.array(x))
        for i in range(n):
            for j in range(n):
                if i == j:
                    continue
                y = list(x)
                y[i] += 1
                y[j] -= 1
                y = tuple(y)
                if y in bases_set:
                    val = f(np.array(y))
                    if val < best_val - 1e-15:
                        best_val = val
                        best = y
        if best is None:
            break
        x = best
        path.append(x)
    return path


# Parameters
n, r = 5, 2
bases = make_uniform_matroid_bases(n, r)
bases_set = set(bases)
num_bases = len(bases)

# Objective: weighted linear
weights = np.array([4.0, 2.0, 0.0, -2.0, -4.0])
f = lambda x: float(np.dot(weights, x))

# Compute layout using spring embedding
# Build adjacency
adj = np.zeros((num_bases, num_bases))
for i in range(num_bases):
    for j in range(i + 1, num_bases):
        if are_exchange_neighbors(bases[i], bases[j], n):
            adj[i, j] = 1
            adj[j, i] = 1

# Simple force-directed layout
np.random.seed(42)
pos = np.random.randn(num_bases, 2) * 2

for _ in range(300):
    forces = np.zeros_like(pos)
    for i in range(num_bases):
        for j in range(num_bases):
            if i == j:
                continue
            diff = pos[i] - pos[j]
            dist = max(np.linalg.norm(diff), 0.01)
            # Repulsion
            forces[i] += diff / dist**2 * 0.5
            # Attraction for edges
            if adj[i, j]:
                forces[i] -= diff * 0.1
    pos += forces * 0.05
    # Center
    pos -= pos.mean(axis=0)

# Compute f values
f_vals = np.array([f(np.array(b)) for b in bases])

# Descent from worst starting point
worst_idx = np.argmax(f_vals)
path = exchange_descent_trace(bases_set, bases, n, f, bases[worst_idx])

# Plot
fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# Draw edges
edge_lines = []
for i in range(num_bases):
    for j in range(i + 1, num_bases):
        if adj[i, j]:
            edge_lines.append([pos[i], pos[j]])

lc = LineCollection(edge_lines, colors='lightgray', linewidths=0.8, zorder=1)
ax.add_collection(lc)

# Draw descent path
path_indices = [bases.index(p) for p in path]
for k in range(len(path_indices) - 1):
    i, j = path_indices[k], path_indices[k + 1]
    ax.annotate('', xy=pos[j], xytext=pos[i],
                arrowprops=dict(arrowstyle='->', color='red', lw=2.5))

# Draw nodes
scatter = ax.scatter(pos[:, 0], pos[:, 1], c=f_vals, cmap='RdYlGn_r',
                     s=200, zorder=3, edgecolors='black', linewidths=1.0)

# Highlight start and end
ax.scatter(*pos[path_indices[0]], s=400, facecolors='none', edgecolors='red',
           linewidths=3, zorder=4, label='Start')
ax.scatter(*pos[path_indices[-1]], s=400, facecolors='none', edgecolors='blue',
           linewidths=3, zorder=4, label='Global minimum')

# Labels
for i, b in enumerate(bases):
    selected = [k for k in range(n) if b[k] == 1]
    label = '{' + ','.join(map(str, selected)) + '}'
    ax.annotate(label, pos[i], textcoords="offset points",
                xytext=(0, 12), ha='center', fontsize=7, fontweight='bold')

plt.colorbar(scatter, ax=ax, label='Objective value f(x)')
ax.set_title(f'Exchange Descent on U({r},{n}) — {len(path)-1} steps to global optimum',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.set_xlabel('Layout x')
ax.set_ylabel('Layout y')
ax.set_aspect('equal')
plt.tight_layout()
plt.savefig('viz_descent_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_descent_landscape.png")
