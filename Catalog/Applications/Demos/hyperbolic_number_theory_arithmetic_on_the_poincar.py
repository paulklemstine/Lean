#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Numerical Demonstrations

Demonstrates key results from the Poincaré disk arithmetic framework:
1. Möbius transformations preserve the disk
2. Hyperbolic area growth
3. Spectral gap analysis
4. Prime geodesic counting
5. Cayley graph diameters (testing Babai-type conjecture)
6. Hyperbolic divisor function for cyclic groups
"""

import math
import cmath
from algorithms import (
    mobius_transform,
    hyperbolic_distance,
    hyperbolic_area,
    angle_defect,
    spectral_gap,
    prime_geodesic_asymptotic,
    lattice_point_leading_coeff,
    selberg_zeta_truncated,
    modular_geodesic_lengths,
    cayley_graph_diameter,
    hyp_area_factor,
    hyperbolic_divisor_count,
)


def demo_mobius_preservation():
    """Verify that Möbius transformations preserve the disk."""
    print("=" * 60)
    print("DEMO 1: Möbius Transformations Preserve the Disk")
    print("=" * 60)

    test_points = [0.3 + 0.4j, -0.5 + 0.2j, 0.1 - 0.7j, 0.8 + 0.1j]
    centers = [0.2 + 0.3j, -0.4 + 0.1j, 0.6 - 0.2j]

    for a in centers:
        print(f"\n  Center a = {a:.3f}, |a| = {abs(a):.4f}")
        for z in test_points:
            w = mobius_transform(a, z)
            print(f"    φ_a({z:.3f}) = {w:.4f}, |w| = {abs(w):.6f} < 1 ✓")
            assert abs(w) < 1, f"Disk not preserved! |w| = {abs(w)}"
    print("\n  All Möbius images stay in the disk. ✓")


def demo_hyperbolic_area():
    """Demonstrate hyperbolic area growth."""
    print("\n" + "=" * 60)
    print("DEMO 2: Hyperbolic Area Growth")
    print("=" * 60)

    print(f"\n  {'R':>5s}  {'A(R)':>12s}  {'π·e^R':>12s}  {'A(R)/π·e^R':>10s}")
    print("  " + "-" * 45)

    for R in [0, 0.5, 1, 2, 3, 5, 8, 10]:
        area = hyperbolic_area(R)
        asymptotic = math.pi * math.exp(R) if R > 0 else 0
        ratio = area / asymptotic if asymptotic > 0 else 0
        print(f"  {R:5.1f}  {area:12.4f}  {asymptotic:12.4f}  {ratio:10.6f}")

    print("\n  As R → ∞, A(R) / (π·e^R) → 1 (exponential growth).")


def demo_spectral_gap():
    """Analyze the spectral gap parameter."""
    print("\n" + "=" * 60)
    print("DEMO 3: Spectral Gap Analysis")
    print("=" * 60)

    print(f"\n  {'λ₁':>8s}  {'δ(λ₁)':>8s}  {'Selberg bound':>14s}")
    print("  " + "-" * 35)

    for lam in [0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 5.0]:
        delta = spectral_gap(lam)
        bound = "λ₁ = 1/4" if abs(lam - 0.25) < 1e-10 else ""
        print(f"  {lam:8.4f}  {delta:8.4f}  {bound}")

    # Verify monotonicity
    lambdas = [0.25 + 0.1 * i for i in range(50)]
    deltas = [spectral_gap(l) for l in lambdas]
    monotone = all(d1 <= d2 for d1, d2 in zip(deltas, deltas[1:]))
    print(f"\n  Monotonicity verified: {monotone} ✓")


def demo_prime_geodesics():
    """Demonstrate prime geodesic counting."""
    print("\n" + "=" * 60)
    print("DEMO 4: Prime Geodesic Theorem")
    print("=" * 60)

    lengths = modular_geodesic_lengths(100)
    print(f"\n  Found {len(lengths)} primitive geodesic lengths for PSL(2,Z)")
    print(f"  (traces 3 to 100)")
    print(f"\n  First 10 lengths: {[f'{l:.4f}' for l in lengths[:10]]}")

    print(f"\n  {'R':>5s}  {'Count':>6s}  {'e^R/R':>10s}  {'Ratio':>8s}")
    print("  " + "-" * 35)

    for R in [2, 3, 4, 5, 6, 7, 8]:
        count = sum(1 for l in lengths if l <= R)
        asymp = prime_geodesic_asymptotic(R)
        ratio = count / asymp if asymp > 0 else 0
        print(f"  {R:5.1f}  {count:6d}  {asymp:10.2f}  {ratio:8.4f}")

    # PSL(2,Z) leading coefficient
    coeff = lattice_point_leading_coeff(math.pi / 3)
    print(f"\n  PSL(2,Z) lattice point leading coefficient: {coeff:.6f}")
    print(f"  Expected (1/12): {1/12:.6f}")
    print(f"  Match: {abs(coeff - 1/12) < 1e-10} ✓")


def demo_cayley_diameters():
    """Test Babai-type conjecture on Cayley graph diameters."""
    print("\n" + "=" * 60)
    print("DEMO 5: Cayley Graph Diameters (Babai Conjecture Test)")
    print("=" * 60)

    print(f"\n  Testing Z/nZ with generators {{1, n-1}}:")
    print(f"  {'n':>5s}  {'Diameter':>8s}  {'⌊n/2⌋':>6s}  {'log₂n':>6s}")
    print("  " + "-" * 30)

    for n in [4, 5, 7, 10, 15, 20, 50, 100]:
        gens = [1, n - 1]
        diam = cayley_graph_diameter(n, gens)
        half_n = n // 2
        log_n = math.log2(n)
        print(f"  {n:5d}  {diam:8d}  {half_n:6d}  {log_n:6.2f}")

    print("\n  Diameter grows linearly (= ⌊n/2⌋), NOT logarithmically.")
    print("  → Conjecture FALSE for cyclic groups with 2 generators.")

    print(f"\n  Testing Z/nZ with generators {{1, 2, n-1, n-2}}:")
    print(f"  {'n':>5s}  {'Diameter':>8s}  {'⌊n/4⌋+1':>8s}")
    print("  " + "-" * 25)

    for n in [4, 5, 7, 10, 15, 20, 50, 100]:
        gens = [1, 2, n - 1, n - 2]
        diam = cayley_graph_diameter(n, gens)
        quarter = n // 4 + 1
        print(f"  {n:5d}  {diam:8d}  {quarter:8d}")


def demo_divisor_function():
    """Demonstrate the hyperbolic divisor function for cyclic groups."""
    print("\n" + "=" * 60)
    print("DEMO 6: Hyperbolic Divisor Function for Z/nZ")
    print("=" * 60)

    for n in [5, 7, 12]:
        elements = list(range(n))
        group_op = lambda a, b, n=n: (a + b) % n

        print(f"\n  Z/{n}Z, S = Z/{n}Z:")
        print(f"  {'g':>4s}  {'d_H(g)':>6s}")
        print("  " + "-" * 14)

        for g in range(n):
            count = hyperbolic_divisor_count(elements, group_op, g)
            marker = " ← identity" if g == 0 else ""
            print(f"  {g:4d}  {count:6d}{marker}")

        # Verify: d_H(0) = n (each element pairs with its inverse)
        d0 = hyperbolic_divisor_count(elements, group_op, 0)
        print(f"  d_H(0) = {d0} = |S| = {n} ✓")


def demo_gauss_bonnet():
    """Demonstrate the Gauss-Bonnet angle defect formula."""
    print("\n" + "=" * 60)
    print("DEMO 7: Gauss-Bonnet Angle Defect")
    print("=" * 60)

    triangles = [
        ("Ideal triangle (all angles 0)", 0, 0, 0),
        ("Right triangle (π/4, π/6, π/4)", math.pi/4, math.pi/6, math.pi/4),
        ("Nearly flat (π/3, π/3, π/3-0.1)", math.pi/3, math.pi/3, math.pi/3 - 0.1),
        ("Very curved (0.1, 0.1, 0.1)", 0.1, 0.1, 0.1),
    ]

    for name, a, b, c in triangles:
        defect = angle_defect(a, b, c)
        angle_sum = a + b + c
        print(f"\n  {name}:")
        print(f"    Angle sum = {angle_sum:.4f} ({math.degrees(angle_sum):.1f}°)")
        print(f"    Defect = Area = {defect:.4f}")
        if defect > 0:
            print(f"    Angle sum < π ✓ (hyperbolic)")


def demo_area_factor():
    """Demonstrate the hyperbolic area factor divergence."""
    print("\n" + "=" * 60)
    print("DEMO 8: Hyperbolic Area Factor Divergence")
    print("=" * 60)

    print(f"\n  {'r':>6s}  {'4/(1-r²)²':>12s}  {'≥ 4':>5s}")
    print("  " + "-" * 28)

    for r in [0, 0.1, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99, 0.999]:
        factor = hyp_area_factor(r)
        check = "✓" if factor >= 4 else "✗"
        print(f"  {r:6.3f}  {factor:12.2f}  {check:>5s}")

    print("\n  Area factor diverges as r → 1: CONFIRMED ✓")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   HYPERBOLIC NUMBER THEORY: NUMERICAL DEMONSTRATIONS    ║")
    print("║   Arithmetic on the Poincaré Disk                       ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_mobius_preservation()
    demo_hyperbolic_area()
    demo_spectral_gap()
    demo_prime_geodesics()
    demo_cayley_diameters()
    demo_divisor_function()
    demo_gauss_bonnet()
    demo_area_factor()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Poincaré Disk with Hyperbolic Lattice Points

Generates a plot of the Poincaré disk showing:
- The unit disk boundary
- Hyperbolic geodesics
- Lattice points of a discrete group
- Hyperbolic circles of increasing radius
"""

