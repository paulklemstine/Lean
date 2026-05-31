#!/usr/bin/env python3
"""
Hyperbolic Number Theory — Demonstration Script

Numerical examples illustrating the core concepts:
1. Hyperbolic distance computations in the Poincaré disk
2. PSL(2,Z) orbit enumeration
3. Lattice point counting vs. asymptotic predictions
4. Primitive geodesic (hyperbolic prime) detection
5. Selberg zeta function evaluation
"""

import math
from algorithms import (
    hyp_distance, hyp_distance_cross_ratio, is_in_disk,
    MobiusTransform, SL2R,
    enumerate_psl2z_words, orbit_in_disk,
    hyp_counting_fn, hyp_prime_asymptotic,
    find_primitive_geodesics, selberg_zeta_truncated,
    hyp_polygon_area, hyp_disk_area, hyp_area_factor,
    lattice_point_leading_coeff,
    build_midpoint_system,
)


def demo_hyperbolic_distance():
    """Demonstrate hyperbolic distance computations."""
    print("=" * 60)
    print("1. HYPERBOLIC DISTANCE IN THE POINCARÉ DISK")
    print("=" * 60)

    pairs = [
        (0j, 0.5 + 0j, "origin to 0.5"),
        (0j, 0.9 + 0j, "origin to 0.9"),
        (0j, 0.99 + 0j, "origin to 0.99"),
        (0.3 + 0.2j, -0.1 + 0.4j, "two interior points"),
    ]

    for z, w, desc in pairs:
        d = hyp_distance(z, w)
        delta = hyp_distance_cross_ratio(z, w)
        print(f"  d({z}, {w}) = {d:.6f}  [{desc}]")
        print(f"    cross-ratio δ = {delta:.6f}, acosh(1+2δ) = {math.acosh(1+2*delta):.6f}")

    print("\n  Key insight: distances near the boundary are vastly larger")
    print(f"  d(0, 0.5) / d(0, 0.9)  = {hyp_distance(0j, 0.5) / hyp_distance(0j, 0.9):.4f}")
    print(f"  d(0, 0.9) / d(0, 0.99) = {hyp_distance(0j, 0.9) / hyp_distance(0j, 0.99):.4f}")
    print()


def demo_mobius_transform():
    """Demonstrate Möbius transformations."""
    print("=" * 60)
    print("2. MÖBIUS TRANSFORMATIONS")
    print("=" * 60)

    phi = MobiusTransform(center=0.3 + 0.1j, rotation=1 + 0j)
    test_points = [0j, 0.5 + 0j, 0.2 + 0.3j, -0.4 + 0.1j]

    for z in test_points:
        w = phi.apply(z)
        print(f"  φ({z}) = {w:.6f},  |w| = {abs(w):.6f} (< 1: {is_in_disk(w)})")

    # Verify distance preservation
    z1, z2 = 0.2 + 0.1j, -0.3 + 0.2j
    d_before = hyp_distance(z1, z2)
    d_after = hyp_distance(phi.apply(z1), phi.apply(z2))
    print(f"\n  Distance preservation check:")
    print(f"    d(z₁, z₂)       = {d_before:.6f}")
    print(f"    d(φ(z₁), φ(z₂)) = {d_after:.6f}")
    print(f"    Difference: {abs(d_before - d_after):.2e}")
    print()


def demo_psl2z_orbit():
    """Demonstrate PSL(2,Z) orbit computation."""
    print("=" * 60)
    print("3. PSL(2,Z) ORBIT ENUMERATION")
    print("=" * 60)

    for word_len in [3, 5, 7, 9]:
        elements = enumerate_psl2z_words(word_len)
        base = 0.0 + 2.0j  # i * 2 in upper half-plane
        orbit = orbit_in_disk(base, elements)

        print(f"  Word length ≤ {word_len}: {len(elements):5d} group elements, "
              f"{len(orbit):5d} orbit points in disk")

    print()


