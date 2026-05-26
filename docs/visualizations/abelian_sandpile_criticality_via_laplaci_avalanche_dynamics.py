#!/usr/bin/env python3
"""
Visualization: Avalanche Dynamics and Self-Organized Criticality

Simulates chip-firing avalanches on the complete graph K6 and
visualizes the avalanche size distribution, showing the characteristic
heavy-tailed behavior of self-organized criticality. Also plots
the energy descent during a single avalanche cascade.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct
from collections import Counter


def make_graph(n, edges):
    adj = np.zeros((n, n), dtype=int)
    for u, v in edges:
        adj[u, v] = 1
        adj[v, u] = 1
    L = np.diag(adj.sum(axis=1).astype(int)) - adj
    return adj, L


def dhar_burning(D, adj, q):
    n = adj.shape[0]
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if v in burned:
                continue
            edges_to_burned = sum(adj[v, w] for w in burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True
    return len(burned) == n


def laplacian_energy(D, adj):
    x = D.astype(float)
    total = 0.0
    for i in range(adj.shape[0]):
        for j in range(adj.shape[0]):
            if adj[i, j]:
                total += (x[i] - x[j]) ** 2
    return total


def enumerate_critical_configs(adj, q):
    n = adj.shape[0]
    degrees = adj.sum(axis=1).astype(int)
    ranges = []
    for v in range(n):
        if v == q:
            ranges.append([0])
        else:
            ranges.append(list(range(max(1, degrees[v]))))
    criticals = []
    for combo in iterproduct(*ranges):
        D = np.array(combo, dtype=int)
        if dhar_burning(D, adj, q):
            criticals.append(D.copy())
    return criticals


# ============================================================
# Setup: Complete graph K5
# ============================================================
n = 5
edges = [(i, j) for i in range(n) for j in range(i+1, n)]
adj, L = make_graph(n, edges)
degrees = adj.sum(axis=1).astype(int)
q = 0

# Find critical configurations
criticals = enumerate_critical_configs(adj, q)
print(f"K{n}: {len(criticals)} critical configurations")

# ============================================================
# Simulate avalanches
# ============================================================
np.random.seed(42)
n_trials = 500
avalanche_sizes = []
avalanche_energies = []  # Store energy trajectories

for trial in range(n_trials):
    c = criticals[np.random.randint(len(criticals))].copy()
    v = np.random.randint(1, n)
    c[v] += 1
    
    # Track energy during avalanche
    energies = [laplacian_energy(c, adj)]
    firings = 0
    for _ in range(10000):
        fired = False
        for w in range(n):
            if w == q:
                continue
            if c[w] >= degrees[w]:
                c -= L[w, :]
                firings += 1
                fired = True
                energies.append(laplacian_energy(c, adj))
        if not fired:
            break
    
    avalanche_sizes.append(firings)
    if trial < 20:  # Store first 20 trajectories
        avalanche_energies.append(energies)

sizes = np.array(avalanche_sizes)

# ============================================================
# Plot
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Avalanche size histogram
ax1 = axes[0]
size_counts = Counter(sizes)
max_size = max(size_counts.keys())
x_vals = list(range(max_size + 1))
y_vals = [size_counts.get(s, 0) for s in x_vals]

ax1.bar(x_vals, y_vals, color='#FF6B6B', edgecolor='white', alpha=0.8)
ax1.set_xlabel('Avalanche Size (# firings)', fontsize=12)
ax1.set_ylabel('Frequency', fontsize=12)
ax1.set_title(f'Avalanche Size Distribution\n(K{n}, {n_trials} trials)', fontsize=13)
ax1.grid(True, alpha=0.3, axis='y')

# Add mean line
ax1.axvline(sizes.mean(), color='black', linestyle='--', linewidth=2,
            label=f'Mean = {sizes.mean():.2f}')
ax1.legend(fontsize=10)

# Plot 2: Energy descent during individual avalanches
ax2 = axes[1]
cmap = plt.cm.viridis(np.linspace(0, 1, min(10, len(avalanche_energies))))
for i, energies in enumerate(avalanche_energies[:10]):
    steps = list(range(len(energies)))
    ax2.plot(steps, energies, '-o', color=cmap[i], markersize=4,
             linewidth=1.5, alpha=0.7)

ax2.set_xlabel('Firing Step', fontsize=12)
ax2.set_ylabel('Laplacian Energy Q(D)', fontsize=12)
ax2.set_title('Energy Descent During Avalanches\n(10 sample trajectories)', fontsize=13)
ax2.grid(True, alpha=0.3)

# Plot 3: Cumulative energy decay
ax3 = axes[2]
# Average normalized energy trajectory
max_len = max(len(e) for e in avalanche_energies[:20])
avg_energy = np.zeros(max_len)
counts = np.zeros(max_len)
for energies in avalanche_energies[:20]:
    if energies[0] > 0:
        normalized = np.array(energies) / energies[0]
        for i, e in enumerate(normalized):
            avg_energy[i] += e
            counts[i] += 1

mask = counts > 0
avg_energy[mask] /= counts[mask]
valid_steps = np.where(mask)[0]

ax3.plot(valid_steps, avg_energy[valid_steps], 'b-o', linewidth=2,
         markersize=6, label='Average normalized energy')
ax3.axhline(0, color='red', linestyle='--', alpha=0.5, label='Ground state')
ax3.set_xlabel('Firing Step', fontsize=12)
ax3.set_ylabel('Normalized Energy E(t)/E(0)', fontsize=12)
ax3.set_title('Average Energy Relaxation\nToward Critical Ground State', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(-0.1, 1.5)

plt.tight_layout()
plt.savefig('viz_avalanche_dynamics.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_avalanche_dynamics.png")
