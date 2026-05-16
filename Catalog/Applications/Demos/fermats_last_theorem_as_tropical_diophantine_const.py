#!/usr/bin/env python3
"""
Applications of Tropical Fermat Hypersurface Theory

Demonstrates real-world applications of the tropical information loss theorems:
1. Abstract interpretation / program analysis analogy
2. Tropical shortest-path analysis
3. Cryptographic hardness barrier illustration
4. Lattice visibility and geometry of numbers
"""

from math import gcd, pi, log
from typing import List, Tuple, Dict
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════════
# Application 1: Abstract Interpretation Analogy
# ═══════════════════════════════════════════════════════════════════

def abstract_interpretation_demo():
    """
    Demonstrate how tropical zero sets act as an abstract domain.

    In program analysis, abstract interpretation over-approximates concrete
    behaviors. Our theorem shows that the tropical abstract domain cannot
    distinguish "zero solutions" (n ≥ 3) from "infinitely many solutions" (n = 2).

    This is a Galois connection:
        concrete domain: integer triples satisfying x^n + y^n = z^n
        abstract domain: tropical combinatorial types
    """
    print("=" * 60)
    print("APPLICATION 1: Abstract Interpretation Analogy")
    print("=" * 60)
    print()

    # Concrete domain: actual solutions
    def classical_solutions(n: int, L: int) -> List[Tuple[int, int, int]]:
        """Find all positive solutions to x^n + y^n = z^n with 0 < x,y,z ≤ L."""
        sols = []
        for x in range(1, L + 1):
            for y in range(x, L + 1):
                for z in range(y, L + 1):
                    if x**n + y**n == z**n:
                        sols.append((x, y, z))
        return sols

    # Abstract domain: tropical zero set membership
    def tropical_abstract(x: int, y: int, z: int) -> str:
        """Map to tropical combinatorial type."""
        m = min(x, y, z)
        achieving = []
        if x == m: achieving.append("x")
        if y == m: achieving.append("y")
        if z == m: achieving.append("z")
        return "+".join(achieving)

    L = 100
    print(f"Searching for solutions in [1, {L}]³:")
    print()

    for n in [2, 3, 4, 5]:
        sols = classical_solutions(n, L)
        print(f"  n = {n}: {len(sols)} classical solutions", end="")
        if sols and len(sols) <= 5:
            print(f"  {sols}", end="")
        elif sols:
            print(f"  (first 3: {sols[:3]}...)", end="")
        print()

    print()

    # Count tropical zero points (abstract domain) — always infinite
    trop_count = sum(1 for x in range(1, L+1) for y in range(1, L+1)
                     for z in range(1, L+1)
                     if min(x, y, z) == sorted([x, y, z])[0]
                     and sorted([x, y, z])[0] == sorted([x, y, z])[1])
    # Simpler: just count on H_xy wall
    h_xy_count = sum(1 for a in range(1, L+1) for b in range(a, L+1))

    print(f"  Tropical zero points on H_xy wall in [1,{L}]²: {h_xy_count}")
    print()
    print("  → Abstract domain (tropical) sees the SAME structure for all n.")
    print("  → This is a provable precision loss in the Galois connection.")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 2: Shortest Path Analysis
# ═══════════════════════════════════════════════════════════════════

