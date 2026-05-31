"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk — Demo

Demonstrates Möbius addition, hyperbolic distance, orbit generation,
prime detection, and conjecture verification.
"""

from algorithms import (
    moebius_add, moebius_iter, hyp_norm, hyp_distance,
    generate_moebius_orbit, find_hyp_primes, verify_orbit_growth_conjecture,
    hyp_zeta_partial
)


def main():
    print("=" * 70)
    print("  HYPERBOLIC NUMBER THEORY: Arithmetic on the Poincaré Disk")
    print("=" * 70)

    # --- 1. Möbius Addition ---
    print("\n1. MÖBIUS ADDITION a ⊕ b = (a+b)/(1+ab)")
    print("-" * 50)
    pairs = [(0.3, 0.5), (0.5, 0.5), (-0.3, 0.3), (0.9, 0.9)]
    for a, b in pairs:
        result = moebius_add(a, b)
        print(f"   {a:6.3f} ⊕ {b:6.3f} = {result:8.5f}  (|result| = {abs(result):.5f})")

    # --- 2. Identity and Inverse ---
    print("\n2. IDENTITY AND INVERSE")
    print("-" * 50)
    for a in [0.3, 0.7, -0.5]:
        print(f"   0 ⊕ {a} = {moebius_add(0, a):.6f}")
        print(f"   {a} ⊕ (-{a}) = {moebius_add(a, -a):.6f}")

    # --- 3. Möbius Iterates ---
    print("\n3. MÖBIUS ITERATES g^{⊕n} (g = 0.5)")
    print("-" * 50)
    g = 0.5
    orbit = generate_moebius_orbit(g, 15)
    for i, x in enumerate(orbit):
        hn = hyp_norm(x) if abs(x) > 1e-15 else 0.0
        print(f"   g^{{⊕{i:2d}}} = {x:10.7f}   hypNorm = {hn:10.4f}")

    # --- 4. Hyperbolic Distance ---
    print("\n4. HYPERBOLIC DISTANCE")
    print("-" * 50)
    pts = [(0.0, 0.5), (0.3, 0.7), (-0.2, 0.8)]
    for a, b in pts:
        d = hyp_distance(a, b)
        print(f"   d({a:5.2f}, {b:5.2f}) = {d:.6f}")
    # Symmetry check
    d1 = hyp_distance(0.3, 0.7)
    d2 = hyp_distance(0.7, 0.3)
    print(f"\n   Symmetry check: d(0.3, 0.7) = {d1:.10f}")
    print(f"                   d(0.7, 0.3) = {d2:.10f}")
    print(f"                   Equal: {abs(d1 - d2) < 1e-14}")

    # --- 5. Hyperbolic Primes ---
    print("\n5. HYPERBOLIC PRIMES (lattice from g = 0.5, n = 20)")
    print("-" * 50)
    orbit_full = generate_moebius_orbit(0.5, 20)
    # Include negatives
    lattice = sorted(set(orbit_full + [-x for x in orbit_full]))
    primes = find_hyp_primes(lattice)
    print(f"   Lattice size: {len(lattice)}")
    print(f"   Number of hyperbolic primes: {len(primes)}")
    for p in sorted(primes, key=abs):
        print(f"     prime: {p:10.7f}  hypNorm = {hyp_norm(p):.4f}")

    # --- 6. Orbit Growth Conjecture ---
    print("\n6. ORBIT GROWTH CONJECTURE VERIFICATION")
    print("   Conjecture: g^{⊕n} > 1 - 2/(n+1) for g = 0.5, n ≥ 1")
    print("-" * 50)
    passed, results = verify_orbit_growth_conjecture(0.5, 50)
    print(f"   All 50 tests passed: {passed}")
    print("\n   Sample values:")
    for n, actual, bound in results[:10]:
        margin = actual - bound
        print(f"     n={n:3d}: g^{{⊕n}} = {actual:.8f} > {bound:.8f}  (margin: {margin:.6f})")

    # --- 7. Hyperbolic Zeta Partial Sums ---
    print("\n7. HYPERBOLIC ZETA FUNCTION (partial sums)")
    print("-" * 50)
    orbit_200 = generate_moebius_orbit(0.5, 200)
    full_lattice = sorted(set(orbit_200 + [-x for x in orbit_200]))
    for s in [1.0, 1.5, 2.0, 3.0]:
        zval = hyp_zeta_partial(full_lattice, s)
        print(f"   ζ_H({s:.1f}) ≈ {zval:.6f}  (over {len(full_lattice)} lattice points)")

    # --- 8. Fundamental Identity Check ---
    print("\n8. FUNDAMENTAL IDENTITY: (a+b)² - (1+ab)² = -((1-a²)(1-b²))")
    print("-" * 50)
    for a, b in [(0.3, 0.4), (0.7, 0.8), (-0.5, 0.9)]:
        lhs = (a + b) ** 2 - (1 + a * b) ** 2
        rhs = -((1 - a ** 2) * (1 - b ** 2))
        print(f"   a={a:5.2f}, b={b:5.2f}: LHS={lhs:.10f}, RHS={rhs:.10f}, match={abs(lhs - rhs) < 1e-14}")

    print("\n" + "=" * 70)
    print("  DEMO COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization: Hyperbolic Tessellation and Lattice Points

Shows the Poincaré disk with lattice points from Möbius iteration,
colored by hyperbolic norm, with geodesic arcs.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def moebius_add_complex(z: complex, w: complex) -> complex:
    return (z + w) / (1 + z.conjugate() * w)


def hyp_norm_complex(z: complex) -> float:
    r = abs(z)
    if r >= 1:
        return float('inf')
    return r / (1 - r)


def generate_lattice_2d(generators: list, depth: int) -> list:
    """Generate lattice points by applying generators repeatedly."""
    points = {0 + 0j}
    frontier = {0 + 0j}

    for _ in range(depth):
        new_frontier = set()
        for p in frontier:
            for g in generators:
                new_p = moebius_add_complex(p, g)
                if abs(new_p) < 0.999:
                    # Discretize to avoid floating point duplicates
                    key = round(new_p.real, 8) + round(new_p.imag, 8) * 1j
                    if key not in points:
                        points.add(key)
                        new_frontier.add(key)
                neg_g = -g
                new_p2 = moebius_add_complex(p, neg_g)
                if abs(new_p2) < 0.999:
                    key2 = round(new_p2.real, 8) + round(new_p2.imag, 8) * 1j
                    if key2 not in points:
                        points.add(key2)
                        new_frontier.add(key2)
        frontier = new_frontier
        if not frontier:
            break

    return list(points)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 7))

    # --- Panel 1: Lattice from two generators ---
    ax = axes[0]
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)

    g1 = 0.3 + 0.1j
    g2 = 0.05 + 0.35j
    lattice = generate_lattice_2d([g1, g2], depth=6)

    xs = [z.real for z in lattice]
    ys = [z.imag for z in lattice]
    norms = [hyp_norm_complex(z) for z in lattice]
    max_norm = max(n for n in norms if n < float('inf')) if norms else 1

    scatter = ax.scatter(xs, ys, c=norms, cmap='plasma', s=15,
                          vmin=0, vmax=min(max_norm, 50), edgecolors='none')
    plt.colorbar(scatter, ax=ax, label='Hyperbolic Norm')

    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title(f'Hyperbolic Lattice ({len(lattice)} points)\n'
                 f'Generators: {g1}, {g2}')
    ax.grid(True, alpha=0.2)

    # --- Panel 2: Orbit density histogram ---
    ax = axes[1]
    radii = [abs(z) for z in lattice if abs(z) > 0.001]
    hyp_dists = [0.5 * np.log((1 + r) / (1 - r)) for r in radii if r < 1]

    ax.hist(hyp_dists, bins=30, color='steelblue', edgecolor='white', alpha=0.8)
    ax.set_xlabel('Hyperbolic Distance from Origin')
    ax.set_ylabel('Number of Lattice Points')
    ax.set_title('Distribution of Lattice Points\nby Hyperbolic Distance')
    ax.grid(True, alpha=0.3)

    # Overlay theoretical growth: area of hyperbolic disk ~ sinh²(R)
    R_vals = np.linspace(0, max(hyp_dists) if hyp_dists else 5, 100)
    # Area of hyperbolic disk of radius R is 4π sinh²(R/2)
    # So point density should grow like sinh(R) (derivative of area)
    if hyp_dists:
        bin_width = (max(hyp_dists) - min(hyp_dists)) / 30
        scale = len(hyp_dists) * bin_width / np.max(np.sinh(R_vals) + 0.01)
        ax.plot(R_vals, scale * np.sinh(R_vals), 'r-', linewidth=2,
                label='~sinh(R) growth')
        ax.legend()

    plt.tight_layout()
    plt.savefig('viz_hyperbolic_tessellation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_hyperbolic_tessellation.png")


if __name__ == "__main__":
    main()


"""
Visualization: Möbius Orbits on the Poincaré Disk

