#!/usr/bin/env python3
"""
Demo 2: Kirchhoff's Laws as Homological Algebra
=================================================

Kirchhoff's Current Law (KCL) and Voltage Law (KVL) are not just empirical rules —
they are exactness conditions in the chain complex of a graph.

Currents are 1-cycles (elements of ker ∂₁).
Voltages are 1-cocycles (elements of ker δ₁ = ker ∂₁ᵀ).

The first Betti number β₁ = dim(ker ∂₁) - dim(im ∂₂) counts independent loops.

Part of: The Algebraic Theory of Electricity
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as FancyArrowPatch
from matplotlib.gridspec import GridSpec
import networkx as nx

plt.rcParams.update({
    'figure.facecolor': '#0a0a1a',
    'axes.facecolor': '#0a0a1a',
    'text.color': '#e0e0e0',
    'axes.labelcolor': '#e0e0e0',
    'xtick.color': '#888888',
    'ytick.color': '#888888',
    'axes.edgecolor': '#333333',
    'font.family': 'monospace',
    'font.size': 10,
})

GOLD = '#FFD700'
CYAN = '#00FFFF'
MAGENTA = '#FF00FF'
LIME = '#00FF88'
ORANGE = '#FF8800'
RED = '#FF4444'
WHITE = '#FFFFFF'

# ─── Build a Wheatstone Bridge circuit ───
# Nodes: 0 (source+), 1 (top), 2 (bottom), 3 (source-)
# Edges: 0→1, 0→2, 1→2, 1→3, 2→3

edges = [(0, 1), (0, 2), (1, 2), (1, 3), (2, 3)]
n_nodes = 4
n_edges = 5

# Incidence matrix (boundary operator ∂₁)
# ∂₁[i, e] = +1 if edge e ends at node i, -1 if edge e starts at node i
incidence = np.zeros((n_nodes, n_edges))
for e_idx, (u, v) in enumerate(edges):
    incidence[u, e_idx] = -1  # tail
    incidence[v, e_idx] = +1  # head

print("═══ THE CHAIN COMPLEX OF THE WHEATSTONE BRIDGE ═══\n")
print("Incidence matrix ∂₁ (boundary operator):")
print(incidence)
print(f"\nShape: C₁ (ℝ^{n_edges}) → C₀ (ℝ^{n_nodes})")

# ─── Compute cycle space (ker ∂₁) ───
# KCL: ∂₁ · I = 0 means current is a 1-cycle
U, S, Vt = np.linalg.svd(incidence)
rank = np.sum(S > 1e-10)
nullity = n_edges - rank
print(f"\nRank of ∂₁: {rank}")
print(f"Nullity of ∂₁ (cycle space dimension): {nullity}")
print(f"β₁ = m - n + 1 = {n_edges} - {n_nodes} + 1 = {n_edges - n_nodes + 1}")
print(f"(This equals the number of independent loops!)\n")

# Find cycle space basis (null space of incidence matrix)
# Cycles are in the null space of ∂₁ᵀ acting on edge space
null_mask = S < 1e-10
# Use the last (n_edges - rank) rows of Vt
cycle_basis = Vt[rank:, :]
print("Cycle space basis (each row is a cycle):")
for i, cycle in enumerate(cycle_basis):
    print(f"  Loop {i+1}: {np.round(cycle, 3)}")

# ─── Graph Laplacian ───
L = incidence @ incidence.T
print(f"\nGraph Laplacian L = ∂₁ · ∂₁ᵀ:")
print(L)
eigenvalues = np.linalg.eigvalsh(L)
print(f"Eigenvalues: {np.round(eigenvalues, 4)}")
print(f"Algebraic connectivity (λ₂): {eigenvalues[1]:.4f}")

# ─── Solve circuit using homological algebra ───
# Impedances
Z = np.array([100, 200, 150, 300, 100], dtype=complex)  # Ohms
Z_diag = np.diag(Z)

# Source: voltage V₀ between nodes 0 and 3
V_source = 12.0  # Volts

# The circuit equation: ∂₁ᵀ Z⁻¹ ∂₁ v = source_currents
# (This is the discrete Hodge-Laplacian!)
Z_inv = np.diag(1.0 / Z)
hodge_laplacian = incidence @ Z_inv @ incidence.T

print(f"\n═══ HODGE-LAPLACIAN (Weighted Graph Laplacian) ═══")
print(f"L_Z = ∂₁ Z⁻¹ ∂₁ᵀ:")
print(np.round(hodge_laplacian.real, 6))

# ─── Visualization ───
fig = plt.figure(figsize=(20, 14))
fig.suptitle("KIRCHHOFF'S LAWS AS HOMOLOGICAL ALGEBRA",
             fontsize=18, color=GOLD, fontweight='bold', y=0.98)
gs = GridSpec(2, 3, figure=fig, hspace=0.4, wspace=0.35)

# Panel 1: The circuit graph
ax1 = fig.add_subplot(gs[0, 0])
G = nx.DiGraph()
G.add_edges_from(edges)
pos = {0: (0, 0.5), 1: (0.5, 1), 2: (0.5, 0), 3: (1, 0.5)}

nx.draw_networkx_nodes(G, pos, ax=ax1, node_color=[CYAN, GOLD, GOLD, MAGENTA],
                       node_size=500, edgecolors=WHITE, linewidths=2)
nx.draw_networkx_labels(G, pos, ax=ax1, font_color='black', font_weight='bold',
                        font_size=14)

edge_colors = [ORANGE] * 5
edge_labels = {e: f'Z{i}={int(Z[i].real)}Ω' for i, e in enumerate(edges)}
nx.draw_networkx_edges(G, pos, ax=ax1, edge_color=edge_colors, width=2.5,
                       arrows=True, arrowsize=20, arrowstyle='->', min_target_margin=15,
                       min_source_margin=15)
nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels, ax=ax1,
                             font_color=ORANGE, font_size=8)

ax1.set_title('Wheatstone Bridge\n(Directed Graph)', color=CYAN, fontsize=13)
ax1.set_xlim(-0.2, 1.2)
ax1.set_ylim(-0.2, 1.2)

# Panel 2: The chain complex
ax2 = fig.add_subplot(gs[0, 1])
ax2.axis('off')

complex_text = """
   THE CHAIN COMPLEX OF A CIRCUIT

        ∂₂         ∂₁         ∂₀
   C₂ ────→ C₁ ────→ C₀ ────→ 0
   faces   edges    nodes

   Key identity: ∂₁ ∘ ∂₂ = 0  (d² = 0)

   ┌─────────────────────────────────┐
   │ KCL: I ∈ ker(∂₁)               │
   │ "Current is a 1-cycle"          │
   │                                 │
   │ KVL: V ∈ ker(∂₁ᵀ) = im(∂₀ᵀ)   │
   │ "Voltage is a 1-coboundary"     │
   │ (V = ∂₀ᵀ φ for node potentials φ)│
   └─────────────────────────────────┘

   Homology:
   H₁(G) = ker(∂₁)/im(∂₂)
   dim H₁ = β₁ = m - n + 1 = 2
   (Two independent loops!)

   Hodge decomposition:
   C₁ = im(∂₂) ⊕ H₁ ⊕ im(∂₁ᵀ)
   edges = boundaries ⊕ harmonic ⊕ coboundaries