def shortest_path_demo():
    """
    The min-plus semiring is the algebraic foundation of shortest-path algorithms.
    Tropical vanishing corresponds to "ties" in shortest paths — when two routes
    have equal cost.

    Our exponent invariance theorem shows that scaling all edge weights by the
    same factor doesn't change the topology of ties.
    """
    print("=" * 60)
    print("APPLICATION 2: Shortest Path Tie Analysis")
    print("=" * 60)
    print()

    # Example: 3-node network with edge weights
    # Nodes: A, B, C
    # We look at paths from a source S to each node
    # Cost to reach A: x, B: y, C: z (via different routes)

    print("Network: Source S connects to nodes A, B, C")
    print("Path costs: S→A = x, S→B = y, S→C = z")
    print()
    print("Tropical Fermat equation asks: when do multiple shortest paths tie?")
    print()

    examples = [
        (3, 3, 7, "A-B tie (routes to A and B have equal cost, cheaper than C)"),
        (5, 8, 5, "A-C tie (routes to A and C have equal cost)"),
        (9, 4, 4, "B-C tie (routes to B and C have equal cost)"),
        (2, 2, 2, "Three-way tie (all routes have equal cost)"),
        (1, 3, 5, "No tie (unique shortest path to A)"),
    ]

    print(f"{'Costs (x,y,z)':>15s}  {'Tie?':>5s}  Description")
    print("-" * 70)
    for x, y, z, desc in examples:
        m = min(x, y, z)
        count = (x == m) + (y == m) + (z == m)
        tie = count >= 2
        print(f"({x},{y},{z}):".rjust(15) + f"  {'YES' if tie else ' NO':>5s}  {desc}")

    print()
    print("Key insight: Scaling all costs by n doesn't change which paths tie.")
    print("This is exactly Theorem A / Stretch Theorem in network terms.")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 3: Cryptographic Hardness Barrier
# ═══════════════════════════════════════════════════════════════════

def crypto_barrier_demo():
    """
    Demonstrate that tropical encodings of Diophantine problems lose
    computational hardness.

    Classical: Finding x,y,z with x^n + y^n = z^n is either trivial (n=2,
    infinite Pythagorean triples) or impossible (n≥3, FLT).

    Tropical: Finding x,y,z in TropZero is always trivially easy.
    """
    print("=" * 60)
    print("APPLICATION 3: Cryptographic Hardness Barrier")
    print("=" * 60)
    print()

    print("Challenge: Given n, find (x,y,z) in TropZero(F_n) with gcd(x,y,z)=1")
    print()
    print("Trivial solution generator:")
    print()

    import time

    for n in [2, 3, 5, 100, 10**6, 10**18]:
        start = time.perf_counter()
        # Trivial O(1) solution: (1, 1, 2) always works
        x, y, z = 1, 1, 2
        assert min(n*x, n*y, n*z) == n*x == n*y  # always true
        elapsed = time.perf_counter() - start
        print(f"  n = {n:>20d}:  solution = ({x},{y},{z})  "
              f"time = {elapsed*1e6:.1f} μs")

    print()
    print("→ Tropical Diophantine problems are ALWAYS trivially solvable.")
    print("→ No cryptographic hardness can survive tropicalization.")
    print("→ This is a formal barrier to tropical cryptographic protocols")
    print("  based on Diophantine-style assumptions.")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 4: Lattice Visibility
# ═══════════════════════════════════════════════════════════════════

def lattice_visibility_demo():
    """
    Primitive points on the tropical hypersurface correspond to
    "visible" lattice points from the origin in the geometry of numbers.

    The density of primitive points is 6/π² ≈ 0.6079, matching the
    probability that two random integers are coprime.
    """
    print("=" * 60)
    print("APPLICATION 4: Lattice Visibility & Geometry of Numbers")
    print("=" * 60)
    print()

    expected_density = 6 / (pi ** 2)
    print(f"Expected density of coprime pairs: 6/π² ≈ {expected_density:.6f}")
    print()

    print(f"{'L':>6s}  {'Primitive':>10s}  {'Total':>8s}  {'Density':>8s}  "
          f"{'Error':>8s}")
    print("-" * 55)

    for L in [10, 20, 50, 100, 200, 500]:
        primitive = 0
        total = 0
        for a in range(1, L + 1):
            for b in range(a, L + 1):
                total += 1
                if gcd(a, b) == 1:
                    primitive += 1

        density = primitive / total if total > 0 else 0
        error = abs(density - expected_density)
        print(f"{L:>6d}  {primitive:>10d}  {total:>8d}  {density:>8.4f}  "
              f"{error:>8.4f}")

    print()
    print("→ Primitive point density converges to 6/π² as predicted by")
    print("  Euler's product formula for the Riemann zeta function.")
    print("→ The tropical Fermat hypersurface inherits this density on each wall.")
    print()


if __name__ == "__main__":
    abstract_interpretation_demo()
    shortest_path_demo()
    crypto_barrier_demo()
    lattice_visibility_demo()


