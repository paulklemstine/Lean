#!/usr/bin/env python3
"""
Pythagorean Quadruple Ghost Structure Explorer

Explores the ghost structure for 4D Pythagorean quadruples a² + b² + c² = d²,
including:
1. Enumeration and statistics of primitive quadruples
2. The (ℤ/2)³ sign-flip (octahedral) ghost group
3. Lifted 3D Berggren inverse transforms
4. Descent in 4D via the three lifting planes
5. Comparison with the 3D ghost structure
"""

import math
from collections import defaultdict
from itertools import product

# ═══════════════════════════════════════════════════════════
# Section 1: Basic Enumeration
# ═══════════════════════════════════════════════════════════

def is_pythagorean_quadruple(a, b, c, d):
    """Check if a² + b² + c² = d²."""
    return a**2 + b**2 + c**2 == d**2

def gcd4(a, b, c, d):
    """GCD of four numbers."""
    return math.gcd(math.gcd(a, b), math.gcd(c, d))

def enumerate_quadruples(N):
    """Find all Pythagorean quadruples with d ≤ N, a ≤ b ≤ c."""
    quads = []
    for d in range(1, N + 1):
        for c in range(0, d):
            for b in range(0, c + 1):
                a_sq = d**2 - b**2 - c**2
                if a_sq < 0:
                    continue
                a = int(math.isqrt(a_sq))
                if a**2 == a_sq and 0 <= a <= b:
                    quads.append((a, b, c, d))
    return quads

def enumerate_primitive_quadruples(N):
    """Find all primitive Pythagorean quadruples with d ≤ N."""
    return [(a, b, c, d) for (a, b, c, d) in enumerate_quadruples(N)
            if gcd4(a, b, c, d) == 1 and a > 0]

print("=" * 60)
print("PYTHAGOREAN QUADRUPLE GHOST STRUCTURE EXPLORER")
print("=" * 60)

print("\n--- Section 1: Enumeration ---")
N = 50
quads = enumerate_quadruples(N)
prims = enumerate_primitive_quadruples(N)
print(f"Total quadruples with d ≤ {N}: {len(quads)}")
print(f"Primitive quadruples with d ≤ {N}: {len(prims)}")
print(f"\nFirst 15 primitive quadruples:")
for q in prims[:15]:
    print(f"  {q}: {q[0]}² + {q[1]}² + {q[2]}² = {q[3]}² "
          f"({q[0]**2} + {q[1]**2} + {q[2]**2} = {q[3]**2})")

# ═══════════════════════════════════════════════════════════
# Section 2: The Octahedral Ghost Group (ℤ/2)³
# ═══════════════════════════════════════════════════════════

print("\n--- Section 2: The Octahedral Ghost Group ---")

def ghost_orbit_4d(a, b, c, d):
    """Generate all 8 elements of the (ℤ/2)³ orbit."""
    orbit = []
    for s1, s2, s3 in product([1, -1], repeat=3):
        orbit.append((s1*a, s2*b, s3*c, d))
    return orbit

# Example: (1, 2, 2, 3)
print("\nGhost orbit of (1, 2, 2, 3):")
for i, g in enumerate(ghost_orbit_4d(1, 2, 2, 3)):
    sign = tuple("+" if x > 0 else "-" for x in g[:3])
    valid = "✓" if is_pythagorean_quadruple(*g) else "✗"
    print(f"  {sign}: {g}  {valid}")

# ═══════════════════════════════════════════════════════════
# Section 3: Lifted Berggren Inverse Transforms
# ═══════════════════════════════════════════════════════════

print("\n--- Section 3: Lifted Berggren Transforms ---")

def lift12_B2(a, b, c, d):
    """B₂⁻¹ lifted in (1,2) plane."""
    return (a + 2*b - 2*d, 2*a + b - 2*d, c, -2*a - 2*b + 3*d)

def lift12_B1(a, b, c, d):
    """B₁⁻¹ lifted in (1,2) plane."""
    return (a + 2*b - 2*d, -2*a - b + 2*d, c, -2*a - 2*b + 3*d)

def lift12_B3(a, b, c, d):
    """B₃⁻¹ lifted in (1,2) plane."""
    return (-a - 2*b + 2*d, 2*a + b - 2*d, c, -2*a - 2*b + 3*d)

def lift13_B2(a, b, c, d):
    """B₂⁻¹ lifted in (1,3) plane."""
    return (a + 2*c - 2*d, b, 2*a + c - 2*d, -2*a - 2*c + 3*d)

def lift23_B2(a, b, c, d):
    """B₂⁻¹ lifted in (2,3) plane."""
    return (a, b + 2*c - 2*d, 2*b + c - 2*d, -2*b - 2*c + 3*d)

# Example: (2, 3, 6, 7) — which lifting plane gives descent?
print("\nDescent of (2, 3, 6, 7) via three lifting planes:")
for name, func in [("(1,2)-lift B₂⁻¹", lift12_B2),
                    ("(1,3)-lift B₂⁻¹", lift13_B2),
                    ("(2,3)-lift B₂⁻¹", lift23_B2)]:
    result = func(2, 3, 6, 7)
    valid = is_pythagorean_quadruple(*result)
    hyp_change = f"{7} → {result[3]}"
    print(f"  {name}: {result}, valid={valid}, hyp: {hyp_change}")

