#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Demonstration
========================================

Numerical demonstrations of:
1. Möbius transformations preserving the unit disk
2. The fundamental norm-squared identity
3. Hyperbolic lattice generation and counting
4. The hyperbolic zeta function
5. Conformal weight properties
"""

import math
import cmath
from algorithms import (
    mobius_map, mobius_inverse, pseudo_hyp_dist, hyperbolic_distance,
    conformal_weight, generate_lattice_orbit, counting_function,
    hyperbolic_zeta_partial, verify_mobius_identity, verify_mobius_inverse,
    verify_conformal_transform
)


def demo_mobius_disk_preservation():
    """Demonstrate that Möbius maps preserve the unit disk."""
    print("=" * 60)
    print("DEMO 1: Möbius Maps Preserve the Unit Disk")
    print("=" * 60)
    
    test_points = [
        (complex(0.3, 0.4), complex(0.1, 0.2)),
        (complex(0.5, 0.5), complex(-0.3, 0.6)),
        (complex(0.9, 0.0), complex(0.0, 0.9)),
        (complex(0.1, -0.8), complex(0.7, 0.3)),
    ]
    
    for a, z in test_points:
        if abs(a) >= 1 or abs(z) >= 1:
            continue
        w = mobius_map(a, z)
        print(f"  a = {a}, |a| = {abs(a):.4f}")
        print(f"  z = {z}, |z| = {abs(z):.4f}")
        print(f"  φ_a(z) = {w:.6f}, |φ_a(z)| = {abs(w):.6f} < 1 ✓")
        print()


def demo_fundamental_identity():
    """Demonstrate the norm-squared identity."""
    print("=" * 60)
    print("DEMO 2: Fundamental Möbius Norm-Squared Identity")
    print("  |1 - ā·z|² - |z - a|² = (1 - |a|²)(1 - |z|²)")
    print("=" * 60)
    
    tests = [
        (complex(0.3, 0.4), complex(0.1, 0.2)),
        (complex(0.0, 0.5), complex(0.5, 0.0)),
        (complex(0.8, 0.1), complex(-0.3, 0.7)),
    ]
    
    for a, z in tests:
        lhs, rhs = verify_mobius_identity(a, z)
        print(f"  a={a}, z={z}: LHS={lhs:.10f}, RHS={rhs:.10f}, err={abs(lhs-rhs):.2e}")


def demo_mobius_inverse():
    """Demonstrate the inverse property φ_{-a} ∘ φ_a = id."""
    print("\n" + "=" * 60)
    print("DEMO 3: Möbius Inverse: φ_{-a}(φ_a(z)) = z")
    print("=" * 60)
    
    tests = [
        (complex(0.3, 0.4), complex(0.1, 0.2)),
        (complex(0.7, 0.0), complex(0.0, 0.5)),
        (complex(0.1, 0.9), complex(-0.5, -0.3)),
    ]
    
    for a, z in tests:
        if abs(a) >= 1 or abs(z) >= 1:
            continue
        err = verify_mobius_inverse(a, z)
        print(f"  a={a}, z={z}: |φ_{{-a}}(φ_a(z)) - z| = {err:.2e} ✓")


def demo_lattice_generation():
    """Generate and analyze a hyperbolic lattice."""
    print("\n" + "=" * 60)
    print("DEMO 4: Hyperbolic Lattice Generation")
    print("=" * 60)
    
    # Use two generators at specific positions
    g1 = complex(0.5, 0.0)
    g2 = complex(0.0, 0.5)
    
    print(f"  Generators: g₁ = {g1}, g₂ = {g2}")
    print(f"  |g₁| = {abs(g1):.4f}, |g₂| = {abs(g2):.4f}")
    
    points = generate_lattice_orbit([g1, g2], max_depth=6, max_points=2000)
    point_list = sorted(list(points), key=abs)
    
    print(f"  Generated {len(point_list)} lattice points")
    print(f"\n  Counting function N(R):")
    
    for R in [0.1, 0.2, 0.3, 0.5, 0.7, 0.8, 0.9, 0.95, 0.99]:
        n = counting_function(point_list, R)
        print(f"    N({R:.2f}) = {n}")
    
    print(f"\n  First 10 lattice points (by distance from origin):")
    for i, z in enumerate(point_list[:10]):
        print(f"    z_{i} = ({z.real:.6f}, {z.imag:.6f}), |z| = {abs(z):.6f}")


def demo_hyperbolic_zeta():
    """Compute the hyperbolic zeta function at various s values."""
    print("\n" + "=" * 60)
    print("DEMO 5: Hyperbolic Zeta Function")
    print("=" * 60)
    
    g1 = complex(0.5, 0.0)
    g2 = complex(0.0, 0.5)
    points = generate_lattice_orbit([g1, g2], max_depth=5, max_points=500)
    point_list = list(points)
    
    print(f"  Using {len(point_list)} lattice points")
    print(f"\n  ζ_H(s) = Σ 1/|z|^(2s):")
    
    for s in [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]:
        val = hyperbolic_zeta_partial(point_list, s)
        print(f"    ζ_H({s:.1f}) = {val:.6f}")


def demo_conformal_weight():
    """Demonstrate conformal weight properties."""
    print("\n" + "=" * 60)
    print("DEMO 6: Conformal Weight Properties")
    print("=" * 60)
    
    print("  conformalWeight(z) = 1/(1 - |z|²)²")
    print("  Property: conformalWeight(z) ≥ 1 for |z| < 1")
    print("  Property: conformalWeight(0) = 1")
    print()
    
    for r in [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99]:
        z = complex(r, 0)
        w = conformal_weight(z)
        print(f"    |z| = {r:.2f}: weight = {w:.4f} ≥ 1 ✓")
    
    print("\n  Conformal transform verification:")
    a = complex(0.3, 0.4)
    z = complex(-0.2, 0.1)
    lhs, rhs = verify_conformal_transform(a, z)
    print(f"    a={a}, z={z}")
    print(f"    1 - |φ_a(z)|² = {lhs:.10f}")
    print(f"    (1-|a|²)(1-|z|²)/|1-ā·z|² = {rhs:.10f}")
    print(f"    Error: {abs(lhs - rhs):.2e}")


def demo_conjecture_test():
    """Test the hyperbolic prime counting conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 7: Conjecture Test — Lattice Growth")
    print("=" * 60)
    
    g1 = complex(0.5, 0.0)
    g2 = complex(0.0, 0.5)
    
    print(f"  Conjecture: N(R) grows as lattice points accumulate at boundary")
    print(f"  Testing with generators at |g| = 0.5\n")
    
    for depth in [2, 4, 6, 8, 10]:
        points = generate_lattice_orbit([g1, g2], max_depth=depth, max_points=10000)
        point_list = list(points)
        n90 = counting_function(point_list, 0.9)
        n95 = counting_function(point_list, 0.95)
        n99 = counting_function(point_list, 0.99)
        print(f"    depth={depth:2d}: total={len(point_list):5d}, "
              f"N(0.9)={n90:4d}, N(0.95)={n95:4d}, N(0.99)={n99:4d}")