#!/usr/bin/env python3
"""
Tropical Fermat Hypersurface — Demonstrations

Concrete numerical demonstrations of the main theorems:
- Theorem A: Exponent invariance of the tropical zero set
- Theorem B: Infinite primitive lattice points
- Theorem C: Scale invariance and information loss
- Stretch Theorem: Universal equal-degree collapse
"""

from math import gcd
from typing import Tuple


def trop_zero(n: int, x: int, y: int, z: int) -> bool:
    """Check if (x, y, z) is in TropZero(F_n).

    A point is in the tropical zero set if the minimum of (nx, ny, nz)
    is attained by at least two terms.
    """
    nx, ny, nz = n * x, n * y, n * z
    return ((nx == ny and nx <= nz) or
            (nx == nz and nx <= ny) or
            (ny == nz and ny <= nx))


def classify_wall(x: int, y: int, z: int) -> str:
    """Classify which wall(s) of the tropical hyperplane a point lies on."""
    walls = []
    if x == y and x <= z:
        walls.append("H_xy")
    if x == z and x <= y:
        walls.append("H_xz")
    if y == z and y <= x:
        walls.append("H_yz")
    if not walls:
        return "not on hypersurface"
    return " ∩ ".join(walls)


def demo_theorem_a():
    """Demonstrate Theorem A: exponent invariance."""
    print("=" * 60)
    print("THEOREM A: Exponent Invariance")
    print("=" * 60)
    print()
    print("Checking that TropZero(F_n) is independent of n:")
    print()

    test_points = [
        (3, 3, 7), (5, 5, 5), (2, 8, 2), (1, 1, 1),
        (0, 0, 5), (-3, -3, 0), (4, 7, 4),
        (1, 2, 3), (5, 3, 7), (0, 1, 2),  # not on hypersurface
    ]
    exponents = [1, 2, 3, 5, 10, 100]

    print(f"{'Point':>15s}", end="")
    for n in exponents:
        print(f"  n={n:>3d}", end="")
    print("  Wall")
    print("-" * 75)

    for p in test_points:
        print(f"{str(p):>15s}", end="")
        results = []
        for n in exponents:
            r = trop_zero(n, *p)
            results.append(r)
            print(f"  {'  ✓ ' if r else '  ✗ ':>6s}", end="")
        print(f"  {classify_wall(*p)}")
        # Verify all results are the same
        assert all(r == results[0] for r in results), \
            f"Exponent invariance FAILED for {p}!"

    print()
    print("✓ All points give identical results across all exponents.")
    print()


def demo_theorem_b():
    """Demonstrate Theorem B: infinite primitive lattice points."""
    print("=" * 60)
    print("THEOREM B: Infinite Primitive Lattice Points")
    print("=" * 60)
    print()
    print("Family (m, m, m+1) for consecutive m:")
    print()
    print(f"{'m':>5s}  {'Point':>15s}  {'gcd':>4s}  {'Primitive':>9s}  {'InTropZero':>10s}")
    print("-" * 55)

    for m in range(1, 21):
        point = (m, m, m + 1)
        g = gcd(m, m + 1)
        is_prim = g == 1
        in_tz = trop_zero(3, *point)  # n=3 for demonstration
        print(f"{m:>5d}  {str(point):>15s}  {g:>4d}  {'yes' if is_prim else 'no':>9s}  {'yes' if in_tz else 'no':>10s}")
        assert is_prim and in_tz

    print()
    print("✓ All consecutive pairs are coprime and lie on TropZero.")
    print()


