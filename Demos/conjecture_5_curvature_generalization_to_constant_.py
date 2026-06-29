"""
Applications of Hyperbolic Conformal Packing Bounds

Demonstrates real-world applications of the certified packing inequality:
1. Capacity bounds for hyperbolic embeddings (ML / information geometry)
2. Entropy bounds for negative-curvature phase spaces (statistical mechanics)
3. Representation capacity of hierarchical data structures

Each application shows how the theorem provides quantitative guarantees
that are impossible in Euclidean space.
"""

import numpy as np
from algorithms import (
    poincare_cf, radial_distortion, euclidean_subball_radius,
    euclidean_ball_volume, certified_packing_bound,
    hyperbolic_weighted_volume_disk
)


def application_1_embedding_capacity():
    """Application: Capacity bounds for hyperbolic embeddings.

    In machine learning, hyperbolic embeddings represent hierarchical data
    (trees, taxonomies, knowledge graphs) by mapping nodes to points in
    the Poincaré disk. The key advantage: hyperbolic space has exponentially
    growing volume near the boundary, matching the exponential growth of trees.

    Our packing bound gives a CERTIFIED upper bound on how many distinguishable
    representations can fit in a given region of the Poincaré disk, where
    "distinguishable" means separated by at least hyperbolic distance 2r.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 1: Embedding Capacity for Hyperbolic Representations")
    print("=" * 70)

    print("\nScenario: Embedding a tree with branching factor b and depth d")
    print("into the Poincaré disk. Each node needs a ball of radius r.")
    print("Question: How large must the disk region be?\n")

    # For a b-ary tree of depth d, we need b^d leaf nodes
    print(f"  {'Depth':>6s}  {'Nodes':>8s}  {'ρ needed':>10s}  "
          f"{'Certified N':>12s}  {'Sufficient?':>11s}")
    print("  " + "-" * 55)

    b = 3  # branching factor
    r = 0.3  # separation radius

    for d in range(1, 9):
        num_nodes = sum(b**k for k in range(d + 1))  # total nodes in tree

        # Binary search for smallest ρ that can fit num_nodes
        rho_lo, rho_hi = 0.1, 0.999
        for _ in range(50):
            rho_mid = (rho_lo + rho_hi) / 2
            result = certified_packing_bound(2, rho_mid, r, num_samples=50000)
            if result['certified_packing_bound'] >= num_nodes:
                rho_hi = rho_mid
            else:
                rho_lo = rho_mid

        result = certified_packing_bound(2, rho_hi, r, num_samples=50000)
        sufficient = "✓" if result['certified_packing_bound'] >= num_nodes else "✗"

        print(f"  {d:6d}  {num_nodes:8d}  {rho_hi:10.4f}  "
              f"{result['certified_packing_bound']:12.0f}  {sufficient:>11s}")

    print(f"\n  Tree branching factor: b = {b}")
    print(f"  Hyperbolic separation radius: r = {r}")
    print(f"\n  Key insight: ρ approaches 1 slowly even as nodes grow exponentially.")
    print(f"  This confirms the exponential capacity advantage of hyperbolic space.")


def application_2_entropy_bounds():
    """Application: Entropy bounds for negative-curvature systems.

    In statistical mechanics on negatively curved spaces, the number of
    distinguishable microstates in a region is bounded by the packing number.
    Our theorem gives: S ≤ log₂(N) ≤ log₂(D · hvol / cell_vol).

    This separates the entropy into:
    - A volume term (extensive, proportional to hvol)
    - A distortion term (intensive, depends on curvature and location)
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Entropy Bounds in Negatively Curved Phase Space")
    print("=" * 70)

    print("\nMicrostates separated by hyperbolic distance 2r in phase space.")
    print("Entropy S ≤ log₂(N_max) gives certified upper bound.\n")

    r = 0.5  # microstate resolution
    print(f"  Microstate resolution: r = {r}")
    print(f"  {'ρ':>5s}  {'N_max':>12s}  {'S_max (bits)':>12s}  "
          f"{'S_Euclid':>10s}  {'Curvature gain':>14s}")
    print("  " + "-" * 60)

    for rho in [0.3, 0.5, 0.7, 0.9, 0.95, 0.99]:
        result = certified_packing_bound(2, rho, r, num_samples=100000)
        N_max = result['certified_packing_bound']
        S_max = np.log2(max(N_max, 1))

        # Compare with Euclidean: N_Euclid = vol(disk ρ) / vol(ball r)
        euclid_vol = np.pi * rho**2
        euclid_cell = np.pi * np.tanh(r / 2)**2  # Euclidean ball of tanh(r/2)
        N_euclid = euclid_vol / euclid_cell
        S_euclid = np.log2(max(N_euclid, 1))

        gain = S_max - S_euclid

        print(f"  {rho:5.2f}  {N_max:12.1f}  {S_max:12.2f}  "
              f"{S_euclid:10.2f}  {gain:+14.2f} bits")

    print("\n  The curvature gain increases dramatically near the boundary.")
    print("  Hyperbolic space stores exponentially more information peripherally.")