def demo_counting():
    """Demonstrate lattice point counting."""
    print("=" * 60)
    print("4. LATTICE POINT COUNTING")
    print("=" * 60)

    elements = enumerate_psl2z_words(8)
    base = 0.0 + 2.0j
    orbit = orbit_in_disk(base, elements)

    print(f"  Total orbit points: {len(orbit)}")
    print(f"\n  {'R':>6s} | {'N(R)':>8s} | {'Asymptotic':>12s} | {'Ratio':>8s}")
    print(f"  {'-'*6} | {'-'*8} | {'-'*12} | {'-'*8}")

    covolume = math.pi / 3  # PSL(2,Z) covolume
    leading = lattice_point_leading_coeff(covolume)

    for R in [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]:
        count = hyp_counting_fn(orbit, R)
        asymp = leading * math.exp(R)
        ratio = count / asymp if asymp > 0 else 0
        print(f"  {R:6.1f} | {count:8d} | {asymp:12.1f} | {ratio:8.3f}")

    print(f"\n  Leading coefficient V/(4π) = {leading:.6f} (V = π/3 for PSL(2,Z))")
    print(f"  Predicted: 1/12 = {1/12:.6f}")
    print()


def demo_geodesic_primes():
    """Demonstrate primitive geodesic detection."""
    print("=" * 60)
    print("5. HYPERBOLIC PRIMES (PRIMITIVE GEODESICS)")
    print("=" * 60)

    elements = enumerate_psl2z_words(8)
    primes = find_primitive_geodesics(elements, max_length=10.0)

    print(f"  Found {len(primes)} primitive geodesics with length ≤ 10.0")
    print(f"\n  First 15 primitive geodesic lengths:")
    for i, (length, g) in enumerate(primes[:15]):
        print(f"    ℓ_{i+1} = {length:.6f}  (trace = {g.trace():.4f})")

    # Compare with asymptotic
    print(f"\n  Counting comparison with e^R/R asymptotic:")
    for R in [3.0, 5.0, 7.0, 10.0]:
        count = sum(1 for ell, _ in primes if ell <= R)
        asymp = hyp_prime_asymptotic(R)
        print(f"    R = {R:.1f}: count = {count:4d}, e^R/R = {asymp:.1f}")

    print()


def demo_selberg_zeta():
    """Demonstrate the Selberg zeta function."""
    print("=" * 60)
    print("6. SELBERG ZETA FUNCTION")
    print("=" * 60)

    elements = enumerate_psl2z_words(7)
    primes = find_primitive_geodesics(elements, max_length=8.0)
    spectrum = [ell for ell, _ in primes]

    print(f"  Using {len(spectrum)} primitive geodesic lengths")
    print(f"\n  {'s':>6s} | {'Z_K(s)':>15s}")
    print(f"  {'-'*6} | {'-'*15}")

    for s in [0.5, 1.0, 1.5, 2.0, 3.0, 5.0, 10.0]:
        Z = selberg_zeta_truncated(spectrum, s, K=10)
        print(f"  {s:6.1f} | {Z:15.8f}")

    print()


def demo_gauss_bonnet():
    """Demonstrate the Gauss-Bonnet theorem for hyperbolic polygons."""
    print("=" * 60)
    print("7. GAUSS-BONNET: HYPERBOLIC POLYGON AREAS")
    print("=" * 60)

    # Ideal triangle (all angles = 0)
    area_ideal = hyp_polygon_area([0, 0, 0])
    print(f"  Ideal triangle (angles = 0, 0, 0): area = {area_ideal:.6f} = π = {math.pi:.6f}")

    # Regular triangles
    for alpha in [math.pi/6, math.pi/4, math.pi/3]:
        angles = [alpha, alpha, alpha]
        area = hyp_polygon_area(angles)
        print(f"  Equilateral triangle (α = π/{int(math.pi/alpha):.0f}): "
              f"area = {area:.6f}")

    # The {3,7} tiling: regular triangles with angle 2π/7
    alpha_37 = 2 * math.pi / 7
    area_37 = hyp_polygon_area([alpha_37, alpha_37, alpha_37])
    print(f"\n  Heptagonal tiling {{3,7}} triangle: area = {area_37:.6f}")

    # Hyperbolic disk areas
    print(f"\n  Hyperbolic disk areas:")
    for R in [1.0, 2.0, 5.0, 10.0]:
        area = hyp_disk_area(R)
        print(f"    R = {R:5.1f}: A = {area:12.2f}")

    # Area factor near boundary
    print(f"\n  Area stretching factor 4/(1-r²)²:")
    for r in [0.0, 0.5, 0.9, 0.99, 0.999]:
        factor = hyp_area_factor(r)
        print(f"    r = {r:.3f}: factor = {factor:12.2f}")

    print()