def demo_theorem_c():
    """Demonstrate Theorem C: scale invariance and information loss."""
    print("=" * 60)
    print("THEOREM C: Scale Invariance & Information Loss")
    print("=" * 60)
    print()

    base_point = (3, 3, 7)
    n = 5
    print(f"Base point: {base_point}, n = {n}")
    print(f"TropZero check: {trop_zero(n, *base_point)}")
    print()
    print("Scaling by k = 1, 2, ..., 10:")
    print(f"{'k':>3s}  {'Scaled point':>20s}  {'In TropZero':>11s}  {'Distinct':>8s}")
    print("-" * 50)

    for k in range(1, 11):
        scaled = (k * base_point[0], k * base_point[1], k * base_point[2])
        in_tz = trop_zero(n, *scaled)
        distinct = scaled != base_point
        print(f"{k:>3d}  {str(scaled):>20s}  {'yes' if in_tz else 'no':>11s}  {'yes' if distinct else 'no':>8s}")
        assert in_tz

    print()
    print("✓ All scaled copies remain in TropZero — the tropical shadow")
    print("  cannot distinguish them from the original point.")
    print()

    # Demonstrate information loss: classical FLT vs tropical
    print("Information Loss Comparison:")
    print("-" * 50)
    print(f"{'Exponent n':>10s}  {'Classical solutions':>20s}  {'Tropical solutions':>20s}")
    print("-" * 50)
    print(f"{'2':>10s}  {'infinitely many':>20s}  {'infinitely many':>20s}")
    for n in [3, 4, 5, 10, 100]:
        print(f"{n:>10d}  {'0 (by FLT)':>20s}  {'infinitely many':>20s}")
    print()
    print("✓ Tropical geometry sees NO difference between n=2 and n≥3.")
    print()


def demo_stretch_theorem():
    """Demonstrate the Stretch Theorem: universal equal-degree collapse."""
    print("=" * 60)
    print("STRETCH THEOREM: Universal Equal-Degree Collapse")
    print("=" * 60)
    print()

    # Check a large set of points for multiple exponents
    import random
    random.seed(42)

    points = [(x, y, z) for x in range(-5, 6) for y in range(-5, 6) for z in range(-5, 6)]
    exponents = [1, 2, 3, 7, 13, 50, 997]

    mismatches = 0
    in_tz_count = 0

    for p in points:
        results = [trop_zero(n, *p) for n in exponents]
        if not all(r == results[0] for r in results):
            mismatches += 1
        if results[0]:
            in_tz_count += 1

    print(f"Tested {len(points)} points across exponents {exponents}")
    print(f"Points in TropZero: {in_tz_count}")
    print(f"Mismatches across exponents: {mismatches}")
    print()
    assert mismatches == 0
    print("✓ Zero mismatches: TropZero(F_n) = TropZero(F_m) for all tested n, m.")
    print()


def demo_primitive_counting():
    """Count primitive lattice points on the tropical Fermat hypersurface."""
    print("=" * 60)
    print("PRIMITIVE POINT COUNTING")
    print("=" * 60)
    print()

    for L in [10, 50, 100, 500]:
        count = 0
        for a in range(1, L + 1):
            for b in range(a, L + 1):
                if gcd(a, b) == 1:
                    # (a, a, b) is in TropZero since a = a ≤ b
                    count += 1
        ratio = count / (L * L) if L > 0 else 0
        print(f"L = {L:>4d}:  primitive points = {count:>8d},  "
              f"L² = {L*L:>8d},  ratio = {ratio:.4f}")

    print()
    print(f"Expected ratio (6/π²) ≈ {6/3.14159265358979**2:.4f}")
    print()


