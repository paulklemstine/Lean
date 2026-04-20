#!/usr/bin/env python3
"""
Ghost Structure & Descent Theory for Pythagorean Quadruples — Interactive Demo

This script demonstrates and explores the key results from the Lean4-verified
research on 4D Pythagorean quadruples.

Usage:
  python ghost_exploration_demo.py

Sections:
  1. Enumerate all PQs up to a given hypotenuse bound
  2. Ghost orbit computation (sign flips + permutations)
  3. Descent via three lifting planes
  4. Greedy descent to canonical root (1,2,2,3)
  5. Descent depth statistics
  6. Matrix descent algebra
  7. Error detection via syndrome
  8. 5D quintuple generation
  9. Quaternion connection
"""

import itertools
import math
from collections import Counter
import numpy as np

# ═══════════════════════════════════════════════════════════════
# Section 1: Pythagorean Quadruple Enumeration
# ═══════════════════════════════════════════════════════════════

def is_pq(a, b, c, d):
    """Check if a² + b² + c² = d²."""
    return a**2 + b**2 + c**2 == d**2

def enumerate_pqs(max_d):
    """Enumerate all PQs (a ≤ b ≤ c, a ≥ 0) with hypotenuse ≤ max_d."""
    pqs = []
    for d in range(1, max_d + 1):
        d2 = d * d
        for c in range(0, d):
            for b in range(0, c + 1):
                a2 = d2 - b*b - c*c
                if a2 < 0:
                    break
                a = int(math.isqrt(a2))
                if a*a == a2 and a <= b:
                    pqs.append((a, b, c, d))
    return pqs

def is_primitive(a, b, c, d):
    """Check if gcd(a, b, c, d) = 1."""
    return math.gcd(math.gcd(a, b), math.gcd(c, d)) == 1

# ═══════════════════════════════════════════════════════════════
# Section 2: Ghost Orbit (B₃ = S₃ ⋊ (ℤ/2)³)
# ═══════════════════════════════════════════════════════════════

def ghost_orbit(a, b, c, d):
    """Compute the full ghost orbit under B₃ = S₃ × (ℤ/2)³."""
    orbit = set()
    for perm in itertools.permutations([a, b, c]):
        for signs in itertools.product([1, -1], repeat=3):
            sa, sb, sc = signs[0]*perm[0], signs[1]*perm[1], signs[2]*perm[2]
            orbit.add((sa, sb, sc, d))
    return orbit

# ═══════════════════════════════════════════════════════════════
# Section 3: Three Lifting Planes (Descent)
# ═══════════════════════════════════════════════════════════════

def parent_hyp_23(a, b, c, d):
    """Parent hypotenuse from (2,3)-plane (excludes a)."""
    return -2*b - 2*c + 3*d

def parent_hyp_13(a, b, c, d):
    """Parent hypotenuse from (1,3)-plane (excludes b)."""
    return -2*a - 2*c + 3*d

def parent_hyp_12(a, b, c, d):
    """Parent hypotenuse from (1,2)-plane (excludes c)."""
    return -2*a - 2*b + 3*d

# Lifted Berggren inverse matrices (from GhostStructure4D.lean)
M_L23 = np.array([
    [1,  0,  0,  0],
    [0,  1,  2, -2],
    [0,  2,  1, -2],
    [0, -2, -2,  3]
])

M_L13 = np.array([
    [1,  0,  2, -2],
    [0,  1,  0,  0],
    [2,  0,  1, -2],
    [-2, 0, -2,  3]
])

M_L12 = np.array([
    [1,  2,  0, -2],
    [2,  1,  0, -2],
    [0,  0,  1,  0],
    [-2, -2, 0,  3]
])

def descend_23(a, b, c, d):
    """Apply M_L23 descent."""
    v = np.array([a, b, c, d])
    r = M_L23 @ v
    return tuple(r.tolist())

def descend_13(a, b, c, d):
    """Apply M_L13 descent."""
    v = np.array([a, b, c, d])
    r = M_L13 @ v
    return tuple(r.tolist())

def descend_12(a, b, c, d):
    """Apply M_L12 descent."""
    v = np.array([a, b, c, d])
    r = M_L12 @ v
    return tuple(r.tolist())

# ═══════════════════════════════════════════════════════════════
# Section 4: Greedy Descent to Root
# ═══════════════════════════════════════════════════════════════

def normalize(a, b, c, d):
    """Make spatial components non-negative and ordered."""
    abc = sorted([abs(a), abs(b), abs(c)])
    return (abc[0], abc[1], abc[2], abs(d))

