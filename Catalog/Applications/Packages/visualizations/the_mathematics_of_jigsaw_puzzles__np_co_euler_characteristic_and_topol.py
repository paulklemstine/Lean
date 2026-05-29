#!/usr/bin/env python3
"""
Visualization: Euler Characteristic and Topological Invariants
==============================================================

Visualizes the cell complex structure of jigsaw puzzles and demonstrates
that the Euler characteristic χ = V - E + F = 1 for all rectangular
puzzle assemblies.

This is a topological invariant: no matter the puzzle size, the completed
assembly always forms a contractible disk with χ = 1. We prove this
algebraically in Lean: (m+1)(n+1) - m(n+1) - (m+1)n + mn = 1.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# ─── Panel 1: Cell complex visualization for a 3×3 puzzle ───

ax1 = axes[0]
m, n = 3, 3

# Draw faces (pieces) as colored squares
colors = plt.cm.Set3(np.linspace(0, 1, m * n))
for i in range(m):
    for j in range(n):
        rect = plt.Rectangle((j, m - 1 - i), 1, 1,
                             facecolor=colors[i * n + j],
                             edgecolor='none', alpha=0.5)
        ax1.add_patch(rect)

# Draw edges
for i in range(m + 1):
    for j in range(n):
        # Horizontal edges
        color = 'red' if 0 < i < m else 'gray'
        lw = 2 if 0 < i < m else 1
        ax1.plot([j, j + 1], [i, i], color=color, linewidth=lw)
for i in range(m):
    for j in range(n + 1):
        # Vertical edges
        color = 'blue' if 0 < j < n else 'gray'
        lw = 2 if 0 < j < n else 1
        ax1.plot([j, j], [i, i + 1], color=color, linewidth=lw)

# Draw vertices
for i in range(m + 1):
    for j in range(n + 1):
        ax1.plot(j, i, 'ko', markersize=6)

V = (m + 1) * (n + 1)
E = m * (n + 1) + (m + 1) * n
F = m * n
chi = V - E + F

ax1.set_xlim(-0.3, n + 0.3)
ax1.set_ylim(-0.3, m + 0.3)
ax1.set_aspect('equal')
ax1.set_title(f'{m}×{n} Puzzle Cell Complex\nV={V}, E={E}, F={F}, χ={chi}',
              fontsize=12)

# Legend
red_line = mpatches.Patch(color='red', label=f'Internal h-edges: {m*(n-1) if n > 1 else 0}')
blue_line = mpatches.Patch(color='blue', label=f'Internal v-edges: {(m-1)*n if m > 1 else 0}')
ax1.legend(handles=[red_line, blue_line], loc='upper right', fontsize=8)

# ─── Panel 2: Euler characteristic for various sizes ───

ax2 = axes[1]
sizes = range(1, 21)
V_vals = [(s + 1) ** 2 for s in sizes]
E_vals = [2 * s * (s + 1) for s in sizes]
F_vals = [s ** 2 for s in sizes]
chi_vals = [V_vals[i] - E_vals[i] + F_vals[i] for i in range(len(sizes))]

ax2.plot(list(sizes), V_vals, 'g^-', label='V = (n+1)²', markersize=4)
ax2.plot(list(sizes), E_vals, 'bs-', label='E = 2n(n+1)', markersize=4)
ax2.plot(list(sizes), F_vals, 'ro-', label='F = n²', markersize=4)
ax2.set_xlabel('Grid size n (for n×n puzzle)', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Cell Complex Components\n(V, E, F grow quadratically)', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Inset: χ is always 1
inset = ax2.inset_axes([0.55, 0.15, 0.4, 0.3])
inset.plot(list(sizes), chi_vals, 'k*-', markersize=8)
inset.set_ylim(0, 2)
inset.set_title('χ = V - E + F', fontsize=9)
inset.set_ylabel('χ', fontsize=9)
inset.axhline(y=1, color='red', linestyle='--', alpha=0.5)
inset.grid(True, alpha=0.3)

# ─── Panel 3: Boundary vs Interior piece count ───

ax3 = axes[2]
sizes2 = range(2, 31)
boundary_counts = [2 * s + 2 * s - 4 for s in sizes2]
interior_counts = [(s - 2) ** 2 for s in sizes2]
total_counts = [s ** 2 for s in sizes2]

ax3.fill_between(list(sizes2), 0, interior_counts, alpha=0.4, color='coral',
                 label='Interior pieces')
ax3.fill_between(list(sizes2), interior_counts, total_counts, alpha=0.4, color='skyblue',
                 label='Boundary pieces')
ax3.plot(list(sizes2), total_counts, 'k-', linewidth=2, label='Total = n²')
ax3.set_xlabel('Grid size n', fontsize=12)
ax3.set_ylabel('Number of pieces', fontsize=12)
ax3.set_title('Boundary vs Interior Pieces\n(Interior dominates for large n)', fontsize=12)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Verify the identity: boundary + interior = total
for s in sizes2:
    boundary = 2 * s + 2 * s - 4
    interior = (s - 2) ** 2
    assert boundary + interior == s * s, f"Failed for n={s}"

plt.tight_layout()
plt.savefig('euler_characteristic.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved euler_characteristic.png")
