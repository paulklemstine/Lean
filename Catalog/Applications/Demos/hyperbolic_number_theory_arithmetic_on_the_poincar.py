"""
Demo: Hyperbolic Number Theory — Arithmetic on the Poincaré Disk

Demonstrates:
1. Möbius addition and its group properties
2. Orbit computation and convergence to the boundary
3. Associativity defect: 0 in 1D, nonzero in 2D
4. Pythagorean–hyperbolic bridge
5. Hyperbolic convolution ring
"""

from algorithms import (
    moebius_add, moebius_add_complex, moebius_orbit,
    hyp_dist_proxy, hyp_convolution, hyp_convolution_full,
    associativity_defect_1d, associativity_defect_2d,
    pythagorean_disk_points, hyperbolic_zeta_partial
)


def demo_moebius_addition():
    """Demonstrate Möbius addition properties."""
    print("=" * 60)
    print("1. MÖBIUS ADDITION ON THE POINCARÉ DISK")
    print("=" * 60)

    a, b = 0.3, 0.5
    s = moebius_add(a, b)
    print(f"\n  a = {a}, b = {b}")
    print(f"  a ⊕ b = {s:.10f}")
    print(f"  |a ⊕ b| < 1: {abs(s) < 1}")

    # Commutativity
    print(f"\n  Commutativity: a ⊕ b = {moebius_add(a, b):.10f}")
    print(f"                b ⊕ a = {moebius_add(b, a):.10f}")

    # Identity
    print(f"\n  Identity: a ⊕ 0 = {moebius_add(a, 0):.10f} (should be {a})")

    # Inverse
    print(f"  Inverse:  a ⊕ (-a) = {moebius_add(a, -a):.2e} (should be 0)")

    # Associativity in 1D
    c = 0.2
    lhs = moebius_add(moebius_add(a, b), c)
    rhs = moebius_add(a, moebius_add(b, c))
    print(f"\n  Associativity (1D):")
    print(f"    (a ⊕ b) ⊕ c = {lhs:.15f}")
    print(f"    a ⊕ (b ⊕ c) = {rhs:.15f}")
    print(f"    Defect = {abs(lhs - rhs):.2e}")


def demo_orbit():
    """Demonstrate Möbius orbit computation."""
    print("\n" + "=" * 60)
    print("2. MÖBIUS ORBIT: HYPERBOLIC INTEGERS")
    print("=" * 60)

    g = 0.5
    n = 20
    orbit = moebius_orbit(g, n)

    print(f"\n  Generator g = {g}")
    print(f"  First 10 orbit points:")
    for i in range(11):
        print(f"    O({i:2d}) = {orbit[i]:.10f}")

    print(f"\n  Last 5 orbit points (approaching boundary):")
    for i in range(n - 4, n + 1):
        print(f"    O({i:2d}) = {orbit[i]:.15f}  (1 - O = {1 - orbit[i]:.2e})")

    # Strict monotonicity check
    is_monotone = all(orbit[i] < orbit[i + 1] for i in range(n))
    print(f"\n  Strictly increasing: {is_monotone}")


def demo_associativity_defect():
    """Demonstrate 1D vs 2D associativity."""
    print("\n" + "=" * 60)
    print("3. ASSOCIATIVITY DEFECT: 1D vs 2D")
    print("=" * 60)

    # 1D test
    a1, b1, c1 = 1/3, 1/5, 1/7
    d1 = associativity_defect_1d(a1, b1, c1)
    print(f"\n  1D test: a={a1:.4f}, b={b1:.4f}, c={c1:.4f}")
    print(f"  δ(a,b,c) = {d1:.2e}  (should be ~0)")

    # 2D test (complex)
    z1 = complex(0.3, 0.4)
    z2 = complex(0.1, -0.2)
    z3 = complex(-0.1, 0.3)
    d2 = associativity_defect_2d(z1, z2, z3)
    print(f"\n  2D test: z₁={z1}, z₂={z2}, z₃={z3}")
    print(f"  δ(z₁,z₂,z₃) = {d2:.10f}  (should be > 0)")
    print(f"  Non-associativity confirmed: {d2 > 1e-10}")


