#!/usr/bin/env python3
"""
Visualization: Cheeger Inequality Verification

Compares the actual spectral gap λ₂ with the Cheeger bound h²/2
and the depth-spectral bound δ²/(2D²) across multiple graph families.

Shows that the Cheeger inequality is tight for some families and
that the depth-spectral bound provides a useful lower bound.

CRITICAL: Fully self-contained. No local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iprod


def build_graph(states, potential_fn, adj_fn):
    """Build adjacency matrix and potential from states."""
    n = len(states)
    adj = np.zeros((n, n))
    pot = np.array([potential_fn(s) for s in states])
    for i in range(n):
        for j in range(i+1, n):
            if adj_fn(states[i], states[j]):
                adj[i, j] = 1
                adj[j, i] = 1
    return adj, pot


def spectral_gap(adj):
    """Compute λ₂ of normalized Laplacian."""
    n = adj.shape[0]
    deg = adj.sum(axis=1)
    D_inv = np.where(deg > 0, 1.0/np.sqrt(deg), 0)
    L = np.diag(deg) - adj
    L_norm = np.diag(D_inv) @ L @ np.diag(D_inv)
    evals = np.sort(np.linalg.eigvalsh(L_norm))
    return float(evals[1]) if len(evals) > 1 else 0


def conductance(adj):
    """Exact Cheeger constant for small graphs."""
    n = adj.shape[0]
    deg = adj.sum(axis=1)
    total = deg.sum()
    best = float('inf')
    for mask in range(1, min(2**n, 2**16)):
        S = [i for i in range(n) if mask & (1 << i)]
        vol = sum(deg[i] for i in S)
        if vol <= 0 or vol > total/2:
            continue
        Sc = [i for i in range(n) if not (mask & (1 << i))]
        bnd = sum(adj[i, j] for i in S for j in Sc)
        best = min(best, bnd/vol)
    return best if best < float('inf') else 0


def depth_decrement(adj, pot):
    """Compute minimum descent decrement."""
    n = adj.shape[0]
    min_p = pot.min()
    delta = float('inf')
    for i in range(n):
        if pot[i] <= min_p + 1e-10:
            continue
        best = 0
        for j in range(n):
            if adj[i, j] > 0:
                best = max(best, pot[i] - pot[j])
        if best > 0:
            delta = min(delta, best)
    return delta if delta < float('inf') else 0


# Build graph families
results = []

# Paths
for n in [4, 5, 6, 7, 8]:
    states = list(range(n))
    adj, pot = build_graph(states, lambda s: float(s), lambda x, y: abs(x-y)==1)
    lam2 = spectral_gap(adj)
    h = conductance(adj)
    d = depth_decrement(adj, pot)
    D = adj.sum(axis=1).max()
    results.append(('Path', n, lam2, h, d, D))

# Cycles
for n in [4, 5, 6, 8, 10]:
    states = list(range(n))
    adj, pot = build_graph(states, lambda s: float(min(s, n-s)),
                           lambda x, y: (x-y)%n==1 or (y-x)%n==1)
    lam2 = spectral_gap(adj)
    h = conductance(adj)
    d = depth_decrement(adj, pot)
    D = adj.sum(axis=1).max()
    results.append(('Cycle', n, lam2, h, d, D))

# Hypercubes
for dim in [2, 3, 4]:
    states = list(iprod([0, 1], repeat=dim))
    adj, pot = build_graph(states, lambda s: float(sum(s)),
                           lambda x, y: sum(abs(x[i]-y[i]) for i in range(dim))==1)
    lam2 = spectral_gap(adj)
    h = conductance(adj)
    d = depth_decrement(adj, pot)
    D = adj.sum(axis=1).max()
    results.append(('Cube', 2**dim, lam2, h, d, D))

# Complete graphs
for n in [3, 4, 5, 6]:
    states = list(range(n))
    adj, pot = build_graph(states, lambda s: float(s),
                           lambda x, y: x != y)
    lam2 = spectral_gap(adj)
    h = conductance(adj)
    d = depth_decrement(adj, pot)
    D = adj.sum(axis=1).max()
    results.append(('Complete', n, lam2, h, d, D))

# Plot
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: λ₂ vs h²/2
ax = axes[0]
lam2s = [r[2] for r in results]
cheeger = [r[3]**2/2 for r in results]
family_colors = {'Path': '#2196F3', 'Cycle': '#FF5722', 'Cube': '#4CAF50', 'Complete': '#9C27B0'}

for family in ['Path', 'Cycle', 'Cube', 'Complete']:
    idx = [i for i, r in enumerate(results) if r[0] == family]
    x = [cheeger[i] for i in idx]
    y = [lam2s[i] for i in idx]
    ax.scatter(x, y, c=family_colors[family], s=80, label=family, edgecolors='black', zorder=5)

maxval = max(max(lam2s), max(cheeger)) * 1.1
ax.plot([0, maxval], [0, maxval], '--', color='gray', alpha=0.5, label='λ₂ = h²/2')
ax.set_xlabel('Cheeger bound h²/2', fontsize=12)
ax.set_ylabel('Spectral gap λ₂', fontsize=12)
ax.set_title('Cheeger Inequality: λ₂ ≥ h²/2', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: λ₂ vs δ²/(2D²)
ax = axes[1]
slbs = [r[4]**2 / (2*r[5]**2) if r[5] > 0 else 0 for r in results]

for family in ['Path', 'Cycle', 'Cube', 'Complete']:
    idx = [i for i, r in enumerate(results) if r[0] == family]
    x = [slbs[i] for i in idx]
    y = [lam2s[i] for i in idx]
    ax.scatter(x, y, c=family_colors[family], s=80, label=family, edgecolors='black', zorder=5)

maxval = max(max(lam2s), max(slbs)) * 1.1
ax.plot([0, maxval], [0, maxval], '--', color='gray', alpha=0.5, label='λ₂ = δ²/(2D²)')
ax.set_xlabel('Depth-spectral bound δ²/(2D²)', fontsize=12)
ax.set_ylabel('Spectral gap λ₂', fontsize=12)
ax.set_title('Depth-Spectral Bound Verification', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Ratio λ₂ / (δ²/(2D²))
ax = axes[2]
ratios = [lam2s[i] / slbs[i] if slbs[i] > 0 else 0 for i in range(len(results))]
names = [f"{r[0]}({r[1]})" for r in results]
bar_colors = [family_colors[r[0]] for r in results]

# Sort by ratio
sorted_idx = sorted(range(len(ratios)), key=lambda i: ratios[i])
ax.barh(range(len(sorted_idx)),
        [ratios[i] for i in sorted_idx],
        color=[bar_colors[i] for i in sorted_idx],
        edgecolor='black', alpha=0.8)
ax.set_yticks(range(len(sorted_idx)))
ax.set_yticklabels([names[i] for i in sorted_idx], fontsize=8)
ax.set_xlabel('λ₂ / (δ²/(2D²))', fontsize=12)
ax.set_title('Tightness of Depth-Spectral Bound', fontsize=13, fontweight='bold')
ax.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='Bound = Exact')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='x')

plt.suptitle('Cheeger Inequality Verification Across Graph Families',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('cheeger_comparison.png', dpi=150, bbox_inches='tight')
print("Saved cheeger_comparison.png")
