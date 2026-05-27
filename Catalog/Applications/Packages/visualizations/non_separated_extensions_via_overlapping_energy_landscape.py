#!/usr/bin/env python3
"""
Visualization: Energy Landscape of the Laplacian Quadratic Form

Produces a heatmap showing the overlap energy E(x) = x^T L_S x
as a function of two-component vectors x = (a, b) for different
subsets S of a graph. Demonstrates positive semidefiniteness and
how the energy landscape changes from separated to non-separated regimes.
"""

import numpy as np
import matplotlib.pyplot as plt


# ─── Self-contained infrastructure ───

def graph_laplacian(n, edges):
    adj = set()
    for u, v in edges:
        adj.add((u, v))
        adj.add((v, u))
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            if i == j:
                L[i, j] = sum(1 for u in range(n) if (i, u) in adj)
            elif (i, j) in adj:
                L[i, j] = -1
    return L


def restricted_lap(L, S):
    k = len(S)
    return np.array([[L[S[a], S[b]] for b in range(k)] for a in range(k)], dtype=int)


# ─── Setup ───

# Path graph P5: 0—1—2—3—4
edges = [(0, 1), (1, 2), (2, 3), (3, 4)]
L = graph_laplacian(5, edges)

subsets = [
    ([0, 4], "S={0,4} (Separated, far apart)"),
    ([0, 2], "S={0,2} (Separated, medium)"),
    ([0, 1], "S={0,1} (Non-separated, adjacent)"),
    ([1, 2], "S={1,2} (Non-separated, central)"),
]

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Overlap Energy Landscape: x^T L_S x\n'
             '(Path Graph P₅, 2-vertex subsets)', fontsize=14, fontweight='bold')

a_range = np.linspace(-3, 3, 100)
b_range = np.linspace(-3, 3, 100)
A, B = np.meshgrid(a_range, b_range)

for idx, (S, title) in enumerate(subsets):
    ax = axes[idx // 2, idx % 2]
    L_S = restricted_lap(L, S)

    # Compute energy for each (a, b)
    # E = a^2 * L_S[0,0] + 2*a*b*L_S[0,1] + b^2 * L_S[1,1]
    E = A**2 * L_S[0, 0] + 2 * A * B * L_S[0, 1] + B**2 * L_S[1, 1]

    # Plot
    levels = np.linspace(0, 30, 16)
    cs = ax.contourf(A, B, E, levels=levels, cmap='viridis')
    ax.contour(A, B, E, levels=levels, colors='white', linewidths=0.3, alpha=0.5)
    plt.colorbar(cs, ax=ax, label='Energy')

    ax.set_title(title, fontsize=10)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_aspect('equal')

    # Mark the zero-energy line if it exists
    ax.plot(0, 0, 'ro', markersize=5)

    # Add matrix annotation
    ax.text(0.02, 0.98, f'L_S = [{L_S[0,0]}, {L_S[0,1]}; {L_S[1,0]}, {L_S[1,1]}]',
            transform=ax.transAxes, fontsize=8, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.tight_layout()
plt.savefig('energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved energy_landscape.png")
