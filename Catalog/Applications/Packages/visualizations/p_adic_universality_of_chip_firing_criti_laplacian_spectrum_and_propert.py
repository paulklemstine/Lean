#!/usr/bin/env python3
"""
Visualization: Laplacian Spectrum and Quadratic Form
Shows the spectral properties of graph Laplacians, connecting
graph theory to physics (Dirichlet energy) and spectral theory.
"""

import numpy as np
import matplotlib.pyplot as plt

# ============================================================
# Self-contained utilities
# ============================================================

def graph_laplacian(adj):
    D = np.diag(adj.sum(axis=1).astype(float))
    return D - adj

def make_cycle(n):
    adj = np.zeros((n, n))
    for i in range(n):
        adj[i, (i+1) % n] = adj[(i+1) % n, i] = 1
    return adj

def make_path(n):
    adj = np.zeros((n, n))
    for i in range(n-1):
        adj[i, i+1] = adj[i+1, i] = 1
    return adj

def make_complete(n):
    return np.ones((n, n)) - np.eye(n)

def make_star(n):
    adj = np.zeros((n, n))
    for i in range(1, n):
        adj[0, i] = adj[i, 0] = 1
    return adj

# ============================================================
# Figure
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# --- Panel 1: Eigenvalue spectrum comparison ---
ax = axes[0, 0]
graphs = [
    ("Cycle C₈", make_cycle(8)),
    ("Path P₈", make_path(8)),
    ("Complete K₈", make_complete(8)),
    ("Star S₈", make_star(8)),
]

colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
for idx, (name, adj) in enumerate(graphs):
    L = graph_laplacian(adj)
    evals = np.sort(np.linalg.eigvalsh(L))
    ax.plot(range(len(evals)), evals, 'o-', label=name,
            color=colors[idx], markersize=6, linewidth=1.5)

ax.set_xlabel('Index', fontsize=11)
ax.set_ylabel('Eigenvalue λ', fontsize=11)
ax.set_title('Laplacian Spectrum of Different Graph Families', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='black', linewidth=0.5)

# --- Panel 2: Quadratic form Q(x) as function of perturbation ---
ax2 = axes[0, 1]
C8 = make_cycle(8)
L8 = graph_laplacian(C8)

# Vary perturbation strength around constant vector
ts = np.linspace(0, 2, 100)
perturbation = np.array([1, -1, 0.5, -0.5, 0.3, -0.3, 0.1, -0.1])
Q_vals = []
for t in ts:
    x = np.ones(8) + t * perturbation
    # Q(x) = x^T L x
    Q = x @ L8 @ x
    Q_vals.append(Q)

ax2.plot(ts, Q_vals, 'b-', linewidth=2)
ax2.fill_between(ts, 0, Q_vals, alpha=0.15, color='blue')
ax2.axhline(y=0, color='red', linestyle='--', linewidth=1, label='Q = 0 (constant vectors)')
ax2.set_xlabel('Perturbation strength t', fontsize=11)
ax2.set_ylabel('Q(1 + t·δ) = x^T L x', fontsize=11)
ax2.set_title('Laplacian Quadratic Form (Dirichlet Energy)\nQ ≥ 0 always (proven in Lean)', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Row-sum zero property heatmap ---
ax3 = axes[1, 0]
K5 = make_complete(5)
L5 = graph_laplacian(K5)

im = ax3.imshow(L5, cmap='RdBu_r', vmin=-2, vmax=5)
ax3.set_title('Laplacian Matrix L(K₅)\nRow sums = 0 (proven in Lean)', fontsize=12)
plt.colorbar(im, ax=ax3, shrink=0.8)

# Annotate values
for i in range(5):
    for j in range(5):
        ax3.text(j, i, f'{int(L5[i,j])}', ha='center', va='center',
                fontsize=12, color='white' if abs(L5[i,j]) > 2 else 'black')

ax3.set_xlabel('Column (vertex)', fontsize=11)
ax3.set_ylabel('Row (vertex)', fontsize=11)

# Add row sum annotations
for i in range(5):
    ax3.text(5.5, i, f'Σ={int(L5[i].sum())}', ha='left', va='center',
            fontsize=10, color='green', fontweight='bold')

# --- Panel 4: Betti number under covers ---
ax4 = axes[1, 1]

base_sizes = [3, 4, 5, 6]
n_sheets_range = range(1, 8)

for b1_base in [1, 2, 3]:
    b1_lifts = [n * (b1_base - 1) + 1 for n in n_sheets_range]
    ax4.plot(list(n_sheets_range), b1_lifts, 'o-', label=f'b₁(base) = {b1_base}',
             markersize=6, linewidth=2)

ax4.set_xlabel('Number of sheets n', fontsize=11)
ax4.set_ylabel('b₁(lifted graph)', fontsize=11)
ax4.set_title('Betti Number Under n-Sheeted Covers\nb₁(lift) = n·(b₁(base) - 1) + 1 (proven in Lean)', fontsize=12)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.suptitle('Graph Laplacian Properties: Spectral Theory Meets Tropical Geometry',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_laplacian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_laplacian_spectrum.png")
