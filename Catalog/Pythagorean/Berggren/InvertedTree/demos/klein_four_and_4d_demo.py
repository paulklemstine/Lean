#!/usr/bin/env python3
"""
Klein Four-Group Action and 4D Extension Demo

Demonstrates:
1. The Klein four-group action on ghost triples
2. The fourth ghost and orbit structure
3. Syndrome-based error detection
4. The 4D octahedral ghost group
5. Descent comparison: 3D vs 4D
"""

import math

# ═══════════════════════════════════════════════════════════
# Section 1: 3D Ghost Parameters
# ═══════════════════════════════════════════════════════════

def gp(a, b, c): return a + 2*b - 2*c
def gq(a, b, c): return 2*a + b - 2*c
def gh(a, b, c): return -2*a - 2*b + 3*c

def ghost_id(a, b, c): return (gp(a,b,c), gq(a,b,c), gh(a,b,c))
def ghost_s1(a, b, c): return (gp(a,b,c), -gq(a,b,c), gh(a,b,c))
def ghost_s2(a, b, c): return (-gp(a,b,c), gq(a,b,c), gh(a,b,c))
def ghost_s12(a, b, c): return (-gp(a,b,c), -gq(a,b,c), gh(a,b,c))

print("=" * 60)
print("KLEIN FOUR-GROUP ACTION & 4D EXTENSION")
print("=" * 60)

# ═══════════════════════════════════════════════════════════
# Section 2: The Four Ghost Orbit
# ═══════════════════════════════════════════════════════════

print("\n--- Section 2: Klein Four-Group Orbits ---\n")

ppts = [(3,4,5), (5,12,13), (8,15,17), (20,21,29), (7,24,25), (9,40,41)]

for triple in ppts:
    a, b, c = triple
    p, q, h = gp(a,b,c), gq(a,b,c), gh(a,b,c)
    print(f"  Triple ({a},{b},{c}): (p,q,h) = ({p},{q},{h})")
    print(f"    σ₀ (B₂⁻¹) = {ghost_id(a,b,c)}")
    print(f"    σ₁ (B₁⁻¹) = {ghost_s1(a,b,c)}")
    print(f"    σ₂ (B₃⁻¹) = {ghost_s2(a,b,c)}")
    print(f"    σ₁₂ (4th)  = {ghost_s12(a,b,c)}")
    # Verify all are Pythagorean
    for name, g in [("σ₀", ghost_id(a,b,c)), ("σ₁", ghost_s1(a,b,c)),
                     ("σ₂", ghost_s2(a,b,c)), ("σ₁₂", ghost_s12(a,b,c))]:
        x, y, z = g
        check = "✓" if x**2 + y**2 == z**2 else "✗"
        print(f"      {name}: {x}² + {y}² = {x**2+y**2}, {z}² = {z**2} {check}")
    print()

# ═══════════════════════════════════════════════════════════
# Section 3: Group Multiplication Table
# ═══════════════════════════════════════════════════════════

print("--- Section 3: Klein Four Group Table ---\n")
print("  ℤ/2 × ℤ/2 multiplication table:")
print("  ┌────┬────┬────┬────┬────┐")
print("  │ ·  │ id │ σ₁ │ σ₂ │σ₁₂│")
print("  ├────┼────┼────┼────┼────┤")
print("  │ id │ id │ σ₁ │ σ₂ │σ₁₂│")
print("  │ σ₁ │ σ₁ │ id │σ₁₂│ σ₂ │")
print("  │ σ₂ │ σ₂ │σ₁₂│ id │ σ₁ │")
print("  │σ₁₂│σ₁₂│ σ₂ │ σ₁ │ id │")
print("  └────┴────┴────┴────┴────┘")
print("\n  Correspondence:")
print("    σ₀ (id)  ↔ B₂⁻¹: sign pattern (+p, +q, h)")
print("    σ₁       ↔ B₁⁻¹: sign pattern (+p, -q, h)")
print("    σ₂       ↔ B₃⁻¹: sign pattern (-p, +q, h)")
print("    σ₁σ₂     ↔ ???:   sign pattern (-p, -q, h)  ← FOURTH GHOST")
print("\n  The Berggren tree uses 3 of 4 group elements.")
print("  The fourth ghost completes the Klein four-group but has no tree branch.")

# ═══════════════════════════════════════════════════════════
# Section 4: Syndrome Error Detection
# ═══════════════════════════════════════════════════════════

