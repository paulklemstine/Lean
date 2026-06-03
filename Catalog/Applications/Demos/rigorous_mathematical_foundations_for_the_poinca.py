"""
Demo: Poincaré Threshold Computation and Stability

Demonstrates the key concepts from the Poincaré threshold theory:
1. Rips graph construction at multiple scales
2. Connectivity threshold computation
3. Stability under perturbation (approximate isometry)
4. Edge count monotonicity
5. Covering number bounds
"""

import numpy as np
from algorithms import (
    rips_graph, connectivity_threshold, edge_count_profile,
    approx_isometry_distortion, covering_number
)


def sample_circle(n: int, noise: float = 0.0, rng=None) -> np.ndarray:
    """Sample n points from the unit circle with optional noise."""
    if rng is None:
        rng = np.random.default_rng(42)
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    points = np.column_stack([np.cos(theta), np.sin(theta)])
    if noise > 0:
        points += rng.normal(0, noise, points.shape)
    return points


def demo_rips_filtration():
    """Demo 1: Rips graph at multiple scales."""
    print("=" * 60)
    print("DEMO 1: Rips Graph Filtration")
    print("=" * 60)

    points = sample_circle(20)
    n = len(points)
    max_edges = n * (n - 1) // 2

    for eps in [0.1, 0.3, 0.5, 0.7, 1.0, 1.5, 2.0]:
        edges = rips_graph(points, eps)
        print(f"  ε = {eps:.1f}: {len(edges):3d} edges "
              f"({100 * len(edges) / max_edges:.1f}% of max)")
    print()


def demo_connectivity_threshold():
    """Demo 2: Connectivity threshold for various shapes."""
    print("=" * 60)
    print("DEMO 2: Connectivity Thresholds")
    print("=" * 60)

    rng = np.random.default_rng(42)

    # Circle
    circle = sample_circle(50)
    t_circle = connectivity_threshold(circle)
    print(f"  Circle (n=50):    threshold = {t_circle:.4f}")

    # Noisy circle
    noisy = sample_circle(50, noise=0.05, rng=rng)
    t_noisy = connectivity_threshold(noisy)
    print(f"  Noisy circle:     threshold = {t_noisy:.4f}")

    # Random points in unit square
    square = rng.uniform(0, 1, (50, 2))
    t_square = connectivity_threshold(square)
    print(f"  Random in [0,1]²: threshold = {t_square:.4f}")

    # Clustered points
    c1 = rng.normal([0, 0], 0.1, (25, 2))
    c2 = rng.normal([3, 0], 0.1, (25, 2))
    clustered = np.vstack([c1, c2])
    t_clustered = connectivity_threshold(clustered)
    print(f"  Two clusters:     threshold = {t_clustered:.4f}")
    print()


def demo_stability():
    """Demo 3: Stability of thresholds under perturbation."""
    print("=" * 60)
    print("DEMO 3: Stability Under Perturbation")
    print("=" * 60)

    rng = np.random.default_rng(42)
    points = sample_circle(40)
    t_orig = connectivity_threshold(points)
    print(f"  Original threshold: {t_orig:.4f}")

    for noise_level in [0.01, 0.05, 0.1, 0.2]:
        perturbed = points + rng.normal(0, noise_level, points.shape)

        # Identity map as approximate isometry
        delta = approx_isometry_distortion(points, perturbed, lambda x: x)
        t_pert = connectivity_threshold(perturbed)
        diff = abs(t_orig - t_pert)

        print(f"  Noise σ={noise_level:.2f}: threshold={t_pert:.4f}, "
              f"|Δt|={diff:.4f}, distortion δ={delta:.4f}, "
              f"|Δt|≤δ? {'✓' if diff <= delta + 1e-10 else '✗'}")
    print()


def demo_edge_monotonicity():
    """Demo 4: Edge count monotonicity."""
    print("=" * 60)
    print("DEMO 4: Edge Count Monotonicity")
    print("=" * 60)

    points = sample_circle(15)
    scales, counts = edge_count_profile(points, num_scales=20)

    # Verify monotonicity
    is_monotone = all(counts[i] <= counts[i + 1] for i in range(len(counts) - 1))
    print(f"  Edge count is monotone: {is_monotone}")

    for i in range(0, len(scales), 4):
        print(f"  ε = {scales[i]:.3f}: {counts[i]:3d} edges")
    print()


def demo_covering_bound():
    """Demo 5: Covering number as a function of scale."""
    print("=" * 60)
    print("DEMO 5: Covering Numbers")
    print("=" * 60)

    rng = np.random.default_rng(42)
    points = sample_circle(100)

    for eps in [0.1, 0.2, 0.5, 1.0, 2.0]:
        cn = covering_number(points, eps)
        print(f"  ε = {eps:.1f}: covering number ≤ {cn}")

    # Diameter bound: connectivity threshold ≤ diameter
    from scipy.spatial.distance import pdist
    diam = pdist(points).max()
    t = connectivity_threshold(points)
    print(f"\n  Diameter = {diam:.4f}")
    print(f"  Connectivity threshold = {t:.4f}")
    print(f"  Threshold ≤ diameter: {'✓' if t <= diam + 1e-10 else '✗'}")
    print()


