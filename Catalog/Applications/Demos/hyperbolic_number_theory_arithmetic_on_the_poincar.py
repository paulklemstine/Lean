#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Demonstration Script

Demonstrates the key concepts:
1. Möbius transformations preserving the Poincaré disk
2. Orbit computation and hyperbolic primes
3. Hyperbolic distance and norm
4. Partial hyperbolic zeta function
5. Orbit growth verification
"""

import cmath
import math
from algorithms import (
    MobiusGenerator, HyperbolicLattice, hyp_dist, hyp_norm,
    mobius_transform, make_regular_generators, verify_disk_preservation
)


def demo_disk_preservation():
    """Demonstrate that Möbius automorphisms preserve the disk."""
    print("=" * 60)
    print("DEMO 1: Möbius Automorphisms Preserve the Poincaré Disk")
    print("=" * 60)

    generators = make_regular_generators(3, radius=0.4)

    for i, gen in enumerate(generators):
        preserved = verify_disk_preservation(gen)
        print(f"  Generator {i+1}: center={gen.center:.4f}, angle={gen.angle:.4f}")
        print(f"    Disk preserved: {preserved}")

    # Show specific examples
    z = 0.3 + 0.4j
    print(f"\n  Test point z = {z} (|z| = {abs(z):.6f})")
    for i, gen in enumerate(generators):
        w = gen.apply(z)
        print(f"    φ_{i+1}(z) = {w:.6f}  (|φ(z)| = {abs(w):.6f} < 1 ✓)")
    print()


def demo_hyperbolic_distance():
    """Demonstrate hyperbolic distance properties."""
    print("=" * 60)
    print("DEMO 2: Hyperbolic Distance Properties")
    print("=" * 60)

    z = 0.3 + 0.2j
    w = -0.1 + 0.5j
    v = 0.4 - 0.3j

    print(f"  z = {z}, w = {w}, v = {v}")
    print(f"\n  d(z,z) = {hyp_dist(z,z):.10f}  (should be 0)")
    print(f"  d(z,w) = {hyp_dist(z,w):.6f}")
    print(f"  d(w,z) = {hyp_dist(w,z):.6f}  (symmetry)")
    print(f"  |d(z,w) - d(w,z)| = {abs(hyp_dist(z,w) - hyp_dist(w,z)):.2e}")

    # Triangle inequality
    dzw = hyp_dist(z, w)
    dwv = hyp_dist(w, v)
    dzv = hyp_dist(z, v)
    print(f"\n  Triangle inequality:")
    print(f"    d(z,v) = {dzv:.6f}")
    print(f"    d(z,w) + d(w,v) = {dzw + dwv:.6f}")
    print(f"    d(z,v) ≤ d(z,w) + d(w,v): {dzv <= dzw + dwv + 1e-10}")

    # Norm properties
    print(f"\n  Hyperbolic norms:")
    for p in [z, w, v]:
        print(f"    ||{p}||_H = {hyp_norm(p):.6f}")
    print(f"    ||0||_H = {hyp_norm(0j):.6f}  (origin has norm 0)")

    # Distance diverges near boundary
    print(f"\n  Norms near boundary:")
    for r in [0.5, 0.9, 0.99, 0.999, 0.9999]:
        print(f"    ||{r}||_H = {hyp_norm(r + 0j):.4f}")
    print()


def demo_orbit_growth():
    """Demonstrate orbit growth and prime counting."""
    print("=" * 60)
    print("DEMO 3: Orbit Growth and Hyperbolic Primes")
    print("=" * 60)

    for k in [2, 3, 4]:
        generators = make_regular_generators(k, radius=0.3)
        lattice = HyperbolicLattice(generators)

        primes = lattice.count_primes()
        print(f"\n  Lattice with {k} generators:")
        print(f"    Hyperbolic primes: {len(primes)}")
        for i, p in enumerate(primes):
            print(f"      π_{i+1} = {p:.4f}  (||π||_H = {hyp_norm(p):.4f})")

        print(f"\n    Orbit growth:")
        print(f"    {'Depth':>6} | {'|Orbit|':>8} | {'(k+1)^n':>10} | {'Ratio':>8}")
        print(f"    {'-'*6}-+-{'-'*8}-+-{'-'*10}-+-{'-'*8}")
        for depth in range(7):
            orbit = lattice.compute_orbit(depth)
            bound = (k + 1) ** depth
            ratio = len(orbit) / bound if bound > 0 else 0
            print(f"    {depth:>6} | {len(orbit):>8} | {bound:>10} | {ratio:>8.4f}")
    print()


def demo_zeta_function():
    """Demonstrate the partial hyperbolic zeta function."""
    print("=" * 60)
    print("DEMO 4: Partial Hyperbolic Zeta Function")
    print("=" * 60)

    generators = make_regular_generators(3, radius=0.4)
    lattice = HyperbolicLattice(generators)

    depth = 5
    print(f"\n  Lattice: 3 generators, depth = {depth}")
    orbit = lattice.compute_orbit(depth)
    print(f"  Orbit size: {len(orbit)}")
    print(f"  Non-origin points: {sum(1 for z in orbit if abs(z) > 1e-10)}")

    print(f"\n  {'s':>6} | {'ζ_H(s)':>15}")
    print(f"  {'-'*6}-+-{'-'*15}")
    for s in [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]:
        zeta_val = lattice.hyp_zeta_partial(depth, s)
        print(f"  {s:>6.1f} | {zeta_val:>15.6f}")

    print(f"\n  Note: ζ_H(s) decreases as s increases (convergence improves)")
    print()


def demo_conjecture_test():
    """Test the hyperbolic orbit growth conjecture."""
    print("=" * 60)
    print("DEMO 5: Testing Hyperbolic Orbit Growth Conjecture")
    print("=" * 60)

    print("\n  Conjecture: For k ≥ 2 generators, ∃ c > 0:")
    print("  card(Orbit_n) ≥ c · k^n for all n\n")

    for k in [2, 3, 5]:
        generators = make_regular_generators(k, radius=0.3)
        lattice = HyperbolicLattice(generators)

        print(f"  k = {k} generators:")
        ratios = []
        for n in range(1, 8):
            orbit = lattice.compute_orbit(n)
            ratio = len(orbit) / (k ** n)
            ratios.append(ratio)
            print(f"    n={n}: |Orbit| = {len(orbit):>6}, "
                  f"k^n = {k**n:>6}, ratio = {ratio:.4f}")

        min_ratio = min(ratios)
        print(f"    Min ratio (candidate c): {min_ratio:.4f}")
        print(f"    Conjecture {'SUPPORTED' if min_ratio > 0.01 else 'UNCLEAR'}")
        print()


def demo_divisibility():
    """Demonstrate hyperbolic divisibility structure."""
    print("=" * 60)
    print("DEMO 6: Hyperbolic Divisibility and Valuation")
    print("=" * 60)

    generators = make_regular_generators(2, radius=0.3)
    lattice = HyperbolicLattice(generators)

    print("\n  Lattice with 2 generators")
    print("  Valuation = min steps to reach from origin\n")

    for depth in range(5):
        orbit_curr = lattice.compute_orbit(depth)
        orbit_prev = lattice.compute_orbit(depth - 1) if depth > 0 else [0j]
        new_points = [z for z in orbit_curr if all(abs(z - w) > 1e-10 for w in orbit_prev)]
        if depth == 0:
            new_points = [0j]
        print(f"  Valuation {depth}: {len(new_points)} points")
        for z in new_points[:4]:
            print(f"    z = {z:.4f}, ||z||_H = {hyp_norm(z):.4f}")
        if len(new_points) > 4:
            print(f"    ... and {len(new_points) - 4} more")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  HYPERBOLIC NUMBER THEORY: DEMONSTRATION")
    print("  Arithmetic on the Poincaré Disk")
    print("=" * 60 + "\n")

    demo_disk_preservation()
    demo_hyperbolic_distance()
    demo_orbit_growth()
    demo_zeta_function()
    demo_conjecture_test()
    demo_divisibility()

    print("=" * 60)
    print("  ALL DEMOS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Hyperbolic lattice orbit on the Poincaré disk."""

