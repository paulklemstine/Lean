#!/usr/bin/env python3
"""
Visualization 2: Spanning Tree Counts and Component Group Orders

Shows the relationship between graph structure and the matrix-tree theorem:
det(L_red) = number of spanning trees = |Φ_J|.

Plots spanning tree counts for families of graphs (complete graphs, cycles,
banana graphs) and their component group structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def graph_laplacian_complete(n):
    """Laplacian of K_n."""
    L = np.full((n, n), -1, dtype=int)
    np.fill_diagonal(L, n - 1)
    return L

def graph_laplacian_cycle(n):
    """Laplacian of C_n."""
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        L[i][i] = 2
        L[i][(i+1) % n] = -1
        L[(i+1) % n][i] = -1
    return L

def spanning_tree_count(L):
    """Compute |det(L_red)|."""
    L_red = L[1:, 1:]
    return abs(int(round(np.linalg.det(L_red))))

def smith_factors(L):
    """Compute nontrivial SNF factors of reduced Laplacian."""
    L_red = L[1:, 1:].copy()
    M = L_red.astype(int)
    m, n = M.shape
    r = min(m, n)
    for k in range(r):
        found = False
        for i in range(k, m):
            for j in range(k, n):
                if M[i][j] != 0:
                    M[[k,i]] = M[[i,k]]
                    M[:,[k,j]] = M[:,[j,k]]
                    found = True; break
            if found: break
        if not found: break
        if M[k][k] < 0: M[k] = -M[k]
        changed = True
        while changed:
            changed = False
            for i in range(k+1, m):
                if M[i][k] != 0:
                    q = M[i][k] // M[k][k]
                    M[i] -= q * M[k]
                    if M[i][k] != 0 and abs(M[i][k]) < abs(M[k][k]):
                        M[[k,i]] = M[[i,k]]
                        if M[k][k] < 0: M[k] = -M[k]
                        changed = True
            for j in range(k+1, n):
                if M[k][j] != 0:
                    q = M[k][j] // M[k][k]
                    M[:,j] -= q * M[:,k]
                    if M[k][j] != 0 and abs(M[k][j]) < abs(M[k][k]):
                        M[:,[k,j]] = M[:,[j,k]]
                        if M[k][k] < 0: M[k] = -M[k]
                        changed = True
            for i in range(k+1, m):
                for j2 in range(k+1, n):
                    if M[k][k] != 0 and M[i][j2] % M[k][k] != 0:
                        M[i] += M[k]; changed = True; break
                if changed: break
    return [abs(M[i][i]) for i in range(r) if M[i][i] != 0 and abs(M[i][i]) > 1]


fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Matrix-Tree Theorem: det(L_red) = Spanning Trees = |Φ_J|',
             fontsize=14, fontweight='bold')

# Panel 1: Complete graphs K_n
ns_complete = list(range(2, 10))
trees_complete = []
for n in ns_complete:
    L = graph_laplacian_complete(n)
    trees_complete.append(spanning_tree_count(L))

ax1 = axes[0]
ax1.semilogy(ns_complete, trees_complete, 'bo-', markersize=8, linewidth=2)
ax1.set_xlabel('n (vertices)', fontsize=12)
ax1.set_ylabel('Spanning trees = |Φ_J|', fontsize=12)
ax1.set_title('Complete Graphs Kₙ\nτ(Kₙ) = n^(n-2)', fontsize=11)
ax1.grid(True, alpha=0.3)
for i, (n, t) in enumerate(zip(ns_complete, trees_complete)):
    if n <= 6:
        ax1.annotate(f'{t}', (n, t), textcoords="offset points",
                    xytext=(0, 10), ha='center', fontsize=9)

# Panel 2: Cycle graphs C_n
ns_cycle = list(range(3, 15))
trees_cycle = [spanning_tree_count(graph_laplacian_cycle(n)) for n in ns_cycle]

ax2 = axes[1]
ax2.plot(ns_cycle, trees_cycle, 'rs-', markersize=8, linewidth=2)
ax2.set_xlabel('n (vertices)', fontsize=12)
ax2.set_ylabel('Spanning trees = |Φ_J|', fontsize=12)
ax2.set_title('Cycle Graphs Cₙ\nτ(Cₙ) = n, Φ_J ≅ ℤ/nℤ', fontsize=11)
ax2.grid(True, alpha=0.3)

# Panel 3: Component group structure table
ax3 = axes[2]
ax3.axis('off')
table_data = []
headers = ['Graph', '|Φ_J|', 'Φ_J']

examples = [
    ('K₃', graph_laplacian_complete(3)),
    ('K₄', graph_laplacian_complete(4)),
    ('K₅', graph_laplacian_complete(5)),
    ('C₃', graph_laplacian_cycle(3)),
    ('C₄', graph_laplacian_cycle(4)),
    ('C₅', graph_laplacian_cycle(5)),
    ('C₆', graph_laplacian_cycle(6)),
]

for name, L in examples:
    order = spanning_tree_count(L)
    factors = smith_factors(L)
    grp = ' × '.join(f'ℤ/{d}ℤ' for d in factors) if factors else '0'
    table_data.append([name, str(order), grp])

table = ax3.table(cellText=table_data, colLabels=headers,
                  loc='center', cellLoc='center',
                  colWidths=[0.2, 0.2, 0.6])
table.auto_set_font_size(False)
table.set_fontsize(11)
table.scale(1.0, 1.5)
for key, cell in table.get_celld().items():
    if key[0] == 0:
        cell.set_facecolor('#4472C4')
        cell.set_text_props(color='white', fontweight='bold')
ax3.set_title('Component Group Structure\n(via Smith Normal Form)', fontsize=11)

plt.tight_layout()
plt.savefig('visualize_spanning_trees.png', dpi=150, bbox_inches='tight')
print("Saved: visualize_spanning_trees.png")