if __name__ == "__main__":
    demo_theorem_a()
    demo_theorem_b()
    demo_theorem_c()
    demo_stretch_theorem()
    demo_primitive_counting()
    print("=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical Fermat Hypersurface Theory

Generates publication-quality figures illustrating the main theorems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from math import gcd, pi
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_tropical_hyperplane():
    """Plot the tropical Fermat hypersurface in 2D projection."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: The three walls in the (x-y, y-z) plane
    ax = axes[0]
    L = 10

    # Wall H_xy: x = y ≤ z → x-y = 0, y-z ≤ 0
    # Wall H_xz: x = z ≤ y → plot in appropriate coordinates
    # Wall H_yz: y = z ≤ x → y-z = 0, x-y ≥ 0

    # Plot lattice points
    colors = {'H_xy': '#2196F3', 'H_xz': '#FF5722', 'H_yz': '#4CAF50',
              'vertex': '#9C27B0', 'none': '#E0E0E0'}

    for x in range(-L, L+1):
        for y in range(-L, L+1):
            for z in range(-L, L+1):
                m = min(x, y, z)
                on_xy = (x == y and x <= z)
                on_xz = (x == z and x <= y)
                on_yz = (y == z and y <= x)

                if x == y == z:
                    ax.plot(x, y, 'o', color=colors['vertex'], markersize=4,
                            alpha=0.8, zorder=5)
                elif on_xy:
                    ax.plot(x, z, 's', color=colors['H_xy'], markersize=3,
                            alpha=0.5)
                elif on_xz:
                    ax.plot(x, y, '^', color=colors['H_xz'], markersize=3,
                            alpha=0.5)
                elif on_yz:
                    ax.plot(y, x, 'D', color=colors['H_yz'], markersize=3,
                            alpha=0.5)

    ax.set_xlabel('Coordinate 1', fontsize=12)
    ax.set_ylabel('Coordinate 2', fontsize=12)
    ax.set_title('Tropical Fermat Hypersurface\n(projected lattice points)',
                 fontsize=13, fontweight='bold')
    ax.set_xlim(-L-1, L+1)
    ax.set_ylim(-L-1, L+1)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    patches = [
        mpatches.Patch(color=colors['H_xy'], label='Wall H_xy: x=y≤z'),
        mpatches.Patch(color=colors['H_xz'], label='Wall H_xz: x=z≤y'),
        mpatches.Patch(color=colors['H_yz'], label='Wall H_yz: y=z≤x'),
        mpatches.Patch(color=colors['vertex'], label='Vertex: x=y=z'),
    ]
    ax.legend(handles=patches, fontsize=9, loc='upper left')

    # Right: Primitive points on H_xy wall
    ax = axes[1]
    L = 30
    prim_a, prim_b = [], []
    nonprim_a, nonprim_b = [], []

    for a in range(0, L+1):
        for b in range(a, L+1):
            if gcd(a, b) == 1:
                prim_a.append(a)
                prim_b.append(b)
            elif a > 0 or b > 0:
                nonprim_a.append(a)
                nonprim_b.append(b)

    ax.scatter(nonprim_a, nonprim_b, c='#BDBDBD', s=8, alpha=0.5,
               label='Non-primitive', zorder=1)
    ax.scatter(prim_a, prim_b, c='#1565C0', s=12, alpha=0.7,
               label=f'Primitive ({len(prim_a)} points)', zorder=2)

    ax.plot([0, L], [0, L], 'k--', alpha=0.3, linewidth=0.5)
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('b ≥ a', fontsize=12)
    ax.set_title(f'Primitive Points on Wall H_xy\n'
                 f'(a, a, b) with gcd(a,b)=1, a≤b≤{L}',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


def plot_exponent_invariance():
    """Visualize that the tropical zero set is independent of n."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    L = 8
    exponents = [1, 3, 100]

    for idx, n in enumerate(exponents):
        ax = axes[idx]
        on_x, on_y = [], []
        off_x, off_y = [], []

        for x in range(-L, L+1):
            for y in range(-L, L+1):
                z = x  # Fix z = x for 2D slice
                nx, ny, nz = n*x, n*y, n*z
                on = ((nx == ny and nx <= nz) or
                      (nx == nz and nx <= ny) or
                      (ny == nz and ny <= nx))
                if on:
                    on_x.append(x)
                    on_y.append(y)
                else:
                    off_x.append(x)
                    off_y.append(y)

        ax.scatter(off_x, off_y, c='#F5F5F5', s=30, edgecolors='#E0E0E0',
                   linewidth=0.5, zorder=1)
        ax.scatter(on_x, on_y, c='#E91E63', s=40, alpha=0.8, zorder=2)

        ax.set_xlabel('x', fontsize=11)
        ax.set_ylabel('y', fontsize=11)
        ax.set_title(f'n = {n}', fontsize=14, fontweight='bold')
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)

    fig.suptitle('Tropical Zero Set (slice z = x) — Independent of Exponent n',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def plot_information_loss():
    """Visualize the information loss: classical vs tropical solution counts."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    exponents = list(range(2, 21))

    # Classical: count Pythagorean triples for n=2, 0 for n≥3
    L = 200
    classical_counts = []
    for n in exponents:
        if n == 2:
            count = sum(1 for a in range(1, L) for b in range(a, L)
                        for c in range(b, L) if a**2 + b**2 == c**2)
            classical_counts.append(count)
        else:
            classical_counts.append(0)

    # Tropical: always the same (count on H_xy wall in [1, L])
    trop_count = sum(1 for a in range(1, L+1) for b in range(a, L+1))

    x = np.array(exponents)
    ax.bar(x - 0.2, classical_counts, width=0.35, color='#1565C0',
           label='Classical solutions', alpha=0.8)
    ax.bar(x + 0.2, [trop_count] * len(exponents), width=0.35,
           color='#FF5722', label=f'Tropical solutions (={trop_count})',
           alpha=0.8)

    ax.set_xlabel('Exponent n', fontsize=13)
    ax.set_ylabel('Number of solutions', fontsize=13)
    ax.set_title(f'Classical vs Tropical: Solution Counts in [1, {L}]³',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xticks(exponents)

    # Add annotation
    ax.annotate('FLT: 0 solutions\nfor all n ≥ 3',
                xy=(5, 0), xytext=(8, max(classical_counts) * 0.5),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='#1565C0'),
                color='#1565C0')
    ax.annotate(f'Tropical: {trop_count}\nsolutions for ALL n',
                xy=(15, trop_count), xytext=(15, trop_count * 1.15),
                fontsize=10, ha='center', color='#FF5722')

    fig.tight_layout()
    return fig


def plot_primitive_density():
    """Plot convergence of primitive point density to 6/π²."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    Ls = list(range(5, 501, 5))
    densities = []

    for L in Ls:
        primitive = sum(1 for a in range(1, L+1) for b in range(a, L+1)
                        if gcd(a, b) == 1)
        total = sum(1 for a in range(1, L+1) for b in range(a, L+1))
        densities.append(primitive / total if total > 0 else 0)

    expected = 6 / (pi ** 2)

    ax.plot(Ls, densities, color='#1565C0', linewidth=1.5,
            label='Observed density', alpha=0.8)
    ax.axhline(y=expected, color='#FF5722', linestyle='--', linewidth=2,
               label=f'6/π² ≈ {expected:.4f}', alpha=0.8)

    ax.set_xlabel('Box size L', fontsize=13)
    ax.set_ylabel('Primitive density', fontsize=13)
    ax.set_title('Primitive Point Density on Tropical Fermat Hypersurface',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


def plot_scale_orbits():
    """Visualize scale orbits showing information loss."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    base_points = [(1, 1, 2), (1, 1, 3), (2, 2, 5), (3, 3, 7)]
    colors = ['#1565C0', '#FF5722', '#4CAF50', '#9C27B0']
    max_k = 8

    for i, (bx, by, bz) in enumerate(base_points):
        xs = [k * bx for k in range(1, max_k + 1)]
        ys = [k * bz for k in range(1, max_k + 1)]
        ax.plot(xs, ys, 'o-', color=colors[i], markersize=8, linewidth=1.5,
                label=f'Orbit of ({bx},{by},{bz})', alpha=0.8)
        for k in range(1, max_k + 1):
            ax.annotate(f'k={k}', (k*bx, k*bz), textcoords="offset points",
                        xytext=(5, 5), fontsize=7, color=colors[i], alpha=0.7)

    ax.set_xlabel('a (first two coordinates)', fontsize=13)
    ax.set_ylabel('b (third coordinate)', fontsize=13)
    ax.set_title('Scale Orbits in TropZero\n'
                 'Each orbit is a ray of tropically identical points',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    fig.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and save as PNG files."""
    print("Generating visualizations...")

    figs = {
        'tropical_hyperplane': plot_tropical_hyperplane(),
        'exponent_invariance': plot_exponent_invariance(),
        'information_loss': plot_information_loss(),
        'primitive_density': plot_primitive_density(),
        'scale_orbits': plot_scale_orbits(),
    }

    base64_data = {}
    for name, fig in figs.items():
        filename = f"{name}.png"
        fig.savefig(filename, dpi=150, bbox_inches='tight')
        base64_data[name] = fig_to_base64(fig)
        print(f"  Saved {filename}")

    return base64_data


if __name__ == "__main__":
    generate_all_visualizations()
    print("Done!")
