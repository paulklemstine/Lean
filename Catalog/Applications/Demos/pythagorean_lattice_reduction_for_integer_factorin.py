#!/usr/bin/env python3
"""
Pythagorean Lattice Reduction — Applications

Demonstrates real-world applications of the Pythagorean lattice framework:
1. RSA-style modulus factoring
2. Lattice analysis for cryptographic parameter assessment
3. Congruence density estimation
"""

from math import gcd, isqrt, log2
from typing import List, Tuple, Optional
import numpy as np
from algorithms import (
    pythagorean_lattice_factor,
    berggren_bfs_congruence,
    extract_factor_from_congruence,
    BERGGREN_GENS, ROOT,
    lattice_norm_statistics
)
from collections import deque


# ============================================================
# Application 1: RSA-style Modulus Analysis
# ============================================================

def analyze_rsa_modulus(p: int, q: int):
    """
    Analyze an RSA-style modulus n = p*q through the Pythagorean lattice lens.

    Shows the density of congruence-satisfying triples and the minimum
    depth at which a factor-revealing triple appears.
    """
    n = p * q
    print(f"\n  RSA Modulus Analysis: n = {p} × {q} = {n}")
    print(f"  Bit length: {int(log2(n)) + 1} bits")

    # Search for factor
    factor = pythagorean_lattice_factor(n, max_depth=12, verbose=True)

    if factor:
        print(f"  ✓ Factor found: {n} = {factor} × {n // factor}")
    else:
        print(f"  ✗ No factor found within search depth")

    # Lattice statistics
    stats = lattice_norm_statistics(n, depth=8)
    print(f"\n  Lattice Statistics (depth ≤ 8):")
    print(f"    Congruence-satisfying triples: {stats['count']}")
    print(f"    Factor-revealing triples:      {stats['factor_revealing']}")
    if stats['count'] > 0:
        print(f"    Density:                       {stats['factor_revealing']/stats['count']:.1%}")
        print(f"    Minimum ℓ¹ norm:               {stats['min_norm']}")
        print(f"    Shortest triple:               {stats['min_triple']}")


# ============================================================
# Application 2: Congruence Density Estimation
# ============================================================

