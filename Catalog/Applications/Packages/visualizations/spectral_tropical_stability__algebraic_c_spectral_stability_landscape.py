"""
Visualization: Spectral Tropical Stability Landscape

Visualizes the core relationship: how the Fiedler eigenvalue (spectral gap)
controls tropical barcode stability under metric perturbation.

Creates a heatmap showing barcode drift as a function of perturbation ε
and cluster separation (which controls λ*).
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


def tropical_barcode(points, thresholds):
    return [tropical_nullity(vietoris_rips_graph(points, r)) for r in thresholds]


def tropical_barcode_distance(bc1, bc2):
    return max(abs(a - b) for a, b in zip(bc1, bc2))


# Parameters
n_per_cluster = 8
d = 2
separations = np.linspace(0.5, 5.0, 20)
epsilons = np.logspace(-2.5, -0.3, 18)
thresholds = np.linspace(0.1, 6.0, 15).tolist()

# Compute data
dtb_matrix = np.zeros((len(separations), len(epsilons)))
lam_matrix = np.zeros((len(separations), len(epsilons)))
ratio_matrix = np.zeros((len(separations), len(epsilons)))

for i, sep in enumerate(separations):
    rng = np.random.RandomState(42)
    c1 = rng.randn(n_per_cluster, d) * 0.3
    c2 = rng.randn(n_per_cluster, d) * 0.3 + np.array([sep, 0])
    points = np.vstack([c1, c2])

    # Compute λ* for this separation
    fvals = []
    for r in thresholds:
        adj = vietoris_rips_graph(points, r)
        lam2 = fiedler_value(adj)
        if lam2 > 1e-10:
            fvals.append(lam2)
    lam_star = min(fvals) if fvals else 0.0

    for j, eps in enumerate(epsilons):
        rng2 = np.random.RandomState(42)
        noise = rng2.randn(2 * n_per_cluster, d) * eps / np.sqrt(d)
        points_pert = points + noise

        bc1 = tropical_barcode(points, thresholds)
        bc2 = tropical_barcode(points_pert, thresholds)
        dtb = tropical_barcode_distance(bc1, bc2)

        dtb_matrix[i, j] = dtb
        lam_matrix[i, j] = lam_star
        if lam_star > 1e-10 and eps > 1e-15:
            ratio_matrix[i, j] = dtb * lam_star / eps
        else:
            ratio_matrix[i, j] = np.nan

# Create figure
fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# Panel 1: Barcode drift heatmap
ax1 = fig.add_subplot(gs[0, 0])
im1 = ax1.pcolormesh(epsilons, separations, dtb_matrix, shading='auto', cmap='YlOrRd')
ax1.set_xscale('log')
ax1.set_xlabel('Perturbation ε', fontsize=12)
ax1.set_ylabel('Cluster Separation', fontsize=12)
ax1.set_title('Tropical Barcode Distance d_tb', fontsize=13, fontweight='bold')
plt.colorbar(im1, ax=ax1, label='d_tb')

# Panel 2: Spectral gap floor
ax2 = fig.add_subplot(gs[0, 1])
lam_vals = [min([fiedler_value(vietoris_rips_graph(
    np.vstack([np.random.RandomState(42).randn(n_per_cluster, d) * 0.3,
               np.random.RandomState(42).randn(n_per_cluster, d) * 0.3 + np.array([s, 0])]), r))
    for r in thresholds
    if fiedler_value(vietoris_rips_graph(
        np.vstack([np.random.RandomState(42).randn(n_per_cluster, d) * 0.3,
                   np.random.RandomState(42).randn(n_per_cluster, d) * 0.3 + np.array([s, 0])]), r)) > 1e-10]
    or [0.0])
    for s in separations]
ax2.plot(separations, lam_vals, 'b-o', linewidth=2, markersize=5)
ax2.set_xlabel('Cluster Separation', fontsize=12)
ax2.set_ylabel('λ* (Spectral Gap Floor)', fontsize=12)
ax2.set_title('Spectral Gap Floor vs Separation', fontsize=13, fontweight='bold')
ax2.grid(True, alpha=0.3)

# Panel 3: Stability ratio heatmap
ax3 = fig.add_subplot(gs[1, 0])
ratio_clipped = np.clip(ratio_matrix, 0, np.nanpercentile(ratio_matrix, 95))
im3 = ax3.pcolormesh(epsilons, separations, ratio_clipped, shading='auto', cmap='viridis')
ax3.set_xscale('log')
ax3.set_xlabel('Perturbation ε', fontsize=12)
ax3.set_ylabel('Cluster Separation', fontsize=12)
ax3.set_title('Stability Ratio d_tb · λ* / ε', fontsize=13, fontweight='bold')
plt.colorbar(im3, ax=ax3, label='d_tb · λ* / ε')

# Panel 4: Ratio vs ε for different separations
ax4 = fig.add_subplot(gs[1, 1])
for idx in [2, 8, 14, 19]:
    if idx < len(separations):
        mask = ~np.isnan(ratio_matrix[idx, :])
        if np.any(mask):
            ax4.plot(epsilons[mask], ratio_matrix[idx, mask],
                    '-o', markersize=4,
                    label=f'sep={separations[idx]:.1f}')
ax4.set_xscale('log')
ax4.set_xlabel('Perturbation ε', fontsize=12)
ax4.set_ylabel('d_tb · λ* / ε', fontsize=12)
ax4.set_title('Conjecture Test: Is Ratio Bounded?', fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

fig.suptitle('Spectral Tropical Stability: λ₂ Controls Barcode Robustness',
             fontsize=15, fontweight='bold', y=0.98)

plt.savefig('spectral_stability_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: spectral_stability_landscape.png")
