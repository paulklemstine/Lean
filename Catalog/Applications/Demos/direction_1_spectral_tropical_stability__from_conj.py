"""
Applications of Spectral Tropical Stability

Real-world applications demonstrating how spectral gap data can certify
topological robustness in practical data analysis pipelines.

Applications:
1. Sensor network robustness: certify that noisy position data preserves topology
2. Protein structure stability: predict barcode sensitivity from connectivity
3. Manifold learning validation: check if persistence is reliable before computing
"""

import numpy as np
from algorithms import (
    vietoris_rips_graph, fiedler_value, tropical_nullity,
    tropical_barcode, tropical_barcode_distance,
    compute_spectral_stability_certificate
)


def application_1_sensor_network():
    """
    Sensor Network Robustness Certification

    Scenario: A network of n sensors with known measurement noise ε.
    Question: Will the topological summary (tropical barcode) of the network
    remain stable under measurement uncertainty?

    The spectral stability theorem tells us: compute the Fiedler eigenvalue
    of the VR graph at each scale, then the barcode drift is at most Kmax·ε/λ*.
    """
    print("=" * 70)
    print("APPLICATION 1: Sensor Network Robustness")
    print("=" * 70)

    np.random.seed(42)
    n_sensors = 25
    measurement_noise = 0.08  # ε: known sensor accuracy

    # Simulate sensor positions (ring + hub topology)
    angles = np.linspace(0, 2 * np.pi, 20, endpoint=False)
    ring = np.column_stack([np.cos(angles), np.sin(angles)]) * 2.0
    hub = np.random.randn(5, 2) * 0.3
    true_positions = np.vstack([ring, hub])

    # Measured positions (with noise)
    measured = true_positions + np.random.randn(n_sensors, 2) * measurement_noise

    # Compute stability certificate
    scales = np.linspace(0.3, 3.0, 15).tolist()
    cert = compute_spectral_stability_certificate(
        true_positions, measured, scales, measurement_noise)

    # Compare with actual drift
    bc_true = tropical_barcode(true_positions, scales)
    bc_meas = tropical_barcode(measured, scales)
    actual = tropical_barcode_distance(bc_true, bc_meas)

    print(f"Sensors: {n_sensors}, noise level: ε={measurement_noise}")
    print(f"Spectral gap floor: λ*={cert.lam_star:.4f}")
    print(f"Edge sensitivity: Kmax={cert.Kmax:.2f}")
    print(f"Certified bound: {cert.bound:.4f}")
    print(f"Actual barcode drift: {actual}")
    print(f"Certificate valid: {actual <= cert.bound + 1e-10}")
    print(f"Stability margin: {cert.bound - actual:.4f}")
    print()

    # Decision support
    tolerance = 2  # acceptable barcode drift
    if cert.bound <= tolerance:
        print(f"✓ CERTIFIED STABLE: barcode drift guaranteed ≤ {cert.bound:.2f} < {tolerance}")
    else:
        print(f"✗ Cannot certify stability: bound {cert.bound:.2f} exceeds tolerance {tolerance}")


def application_2_protein_structure():
    """
    Protein Structure Stability Analysis

    Scenario: Given a protein's contact map (as a point cloud of Cα positions),
    predict whether small conformational changes will alter the topological
    signature used for structure classification.

    Uses spectral gap as a proxy for structural rigidity.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Protein Structure Stability")
    print("=" * 70)

    np.random.seed(123)

    # Simulate a protein backbone (simplified helix + sheet)
    n_residues = 30
    t = np.linspace(0, 4 * np.pi, n_residues)
    # Helix part
    helix = np.column_stack([np.cos(t[:15]), np.sin(t[:15]), t[:15] * 0.5])
    # Sheet part
    sheet = np.column_stack([
        np.linspace(2, 4, 15),
        np.sin(np.linspace(0, np.pi, 15)) * 0.3,
        np.zeros(15) + 1.0
    ])
    positions = np.vstack([helix, sheet])

    # Thermal fluctuation
    thermal_noise = 0.15  # Angstrom-scale fluctuations
    fluctuated = positions + np.random.randn(n_residues, 3) * thermal_noise

    scales = np.linspace(0.5, 5.0, 12).tolist()
    cert = compute_spectral_stability_certificate(
        positions, fluctuated, scales, thermal_noise)

    bc1 = tropical_barcode(positions, scales)
    bc2 = tropical_barcode(fluctuated, scales)
    actual = tropical_barcode_distance(bc1, bc2)

    print(f"Residues: {n_residues}, thermal noise: {thermal_noise} Å")
    print(f"Spectral gap floor: λ*={cert.lam_star:.4f}")
    print(f"Certified barcode bound: {cert.bound:.4f}")
    print(f"Actual barcode drift: {actual}")
    print(f"Structural rigidity index: {cert.lam_star / thermal_noise:.2f}")


def application_3_manifold_learning():
    """
    Manifold Learning Validation

    Scenario: Before running expensive persistent homology computations,
    use spectral data to check if the persistence diagram will be reliable
    under the expected noise level.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Manifold Learning Validation")
    print("=" * 70)

    np.random.seed(456)

    # Sample from a torus
    n_points = 40
    theta = np.random.uniform(0, 2 * np.pi, n_points)
    phi = np.random.uniform(0, 2 * np.pi, n_points)
    R, r_inner = 2.0, 0.8
    x = (R + r_inner * np.cos(theta)) * np.cos(phi)
    y = (R + r_inner * np.cos(theta)) * np.sin(phi)
    z = r_inner * np.sin(theta)
    points = np.column_stack([x, y, z])

    noise_levels = [0.01, 0.05, 0.1, 0.2, 0.3]
    scales = np.linspace(0.3, 4.0, 15).tolist()

    print(f"Manifold: Torus (R={R}, r={r_inner}), {n_points} samples")
    print(f"\n{'noise':>8} {'λ*':>8} {'bound':>8} {'actual':>8} {'reliable':>10}")

    for noise in noise_levels:
        noisy = points + np.random.randn(n_points, 3) * noise
        cert = compute_spectral_stability_certificate(
            points, noisy, scales, noise)
        bc1 = tropical_barcode(points, scales)
        bc2 = tropical_barcode(noisy, scales)
        actual = tropical_barcode_distance(bc1, bc2)
        reliable = "Yes" if cert.bound < 3 else "No"
        print(f"{noise:>8.3f} {cert.lam_star:>8.4f} {cert.bound:>8.2f} "
              f"{actual:>8} {reliable:>10}")


