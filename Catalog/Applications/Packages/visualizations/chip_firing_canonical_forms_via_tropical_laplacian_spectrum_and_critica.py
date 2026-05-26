#!/usr/bin/env python3
"""
Visualization: Laplacian Spectrum and Critical Group Structure

Visualizes the relationship between graph Laplacian eigenvalues,
Smith Normal Form invariant factors, and critical group structure
across a family of graphs.

This illustrates the core mathematical content: the Laplacian's
arithmetic (SNF) and spectral (eigenvalues) decompositions encode
the same structural information, and canonical tropical kernel
generators bridge between them.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1).astype(int)) - adj.astype(int)


def smith_normal_form_diag(M):
    M = np.array(M, dtype=np.int64).copy()
    rows, cols = M.shape
    min_dim = min(rows, cols)
    for k in range(min_dim):
        if np.all(M[k:, k:] == 0):
            break
        for _ in range(2000):
            nonzero = np.argwhere(M[k:, k:] != 0)
            if len(nonzero) == 0:
                break
            abs_vals = [abs(int(M[k+r, k+c])) for r, c in nonzero]
            min_idx = np.argmin(abs_vals)
            r, c = nonzero[min_idx]
            r, c = int(r+k), int(c+k)
            if r != k:
                M[[k, r]] = M[[r, k]]
            if c != k:
                M[:, [k, c]] = M[:, [c, k]]
            if M[k,k] < 0:
                M[k] = -M[k]
            if M[k,k] == 0:
                break
            changed = False
            for i in range(k+1, rows):
                if M[i,k] != 0:
                    q = int(M[i,k]) // int(M[k,k])
                    M[i] -= q * M[k]
                    if M[i,k] != 0:
                        changed = True
            for j in range(k+1, cols):
                if M[k,j] != 0:
                    q = int(M[k,j]) // int(M[k,k])
                    M[:,j] -= q * M[:,k]
                    if M[k,j] != 0:
                        changed = True
            if not changed:
                ok = True
                for i in range(k+1, rows):
                    for j in range(k+1, cols):
                        if M[k,k] != 0 and M[i,j] % M[k,k] != 0:
                            M[i] += M[k]
                            ok = False
                            break
                    if not ok:
                        break
                if ok:
                    break
    return [abs(int(M[k,k])) for k in range(min_dim) if M[k,k] != 0]


def create_cycle(n):
    A = np.zeros((n, n), dtype=int)
    for i in range(n):
        A[i, (i+1) % n] = 1
        A[(i+1) % n, i] = 1
    return A


def create_complete(n):
    return np.ones((n, n), dtype=int) - np.eye(n, dtype=int)


fig = plt.figure(figsize=(16, 12))
fig.suptitle('Laplacian Arithmetic & Tropical Kernel Structure', fontsize=16, fontweight='bold')
gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

# Panel 1: Cycle graph spectra
ax1 = fig.add_subplot(gs[0, 0])
for n in range(3, 8):
    A = create_cycle(n)
    L = graph_laplacian(A)
    eigs = np.sort(np.linalg.eigvalsh(L.astype(float)))
    ax1.plot(range(len(eigs)), eigs, 'o-', label=f'C_{n}', markersize=5)
ax1.set_xlabel('Eigenvalue index')
ax1.set_ylabel('Eigenvalue λ')
ax1.set_title('Laplacian Spectra of Cycles')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Panel 2: Critical group orders
ax2 = fig.add_subplot(gs[0, 1])
ns = list(range(3, 10))
cycle_orders = []
complete_orders = []
for n in ns:
    # Cycle: critical group order = n
    A = create_cycle(n)
    L = graph_laplacian(A)
    S = list(range(1, n))
    L_S = L[np.ix_(S, S)]
    snf = smith_normal_form_diag(L_S)
    order = np.prod([f for f in snf if f > 1]) if any(f > 1 for f in snf) else 1
    cycle_orders.append(order)
    
    # Complete: critical group order = n^(n-2)
    A = create_complete(n)
    L = graph_laplacian(A)
    S = list(range(1, n))
    L_S = L[np.ix_(S, S)]
    snf = smith_normal_form_diag(L_S)
    order = np.prod([f for f in snf if f > 1]) if any(f > 1 for f in snf) else 1
    complete_orders.append(order)

ax2.semilogy(ns, cycle_orders, 'bo-', label='Cycle Cₙ', markersize=6)
ax2.semilogy(ns, complete_orders, 'rs-', label='Complete Kₙ', markersize=6)
ax2.set_xlabel('n (vertices)')
ax2.set_ylabel('Critical group order')
ax2.set_title('Critical Group Orders')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Panel 3: SNF structure comparison
ax3 = fig.add_subplot(gs[0, 2])
graphs = {
    'C₃': create_cycle(3),
    'C₄': create_cycle(4),
    'C₅': create_cycle(5),
    'C₆': create_cycle(6),
    'K₃': create_complete(3),
    'K₄': create_complete(4),
}
graph_names = list(graphs.keys())
max_factors = 4
snf_data = np.zeros((len(graphs), max_factors))
for i, (name, A) in enumerate(graphs.items()):
    L = graph_laplacian(A)
    n = A.shape[0]
    S = list(range(1, n))
    L_S = L[np.ix_(S, S)]
    snf = smith_normal_form_diag(L_S)
    for j, f in enumerate(snf[:max_factors]):
        snf_data[i, j] = f

im = ax3.imshow(snf_data, cmap='YlOrRd', aspect='auto')
ax3.set_xticks(range(max_factors))
ax3.set_xticklabels([f'd_{j+1}' for j in range(max_factors)])
ax3.set_yticks(range(len(graph_names)))
ax3.set_yticklabels(graph_names)
ax3.set_title('SNF Invariant Factors')
plt.colorbar(im, ax=ax3, shrink=0.8)
for i in range(snf_data.shape[0]):
    for j in range(snf_data.shape[1]):
        if snf_data[i, j] > 0:
            ax3.text(j, i, str(int(snf_data[i, j])), ha='center', va='center', fontsize=9)

# Panel 4: Harmonic function on C_5
ax4 = fig.add_subplot(gs[1, 0])
n = 5
A = create_cycle(n)
L = graph_laplacian(A)
eigs, vecs = np.linalg.eigh(L.astype(float))
# Plot the harmonic modes (eigenvectors)
theta = np.linspace(0, 2*np.pi, n, endpoint=False)
x = np.cos(theta)
y = np.sin(theta)

# Draw graph
for i in range(n):
    for j in range(i+1, n):
        if A[i, j] == 1:
            ax4.plot([x[i], x[j]], [y[i], y[j]], 'k-', alpha=0.3)

# Color by second eigenvector (first nontrivial harmonic mode)
colors = vecs[:, 1]
sc = ax4.scatter(x, y, c=colors, cmap='RdBu', s=200, zorder=5, edgecolors='black')
for i in range(n):
    ax4.annotate(f'v{i}', (x[i], y[i]), textcoords="offset points",
                xytext=(0, 12), ha='center', fontsize=9)
ax4.set_title('Harmonic Mode on C₅\n(2nd eigenvector)')
ax4.set_aspect('equal')
ax4.axis('off')
plt.colorbar(sc, ax=ax4, shrink=0.8, label='f(v)')

# Panel 5: Leaf rigidity propagation
ax5 = fig.add_subplot(gs[1, 1])
# Path graph with harmonic function
n = 6
x_pos = np.arange(n)
y_pos = np.zeros(n)
# Harmonic function on path = constant (forced by leaf rigidity)
f_vals = np.ones(n) * 0.5  # constant

for i in range(n-1):
    ax5.plot([x_pos[i], x_pos[i+1]], [0, 0], 'k-', linewidth=2)

ax5.scatter(x_pos, y_pos, c=f_vals, cmap='coolwarm', s=200, 
           zorder=5, edgecolors='black', vmin=0, vmax=1)

# Annotations showing propagation
for i in range(n):
    ax5.annotate(f'f={f_vals[i]:.1f}', (x_pos[i], 0), 
                textcoords="offset points", xytext=(0, 20), ha='center', fontsize=9)
    
# Mark leaves
ax5.annotate('leaf', (x_pos[0], 0), textcoords="offset points", 
            xytext=(0, -25), ha='center', fontsize=8, color='red')
ax5.annotate('leaf', (x_pos[-1], 0), textcoords="offset points",
            xytext=(0, -25), ha='center', fontsize=8, color='red')

# Arrows showing propagation
for i in range(n-1):
    ax5.annotate('', xy=(x_pos[i+1]-0.1, 0.08), xytext=(x_pos[i]+0.1, 0.08),
                arrowprops=dict(arrowstyle='->', color='blue', lw=1.5))

ax5.set_title('Leaf Rigidity Propagation\nf(leaf) = f(neighbor) → constant')
ax5.set_ylim(-0.5, 0.5)
ax5.axis('off')

# Panel 6: Critical group structure diagram
ax6 = fig.add_subplot(gs[1, 2])
ax6.axis('off')
text = """
Tropical Kernel ↔ Critical Group
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Harmonic        Smith Normal
    Functions  ═══  Form of L_S
       │                │
       ▼                ▼
   Canonical       Invariant
   Generators      Factors
       │                │
       ▼                ▼
   Tropical ══════ Critical
   Kernel          Group
  (mod const)    (Z^n/Im L_S)

Key Correspondence:
• dim(kernel) - 1 ↔ #(factors > 1)  
• Normalized generators ↔ Torsion classes
• Leaf rigidity ↔ Unique extensions
• Separation ↔ Faithful restriction
"""
ax6.text(0.05, 0.95, text, transform=ax6.transAxes, fontsize=9,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.savefig('viz_laplacian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_laplacian_spectrum.png")
