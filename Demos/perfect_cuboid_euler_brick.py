#!/usr/bin/env python3
"""
Perfect Cuboid / Euler Brick — Demonstration Script

Searches for Euler bricks and near-miss perfect cuboids,
demonstrates parametric families, and tests the conjecture
that no perfect cuboid exists below a given bound.
"""

import math
from typing import Optional


def is_perfect_square(n: int) -> bool:
    """Check if n is a perfect square."""
    if n < 0:
        return False
    r = int(math.isqrt(n))
    return r * r == n


def is_euler_brick(x: int, y: int, z: int) -> bool:
    """Check if (x, y, z) forms an Euler brick."""
    return (is_perfect_square(x*x + y*y) and
            is_perfect_square(x*x + z*z) and
            is_perfect_square(y*y + z*z))


def is_perfect_cuboid(x: int, y: int, z: int) -> bool:
    """Check if (x, y, z) forms a perfect cuboid."""
    return (is_euler_brick(x, y, z) and
            is_perfect_square(x*x + y*y + z*z))


def cuboid_defect(x: int, y: int, z: int) -> int:
    """Compute the defect: distance from space diagonal² to nearest square below."""
    s = x*x + y*y + z*z
    r = int(math.isqrt(s))
    return s - r*r


def find_euler_bricks(bound: int) -> list[tuple[int, int, int]]:
    """Find all primitive Euler bricks with edges ≤ bound."""
    bricks = []
    for x in range(1, bound + 1):
        for y in range(x, bound + 1):
            if not is_perfect_square(x*x + y*y):
                continue
            for z in range(y, bound + 1):
                if is_euler_brick(x, y, z):
                    bricks.append((x, y, z))
    return bricks


def saunderson_brick(m: int, n: int) -> Optional[tuple[int, int, int]]:
    """
    Generate an Euler brick from the Saunderson parametrization.
    Given a Pythagorean triple (u, v, w) with u = m²-n², v = 2mn, w = m²+n²,
    produces edges:
        x = u * |4v² - w²|
        y = v * |4u² - w²|
        z = 4 * u * v * w
    Returns None if any edge is zero or negative.
    """
    u = m*m - n*n
    v = 2*m*n
    w = m*m + n*n

    x = abs(u * (4*v*v - w*w))
    y = abs(v * (4*u*u - w*w))
    z = abs(4 * u * v * w)

    if x == 0 or y == 0 or z == 0:
        return None

    return tuple(sorted([x, y, z]))


def find_near_misses(bound: int, max_defect: int = 10) -> list[tuple[int, int, int, int]]:
    """Find Euler bricks with small space diagonal defect."""
    results = []
    for x in range(1, bound + 1):
        for y in range(x, bound + 1):
            if not is_perfect_square(x*x + y*y):
                continue
            for z in range(y, bound + 1):
                if is_euler_brick(x, y, z):
                    d = cuboid_defect(x, y, z)
                    if d <= max_defect:
                        results.append((x, y, z, d))
    return results


def verify_parity_theorem(bricks: list[tuple[int, int, int]]) -> bool:
    """Verify that at least two edges are even in every Euler brick."""
    for x, y, z in bricks:
        even_count = sum(1 for e in [x, y, z] if e % 2 == 0)
        if even_count < 2:
            print(f"COUNTEREXAMPLE: ({x}, {y}, {z}) has {even_count} even edges!")
            return False
    return True


def verify_mod4_constraint(bricks: list[tuple[int, int, int]]) -> bool:
    """Verify that not all edges are odd in every Euler brick."""
    for x, y, z in bricks:
        if x % 2 == 1 and y % 2 == 1 and z % 2 == 1:
            print(f"COUNTEREXAMPLE: ({x}, {y}, {z}) has all odd edges!")
            return False
    return True


