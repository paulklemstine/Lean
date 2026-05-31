"""
Stereographic Persistence Demo

Demonstrates the key results:
1. Conformal factor properties
2. Weighted vs unweighted Čech filtration interleaving
3. Persistence diagram comparison for spherical point clouds
"""

import numpy as np
from algorithms import (
    stereo_conformal_factor,
    stereo_weighted_dist,
    stereographic_project,
    inverse_stereographic,
    geodesic_dist,
    compute_pairwise_distances,
    vietoris_rips_persistence,
    compare_persistence_diagrams,
    stereo_persistence_interleaving_bound,
    generate_spherical_points,
)


def demo_conformal_factor():
    """Demonstrate properties of the stereographic conformal factor."""
    print("=" * 60)
    print("DEMO 1: Stereographic Conformal Factor Properties")
    print("=" * 60)

    # Property 1: w(0) = 2
    origin = np.zeros(3)
    w0 = stereo_conformal_factor(origin)
    print(f"\nw(0) = {w0:.6f} (should be 2.0)")

    # Property 2: w(x) ≤ 2 for all x
    print("\nConformal factor for random points (should all be ≤ 2):")
    np.random.seed(42)
    for _ in range(5):
        x = np.random.randn(3)
        w = stereo_conformal_factor(x)
        print(f"  x = [{x[0]:.3f}, {x[1]:.3f}, {x[2]:.3f}], ||x|| = {np.linalg.norm(x):.3f}, w(x) = {w:.6f}")

    # Property 3: Monotone decreasing in norm
    print("\nMonotonicity (w decreases as ||x|| increases):")
    norms = [0, 0.5, 1.0, 2.0, 5.0, 10.0]
    for r in norms:
        x = np.array([r, 0, 0])
        w = stereo_conformal_factor(x)
        print(f"  ||x|| = {r:5.1f}, w(x) = {w:.6f}")

    # Property 4: Lower bound for bounded clouds
    R = 3.0
    c_min = 2.0 / (1.0 + R**2)
    print(f"\nFor R = {R}: c_min = 2/(1+R²) = {c_min:.6f}")
    print(f"All points with ||x|| ≤ {R} have w(x) ≥ {c_min:.6f}")


def demo_weighted_distance():
    """Demonstrate weighted distance properties."""
    print("\n" + "=" * 60)
    print("DEMO 2: Weighted Distance Bounds")
    print("=" * 60)

    np.random.seed(123)
    x = np.random.randn(3)
    y = np.random.randn(3)
    eucl_dist = np.linalg.norm(x - y)
    w_dist = stereo_weighted_dist(x, y)

    print(f"\nPoints: x = {x}, y = {y}")
    print(f"Euclidean distance: {eucl_dist:.6f}")
    print(f"Weighted distance:  {w_dist:.6f}")
    print(f"Ratio w_dist/eucl:  {w_dist/eucl_dist:.6f}")
    print(f"Upper bound (4x):   {4*eucl_dist:.6f}")
    print(f"w_dist ≤ 4·eucl? {w_dist <= 4*eucl_dist}")

    # Symmetry
    w_dist_rev = stereo_weighted_dist(y, x)
    print(f"\nSymmetry: d_w(x,y) = {w_dist:.10f}")
    print(f"          d_w(y,x) = {w_dist_rev:.10f}")
    print(f"          Equal? {abs(w_dist - w_dist_rev) < 1e-14}")