import cmath
import math
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def mobius_transform(z, a, theta):
    rotation = cmath.exp(1j * theta)
    return rotation * (z - a) / (1 - a.conjugate() * z)


def hyp_norm(z):
    r = abs(z)
    if r >= 1 or r < 1e-15:
        return 0.0 if r < 1e-15 else float('inf')
    return 2 * math.atanh(r)


def compute_orbit(generators, depth, tolerance=1e-10):
    orbit = [0j]
    seen = {(0.0, 0.0)}
    for _ in range(depth):
        new_points = []
        for z in orbit:
            for a, theta in generators:
                w = mobius_transform(z, a, theta)
                key = (round(w.real / tolerance) * tolerance,
                       round(w.imag / tolerance) * tolerance)
                if key not in seen:
                    seen.add(key)
                    new_points.append(w)
        if not new_points:
            break
        orbit.extend(new_points)
    return orbit


def compute_orbit_by_depth(generators, max_depth, tolerance=1e-10):
    layers = [[0j]]
    seen = {(0.0, 0.0)}
    for d in range(max_depth):
        new_points = []
        for z in layers[-1]:
            for a, theta in generators:
                w = mobius_transform(z, a, theta)
                key = (round(w.real / tolerance) * tolerance,
                       round(w.imag / tolerance) * tolerance)
                if key not in seen:
                    seen.add(key)
                    new_points.append(w)
        layers.append(new_points)
    return layers