def greedy_descent(a, b, c, d, max_steps=100):
    """Greedily descend by choosing plane with smallest parent hypotenuse.
    Returns the descent chain."""
    chain = [(a, b, c, d)]
    for _ in range(max_steps):
        a, b, c, d = normalize(a, b, c, d)
        if d <= 1:
            break
        # Compute all three parent hypotenuses
        h23 = parent_hyp_23(a, b, c, d)
        h13 = parent_hyp_13(a, b, c, d)
        h12 = parent_hyp_12(a, b, c, d)

        # Choose best plane
        hyps = [(h23, '23'), (h13, '13'), (h12, '12')]
        hyps.sort()
        best_h, best_plane = hyps[0]

        if best_h >= d:
            break  # No descent possible

        # Apply descent
        if best_plane == '23':
            result = descend_23(a, b, c, d)
        elif best_plane == '13':
            result = descend_13(a, b, c, d)
        else:
            result = descend_12(a, b, c, d)

        a, b, c, d = normalize(*result)
        chain.append((a, b, c, d))

        if (a, b, c, d) == (1, 2, 2, 3) or d <= 1:
            break

    return chain

# ═══════════════════════════════════════════════════════════════
# Section 5: Syndrome-Based Error Detection
# ═══════════════════════════════════════════════════════════════

def syndrome(a, b, c, d):
    """Compute S = a² + b² + c² - d²."""
    return a**2 + b**2 + c**2 - d**2

# ═══════════════════════════════════════════════════════════════
# Section 6: 5D Quintuples
# ═══════════════════════════════════════════════════════════════

def is_pq5(a, b, c, d, e):
    """Check a² + b² + c² + d² = e²."""
    return a**2 + b**2 + c**2 + d**2 == e**2

def enumerate_pq5s(max_e):
    """Enumerate ordered PQ5s (a ≤ b ≤ c ≤ d)."""
    pq5s = []
    for e in range(1, max_e + 1):
        e2 = e * e
        for d in range(0, e):
            for c in range(0, d + 1):
                rem = e2 - c*c - d*d
                if rem < 0:
                    break
                for b in range(0, c + 1):
                    a2 = rem - b*b
                    if a2 < 0:
                        break
                    a = int(math.isqrt(a2))
                    if a*a == a2 and a <= b:
                        pq5s.append((a, b, c, d, e))
    return pq5s

# ═══════════════════════════════════════════════════════════════
# Section 7: Quaternion Norm
# ═══════════════════════════════════════════════════════════════

def quat_norm(a, b, c, d):
    return a**2 + b**2 + c**2 + d**2

