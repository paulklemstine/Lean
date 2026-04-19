#!/usr/bin/env python3
"""
Four-Dimensional Pythagorean Quadruples: Ghost Structure Exploration

This script explores the ghost structure of 4D Pythagorean quadruples,
computing descent paths, enumerating quadruples, and demonstrating
the key discoveries formalized in Lean 4.

Usage: python3 exploration_demo.py
"""

import math
from itertools import product as iterproduct
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════════
# Section 1: Basic Pythagorean Quadruple Operations
# ═══════════════════════════════════════════════════════════════════

def is_pq(a, b, c, d):
    """Check if (a, b, c, d) is a Pythagorean quadruple."""
    return a**2 + b**2 + c**2 == d**2

def is_primitive_pq(a, b, c, d):
    """Check if (a, b, c, d) is a primitive Pythagorean quadruple."""
    if not is_pq(a, b, c, d):
        return False
    return math.gcd(math.gcd(a, b), math.gcd(c, d)) == 1


# ═══════════════════════════════════════════════════════════════════
# Section 2: Enumerate Pythagorean Quadruples
# ═══════════════════════════════════════════════════════════════════

def enumerate_pqs(max_d):
    """Enumerate all positive Pythagorean quadruples with d ≤ max_d."""
    results = []
    for d in range(1, max_d + 1):
        for a in range(0, d):
            if a**2 > d**2:
                break
            for b in range(a, d):
                if a**2 + b**2 > d**2:
                    break
                rem = d**2 - a**2 - b**2
                c = int(math.isqrt(rem))
                if c >= b and c**2 == rem:
                    results.append((a, b, c, d))
    return results


# ═══════════════════════════════════════════════════════════════════
# Section 3: Ghost Group (ℤ/2)³ × S₃
# ═══════════════════════════════════════════════════════════════════

def ghost_orbit(a, b, c, d):
    """Compute the full ghost orbit: all (ℤ/2)³ × S₃ images."""
    orbit = set()
    # S₃ permutations of (a, b, c)
    perms = [
        (a, b, c), (a, c, b), (b, a, c),
        (b, c, a), (c, a, b), (c, b, a)
    ]
    # (ℤ/2)³ sign flips
    signs = list(iterproduct([1, -1], repeat=3))

    for (x, y, z) in perms:
        for (s1, s2, s3) in signs:
            orbit.add((s1*x, s2*y, s3*z, d))

    return orbit


# ═══════════════════════════════════════════════════════════════════
# Section 4: Lifted Berggren Transforms
# ═══════════════════════════════════════════════════════════════════

def lift12(a, b, c, d):
    """B₂⁻¹ lifted in the (1,2) plane."""
    return (a + 2*b - 2*d, 2*a + b - 2*d, c, -2*a - 2*b + 3*d)

def lift13(a, b, c, d):
    """B₂⁻¹ lifted in the (1,3) plane."""
    return (a + 2*c - 2*d, b, 2*a + c - 2*d, -2*a - 2*c + 3*d)

def lift23(a, b, c, d):
    """B₂⁻¹ lifted in the (2,3) plane."""
    return (a, b + 2*c - 2*d, 2*b + c - 2*d, -2*b - 2*c + 3*d)


def parent_hyp12(a, b, c, d):
    return -2*a - 2*b + 3*d

def parent_hyp13(a, b, c, d):
    return -2*a - 2*c + 3*d

def parent_hyp23(a, b, c, d):
    return -2*b - 2*c + 3*d


# ═══════════════════════════════════════════════════════════════════
# Section 5: Descent Algorithm
# ═══════════════════════════════════════════════════════════════════

def best_descent(a, b, c, d):
    """Find the best lifting plane for descent (smallest parent hypotenuse)."""
    hyps = {
        '(1,2)': parent_hyp12(a, b, c, d),
        '(1,3)': parent_hyp13(a, b, c, d),
        '(2,3)': parent_hyp23(a, b, c, d),
    }
    best_plane = min(hyps, key=hyps.get)
    return best_plane, hyps[best_plane], hyps

