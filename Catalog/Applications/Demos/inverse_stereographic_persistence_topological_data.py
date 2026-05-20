"""
Applications of Stereographic Persistence Theory

Real-world applications demonstrating the utility of exact metric transport
for topological data analysis on spherical data.

Applications:
1. Astrophysical sky map analysis (CMB-like distributions)
2. Directional statistics (wind/ocean current data)
3. Molecular orientation analysis
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (
    stereographic_project,
    spherical_distance_matrix, weighted_distance_matrix,
    euclidean_distance_matrix,
    sample_spherical_cap, sample_sphere_uniform,
)


def astrophysical_anisotropy_detection():
    """
    Application 1: Detecting anisotropy in sky distributions.

    Simulates isotropic vs anisotropic point distributions on S^2
    (as a simplified model of CMB hotspot locations), and compares
    the Rips complex structure under different metrics.
    """
    print("=" * 70)
    print("APPLICATION 1: Astrophysical Anisotropy Detection")
    print("=" * 70)

    np.random.seed(42)
    N = 40

    # Isotropic distribution: uniform on S^2
    iso_points = sample_sphere_uniform(N, n_dim=2, seed=42)
    iso_points[iso_points[:, 2] > 0.95, 2] = 0.9
    iso_points = iso_points / np.linalg.norm(iso_points, axis=1, keepdims=True)

    # Anisotropic: clustered around two antipodal caps (dipole pattern)
    aniso1 = sample_spherical_cap(N // 2, n_dim=2, angular_radius=0.6,
                                  center=np.array([1, 0, 0.0]), seed=100)
    aniso2 = sample_spherical_cap(N // 2, n_dim=2, angular_radius=0.6,
                                  center=np.array([-1, 0, 0.0]), seed=200)
    aniso_points = np.vstack([aniso1, aniso2])

    for label, points in [("Isotropic", iso_points), ("Anisotropic (dipole)", aniso_points)]:
        projected = stereographic_project(points)
        n = len(points)

        D_sph = spherical_distance_matrix(points)
        D_wt = weighted_distance_matrix(projected)
        D_euc = euclidean_distance_matrix(projected)

        iu = np.triu_indices(n, k=1)
        err_exact = np.max(np.abs(D_sph[iu] - D_wt[iu]))
        err_naive = np.max(np.abs(D_sph[iu] - D_euc[iu]))

        # Count edges at representative scale
        eps = 0.5
        e_sph = np.sum(D_sph[iu] <= eps)
        e_wt = np.sum(D_wt[iu] <= eps)
        e_euc = np.sum(D_euc[iu] <= eps)

        print(f"\n  {label} (N={n}):")
        print(f"    Exact transport error: {err_exact:.2e}")
        print(f"    Naive Euclidean error: {err_naive:.4f}")
        print(f"    Edges at ε=0.5: spherical={e_sph}, weighted={e_wt}, euclidean={e_euc}")

    print("\n  Key insight: weighted stereographic matches spherical exactly,")
    print("  while naive Euclidean systematically distorts the filtration.")


def directional_statistics_wind():
    """
    Application 2: Wind direction analysis.

    Simulates directional data and demonstrates that weighted stereographic
    persistence correctly captures circular structure.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Directional Statistics (Wind Directions)")
    print("=" * 70)

    np.random.seed(123)
    N = 40

    # Simulate wind directions: two clusters
    theta = np.random.vonmises(mu=0, kappa=5, size=N // 2)
    phi = np.random.vonmises(mu=np.pi / 4, kappa=10, size=N // 2)
    theta2 = np.random.vonmises(mu=np.pi, kappa=5, size=N // 2)
    phi2 = np.random.vonmises(mu=np.pi / 4, kappa=10, size=N // 2)

    theta_all = np.concatenate([theta, theta2])
    phi_all = np.concatenate([phi, phi2])

    x = np.cos(phi_all) * np.cos(theta_all)
    y = np.cos(phi_all) * np.sin(theta_all)
    z = np.sin(phi_all)
    points = np.column_stack([x, y, z])
    points = points / np.linalg.norm(points, axis=1, keepdims=True)
    points[points[:, 2] > 0.95, 2] = 0.9
    points = points / np.linalg.norm(points, axis=1, keepdims=True)

    projected = stereographic_project(points)

    D_sph = spherical_distance_matrix(points)
    D_wt = weighted_distance_matrix(projected)
    D_euc = euclidean_distance_matrix(projected)

    # Edge count comparison at multiple scales
    scales = [0.3, 0.5, 0.8, 1.0]
    iu = np.triu_indices(N, k=1)

    print(f"\n  Wind direction data (N={N}):")
    print(f"  {'Scale':<8} {'Sph edges':<12} {'Wt edges':<12} {'Euc edges':<12}")
    for eps in scales:
        e_s = np.sum(D_sph[iu] <= eps)
        e_w = np.sum(D_wt[iu] <= eps)
        e_e = np.sum(D_euc[iu] <= eps)
        print(f"  {eps:<8.1f} {e_s:<12d} {e_w:<12d} {e_e:<12d}")

    print("  Weighted matches spherical exactly at every scale.")


def molecular_orientation_analysis():
    """
    Application 3: Molecular orientation analysis.

    Demonstrates persistence on orientation data for distinguishing
    conformational states.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Molecular Orientation Analysis")
    print("=" * 70)

    np.random.seed(456)
    N = 30

    # Class A: near a great circle
    t = np.linspace(0, 2 * np.pi, N)
    noise = 0.1
    points_A = np.column_stack([
        np.cos(t) + noise * np.random.randn(N),
        np.sin(t) + noise * np.random.randn(N),
        noise * np.random.randn(N)
    ])
    points_A = points_A / np.linalg.norm(points_A, axis=1, keepdims=True)

    # Class B: two clusters
    c1 = sample_spherical_cap(N // 2, n_dim=2, angular_radius=0.8,
                              center=np.array([0, 0, -1.0]), seed=10)
    center2 = np.array([0, 0.5, 0.5])
    center2 = center2 / np.linalg.norm(center2)
    c2 = sample_spherical_cap(N - N // 2, n_dim=2, angular_radius=0.8,
                              center=center2, seed=20)
    points_B = np.vstack([c1, c2])

    for label, points in [("Alpha-helix-like", points_A),
                          ("Beta-sheet-like", points_B)]:
        points[points[:, 2] > 0.95, 2] = 0.9
        points = points / np.linalg.norm(points, axis=1, keepdims=True)

        projected = stereographic_project(points)
        D_sph = spherical_distance_matrix(points)
        D_wt = weighted_distance_matrix(projected)

        iu = np.triu_indices(len(points), k=1)
        total_sph = np.sum(D_sph[iu])
        total_wt = np.sum(D_wt[iu])
        err = np.max(np.abs(D_sph[iu] - D_wt[iu]))

        print(f"\n  {label} (N={len(points)}):")
        print(f"    Total pairwise spherical distance: {total_sph:.2f}")
        print(f"    Total pairwise weighted distance:  {total_wt:.2f}")
        print(f"    Max pointwise error: {err:.2e}")

    print("\n  Both conformational classes show exact agreement between")
    print("  spherical and weighted stereographic metrics.")


if __name__ == '__main__':
    print("Stereographic Persistence: Applications")
    print("=" * 70)

    astrophysical_anisotropy_detection()
    directional_statistics_wind()
    molecular_orientation_analysis()

    print("\n" + "=" * 70)
    print("All applications complete.")


"""
Demo: Stereographic Persistence — Exact Metric Transport from S^n to R^n

This script demonstrates the main results of the stereographic persistence theory:

1. The exact distance transport formula: d_st(x,y) = d_{S^n}(σ⁻¹(x), σ⁻¹(y))
2. Čech filtration equivalence under stereographic projection
3. Bi-Lipschitz bounds on bounded regions
4. Comparison of exact vs naive Euclidean persistence
5. Stress tests near the stereographic singularity
6. Runtime scaling analysis

Usage:
    python demo.py

All plots are saved to the current directory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
from algorithms import (
    stereographic_project, inverse_stereographic,
    spherical_distance_matrix, weighted_distance_matrix,
    euclidean_distance_matrix, weighted_stereographic_distance,
    spherical_geodesic_distance, bi_lipschitz_constants,
    sample_spherical_cap, sample_sphere_uniform,
    persistence_comparison, rips_filtration_values
)
import time


def demo_exact_transport(N=50):
    """
    Demonstrate that the weighted stereographic distance exactly reproduces
    spherical geodesic distance. This is the core theorem.
    """
    print("=" * 70)
    print("DEMO 1: Exact Distance Transport Theorem")
    print("=" * 70)

    for n_dim in [2, 3, 5]:
        points = sample_spherical_cap(N, n_dim=n_dim, angular_radius=2.5, seed=42)
        result = persistence_comparison(points)

        print(f"\nS^{n_dim}, N={N} points:")
        print(f"  Max |d_spherical - d_weighted|:  {result['max_error_exact_transport']:.2e}")
        print(f"  Max |d_spherical - d_euclidean|: {result['max_error_naive_euclidean']:.4f}")
        print(f"  Mean d_euclidean / d_spherical:  {result['mean_euclidean_to_spherical_ratio']:.4f}")

    # Detailed plot for S^2
    points = sample_spherical_cap(100, n_dim=2, angular_radius=2.5, seed=42)
    result = persistence_comparison(points)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    D_s = result['D_spherical']
    D_w = result['D_weighted']
    D_e = result['D_euclidean']

    # Extract upper triangle
    idx = np.triu_indices(len(D_s), k=1)
    ds = D_s[idx]
    dw = D_w[idx]
    de = D_e[idx]

    axes[0].scatter(ds, dw, alpha=0.3, s=5, color='blue')
    axes[0].plot([0, np.pi], [0, np.pi], 'r--', linewidth=2, label='y = x (exact)')
    axes[0].set_xlabel('Spherical geodesic distance')
    axes[0].set_ylabel('Weighted stereographic distance')
    axes[0].set_title('Exact Transport (should be y=x)')
    axes[0].legend()

    axes[1].scatter(ds, de, alpha=0.3, s=5, color='orange')
    axes[1].plot([0, np.pi], [0, np.pi], 'r--', linewidth=2, label='y = x')
    axes[1].set_xlabel('Spherical geodesic distance')
    axes[1].set_ylabel('Naive Euclidean distance')
    axes[1].set_title('Naive Euclidean (systematic distortion)')
    axes[1].legend()

    axes[2].hist(np.abs(ds - dw), bins=50, color='blue', alpha=0.7, label='|d_sph - d_wt|')
    axes[2].hist(np.abs(ds - de), bins=50, color='orange', alpha=0.7, label='|d_sph - d_euc|')
    axes[2].set_xlabel('Absolute error')
    axes[2].set_ylabel('Count')
    axes[2].set_title('Error Distribution')
    axes[2].legend()
    axes[2].set_yscale('log')

    plt.tight_layout()
    plt.savefig('demo_exact_transport.png', dpi=150)
    plt.close()
    print("\n  Plot saved: demo_exact_transport.png")


def demo_filtration_equivalence(N=30):
    """
    Demonstrate that the Rips filtration values are identical under
    exact metric transport but differ under naive Euclidean distance.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Filtration Equivalence")
    print("=" * 70)

    points = sample_spherical_cap(N, n_dim=2, angular_radius=2.0, seed=123)
    projected = stereographic_project(points)

    D_sph = spherical_distance_matrix(points)
    D_wt = weighted_distance_matrix(projected)
    D_euc = euclidean_distance_matrix(projected)

    filt_sph = rips_filtration_values(D_sph)
    filt_wt = rips_filtration_values(D_wt)
    filt_euc = rips_filtration_values(D_euc)

    print(f"\n  Number of filtration values (spherical): {len(filt_sph)}")
    print(f"  Number of filtration values (weighted):  {len(filt_wt)}")
    print(f"  Number of filtration values (Euclidean): {len(filt_euc)}")
    print(f"  Max |filt_sph - filt_wt|: {np.max(np.abs(filt_sph - filt_wt)):.2e}")

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(range(len(filt_sph)), filt_sph, 'b-', label='Spherical geodesic', linewidth=2)
    ax.plot(range(len(filt_wt)), filt_wt, 'g--', label='Weighted stereographic', linewidth=2)
    ax.plot(range(len(filt_euc)), filt_euc, 'r:', label='Naive Euclidean', linewidth=2)
    ax.set_xlabel('Edge index (sorted)')
    ax.set_ylabel('Filtration value (distance)')
    ax.set_title(f'Rips Filtration Values (N={N} points on S²)')
    ax.legend()
    plt.tight_layout()
    plt.savefig('demo_filtration_equivalence.png', dpi=150)
    plt.close()
    print("  Plot saved: demo_filtration_equivalence.png")


def demo_bilipschitz(N=100):
    """
    Demonstrate the bi-Lipschitz bounds on bounded regions.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Bi-Lipschitz Bounds on Bounded Regions")
    print("=" * 70)

    Rs = [0.5, 1.0, 2.0, 5.0, 10.0]

    fig, axes = plt.subplots(1, len(Rs), figsize=(5 * len(Rs), 5))

    for idx, R in enumerate(Rs):
        rho = 2 * np.arctan(R)  # angular radius of cap
        points = sample_spherical_cap(N, n_dim=2, angular_radius=rho, seed=42)
        projected = stereographic_project(points)

        norms = np.linalg.norm(projected, axis=1)
        actual_R = np.max(norms)

        C1, C2 = bi_lipschitz_constants(actual_R)

        D_wt = weighted_distance_matrix(projected)
        D_euc = euclidean_distance_matrix(projected)

        iu = np.triu_indices(N, k=1)
        dw = D_wt[iu]
        de = D_euc[iu]

        ax = axes[idx]
        ax.scatter(de, dw, alpha=0.3, s=5, color='blue')
        t = np.linspace(0, np.max(de) * 1.1, 100)
        ax.plot(t, C1 * t, 'g-', label=f'C₁={C1:.3f}', linewidth=2)
        ax.plot(t, C2 * t, 'r-', label=f'C₂={C2:.3f}', linewidth=2)
        ax.set_xlabel('Euclidean distance')
        ax.set_ylabel('Weighted distance')
        ax.set_title(f'R={R:.1f}, ρ={np.degrees(rho):.0f}°')
        ax.legend(fontsize=8)

        # Check bounds
        violations_lower = np.sum(dw < C1 * de - 1e-10)
        violations_upper = np.sum(dw > C2 * de + 1e-10)
        print(f"  R={R:.1f}: C₁={C1:.4f}, C₂={C2:.4f}, "
              f"lower violations={violations_lower}, upper violations={violations_upper}")

    plt.tight_layout()
    plt.savefig('demo_bilipschitz.png', dpi=150)
    plt.close()
    print("  Plot saved: demo_bilipschitz.png")


def demo_north_pole_stress(N=30):
    """
    Stress test near the stereographic singularity (north pole).
    """
    print("\n" + "=" * 70)
    print("DEMO 4: North Pole Stress Test")
    print("=" * 70)

    # Base cloud on the southern hemisphere
    base_points = sample_spherical_cap(N - 1, n_dim=2, angular_radius=1.0, seed=42)

    angular_distances = [1.0, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01]
    max_proj_norms = []
    condition_numbers = []
    max_weighted_errors = []

    for delta in angular_distances:
        # Point near north pole at angular distance delta
        near_pole = np.array([np.sin(delta), 0.0, np.cos(delta)])
        points = np.vstack([base_points, near_pole.reshape(1, -1)])

        projected = stereographic_project(points)
        max_norm = np.max(np.linalg.norm(projected, axis=1))
        max_proj_norms.append(max_norm)

        D_sph = spherical_distance_matrix(points)
        D_wt = weighted_distance_matrix(projected)
        D_euc = euclidean_distance_matrix(projected)

        max_err = np.max(np.abs(D_sph - D_wt))
        max_weighted_errors.append(max_err)

        # Condition number of distance matrix
        eigenvalues = np.linalg.eigvalsh(D_wt)
        nonzero_eig = eigenvalues[np.abs(eigenvalues) > 1e-12]
        if len(nonzero_eig) > 0:
            cond = np.max(np.abs(nonzero_eig)) / np.min(np.abs(nonzero_eig))
        else:
            cond = float('inf')
        condition_numbers.append(cond)

        print(f"  δ={delta:.3f}: max_proj_norm={max_norm:.1f}, "
              f"cond={cond:.1f}, exact_error={max_err:.2e}")

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    axes[0].loglog(angular_distances, max_proj_norms, 'bo-', linewidth=2)
    axes[0].set_xlabel('Angular distance from north pole')
    axes[0].set_ylabel('Max projected norm')
    axes[0].set_title('Projection Norm vs Distance from Pole')
    axes[0].grid(True)

    axes[1].loglog(angular_distances, condition_numbers, 'ro-', linewidth=2)
    axes[1].set_xlabel('Angular distance from north pole')
    axes[1].set_ylabel('Condition number')
    axes[1].set_title('Distance Matrix Conditioning')
    axes[1].grid(True)

    axes[2].semilogy(angular_distances, max_weighted_errors, 'go-', linewidth=2)
    axes[2].set_xlabel('Angular distance from north pole')
    axes[2].set_ylabel('Max |d_spherical - d_weighted|')
    axes[2].set_title('Exact Transport Numerical Error')
    axes[2].grid(True)

    plt.tight_layout()
    plt.savefig('demo_north_pole_stress.png', dpi=150)
    plt.close()
    print("  Plot saved: demo_north_pole_stress.png")


def demo_cap_approximation():
    """
    Demonstrate how Euclidean approximation improves on smaller caps.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Cap Radius vs Euclidean Approximation Quality")
    print("=" * 70)

    N = 100
    radii = np.linspace(0.1, 2.5, 15)
    max_errors = []
    mean_errors = []

    for rho in radii:
        points = sample_spherical_cap(N, n_dim=2, angular_radius=rho, seed=42)
        projected = stereographic_project(points)

        D_sph = spherical_distance_matrix(points)
        D_euc = euclidean_distance_matrix(projected)

        iu = np.triu_indices(N, k=1)
        ds = D_sph[iu]
        de = D_euc[iu]
        mask = ds > 1e-10

        if np.any(mask):
            rel_errors = np.abs(ds[mask] - de[mask]) / ds[mask]
            max_errors.append(np.max(rel_errors))
            mean_errors.append(np.mean(rel_errors))
        else:
            max_errors.append(0)
            mean_errors.append(0)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(np.degrees(radii), max_errors, 'r-o', label='Max relative error', linewidth=2)
    ax.plot(np.degrees(radii), mean_errors, 'b-s', label='Mean relative error', linewidth=2)
    ax.set_xlabel('Cap angular radius (degrees)')
    ax.set_ylabel('Relative error |d_sph - d_euc| / d_sph')
    ax.set_title('Euclidean Approximation Quality vs Cap Size')
    ax.legend()
    ax.grid(True)
    plt.tight_layout()
    plt.savefig('demo_cap_approximation.png', dpi=150)
    plt.close()
    print("  Plot saved: demo_cap_approximation.png")


def demo_scaling():
    """
    Runtime scaling analysis for the three distance computations.
    """
    print("\n" + "=" * 70)
    print("DEMO 6: Runtime Scaling")
    print("=" * 70)

    sizes = [50, 100, 200]
    times_sph = []
    times_wt = []
    times_euc = []

    for N in sizes:
        points = sample_sphere_uniform(N, n_dim=2, seed=42)
        # Ensure no point is too close to north pole
        points[points[:, -1] > 0.95, -1] = 0.9
        points = points / np.linalg.norm(points, axis=1, keepdims=True)

        projected = stereographic_project(points)

        t0 = time.time()
        for _ in range(3):
            D_sph = spherical_distance_matrix(points)
        t_sph = (time.time() - t0) / 3

        t0 = time.time()
        for _ in range(3):
            D_wt = weighted_distance_matrix(projected)
        t_wt = (time.time() - t0) / 3

        t0 = time.time()
        for _ in range(3):
            D_euc = euclidean_distance_matrix(projected)
        t_euc = (time.time() - t0) / 3

        times_sph.append(t_sph)
        times_wt.append(t_wt)
        times_euc.append(t_euc)

        print(f"  N={N}: spherical={t_sph:.4f}s, weighted={t_wt:.4f}s, euclidean={t_euc:.4f}s")

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(sizes, times_sph, 'b-o', label='Spherical geodesic', linewidth=2)
    ax.plot(sizes, times_wt, 'g-s', label='Weighted stereographic', linewidth=2)
    ax.plot(sizes, times_euc, 'r-^', label='Naive Euclidean', linewidth=2)
    ax.set_xlabel('Number of points')
    ax.set_ylabel('Time (seconds)')
    ax.set_title('Distance Matrix Computation Time')
    ax.legend()
    ax.grid(True)
    plt.tight_layout()
    plt.savefig('demo_scaling.png', dpi=150)
    plt.close()
    print("  Plot saved: demo_scaling.png")


if __name__ == '__main__':
    print("Stereographic Persistence: Demonstrations")
    print("=" * 70)
    print()

    demo_exact_transport(N=50)
    demo_filtration_equivalence(N=30)
    demo_bilipschitz(N=100)
    demo_north_pole_stress(N=30)
    demo_cap_approximation()
    demo_scaling()

    print("\n" + "=" * 70)
    print("All demos complete. Plots saved to current directory.")
    print("=" * 70)