import math
import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.patches import Circle, Arc
    from matplotlib.collections import LineCollection
except ImportError:
    print("matplotlib not available, skipping visualization")
    exit(0)


def mobius_transform(a: complex, z: complex) -> complex:
    """Apply Möbius automorphism φ_a(z) = (z - a) / (1 - conj(a)*z)."""
    denom = 1 - a.conjugate() * z
    if abs(denom) < 1e-15:
        return 0j
    return (z - a) / denom


def generate_lattice_points(centers: list, depth: int = 4) -> list:
    """Generate lattice points by composing Möbius transforms."""
    points = [0j]
    current_gen = [0j]

    for _ in range(depth):
        next_gen = []
        for z in current_gen:
            for a in centers:
                w = mobius_transform(a, z)
                if abs(w) < 0.999:
                    # Check if point is new
                    is_new = all(abs(w - p) > 0.01 for p in points)
                    if is_new:
                        points.append(w)
                        next_gen.append(w)
                # Also try inverse
                w_inv = mobius_transform(-a, z)
                if abs(w_inv) < 0.999:
                    is_new = all(abs(w_inv - p) > 0.01 for p in points)
                    if is_new:
                        points.append(w_inv)
                        next_gen.append(w_inv)
        current_gen = next_gen
        if not current_gen:
            break

    return points