def main():
    print("=" * 60)
    print("Perfect Cuboid / Euler Brick Demonstration")
    print("=" * 60)

    # 1. Find small Euler bricks
    print("\n--- Finding Euler bricks with edges ≤ 300 ---")
    bricks = find_euler_bricks(300)
    print(f"Found {len(bricks)} Euler bricks")
    for b in bricks[:10]:
        x, y, z = b
        diags = [int(math.isqrt(x*x+y*y)), int(math.isqrt(x*x+z*z)),
                 int(math.isqrt(y*y+z*z))]
        defect = cuboid_defect(x, y, z)
        print(f"  ({x:>4}, {y:>4}, {z:>4}) | diags: {diags} | defect: {defect}")

    # 2. Verify parity theorem
    print(f"\n--- Verifying parity theorem on {len(bricks)} bricks ---")
    if verify_parity_theorem(bricks):
        print("✓ All Euler bricks have at least 2 even edges (consistent with theorem)")
    if verify_mod4_constraint(bricks):
        print("✓ No Euler brick has all odd edges (consistent with mod-4 constraint)")

    # 3. Saunderson parametric family
    print("\n--- Saunderson parametric Euler bricks ---")
    seen = set()
    for m in range(2, 15):
        for n in range(1, m):
            if math.gcd(m, n) != 1 or (m - n) % 2 == 0:
                continue
            result = saunderson_brick(m, n)
            if result and result not in seen:
                seen.add(result)
                x, y, z = result
                valid = is_euler_brick(x, y, z)
                defect = cuboid_defect(x, y, z)
                print(f"  m={m:>2}, n={n:>2}: ({x}, {y}, {z})"
                      f" | valid={valid} | defect={defect}")

    # 4. Search for perfect cuboids
    print("\n--- Searching for perfect cuboids with edges ≤ 300 ---")
    found = False
    for b in bricks:
        if is_perfect_cuboid(*b):
            print(f"  PERFECT CUBOID FOUND: {b}")
            found = True
    if not found:
        print("  No perfect cuboid found (consistent with conjecture)")

    # 5. Near-miss analysis
    print("\n--- Near-miss perfect cuboids (defect ≤ 50) ---")
    near_misses = find_near_misses(300, max_defect=50)
    near_misses.sort(key=lambda t: t[3])
    for x, y, z, d in near_misses[:15]:
        s = x*x + y*y + z*z
        r = int(math.isqrt(s))
        print(f"  ({x:>4}, {y:>4}, {z:>4}) | s²={s:>8} | √s≈{r} | defect={d}")

    # 6. Diagonal sum relation verification
    print("\n--- Verifying a² + b² + c² = 2d² relation ---")
    print("  (Would hold for any perfect cuboid point)")
    for b in bricks[:5]:
        x, y, z = b
        a = int(math.isqrt(x*x + y*y))
        bb = int(math.isqrt(x*x + z*z))
        c = int(math.isqrt(y*y + z*z))
        lhs = a*a + bb*bb + c*c
        rhs_half = x*x + y*y + z*z
        print(f"  ({x}, {y}, {z}): a²+b²+c² = {lhs}, 2(x²+y²+z²) = {2*rhs_half}, "
              f"match: {lhs == 2*rhs_half}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Euler Brick near-miss defects and parametric families.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def is_perfect_square(n: int) -> bool:
    if n < 0:
        return False
    r = int(math.isqrt(n))
    return r * r == n


def find_euler_bricks_with_defect(bound: int):
    results = []
    for x in range(1, bound + 1):
        for y in range(x, bound + 1):
            if not is_perfect_square(x*x + y*y):
                continue
            for z in range(y, bound + 1):
                if is_perfect_square(x*x + z*z) and is_perfect_square(y*y + z*z):
                    s = x*x + y*y + z*z
                    r = int(math.isqrt(s))
                    defect = s - r*r
                    results.append((x, y, z, defect, s))
    return results


def main():
    # Find Euler bricks up to bound 500
    print("Finding Euler bricks...")
    bricks = find_euler_bricks_with_defect(500)
    print(f"Found {len(bricks)} Euler bricks")

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Perfect Cuboid Analysis: Euler Bricks & Near-Misses', fontsize=16, fontweight='bold')

    # Plot 1: Defect distribution
    ax = axes[0, 0]
    defects = [b[3] for b in bricks]
    ax.hist(defects, bins=50, color='steelblue', edgecolor='white', alpha=0.8)
    ax.set_xlabel('Space Diagonal Defect')
    ax.set_ylabel('Count')
    ax.set_title('Distribution of Space Diagonal Defects')
    ax.axvline(x=0, color='red', linestyle='--', linewidth=2, label='Perfect cuboid (defect=0)')
    ax.legend()

    # Plot 2: Edge sum vs defect
    ax = axes[0, 1]
    edge_sums = [b[0]+b[1]+b[2] for b in bricks]
    ax.scatter(edge_sums, defects, s=8, alpha=0.5, c='darkorange')
    ax.set_xlabel('Sum of Edges (x + y + z)')
    ax.set_ylabel('Space Diagonal Defect')
    ax.set_title('Edge Sum vs. Defect')
    ax.set_yscale('log', nonpositive='clip')

    # Plot 3: Parity structure
    ax = axes[1, 0]
    parity_counts = {'0 even': 0, '1 even': 0, '2 even': 0, '3 even': 0}
    for x, y, z, _, _ in bricks:
        n_even = sum(1 for e in [x, y, z] if e % 2 == 0)
        parity_counts[f'{n_even} even'] += 1
    labels = list(parity_counts.keys())
    values = list(parity_counts.values())
    colors = ['#ff6b6b', '#ffd93d', '#6bcb77', '#4d96ff']
    bars = ax.bar(labels, values, color=colors, edgecolor='white')
    ax.set_xlabel('Number of Even Edges')
    ax.set_ylabel('Count')
    ax.set_title('Parity Structure of Euler Bricks\n(Theorem: at least 2 must be even)')
    for bar, val in zip(bars, values):
        if val > 0:
            ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
                    str(val), ha='center', va='bottom', fontweight='bold')

    # Plot 4: Near-miss ranking
    ax = axes[1, 1]
    sorted_bricks = sorted(bricks, key=lambda b: b[3])[:30]
    y_pos = range(len(sorted_bricks))
    defect_vals = [b[3] for b in sorted_bricks]
    labels_nm = [f'({b[0]},{b[1]},{b[2]})' for b in sorted_bricks]
    ax.barh(y_pos, defect_vals, color='mediumseagreen', edgecolor='white')
    ax.set_yticks(y_pos)
    ax.set_yticklabels(labels_nm, fontsize=7)
    ax.set_xlabel('Defect')
    ax.set_title('Top 30 Near-Miss Perfect Cuboids')
    ax.invert_yaxis()

    plt.tight_layout()
    plt.savefig('euler_brick_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved euler_brick_analysis.png")


if __name__ == "__main__":
    main()
