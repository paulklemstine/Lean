"""
Demo: Poincaré Conjecture for Data — Manifold Detection via Persistent Homology

Demonstrates:
1. Vietoris-Rips complex construction and filtration
2. Covering number estimation and scaling verification
3. The n^{-1/d} scaling law for detection thresholds
4. Comparison between sphere and non-sphere data
"""

import numpy as np
from algorithms import (
    sample_sphere, pairwise_distances,
    predicted_threshold, covering_number_estimate,
    vietoris_rips_edges, connected_components
)

np.random.seed(42)


def demo_rips_filtration():
    """Demonstrate the Rips filtration growing with epsilon."""
    print("=" * 70)
    print("VIETORIS-RIPS FILTRATION DEMO")
    print("=" * 70)

    n = 30
    points = sample_sphere(n, 1)  # Circle in R^2
    dist_mat = pairwise_distances(points)

    print(f"\n  {n} points on S^1 (circle):")
    print(f"  {'ε':>8s}  {'Edges':>6s}  {'Components':>11s}  {'Status':>20s}")
    print(f"  {'─'*8}  {'─'*6}  {'─'*11}  {'─'*20}")

    for eps_frac in [0.05, 0.1, 0.2, 0.3, 0.5, 0.8, 1.0, 1.5]:
        eps = eps_frac * 2  # Scale relative to diameter ≈ 2
        edges = vietoris_rips_edges(dist_mat, eps)
        comps = connected_components(n, edges)
        if comps > 1:
            status = "disconnected"
        elif comps == 1 and len(edges) < n * (n-1) // 2:
            status = "connected, sparse"
        else:
            status = "complete simplex"
        print(f"  {eps:8.3f}  {len(edges):6d}  {comps:11d}  {status:>20s}")


def demo_covering_numbers():
    """Demonstrate covering number estimation and scaling."""
    print("\n\n" + "=" * 70)
    print("COVERING NUMBER SCALING")
    print("=" * 70)

    for d in [1, 2]:
        print(f"\n  S^{d} covering numbers:")
        print(f"  {'ε':>8s}  {'N(S^d,ε)':>10s}  {'(1/ε)^d':>10s}  {'Ratio':>8s}")
        print(f"  {'─'*8}  {'─'*10}  {'─'*10}  {'─'*8}")

        n = 500
        points = sample_sphere(n, d)
        dist_mat = pairwise_distances(points)

        for eps in [0.3, 0.5, 0.8, 1.0, 1.3]:
            cov = covering_number_estimate(dist_mat, eps)
            predicted = (1.0 / eps) ** d
            ratio = cov / predicted if predicted > 0 else float('inf')
            print(f"  {eps:8.3f}  {cov:10d}  {predicted:10.1f}  {ratio:8.2f}")


def demo_scaling_law():
    """Verify the n^{-1/d} scaling law via covering numbers."""
    print("\n\n" + "=" * 70)
    print("SCALING LAW: ε* ~ n^{-1/d}")
    print("=" * 70)

    print("\n  The covering number N(S^d, ε) ≈ C · ε^{-d}")
    print("  So the minimum ε to cover with n points: ε ≈ C' · n^{-1/d}")

    for d in [1, 2, 3]:
        print(f"\n  Dimension d = {d}:")
        print(f"  {'n':>6s}  {'min ε-cover':>12s}  {'n^(-1/d)':>10s}  {'Ratio':>8s}")
        print(f"  {'─'*6}  {'─'*12}  {'─'*10}  {'─'*8}")

        ratios = []
        for n in [50, 100, 200, 400]:
            points = sample_sphere(n, d)
            dist_mat = pairwise_distances(points)

            # Find minimum epsilon such that covering number ≤ n
            # (binary search)
            lo, hi = 0.001, 2.0
            for _ in range(30):
                mid = (lo + hi) / 2
                if covering_number_estimate(dist_mat, mid) <= n:
                    hi = mid
                else:
                    lo = mid
            eps_star = hi

            scaling = n ** (-1.0 / d)
            ratio = eps_star / scaling
            ratios.append(ratio)
            print(f"  {n:6d}  {eps_star:12.4f}  {scaling:10.4f}  {ratio:8.4f}")

        print(f"  → Ratio stability: mean={np.mean(ratios):.3f}, std={np.std(ratios):.3f}")