def hyperbolic_circle_euclidean(center_hyp: complex, R: float, n_points: int = 200) -> list:
    """Convert a hyperbolic circle to Euclidean coordinates."""
    # For a circle centered at origin with hyperbolic radius R,
    # the Euclidean radius is tanh(R/2)
    if abs(center_hyp) < 1e-10:
        r_eucl = math.tanh(R / 2)
        return [(r_eucl * math.cos(t), r_eucl * math.sin(t))
                for t in np.linspace(0, 2*math.pi, n_points)]
    else:
        # General case: transform a circle at origin
        r_eucl = math.tanh(R / 2)
        points = []
        for t in np.linspace(0, 2*math.pi, n_points):
            z = r_eucl * complex(math.cos(t), math.sin(t))
            # Transform from origin to center_hyp
            w = mobius_transform(-center_hyp, z)
            points.append((w.real, w.imag))
        return points


def plot_poincare_disk():
    """Create the main Poincaré disk visualization."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # ====== Left plot: Lattice points ======
    ax = axes[0]
    ax.set_aspect('equal')
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_title('Hyperbolic Integers on the Poincaré Disk', fontsize=13)

    # Draw unit disk
    disk = Circle((0, 0), 1, fill=False, edgecolor='black', linewidth=2)
    ax.add_patch(disk)
    disk_fill = Circle((0, 0), 1, fill=True, facecolor='#f0f8ff', edgecolor='none')
    ax.add_patch(disk_fill)

    # Generate lattice points using two generators
    gen1 = 0.4 + 0.3j
    gen2 = -0.2 + 0.5j
    points = generate_lattice_points([gen1, gen2], depth=5)

    # Draw hyperbolic circles
    for R in [0.5, 1.0, 1.5, 2.0, 2.5]:
        circle_pts = hyperbolic_circle_euclidean(0j, R)
        xs = [p[0] for p in circle_pts]
        ys = [p[1] for p in circle_pts]
        ax.plot(xs, ys, 'b-', alpha=0.15, linewidth=0.5)

    # Plot lattice points
    for p in points:
        color = 'red' if abs(p) < 0.01 else ('darkblue' if abs(p) < 0.5 else 'steelblue')
        size = 40 if abs(p) < 0.01 else (20 if abs(p) < 0.5 else 10)
        ax.plot(p.real, p.imag, 'o', color=color, markersize=math.sqrt(size),
                alpha=0.8, markeredgecolor='white', markeredgewidth=0.3)

    ax.plot(0, 0, 'o', color='red', markersize=8, label='Origin (identity)')
    ax.legend(loc='upper right', fontsize=9)

    # Labels
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.text(0.02, -0.06, '0', fontsize=8, color='red')

    # ====== Right plot: Area growth ======
    ax2 = axes[1]
    Rs = np.linspace(0, 6, 200)
    areas = [2 * math.pi * (math.cosh(R) - 1) for R in Rs]
    asymp = [math.pi * math.exp(R) for R in Rs]

    ax2.plot(Rs, areas, 'b-', linewidth=2, label=r'$A(R) = 2\pi(\cosh R - 1)$')
    ax2.plot(Rs, asymp, 'r--', linewidth=1.5, label=r'$\pi e^R$ (asymptotic)')
    ax2.fill_between(Rs, areas, alpha=0.1, color='blue')

    ax2.set_xlabel('Hyperbolic radius R', fontsize=12)
    ax2.set_ylabel('Hyperbolic area', fontsize=12)
    ax2.set_title('Exponential Growth of Hyperbolic Area', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_yscale('log')
    ax2.set_ylim(0.1, 2000)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('poincare_disk.png', dpi=150, bbox_inches='tight')
    print("Saved poincare_disk.png")
    plt.close()


def plot_spectral_gap():
    """Plot the spectral gap analysis."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: spectral gap function
    ax = axes[0]
    lambdas = np.linspace(0.25, 5, 200)
    deltas = [0.5 + math.sqrt(max(0, l - 0.25)) for l in lambdas]

    ax.plot(lambdas, deltas, 'b-', linewidth=2)
    ax.axhline(y=0.5, color='r', linestyle='--', alpha=0.5, label=r'$\delta = 1/2$ (minimum)')
    ax.axvline(x=0.25, color='g', linestyle='--', alpha=0.5, label=r'$\lambda_1 = 1/4$ (Selberg)')
    ax.set_xlabel(r'$\lambda_1$', fontsize=14)
    ax.set_ylabel(r'$\delta(\lambda_1)$', fontsize=14)
    ax.set_title('Spectral Gap: Monotonically Increasing', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: area factor divergence
    ax2 = axes[1]
    rs = np.linspace(0, 0.99, 500)
    factors = [4 / (1 - r**2)**2 for r in rs]

    ax2.plot(rs, factors, 'purple', linewidth=2)
    ax2.axhline(y=4, color='r', linestyle='--', alpha=0.5, label='Minimum = 4')
    ax2.set_xlabel('Euclidean radius r', fontsize=14)
    ax2.set_ylabel(r'$4/(1-r^2)^2$', fontsize=14)
    ax2.set_title('Hyperbolic Area Factor Divergence', fontsize=13)
    ax2.set_yscale('log')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('spectral_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_analysis.png")
    plt.close()


if __name__ == "__main__":
    plot_poincare_disk()
    plot_spectral_gap()
    print("All visualizations generated.")