# ═══════════════════════════════════════════════════════════
# Section 4: Multi-Step Descent in 4D
# ═══════════════════════════════════════════════════════════

print("\n--- Section 4: Multi-Step Descent ---")

def best_descent_4d(a, b, c, d):
    """Choose the best lifting plane for descent (smallest hypotenuse)."""
    candidates = []
    for name, func in [("12", lift12_B2), ("13", lift13_B2), ("23", lift23_B2)]:
        r = func(a, b, c, d)
        if r[3] > 0 and r[3] < d:
            candidates.append((r[3], name, r))
    # Also try B₁ and B₃ variants
    for name, func in [("12-B1", lift12_B1), ("12-B3", lift12_B3)]:
        r = func(a, b, c, d)
        if r[3] > 0 and r[3] < d:
            candidates.append((r[3], name, r))
    if candidates:
        candidates.sort()
        return candidates[0]  # (hyp, name, result)
    return None

def descend_4d(a, b, c, d, max_steps=20):
    """Perform descent until no further reduction possible."""
    path = [(a, b, c, d)]
    for _ in range(max_steps):
        result = best_descent_4d(*path[-1])
        if result is None:
            break
        path.append(result[2])
    return path

# Example descents
examples = [(2, 3, 6, 7), (1, 4, 8, 9), (4, 4, 7, 9), (1, 2, 14, 15)]
for ex in examples:
    if is_pythagorean_quadruple(*ex):
        path = descend_4d(*ex)
        print(f"\n  Descent of {ex}:")
        for i, step in enumerate(path):
            print(f"    Step {i}: {step} (d = {step[3]})")

# ═══════════════════════════════════════════════════════════
# Section 5: Statistics on Descent
# ═══════════════════════════════════════════════════════════

print("\n--- Section 5: Descent Statistics ---")
N = 25
prims = enumerate_primitive_quadruples(N)
depths = []
for q in prims:
    path = descend_4d(*q)
    depths.append(len(path) - 1)

if depths:
    print(f"Primitive quadruples with d ≤ {N}: {len(prims)}")
    print(f"Average descent depth: {sum(depths)/len(depths):.1f}")
    print(f"Max descent depth: {max(depths)}")
    print(f"Min descent depth: {min(depths)}")

# ═══════════════════════════════════════════════════════════
# Section 6: Ghost Structure Comparison (3D vs 4D)
# ═══════════════════════════════════════════════════════════

print("\n--- Section 6: 3D vs 4D Comparison ---")

print("""
Dimension | Ghost Group  | Order | Branches | Ghost Elements
----------|-------------|-------|----------|----------------
  3D      | ℤ/2 × ℤ/2  |   4   |    3     |       1
  4D      | (ℤ/2)³     |   8   |    7     |       1
  5D      | (ℤ/2)⁴     |  16   |   15     |       1
  nD      | (ℤ/2)^{n-1}| 2^{n-1}| 2^{n-1}-1|      1

Key Difference in 4D:
- In 3D: ONE universal parent hypotenuse
- In 4D: THREE parent hypotenuses (one per lifting plane)
- The correct plane must be chosen for descent
- Full symmetry group: S₃ × (ℤ/2)² = 24 elements
""")

# ═══════════════════════════════════════════════════════════
# Section 7: The Lebesgue Parametrization
# ═══════════════════════════════════════════════════════════

print("--- Section 7: Lebesgue Parametrization ---")

def lebesgue_param(m, n, p, q):
    """Lebesgue parametrization of Pythagorean quadruples."""
    a = m**2 + n**2 - p**2 - q**2
    b = 2*(m*q + n*p)
    c = 2*(n*q - m*p)
    d = m**2 + n**2 + p**2 + q**2
    return (a, b, c, d)

print("\nSmall Lebesgue quadruples:")
seen = set()
for m in range(1, 5):
    for n in range(0, m):
        for p in range(0, m):
            for q in range(0, m):
                if m**2 + n**2 > p**2 + q**2:
                    quad = lebesgue_param(m, n, p, q)
                    a, b, c, d = quad
                    key = tuple(sorted([abs(a), abs(b), abs(c)]) + [d])
                    if key not in seen and d <= 30 and a > 0:
                        seen.add(key)
                        print(f"  ({m},{n},{p},{q}) → ({a},{b},{c},{d}), "
                              f"check: {a**2+b**2+c**2}={d**2} "
                              f"{'✓' if a**2+b**2+c**2==d**2 else '✗'}")

# ═══════════════════════════════════════════════════════════
# Section 8: Parity Patterns
# ═══════════════════════════════════════════════════════════

print("\n--- Section 8: Parity Patterns ---")
N = 25
parity_counts = defaultdict(int)
for q in enumerate_primitive_quadruples(N):
    pat = tuple(x % 2 for x in q)
    parity_counts[pat] += 1

print(f"\nParity patterns of primitive quadruples (d ≤ {N}):")
for pat, count in sorted(parity_counts.items(), key=lambda x: -x[1]):
    labels = ['odd' if p else 'even' for p in pat]
    print(f"  ({', '.join(labels)}): {count}")

print("\n" + "=" * 60)
print("EXPLORATION COMPLETE")
print("=" * 60)
