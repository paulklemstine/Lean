#!/usr/bin/env python3
"""
Visualization 1: Tropical Exchange Descent Landscape

Visualizes the potential landscape of a tropical exchange family on the uniform
matroid U(3, 6). Each basis (3-element subset) is a node, and exchange neighbors
are connected by edges. The color represents the potential value, and the descent
path is highlighted in red.

This illustrates:
- The structure of the exchange graph (nodes = bases, edges = single exchanges)
- The potential landscape (color = Φ value)
- How greedy descent navigates from high to low potential
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
import random

# Generate the uniform matroid U(3, 6)
n, r = 6, 3
ground = list(range(n))
bases = [frozenset(c) for c in combinations(ground, r)]
basis_index = {B: i for i, B in enumerate(bases)}

# Lorentzian-inspired valuation
val = {B: sum(i * i for i in B) for B in bases}
phi = {B: -val[B] for B in bases}  # Potential to minimize

# Build exchange graph
edges = []
for i, B1 in enumerate(bases):
    for j, B2 in enumerate(bases):
        if j <= i:
            continue
        # Check if B1 and B2 differ by exactly one element
        diff1 = B1 - B2
        diff2 = B2 - B1
        if len(diff1) == 1 and len(diff2) == 1:
            edges.append((i, j))

# Layout: use spectral-like embedding based on basis elements
positions = {}
for i, B in enumerate(bases):
    elems = sorted(B)
    # Use barycentric coordinates based on element values
    angle = sum(e * 2 * np.pi / n for e in elems) / r
    radius = 1 + 0.3 * sum(elems) / r
    positions[i] = (radius * np.cos(angle), radius * np.sin(angle))

# Add jitter to avoid overlaps
random.seed(42)
for i in positions:
    x, y = positions[i]
    positions[i] = (x + random.uniform(-0.15, 0.15),
                    y + random.uniform(-0.15, 0.15))

# Run greedy descent
def greedy_descent(start_idx):
    path = [start_idx]
    current = start_idx
    for _ in range(100):
        B = bases[current]
        best_next = None
        best_phi = phi[B]
        for x in B:
            for y in ground:
                if y not in B:
                    Bn = (B - {x}) | {y}
                    if Bn in basis_index:
                        if phi[Bn] < best_phi:
                            best_phi = phi[Bn]
                            best_next = basis_index[Bn]
        if best_next is None:
            break
        path.append(best_next)
        current = best_next
    return path

# Find worst starting point for longest descent
worst_start = max(range(len(bases)), key=lambda i: phi[bases[i]])
descent_path = greedy_descent(worst_start)

# Plotting
fig, ax = plt.subplots(1, 1, figsize=(12, 10))

# Draw exchange edges (light gray)
for i, j in edges:
    x1, y1 = positions[i]
    x2, y2 = positions[j]
    ax.plot([x1, x2], [y1, y2], '-', color='#e0e0e0', linewidth=0.5, zorder=1)

# Color nodes by potential
phi_values = [phi[bases[i]] for i in range(len(bases))]
phi_min, phi_max = min(phi_values), max(phi_values)

# Draw nodes
for i, B in enumerate(bases):
    x, y = positions[i]
    # Normalize color
    norm_phi = (phi[B] - phi_min) / (phi_max - phi_min) if phi_max > phi_min else 0.5
    color = plt.cm.RdYlGn(1 - norm_phi)  # Green = low potential (good), Red = high
    size = 200
    ax.scatter(x, y, c=[color], s=size, zorder=3, edgecolors='gray', linewidth=0.5)

    # Label with basis elements
    label = '{' + ','.join(str(e) for e in sorted(B)) + '}'
    ax.annotate(label, (x, y), textcoords="offset points",
                xytext=(0, 12), ha='center', fontsize=6, color='#333333')

# Draw descent path (red arrows)
for k in range(len(descent_path) - 1):
    i, j = descent_path[k], descent_path[k + 1]
    x1, y1 = positions[i]
    x2, y2 = positions[j]
    dx, dy = x2 - x1, y2 - y1
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color='red', lw=2.5),
                zorder=5)

# Highlight start and end
x0, y0 = positions[descent_path[0]]
xf, yf = positions[descent_path[-1]]
ax.scatter(x0, y0, c='red', s=400, zorder=6, marker='*', edgecolors='darkred',
           linewidth=1.5, label=f'Start (Φ={phi[bases[descent_path[0]]]})')
ax.scatter(xf, yf, c='lime', s=400, zorder=6, marker='*', edgecolors='darkgreen',
           linewidth=1.5, label=f'Optimal (Φ={phi[bases[descent_path[-1]]]})')

ax.set_title('Tropical Exchange Descent on U(3,6)\n'
             'Nodes = bases, edges = single exchanges, color = potential Φ\n'
             f'Red path: greedy descent ({len(descent_path)-1} steps)',
             fontsize=14, fontweight='bold')
ax.legend(loc='upper right', fontsize=10)
ax.set_aspect('equal')
ax.axis('off')

plt.tight_layout()
plt.savefig('viz_descent_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_descent_landscape.png")
