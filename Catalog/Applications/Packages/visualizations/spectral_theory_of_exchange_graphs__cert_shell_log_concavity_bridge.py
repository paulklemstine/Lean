#!/usr/bin/env python3
"""
Visualization: Log-Concavity of Shell Masses and Ratio Monotonicity

Demonstrates the key bridge theorem: log-concave shell masses yield
non-increasing shell ratios, which provide an expansion proxy.

Panel 1: Shell mass profiles for several exchange graphs
Panel 2: Shell ratios showing non-increasing property
Panel 3: Conductance vs depth decrement scatter plot

CRITICAL: Fully self-contained. No local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iprod


def build_hypercube(d):
    """Build hypercube Q_d: states, adjacency, potential (Hamming weight)."""
    states = list(iprod([0, 1], repeat=d))
    n = len(states)
    potential = np.array([float(sum(s)) for s in states])
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i+1, n):
            if sum(abs(states[i][k] - states[j][k]) for k in range(d)) == 1:
                adj[i, j] = 1
                adj[j, i] = 1
    return states, adj, potential


def compute_shells(potential):
    """Return (values, counts) for potential shells."""
    unique = sorted(set(potential))
    counts = [int(np.sum(np.abs(potential - v) < 1e-10)) for v in unique]
    return unique, counts


def compute_conductance_exact(adj, n):
    """Exact Cheeger constant for small graphs."""
    degrees = adj.sum(axis=1)
    total_vol = degrees.sum()
    best_h = float('inf')
    for mask in range(1, min(2**n, 2**16)):
        S = [i for i in range(n) if mask & (1 << i)]
        vol_S = sum(degrees[i] for i in S)
        if vol_S <= 0 or vol_S > total_vol / 2:
            continue
        Sc = [i for i in range(n) if not (mask & (1 << i))]
        boundary = sum(adj[i, j] for i in S for j in Sc)
        h = boundary / vol_S
        best_h = min(best_h, h)
    return best_h if best_h < float('inf') else 0


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Shell mass profiles
ax = axes[0]
dims = [3, 4, 5, 6]
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
all_data = {}

for d, col in zip(dims, colors):
    states, adj, pot = build_hypercube(d)
    vals, counts = compute_shells(pot)
    ax.plot(vals, counts, 'o-', color=col, label=f'Q_{d}', linewidth=2, markersize=7)
    all_data[d] = (states, adj, pot, vals, counts)

ax.set_xlabel('Shell level (Hamming weight)', fontsize=12)
ax.set_ylabel('Shell mass (# states)', fontsize=12)
ax.set_title('Shell Mass Profiles (Hypercubes)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Shell ratios
ax = axes[1]
for d, col in zip(dims, colors):
    _, _, _, vals, counts = all_data[d]
    ratios = [counts[i+1]/counts[i] for i in range(len(counts)-1)]
    ax.plot(range(len(ratios)), ratios, 's-', color=col, label=f'Q_{d}', linewidth=2, markersize=6)

ax.set_xlabel('Shell index n', fontsize=12)
ax.set_ylabel('Ratio a(n+1)/a(n)', fontsize=12)
ax.set_title('Shell Ratios (Non-Increasing ⟹ Log-Concave)', fontsize=13, fontweight='bold')
ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='ratio = 1')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: δ vs conductance
ax = axes[2]
deltas_list = []
conds_list = []
labels = []

for d in [3, 4, 5]:
    states, adj, pot = build_hypercube(d)
    n = len(states)
    min_pot = pot.min()
    delta_val = float('inf')
    for i in range(n):
        if pot[i] <= min_pot + 1e-10:
            continue
        best = 0
        for j in range(n):
            if adj[i, j] > 0:
                best = max(best, pot[i] - pot[j])
        if best > 0:
            delta_val = min(delta_val, best)
    if delta_val == float('inf'):
        delta_val = 0

    D = adj.sum(axis=1).max()
    h = compute_conductance_exact(adj, n) if n <= 16 else 0

    deltas_list.append(delta_val / D if D > 0 else 0)
    conds_list.append(h)
    labels.append(f'Q_{d}')

ax.scatter(deltas_list, conds_list, c=colors[:len(deltas_list)], s=120, zorder=5, edgecolors='black')
for i, label in enumerate(labels):
    ax.annotate(label, (deltas_list[i], conds_list[i]),
                textcoords="offset points", xytext=(10, 5), fontsize=11)

# Reference line
if deltas_list:
    x_line = np.linspace(0, max(deltas_list)*1.2, 50)
    ax.plot(x_line, x_line, '--', color='gray', alpha=0.5, label='h = δ/D')
ax.set_xlabel('δ/D (depth-degree ratio)', fontsize=12)
ax.set_ylabel('Conductance h', fontsize=12)
ax.set_title('Conductance vs Depth-Degree Ratio', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Log-Concavity Bridge: Shells → Ratios → Expansion',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shell_logconcavity.png', dpi=150, bbox_inches='tight')
print("Saved shell_logconcavity.png")