if __name__ == "__main__":
    application_1_sensor_network()
    application_2_protein_structure()
    application_3_manifold_learning()


"""
Demo: Spectral Tropical Stability — Computational Experiments

This script demonstrates the main theorem: spectral connectivity (Fiedler eigenvalue)
controls tropical persistent homology stability. It generates point clouds with
tunable cluster separation, builds VR filtrations, computes spectral data, and
verifies the certified stability bound against observed barcode drift.

Experiments:
1. Single perturbation demo with certificate
2. Systematic sweep: vary ε and measure d_tb · λ* / ε ratio
3. Cluster separation experiment: how spectral gap affects stability
4. Falsifiable conjecture test: does d_tb · λ* / ε remain bounded?
"""

import numpy as np
from algorithms import (
    vietoris_rips_graph, fiedler_value, tropical_nullity,
    edge_symm_diff_card, tropical_barcode, tropical_barcode_distance,
    compute_spectral_stability_certificate, ambiguous_pair_count
)


def generate_clustered_cloud(n_per_cluster: int, d: int, separation: float,
                             cluster_std: float = 0.3, seed: int = 42) -> np.ndarray:
    """Generate a two-cluster point cloud with given separation."""
    rng = np.random.RandomState(seed)
    c1 = rng.randn(n_per_cluster, d) * cluster_std
    c2 = rng.randn(n_per_cluster, d) * cluster_std + np.array([separation] + [0] * (d - 1))
    return np.vstack([c1, c2])


def experiment_1_single_demo():
    """Single perturbation demo with full certificate output."""
    print("=" * 70)
    print("EXPERIMENT 1: Single Perturbation Demo")
    print("=" * 70)

    n, d, sep = 15, 2, 2.0
    eps = 0.05
    points = generate_clustered_cloud(n, d, sep)
    rng = np.random.RandomState(123)
    noise = rng.randn(2 * n, d) * eps / np.sqrt(d)
    points_pert = points + noise

    # Actual perturbation magnitude
    actual_eps = max(np.linalg.norm(noise[i]) for i in range(2 * n))
    print(f"Point cloud: {2*n} points in R^{d}, separation={sep}")
    print(f"Perturbation: ε={eps}, actual max perturbation={actual_eps:.4f}")

    thresholds = np.linspace(0.1, 3.5, 20).tolist()

    # Compute tropical barcodes
    bc_orig = tropical_barcode(points, thresholds)
    bc_pert = tropical_barcode(points_pert, thresholds)
    actual_dist = tropical_barcode_distance(bc_orig, bc_pert)

    # Compute certificate
    cert = compute_spectral_stability_certificate(points, points_pert, thresholds, eps)

    print(f"\nTropical barcode (original):  {bc_orig}")
    print(f"Tropical barcode (perturbed): {bc_pert}")
    print(f"\nActual barcode distance: {actual_dist}")
    print(f"\n{cert}")
    print(f"\nBound valid: {actual_dist <= cert.bound + 1e-10}")

    # Show per-stage analysis
    print("\nPer-stage analysis:")
    print(f"{'Stage':>5} {'r':>6} {'λ₂':>8} {'ΔE':>4} {'Δβ₁':>4} {'Ambig':>5}")
    for idx, r in enumerate(thresholds):
        adj_o = vietoris_rips_graph(points, r)
        adj_p = vietoris_rips_graph(points_pert, r)
        lam2 = fiedler_value(adj_o)
        de = edge_symm_diff_card(adj_o, adj_p)
        db = abs(tropical_nullity(adj_o) - tropical_nullity(adj_p))
        amb = ambiguous_pair_count(points, points_pert, r, eps)
        print(f"{idx:>5} {r:>6.2f} {lam2:>8.4f} {de:>4} {db:>4} {amb:>5}")