def application_3_hierarchical_resolution():
    """Application: Resolution limits for hierarchical data.

    Given a hyperbolic embedding with N items at resolution r,
    how many additional items can we add at finer resolution r' < r?
    The packing bound gives precise capacity at each resolution level.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Multi-Resolution Hierarchical Capacity")
    print("=" * 70)

    print("\nMulti-resolution analysis: how capacity grows as resolution increases.\n")

    rho = 0.9
    print(f"  Domain: B̄(0, {rho}) in the Poincaré disk")
    print(f"  {'Resolution r':>14s}  {'R(ρ,r)':>10s}  {'N_max':>10s}  "
          f"{'Marginal':>10s}  {'Density':>10s}")
    print("  " + "-" * 60)

    prev_N = 0
    for r in [2.0, 1.5, 1.0, 0.7, 0.5, 0.3, 0.2, 0.1]:
        result = certified_packing_bound(2, rho, r, num_samples=100000)
        N = result['certified_packing_bound']
        R = result['euclidean_subball_radius']
        marginal = N - prev_N
        density = N / result['hyperbolic_weighted_volume'] if result['hyperbolic_weighted_volume'] > 0 else 0

        print(f"  {r:14.1f}  {R:10.6f}  {N:10.0f}  "
              f"{marginal:+10.0f}  {density:10.4f}")
        prev_N = N


def application_4_curvature_comparison():
    """Compare packing in Euclidean vs hyperbolic space.

    Shows the fundamental difference: in Euclidean space, packing density
    is roughly constant. In hyperbolic space, it varies dramatically
    with position (distance from origin).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Euclidean vs Hyperbolic Packing Density")
    print("=" * 70)

    print("\nLocal packing density at different radial positions.\n")

    r = 0.5
    n = 2
    print(f"  Dimension n = {n}, hyperbolic radius r = {r}")
    print(f"  {'Position ρ':>12s}  {'λ_H':>8s}  {'R(ρ,r)':>10s}  "
          f"{'Local density':>14s}  {'vs Euclidean':>12s}")
    print("  " + "-" * 62)

    # Euclidean baseline: density = 1 / vol(ball r) for balls of Euclidean radius r
    R_origin = euclidean_subball_radius(0, r)
    euclid_density = 1.0 / euclidean_ball_volume(n, R_origin)

    for rho in [0.0, 0.2, 0.4, 0.6, 0.8, 0.9, 0.95, 0.99]:
        x = np.array([rho, 0.0])
        lam = poincare_cf(x) if rho > 0 else 2.0
        R = euclidean_subball_radius(rho, r)
        local_density = 1.0 / euclidean_ball_volume(n, R) if R > 0 else float('inf')
        ratio = local_density / euclid_density

        print(f"  {rho:12.2f}  {lam:8.3f}  {R:10.6f}  "
              f"{local_density:14.2f}  {ratio:12.2f}×")