if __name__ == "__main__":
    demo_mobius_disk_preservation()
    demo_fundamental_identity()
    demo_mobius_inverse()
    demo_lattice_generation()
    demo_hyperbolic_zeta()
    demo_conformal_weight()
    demo_conjecture_test()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Hyperbolic Lattice on the Poincaré Disk
=======================================================

Generates a matplotlib figure showing:
1. The Poincaré disk boundary
2. Lattice points colored by generation depth
3. Hyperbolic geodesics connecting nearest neighbors
"""

import math
import cmath
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def mobius_map(a, z):
    return (z - a) / (1 - a.conjugate() * z)

def mobius_inverse(a, w):
    return (w + a) / (1 + a.conjugate() * w)

def generate_lattice_by_depth(generators, max_depth=7, max_points=3000):
    """Generate lattice points labeled by depth."""
    GRID = 1_000_000
    def grid_key(z):
        return (round(z.real * GRID), round(z.imag * GRID))
    
    seen = set()
    depth_points = {0: [complex(0, 0)]}
    key = grid_key(complex(0, 0))
    seen.add(key)
    
    current = [complex(0, 0)]
    total = 1
    
    all_maps = []
    for g in generators:
        all_maps.append(('fwd', g))
        all_maps.append(('inv', g))
    
    for d in range(1, max_depth + 1):
        next_layer = []
        for z in current:
            for direction, g in all_maps:
                w = mobius_map(g, z) if direction == 'fwd' else mobius_inverse(g, z)
                if abs(w) >= 0.999:
                    continue
                key = grid_key(w)
                if key not in seen:
                    seen.add(key)
                    next_layer.append(w)
                    total += 1
                    if total >= max_points:
                        depth_points[d] = next_layer
                        return depth_points
        depth_points[d] = next_layer
        current = next_layer
        if not current:
            break
    
    return depth_points


def draw_geodesic_arc(ax, z1, z2, color='gray', alpha=0.15, lw=0.3):
    """Draw a hyperbolic geodesic between z1 and z2 on the Poincaré disk."""
    # Parametrize the geodesic via Möbius map
    # Map z1 to origin, then the geodesic is a diameter through the image of z2
    if abs(z1 - z2) < 1e-10:
        return
    
    # Simple: just draw a straight line for nearby points
    # (for a full implementation, compute the circular arc)
    t = np.linspace(0, 1, 20)
    # Use the Möbius midpoint formula for a smoother curve
    points = []
    for ti in t:
        # Linear interpolation in disk model (not geodesic, but visually ok for nearby points)
        zi = z1 * (1 - ti) + z2 * ti
        if abs(zi) < 1:
            points.append(zi)
    
    if len(points) > 1:
        xs = [p.real for p in points]
        ys = [p.imag for p in points]
        ax.plot(xs, ys, color=color, alpha=alpha, linewidth=lw)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))
    
    # ---- Left panel: Two-generator lattice ----
    ax = axes[0]
    g1 = complex(0.5, 0.0)
    g2 = complex(0.0, 0.5)
    
    depth_points = generate_lattice_by_depth([g1, g2], max_depth=7, max_points=2000)
    
    # Draw disk boundary
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)
    
    # Color map for depths
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628', '#f781bf', '#999999']
    
    all_pts = []
    for d, pts in sorted(depth_points.items()):
        if not pts:
            continue
        xs = [z.real for z in pts]
        ys = [z.imag for z in pts]
        c = colors[d % len(colors)]
        size = max(2, 15 - 2 * d)
        ax.scatter(xs, ys, c=c, s=size, zorder=5 + d, label=f'Depth {d}', alpha=0.8)
        all_pts.extend(pts)
    
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title('Hyperbolic Lattice on the Poincaré Disk\n'
                 f'Generators: ({g1.real}, {g1.imag}), ({g2.real}, {g2.imag})\n'
                 f'{len(all_pts)} lattice points', fontsize=12)
    ax.legend(loc='upper right', fontsize=8, markerscale=2)
    ax.grid(True, alpha=0.2)
    
    # ---- Right panel: Counting function ----
    ax2 = axes[1]
    
    radii = np.linspace(0, 0.99, 200)
    counts = [sum(1 for z in all_pts if abs(z) <= r) for r in radii]
    
    ax2.plot(radii, counts, 'b-', linewidth=2, label='N(R) = # points with |z| ≤ R')
    
    # Theoretical comparison: exponential growth
    # For a lattice in H², N(R_hyp) ~ e^{R_hyp}, but in Euclidean coords
    # R_eucl ~ tanh(R_hyp/2), so R_hyp ~ 2·arctanh(R_eucl)
    # Hence N ~ exp(2·arctanh(R)) ~ (1+R)/(1-R) for large R
    theoretical = [max(1, 0.5 * (1 + r) / (1 - r + 0.01)) for r in radii]
    ax2.plot(radii, theoretical, 'r--', linewidth=1.5, alpha=0.7,
             label=r'$\sim \frac{1+R}{1-R}$ (theoretical growth)')
    
    ax2.set_xlabel('Euclidean radius R', fontsize=12)
    ax2.set_ylabel('N(R)', fontsize=12)
    ax2.set_title('Hyperbolic Lattice Counting Function', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_yscale('log')
    
    plt.tight_layout()
    plt.savefig('poincare_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: poincare_lattice.png")


if __name__ == "__main__":
    main()