def demo_predicted_threshold():
    """Compare predicted vs empirical threshold."""
    print("\n\n" + "=" * 70)
    print("PREDICTED POINCARÉ THRESHOLD")
    print("=" * 70)

    print("\n  Formula: ε* = C · √d · n^{-1/d}")
    print()

    for d in [1, 2, 3]:
        print(f"  d = {d}:")
        for n in [100, 500, 1000, 5000]:
            for C in [1.0, 1.5, 2.0]:
                eps = predicted_threshold(n, d, C)
                print(f"    n={n:5d}, C={C:.1f}: ε* = {eps:.6f}")
        print()


def demo_connectivity():
    """Demonstrate connectivity transition in the Rips complex."""
    print("\n\n" + "=" * 70)
    print("CONNECTIVITY TRANSITION")
    print("=" * 70)

    for d in [1, 2]:
        print(f"\n  S^{d} connectivity (n=100):")

        n = 100
        points = sample_sphere(n, d)
        dist_mat = pairwise_distances(points)

        # Find connectivity threshold
        all_dists = []
        for i in range(n):
            for j in range(i+1, n):
                all_dists.append(dist_mat[i, j])
        all_dists.sort()

        # The connectivity threshold is related to the longest edge
        # in the minimum spanning tree
        # Use union-find to find it
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
                return True
            return False

        connect_eps = 0
        edges_sorted = sorted(((dist_mat[i,j], i, j)
                               for i in range(n) for j in range(i+1, n)))
        for d_val, i, j in edges_sorted:
            if union(i, j):
                connect_eps = d_val

        scaling = n ** (-1.0 / d)
        print(f"    Connectivity threshold: ε_conn = {connect_eps:.4f}")
        print(f"    n^(-1/d)              :         {scaling:.4f}")
        print(f"    Ratio ε_conn/n^(-1/d) :         {connect_eps/scaling:.4f}")


def demo_non_manifold():
    """Compare sphere vs non-sphere data."""
    print("\n\n" + "=" * 70)
    print("SPHERE vs NON-MANIFOLD COMPARISON")
    print("=" * 70)

    n = 100

    # Sphere data
    sphere_pts = sample_sphere(n, 2)
    sphere_dist = pairwise_distances(sphere_pts)

    # Gaussian cloud (not a manifold)
    gauss_pts = np.random.randn(n, 3) * 0.5
    gauss_dist = pairwise_distances(gauss_pts)

    # Uniform cube (not a sphere)
    cube_pts = np.random.uniform(-1, 1, (n, 3))
    cube_dist = pairwise_distances(cube_pts)

    print(f"\n  Covering numbers at ε = 0.5:")
    for name, dist_mat in [("S² sphere", sphere_dist),
                           ("Gaussian cloud", gauss_dist),
                           ("Uniform cube", cube_dist)]:
        cov = covering_number_estimate(dist_mat, 0.5)
        edges = vietoris_rips_edges(dist_mat, 0.5)
        comps = connected_components(n, edges)
        print(f"    {name:20s}: N={cov:4d}, components={comps}, edges={len(edges)}")

    print(f"\n  Covering number profiles:")
    print(f"  {'ε':>6s}  {'S²':>6s}  {'Gauss':>6s}  {'Cube':>6s}")
    print(f"  {'─'*6}  {'─'*6}  {'─'*6}  {'─'*6}")
    for eps in [0.3, 0.5, 0.8, 1.0, 1.5]:
        n_sphere = covering_number_estimate(sphere_dist, eps)
        n_gauss = covering_number_estimate(gauss_dist, eps)
        n_cube = covering_number_estimate(cube_dist, eps)
        print(f"  {eps:6.2f}  {n_sphere:6d}  {n_gauss:6d}  {n_cube:6d}")