def congruence_density_analysis():
    """
    Estimate the density of factor-revealing triples in the Berggren tree
    as a function of n for various semiprimes.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Congruence Density Analysis")
    print("=" * 70)

    semiprimes = [
        (3, 5), (5, 7), (7, 11), (11, 13), (13, 17),
        (17, 19), (19, 23), (23, 29), (29, 31), (31, 37)
    ]

    print(f"\n{'n':>8} {'p×q':>10} {'total':>8} {'cong':>8} {'factor':>8} {'density':>10}")
    print("-" * 60)

    for p, q in semiprimes:
        n = p * q
        # Count triples at fixed depth
        depth = 6
        queue = deque([(ROOT, 0)])
        total = 0
        cong_count = 0
        factor_count = 0

        while queue:
            triple, d = queue.popleft()
            total += 1
            a, b, c = int(triple[0]), int(triple[1]), int(triple[2])

            if (a**2 - b**2) % n == 0:
                cong_count += 1
                f = extract_factor_from_congruence(n, a, b)
                if f is not None:
                    factor_count += 1

            if d < depth:
                for M in BERGGREN_GENS:
                    queue.append((M @ triple, d + 1))

        density = factor_count / total if total > 0 else 0
        print(f"{n:>8} {f'{p}×{q}':>10} {total:>8} {cong_count:>8} {factor_count:>8} {density:>10.4f}")


# ============================================================
# Application 3: Lattice Geometry Visualization Data
# ============================================================

def lattice_geometry_data(n: int = 35, depth: int = 6):
    """
    Generate data showing the geometric structure of the Berggren lattice mod n.
    Outputs coordinates for plotting.
    """
    print(f"\n  Lattice geometry for n = {n}, depth ≤ {depth}")

    queue = deque([(ROOT, 0)])
    all_points = []
    lattice_points = []
    factor_points = []

    while queue:
        triple, d = queue.popleft()
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
        all_points.append((a % n, b % n))

        if (a**2 - b**2) % n == 0:
            lattice_points.append((a % n, b % n))
            f = extract_factor_from_congruence(n, a, b)
            if f is not None:
                factor_points.append((a % n, b % n))

        if d < depth:
            for M in BERGGREN_GENS:
                queue.append((M @ triple, d + 1))

    print(f"    Total triples: {len(all_points)}")
    print(f"    Lattice members: {len(lattice_points)}")
    print(f"    Factor-revealing: {len(factor_points)}")

    # Show the residue classes mod n
    print(f"\n    Residue classes (a mod {n}, b mod {n}) of lattice members:")
    seen = set()
    for a_mod, b_mod in lattice_points:
        if (a_mod, b_mod) not in seen:
            seen.add((a_mod, b_mod))
            print(f"      ({a_mod:3d}, {b_mod:3d})")
    print(f"    Distinct residue classes: {len(seen)} out of {n**2} possible")

    return all_points, lattice_points, factor_points


# ============================================================
# Application 4: Comparative Factoring
# ============================================================

def comparative_factoring():
    """
    Compare Pythagorean lattice factoring with trial division
    for various semiprimes.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Comparative Factoring Analysis")
    print("=" * 70)

    import time

    semiprimes = [
        (7, 13), (11, 17), (13, 19), (17, 23), (19, 29),
        (23, 31), (29, 37), (31, 41), (37, 43), (41, 47)
    ]

    print(f"\n{'n':>8} {'Trial div':>12} {'Pyth lattice':>14} {'Speedup':>10}")
    print("-" * 48)

    for p, q in semiprimes:
        n = p * q

        # Trial division
        t0 = time.perf_counter()
        for _ in range(100):
            for d in range(2, isqrt(n) + 1):
                if n % d == 0:
                    break
        td_time = (time.perf_counter() - t0) / 100

        # Pythagorean lattice
        t0 = time.perf_counter()
        for _ in range(100):
            pythagorean_lattice_factor(n, max_depth=8)
        pl_time = (time.perf_counter() - t0) / 100

        speedup = td_time / pl_time if pl_time > 0 else float('inf')
        print(f"{n:>8} {td_time*1e6:>10.1f}μs {pl_time*1e6:>12.1f}μs {speedup:>9.2f}×")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Pythagorean Lattice Reduction — Applications                      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    print("\n" + "=" * 70)
    print("APPLICATION 1: RSA Modulus Analysis")
    print("=" * 70)

    analyze_rsa_modulus(7, 13)
    analyze_rsa_modulus(101, 103)

    congruence_density_analysis()

    print("\n" + "=" * 70)
    print("APPLICATION 3: Lattice Geometry")
    print("=" * 70)
    lattice_geometry_data(35, 5)

    comparative_factoring()


#!/usr/bin/env python3
"""
Pythagorean Lattice Reduction for Integer Factoring — Demonstration

This script demonstrates the core mathematical ideas:
1. Berggren tree generation of primitive Pythagorean triples
2. Congruence-of-squares extraction from Pythagorean triples
3. Factor extraction via GCD
4. Lattice structure visualization
"""

from math import gcd, isqrt
from typing import List, Tuple, Optional
import numpy as np

# ============================================================
# Berggren Matrices
# ============================================================

BERGGREN_A = np.array([
    [1, -2, 2],
    [2, -1, 2],
    [2, -2, 3]
], dtype=np.int64)

BERGGREN_B = np.array([
    [1, 2, 2],
    [2, 1, 2],
    [2, 2, 3]
], dtype=np.int64)

BERGGREN_C = np.array([
    [-1, 2, 2],
    [-2, 1, 2],
    [-2, 2, 3]
], dtype=np.int64)

BERGGREN_GENS = [BERGGREN_A, BERGGREN_B, BERGGREN_C]

ROOT_TRIPLE = np.array([3, 4, 5], dtype=np.int64)


def generate_berggren_tree(depth: int) -> List[np.ndarray]:
    """Generate all primitive Pythagorean triples up to given depth in the Berggren tree."""
    triples = [ROOT_TRIPLE]
    frontier = [ROOT_TRIPLE]
    for _ in range(depth):
        new_frontier = []
        for t in frontier:
            for M in BERGGREN_GENS:
                child = M @ t
                new_frontier.append(child)
                triples.append(child)
        frontier = new_frontier
    return triples


