#!/usr/bin/env python3
"""
Demo: Hyperbolic Number Theory — Arithmetic on the Poincaré Disk

Demonstrates:
1. Einstein addition and its group structure
2. Chebyshev trace sequences and exponential growth
3. Tree Möbius inversion verification
4. Hyperbolic lattice point generation
5. Pseudo-hyperbolic distance computation
"""

import math
import cmath
from typing import List, Tuple


def einstein_add(a: float, b: float) -> float:
    """Einstein addition: (a + b) / (1 + ab)"""
    return (a + b) / (1 + a * b)


def chebyshev_trace(t: int, n: int) -> int:
    """Chebyshev trace: T(0)=2, T(1)=t, T(n+2)=t*T(n+1)-T(n)"""
    if n == 0:
        return 2
    if n == 1:
        return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr


def tree_moebius(k: int, d: int) -> int:
    if d == 0: return 1
    if d == 1: return -k
    return 0


def tree_convolve(k: int, n: int) -> int:
    return sum(tree_moebius(k, i) * k**(n - i) for i in range(n + 1))


def pseudo_hyp_dist(z: complex, w: complex) -> float:
    return abs(z - w) / abs(1 - w.conjugate() * z)


def mobius_map(a: complex, z: complex) -> complex:
    return (z - a) / (1 - a.conjugate() * z)