def demo_pythagorean_bridge():
    """Demonstrate the Pythagorean–hyperbolic bridge."""
    print("\n" + "=" * 60)
    print("4. PYTHAGOREAN–HYPERBOLIC BRIDGE")
    print("=" * 60)

    triples = pythagorean_disk_points(50)
    print(f"\n  Pythagorean triples with c ≤ 50:")
    for a, b, c, ratio in triples[:10]:
        print(f"    ({a:2d}, {b:2d}, {c:2d}) → disk point a/c = {ratio:.6f}")

    # Möbius sum of 3/5 and 5/13
    p1 = 3 / 5   # from (3, 4, 5)
    p2 = 5 / 13  # from (5, 12, 13)
    s = moebius_add(p1, p2)
    print(f"\n  Möbius sum: 3/5 ⊕ 5/13 = {s:.10f} = {s} ≈ 4/5 = {4/5}")
    print(f"  This is the disk point of the triple (4, 3, 5)!")

    # Check closure: all pairwise sums stay in disk
    disk_points = [ratio for _, _, _, ratio in triples[:5]]
    print(f"\n  Closure check (first 5 Pythagorean disk points):")
    for i in range(len(disk_points)):
        for j in range(i + 1, len(disk_points)):
            s = moebius_add(disk_points[i], disk_points[j])
            print(f"    {disk_points[i]:.4f} ⊕ {disk_points[j]:.4f} = {s:.6f}  (|·| < 1: {abs(s) < 1})")