def canonical_descent(a, b, c, d, max_steps=20):
    """Perform canonical descent to find the root quadruple."""
    path = [(a, b, c, d)]
    for _ in range(max_steps):
        # Sort spatial components: use absolute values
        coords = sorted([abs(a), abs(b), abs(c)])
        a, b, c = coords
        if d <= 0:
            break

        # Apply the best plane (excluding smallest = a)
        h23 = parent_hyp23(a, b, c, d)
        if h23 >= d or h23 <= 0:
            break

        result = lift23(a, b, c, d)
        a_new, b_new, c_new, d_new = result
        a, b, c, d = abs(a_new), abs(b_new), abs(c_new), abs(d_new)

        # Sort
        coords = sorted([a, b, c])
        a, b, c = coords
        path.append((a, b, c, d))

        if d <= 3:  # reached root
            break

    return path


# ═══════════════════════════════════════════════════════════════════
# Section 6: Lebesgue Parametrization
# ═══════════════════════════════════════════════════════════════════

def lebesgue_param(m, n, p, q):
    """Lebesgue parametrization of Pythagorean quadruples."""
    a = m**2 + n**2 - p**2 - q**2
    b = 2*(m*q + n*p)
    c = 2*(n*q - m*p)
    d = m**2 + n**2 + p**2 + q**2
    return (a, b, c, d)


# ═══════════════════════════════════════════════════════════════════
# Section 7: Error Detection Syndrome
# ═══════════════════════════════════════════════════════════════════

def syndrome(a, b, c, d):
    """Compute the Lorentz syndrome S = a² + b² + c² - d².
    S = 0 for valid quadruples; S ≠ 0 indicates corruption."""
    return a**2 + b**2 + c**2 - d**2


# ═══════════════════════════════════════════════════════════════════
# Main: Run all demonstrations
# ═══════════════════════════════════════════════════════════════════