def demo_persistence_comparison():
    """Compare persistence diagrams for spherical point clouds."""
    print("\n" + "=" * 60)
    print("DEMO 3: Persistence Diagram Comparison")
    print("=" * 60)

    for N in [20, 50, 100]:
        print(f"\n--- N = {N} points on S² ---")

        # Generate points on S²
        sphere_pts = generate_spherical_points(N, dim=2, seed=42)

        # Project to R²
        proj_pts = np.array([stereographic_project(p) for p in sphere_pts])

        # Filter out any points near the north pole (infinite projection)
        valid = np.all(np.isfinite(proj_pts), axis=1)
        sphere_pts = sphere_pts[valid]
        proj_pts = proj_pts[valid]
        N_valid = len(sphere_pts)
        print(f"  Valid points: {N_valid}")

        # Compute geodesic distance matrix
        D_geo = compute_pairwise_distances(sphere_pts, metric='geodesic')

        # Compute Euclidean distance matrix in R²
        D_eucl = compute_pairwise_distances(proj_pts, metric='euclidean')

        # Compute weighted distance matrix
        weights = np.array([stereo_conformal_factor(p) for p in proj_pts])
        D_weighted = np.zeros((N_valid, N_valid))
        for i in range(N_valid):
            for j in range(i + 1, N_valid):
                d_w = weights[i] * weights[j] * np.linalg.norm(proj_pts[i] - proj_pts[j])
                D_weighted[i, j] = d_w
                D_weighted[j, i] = d_w

        # Compute persistence for each
        pers_geo = vietoris_rips_persistence(D_geo, max_epsilon=np.pi)
        pers_eucl = vietoris_rips_persistence(D_eucl, max_epsilon=20.0)
        pers_weighted = vietoris_rips_persistence(D_weighted, max_epsilon=20.0)

        # Compare
        diff_geo_weighted, close_gw = compare_persistence_diagrams(
            pers_geo, pers_weighted, threshold=0.5)
        diff_eucl_weighted, close_ew = compare_persistence_diagrams(
            pers_eucl, pers_weighted, threshold=0.5)

        print(f"  |pers_geo - pers_weighted| = {diff_geo_weighted:.6f}")
        print(f"  |pers_eucl - pers_weighted| = {diff_eucl_weighted:.6f}")

        # Significant features
        sig_geo = sum(1 for p in pers_geo if p.is_significant(0.1))
        sig_weighted = sum(1 for p in pers_weighted if p.is_significant(0.1))
        print(f"  Significant features (geo): {sig_geo}")
        print(f"  Significant features (weighted): {sig_weighted}")


def demo_interleaving_bounds():
    """Demonstrate the interleaving bounds."""
    print("\n" + "=" * 60)
    print("DEMO 4: Interleaving Bounds")
    print("=" * 60)

    for R in [1.0, 2.0, 5.0, 10.0]:
        epsilon = 1.0
        fwd, rev = stereo_persistence_interleaving_bound(R, epsilon)
        ratio = rev / fwd
        print(f"\n  R = {R:5.1f}: forward ε/c²_max = {fwd:.6f}, "
              f"reverse ε/c²_min = {rev:.6f}, ratio = {ratio:.2f}")


def demo_separation_bound():
    """Test the conjecture on separation bounds."""
    print("\n" + "=" * 60)
    print("DEMO 5: Separation Bound Conjecture Test")
    print("=" * 60)

    for N in [50, 100, 200]:
        sphere_pts = generate_spherical_points(N, dim=2, seed=42)
        proj_pts = np.array([stereographic_project(p) for p in sphere_pts])
        valid = np.all(np.isfinite(proj_pts), axis=1)
        proj_pts = proj_pts[valid]
        N_valid = len(proj_pts)

        # Compute norms and minimum separation
        norms = np.linalg.norm(proj_pts, axis=1)
        R = np.max(norms)

        min_sep = np.inf
        min_weighted = np.inf
        for i in range(N_valid):
            for j in range(i + 1, N_valid):
                d = np.linalg.norm(proj_pts[i] - proj_pts[j])
                dw = stereo_weighted_dist(proj_pts[i], proj_pts[j])
                if d < min_sep:
                    min_sep = d
                if dw < min_weighted:
                    min_weighted = dw

        c_min = 2.0 / (1.0 + R**2)
        predicted_bound = min_sep * c_min**2

        print(f"\n  N = {N}: R = {R:.4f}, δ = {min_sep:.6f}")
        print(f"    c_min = {c_min:.6f}")
        print(f"    Predicted bound: δ·c²_min = {predicted_bound:.8f}")
        print(f"    Actual min d_w:            {min_weighted:.8f}")
        print(f"    Conjecture holds? {min_weighted >= predicted_bound - 1e-12}")