print("\n--- Section 4: Syndrome Error Detection ---\n")

def syndrome(a, b, c):
    """Compute the ghost syndrome."""
    return gp(a,b,c)**2 + gq(a,b,c)**2 - gh(a,b,c)**2

# For Pythagorean triples, syndrome = 0
print("  Syndrome for Pythagorean triples (should all be 0):")
for a, b, c in ppts:
    s = syndrome(a, b, c)
    print(f"    ({a},{b},{c}): syndrome = {s} {'✓' if s == 0 else '✗'}")

print("\n  Syndrome for corrupted triples:")
for a, b, c in [(3,4,5), (5,12,13)]:
    for delta in [1, -1, 2]:
        s = syndrome(a + delta, b, c)
        expected = (a+delta)**2 + b**2 - c**2
        print(f"    ({a}+{delta},{b},{c}): syndrome = {s}, "
              f"error = a²+b²-c² = {expected}")

# ═══════════════════════════════════════════════════════════
# Section 5: Parity Cascade
# ═══════════════════════════════════════════════════════════

print("\n--- Section 5: Parity Cascade ---\n")

# Show that parities are preserved through descent
def full_descent(a, b, c):
    """Descend to root, tracking parities."""
    path = [(a, b, c)]
    while (a, b, c) != (3, 4, 5) and (a, b, c) != (4, 3, 5):
        p, q, h = gp(a,b,c), gq(a,b,c), gh(a,b,c)
        if p > 0 and q < 0 and h > 0:
            a, b, c = p, -q, h
        elif p > 0 and q > 0 and h > 0:
            a, b, c = p, q, h
        elif p < 0 and q > 0 and h > 0:
            a, b, c = -p, q, h
        else:
            break
        path.append((a, b, c))
        if len(path) > 20:
            break
    return path

print("  Parity preservation through descent:")
for start in [(5,12,13), (7,24,25), (20,21,29), (9,40,41)]:
    path = full_descent(*start)
    print(f"\n  Descent from {start}:")
    for step in path:
        parity = tuple("odd" if x % 2 else "even" for x in step)
        print(f"    {step}: ({parity[0]}, {parity[1]}, {parity[2]})")

# ═══════════════════════════════════════════════════════════
# Section 6: Continued Fraction Connection
# ═══════════════════════════════════════════════════════════

print("\n--- Section 6: Branch Determination via m/n ---\n")

# For Euclid parameters (m, n), the ratio m/n determines the branch
def euclid_branch(m, n):
    if n < m < 2*n: return "B₁⁻¹ (1 < m/n < 2)"
    elif 2*n < m < 3*n: return "B₂⁻¹ (2 < m/n < 3)"
    elif m > 3*n: return "B₃⁻¹ (m/n > 3)"
    elif m == 2*n: return "Root boundary (m/n = 2)"
    elif m == 3*n: return "B₂/B₃ boundary (m/n = 3)"
    else: return "Unknown"

print("  Branch determination by Euclid ratio m/n:")
examples = [(2,1), (3,1), (3,2), (4,1), (4,3), (5,1), (5,2), (5,3), (7,2), (7,4)]
for m, n in examples:
    a = m**2 - n**2
    b = 2*m*n
    c = m**2 + n**2
    ratio = m/n
    branch = euclid_branch(m, n)
    print(f"    (m,n)=({m},{n}), m/n={ratio:.2f}, triple=({a},{b},{c}), branch: {branch}")

# ═══════════════════════════════════════════════════════════
# Section 7: 4D Extension Summary
# ═══════════════════════════════════════════════════════════

print("\n--- Section 7: 3D → 4D Extension ---\n")
print("""
  3D Berggren Ghost Structure:
    - 3 inverse branches → Klein four-group (ℤ/2)²
    - 1 universal parent hypotenuse: h = 3c - 2(a+b)
    - Descent is deterministic

  4D Quadruple Ghost Structure (NEW):
    - 3 lifting planes × 3 branches = 9 transforms
    - 3 parent hypotenuses (one per plane)
    - Descent requires choosing the right plane
    - Ghost group: (ℤ/2)³ (8 elements)
    - Full symmetry: S₃ × (ℤ/2)³ (48 elements)

  Key Insight: The transition from 3D to 4D breaks the
  universality of the parent hypotenuse. This is the most
  significant structural difference between the ghost
  structures in different dimensions.
""")

print("=" * 60)
print("DEMO COMPLETE")
print("=" * 60)