def demo_arithmetic_system():
    """Demonstrate the Hyperbolic Arithmetic System."""
    print("=" * 60)
    print("8. HYPERBOLIC ARITHMETIC SYSTEM")
    print("=" * 60)

    elements = enumerate_psl2z_words(5)
    base = 0.0 + 2.0j
    orbit = orbit_in_disk(base, elements)

    # Filter to unique points close to origin for a small system
    small_orbit = [0j] + [z for z in orbit if abs(z) < 0.5]
    # Deduplicate
    unique = [small_orbit[0]]
    for z in small_orbit[1:]:
        if all(abs(z - u) > 1e-6 for u in unique):
            unique.append(z)

    system = build_midpoint_system(unique)
    print(f"  System size: {system.size}")
    print(f"  Points below R=1: {system.count_below(1.0)}")
    print(f"  Points below R=2: {system.count_below(2.0)}")

    primes = system.find_primes()
    print(f"  Hyperbolic primes (midpoint-irreducible): {len(primes)}")
    for i, p in enumerate(primes[:5]):
        print(f"    p_{i+1} = {p:.6f},  |p| = {abs(p):.6f}")

    print()


def main():
    print("\n" + "=" * 60)
    print("  HYPERBOLIC NUMBER THEORY: ARITHMETIC ON THE POINCARÉ DISK")
    print("=" * 60 + "\n")

    demo_hyperbolic_distance()
    demo_mobius_transform()
    demo_psl2z_orbit()
    demo_counting()
    demo_geodesic_primes()
    demo_selberg_zeta()
    demo_gauss_bonnet()
    demo_arithmetic_system()

    print("=" * 60)
    print("  TESTABLE CONJECTURE")
    print("=" * 60)
    print("""
  Conjecture (Hyperbolic Prime Number Theorem):
    For PSL(2,Z), the number of primitive closed geodesics
    with length ≤ R satisfies π_H(R) ~ e^R / R as R → ∞.

  This is actually the Prime Geodesic Theorem (Huber 1961),
  a known result. Our computation provides numerical evidence:
""")

    elements = enumerate_psl2z_words(9)
    primes = find_primitive_geodesics(elements, max_length=12.0)

    for R in [4.0, 6.0, 8.0, 10.0]:
        count = sum(1 for ell, _ in primes if ell <= R)
        asymp = hyp_prime_asymptotic(R)
        ratio = count / asymp if asymp > 0 else 0
        print(f"  R = {R:5.1f}: π_H(R) = {count:4d}, e^R/R = {asymp:8.1f}, ratio = {ratio:.3f}")

    print("\n  If the conjecture holds, the ratio → 1 as R → ∞.")
    print("  (Deviations for small R are expected error terms.)\n")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 3: Hyperbolic Geometry — Area, Curvature, and the Gauss-Bonnet Theorem

Shows:
- The hyperbolic area scaling factor 4/(1-r²)²
- Hyperbolic disk area vs Euclidean disk area
- Triangle area deficit (Gauss-Bonnet) in hyperbolic geometry
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from algorithms import hyp_area_factor, hyp_disk_area, hyp_polygon_area