if __name__ == "__main__":
    demo_conformal_factor()
    demo_weighted_distance()
    demo_persistence_comparison()
    demo_interleaving_bounds()
    demo_separation_bound()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Stereographic Conformal Factor and Weighted Distance

Self-contained script generating plots of the conformal weight function
and distance distortion under stereographic projection.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def stereo_conformal_factor(x):
    """w(x) = 2/(1 + ||x||²)"""
    return 2.0 / (1.0 + np.sum(x**2, axis=-1))


def main():
    fig = plt.figure(figsize=(14, 10))
    gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

    # Plot 1: Conformal factor as function of norm
    ax1 = fig.add_subplot(gs[0, 0])
    r = np.linspace(0, 5, 200)
    w = 2.0 / (1.0 + r**2)
    ax1.plot(r, w, 'b-', linewidth=2, label=r'$w(r) = \frac{2}{1+r^2}$')
    ax1.axhline(y=2, color='r', linestyle='--', alpha=0.5, label='Upper bound (2)')
    ax1.fill_between(r, 0, w, alpha=0.15, color='blue')
    ax1.set_xlabel(r'$\|x\|$', fontsize=12)
    ax1.set_ylabel(r'$w(x)$', fontsize=12)
    ax1.set_title('Stereographic Conformal Factor', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 2.3)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Conformal factor heatmap in 2D
    ax2 = fig.add_subplot(gs[0, 1])
    x_grid = np.linspace(-4, 4, 200)
    y_grid = np.linspace(-4, 4, 200)
    X, Y = np.meshgrid(x_grid, y_grid)
    points = np.stack([X, Y], axis=-1)
    W = stereo_conformal_factor(points)
    im = ax2.pcolormesh(X, Y, W, shading='auto', cmap='viridis')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('y', fontsize=12)
    ax2.set_title('Conformal Weight on ℝ²', fontsize=13)
    ax2.set_aspect('equal')
    plt.colorbar(im, ax=ax2, label=r'$w(x)$')

    # Plot 3: Distance distortion ratio
    ax3 = fig.add_subplot(gs[1, 0])
    np.random.seed(42)
    n_pairs = 500
    pts = np.random.randn(n_pairs * 2, 2) * 2
    eucl_dists = []
    weighted_dists = []
    norms = []
    for k in range(n_pairs):
        x, y = pts[2*k], pts[2*k+1]
        d_e = np.linalg.norm(x - y)
        w_x = stereo_conformal_factor(x)
        w_y = stereo_conformal_factor(y)
        d_w = w_x * w_y * d_e
        eucl_dists.append(d_e)
        weighted_dists.append(d_w)
        norms.append(max(np.linalg.norm(x), np.linalg.norm(y)))

    eucl_dists = np.array(eucl_dists)
    weighted_dists = np.array(weighted_dists)
    norms = np.array(norms)

    sc = ax3.scatter(eucl_dists, weighted_dists, c=norms, cmap='coolwarm',
                     s=10, alpha=0.6)
    ax3.plot([0, max(eucl_dists)], [0, 4*max(eucl_dists)], 'r--', alpha=0.3,
             label=r'$4 \cdot d_E$ bound')
    ax3.set_xlabel(r'Euclidean distance $d_E$', fontsize=12)
    ax3.set_ylabel(r'Weighted distance $d_w$', fontsize=12)
    ax3.set_title('Distance Distortion', fontsize=13)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)
    plt.colorbar(sc, ax=ax3, label=r'max $\|x\|$')

    # Plot 4: Interleaving ratio vs R
    ax4 = fig.add_subplot(gs[1, 1])
    R_vals = np.linspace(0.1, 10, 200)
    c_min = 2.0 / (1.0 + R_vals**2)
    c_max = 2.0
    ratio = (c_max / c_min)**2
    ax4.semilogy(R_vals, ratio, 'b-', linewidth=2)
    ax4.axhline(y=1, color='g', linestyle='--', alpha=0.5, label='Exact isometry')
    ax4.set_xlabel(r'$R$ (norm bound)', fontsize=12)
    ax4.set_ylabel('Interleaving ratio', fontsize=12)
    ax4.set_title('Persistence Interleaving Quality', fontsize=13)
    ax4.legend(fontsize=10)
    ax4.grid(True, alpha=0.3)

    plt.suptitle('Stereographic Persistence: Conformal Analysis',
                 fontsize=15, fontweight='bold', y=0.98)
    plt.savefig('stereo_persistence_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: stereo_persistence_analysis.png")


if __name__ == "__main__":
    main()


"""
Visualization: Persistence Diagram Comparison

Self-contained script comparing persistence diagrams computed with
geodesic, Euclidean, and conformally weighted distances.
"""

import numpy as np
import matplotlib.pyplot as plt


def stereo_conformal_factor(x):
    return 2.0 / (1.0 + np.sum(x**2, axis=-1))


def stereographic_project(p):
    n = len(p) - 1
    denom = 1.0 - p[-1]
    if abs(denom) < 1e-15:
        return np.full(n, np.inf)
    return p[:n] / denom


def geodesic_dist(p, q):
    dot = np.clip(np.dot(p, q), -1.0, 1.0)
    return np.arccos(dot)


def generate_spherical_points(n_points, dim=2, seed=None):
    if seed is not None:
        np.random.seed(seed)
    points = np.random.randn(n_points, dim + 1)
    norms = np.linalg.norm(points, axis=1, keepdims=True)
    return points / norms


def vietoris_rips_h0(dist_matrix):
    n = len(dist_matrix)
    parent = list(range(n))
    pairs = []

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        parent[rx] = ry
        return True

    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((dist_matrix[i, j], i, j))
    edges.sort()

    for dist, i, j in edges:
        if union(i, j):
            pairs.append((0.0, dist / 2.0))

    return pairs


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    N = 60
    sphere_pts = generate_spherical_points(N, dim=2, seed=42)
    proj_pts = np.array([stereographic_project(p) for p in sphere_pts])
    valid = np.all(np.isfinite(proj_pts), axis=1)
    sphere_pts = sphere_pts[valid]
    proj_pts = proj_pts[valid]
    N_valid = len(sphere_pts)

    # Geodesic distances
    D_geo = np.zeros((N_valid, N_valid))
    for i in range(N_valid):
        for j in range(i+1, N_valid):
            d = geodesic_dist(sphere_pts[i], sphere_pts[j])
            D_geo[i, j] = d
            D_geo[j, i] = d

    # Euclidean distances
    D_eucl = np.zeros((N_valid, N_valid))
    for i in range(N_valid):
        for j in range(i+1, N_valid):
            d = np.linalg.norm(proj_pts[i] - proj_pts[j])
            D_eucl[i, j] = d
            D_eucl[j, i] = d

    # Weighted distances
    weights = np.array([stereo_conformal_factor(p) for p in proj_pts])
    D_weighted = np.zeros((N_valid, N_valid))
    for i in range(N_valid):
        for j in range(i+1, N_valid):
            d = weights[i] * weights[j] * np.linalg.norm(proj_pts[i] - proj_pts[j])
            D_weighted[i, j] = d
            D_weighted[j, i] = d

    # Persistence diagrams
    pairs_geo = vietoris_rips_h0(D_geo)
    pairs_eucl = vietoris_rips_h0(D_eucl)
    pairs_weighted = vietoris_rips_h0(D_weighted)

    for ax, pairs, title, color in [
        (axes[0], pairs_geo, 'Geodesic H₀', 'blue'),
        (axes[1], pairs_eucl, 'Euclidean H₀', 'red'),
        (axes[2], pairs_weighted, 'Weighted H₀', 'green')
    ]:
        births = [p[0] for p in pairs]
        deaths = [p[1] for p in pairs]
        max_val = max(deaths) if deaths else 1
        ax.scatter(births, deaths, c=color, s=20, alpha=0.7)
        ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.3)
        ax.set_xlabel('Birth', fontsize=11)
        ax.set_ylabel('Death', fontsize=11)
        ax.set_title(title, fontsize=13)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)

    plt.suptitle(f'Persistence Diagrams (N={N_valid} points on S²)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('persistence_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: persistence_comparison.png")


if __name__ == "__main__":
    main()
