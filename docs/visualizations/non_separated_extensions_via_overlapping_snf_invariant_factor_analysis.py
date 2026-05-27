#!/usr/bin/env python3
"""
Visualization: Smith Normal Form Invariant Factors Across All Subsets

For a fixed graph, computes the SNF invariant factors of the restricted
Laplacian for every nonempty subset S, and displays how the algebraic
structure (cokernel type) varies with subset choice and separation status.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


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
    return L, adj


def restricted_lap(L, S):
    k = len(S)
    return np.array([[L[S[a], S[b]] for b in range(k)] for a in range(k)], dtype=int)


def is_separated(adj, S):
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            if (S[i], S[j]) in adj:
                return False
    return True


def snf_factors(M):
    A = M.copy().astype(int)
    n, m = A.shape
    for k in range(min(n, m)):
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if A[i, j] != 0:
                    A[[k, i]] = A[[i, k]]
                    A[:, [k, j]] = A[:, [j, k]]
                    found = True
                    break
            if found:
                break
        if not found:
            break
        changed = True
        while changed:
            changed = False
            if A[k, k] < 0:
                A[k] = -A[k]
            for j in range(k + 1, m):
                if A[k, j] != 0:
                    q = A[k, j] // A[k, k]
                    A[:, j] -= q * A[:, k]
                    if A[k, j] != 0:
                        A[:, [k, j]] = A[:, [j, k]]
                        changed = True
            for i in range(k + 1, n):
                if A[i, k] != 0:
                    q = A[i, k] // A[k, k]
                    A[i] -= q * A[k]
                    if A[i, k] != 0:
                        A[[k, i]] = A[[i, k]]
                        changed = True
    return sorted([abs(int(A[i, i])) for i in range(min(n, m)) if A[i, i] != 0])


# ─── Build the figure ───

# Cycle graph C6
n = 6
edges = [(0,1), (1,2), (2,3), (3,4), (4,5), (5,0)]
L, adj = graph_laplacian(n, edges)

# Collect data for all subsets of size ≥ 2
data_sep = []  # (subset_str, max_factor)
data_nonsep = []

all_subsets = []
for r in range(2, n + 1):
    for S in combinations(range(n), r):
        S = list(S)
        L_S = restricted_lap(L, S)
        factors = snf_factors(L_S)
        sep = is_separated(adj, S)
        max_f = max(factors) if factors else 0
        det = int(np.prod(factors)) if factors else 0
        entry = {
            'S': S,
            'factors': factors,
            'max_factor': max_f,
            'det': det,
            'sep': sep,
            'size': len(S),
        }
        all_subsets.append(entry)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('SNF Structure Across Subsets of Cycle Graph C₆\n'
             '(Blue = Separated, Red = Non-Separated)', fontsize=13, fontweight='bold')

# Plot 1: Max invariant factor vs subset size
ax1 = axes[0]
for entry in all_subsets:
    color = '#2196F3' if entry['sep'] else '#FF5722'
    marker = 'o' if entry['sep'] else 's'
    ax1.scatter(entry['size'] + np.random.uniform(-0.15, 0.15),
               entry['max_factor'],
               c=color, marker=marker, alpha=0.6, s=40)
ax1.set_xlabel('Subset size |S|')
ax1.set_ylabel('Max invariant factor')
ax1.set_title('Largest Invariant Factor')
# Legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2196F3', markersize=8, label='Separated'),
    Line2D([0], [0], marker='s', color='w', markerfacecolor='#FF5722', markersize=8, label='Non-separated'),
]
ax1.legend(handles=legend_elements)

# Plot 2: Determinant (product of factors) vs subset size
ax2 = axes[1]
for entry in all_subsets:
    color = '#2196F3' if entry['sep'] else '#FF5722'
    marker = 'o' if entry['sep'] else 's'
    ax2.scatter(entry['size'] + np.random.uniform(-0.15, 0.15),
               entry['det'],
               c=color, marker=marker, alpha=0.6, s=40)
ax2.set_xlabel('Subset size |S|')
ax2.set_ylabel('det(L_S) = ∏ factors')
ax2.set_title('Determinant of L_S')
ax2.legend(handles=legend_elements)

# Plot 3: Number of distinct invariant factors > 1
ax3 = axes[2]
for entry in all_subsets:
    color = '#2196F3' if entry['sep'] else '#FF5722'
    marker = 'o' if entry['sep'] else 's'
    nontrivial = sum(1 for f in entry['factors'] if f > 1)
    ax3.scatter(entry['size'] + np.random.uniform(-0.15, 0.15),
               nontrivial,
               c=color, marker=marker, alpha=0.6, s=40)
ax3.set_xlabel('Subset size |S|')
ax3.set_ylabel('# nontrivial factors (> 1)')
ax3.set_title('Torsion Rank')
ax3.legend(handles=legend_elements)

plt.tight_layout()
plt.savefig('snf_analysis.png', dpi=150, bbox_inches='tight')
print("Saved snf_analysis.png")
