"""
Visualization: Cheeger Bridge — From Expansion to Stability

Illustrates the cross-domain bridge theorem: how the Cheeger constant
(graph expansion / isoperimetric profile) connects to tropical barcode
stability through the spectral gap.

Shows: Cheeger constant → Fiedler eigenvalue → barcode stability bound.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def vietoris_rips_graph(points, threshold):
    n = points.shape[0]
    dists = np.linalg.norm(points[:, None, :] - points[None, :, :], axis=2)
    adj = (dists <= threshold) & ~np.eye(n, dtype=bool)
    return adj


def graph_laplacian(adj):
    degree = adj.sum(axis=1)
    return np.diag(degree) - adj.astype(float)


def fiedler_value(adj):
    L = graph_laplacian(adj)
    eigenvalues = np.linalg.eigvalsh(L)
    eigenvalues.sort()
    return max(0.0, eigenvalues[1]) if len(eigenvalues) >= 2 else 0.0


def estimate_cheeger(adj):
    """Estimate Cheeger constant by sampling random vertex subsets."""
    n = adj.shape[0]
    if n <= 1:
        return 0.0
    degrees = adj.sum(axis=1)
    best_h = float('inf')
    rng = np.random.RandomState(42)
    for _ in range(min(500, 2**n)):
        size = rng.randint(1, n)
        S = set(rng.choice(n, size, replace=False))
        S_comp = set(range(n)) - S
        vol_S = sum(degrees[v] for v in S)
        vol_Sc = sum(degrees[v] for v in S_comp)
        if vol_S == 0 or vol_Sc == 0:
            continue
        cut = sum(1 for u in S for v in S_comp if adj[u, v])
        h = cut / min(vol_S, vol_Sc)
        best_h = min(best_h, h)
    return best_h if best_h < float('inf') else 0.0


def tropical_nullity(adj):
    n = adj.shape[0]
    num_edges = int(adj.sum()) // 2
    visited = set()
    nc = 0
    for s in range(n):
        if s not in visited:
            nc += 1
            q = [s]
            visited.add(s)
            while q:
                node = q.pop(0)
                for nb in range(n):
                    if adj[node, nb] and nb not in visited:
                        visited.add(nb)
                        q.append(nb)
    return num_edges - n + nc


# Generate diverse graph topologies
np.random.seed(42)
n_graphs = 50
n_points = 15
d = 2

cheeger_vals = []
fiedler_vals = []
stability_scores = []
graph_types = []

for trial in range(n_graphs):
    # Vary topology by changing point distribution
    if trial < n_graphs // 3:
        # Tight cluster (high expansion)
        pts = np.random.randn(n_points, d) * 0.5
        gtype = 'Dense'
    elif trial < 2 * n_graphs // 3:
        # Two clusters with bridge
        c1 = np.random.randn(n_points // 2, d) * 0.3
        c2 = np.random.randn(n_points - n_points // 2, d) * 0.3 + np.array([1.5 + trial * 0.05, 0])
        pts = np.vstack([c1, c2])
        gtype = 'Bridged'
    else:
        # Random sparse
        pts = np.random.randn(n_points, d) * (1.0 + trial * 0.02)
        gtype = 'Sparse'

    threshold = 1.2
    adj = vietoris_rips_graph(pts, threshold)
    lam2 = fiedler_value(adj)
    h = estimate_cheeger(adj)

    if lam2 > 1e-10:
        # Measure stability: perturb and check barcode drift
        eps = 0.05
        pts_pert = pts + np.random.randn(n_points, d) * eps
        adj_pert = vietoris_rips_graph(pts_pert, threshold)
        tn_orig = tropical_nullity(adj)
        tn_pert = tropical_nullity(adj_pert)
        stability = abs(tn_orig - tn_pert) / (eps + 1e-10)

        cheeger_vals.append(h)
        fiedler_vals.append(lam2)
        stability_scores.append(stability)
        graph_types.append(gtype)

# Create figure
fig = plt.figure(figsize=(16, 10))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# Panel 1: Cheeger vs Fiedler (discrete Cheeger inequality)
ax1 = fig.add_subplot(gs[0, 0])
colors_map = {'Dense': 'steelblue', 'Bridged': 'orange', 'Sparse': 'green'}
for gt in ['Dense', 'Bridged', 'Sparse']:
    mask = [g == gt for g in graph_types]
    h_vals = [cheeger_vals[i] for i in range(len(mask)) if mask[i]]
    f_vals = [fiedler_vals[i] for i in range(len(mask)) if mask[i]]
    ax1.scatter(h_vals, f_vals, c=colors_map[gt], s=50, alpha=0.7, label=gt)

# Cheeger inequality curves
h_range = np.linspace(0.001, max(cheeger_vals) * 1.2, 100)
ax1.plot(h_range, h_range**2 / 2, 'k--', linewidth=1.5, alpha=0.6, label='h²/2 (lower)')
ax1.plot(h_range, 2 * h_range, 'k:', linewidth=1.5, alpha=0.6, label='2h (upper)')
ax1.set_xlabel('Cheeger Constant h(G)', fontsize=12)
ax1.set_ylabel('Fiedler Value λ₂(G)', fontsize=12)
ax1.set_title('Discrete Cheeger Inequality', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.2)

# Panel 2: Fiedler vs Stability (inverse relationship)
ax2 = fig.add_subplot(gs[0, 1])
for gt in ['Dense', 'Bridged', 'Sparse']:
    mask = [g == gt for g in graph_types]
    f_vals = [fiedler_vals[i] for i in range(len(mask)) if mask[i]]
    s_vals = [stability_scores[i] for i in range(len(mask)) if mask[i]]
    ax2.scatter(f_vals, s_vals, c=colors_map[gt], s=50, alpha=0.7, label=gt)
ax2.set_xlabel('λ₂ (Fiedler Value)', fontsize=12)
ax2.set_ylabel('Barcode Sensitivity |Δβ₁|/ε', fontsize=12)
ax2.set_title('Spectral Stiffness Controls Stability', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.2)

# Panel 3: Bridge diagram
ax3 = fig.add_subplot(gs[1, 0])
ax3.axis('off')

bridge_text = """
    ┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐
    │   ISOPERIMETRY   │        │  SPECTRAL THEORY │        │   TROPICAL TDA   │
    │                  │        │                  │        │                  │
    │  Cheeger const.  │──────▶ │  Fiedler value   │──────▶ │  Barcode bound   │
    │     h(G)         │ h²/2≤λ₂│     λ₂(G)       │ Kε/λ₂ │  d_tb ≤ Kε/λ*   │
    │                  │        │                  │        │                  │
    │ Graph expansion  │        │ Algebraic conn.  │        │ Topological      │
    │ Cut structure    │        │ Laplacian gap    │        │ persistence      │
    └─────────────────┘        └─────────────────┘        └─────────────────┘

                    The Cheeger Bridge Theorem:

          d_tb(F, F̃; N) ≤ Kmax · ε / (c · h_min²)

    Expansion ⟶ Spectral gap ⟶ Topological robustness
