#!/usr/bin/env python3
"""
Visualization: Overlap Interaction Matrices and Energy Landscapes

Produces a 2x2 figure showing:
1. Top-left: Interaction matrix heatmap for a separated subset
2. Top-right: Interaction matrix heatmap for a non-separated subset
3. Bottom-left: Energy decomposition bar chart
4. Bottom-right: SNF invariant factor comparison

Demonstrates visually that separation = zero interaction,
while non-separated subsets have rich off-diagonal structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# ─── Self-contained graph infrastructure ───

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


def interaction_mat(L_S):
    return L_S - np.diag(np.diag(L_S))


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

# Graph: Complete graph K5
n = 5
edges_K5 = [(i, j) for i in range(5) for j in range(i+1, 5)]
L_K5, adj_K5 = graph_laplacian(n, edges_K5)

# Separated subset: {0, 2} in path graph P5
edges_P5 = [(0, 1), (1, 2), (2, 3), (3, 4)]
L_P5, adj_P5 = graph_laplacian(5, edges_P5)

# Choose subsets
S_sep = [0, 2, 4]  # Separated in P5
S_nonsep = [0, 1, 2]  # Non-separated in P5 (edges 0-1, 1-2)

L_sep = restricted_lap(L_P5, S_sep)
L_nonsep = restricted_lap(L_P5, S_nonsep)
Omega_sep = interaction_mat(L_sep)
Omega_nonsep = interaction_mat(L_nonsep)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Overlap Support Theory: Separated vs Non-Separated Subsets\n'
             '(Path Graph P₅: 0—1—2—3—4)', fontsize=14, fontweight='bold')

# Top-left: Separated interaction matrix
ax1 = axes[0, 0]
im1 = ax1.imshow(Omega_sep, cmap='RdBu_r', vmin=-1, vmax=1, aspect='equal')
ax1.set_title(f'Interaction Ω_S\nS = {{{", ".join(map(str, S_sep))}}} (Separated)', fontsize=11)
ax1.set_xlabel('Vertex index in S')
ax1.set_ylabel('Vertex index in S')
for i in range(len(S_sep)):
    for j in range(len(S_sep)):
        ax1.text(j, i, str(Omega_sep[i, j]), ha='center', va='center', fontsize=14,
                color='black' if abs(Omega_sep[i, j]) < 0.5 else 'white')
plt.colorbar(im1, ax=ax1, shrink=0.8)

# Top-right: Non-separated interaction matrix
ax2 = axes[0, 1]
im2 = ax2.imshow(Omega_nonsep, cmap='RdBu_r', vmin=-1, vmax=1, aspect='equal')
ax2.set_title(f'Interaction Ω_S\nS = {{{", ".join(map(str, S_nonsep))}}} (Non-Separated)', fontsize=11)
ax2.set_xlabel('Vertex index in S')
ax2.set_ylabel('Vertex index in S')
for i in range(len(S_nonsep)):
    for j in range(len(S_nonsep)):
        ax2.text(j, i, str(Omega_nonsep[i, j]), ha='center', va='center', fontsize=14,
                color='black' if abs(Omega_nonsep[i, j]) < 0.5 else 'white')
plt.colorbar(im2, ax=ax2, shrink=0.8)

# Bottom-left: Energy decomposition comparison
ax3 = axes[1, 0]
x_test = np.array([1, -1, 1], dtype=int)
energies = []
for label, L_S in [('Separated', L_sep), ('Non-Sep', L_nonsep)]:
    E = int(x_test @ L_S @ x_test)
    D = np.diag(np.diag(L_S))
    Omega = L_S - D
    E_self = int(x_test @ D @ x_test)
    E_int = int(x_test @ Omega @ x_test)
    energies.append((label, E, E_self, E_int))

x_pos = np.arange(2)
width = 0.25
bars1 = ax3.bar(x_pos - width, [e[2] for e in energies], width, label='Self-energy', color='#2196F3')
bars2 = ax3.bar(x_pos, [e[3] for e in energies], width, label='Interaction', color='#FF5722')
bars3 = ax3.bar(x_pos + width, [e[1] for e in energies], width, label='Total', color='#4CAF50')
ax3.set_xticks(x_pos)
ax3.set_xticklabels([e[0] for e in energies])
ax3.set_ylabel('Energy')
ax3.set_title('Energy Decomposition\n(test vector x = [1, -1, 1])', fontsize=11)
ax3.legend()
ax3.axhline(y=0, color='black', linewidth=0.5)

# Bottom-right: SNF invariant factors
ax4 = axes[1, 1]
factors_sep = snf_factors(L_sep)
factors_nonsep = snf_factors(L_nonsep)

# Pad to same length
max_len = max(len(factors_sep), len(factors_nonsep))
f_sep = factors_sep + [0] * (max_len - len(factors_sep))
f_nonsep = factors_nonsep + [0] * (max_len - len(factors_nonsep))

x_pos2 = np.arange(max_len)
width2 = 0.35
ax4.bar(x_pos2 - width2/2, f_sep, width2, label='Separated', color='#2196F3', alpha=0.8)
ax4.bar(x_pos2 + width2/2, f_nonsep, width2, label='Non-Separated', color='#FF5722', alpha=0.8)
ax4.set_xlabel('Factor index')
ax4.set_ylabel('Invariant factor value')
ax4.set_title('Smith Normal Form\nInvariant Factors', fontsize=11)
ax4.legend()
ax4.set_xticks(x_pos2)

plt.tight_layout()
plt.savefig('overlap_visualization.png', dpi=150, bbox_inches='tight')
print("Saved overlap_visualization.png")