def plot_hyperbolic_area():
    """Plot hyperbolic area concepts."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # --- Panel 1: Area scaling factor ---
    ax = axes[0]
    r_values = np.linspace(0, 0.995, 500)
    factors = [hyp_area_factor(r) for r in r_values]

    ax.semilogy(r_values, factors, 'darkblue', linewidth=2)
    ax.axhline(y=4, color='red', linestyle='--', alpha=0.5, label='Minimum = 4')
    ax.set_xlabel('Euclidean radius r', fontsize=12)
    ax.set_ylabel('Area factor (log scale)', fontsize=12)
    ax.set_title(r'Conformal Factor $\frac{4}{(1-r^2)^2}$', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 1)
    ax.set_ylim(1, 1e6)

    # --- Panel 2: Hyperbolic vs Euclidean disk area ---
    ax = axes[1]
    R_values = np.linspace(0.01, 5.0, 200)
    hyp_areas = [hyp_disk_area(R) for R in R_values]
    eucl_areas = [math.pi * R**2 for R in R_values]

    ax.plot(R_values, hyp_areas, 'b-', linewidth=2, label='Hyperbolic area')
    ax.plot(R_values, eucl_areas, 'r--', linewidth=2, label='Euclidean area')

    ax.set_xlabel('Radius R', fontsize=12)
    ax.set_ylabel('Area', fontsize=12)
    ax.set_title('Disk Area: Hyperbolic vs Euclidean', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # --- Panel 3: Triangle area deficit ---
    ax = axes[2]

    # For a hyperbolic triangle with all angles = α, area = π - 3α
    alpha_values = np.linspace(0, math.pi / 3 - 0.01, 200)
    triangle_areas = [math.pi - 3 * alpha for alpha in alpha_values]
    angle_sums = [3 * alpha for alpha in alpha_values]

    ax.plot(np.degrees(angle_sums), triangle_areas, 'purple', linewidth=2)
    ax.axvline(x=180, color='gray', linestyle='--', alpha=0.5,
               label='Euclidean angle sum = 180°')
    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)

    ax.fill_between(np.degrees(angle_sums), 0, triangle_areas,
                     alpha=0.15, color='purple')

    ax.set_xlabel('Angle sum (degrees)', fontsize=12)
    ax.set_ylabel('Area', fontsize=12)
    ax.set_title('Gauss-Bonnet: Triangle Area = π − Σαᵢ', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 180)

    plt.tight_layout()
    plt.savefig('hyperbolic_area.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved hyperbolic_area.png")


if __name__ == "__main__":
    plot_hyperbolic_area()


#!/usr/bin/env python3
"""
Visualization 1: The Poincaré Disk and Hyperbolic Lattice Points

Creates a plot showing the PSL(2,Z) orbit in the Poincaré disk,
colored by hyperbolic distance from the origin.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from algorithms import (
    enumerate_psl2z_words, orbit_in_disk,
    hyp_distance, hyp_counting_fn, hyp_disk_area,
)


def plot_poincare_disk():
    """Plot the PSL(2,Z) orbit in the Poincaré disk."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Left panel: Orbit points colored by distance ---
    ax = axes[0]

    # Draw the unit disk boundary
    theta = np.linspace(0, 2 * np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

    # Compute orbit
    elements = enumerate_psl2z_words(8)
    base = 0.0 + 2.0j
    orbit = orbit_in_disk(base, elements)

    xs = [z.real for z in orbit]
    ys = [z.imag for z in orbit]
    dists = [hyp_distance(0j, z) for z in orbit]

    scatter = ax.scatter(xs, ys, c=dists, cmap='viridis', s=15, alpha=0.8,
                         edgecolors='none', vmin=0, vmax=max(dists))
    plt.colorbar(scatter, ax=ax, label='Hyperbolic distance from origin')

    # Mark origin
    ax.plot(0, 0, 'r*', markersize=12, label='Origin')

    ax.set_xlim(-1.1, 1.1)
    ax.set_ylim(-1.1, 1.1)
    ax.set_aspect('equal')
    ax.set_title('PSL(2,ℤ) Orbit in the Poincaré Disk', fontsize=13)
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.legend(loc='upper right')
    ax.grid(True, alpha=0.3)

    # --- Right panel: Counting function ---
    ax = axes[1]

    R_values = np.linspace(0.1, 7.0, 100)
    counts = [hyp_counting_fn(orbit, R) for R in R_values]

    # Asymptotic: V/(4π) * e^R where V = π/3
    leading = (math.pi / 3) / (4 * math.pi)
    asymp = [leading * math.exp(R) for R in R_values]

    ax.semilogy(R_values, counts, 'b-', linewidth=2, label='N(R) (actual)')
    ax.semilogy(R_values, asymp, 'r--', linewidth=2, label=r'$\frac{1}{12} e^R$ (asymptotic)')

    ax.set_xlabel('Hyperbolic radius R', fontsize=12)
    ax.set_ylabel('Count (log scale)', fontsize=12)
    ax.set_title('Lattice Point Counting Function', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('poincare_disk.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved poincare_disk.png")


if __name__ == "__main__":
    plot_poincare_disk()


#!/usr/bin/env python3
"""
Visualization 2: Hyperbolic Primes and the Selberg Zeta Function