def demo_convolution():
    """Demonstrate the hyperbolic convolution ring."""
    print("\n" + "=" * 60)
    print("5. HYPERBOLIC CONVOLUTION RING")
    print("=" * 60)

    # Delta function
    delta = [1.0] + [0.0] * 9
    f = [1.0, 2.0, 3.0, 4.0, 5.0, 0.0, 0.0, 0.0, 0.0, 0.0]

    # Test identity: δ ⋆ f = f
    print(f"\n  f = {f[:5]}")
    conv_result = [hyp_convolution(delta, f, n) for n in range(5)]
    print(f"  δ ⋆ f = {conv_result}  (should equal f[:5])")

    # Test commutativity
    g_func = [0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    fg = [hyp_convolution(f, g_func, n) for n in range(5)]
    gf = [hyp_convolution(g_func, f, n) for n in range(5)]
    print(f"\n  f ⋆ g = {fg}")
    print(f"  g ⋆ f = {gf}")
    print(f"  Commutative: {fg == gf}")

    # Test associativity
    h_func = [1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    fg_full = hyp_convolution_full(f, g_func)
    gh_full = hyp_convolution_full(g_func, h_func)
    lhs = [hyp_convolution(fg_full, h_func, n) for n in range(5)]
    rhs = [hyp_convolution(f, gh_full, n) for n in range(5)]
    print(f"\n  (f ⋆ g) ⋆ h = {lhs}")
    print(f"  f ⋆ (g ⋆ h) = {rhs}")
    print(f"  Associative: {all(abs(a - b) < 1e-10 for a, b in zip(lhs, rhs))}")


def demo_zeta():
    """Demonstrate the hyperbolic zeta function."""
    print("\n" + "=" * 60)
    print("6. HYPERBOLIC ZETA FUNCTION")
    print("=" * 60)

    g = 0.5
    print(f"\n  Generator g = {g}")
    print(f"  ζ_H(s) = Σ |O(g,n)|^(-2s)")
    print(f"\n  {'s':>6}  {'ζ_H(s) (100 terms)':>20}  {'ζ_H(s) (500 terms)':>20}")
    print(f"  {'-'*6}  {'-'*20}  {'-'*20}")
    for s in [0.6, 0.8, 1.0, 1.5, 2.0, 3.0]:
        z100 = hyperbolic_zeta_partial(g, s, 100)
        z500 = hyperbolic_zeta_partial(g, s, 500)
        print(f"  {s:6.1f}  {z100:20.6f}  {z500:20.6f}")


def demo_hyperbolic_distances():
    """Demonstrate hyperbolic distance properties."""
    print("\n" + "=" * 60)
    print("7. HYPERBOLIC DISTANCES")
    print("=" * 60)

    points = [0.0, 0.1, 0.3, 0.5, 0.7, 0.9]
    print(f"\n  Distance matrix (hyperbolic distance proxy):")
    print(f"  {'':>6}", end="")
    for p in points:
        print(f"  {p:6.1f}", end="")
    print()

    for a in points:
        print(f"  {a:6.1f}", end="")
        for b in points:
            d = hyp_dist_proxy(a, b)
            print(f"  {d:6.4f}", end="")
        print()

    # Verify symmetry and self-distance
    print(f"\n  Symmetry check: d(0.3, 0.7) = {hyp_dist_proxy(0.3, 0.7):.10f}")
    print(f"                  d(0.7, 0.3) = {hyp_dist_proxy(0.7, 0.3):.10f}")
    print(f"  Self-distance:  d(0.5, 0.5) = {hyp_dist_proxy(0.5, 0.5):.10f}")


if __name__ == "__main__":
    demo_moebius_addition()
    demo_orbit()
    demo_associativity_defect()
    demo_pythagorean_bridge()
    demo_convolution()
    demo_zeta()
    demo_hyperbolic_distances()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


"""
Visualization: Associativity Defect — 1D vs 2D

Heatmap of the associativity defect δ(z₁, z₂, z₃) in the 2D complex disk,
showing that non-associativity is a genuine 2D phenomenon.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def moebius_add_complex(z: complex, w: complex) -> complex:
    return (z + w) / (1 + z.conjugate() * w)


def assoc_defect_2d(z1: complex, z2: complex, z3: complex) -> float:
    lhs = moebius_add_complex(moebius_add_complex(z1, z2), z3)
    rhs = moebius_add_complex(z1, moebius_add_complex(z2, z3))
    return abs(lhs - rhs)


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Fix z1 = 0.3 + 0.4i, z3 = -0.1 + 0.3i
    # Vary z2 across the disk
    z1 = complex(0.3, 0.4)
    z3 = complex(-0.1, 0.3)

    n = 100
    x = np.linspace(-0.8, 0.8, n)
    y = np.linspace(-0.8, 0.8, n)
    X, Y = np.meshgrid(x, y)
    Z = np.zeros((n, n))

    for i in range(n):
        for j in range(n):
            z2 = complex(X[i, j], Y[i, j])
            if abs(z2) < 0.95:
                Z[i, j] = assoc_defect_2d(z1, z2, z3)
            else:
                Z[i, j] = np.nan

    # Heatmap
    im = ax1.pcolormesh(X, Y, Z, cmap='hot', shading='auto')
    circle = plt.Circle((0, 0), 1, fill=False, color='white', linewidth=2)
    ax1.add_patch(circle)
    ax1.set_aspect('equal')
    ax1.set_title('Associativity Defect δ(z₁, z₂, z₃)\n'
                   f'z₁ = {z1}, z₃ = {z3}', fontsize=12)
    ax1.set_xlabel('Re(z₂)')
    ax1.set_ylabel('Im(z₂)')
    fig.colorbar(im, ax=ax1, label='δ')

    # Cross-section along real axis
    real_z2 = np.linspace(-0.9, 0.9, 200)
    defects_real = [assoc_defect_2d(z1, complex(r, 0), z3) for r in real_z2]
    defects_imag = [assoc_defect_2d(z1, complex(0, r), z3) for r in real_z2]

    ax2.plot(real_z2, defects_real, 'b-', linewidth=2, label='z₂ real')
    ax2.plot(real_z2, defects_imag, 'r-', linewidth=2, label='z₂ imaginary')
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel('z₂ value')
    ax2.set_ylabel('Defect δ')
    ax2.set_title('Defect Cross-Sections', fontsize=12)
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Non-Associativity of 2D Möbius Addition', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_defect.png', dpi=150, bbox_inches='tight')
    print("Saved viz_defect.png")


if __name__ == "__main__":
    main()


"""
Visualization: Möbius Orbit on the Poincaré Disk

Plots the orbit points O(g, 0), O(g, 1), ..., O(g, n) for various generators,
showing how they accumulate near the boundary.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def moebius_add(a: float, b: float) -> float:
    return (a + b) / (1 + a * b)


def moebius_orbit(g: float, n: int) -> list:
    orbit = [0.0]
    for _ in range(n):
        orbit.append(moebius_add(g, orbit[-1]))
    return orbit


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    generators = [0.2, 0.5, 0.8]
    n_steps = 30

    for ax, g in zip(axes, generators):
        orbit = moebius_orbit(g, n_steps)
        ns = list(range(n_steps + 1))

        # Plot orbit points
        ax.scatter(ns, orbit, c=ns, cmap='viridis', s=50, zorder=3, edgecolors='black', linewidth=0.5)

        # Plot the boundary at y=1
        ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Boundary')
        ax.axhline(y=0.0, color='gray', linestyle='-', alpha=0.3)

        # Connect points
        ax.plot(ns, orbit, 'b-', alpha=0.3)

        ax.set_title(f'Generator g = {g}', fontsize=14)
        ax.set_xlabel('Step n')
        ax.set_ylabel('O(g, n)')
        ax.set_ylim(-0.05, 1.05)
        ax.legend()
        ax.grid(True, alpha=0.3)

    fig.suptitle('Möbius Orbits: Hyperbolic Integers Approaching the Boundary', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_orbit.png', dpi=150, bbox_inches='tight')
    print("Saved viz_orbit.png")


if __name__ == "__main__":
    main()