"""
ax3.text(0.5, 0.5, bridge_text, transform=ax3.transAxes,
        fontsize=9, fontfamily='monospace',
        verticalalignment='center', horizontalalignment='center',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

# Panel 4: Combined Cheeger → Stability
ax4 = fig.add_subplot(gs[1, 1])
for gt in ['Dense', 'Bridged', 'Sparse']:
    mask = [g == gt for g in graph_types]
    h_vals = [cheeger_vals[i] for i in range(len(mask)) if mask[i]]
    s_vals = [stability_scores[i] for i in range(len(mask)) if mask[i]]
    ax4.scatter(h_vals, s_vals, c=colors_map[gt], s=50, alpha=0.7, label=gt)
ax4.set_xlabel('Cheeger Constant h(G)', fontsize=12)
ax4.set_ylabel('Barcode Sensitivity |Δβ₁|/ε', fontsize=12)
ax4.set_title('Cheeger → Stability (Full Bridge)', fontsize=13, fontweight='bold')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.2)

fig.suptitle('The Cheeger Bridge: From Graph Expansion to Topological Stability',
             fontsize=15, fontweight='bold', y=0.98)

plt.savefig('cheeger_bridge.png', dpi=150, bbox_inches='tight')
print("Saved: cheeger_bridge.png")