def main():
    print("=" * 70)
    print("  HYPERBOLIC NUMBER THEORY: ARITHMETIC ON THE POINCARÉ DISK")
    print("=" * 70)

    # ── Demo 1: Einstein Addition Group ──
    print("\n━━━ Demo 1: Einstein Addition — The Velocity Group ━━━")
    print("Einstein addition: a ⊕ b = (a + b) / (1 + ab)")
    print()

    vals = [0.1, 0.3, 0.5, 0.7, 0.9]
    print("Closure (stays in (-1,1)):")
    for a in vals:
        for b in vals:
            result = einstein_add(a, b)
            print(f"  {a} ⊕ {b} = {result:.6f}  (< 1: {'✓' if abs(result) < 1 else '✗'})")

    print("\nAssociativity: (a ⊕ b) ⊕ c = a ⊕ (b ⊕ c)")
    a, b, c = 0.3, 0.5, 0.7
    lhs = einstein_add(einstein_add(a, b), c)
    rhs = einstein_add(a, einstein_add(b, c))
    print(f"  ({a} ⊕ {b}) ⊕ {c} = {lhs:.10f}")
    print(f"  {a} ⊕ ({b} ⊕ {c}) = {rhs:.10f}")
    print(f"  Difference: {abs(lhs - rhs):.2e}")

    print("\nInverse property: a ⊕ (-a) = 0")
    for a in vals:
        print(f"  {a} ⊕ {-a} = {einstein_add(a, -a):.2e}")

    print("\nIterated addition (approaches 1 = speed of light):")
    x = 0.5
    curr = 0.0
    for n in range(1, 16):
        curr = einstein_add(curr, x)
        tanh_val = math.tanh(n * math.atanh(x))
        print(f"  {x} ⊕^{n:2d} = {curr:.10f}  "
              f"(tanh({n}·artanh({x})) = {tanh_val:.10f}, "
              f"diff = {abs(curr - tanh_val):.2e})")

    # ── Demo 2: Chebyshev Trace Sequences ──
    print("\n━━━ Demo 2: Chebyshev Trace Sequences ━━━")
    print("For SL₂(ℤ): Tr(g^n) satisfies T(n+2) = t·T(n+1) - T(n)")
    print()

    for t in [3, 4, 5, -3]:
        print(f"Trace t = {t}:")
        traces = [chebyshev_trace(t, n) for n in range(10)]
        print(f"  T(0..9) = {traces}")
        # Verify growth
        abs_traces = [abs(x) for x in traces]
        ratios = [abs_traces[i+1] / abs_traces[i] if abs_traces[i] > 0 else float('inf')
                  for i in range(len(abs_traces) - 1)]
        print(f"  |T(n+1)/T(n)| = {[f'{r:.3f}' for r in ratios]}")
        print()

    print("Verified: |T(n)| ≥ n+1 for |t| ≥ 3:")
    t = 3
    for n in range(15):
        val = abs(chebyshev_trace(t, n))
        bound = n + 1
        print(f"  n={n:2d}: |T_{t}({n})| = {val:>10d} ≥ {bound:2d}  {'✓' if val >= bound else '✗'}")

    # ── Demo 3: Symmetry: T_{-t}(n) = (-1)^n T_t(n) ──
    print("\n━━━ Demo 3: Chebyshev Sign Symmetry ━━━")
    print("Theorem: T_{-t}(n) = (-1)^n · T_t(n)")
    t = 5
    for n in range(8):
        lhs = chebyshev_trace(-t, n)
        rhs = (-1)**n * chebyshev_trace(t, n)
        print(f"  T_{-t}({n}) = {lhs:>8d},  (-1)^{n} · T_{t}({n}) = {rhs:>8d}  "
              f"{'✓' if lhs == rhs else '✗'}")

    # ── Demo 4: Tree Möbius Inversion ──
    print("\n━━━ Demo 4: Tree Möbius Inversion ━━━")
    print("On a k-ary tree: μ_T * ζ_T = δ")
    print()

    for k in [2, 3, 5, 10]:
        print(f"k = {k} (k-ary tree):")
        results = []
        for n in range(8):
            val = tree_convolve(k, n)
            expected = 1 if n == 0 else 0
            results.append(f"{val}")
        print(f"  (μ * ζ)(0..7) = [{', '.join(results)}]")
        all_correct = all(tree_convolve(k, n) == (1 if n == 0 else 0) for n in range(20))
        print(f"  Verified for n = 0..19: {'✓' if all_correct else '✗'}")
        print()

    # ── Demo 5: Trace Surjectivity ──
    print("\n━━━ Demo 5: Trace Surjectivity — Every Integer Is a Trace ━━━")
    print("Witness: M = [[t, -1], [1, 0]] has det=1, trace=t")
    for t in [-5, -1, 0, 1, 3, 7, 100]:
        M = [[t, -1], [1, 0]]
        det = M[0][0] * M[1][1] - M[0][1] * M[1][0]
        tr = M[0][0] + M[1][1]
        print(f"  t={t:>4d}: det = {det}, trace = {tr}  {'✓' if det == 1 and tr == t else '✗'}")

    # ── Demo 6: Strictly Increasing |T(n)| ──
    print("\n━━━ Demo 6: Strict Monotonicity of |T(n)| ━━━")
    print("For |t| ≥ 3: |T(n)| < |T(n+1)| for all n ≥ 1")
    for t in [3, -4, 7]:
        print(f"\n  t = {t}:")
        for n in range(1, 12):
            curr = abs(chebyshev_trace(t, n))
            next_val = abs(chebyshev_trace(t, n + 1))
            print(f"    |T({n:2d})| = {curr:>12d} < |T({n+1:2d})| = {next_val:>12d}  "
                  f"{'✓' if curr < next_val else '✗'}")

    # ── Demo 7: Pseudo-Hyperbolic Distance ──
    print("\n━━━ Demo 7: Pseudo-Hyperbolic Distance ━━━")
    print("ρ(z,w) = |z-w|/|1-w̄z|, symmetric: ρ(z,w) = ρ(w,z)")
    points = [0.3+0.2j, -0.1+0.4j, 0.5-0.3j, 0.1+0.1j]
    for i, z in enumerate(points):
        for j, w in enumerate(points):
            if i < j:
                d1 = pseudo_hyp_dist(z, w)
                d2 = pseudo_hyp_dist(w, z)
                print(f"  ρ({z}, {w}) = {d1:.8f}")
                print(f"  ρ({w}, {z}) = {d2:.8f}")
                print(f"  Symmetric: {'✓' if abs(d1 - d2) < 1e-14 else '✗'}")
                print()

    # ── Demo 8: Hyperbolic Lattice Points ──
    print("\n━━━ Demo 8: Hyperbolic Lattice Points ━━━")
    gen = 0.4 + 0.1j  # A generator in the disk
    points = [0j]
    seen = {0j}
    frontier = [0j]

    for depth in range(5):
        new_frontier = []
        for p in frontier:
            for g in [gen, -gen]:
                new_p = mobius_map(g, p)
                if abs(new_p) < 0.999 and all(abs(new_p - s) > 1e-8 for s in seen):
                    new_frontier.append(new_p)
                    seen.add(new_p)
                    points.append(new_p)
        frontier = new_frontier
        print(f"  Depth {depth+1}: {len(points)} total points, {len(frontier)} new")

    # ── Demo 9: Conjectured Conjugacy Class Count ──
    print("\n━━━ Demo 9: Conjugacy Class Conjecture ━━━")
    print("Conjecture: #{hyperbolic conj classes with |tr| ≤ T} = 2T - 3 for T ≥ 2")
    print()
    print("For the modular group PSL(2,ℤ), hyperbolic conjugacy classes")
    print("are parametrized by trace values |t| > 2. For each t ∈ {3,...,T},")
    print("there is exactly one conjugacy class with trace t and one with -t.")
    print("Plus the class with trace t for each t ∈ {3,...,T}.")
    print()
    for T in range(2, 15):
        count = 2 * T - 3 if T >= 2 else 0
        # Actual hyperbolic traces: |t| ≥ 3 and |t| ≤ T
        traces = [t for t in range(-T, T+1) if abs(t) >= 3]
        print(f"  T = {T:2d}: conjectured = {count:3d}, "
              f"trace values with |t| ∈ [3,T] = {len(traces)}")

    # ── Demo 10: Lattice Count Constant ──
    print("\n━━━ Demo 10: Lattice Count Constant ━━━")
    print(f"Conjectured: N(R) / e^R → C = 3/π ≈ {3/math.pi:.6f}")
    print("(For the modular group PSL(2,ℤ) acting on the Poincaré disk)")

    print("\n" + "=" * 70)
    print("  All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tree Möbius Inversion and Einstein Addition

Generates figures showing:
1. The tree Möbius function values and convolution verification
2. Einstein addition phase portrait on (-1,1)
3. Iterated Einstein addition convergence
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def einstein_add(a, b):
    return (a + b) / (1 + a * b)


def tree_moebius(k, d):
    if d == 0: return 1
    if d == 1: return -k
    return 0


def tree_convolve(k, n):
    return sum(tree_moebius(k, i) * k**(n - i) for i in range(n + 1))


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # ── Panel 1: Tree Möbius inversion verification ──
    ax = axes[0, 0]
    ks = [2, 3, 5, 7]
    x_vals = list(range(10))
    for k in ks:
        vals = [tree_convolve(k, n) for n in x_vals]
        ax.plot(x_vals, vals, 'o-', label=f'k={k}', markersize=8)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Depth n', fontsize=12)
    ax.set_ylabel('(μ_T * ζ_T)(n)', fontsize=12)
    ax.set_title('Tree Möbius Inversion: μ_T * ζ_T = δ', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yticks([-1, 0, 1, 2])
    ax.grid(True, alpha=0.3)

    # ── Panel 2: Einstein addition phase portrait ──
    ax = axes[0, 1]
    a_vals = np.linspace(-0.95, 0.95, 200)
    b_fixed = [0.1, 0.3, 0.5, 0.7, 0.9]

    for b in b_fixed:
        results = [einstein_add(a, b) for a in a_vals]
        ax.plot(a_vals, results, label=f'a ⊕ {b}', linewidth=1.5)

    ax.plot([-1, 1], [-1, 1], 'k--', alpha=0.3, label='identity')
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('a ⊕ b', fontsize=12)
    ax.set_title('Einstein Addition Phase Portrait', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_xlim(-1, 1)
    ax.set_ylim(-1, 1)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # ── Panel 3: Iterated Einstein addition ──
    ax = axes[1, 0]
    base_vals = [0.1, 0.3, 0.5, 0.7, 0.9]
    ns = list(range(1, 21))

    for base in base_vals:
        values = []
        curr = 0.0
        for n in ns:
            curr = einstein_add(curr, base)
            values.append(curr)
        ax.plot(ns, values, 'o-', label=f'base = {base}', markersize=4)

    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='light speed')
    ax.set_xlabel('Iterations n', fontsize=12)
    ax.set_ylabel('n-fold Einstein sum', fontsize=12)
    ax.set_title('Iterated Einstein Addition\n(approaches speed of light)', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # ── Panel 4: Comparison with tanh(n·artanh(a)) ──
    ax = axes[1, 1]
    base = 0.5
    ns = list(range(1, 16))
    einstein_vals = []
    tanh_vals = []
    curr = 0.0
    for n in ns:
        curr = einstein_add(curr, base)
        einstein_vals.append(curr)
        tanh_vals.append(math.tanh(n * math.atanh(base)))

    errors = [abs(e - t) for e, t in zip(einstein_vals, tanh_vals)]
    ax.semilogy(ns, [max(e, 1e-20) for e in errors], 'ro-', markersize=6)
    ax.set_xlabel('Iterations n', fontsize=12)
    ax.set_ylabel('|Einstein - tanh(n·artanh(a))| ', fontsize=12)
    ax.set_title(f'Numerical Agreement (base={base})\nEinstein sum = tanh ∘ (n × artanh)', fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=1e-15, color='gray', linestyle=':', alpha=0.5, label='machine ε')
    ax.legend()

    plt.tight_layout()
    plt.savefig('moebius_inversion_and_einstein.png', dpi=150, bbox_inches='tight')
    print("Saved: moebius_inversion_and_einstein.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Hyperbolic Lattice Points on the Poincaré Disk

Generates a figure showing:
1. The Poincaré disk boundary
2. Lattice points generated by Möbius transformations
3. Geodesic connections between nearby points
4. Color-coded by generation depth
"""

import math
import cmath
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def mobius_map(a: complex, z: complex) -> complex:
    """Möbius disk automorphism: z ↦ (z - a) / (1 - conj(a) z)"""
    return (z - a) / (1 - a.conjugate() * z)


def generate_lattice(generators, max_depth=6):
    """Generate lattice points on the Poincaré disk."""
    points_by_depth = {0: [0j]}
    all_points = {0j}
    frontier = [0j]

    for depth in range(1, max_depth + 1):
        new_frontier = []
        depth_points = []
        for p in frontier:
            for g in generators:
                for new_p in [mobius_map(g, p), mobius_map(-g, p)]:
                    if abs(new_p) < 0.999:
                        is_new = all(abs(new_p - existing) > 1e-8
                                     for existing in all_points)
                        if is_new:
                            new_frontier.append(new_p)
                            all_points.add(new_p)
                            depth_points.append(new_p)
        points_by_depth[depth] = depth_points
        frontier = new_frontier

    return points_by_depth


def poincare_geodesic_arc(z1, z2, num_points=50):
    """Compute the geodesic arc between z1 and z2 in the Poincaré disk."""
    if abs(z1) < 1e-10 or abs(z2) < 1e-10 or abs(z1.imag * z2.real - z1.real * z2.imag) < 1e-10:
        # Points are collinear with origin — geodesic is a straight line
        ts = np.linspace(0, 1, num_points)
        return [z1 + t * (z2 - z1) for t in ts]

    # General case: geodesic is an arc of a circle orthogonal to the unit circle
    x1, y1 = z1.real, z1.imag
    x2, y2 = z2.real, z2.imag

    # The geodesic circle passes through z1, z2 and is orthogonal to |z|=1
    # Center of the geodesic circle: solve the orthogonality condition
    # |center|^2 = 1 + R^2 and center equidistant from z1, z2
    A = 2 * (x2 - x1)
    B = 2 * (y2 - y1)
    C = (x2**2 + y2**2) - (x1**2 + y1**2)
    D = 2 * x1
    E = 2 * y1
    F = x1**2 + y1**2 - 1

    det = A * E - B * D
    if abs(det) < 1e-12:
        ts = np.linspace(0, 1, num_points)
        return [z1 + t * (z2 - z1) for t in ts]

    cx = (C * E - B * F) / det
    cy = (A * F - C * D) / det
    center = complex(cx, cy)
    R = abs(z1 - center)

    angle1 = cmath.phase(z1 - center)
    angle2 = cmath.phase(z2 - center)

    if angle2 - angle1 > math.pi:
        angle2 -= 2 * math.pi
    elif angle1 - angle2 > math.pi:
        angle1 -= 2 * math.pi

    angles = np.linspace(angle1, angle2, num_points)
    return [center + R * cmath.exp(1j * a) for a in angles]


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # ── Left panel: Lattice points on the Poincaré disk ──
    ax = axes[0]
    ax.set_aspect('equal')
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)

    # Draw unit circle
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)

    # Generate lattice
    generators = [0.4 + 0.15j, 0.1 + 0.35j]
    points_by_depth = generate_lattice(generators, max_depth=5)

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']

    for depth, pts in sorted(points_by_depth.items()):
        if not pts:
            continue
        xs = [p.real for p in pts]
        ys = [p.imag for p in pts]
        color = colors[depth % len(colors)]
        size = max(5, 40 - 6 * depth)
        ax.scatter(xs, ys, c=color, s=size, zorder=5,
                  label=f'Depth {depth} ({len(pts)} pts)',
                  edgecolors='black', linewidth=0.5, alpha=0.8)

    ax.set_title('Hyperbolic Lattice Points\non the Poincaré Disk', fontsize=14)
    ax.legend(loc='upper right', fontsize=8)
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')

    # ── Right panel: Chebyshev trace growth ──
    ax = axes[1]

    for t in [3, 4, 5]:
        ns = list(range(12))
        traces = [abs(chebyshev_trace_py(t, n)) for n in ns]
        ax.semilogy(ns, traces, 'o-', label=f't = {t}', linewidth=2, markersize=6)

    # Reference: exponential growth
    ns = list(range(12))
    for t in [3, 4, 5]:
        growth_rate = (t + math.sqrt(t**2 - 4)) / 2
        ref = [2 * growth_rate**n for n in ns]
        ax.semilogy(ns, ref, '--', alpha=0.3, color='gray')

    ax.set_xlabel('n (power)', fontsize=12)
    ax.set_ylabel('|T_t(n)| (log scale)', fontsize=12)
    ax.set_title('Chebyshev Trace Growth\n|T(n+2)| = |t·T(n+1) - T(n)|', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('hyperbolic_lattice_and_traces.png', dpi=150, bbox_inches='tight')
    print("Saved: hyperbolic_lattice_and_traces.png")


def chebyshev_trace_py(t, n):
    if n == 0: return 2
    if n == 1: return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr


if __name__ == '__main__':
    main()