def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF HYPERBOLIC CONFORMAL PACKING THEORY           ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    application_1_embedding_capacity()
    application_2_entropy_bounds()
    application_3_hierarchical_resolution()
    application_4_curvature_comparison()

    print("\n" + "=" * 70)
    print("All applications demonstrated.")
    print("=" * 70)


if __name__ == '__main__':
    main()


"""
Interactive Demonstration: Hyperbolic Conformal Packing Bounds

Visualizes the Poincaré disk model and demonstrates how the conformal packing
bound works in practice. Shows:
1. The Poincaré disk with conformal factor heatmap
2. Greedy hyperbolic circle packings
3. Certified upper bounds vs actual packing counts
4. Sensitivity analysis as ρ → 1

Usage:
    python demo.py              # Run all demonstrations
    python demo.py --interactive  # Save figures for inspection
"""

import numpy as np
import sys

# Check if matplotlib is available for visualization
try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    from matplotlib.patches import Circle
    from matplotlib.colors import Normalize
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib not available; running in text-only mode.")

from algorithms import (
    poincare_cf, radial_distortion, euclidean_subball_radius,
    euclidean_ball_volume, hyperbolic_weighted_volume_disk,
    certified_packing_bound, greedy_hyperbolic_packing_2d,
    hyperbolic_distance_2d, boundary_shell_experiment
)


def demo_conformal_factor():
    """Demonstrate the conformal factor's radial blow-up."""
    print("\n" + "=" * 60)
    print("DEMO 1: Poincaré Conformal Factor λ_H(x) = 2/(1-‖x‖²)")
    print("=" * 60)

    print("\nThe conformal factor measures local stretching of the")
    print("hyperbolic metric relative to Euclidean. It equals 2 at")
    print("the origin and blows up to infinity near the boundary.\n")

    radii = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 0.999]
    print(f"  {'‖x‖':>8s}  {'λ_H(x)':>10s}  {'λ_H(x)²':>12s}  {'Interpretation':>30s}")
    print("  " + "-" * 65)
    for r in radii:
        x = np.array([r, 0.0])
        lam = poincare_cf(x)
        interp = ""
        if r == 0.0:
            interp = "Center (minimal distortion)"
        elif r == 0.5:
            interp = "Moderate stretching"
        elif r == 0.9:
            interp = "Strong stretching (5×)"
        elif r == 0.99:
            interp = "Extreme stretching (100×)"
        elif r == 0.999:
            interp = "Near-boundary blow-up"
        print(f"  {r:8.3f}  {lam:10.4f}  {lam**2:12.2f}  {interp}")

    if HAS_MATPLOTLIB:
        fig, ax = plt.subplots(1, 1, figsize=(8, 8))
        # Heatmap of conformal factor
        x_grid = np.linspace(-0.99, 0.99, 400)
        y_grid = np.linspace(-0.99, 0.99, 400)
        X, Y = np.meshgrid(x_grid, y_grid)
        R = np.sqrt(X**2 + Y**2)
        mask = R < 1.0
        Z = np.full_like(R, np.nan)
        Z[mask] = 2.0 / (1.0 - R[mask]**2)

        im = ax.pcolormesh(X, Y, np.log10(Z), cmap='inferno', shading='auto')
        boundary = Circle((0, 0), 1.0, fill=False, color='white', linewidth=2)
        ax.add_patch(boundary)
        ax.set_xlim(-1.1, 1.1)
        ax.set_ylim(-1.1, 1.1)
        ax.set_aspect('equal')
        ax.set_title('Poincaré Disk: log₁₀(λ_H)', fontsize=14)
        plt.colorbar(im, ax=ax, label='log₁₀(conformal factor)')
        fig.savefig('conformal_factor_heatmap.png', dpi=150, bbox_inches='tight')
        plt.close()
        print("\n  [Saved: conformal_factor_heatmap.png]")