def is_pythagorean(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a Pythagorean triple."""
    return a**2 + b**2 == c**2


def is_primitive(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a primitive Pythagorean triple."""
    return is_pythagorean(a, b, c) and gcd(gcd(abs(a), abs(b)), abs(c)) == 1


def encodes_congruence_of_squares(n: int, a: int, b: int) -> bool:
    """Check if n | (a^2 - b^2)."""
    return (a**2 - b**2) % n == 0


def factor_from_congruence(n: int, x: int, y: int) -> Optional[int]:
    """
    Given x^2 ≡ y^2 (mod n), try to extract a nontrivial factor of n.
    Returns a nontrivial factor, or None if the congruence is degenerate.
    """
    d = gcd(n, abs(x - y))
    if d != 1 and d != n:
        return d
    d = gcd(n, abs(x + y))
    if d != 1 and d != n:
        return d
    return None


# ============================================================
# Demo 1: Berggren Tree and Pythagorean Verification
# ============================================================

def demo_berggren_tree():
    print("=" * 70)
    print("DEMO 1: Berggren Tree — First 3 Levels")
    print("=" * 70)

    triples = generate_berggren_tree(2)
    print(f"\nGenerated {len(triples)} primitive Pythagorean triples:\n")

    for i, t in enumerate(triples):
        a, b, c = int(t[0]), int(t[1]), int(t[2])
        assert is_pythagorean(a, b, c), f"Not Pythagorean: {a, b, c}"
        prim = is_primitive(a, b, c)
        print(f"  Triple {i+1:2d}: ({a:4d}, {b:4d}, {c:4d})  "
              f"  {a}² + {b}² = {a**2} + {b**2} = {c**2} = {c}²  "
              f"  primitive={prim}")

    print(f"\n✓ All {len(triples)} triples verified as Pythagorean.")
    print(f"✓ All triples are primitive (gcd = 1).")


# ============================================================
# Demo 2: Factor Extraction via Congruence of Squares
# ============================================================

def demo_factor_extraction():
    print("\n" + "=" * 70)
    print("DEMO 2: Factor Extraction from Pythagorean Congruences")
    print("=" * 70)

    # Target composites to factor
    test_cases = [
        (15, "3 × 5"),
        (35, "5 × 7"),
        (77, "7 × 11"),
        (91, "7 × 13"),
        (143, "11 × 13"),
        (221, "13 × 17"),
        (323, "17 × 19"),
        (1001, "7 × 11 × 13"),
        (2021, "43 × 47"),
    ]

    triples = generate_berggren_tree(10)  # Generate many triples

    for n, factorization in test_cases:
        print(f"\n  n = {n} ({factorization}):")
        found = False
        for t in triples:
            a, b, c = int(t[0]), int(t[1]), int(t[2])
            if encodes_congruence_of_squares(n, a, b):
                d = factor_from_congruence(n, a, b)
                if d is not None:
                    print(f"    Triple ({a}, {b}, {c}): "
                          f"{a}² - {b}² = {a**2 - b**2} ≡ 0 (mod {n})")
                    print(f"    → gcd({n}, |{a} - {b}|) = gcd({n}, {abs(a-b)}) = {gcd(n, abs(a-b))}")
                    print(f"    → Factor found: {d} × {n // d} = {n}  ✓")
                    found = True
                    break
        if not found:
            # Try x+y instead of x-y
            for t in triples:
                a, b, c = int(t[0]), int(t[1]), int(t[2])
                if (a**2 - b**2) % n == 0:
                    d = gcd(n, abs(a + b))
                    if d != 1 and d != n:
                        print(f"    Triple ({a}, {b}, {c}): "
                              f"{a}² ≡ {b}² (mod {n})")
                        print(f"    → gcd({n}, {a} + {b}) = {d}")
                        print(f"    → Factor found: {d} × {n // d} = {n}  ✓")
                        found = True
                        break
            if not found:
                print(f"    No factor-revealing triple found in search depth.")


# ============================================================
# Demo 3: Lattice Structure
# ============================================================

def demo_lattice_structure():
    print("\n" + "=" * 70)
    print("DEMO 3: Berggren Congruence Lattice Structure")
    print("=" * 70)

    n = 15
    print(f"\n  Berggren Lattice L_{n}: vectors v with {n} | (v₀² - v₁²)")

    triples = generate_berggren_tree(5)
    members = []
    for t in triples:
        a, b, c = int(t[0]), int(t[1]), int(t[2])
        if (a**2 - b**2) % n == 0:
            members.append((a, b, c))

    print(f"\n  Found {len(members)} triples in L_{n}:")
    for a, b, c in members[:10]:
        norm = abs(a) + abs(b) + abs(c)
        d_minus = gcd(n, abs(a - b))
        d_plus = gcd(n, abs(a + b))
        factor_revealing = (d_minus != 1 and d_minus != n) or (d_plus != 1 and d_plus != n)
        print(f"    ({a:5d}, {b:5d}, {c:5d})  ‖v‖₁ = {norm:6d}  "
              f"gcd(n,|a-b|)={d_minus:2d}  gcd(n,|a+b|)={d_plus:2d}  "
              f"{'FACTOR-REVEALING' if factor_revealing else ''}")


# ============================================================
# Demo 4: Congruence of Squares Pipeline
# ============================================================

def demo_congruence_pipeline():
    print("\n" + "=" * 70)
    print("DEMO 4: Full Pipeline — Berggren → Lattice → Congruence → Factor")
    print("=" * 70)

    n = 91  # = 7 × 13
    print(f"\n  Target: n = {n}")
    print(f"  Step 1: Generate Berggren tree (depth 5)")

    triples = generate_berggren_tree(5)
    print(f"          Generated {len(triples)} primitive Pythagorean triples")

    print(f"  Step 2: Filter for lattice membership (n | a² - b²)")
    lattice_members = []
    for t in triples:
        a, b, c = int(t[0]), int(t[1]), int(t[2])
        if (a**2 - b**2) % n == 0:
            lattice_members.append((a, b, c))
    print(f"          Found {len(lattice_members)} lattice members")

    print(f"  Step 3: Find shortest factor-revealing vector")
    best = None
    best_norm = float('inf')
    for a, b, c in lattice_members:
        norm = abs(a) + abs(b) + abs(c)
        d = gcd(n, abs(a - b))
        if d != 1 and d != n and norm < best_norm:
            best = (a, b, c)
            best_norm = norm

    if best is None:
        for a, b, c in lattice_members:
            norm = abs(a) + abs(b) + abs(c)
            d = gcd(n, abs(a + b))
            if d != 1 and d != n and norm < best_norm:
                best = (a, b, c)
                best_norm = norm

    if best:
        a, b, c = best
        d = gcd(n, abs(a - b))
        if d == 1 or d == n:
            d = gcd(n, abs(a + b))
        print(f"          Shortest: ({a}, {b}, {c}), ‖v‖₁ = {best_norm}")
        print(f"  Step 4: Extract factor via GCD")
        print(f"          gcd({n}, ...) = {d}")
        print(f"          {n} = {d} × {n // d}")
        print(f"\n  ✓ FACTORING COMPLETE: {n} = {d} × {n // d}")
    else:
        print(f"          No factor-revealing vector found at this depth.")


# ============================================================
# Demo 5: Berggren Matrix Properties
# ============================================================

def demo_matrix_properties():
    print("\n" + "=" * 70)
    print("DEMO 5: Berggren Matrices and Lorentz Form Preservation")
    print("=" * 70)

    Q = np.diag([1, 1, -1])
    print(f"\n  Lorentz form Q = diag(1, 1, -1)")
    print(f"  Q preserves: x² + y² - z² (signature (2,1))\n")

    names = ["A", "B", "C"]
    for name, M in zip(names, BERGGREN_GENS):
        product = M.T @ Q @ M
        preserves = np.array_equal(product, Q)
        print(f"  M_{name}^T · Q · M_{name} = Q ? {preserves}")
        print(f"    det(M_{name}) = {int(round(np.linalg.det(M)))}")

    # Verify tree property: all children of (3,4,5) are primitive Pythagorean
    print(f"\n  Children of (3, 4, 5):")
    for name, M in zip(names, BERGGREN_GENS):
        child = M @ ROOT_TRIPLE
        a, b, c = child
        print(f"    M_{name} · (3,4,5) = ({a}, {b}, {c})  "
              f"  check: {a}² + {b}² = {a**2 + b**2} = {c**2} = {c}²  ✓")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Pythagorean Lattice Reduction for Integer Factoring               ║")
    print("║  Demonstration of Core Mathematical Framework                      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_berggren_tree()
    demo_factor_extraction()
    demo_lattice_structure()
    demo_congruence_pipeline()
    demo_matrix_properties()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Pythagorean Lattice Reduction — Visualizations

Generates publication-quality figures illustrating:
1. The Berggren tree structure
2. Lattice geometry mod n
3. Factor-revealing triple distribution
4. Norm growth in the Berggren tree
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from collections import deque
from math import gcd
import base64
import io

BERGGREN_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
BERGGREN_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
BERGGREN_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)
BERGGREN_GENS = [BERGGREN_A, BERGGREN_B, BERGGREN_C]
ROOT = np.array([3, 4, 5], dtype=np.int64)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


# ============================================================
# Figure 1: Berggren Tree
# ============================================================

def plot_berggren_tree():
    """Plot the first 3 levels of the Berggren tree."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    positions = {}
    labels = {}

    # Root
    positions[(3, 4, 5)] = (7, 4)
    labels[(3, 4, 5)] = "(3, 4, 5)"

    queue = deque([(ROOT, 0, (3, 4, 5))])
    depth_counts = {0: 0, 1: 0, 2: 0}
    edges = []

    while queue:
        triple, depth, key = queue.popleft()
        if depth >= 2:
            continue

        for i, M in enumerate(BERGGREN_GENS):
            child = M @ triple
            a, b, c = int(child[0]), int(child[1]), int(child[2])
            child_key = (a, b, c)

            depth_counts[depth + 1] = depth_counts.get(depth + 1, 0)
            child_count = depth_counts[depth + 1]

            if depth == 0:
                x = 2 + i * 5
                y = 2.5
            else:
                parent_x = positions[key][0]
                x = parent_x - 1.5 + i * 1.5
                y = 1

            positions[child_key] = (x, y)
            labels[child_key] = f"({a},{b},{c})"
            edges.append((key, child_key))
            depth_counts[depth + 1] += 1

            queue.append((child, depth + 1, child_key))

    # Draw edges
    for parent, child in edges:
        px, py = positions[parent]
        cx, cy = positions[child]
        ax.annotate("", xy=(cx, cy + 0.15), xytext=(px, py - 0.15),
                     arrowprops=dict(arrowstyle="->", color='#4a90d9', lw=1.5))

    # Draw nodes
    for key, (x, y) in positions.items():
        a, b, c = key
        color = '#2ecc71' if gcd(gcd(abs(a), abs(b)), abs(c)) == 1 else '#e74c3c'
        ax.add_patch(plt.Circle((x, y), 0.12, color=color, zorder=5))
        ax.text(x, y - 0.35, labels[key], ha='center', va='top', fontsize=8,
                fontweight='bold', color='#2c3e50')

    # Generator labels
    gen_names = ['A', 'B', 'C']
    for i, name in enumerate(gen_names):
        ax.text(2 + i * 5, 3.2, f"Generator {name}", ha='center', fontsize=10,
                color='#4a90d9', style='italic')

    ax.set_xlim(-1, 15)
    ax.set_ylim(0.3, 4.8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("The Berggren Tree: Generating All Primitive Pythagorean Triples",
                 fontsize=14, fontweight='bold', pad=20)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/berggren_tree.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Figure 2: Lattice Points mod n
# ============================================================

def plot_lattice_mod_n(n=35):
    """Plot residue classes of Berggren triples mod n, highlighting congruence members."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))

    queue = deque([(ROOT, 0)])
    all_a_mod = []
    all_b_mod = []
    cong_a_mod = []
    cong_b_mod = []
    factor_a_mod = []
    factor_b_mod = []

    while queue:
        triple, depth = queue.popleft()
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
        all_a_mod.append(a % n)
        all_b_mod.append(b % n)

        if (a**2 - b**2) % n == 0:
            cong_a_mod.append(a % n)
            cong_b_mod.append(b % n)

            d1 = gcd(n, abs(a - b))
            d2 = gcd(n, abs(a + b))
            if (1 < d1 < n) or (1 < d2 < n):
                factor_a_mod.append(a % n)
                factor_b_mod.append(b % n)

        if depth < 7:
            for M in BERGGREN_GENS:
                queue.append((M @ triple, depth + 1))

    ax.scatter(all_a_mod, all_b_mod, s=3, alpha=0.1, color='#bdc3c7', label='All triples')
    ax.scatter(cong_a_mod, cong_b_mod, s=30, alpha=0.6, color='#3498db',
               label=f'n | (a²−b²)', zorder=3)
    ax.scatter(factor_a_mod, factor_b_mod, s=80, alpha=0.8, color='#e74c3c',
               marker='*', label='Factor-revealing', zorder=4)

    ax.set_xlabel(f'a mod {n}', fontsize=12)
    ax.set_ylabel(f'b mod {n}', fontsize=12)
    ax.set_title(f'Berggren Triples mod {n} = 5 × 7\nCongruence Lattice Structure',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.set_xlim(-1, n)
    ax.set_ylim(-1, n)
    ax.grid(True, alpha=0.2)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/lattice_mod_n.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Figure 3: Norm Growth in Berggren Tree
# ============================================================

def plot_norm_growth():
    """Plot ℓ¹ norm of triples as a function of tree depth."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    max_depth = 8
    depths = []
    norms = []
    hypotenuses = []

    queue = deque([(ROOT, 0)])
    while queue:
        triple, depth = queue.popleft()
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
        depths.append(depth)
        norms.append(abs(a) + abs(b) + abs(c))
        hypotenuses.append(abs(c))

        if depth < max_depth:
            for M in BERGGREN_GENS:
                queue.append((M @ triple, depth + 1))

    # Plot 1: Norms by depth
    ax1.scatter(depths, norms, s=5, alpha=0.3, color='#3498db')

    # Compute mean norms per depth
    for d in range(max_depth + 1):
        d_norms = [n for dd, n in zip(depths, norms) if dd == d]
        if d_norms:
            ax1.scatter([d], [np.mean(d_norms)], s=100, color='#e74c3c',
                       marker='D', zorder=5, edgecolors='black')

    ax1.set_yscale('log')
    ax1.set_xlabel('Tree Depth', fontsize=12)
    ax1.set_ylabel('ℓ¹ Norm (log scale)', fontsize=12)
    ax1.set_title('Triple Norms vs. Berggren Tree Depth', fontsize=13, fontweight='bold')
    ax1.grid(True, alpha=0.3)

    # Plot 2: Hypotenuse distribution
    ax2.hist(np.log10(hypotenuses), bins=50, color='#2ecc71', alpha=0.7, edgecolor='black')
    ax2.set_xlabel('log₁₀(hypotenuse)', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Hypotenuse Values', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/norm_growth.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Figure 4: Factor Success Rate
# ============================================================

def plot_factor_success():
    """Plot factor-finding success rate vs search depth for various n."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    test_n = [15, 35, 77, 143, 221, 323]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(test_n)))

    for n, color in zip(test_n, colors):
        success_depths = []
        max_d = 10

        for depth_limit in range(1, max_d + 1):
            queue = deque([(ROOT, 0)])
            found = False
            while queue and not found:
                triple, d = queue.popleft()
                a, b, c = int(triple[0]), int(triple[1]), int(triple[2])

                if (a**2 - b**2) % n == 0:
                    d1 = gcd(n, abs(a - b))
                    d2 = gcd(n, abs(a + b))
                    if (1 < d1 < n) or (1 < d2 < n):
                        found = True

                if d < depth_limit and not found:
                    for M in BERGGREN_GENS:
                        queue.append((M @ triple, d + 1))

            success_depths.append(1 if found else 0)

        ax.plot(range(1, max_d + 1), np.cumsum(success_depths).clip(0, 1),
                'o-', color=color, label=f'n = {n}', linewidth=2, markersize=6)

    ax.set_xlabel('Search Depth', fontsize=12)
    ax.set_ylabel('Factor Found (cumulative)', fontsize=12)
    ax.set_title('Factor Discovery Depth for Various Composites', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='lower right')
    ax.set_yticks([0, 1])
    ax.set_yticklabels(['No', 'Yes'])
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/factor_success.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    print("  1. Berggren tree...")
    plot_berggren_tree()

    print("  2. Lattice mod n...")
    plot_lattice_mod_n()

    print("  3. Norm growth...")
    plot_norm_growth()

    print("  4. Factor success rate...")
    plot_factor_success()

    print("\nAll visualizations saved as PNG files.")
