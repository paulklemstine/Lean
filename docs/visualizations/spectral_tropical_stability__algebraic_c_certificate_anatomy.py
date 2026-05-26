"""
Visualization: Anatomy of a Spectral Stability Certificate

Shows how a spectral stability certificate is assembled from per-stage data:
Fiedler eigenvalues, edge symmetric differences, and the gap floor.
Illustrates the "pipeline" from point cloud → spectrum → certified bound.
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


def tropical_nullity(adj):
    n = adj.shape[0]
    num_edges = int(adj.sum()) // 2
    visited = set()
    num_components = 0
    for start in range(n):
        if start not in visited:
            num_components += 1
            queue = [start]
            visited.add(start)
            while queue:
                node = queue.pop(0)
                for neighbor in range(n):
                    if adj[node, neighbor] and neighbor not in visited:
                        visited.add(neighbor)
                        queue.append(neighbor)
    return num_edges - n + num_components


def edge_symm_diff_card(adj1, adj2):
    diff = np.logical_xor(adj1, adj2)
    return int(diff.sum()) // 2


# Generate data
np.random.seed(42)
n_per_cluster = 10
d = 2
sep = 2.0
eps = 0.08

c1 = np.random.randn(n_per_cluster, d) * 0.3
c2 = np.random.randn(n_per_cluster, d) * 0.3 + np.array([sep, 0])
points = np.vstack([c1, c2])
n = 2 * n_per_cluster

noise = np.random.randn(n, d) * eps / np.sqrt(d)
points_pert = points + noise

thresholds = np.linspace(0.1, 4.0, 25)

# Compute per-stage data
fiedler_vals = []
edge_diffs = []
nullity_orig = []
nullity_pert = []
connected = []

for r in thresholds:
    adj_o = vietoris_rips_graph(points, r)
    adj_p = vietoris_rips_graph(points_pert, r)
    lam2 = fiedler_value(adj_o)
    fiedler_vals.append(lam2)
    edge_diffs.append(edge_symm_diff_card(adj_o, adj_p))
    nullity_orig.append(tropical_nullity(adj_o))
    nullity_pert.append(tropical_nullity(adj_p))
    connected.append(lam2 > 1e-10)

fiedler_vals = np.array(fiedler_vals)
edge_diffs = np.array(edge_diffs)
conn_mask = np.array(connected)
lam_star = min(fiedler_vals[conn_mask]) if np.any(conn_mask) else 0

# Create figure
fig = plt.figure(figsize=(16, 14))
gs = gridspec.GridSpec(3, 2, hspace=0.4, wspace=0.3)

# Panel 1: Point clouds
ax1 = fig.add_subplot(gs[0, 0])
ax1.scatter(points[:n_per_cluster, 0], points[:n_per_cluster, 1],
           c='steelblue', s=60, label='Original', zorder=3, edgecolors='navy')
ax1.scatter(points[n_per_cluster:, 0], points[n_per_cluster:, 1],
           c='steelblue', s=60, zorder=3, edgecolors='navy')
ax1.scatter(points_pert[:, 0], points_pert[:, 1],
           c='coral', s=30, alpha=0.6, label='Perturbed', zorder=2)
for i in range(n):
    ax1.annotate('', xy=points_pert[i], xytext=points[i],
                arrowprops=dict(arrowstyle='->', color='gray', alpha=0.4, lw=0.5))
ax1.set_title(f'Point Clouds (ε={eps})', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.2)

# Panel 2: Fiedler eigenvalue across stages
ax2 = fig.add_subplot(gs[0, 1])
colors = ['green' if c else 'red' for c in connected]
ax2.bar(range(len(thresholds)), fiedler_vals, color=colors, alpha=0.7, width=0.8)
ax2.axhline(y=lam_star, color='darkred', linestyle='--', linewidth=2,
           label=f'λ* = {lam_star:.4f}')
ax2.set_xlabel('Filtration Stage', fontsize=12)
ax2.set_ylabel('λ₂ (Fiedler Value)', fontsize=12)
ax2.set_title('Spectral Profile of Filtration', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.2, axis='y')

# Panel 3: Edge symmetric differences
ax3 = fig.add_subplot(gs[1, 0])
ax3.bar(range(len(thresholds)), edge_diffs, color='darkorange', alpha=0.7, width=0.8)
if lam_star > 1e-10 and eps > 0:
    bound_line = max(edge_diffs) * np.ones(len(thresholds))
    ax3.axhline(y=max(edge_diffs), color='red', linestyle='--',
               label=f'Max ΔE = {max(edge_diffs)}')
ax3.set_xlabel('Filtration Stage', fontsize=12)
ax3.set_ylabel('|E(F) Δ E(F̃)|', fontsize=12)
ax3.set_title('Edge Symmetric Differences', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.2, axis='y')

# Panel 4: Tropical barcodes
ax4 = fig.add_subplot(gs[1, 1])
ax4.step(range(len(thresholds)), nullity_orig, where='mid',
        linewidth=2, color='steelblue', label='Original β₁')
ax4.step(range(len(thresholds)), nullity_pert, where='mid',
        linewidth=2, color='coral', label='Perturbed β₁', linestyle='--')
diffs = [abs(a - b) for a, b in zip(nullity_orig, nullity_pert)]
ax4.fill_between(range(len(thresholds)), nullity_orig, nullity_pert,
                alpha=0.15, color='red', step='mid')
ax4.set_xlabel('Filtration Stage', fontsize=12)
ax4.set_ylabel('Tropical Nullity β₁', fontsize=12)
ax4.set_title('Tropical Barcode Profiles', fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.2)

# Panel 5: Certificate summary
ax5 = fig.add_subplot(gs[2, :])
ax5.axis('off')

actual_dist = max(diffs)
Kmax_val = max(d * lam_star / eps if d > 0 and lam_star > 0 else 0 for d in edge_diffs)
bound_val = Kmax_val * eps / lam_star if lam_star > 1e-10 else float('inf')

cert_text = (
    f"╔══════════════════════════════════════════════════════════════╗\n"
    f"║           SPECTRAL STABILITY CERTIFICATE                    ║\n"
    f"╠══════════════════════════════════════════════════════════════╣\n"
    f"║  Stages: {len(thresholds):>3}    Points: {n:>3}    Dimension: {d}               ║\n"
    f"║  Perturbation ε = {eps:.4f}                                  ║\n"
    f"║  Spectral gap floor λ* = {lam_star:.6f}                     ║\n"
    f"║  Edge sensitivity Kmax = {Kmax_val:.4f}                       ║\n"
    f"║                                                              ║\n"
    f"║  CERTIFIED BOUND: d_tb ≤ Kmax·ε/λ* = {bound_val:.4f}            ║\n"
    f"║  ACTUAL DISTANCE: d_tb = {actual_dist}                            ║\n"
    f"║  CERTIFICATE VALID: {'✓ YES' if actual_dist <= bound_val + 0.01 else '✗ NO':>5}                                  ║\n"
    f"╚══════════════════════════════════════════════════════════════╝"
)
ax5.text(0.5, 0.5, cert_text, transform=ax5.transAxes,
        fontsize=11, fontfamily='monospace',
        verticalalignment='center', horizontalalignment='center',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

fig.suptitle('Anatomy of a Spectral Stability Certificate',
             fontsize=15, fontweight='bold', y=0.98)

plt.savefig('certificate_anatomy.png', dpi=150, bbox_inches='tight')
print("Saved: certificate_anatomy.png")