def demo_packing_bounds():
    """Demonstrate certified packing bounds for various parameters."""
    print("\n" + "=" * 60)
    print("DEMO 2: Certified Hyperbolic Packing Bounds")
    print("=" * 60)

    print("\nFor a domain B̄(0,ρ) in the 2D Poincaré disk, the theorem gives:")
    print("  N ≤ D(2,ρ) · hvol(B̄(0,ρ)) / (4 · π · R(ρ,r)²)")
    print()

    print(f"  {'ρ':>5s}  {'r':>5s}  {'D':>8s}  {'R(ρ,r)':>8s}  {'hvol':>10s}  "
          f"{'Euclid vol':>10s}  {'N (bound)':>10s}")
    print("  " + "-" * 72)

    for rho in [0.3, 0.5, 0.7, 0.9, 0.95]:
        for r in [0.3, 0.5, 1.0, 2.0]:
            result = certified_packing_bound(2, rho, r, num_samples=200000)
            print(f"  {rho:5.2f}  {r:5.1f}  {result['distortion']:8.3f}  "
                  f"{result['euclidean_subball_radius']:8.5f}  "
                  f"{result['hyperbolic_weighted_volume']:10.2f}  "
                  f"{result['euclidean_volume']:10.6f}  "
                  f"{result['certified_packing_bound']:10.1f}")
        print()


def demo_greedy_vs_certified():
    """Compare greedy packing counts against certified bounds."""
    print("\n" + "=" * 60)
    print("DEMO 3: Greedy Packing vs Certified Upper Bound")
    print("=" * 60)

    print("\nCompare actual (greedy) packing counts with the certified bound.")
    print("The gap measures the tightness of the inequality.\n")

    r = 0.5
    print(f"  Hyperbolic radius r = {r}")
    print(f"  {'ρ':>5s}  {'Greedy N':>10s}  {'Certified N':>12s}  {'Ratio':>8s}  {'Gap factor':>10s}")
    print("  " + "-" * 55)

    for rho in [0.3, 0.5, 0.7, 0.8, 0.9, 0.95]:
        result = certified_packing_bound(2, rho, r, num_samples=200000)
        centers = greedy_hyperbolic_packing_2d(rho, r, max_attempts=20000)
        greedy_N = len(centers)
        certified_N = result['certified_packing_bound']
        ratio = greedy_N / certified_N if certified_N > 0 else 0
        gap = certified_N / greedy_N if greedy_N > 0 else float('inf')

        print(f"  {rho:5.2f}  {greedy_N:10d}  {certified_N:12.1f}  "
              f"{ratio:8.4f}  {gap:10.2f}×")

    if HAS_MATPLOTLIB:
        # Visualize a packing
        rho = 0.8
        r = 0.5
        centers = greedy_hyperbolic_packing_2d(rho, r, max_attempts=20000)

        fig, ax = plt.subplots(1, 1, figsize=(8, 8))

        # Draw boundary
        boundary = Circle((0, 0), 1.0, fill=False, color='black', linewidth=2)
        ax.add_patch(boundary)
        domain = Circle((0, 0), rho, fill=False, color='blue', linewidth=1.5,
                        linestyle='--', label=f'Domain ρ={rho}')
        ax.add_patch(domain)

        # Draw Euclidean approximations to hyperbolic balls
        for c in centers:
            norm_c = np.linalg.norm(c)
            if norm_c < 1:
                # Approximate Euclidean radius of hyperbolic r-ball at c
                euc_r = euclidean_subball_radius(norm_c, r)
                circle = Circle(c, euc_r, fill=True, alpha=0.3, color='red')
                ax.add_patch(circle)
                ax.plot(c[0], c[1], 'k.', markersize=2)

        ax.set_xlim(-1.15, 1.15)
        ax.set_ylim(-1.15, 1.15)
        ax.set_aspect('equal')
        ax.set_title(f'Greedy Hyperbolic Packing (ρ={rho}, r={r}, N={len(centers)})', fontsize=13)
        ax.legend(loc='upper right')
        fig.savefig('hyperbolic_packing_visualization.png', dpi=150, bbox_inches='tight')
        plt.close()
        print(f"\n  [Saved: hyperbolic_packing_visualization.png]")


