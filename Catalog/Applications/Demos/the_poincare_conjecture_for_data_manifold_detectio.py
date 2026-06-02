#!/usr/bin/env python3
"""
Demo: Poincaré Threshold for Data — Manifold Detection via Persistent Homology

This script demonstrates the key ideas:
1. Sample point clouds from spheres of various dimensions
2. Compute the Rips filtration and Betti numbers
3. Detect the Poincaré threshold
4. Compare with theoretical scaling prediction ε* ~ C · d^{1/2} · n^{-1/d}
"""

import numpy as np
from algorithms import (
    sample_sphere,
    pairwise_distances,
    connectivity_threshold,
    rips_simplices,
    betti_numbers_from_simplices,
    poincare_threshold,
    theoretical_poincare_threshold,
    sphere_betti,
    euler_characteristic,
)


def demo_betti_numbers():
    """Demonstrate Betti number computation for point clouds on S^1 and S^2."""
    print("=" * 60)
    print("DEMO 1: Betti Numbers of Point Clouds on Spheres")
    print("=" * 60)

    for dim, n_points in [(1, 20), (2, 30)]:
        points = sample_sphere(n_points, dim)
        dist = pairwise_distances(points)

        print(f"\n--- S^{dim}: {n_points} points in R^{dim+1} ---")
        print(f"Target Betti signature: {sphere_betti(dim)}")

        # Try several epsilon values
        max_dist = np.max(dist)
        for frac in [0.2, 0.4, 0.6, 0.8, 1.0]:
            eps = frac * max_dist
            simplices = rips_simplices(dist, eps, max_dim=dim)
            betti = betti_numbers_from_simplices(simplices, max_dim=dim)
            n_edges = len(simplices.get(1, []))
            print(f"  ε = {eps:.3f} ({frac:.0%} of diam): "
                  f"β = {betti}, edges = {n_edges}, "
                  f"χ = {euler_characteristic(betti)}")


def demo_connectivity_threshold():
    """Demonstrate the connectivity threshold computation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Connectivity Threshold (MST bottleneck)")
    print("=" * 60)

    for dim in [1, 2, 3]:
        print(f"\n--- S^{dim} ---")
        for n_points in [10, 20, 50, 100]:
            points = sample_sphere(n_points, dim)
            dist = pairwise_distances(points)
            eps0 = connectivity_threshold(dist)
            theoretical = theoretical_poincare_threshold(n_points, dim)
            print(f"  n={n_points:3d}: ε₀ = {eps0:.4f}, "
                  f"theory = {theoretical:.4f}, "
                  f"ratio = {eps0/theoretical:.2f}")


def demo_poincare_threshold():
    """Demonstrate the Poincaré threshold detection."""
    print("\n" + "=" * 60)
    print("DEMO 3: Poincaré Threshold Detection")
    print("=" * 60)

    for dim in [1, 2]:
        print(f"\n--- Target: S^{dim} ---")
        for n_points in [12, 20, 30]:
            points = sample_sphere(n_points, dim)
            eps_star = poincare_threshold(points, dim, num_scales=50)
            theoretical = theoretical_poincare_threshold(n_points, dim)

            if eps_star is not None:
                print(f"  n={n_points:3d}: ε* = {eps_star:.4f}, "
                      f"theory = {theoretical:.4f}, "
                      f"ratio = {eps_star/theoretical:.2f}")
            else:
                print(f"  n={n_points:3d}: ε* not found (need finer grid)")


def demo_scaling_law():
    """Test the conjectured scaling law ε* ~ C · d^{1/2} · n^{-1/d}."""
    print("\n" + "=" * 60)
    print("DEMO 4: Scaling Law Verification")
    print("=" * 60)

    print("\nConnectivity threshold scaling (should be ~ n^{-1/d}):")
    for dim in [1, 2]:
        print(f"\n  S^{dim}:")
        thresholds = []
        ns = [10, 15, 20, 30, 50]
        for n in ns:
            eps_values = []
            for seed in range(5):
                points = sample_sphere(n, dim, seed=seed)
                dist = pairwise_distances(points)
                eps_values.append(connectivity_threshold(dist))
            mean_eps = np.mean(eps_values)
            thresholds.append(mean_eps)
            predicted = theoretical_poincare_threshold(n, dim)
            print(f"    n={n:3d}: ε₀ = {mean_eps:.4f} ± {np.std(eps_values):.4f}, "
                  f"predicted = {predicted:.4f}")

        # Fit power law
        log_n = np.log(ns)
        log_eps = np.log(thresholds)
        slope, intercept = np.polyfit(log_n, log_eps, 1)
        print(f"  Fitted exponent: {slope:.3f} (theory: {-1.0/dim:.3f})")


def demo_euler_characteristic():
    """Demonstrate the Euler characteristic of spheres."""
    print("\n" + "=" * 60)
    print("DEMO 5: Euler Characteristic of Spheres")
    print("=" * 60)

    for dim in range(1, 6):
        betti = sphere_betti(dim)
        chi = euler_characteristic(betti)
        formula = 1 + (-1) ** dim
        print(f"  S^{dim}: β = {betti}, χ = {chi}, "
              f"1 + (-1)^{dim} = {formula}, "
              f"{'EVEN' if dim % 2 == 0 else 'ODD'} dimension")


if __name__ == "__main__":
    demo_betti_numbers()
    demo_connectivity_threshold()
    demo_poincare_threshold()
    demo_scaling_law()
    demo_euler_characteristic()


#!/usr/bin/env python3
"""
Visualization: Poincaré Threshold Scaling Law