"""
ax2.text(0.02, 0.98, complex_text, transform=ax2.transAxes, fontsize=9,
        verticalalignment='top', fontfamily='monospace', color=LIME,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=LIME, alpha=0.8))

# Panel 3: Incidence matrix heatmap
ax3 = fig.add_subplot(gs[0, 2])
im = ax3.imshow(incidence, cmap='RdBu_r', aspect='auto', vmin=-1.5, vmax=1.5,
               interpolation='nearest')
ax3.set_xlabel('Edges (e₀ ... e₄)')
ax3.set_ylabel('Nodes (v₀ ... v₃)')
ax3.set_title('Boundary Operator ∂₁\n(Incidence Matrix)', color=MAGENTA, fontsize=13)
ax3.set_xticks(range(n_edges))
ax3.set_yticks(range(n_nodes))
ax3.set_xticklabels([f'e{i}' for i in range(n_edges)])
ax3.set_yticklabels([f'v{i}' for i in range(n_nodes)])

for i in range(n_nodes):
    for j in range(n_edges):
        val = int(incidence[i, j])
        if val != 0:
            ax3.text(j, i, f'{val:+d}', ha='center', va='center',
                    color=WHITE, fontweight='bold', fontsize=14)

plt.colorbar(im, ax=ax3, shrink=0.8)

# Panel 4: Laplacian spectrum
ax4 = fig.add_subplot(gs[1, 0])
eigenvalues_sorted = np.sort(eigenvalues)
colors = [RED if ev < 0.01 else CYAN for ev in eigenvalues_sorted]
bars = ax4.bar(range(len(eigenvalues_sorted)), eigenvalues_sorted, color=colors,
              edgecolor=WHITE, linewidth=0.5)
ax4.set_xlabel('Eigenvalue index')
ax4.set_ylabel('λ')
ax4.set_title('Laplacian Spectrum\n(λ₁=0 ↔ connected)', color=CYAN, fontsize=13)
ax4.set_xticks(range(len(eigenvalues_sorted)))
ax4.set_xticklabels([f'λ{i}' for i in range(len(eigenvalues_sorted))])

for i, ev in enumerate(eigenvalues_sorted):
    ax4.text(i, ev + 0.1, f'{ev:.2f}', ha='center', va='bottom',
            color=colors[i], fontsize=10)

ax4.grid(True, alpha=0.2, color='#444444', axis='y')

# Panel 5: Cycle space visualization
ax5 = fig.add_subplot(gs[1, 1])

# Draw the two independent loops
for idx, (cycle, color, label) in enumerate(zip(cycle_basis,
                                                 [CYAN, MAGENTA],
                                                 ['Loop 1', 'Loop 2'])):
    offsets = [(0, 0.05 * (idx - 0.5)), (0, 0.05 * (idx - 0.5))]
    for e_idx, (u, v) in enumerate(edges):
        if abs(cycle[e_idx]) > 0.01:
            p1 = np.array(pos[u]) + np.array([0, 0.05 * (idx - 0.5)])
            p2 = np.array(pos[v]) + np.array([0, 0.05 * (idx - 0.5)])
            mid = (p1 + p2) / 2
            ax5.annotate('', xy=p2, xytext=p1,
                        arrowprops=dict(arrowstyle='->', color=color,
                                       lw=2 * abs(cycle[e_idx]) + 0.5))
            ax5.text(mid[0], mid[1] + 0.05, f'{cycle[e_idx]:.2f}',
                    fontsize=7, color=color, ha='center')

for node, (x, y) in pos.items():
    ax5.plot(x, y, 'o', markersize=15, color='#222222', markeredgecolor=WHITE,
            markeredgewidth=2, zorder=5)
    ax5.text(x, y, str(node), ha='center', va='center', color=WHITE,
            fontweight='bold', fontsize=12, zorder=6)

ax5.set_title('Cycle Space Basis\n(Independent Loops = ker ∂₁)',
             color=GOLD, fontsize=13)
ax5.legend([f'Loop 1 (blue)', f'Loop 2 (magenta)'], loc='lower right',
          fontsize=9)
ax5.set_xlim(-0.3, 1.3)
ax5.set_ylim(-0.3, 1.3)

# Panel 6: The discrete-continuous correspondence
ax6 = fig.add_subplot(gs[1, 2])
ax6.axis('off')

correspondence = """
╔═══════════════════════════════════════════╗
║  DISCRETE ←→ CONTINUOUS DICTIONARY       ║
╠═══════════════════════════════════════════╣
║                                           ║
║  Graph G          ←→  Manifold M          ║
║  Nodes (0-cells)  ←→  Points              ║
║  Edges (1-cells)  ←→  Paths               ║
║  Faces (2-cells)  ←→  Surfaces            ║
║                                           ║
║  C*(G; ℝ)         ←→  Ω*(M)              ║
║  (chain complex)      (de Rham complex)   ║
║                                           ║
║  ∂ (boundary)     ←→  d (exterior deriv)  ║
║  ∂² = 0           ←→  d² = 0             ║
║                                           ║
║  KCL: ∂₁I = 0    ←→  dF = 0 (Bianchi)   ║
║  KVL: ∂₁ᵀV = 0   ←→  d★F = J (Maxwell)  ║
║                                           ║
║  Graph Laplacian  ←→  Laplace-de Rham     ║
║  L = ∂∂ᵀ          ←→  Δ = dδ + δd         ║
║                                           ║
║  β₁ = m-n+1      ←→  β₁ = dim H¹_dR(M)  ║
║  (independent         (topological        ║
║   loops)               holes)             ║
╚═══════════════════════════════════════════╝
"""
ax6.text(0.02, 0.98, correspondence, transform=ax6.transAxes, fontsize=8.5,
        verticalalignment='top', fontfamily='monospace', color=ORANGE,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=ORANGE, alpha=0.8))

plt.savefig('/workspace/request-project/Electricity/demos/fig2_kirchhoff_homology.png',
           dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()

print("\n✅ Demo 2: Kirchhoff-Homology visualization saved.")