Shows how Möbius iteration maps points through the disk,
with orbit trajectories and the approach to the boundary.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def moebius_add(a: float, b: float) -> float:
    return (a + b) / (1 + a * b)


def moebius_iter(g: float, n: int) -> float:
    result = 0.0
    for _ in range(n):
        result = moebius_add(result, g)
    return result


def moebius_add_complex(z: complex, w: complex) -> complex:
    return (z + w) / (1 + z.conjugate() * w)


def generate_complex_orbit(g: complex, n: int) -> list:
    orbit = [0 + 0j]
    for _ in range(1, n):
        orbit.append(moebius_add_complex(orbit[-1], g))
    return orbit


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # --- Panel 1: Real Möbius orbits ---
    ax = axes[0]
    generators = [0.2, 0.3, 0.5, 0.7, 0.9]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(generators)))
    for g, c in zip(generators, colors):
        ns = range(20)
        vals = [moebius_iter(g, n) for n in ns]
        ax.plot(ns, vals, 'o-', color=c, markersize=4, label=f'g={g}')
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Boundary')
    ax.axhline(y=-1, color='red', linestyle='--', alpha=0.5)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('g^{⊕n}')
    ax.set_title('Möbius Iterates Approach the Boundary')
    ax.legend(fontsize=8)
    ax.set_ylim(-0.1, 1.1)
    ax.grid(True, alpha=0.3)

    # --- Panel 2: Complex orbits on disk ---
    ax = axes[1]
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)

    complex_gens = [0.3 + 0.2j, 0.1 + 0.4j, -0.2 + 0.3j, 0.4 - 0.1j]
    colors2 = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    for g, c in zip(complex_gens, colors2):
        orbit = generate_complex_orbit(g, 30)
        xs = [z.real for z in orbit]
        ys = [z.imag for z in orbit]
        ax.plot(xs, ys, 'o-', color=c, markersize=3, alpha=0.7,
                label=f'g={g.real:.1f}+{g.imag:.1f}i')
        ax.plot(xs[0], ys[0], 's', color=c, markersize=8)

    ax.set_xlim(-1.2, 1.2)
    ax.set_ylim(-1.2, 1.2)
    ax.set_aspect('equal')
    ax.set_title('Complex Möbius Orbits in the Poincaré Disk')
    ax.legend(fontsize=7, loc='lower left')
    ax.grid(True, alpha=0.3)

    # --- Panel 3: Growth rate comparison ---
    ax = axes[2]
    g = 0.5
    ns = np.arange(1, 30)
    iterates = [moebius_iter(g, int(n)) for n in ns]
    bound = 1 - 2 / (ns + 1)
    euclidean = np.minimum(ns * g, 0.999)

    ax.plot(ns, iterates, 'bo-', markersize=4, label='Möbius g^{⊕n}')
    ax.plot(ns, bound, 'r--', linewidth=2, label='Bound: 1 - 2/(n+1)')
    ax.fill_between(ns, bound, iterates, alpha=0.2, color='green',
                     label='Margin')
    ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('n')
    ax.set_ylabel('Value')
    ax.set_title('Orbit Growth Conjecture (g=0.5)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_moebius_orbits.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_moebius_orbits.png")


if __name__ == "__main__":
    main()