if __name__ == "__main__":
    demo_rips_filtration()
    demo_covering_numbers()
    demo_scaling_law()
    demo_predicted_threshold()
    demo_connectivity()
    demo_non_manifold()

    print("\n\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
  The Poincaré conjecture for data connects topology to statistics:
  - The Vietoris-Rips complex at scale ε captures topology
  - Covering numbers scale as N ~ ε^{-d} for d-manifolds
  - The detection threshold scales as ε* ~ n^{-1/d}
  - This scaling law is the topological curse of dimensionality
  - Non-manifold data has different covering profiles

  Machine-verified theorems in Lean 4:
  - Rips monotonicity (filtration property)
  - Nerve-Rips bridge (triangle inequality → edge inclusion)
  - Detection window theorem (connected interval)
  - Scaling law monotonicity
  - Diameter contractibility
    """)


"""
Visualization: Betti Number Evolution for Point Clouds on Spheres

Generates a plot showing how Betti numbers change as the scale parameter
epsilon varies in the Vietoris-Rips filtration. This visualizes the
"detection window" where sphere-like homology appears.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def pairwise_distances(points):
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def connected_components(n, edges):
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


def estimate_betti(dist_matrix, epsilon, max_dim=2):
    n = dist_matrix.shape[0]
    edges = [(i, j) for i in range(n) for j in range(i+1, n) if dist_matrix[i,j] <= epsilon]
    beta_0 = connected_components(n, edges)

    adj = {i: set() for i in range(n)}
    for i, j in edges:
        adj[i].add(j)
        adj[j].add(i)

    n_triangles = 0
    if max_dim >= 2:
        for i, j in edges:
            n_triangles += len(adj[i] & adj[j] - {i, j})
        n_triangles //= 3

    f0, f1, f2 = n, len(edges), n_triangles
    chi = f0 - f1 + f2
    beta_1 = max(0, beta_0 - chi)
    beta_2 = max(0, chi - beta_0 + beta_1)

    return [beta_0, beta_1, beta_2]


def sample_sphere(n, d):
    points = np.random.randn(n, d + 1)
    norms = np.linalg.norm(points, axis=1, keepdims=True)
    return points / norms


def main():
    np.random.seed(42)
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    for idx, (d, n) in enumerate([(1, 80), (2, 120)]):
        points = sample_sphere(n, d)
        dist_mat = pairwise_distances(points)
        max_dist = np.max(dist_mat)

        epsilons = np.linspace(0.01, max_dist * 0.9, 80)
        betti_vals = {k: [] for k in range(3)}

        for eps in epsilons:
            b = estimate_betti(dist_mat, eps, max_dim=2)
            for k in range(3):
                betti_vals[k].append(b[k] if k < len(b) else 0)

        ax = axes[idx]
        colors = ['#2196F3', '#FF5722', '#4CAF50']
        labels = [r'$\beta_0$', r'$\beta_1$', r'$\beta_2$']
        for k in range(min(3, d + 1)):
            ax.plot(epsilons, betti_vals[k], color=colors[k], linewidth=2,
                    label=labels[k])

        # Mark detection window
        sphere_eps = [eps for eps, b0, bd in zip(epsilons, betti_vals[0],
                      betti_vals[d]) if b0 == 1 and bd == 1]
        if sphere_eps:
            ax.axvspan(min(sphere_eps), max(sphere_eps), alpha=0.15,
                       color='gold', label='Detection window')
            ax.axvline(min(sphere_eps), color='gold', linestyle='--',
                       linewidth=1.5, alpha=0.7)

        ax.set_xlabel(r'Scale $\varepsilon$', fontsize=13)
        ax.set_ylabel('Betti number', fontsize=13)
        ax.set_title(f'Betti Evolution: {n} pts on $S^{d}$', fontsize=14)
        ax.legend(fontsize=11, loc='upper right')
        ax.set_ylim(-0.5, max(max(betti_vals[0]), 10) + 1)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_betti_evolution.png', dpi=150, bbox_inches='tight')
    print("Saved viz_betti_evolution.png")


if __name__ == "__main__":
    main()
