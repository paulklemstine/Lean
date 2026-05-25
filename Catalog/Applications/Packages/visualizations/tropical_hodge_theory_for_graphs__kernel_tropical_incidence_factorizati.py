#!/usr/bin/env python3
"""
Visualization 3: Tropical Incidence Factorization

Visualizes the tropical incidence factorization L = B⊗Bᵀ (off-diagonal)
by showing the incidence matrix B, its transpose, and the resulting product
compared to the tropical Laplacian, for several small graphs.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict

INF = float('inf')

def trop_add(a, b):
    return min(a, b)

def trop_mul(a, b):
    if a == INF or b == INF:
        return INF
    return a + b

def trop_matmul(A, B):
    n, m, p = len(A), len(B), len(B[0])
    C = [[INF]*p for _ in range(n)]
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i][j] = trop_add(C[i][j], trop_mul(A[i][k], B[k][j]))
    return C

def tropical_laplacian(n, edges):
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    L = [[INF]*n for _ in range(n)]
    for i in range(n):
        L[i][i] = len(adj[i])
        for j in adj[i]:
            L[i][j] = 0
    return L

def tropical_incidence(n, edges):
    m = len(edges)
    B = [[INF]*m for _ in range(n)]
    for idx, (u, v) in enumerate(edges):
        B[u][idx] = 0
        B[v][idx] = 0
    return B

def matrix_to_display(M, replace_inf='∞'):
    return [[replace_inf if v == INF else str(int(v)) for v in row] for row in M]

fig, axes = plt.subplots(2, 4, figsize=(18, 9))
fig.suptitle('Tropical Incidence Factorization: L = B ⊗ Bᵀ (Off-Diagonal)',
             fontsize=15, fontweight='bold')

graphs = [
    ("Path P₄", 4, [(0,1),(1,2),(2,3)]),
    ("Triangle K₃", 3, [(0,1),(1,2),(0,2)]),
]

for row, (name, n, edges) in enumerate(graphs):
    B = tropical_incidence(n, edges)
    m = len(edges)
    Bt = [[B[j][i] for j in range(n)] for i in range(m)]
    BBt = trop_matmul(B, Bt)
    L = tropical_laplacian(n, edges)

    def plot_matrix(ax, M, title, max_val=5):
        arr = np.array([[v if v != INF else np.nan for v in r] for r in M])
        cmap = plt.cm.YlOrRd.copy()
        cmap.set_bad(color='lightgray')
        ax.imshow(arr, cmap=cmap, vmin=0, vmax=max_val, aspect='auto')
        for i in range(len(M)):
            for j in range(len(M[0])):
                val = M[i][j]
                text = '∞' if val == INF else str(int(val))
                ax.text(j, i, text, ha='center', va='center', fontsize=11,
                       color='gray' if val == INF else 'black', fontweight='bold')
        ax.set_title(title, fontsize=11)
        ax.set_xticks(range(len(M[0])))
        ax.set_yticks(range(len(M)))

    plot_matrix(axes[row][0], B, f'{name}\nIncidence B ({n}×{m})')
    plot_matrix(axes[row][1], Bt, f'Transpose Bᵀ ({m}×{n})')
    plot_matrix(axes[row][2], BBt, f'B ⊗ Bᵀ ({n}×{n})')
    plot_matrix(axes[row][3], L, f'Laplacian L ({n}×{n})')

    # Mark off-diagonal agreement
    ax = axes[row][3]
    for i in range(n):
        for j in range(n):
            if i != j and L[i][j] == BBt[i][j]:
                rect = plt.Rectangle((j-0.5, i-0.5), 1, 1, linewidth=2,
                                     edgecolor='green', facecolor='none')
                ax.add_patch(rect)

plt.tight_layout()
plt.savefig('viz_factorization.png', dpi=150, bbox_inches='tight')
print("Saved viz_factorization.png")