Plots the connectivity threshold vs n for different sphere dimensions,
comparing with the theoretical prediction ε* ~ C · d^{1/2} · n^{-1/d}.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def pairwise_distances(points):
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def connectivity_threshold(dist_matrix):
    n = dist_matrix.shape[0]
    if n <= 1:
        return 0.0
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((dist_matrix[i, j], i, j))
    edges.sort()
    parent = list(range(n))
    rank = [0] * n
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px == py: return False
        if rank[px] < rank[py]: px, py = py, px
        parent[py] = px
        if rank[px] == rank[py]: rank[px] += 1
        return True
    max_edge = 0.0
    added = 0
    for w, i, j in edges:
        if union(i, j):
            max_edge = w
            added += 1
            if added == n - 1: break
    return max_edge


def sample_sphere(n, d, seed=42):
    rng = np.random.default_rng(seed)
    points = rng.standard_normal((n, d + 1))
    norms = np.linalg.norm(points, axis=1, keepdims=True)
    return points / norms


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
dims = [1, 2, 3]
ns = [10, 15, 20, 30, 50, 75, 100]
n_trials = 10

for ax, dim in zip(axes, dims):
    mean_eps = []
    std_eps = []
    for n in ns:
        eps_vals = []
        for seed in range(n_trials):
            pts = sample_sphere(n, dim, seed=seed)
            dist = pairwise_distances(pts)
            eps_vals.append(connectivity_threshold(dist))
        mean_eps.append(np.mean(eps_vals))
        std_eps.append(np.std(eps_vals))

    ax.errorbar(ns, mean_eps, yerr=std_eps, fmt='o-', capsize=3, label='Measured ε₀')

    # Fit C · n^{-1/d}
    log_n = np.log(ns)
    log_eps = np.log(mean_eps)
    slope, intercept = np.polyfit(log_n, log_eps, 1)
    C_fit = np.exp(intercept)
    n_fine = np.linspace(8, 110, 100)
    ax.plot(n_fine, C_fit * n_fine ** slope, '--', color='red',
            label=f'Fit: {C_fit:.2f}·n^{{{slope:.3f}}}')
    ax.plot(n_fine, C_fit * n_fine ** (-1.0/dim), ':', color='green',
            label=f'Theory: C·n^{{{-1.0/dim:.3f}}}')

    ax.set_xlabel('Number of points n')
    ax.set_ylabel('Connectivity threshold ε₀')
    ax.set_title(f'S^{dim} (d={dim})')
    ax.legend(fontsize=8)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

plt.suptitle('Connectivity Threshold Scaling: ε₀ vs n for Sphere Point Clouds',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('scaling_law.png', dpi=150, bbox_inches='tight')
print("Saved scaling_law.png")