Creates plots showing:
- Distribution of primitive geodesic lengths (hyperbolic primes)
- The Selberg zeta function
- Comparison with the e^R/R asymptotic
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from algorithms import (
    enumerate_psl2z_words, find_primitive_geodesics,
    selberg_zeta_truncated, hyp_prime_asymptotic,
)


def plot_hyperbolic_primes():
    """Plot the distribution of hyperbolic primes and the Selberg zeta."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Compute geodesic data
    elements = enumerate_psl2z_words(9)
    primes = find_primitive_geodesics(elements, max_length=12.0)
    lengths = sorted(set(round(ell, 4) for ell, _ in primes))

    # --- Panel 1: Length spectrum histogram ---
    ax = axes[0]
    all_lengths = [ell for ell, _ in primes]
    ax.hist(all_lengths, bins=30, color='steelblue', edgecolor='black', alpha=0.8)
    ax.set_xlabel('Geodesic length ℓ', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Primitive Geodesic Length Spectrum', fontsize=13)
    ax.axvline(x=2 * math.acosh(1.5), color='red', linestyle='--',
               label=f'ℓ_min = {2*math.acosh(1.5):.3f}')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # --- Panel 2: Counting function vs asymptotic ---
    ax = axes[1]
    R_range = np.linspace(1.0, max(all_lengths) + 1, 200)

    # Staircase counting function
    prime_count = []
    for R in R_range:
        count = sum(1 for ell in all_lengths if ell <= R)
        prime_count.append(count)

    # Asymptotic: e^R / R
    asymp_values = [hyp_prime_asymptotic(R) for R in R_range]

    ax.plot(R_range, prime_count, 'b-', linewidth=2, label=r'$\pi_H(R)$ (counted)')
    ax.plot(R_range, asymp_values, 'r--', linewidth=2, label=r'$e^R / R$ (asymptotic)')
    ax.set_xlabel('Length threshold R', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Hyperbolic Prime Counting Function', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # --- Panel 3: Selberg zeta function ---
    ax = axes[2]
    spectrum = [ell for ell, _ in primes]
    s_values = np.linspace(0.3, 8.0, 200)
    Z_values = [selberg_zeta_truncated(spectrum, s, K=15) for s in s_values]

    ax.plot(s_values, Z_values, 'darkgreen', linewidth=2)
    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.5)
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.3)
    ax.set_xlabel('s', fontsize=12)
    ax.set_ylabel('Z(s)', fontsize=12)
    ax.set_title('Selberg Zeta Function Z(s)', fontsize=13)
    ax.grid(True, alpha=0.3)

    # Mark the zero near s=1
    ax.axvline(x=1.0, color='red', linestyle=':', alpha=0.5, label='s = 1 (trivial zero)')
    ax.legend()

    plt.tight_layout()
    plt.savefig('hyperbolic_primes.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved hyperbolic_primes.png")


if __name__ == "__main__":
    plot_hyperbolic_primes()
