#!/usr/bin/env python3
"""
Visualization: Energy Landscape of Chip-Firing Equivalence Classes

Visualizes how the Laplacian quadratic energy varies across divisors
in a chip-firing equivalence class, showing that the q-reduced
representative sits at the unique energy minimum.

For the cycle graph C4 with sink q=0, we enumerate all sink-normalized
divisors reachable by firing vectors with small coefficients, and plot
their energies as a heatmap to reveal the convex energy landscape.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


def make_graph(n, edges):
    adj = np.zeros((n, n), dtype=int)
    for u, v in edges:
        adj[u, v] = 1
        adj[v, u] = 1
    L = np.diag(adj.sum(axis=1).astype(int)) - adj
    return adj, L


def laplacian_energy(D, adj):
    x = D.astype(float)
    total = 0.0
    for i in range(adj.shape[0]):
        for j in range(adj.shape[0]):
            if adj[i, j]:
                total += (x[i] - x[j]) ** 2
    return total


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


# Build cycle graph C5
n = 5
edges = [(i, (i+1) % n) for i in range(n)]
adj, L = make_graph(n, edges)
q = 0

# Start from the zero divisor (which is critical for C5)
D0 = np.array([0, 0, 0, 0, 0], dtype=int)

# Generate equivalence class by applying firing vectors
# f with f[q] = 0, f[v] in {-3,...,3} for v != q
fire_range = range(-3, 4)

# Collect (f1, f2, energy) for 2D projection
# Use f[1] and f[2] as axes (fixing f[3]=f[4]=0 for visualization)
energies = {}
q_reduced_points = []

for f1 in range(-5, 6):
    for f2 in range(-5, 6):
        f = np.array([0, f1, f2, 0, 0], dtype=int)
        D = D0 + L @ f  # D0 + Lf
        E = laplacian_energy(D, adj)
        energies[(f1, f2)] = E
        if dhar_burning(D, adj, q):
            q_reduced_points.append((f1, f2, E))

# Create heatmap
f1_vals = sorted(set(k[0] for k in energies))
f2_vals = sorted(set(k[1] for k in energies))
Z = np.zeros((len(f2_vals), len(f1_vals)))
for i, f2 in enumerate(f2_vals):
    for j, f1 in enumerate(f1_vals):
        Z[i, j] = energies.get((f1, f2), 0)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Energy heatmap
ax1 = axes[0]
im = ax1.imshow(Z, origin='lower', cmap='viridis',
                extent=[min(f1_vals)-0.5, max(f1_vals)+0.5,
                        min(f2_vals)-0.5, max(f2_vals)+0.5],
                aspect='equal')
plt.colorbar(im, ax=ax1, label='Laplacian Energy Q(D)')

# Mark q-reduced points
if q_reduced_points:
    qr_f1 = [p[0] for p in q_reduced_points]
    qr_f2 = [p[1] for p in q_reduced_points]
    ax1.scatter(qr_f1, qr_f2, c='red', s=100, marker='*',
                zorder=5, label='q-reduced', edgecolors='white')

# Mark the origin (zero firing = original divisor)
ax1.scatter([0], [0], c='white', s=150, marker='o', zorder=5,
            edgecolors='black', linewidths=2, label='Original D₀')

ax1.set_xlabel('Firing coefficient f₁', fontsize=12)
ax1.set_ylabel('Firing coefficient f₂', fontsize=12)
ax1.set_title('Energy Landscape of Chip-Firing Class\n(Cycle C₅, sink q=0)', fontsize=13)
ax1.legend(loc='upper right', fontsize=10)

# Right: Energy along a 1D slice
ax2 = axes[1]
f1_slice = list(range(-5, 6))
energies_slice = []
for f1 in f1_slice:
    f = np.array([0, f1, 0, 0, 0], dtype=int)
    D = D0 + L @ f
    E = laplacian_energy(D, adj)
    energies_slice.append(E)

ax2.plot(f1_slice, energies_slice, 'b-o', linewidth=2, markersize=8)
ax2.set_xlabel('Firing coefficient f₁ (single vertex)', fontsize=12)
ax2.set_ylabel('Laplacian Energy Q(D₀ + Lf)', fontsize=12)
ax2.set_title('Energy Along a 1D Firing Direction\n(Convex parabolic profile)', fontsize=13)
ax2.grid(True, alpha=0.3)

# Mark minimum
min_idx = np.argmin(energies_slice)
ax2.scatter([f1_slice[min_idx]], [energies_slice[min_idx]],
            c='red', s=150, marker='*', zorder=5,
            label=f'Minimum at f₁={f1_slice[min_idx]}')
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_energy_landscape.png")