def main():
    print("=" * 70)
    print("Four-Dimensional Pythagorean Quadruples: Ghost Structure Explorer")
    print("=" * 70)

    # ─── Demo 1: Enumerate quadruples ───
    print("\n" + "─" * 60)
    print("Demo 1: Enumerate Pythagorean quadruples with d ≤ 25")
    print("─" * 60)

    pqs = enumerate_pqs(25)
    primitives = [(a, b, c, d) for (a, b, c, d) in pqs if is_primitive_pq(a, b, c, d) and a > 0]

    print(f"\nTotal quadruples (a ≤ b ≤ c, d ≤ 25): {len(pqs)}")
    print(f"Primitive quadruples with a > 0: {len(primitives)}")
    print("\nFirst 15 quadruples:")
    for i, (a, b, c, d) in enumerate(pqs[:15]):
        prim = "P" if is_primitive_pq(a, b, c, d) else " "
        print(f"  [{prim}] ({a:2d}, {b:2d}, {c:2d}, {d:2d})  "
              f"check: {a}² + {b}² + {c}² = {a**2 + b**2 + c**2} = {d}² = {d**2}")

    # ─── Demo 2: Ghost orbit ───
    print("\n" + "─" * 60)
    print("Demo 2: Ghost Orbit of (1, 2, 2, 3)")
    print("─" * 60)

    orbit = ghost_orbit(1, 2, 2, 3)
    print(f"\nFull ghost orbit size: {len(orbit)} (expected: ≤ 48)")
    print("(Some orbits are smaller due to repeated coordinates)")
    print("\nFirst 12 orbit elements:")
    for i, elem in enumerate(sorted(orbit)[:12]):
        valid = "✓" if is_pq(*elem) else "✗"
        print(f"  {valid} {elem}")

    # ─── Demo 3: Three parent hypotenuses ───
    print("\n" + "─" * 60)
    print("Demo 3: Three Parent Hypotenuses (Key 4D Discovery)")
    print("─" * 60)

    test_cases = [(1, 2, 2, 3), (2, 3, 6, 7), (1, 4, 8, 9), (4, 4, 7, 9)]
    for (a, b, c, d) in test_cases:
        h12 = parent_hyp12(a, b, c, d)
        h13 = parent_hyp13(a, b, c, d)
        h23 = parent_hyp23(a, b, c, d)
        best = min(h12, h13, h23)
        print(f"\n  ({a}, {b}, {c}, {d}):")
        print(f"    h₁₂ = {h12}, h₁₃ = {h13}, h₂₃ = {h23}")
        print(f"    Best = {best} {'< d ✓' if best < d else '>= d ✗'}")
        print(f"    Differences: h₁₂-h₁₃ = 2({c}-{b}) = {2*(c-b)}, "
              f"h₁₂-h₂₃ = 2({c}-{a}) = {2*(c-a)}")

    # ─── Demo 4: Descent paths ───
    print("\n" + "─" * 60)
    print("Demo 4: Descent Paths to Root")
    print("─" * 60)

    descent_examples = [(2, 3, 6, 7), (1, 4, 8, 9), (4, 4, 7, 9), (2, 6, 9, 11), (3, 6, 22, 23)]
    for (a, b, c, d) in descent_examples:
        path = canonical_descent(a, b, c, d)
        print(f"\n  ({a}, {b}, {c}, {d}): depth = {len(path) - 1}")
        for step, quad in enumerate(path):
            valid = "✓" if is_pq(*quad) else "?"
            print(f"    Step {step}: {quad} [{valid}]")

    # ─── Demo 5: Lebesgue parametrization ───
    print("\n" + "─" * 60)
    print("Demo 5: Lebesgue Parametrization")
    print("─" * 60)

    params = [(1, 0, 0, 1), (1, 1, 0, 0), (2, 1, 1, 0), (1, 1, 1, 0), (2, 0, 1, 0)]
    for (m, n, p, q) in params:
        result = lebesgue_param(m, n, p, q)
        a, b, c, d = result
        valid = "✓" if is_pq(a, b, c, d) else "✗"
        print(f"  L({m},{n},{p},{q}) = ({a}, {b}, {c}, {d}) [{valid}]")

    # ─── Demo 6: Error detection ───
    print("\n" + "─" * 60)
    print("Demo 6: Syndrome-Based Error Detection")
    print("─" * 60)

    print("\n  Valid quadruples (syndrome = 0):")
    for (a, b, c, d) in [(1, 2, 2, 3), (2, 3, 6, 7)]:
        s = syndrome(a, b, c, d)
        print(f"    ({a}, {b}, {c}, {d}): S = {s}")

    print("\n  Corrupted quadruples (syndrome ≠ 0):")
    corruptions = [(1, 2, 3, 3), (2, 3, 6, 8), (1, 2, 2, 4)]
    for (a, b, c, d) in corruptions:
        s = syndrome(a, b, c, d)
        print(f"    ({a}, {b}, {c}, {d}): S = {s} ← CORRUPTED")

    # ─── Demo 7: Descent depth statistics ───
    print("\n" + "─" * 60)
    print("Demo 7: Descent Depth Statistics")
    print("─" * 60)

    all_pqs = enumerate_pqs(50)
    depth_counts = defaultdict(int)
    max_depth = 0

    for (a, b, c, d) in all_pqs:
        if a > 0 and is_primitive_pq(a, b, c, d):
            path = canonical_descent(a, b, c, d)
            depth = len(path) - 1
            depth_counts[depth] += 1
            max_depth = max(max_depth, depth)

    print(f"\n  Primitive quadruples with a > 0, d ≤ 50:")
    total = sum(depth_counts.values())
    print(f"  Total: {total}")
    for depth in sorted(depth_counts):
        count = depth_counts[depth]
        avg_label = f"  ({count/total*100:.1f}%)"
        print(f"    Depth {depth}: {count} quadruples{avg_label}")
    print(f"    Max depth: {max_depth}")

    if total > 0:
        avg_depth = sum(d * c for d, c in depth_counts.items()) / total
        print(f"    Average depth: {avg_depth:.2f}")

    # ─── Demo 8: Ghost group sizes ───
    print("\n" + "─" * 60)
    print("Demo 8: Ghost Group Sizes by Dimension")
    print("─" * 60)

    for k in range(3, 9):
        sign_flips = 2 ** (k-1)
        perms = math.factorial(k-1)
        total_group = sign_flips * perms
        lift_planes = math.comb(k-1, 2)
        branches = 3 * lift_planes
        print(f"  k={k}: |G| = {perms} × {sign_flips} = {total_group}, "
              f"planes = {lift_planes}, branches = {branches}")

    # ─── Demo 9: Quaternion norm connection ───
    print("\n" + "─" * 60)
    print("Demo 9: Quaternion Norm Connection")
    print("─" * 60)

    for (a, b, c, d) in [(1, 2, 2, 3), (2, 3, 6, 7), (1, 4, 8, 9)]:
        qn = a**2 + b**2 + c**2 + d**2  # quaternion norm
        print(f"  ({a},{b},{c},{d}): |q|² = {qn} = 2×{d}² = {2*d**2} {'✓' if qn == 2*d**2 else '✗'}")

    print("\n" + "=" * 70)
    print("Exploration complete!")
    print("=" * 70)


if __name__ == "__main__":
    main()