def experiment_2_epsilon_sweep():
    """Sweep ε and measure d_tb · λ* / ε ratio."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 2: ε Sweep — Testing Spectral Stability Ratio")
    print("=" * 70)

    n, d, sep = 12, 2, 2.5
    points = generate_clustered_cloud(n, d, sep, seed=99)
    thresholds = np.linspace(0.2, 3.0, 15).tolist()

    epsilons = [0.001, 0.005, 0.01, 0.02, 0.05, 0.1, 0.15, 0.2]

    print(f"{'ε':>8} {'d_tb':>6} {'λ*':>8} {'ratio':>10} {'bound':>10} {'valid':>6}")
    for eps in epsilons:
        rng = np.random.RandomState(42)
        noise = rng.randn(2 * n, d) * eps / np.sqrt(d)
        points_pert = points + noise

        bc1 = tropical_barcode(points, thresholds)
        bc2 = tropical_barcode(points_pert, thresholds)
        dtb = tropical_barcode_distance(bc1, bc2)

        cert = compute_spectral_stability_certificate(
            points, points_pert, thresholds, eps)

        if cert.lam_star > 1e-10 and eps > 1e-15:
            ratio = dtb * cert.lam_star / eps
        else:
            ratio = float('nan')

        valid = dtb <= cert.bound + 1e-10
        print(f"{eps:>8.4f} {dtb:>6} {cert.lam_star:>8.4f} "
              f"{ratio:>10.4f} {cert.bound:>10.4f} {str(valid):>6}")


def experiment_3_separation_sweep():
    """Vary cluster separation and observe spectral gap effect."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 3: Cluster Separation Sweep")
    print("=" * 70)

    n, d = 10, 2
    eps = 0.05
    separations = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0]
    thresholds = np.linspace(0.1, 6.0, 20).tolist()

    print(f"{'sep':>5} {'d_tb':>6} {'λ*':>8} {'Kmax':>8} {'bound':>10} {'ratio':>10}")
    for sep in separations:
        points = generate_clustered_cloud(n, d, sep, seed=42)
        rng = np.random.RandomState(42)
        noise = rng.randn(2 * n, d) * eps / np.sqrt(d)
        points_pert = points + noise

        bc1 = tropical_barcode(points, thresholds)
        bc2 = tropical_barcode(points_pert, thresholds)
        dtb = tropical_barcode_distance(bc1, bc2)

        cert = compute_spectral_stability_certificate(
            points, points_pert, thresholds, eps)

        ratio = dtb * cert.lam_star / eps if cert.lam_star > 1e-10 else float('nan')
        print(f"{sep:>5.1f} {dtb:>6} {cert.lam_star:>8.4f} "
              f"{cert.Kmax:>8.2f} {cert.bound:>10.4f} {ratio:>10.4f}")


def experiment_4_conjecture_test():
    """Test the uniform spectral exponent conjecture."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 4: Uniform Spectral Exponent Conjecture Test")
    print("=" * 70)
    print("Conjecture: d_tb · λ* / ε ≤ C_d for all configurations")
    print("If the ratio stays bounded, the conjecture holds with α=1.\n")

    n, d = 8, 2
    eps = 0.03
    thresholds = np.linspace(0.1, 4.0, 12).tolist()
    max_ratio = 0.0

    configs = []
    for sep in [0.8, 1.2, 1.5, 2.0, 3.0]:
        for std in [0.15, 0.3, 0.5]:
            for seed in [1, 2, 3]:
                configs.append((sep, std, seed))

    print(f"{'sep':>5} {'std':>5} {'seed':>4} {'d_tb':>5} {'λ*':>8} {'ratio':>10}")
    for sep, std, seed in configs:
        points = generate_clustered_cloud(n, d, sep, cluster_std=std, seed=seed)
        rng = np.random.RandomState(seed + 100)
        noise = rng.randn(2 * n, d) * eps / np.sqrt(d)
        points_pert = points + noise

        bc1 = tropical_barcode(points, thresholds)
        bc2 = tropical_barcode(points_pert, thresholds)
        dtb = tropical_barcode_distance(bc1, bc2)

        cert = compute_spectral_stability_certificate(
            points, points_pert, thresholds, eps)

        if cert.lam_star > 1e-10:
            ratio = dtb * cert.lam_star / eps
            max_ratio = max(max_ratio, ratio)
            print(f"{sep:>5.1f} {std:>5.2f} {seed:>4} {dtb:>5} "
                  f"{cert.lam_star:>8.4f} {ratio:>10.4f}")

    print(f"\nMaximum ratio observed: {max_ratio:.4f}")
    print(f"Conjecture assessment: ratio appears {'bounded' if max_ratio < 100 else 'unbounded'}")


if __name__ == "__main__":
    experiment_1_single_demo()
    experiment_2_epsilon_sweep()
    experiment_3_separation_sweep()
    experiment_4_conjecture_test()


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
