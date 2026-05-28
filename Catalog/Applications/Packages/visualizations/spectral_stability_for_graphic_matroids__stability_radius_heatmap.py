#!/usr/bin/env python3
"""
Visualization 3: Stability Radius Heatmap

Creates a heatmap showing the certified stability radius for different
graph families (K_n, C_n, P_n) across different sizes n. Illustrates
how algebraic connectivity controls robustness.
"""

import numpy as np
import matplotlib.pyplot as plt


def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj

def algebraic_connectivity(L):
    evals = np.linalg.eigvalsh(L)
    evals.sort()
    return float(evals[1]) if len(evals) > 1 else 0.0

def edge_count(adj):
    return int(adj.sum() / 2)

def complete_graph(n):
    return np.ones((n, n)) - np.eye(n)

def cycle_graph(n):
    A = np.zeros((n, n))
    for i in range(n):
        A[i,(i+1)%n] = 1
        A[(i+1)%n,i] = 1
    return A

def path_graph(n):
    A = np.zeros((n, n))
    for i in range(n-1):
        A[i,i+1] = 1
        A[i+1,i] = 1
    return A

def complete_bipartite(p, q):
    n = p + q
    A = np.zeros((n, n))
    for i in range(p):
        for j in range(p, n):
            A[i, j] = 1
            A[j, i] = 1
    return A


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap data
ns = range(3, 11)
families = ['K_n', 'C_n', 'P_n', 'K_{2,n-2}']
constructors = [complete_graph, cycle_graph, path_graph, lambda n: complete_bipartite(2, n-2)]

data_lam2 = np.zeros((len(families), len(list(ns))))
data_rho = np.zeros((len(families), len(list(ns))))

for i, (name, constructor) in enumerate(zip(families, constructors)):
    for j, n in enumerate(ns):
        adj = constructor(n)
        L = graph_laplacian(adj)
        lam2 = algebraic_connectivity(L)
        m = edge_count(adj)
        data_lam2[i, j] = lam2
        data_rho[i, j] = lam2 / (2 * m) if m > 0 else 0

# Plot 1: Algebraic connectivity heatmap
ax1 = axes[0]
im1 = ax1.imshow(data_lam2, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax1.set_xticks(range(len(list(ns))))
ax1.set_xticklabels([str(n) for n in ns])
ax1.set_yticks(range(len(families)))
ax1.set_yticklabels(families)
ax1.set_xlabel('n (vertices)', fontsize=12)
ax1.set_title('Algebraic Connectivity λ₂(L_G)', fontsize=13, fontweight='bold')
plt.colorbar(im1, ax=ax1, shrink=0.8)

# Annotate cells
for i in range(len(families)):
    for j in range(len(list(ns))):
        val = data_lam2[i, j]
        color = 'white' if val > data_lam2.max() * 0.6 else 'black'
        ax1.text(j, i, f'{val:.2f}', ha='center', va='center', fontsize=8, color=color)

# Plot 2: Certified stability radius heatmap
ax2 = axes[1]
# Use log scale for better visibility
data_rho_log = np.log10(data_rho + 1e-10)
im2 = ax2.imshow(data_rho, aspect='auto', cmap='viridis', interpolation='nearest')
ax2.set_xticks(range(len(list(ns))))
ax2.set_xticklabels([str(n) for n in ns])
ax2.set_yticks(range(len(families)))
ax2.set_yticklabels(families)
ax2.set_xlabel('n (vertices)', fontsize=12)
ax2.set_title('Certified Stability Radius ρ = λ₂/(2|E|)', fontsize=13, fontweight='bold')
plt.colorbar(im2, ax=ax2, shrink=0.8)

# Annotate cells
for i in range(len(families)):
    for j in range(len(list(ns))):
        val = data_rho[i, j]
        color = 'white' if val < data_rho.max() * 0.4 else 'black'
        ax2.text(j, i, f'{val:.4f}', ha='center', va='center', fontsize=7, color=color)

plt.suptitle('Spectral Stability Across Graph Families\nHigher values = more robust Lorentzian structure',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('stability_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: stability_heatmap.png")