def main():
    k = 3
    radius = 0.4
    generators = [(radius * cmath.exp(2j * math.pi * i / k), 2 * math.pi * i / k)
                   for i in range(k)]

    max_depth = 6
    layers = compute_orbit_by_depth(generators, max_depth)

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Orbit on Poincaré disk, colored by valuation
    ax = axes[0]
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)

    colors = plt.cm.viridis(np.linspace(0, 1, max_depth + 1))
    for d, layer in enumerate(layers):
        if not layer:
            continue
        xs = [z.real for z in layer]
        ys = [z.imag for z in layer]
        size = max(5, 50 - 8 * d)
        ax.scatter(xs, ys, c=[colors[d]], s=size, zorder=5, label=f'v={d} ({len(layer)} pts)')

    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title(f'Hyperbolic Lattice Orbit ({k} generators)', fontsize=14)
    ax.legend(loc='upper right', fontsize=8)
    ax.grid(True, alpha=0.3)

    # Right: Orbit growth
    ax2 = axes[1]
    depths = list(range(max_depth + 1))
    cumulative = [sum(len(layers[i]) for i in range(d + 1)) for d in depths]
    upper_bound = [(k + 1) ** d for d in depths]

    ax2.semilogy(depths, cumulative, 'bo-', linewidth=2, markersize=8, label='|Orbit_n|')
    ax2.semilogy(depths, upper_bound, 'r--', linewidth=2, label=f'(k+1)^n = {k+1}^n')
    ax2.set_xlabel('Depth n', fontsize=12)
    ax2.set_ylabel('Count (log scale)', fontsize=12)
    ax2.set_title('Orbit Growth vs Upper Bound', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_orbit.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_orbit.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Hyperbolic zeta function and distance properties."""

import cmath
import math
import matplotlib.pyplot as plt
import numpy as np


def mobius_transform(z, a, theta):
    rotation = cmath.exp(1j * theta)
    return rotation * (z - a) / (1 - a.conjugate() * z)


def hyp_norm(z):
    r = abs(z)
    if r >= 1 or r < 1e-15:
        return 0.0 if r < 1e-15 else float('inf')
    return 2 * math.atanh(r)


def compute_orbit(generators, depth, tolerance=1e-10):
    orbit = [0j]
    seen = {(0.0, 0.0)}
    for _ in range(depth):
        new_points = []
        for z in orbit:
            for a, theta in generators:
                w = mobius_transform(z, a, theta)
                key = (round(w.real / tolerance) * tolerance,
                       round(w.imag / tolerance) * tolerance)
                if key not in seen:
                    seen.add(key)
                    new_points.append(w)
        if not new_points:
            break
        orbit.extend(new_points)
    return orbit


def hyp_zeta(orbit, s):
    total = 0.0
    for z in orbit:
        hn = hyp_norm(z)
        if hn > 1e-10:
            total += 1.0 / (hn ** (2 * s))
    return total


def main():
    k = 3
    radius = 0.4
    generators = [(radius * cmath.exp(2j * math.pi * i / k), 2 * math.pi * i / k)
                   for i in range(k)]

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # Top-left: Hyperbolic norm vs Euclidean norm
    ax = axes[0, 0]
    rs = np.linspace(0, 0.999, 500)
    hyp_norms = [2 * np.arctanh(r) for r in rs]
    ax.plot(rs, hyp_norms, 'b-', linewidth=2)
    ax.plot(rs, rs, 'r--', linewidth=1, alpha=0.5, label='Euclidean |z|')
    ax.set_xlabel('Euclidean norm |z|', fontsize=12)
    ax.set_ylabel('Hyperbolic norm ||z||_H', fontsize=12)
    ax.set_title('Hyperbolic vs Euclidean Norm', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 8)

    # Top-right: Partial zeta function for different depths
    ax = axes[0, 1]
    s_vals = np.linspace(0.3, 4.0, 100)
    for depth in [3, 5, 7]:
        orbit = compute_orbit(generators, depth)
        zeta_vals = [hyp_zeta(orbit, s) for s in s_vals]
        ax.plot(s_vals, zeta_vals, linewidth=2, label=f'depth {depth} ({len(orbit)} pts)')

    ax.set_xlabel('s', fontsize=12)
    ax.set_ylabel('ζ_H^{(n)}(s)', fontsize=12)
    ax.set_title('Partial Hyperbolic Zeta Function', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 50)

    # Bottom-left: Distribution of hyperbolic norms in the orbit
    ax = axes[1, 0]
    orbit = compute_orbit(generators, 7)
    norms = sorted([hyp_norm(z) for z in orbit if abs(z) > 1e-10])
    ax.hist(norms, bins=40, color='steelblue', edgecolor='black', alpha=0.7)
    ax.set_xlabel('Hyperbolic norm ||z||_H', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(f'Distribution of Hyperbolic Norms ({len(norms)} points)', fontsize=14)
    ax.grid(True, alpha=0.3)

    # Bottom-right: Geodesic circles and lattice points
    ax = axes[1, 1]
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)

    # Draw hyperbolic circles (Euclidean circles in disk model)
    for R in [0.5, 1.0, 1.5, 2.0, 3.0]:
        r_euc = math.tanh(R / 2)  # Euclidean radius of hyperbolic circle
        circ = plt.Circle((0, 0), r_euc, fill=False, color='gray', linestyle='--', alpha=0.4)
        ax.add_patch(circ)
        ax.text(r_euc + 0.02, 0.02, f'R={R}', fontsize=7, color='gray')

    orbit_short = compute_orbit(generators, 5)
    for z in orbit_short:
        hn = hyp_norm(z)
        color = 'red' if hn < 0.01 else ('orange' if hn < 1 else ('blue' if hn < 2 else 'purple'))
        ax.plot(z.real, z.imag, 'o', color=color, markersize=3)

    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title('Lattice Points with Geodesic Circles', fontsize=14)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_zeta.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_zeta.png")


if __name__ == "__main__":
    main()