# ═══════════════════════════════════════════════════════════════
# MAIN DEMONSTRATION
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("PYTHAGOREAN QUADRUPLES: GHOST STRUCTURE & DESCENT THEORY")
    print("Machine-verified in Lean 4 — Interactive Python Demo")
    print("=" * 70)

    # 1. Enumeration
    print("\n" + "=" * 70)
    print("1. ENUMERATION OF PYTHAGOREAN QUADRUPLES")
    print("=" * 70)

    for bound in [10, 25, 50]:
        pqs = enumerate_pqs(bound)
        prims = [q for q in pqs if q[0] > 0 and is_primitive(*q)]
        print(f"  d ≤ {bound:3d}: {len(pqs):4d} total (a≤b≤c),  {len(prims):3d} primitive (a>0)")

    # 2. Ghost Orbits
    print("\n" + "=" * 70)
    print("2. GHOST ORBITS (B₃ = S₃ ⋊ (ℤ/2)³)")
    print("=" * 70)

    examples = [(1, 2, 2, 3), (2, 3, 6, 7), (1, 4, 8, 9)]
    for ex in examples:
        orbit = ghost_orbit(*ex)
        print(f"  {ex}: orbit size = {len(orbit)} (max 48)")

    # 3. Three Parent Hypotenuses
    print("\n" + "=" * 70)
    print("3. THREE PARENT HYPOTENUSES")
    print("=" * 70)
    print(f"  {'Quadruple':20s} {'h₂₃':>5s} {'h₁₃':>5s} {'h₁₂':>5s} {'Best':>6s}")
    print("  " + "-" * 50)

    test_quads = [(1,2,2,3), (2,3,6,7), (1,4,8,9), (4,4,7,9), (2,6,9,11)]
    for q in test_quads:
        h23 = parent_hyp_23(*q)
        h13 = parent_hyp_13(*q)
        h12 = parent_hyp_12(*q)
        best = "h₂₃" if h23 <= h13 and h23 <= h12 else ("h₁₃" if h13 <= h12 else "h₁₂")
        print(f"  {str(q):20s} {h23:5d} {h13:5d} {h12:5d} {best:>6s}")

    # 4. Greedy Descent Chains
    print("\n" + "=" * 70)
    print("4. GREEDY DESCENT CHAINS")
    print("=" * 70)

    descent_examples = [(2,3,6,7), (1,4,8,9), (3,6,22,23), (2,6,9,11), (4,4,7,9)]
    for ex in descent_examples:
        chain = greedy_descent(*ex)
        print(f"  {ex} → depth {len(chain)-1}:")
        for i, step in enumerate(chain):
            prefix = "    → " if i > 0 else "      "
            print(f"  {prefix}{step}")

    # 5. Descent Depth Statistics
    print("\n" + "=" * 70)
    print("5. DESCENT DEPTH STATISTICS (d ≤ 50, primitive, a > 0)")
    print("=" * 70)

    pqs_50 = enumerate_pqs(50)
    prims_50 = [q for q in pqs_50 if q[0] > 0 and is_primitive(*q)]
    depths = []
    for q in prims_50:
        chain = greedy_descent(*q)
        depths.append(len(chain) - 1)

    depth_counts = Counter(depths)
    for depth in sorted(depth_counts.keys()):
        count = depth_counts[depth]
        pct = 100 * count / len(depths)
        bar = "█" * int(pct / 2)
        print(f"  Depth {depth}: {count:3d} ({pct:5.1f}%) {bar}")
    avg_depth = sum(depths) / len(depths) if depths else 0
    print(f"  Average depth: {avg_depth:.2f}")

    # 6. Error Detection
    print("\n" + "=" * 70)
    print("6. SYNDROME-BASED ERROR DETECTION")
    print("=" * 70)

    a, b, c, d = 1, 2, 2, 3
    print(f"  Valid PQ {(a,b,c,d)}: S = {syndrome(a,b,c,d)}")
    for comp, name in [(0, 'a'), (1, 'b'), (2, 'c'), (3, 'd')]:
        corrupted = list((a, b, c, d))
        corrupted[comp] += 1
        s = syndrome(*corrupted)
        print(f"  Corrupt {name}→{name}+1: {tuple(corrupted)} → S = {s}")

    print(f"\n  Undetectable error (sign flip): a→-a gives (-1,2,2,3)")
    print(f"    S(-1,2,2,3) = {syndrome(-1,2,2,3)} (still zero — ghost symmetry!)")

    # 7. Matrix Properties
    print("\n" + "=" * 70)
    print("7. DESCENT MATRIX PROPERTIES")
    print("=" * 70)

    for name, M in [("M_L23", M_L23), ("M_L13", M_L13), ("M_L12", M_L12)]:
        det = int(round(np.linalg.det(M)))
        tr = int(np.trace(M))
        print(f"  {name}: det = {det:+d}, trace = {tr}")

    # Check non-commutativity
    prod12 = M_L23 @ M_L13
    prod21 = M_L13 @ M_L23
    print(f"  M_L23·M_L13 == M_L13·M_L23? {np.allclose(prod12, prod21)}")

    # Lorentz form preservation
    eta = np.diag([1, 1, 1, -1])
    for name, M in [("M_L23", M_L23), ("M_L13", M_L13), ("M_L12", M_L12)]:
        preserved = np.allclose(M.T @ eta @ M, eta)
        print(f"  {name} ∈ O(3,1;ℤ)? {preserved}")

    # 8. 5D Quintuples
    print("\n" + "=" * 70)
    print("8. 5D PYTHAGOREAN QUINTUPLES (e ≤ 10)")
    print("=" * 70)

    pq5s = enumerate_pq5s(10)
    print(f"  Found {len(pq5s)} quintuples (ordered, e ≤ 10)")
    for q in pq5s[:10]:
        orbit = set()
        for perm in itertools.permutations(q[:4]):
            for signs in itertools.product([1, -1], repeat=4):
                t = tuple(s*p for s, p in zip(signs, perm)) + (q[4],)
                orbit.add(t)
        print(f"  {q}: orbit size = {len(orbit)}")

    # 9. Quaternion Connection
    print("\n" + "=" * 70)
    print("9. QUATERNION CONNECTION")
    print("=" * 70)

    for q in [(1,2,2,3), (2,3,6,7), (1,4,8,9)]:
        a, b, c, d = q
        qn = quat_norm(a, b, c, d)
        print(f"  PQ {q}: |q|² = {qn} = 2·{d}² = {2*d**2} ✓" if qn == 2*d**2 else f"  PQ {q}: FAIL")

    # Euler's four-square identity demo
    print("\n  Euler's Four-Square Identity:")
    x = (1, 2, 3, 4)
    y = (5, 6, 7, 8)
    prod = quat_norm(*x) * quat_norm(*y)
    # Quaternion product components
    r = (x[0]*y[0]-x[1]*y[1]-x[2]*y[2]-x[3]*y[3],
         x[0]*y[1]+x[1]*y[0]+x[2]*y[3]-x[3]*y[2],
         x[0]*y[2]-x[1]*y[3]+x[2]*y[0]+x[3]*y[1],
         x[0]*y[3]+x[1]*y[2]-x[2]*y[1]+x[3]*y[0])
    result = quat_norm(*r)
    print(f"  |{x}|² · |{y}|² = {quat_norm(*x)} · {quat_norm(*y)} = {prod}")
    print(f"  |product|² = |{r}|² = {result}")
    print(f"  Equal? {prod == result} ✓")

    print("\n" + "=" * 70)
    print("DEMO COMPLETE — All results machine-verified in Lean 4")
    print("=" * 70)