if __name__ == "__main__":
    print("\n  Poincaré Threshold for Data: Numerical Demonstrations\n")
    demo_rips_filtration()
    demo_connectivity_threshold()
    demo_stability()
    demo_edge_monotonicity()
    demo_covering_bound()
    print("All demos completed successfully.")


"""
Visualization: Rips Filtration and Poincaré Threshold

Standalone matplotlib visualization showing the Rips graph at multiple scales,
edge count profile, and connectivity threshold.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial.distance import pdist, squareform


def sample_circle(n, noise=0.0, seed=42):
    rng = np.random.default_rng(seed)
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    pts = np.column_stack([np.cos(theta), np.sin(theta)])
    if noise > 0:
        pts += rng.normal(0, noise, pts.shape)
    return pts


def rips_edges(points, eps):
    n = len(points)
    D = squareform(pdist(points))
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if D[i, j] <= eps:
                edges.append((i, j))
    return edges


def connected_components_count(n, edges):
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    for i, j in edges:
        union(i, j)
    return len(set(find(i) for i in range(n)))


def connectivity_threshold(points):
    n = len(points)
    D = squareform(pdist(points))
    weights = sorted(set(D[i, j] for i in range(n) for j in range(i+1, n)))
    for w in weights:
        edges = rips_edges(points, w)
        if connected_components_count(n, edges) == 1:
            return w
    return weights[-1] if weights else 0.0


def main():
    n_pts = 30
    points = sample_circle(n_pts, noise=0.08, seed=42)
    threshold = connectivity_threshold(points)

    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle("Rips Filtration and Poincaré Threshold", fontsize=16, fontweight='bold')

    # Top row: Rips graphs at three scales
    scales = [0.2, threshold, 1.5]
    titles = [f"ε = 0.2 (below threshold)", f"ε = {threshold:.3f} (threshold)", f"ε = 1.5 (above)"]

    for ax, eps, title in zip(axes[0], scales, titles):
        edges = rips_edges(points, eps)
        n_comp = connected_components_count(n_pts, edges)

        for i, j in edges:
            ax.plot([points[i, 0], points[j, 0]], [points[i, 1], points[j, 1]],
                    'b-', alpha=0.3, linewidth=0.8)
        ax.scatter(points[:, 0], points[:, 1], c='red', s=30, zorder=5)
        ax.set_title(f"{title}\n{len(edges)} edges, {n_comp} components", fontsize=10)
        ax.set_aspect('equal')
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.grid(True, alpha=0.3)

    # Bottom left: edge count profile
    D = squareform(pdist(points))
    max_d = D.max()
    eps_range = np.linspace(0, max_d * 1.1, 200)
    edge_counts = []
    for eps in eps_range:
        count = sum(1 for i in range(n_pts) for j in range(i+1, n_pts) if D[i, j] <= eps)
        edge_counts.append(count)

    axes[1, 0].fill_between(eps_range, edge_counts, alpha=0.3, color='blue')
    axes[1, 0].plot(eps_range, edge_counts, 'b-', linewidth=1.5)
    axes[1, 0].axvline(threshold, color='red', linestyle='--', label=f'τ = {threshold:.3f}')
    axes[1, 0].set_xlabel('Scale ε')
    axes[1, 0].set_ylabel('Edge count')
    axes[1, 0].set_title('Edge Count (Monotone in ε)')
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)

    # Bottom center: connected components vs scale
    comp_counts = []
    for eps in eps_range:
        edges = rips_edges(points, eps)
        comp_counts.append(connected_components_count(n_pts, edges))

    axes[1, 1].plot(eps_range, comp_counts, 'g-', linewidth=2)
    axes[1, 1].axvline(threshold, color='red', linestyle='--', label=f'τ = {threshold:.3f}')
    axes[1, 1].axhline(1, color='gray', linestyle=':', alpha=0.5)
    axes[1, 1].set_xlabel('Scale ε')
    axes[1, 1].set_ylabel('Connected components')
    axes[1, 1].set_title('Components (Antitone in ε)')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)

    # Bottom right: stability demonstration
    noise_levels = np.linspace(0, 0.3, 50)
    thresholds = []
    rng = np.random.default_rng(123)
    for noise in noise_levels:
        perturbed = points + rng.normal(0, noise, points.shape)
        t = connectivity_threshold(perturbed)
        thresholds.append(t)

    axes[1, 2].plot(noise_levels, thresholds, 'purple', linewidth=2)
    axes[1, 2].fill_between(noise_levels, threshold - 2*noise_levels, threshold + 2*noise_levels,
                            alpha=0.15, color='red', label='±2σ stability band')
    axes[1, 2].axhline(threshold, color='red', linestyle='--', alpha=0.5, label=f'Original τ = {threshold:.3f}')
    axes[1, 2].set_xlabel('Perturbation σ')
    axes[1, 2].set_ylabel('Threshold')
    axes[1, 2].set_title('Stability Under Perturbation')
    axes[1, 2].legend(fontsize=8)
    axes[1, 2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('rips_filtration_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: rips_filtration_visualization.png")


if __name__ == "__main__":
    main()