def demo_boundary_shell():
    """Test Conjecture D: sharpness near the boundary."""
    print("\n" + "=" * 60)
    print("DEMO 4: Boundary Shell Experiment (Conjecture D)")
    print("=" * 60)

    print("\nAs ρ → 1⁻, does the packing bound become asymptotically sharp")
    print("in thin boundary shells?\n")

    results = boundary_shell_experiment(n=2, r=0.5,
                                         rho_values=[0.7, 0.8, 0.9, 0.95, 0.98, 0.99])

    print(f"  {'ρ_outer':>8s}  {'hvol':>10s}  {'Certified':>10s}  "
          f"{'Greedy':>8s}  {'Distortion':>10s}  {'Efficiency':>10s}")
    print("  " + "-" * 65)
    for res in results:
        eff = f"{res['efficiency_ratio']:.4f}" if res['efficiency_ratio'] else "N/A"
        greedy = str(res['greedy_count']) if res['greedy_count'] is not None else "N/A"
        print(f"  {res['rho_outer']:8.2f}  {res['hvol']:10.2f}  "
              f"{res['certified_bound']:10.1f}  {greedy:>8s}  "
              f"{res['distortion']:10.3f}  {eff:>10s}")


def demo_distortion_growth():
    """Show how distortion grows with ρ and dimension."""
    print("\n" + "=" * 60)
    print("DEMO 5: Distortion Factor Growth")
    print("=" * 60)

    print("\nThe distortion D(n,ρ) = 1/(1-ρ²)^n grows polynomially in 1/(1-ρ²)")
    print("and exponentially in dimension n.\n")

    print(f"  {'ρ':>5s}", end="")
    for n in [1, 2, 3, 5, 10]:
        print(f"  {'n=' + str(n):>10s}", end="")
    print()
    print("  " + "-" * 60)

    for rho in [0.0, 0.3, 0.5, 0.7, 0.8, 0.9, 0.95, 0.99]:
        print(f"  {rho:5.2f}", end="")
        for n in [1, 2, 3, 5, 10]:
            d = radial_distortion(n, rho)
            if d < 1e6:
                print(f"  {d:10.2f}", end="")
            else:
                print(f"  {d:10.1e}", end="")
        print()


def demo_subball_radius():
    """Show how the Euclidean subball radius shrinks near the boundary."""
    print("\n" + "=" * 60)
    print("DEMO 6: Euclidean Subball Radius R(ρ,r)")
    print("=" * 60)

    print("\nAs ρ → 1, a fixed hyperbolic ball occupies less Euclidean space:")
    print("  R(ρ,r) = (1-ρ²)·tanh(r/2) / (1+ρ·tanh(r/2))\n")

    r = 1.0
    print(f"  Hyperbolic radius r = {r}")
    print(f"  {'ρ':>5s}  {'R(ρ,r)':>10s}  {'tanh(r/2)':>10s}  {'Ratio R/tanh':>12s}")
    print("  " + "-" * 45)

    tanh_half_r = np.tanh(r / 2)
    for rho in [0.0, 0.2, 0.4, 0.6, 0.8, 0.9, 0.95, 0.99]:
        R = euclidean_subball_radius(rho, r)
        ratio = R / tanh_half_r
        print(f"  {rho:5.2f}  {R:10.6f}  {tanh_half_r:10.6f}  {ratio:12.6f}")


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  HYPERBOLIC CONFORMAL PACKING: INTERACTIVE DEMONSTRATIONS  ║")
    print("║                                                            ║")
    print("║  Exploring packing density in negatively curved spaces     ║")
    print("║  via the Poincaré disk model                               ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    demo_conformal_factor()
    demo_packing_bounds()
    demo_greedy_vs_certified()
    demo_boundary_shell()
    demo_distortion_growth()
    demo_subball_radius()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    if HAS_MATPLOTLIB:
        print("Generated figures: conformal_factor_heatmap.png,")
        print("                   hyperbolic_packing_visualization.png")
    print("=" * 60)


if __name__ == '__main__':
    main()
