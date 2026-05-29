"""
Visualization: Tropical Jacobian Structure and Abel-Jacobi Coordinates

Illustrates the S-supported Jacobian quotient structure on metric graphs.
Shows how the canonical kernel quotient captures the tropical Jacobian,
and how the energy pairing encodes effective resistances.

This script is fully self-contained.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def build_graph_laplacian(n, edges):
    """Build metric Laplacian from edge list."""
    L = np.zeros((n, n))
    for i, j, length in edges:
        cond = 1.0 / length
        L[i, i] += cond
        L[j, j] += cond
        L[i, j] -= cond
        L[j, i] -= cond
    return L


def solve_kernel(L, D):
    n = L.shape[0]
    A = L.copy()
    b = D.copy()
    A[-1, :] = 1.0
    b[-1] = 0.0
    return np.linalg.solve(A, b)


def theta_graph_laplacian(l1, l2, l3):
    """Theta graph: vertices 0,1 (poles), 2,3,4 (midpoints)."""
    edges = [
        (0, 2, l1/2), (2, 1, l1/2),
        (0, 3, l2/2), (3, 1, l2/2),
        (0, 4, l3/2), (4, 1, l3/2),
    ]
    return build_graph_laplacian(5, edges), 5


fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.3)

# --- Panel 1: Abel-Jacobi coordinates on theta graph ---
ax1 = fig.add_subplot(gs[0, 0])

L, n = theta_graph_laplacian(1.0, 2.0, 3.0)
S = list(range(n))
s0 = 0

# Compute kernel generators
kernels = []
for idx in range(1, n):
    D = np.zeros(n)
    D[idx] = 1.0
    D[s0] = -1.0
    kernels.append(solve_kernel(L, D))

# Project onto 2D via first two kernel generators
k1 = kernels[0]
k2 = kernels[1]

# Plot the Abel-Jacobi image of each vertex
aj_x = [k[1] for k in kernels]  # Value at vertex 1
aj_y = [k[2] for k in kernels]  # Value at vertex 2

colors_pts = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
for idx in range(len(kernels)):
    ax1.scatter(aj_x[idx], aj_y[idx], c=colors_pts[idx], s=200,
               edgecolors='black', linewidths=1.5, zorder=5,
               label=f'δ_{idx+1} - δ₀')

ax1.scatter(0, 0, c='gray', s=200, marker='x', linewidths=3, zorder=5,
           label='Origin (δ₀ - δ₀)')
ax1.set_xlabel('k₁ coordinate', fontsize=12)
ax1.set_ylabel('k₂ coordinate', fontsize=12)
ax1.set_title('Abel-Jacobi Coordinates\n(Theta Graph, genus 2)', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_aspect('equal')

# --- Panel 2: Energy pairing vs edge lengths ---
ax2 = fig.add_subplot(gs[0, 1])

# Vary one edge length and track energy eigenvalues
l3_values = np.linspace(0.5, 10.0, 50)
eig_traces = [[], []]

for l3 in l3_values:
    L_var, n_var = theta_graph_laplacian(1.0, 2.0, l3)
    S_var = list(range(n_var))
    ks = []
    for idx in range(1, n_var):
        D = np.zeros(n_var)
        D[idx] = 1.0
        D[0] = -1.0
        ks.append(solve_kernel(L_var, D))
    Q = np.zeros((n_var-1, n_var-1))
    for i in range(n_var-1):
        for j in range(n_var-1):
            Q[i,j] = ks[i] @ L_var @ ks[j]
    eigs = sorted(np.linalg.eigvalsh(Q))
    for k_idx in range(2):
        eig_traces[k_idx].append(eigs[k_idx])

ax2.plot(l3_values, eig_traces[0], 'b-', linewidth=2, label='λ₁ (smallest)')
ax2.plot(l3_values, eig_traces[1], 'r-', linewidth=2, label='λ₂')
ax2.set_xlabel('Third path length ℓ₃', fontsize=12)
ax2.set_ylabel('Energy eigenvalue', fontsize=12)
ax2.set_title('Energy Spectrum vs Edge Length\n(Theta Graph)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# --- Panel 3: S-Jacobian rank vs support size ---
ax3 = fig.add_subplot(gs[1, 0])

# Compute Jacobian rank for different support sizes on various graphs
# Graph: complete graph K4 with varying edge lengths
K4_edges = [
    (0, 1, 1.0), (0, 2, 1.5), (0, 3, 2.0),
    (1, 2, 1.2), (1, 3, 1.8), (2, 3, 1.4)
]
L_K4 = build_graph_laplacian(4, K4_edges)

# For each support size, compute rank of energy pairing
support_sizes = []
ranks = []
for size in range(2, 5):
    # Use first 'size' vertices as support
    S = list(range(size))
    ks = []
    for idx in range(1, size):
        D = np.zeros(4)
        D[S[idx]] = 1.0
        D[S[0]] = -1.0
        ks.append(solve_kernel(L_K4, D))
    Q = np.zeros((size-1, size-1))
    for i in range(size-1):
        for j in range(size-1):
            Q[i,j] = ks[i] @ L_K4 @ ks[j]
    rank = np.linalg.matrix_rank(Q, tol=1e-8)
    support_sizes.append(size)
    ranks.append(rank)

# Also compute genus
n_edges_K4 = 6
genus_K4 = n_edges_K4 - 4 + 1
ax3.bar(support_sizes, ranks, color='steelblue', edgecolor='black', alpha=0.8)
ax3.axhline(y=genus_K4, color='red', linestyle='--', linewidth=2,
            label=f'Genus = {genus_K4}')
ax3.set_xlabel('Support size |S|', fontsize=12)
ax3.set_ylabel('Rank of Q (Jacobian dimension)', fontsize=12)
ax3.set_title('S-Jacobian Rank vs Support Size\n(K₄ graph)', fontsize=13)
ax3.legend(fontsize=10)
ax3.set_xticks(support_sizes)

# --- Panel 4: Effective resistance network visualization ---
ax4 = fig.add_subplot(gs[1, 1])

# Compute all pairwise effective resistances on K4
R_eff = np.zeros((4, 4))
for i in range(4):
    for j in range(i+1, 4):
        D = np.zeros(4)
        D[i] = 1.0
        D[j] = -1.0
        f = solve_kernel(L_K4, D)
        R_eff[i,j] = f @ L_K4 @ f
        R_eff[j,i] = R_eff[i,j]

im = ax4.imshow(R_eff, cmap='YlOrRd', aspect='equal')
plt.colorbar(im, ax=ax4, label='Effective resistance (Ω)')
ax4.set_xticks(range(4))
ax4.set_yticks(range(4))
ax4.set_xlabel('Vertex j', fontsize=12)
ax4.set_ylabel('Vertex i', fontsize=12)
ax4.set_title('Effective Resistance Matrix\n(K₄ with heterogeneous edges)', fontsize=13)

for i in range(4):
    for j in range(4):
        ax4.text(j, i, f'{R_eff[i,j]:.2f}', ha='center', va='center',
                fontsize=10, color='black' if R_eff[i,j] < R_eff.max()*0.6 else 'white')

fig.suptitle('Tropical Jacobian Structure and Energy Pairings', fontsize=15, y=0.98)
plt.savefig('viz_jacobian_structure.png', dpi=150, bbox_inches='tight')
print("Saved viz_jacobian_structure.png")
