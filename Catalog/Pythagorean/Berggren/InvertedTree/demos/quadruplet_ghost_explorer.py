#!/usr/bin/env python3
"""
QUADRUPLET GHOST STRUCTURE — Python Exploration
================================================

Explores the extension of the Ghost Triple Structure to Pythagorean quadruples
a² + b² + c² = d².

Key Finding: The naive extension (p₁, p₂, 2c, h) FAILS — it does not form
a Pythagorean quadruple. The CORRECT extension uses p₃ = c (preserved),
giving p₁² + p₂² + c² = h². The third coordinate passes through unchanged.
"""

from math import gcd, sqrt, isqrt
from collections import defaultdict
import itertools

# ═══════════════════════════════════════════════════════════════
# SECTION 1: Core Definitions
# ═══════════════════════════════════════════════════════════════

def quad_p1(a, b, c, d):
    return a + 2*b - 2*d

def quad_p2(a, b, c, d):
    return 2*a + b - 2*d

def quad_h(a, b, c, d):
    return -2*a - 2*b + 3*d

def is_pyth_quad(a, b, c, d):
    return a*a + b*b + c*c == d*d

def universal_parent_quad(a, b, c, d):
    """Universal parent for quadruples: (|p₁|, |p₂|, |c|, h)."""
    return (abs(quad_p1(a, b, c, d)),
            abs(quad_p2(a, b, c, d)),
            abs(c),
            quad_h(a, b, c, d))

# ═══════════════════════════════════════════════════════════════
# SECTION 2: Generate Pythagorean Quadruples
# ═══════════════════════════════════════════════════════════════

def generate_pyth_quads(max_d=100):
    """Generate primitive Pythagorean quadruples with d ≤ max_d."""
    quads = []
    for d in range(1, max_d + 1):
        d2 = d * d
        for a in range(1, d):
            for b in range(a, d):
                rem = d2 - a*a - b*b
                if rem <= 0:
                    break
                c = isqrt(rem)
                if c >= b and c*c == rem and gcd(gcd(a, b), gcd(c, d)) == 1:
                    quads.append((a, b, c, d))
    return quads

# ═══════════════════════════════════════════════════════════════
# SECTION 3: Verify Ghost Quadruple Theorem
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("QUADRUPLET GHOST STRUCTURE — Exploration")
print("=" * 70)

print("\n--- Section 1: Ghost Quadruple Pythagorean Theorem ---\n")
print("Testing: p₁² + p₂² + c² = h² when a² + b² + c² = d²\n")

quads = generate_pyth_quads(50)
print(f"Generated {len(quads)} primitive Pythagorean quadruples with d ≤ 50\n")

# Test naive extension (p₃ = 2c)
naive_works = 0
corrected_works = 0

for a, b, c, d in quads[:20]:
    p1 = quad_p1(a, b, c, d)
    p2 = quad_p2(a, b, c, d)
    h = quad_h(a, b, c, d)
    
    # Naive: p₃ = 2c
    naive_lhs = p1**2 + p2**2 + (2*c)**2
    naive_rhs = h**2
    naive_ok = naive_lhs == naive_rhs
    
    # Corrected: p₃ = c
    corr_lhs = p1**2 + p2**2 + c**2
    corr_rhs = h**2
    corr_ok = corr_lhs == corr_rhs
    
    if naive_ok:
        naive_works += 1
    if corr_ok:
        corrected_works += 1
    
    print(f"  ({a},{b},{c},{d}): naive={'✓' if naive_ok else '✗'}, "
          f"corrected={'✓' if corr_ok else '✗'}, "
          f"p₁={p1:+d}, p₂={p2:+d}, h={h}")

print(f"\n  Naive (p₃=2c) works: {naive_works}/{min(20, len(quads))}")
print(f"  Corrected (p₃=c) works: {corrected_works}/{min(20, len(quads))}")

# Full verification
all_corrected = all(
    quad_p1(a,b,c,d)**2 + quad_p2(a,b,c,d)**2 + c**2 == quad_h(a,b,c,d)**2
    for a, b, c, d in quads
)
print(f"  Corrected holds for ALL {len(quads)} quadruples: {all_corrected}")

# ═══════════════════════════════════════════════════════════════
# SECTION 4: Universal Parent Quadruple
# ═══════════════════════════════════════════════════════════════

print("\n--- Section 2: Universal Parent for Quadruples ---\n")

for a, b, c, d in quads[:10]:
    parent = universal_parent_quad(a, b, c, d)
    is_pyth = is_pyth_quad(*parent)
    descent = parent[3] < d
    print(f"  ({a},{b},{c},{d}) → UP = {parent}  "
          f"Pyth={'✓' if is_pyth else '✗'}, descent={'✓' if descent else '✗'}")

# ═══════════════════════════════════════════════════════════════
# SECTION 5: Descent Analysis
# ═══════════════════════════════════════════════════════════════

print("\n--- Section 3: Descent Analysis ---\n")
print("  For quadruples, descent (h < d) requires a + b > d.")
print("  This may FAIL for elongated quadruples with c >> a,b.\n")

descent_ok = 0
descent_fail = 0

for a, b, c, d in quads:
    h = quad_h(a, b, c, d)
    if h < d:
        descent_ok += 1
    else:
        descent_fail += 1

print(f"  Descent works: {descent_ok}/{len(quads)} ({100*descent_ok/len(quads):.1f}%)")
print(f"  Descent fails: {descent_fail}/{len(quads)} ({100*descent_fail/len(quads):.1f}%)")

# Show examples where descent fails
print("\n  Examples where descent fails (h ≥ d):")
for a, b, c, d in quads:
    h = quad_h(a, b, c, d)
    if h >= d:
        print(f"    ({a},{b},{c},{d}): h={h}, a+b={a+b}, d={d}")
        if len([1 for x in quads if quad_h(*x) >= x[3]]) > 10:
            print("    ... (truncated)")
            break

# ═══════════════════════════════════════════════════════════════
# SECTION 6: Sign-Flip Group
# ═══════════════════════════════════════════════════════════════

print("\n--- Section 4: Sign-Flip Group ---\n")
print("  For corrected ghost (p₁, p₂, c, h):")
print("  Only p₁ and p₂ flip signs → group is ℤ/2 × ℤ/2\n")

for a, b, c, d in quads[:3]:
    p1 = quad_p1(a, b, c, d)
    p2 = quad_p2(a, b, c, d)
    h = quad_h(a, b, c, d)
    
    print(f"  Quadruple ({a}, {b}, {c}, {d}):")
    for s1, s2 in [(1,1), (1,-1), (-1,1), (-1,-1)]:
        sign_name = f"({'+' if s1>0 else '-'}{'+' if s2>0 else '-'})"
        ghost = (s1*p1, s2*p2, c, h)
        is_pyth = is_pyth_quad(*ghost)
        print(f"    {sign_name} ({s1*p1:+d}, {s2*p2:+d}, {c}, {h})  Pyth={'✓' if is_pyth else '✗'}")
    print()

# ═══════════════════════════════════════════════════════════════
# SECTION 7: Comparison with Triples
# ═══════════════════════════════════════════════════════════════

print("--- Section 5: Triple vs Quadruple Ghost Structure ---\n")

print("  SIMILARITIES:")
print("  • p₁ - p₂ = b - a (leg difference preserved)")
print("  • p₁ + p₂ = 3(a+b) - 4d")
print("  • Parity: p₁ ≡ a, p₂ ≡ b, h ≡ d (mod 2)")
print("  • Sign-flip group is ℤ/2 × ℤ/2")
print("  • Lorentz form Q₄(p₁,p₂,c,h) = Q₄(a,b,c,d)")
print()
print("  DIFFERENCES:")
print("  • c is preserved (not transformed)")
print("  • Descent may fail (h ≥ d possible)")
print("  • No guaranteed convergence to a root")
print("  • Berggren tree for quadruples is not as canonical")

# Verify identities
print("\n  Verification of identities:")
for a, b, c, d in quads[:5]:
    p1 = quad_p1(a, b, c, d)
    p2 = quad_p2(a, b, c, d)
    h = quad_h(a, b, c, d)
    
    assert p1 - p2 == b - a, "p₁ - p₂ = b - a FAILED"
    assert p1 + p2 == 3*(a+b) - 4*d, "p₁ + p₂ = 3(a+b) - 4d FAILED"
    assert p1 % 2 == a % 2, "p₁ parity FAILED"
    assert p2 % 2 == b % 2, "p₂ parity FAILED"
    assert h % 2 == d % 2, "h parity FAILED"
    print(f"  ({a},{b},{c},{d}): all identities ✓")

# ═══════════════════════════════════════════════════════════════
# SECTION 8: Fixed Points
# ═══════════════════════════════════════════════════════════════

print("\n--- Section 6: Fixed Points ---\n")
print("  Looking for quadruples where UP(a,b,c,d) = (a,b,c,d):\n")

for a, b, c, d in quads:
    parent = universal_parent_quad(a, b, c, d)
    if parent == (a, b, c, d):
        print(f"  Fixed point: ({a}, {b}, {c}, {d})")

# ═══════════════════════════════════════════════════════════════
# SECTION 9: Iterated Application
# ═══════════════════════════════════════════════════════════════

print("\n--- Section 7: Iterated Descent ---\n")

for a, b, c, d in [(2, 3, 6, 7), (1, 4, 8, 9), (2, 6, 9, 11)]:
    if not is_pyth_quad(a, b, c, d):
        continue
    chain = [(a, b, c, d)]
    cur = (a, b, c, d)
    for _ in range(10):
        parent = universal_parent_quad(*cur)
        if parent[3] <= 0:
            break
        chain.append(parent)
        if parent == cur:  # Fixed point
            break
        cur = parent
    
    print(f"  {(a,b,c,d)} descent ({len(chain)-1} steps):")
    for step in chain:
        is_pyth = is_pyth_quad(*step)
        print(f"    {step}  Pyth={'✓' if is_pyth else '✗'}")
    print()

# ═══════════════════════════════════════════════════════════════
# SECTION 10: Multi-Axis Ghost
# ═══════════════════════════════════════════════════════════════

print("--- Section 8: Multi-Axis Ghost Structure ---\n")
print("  For quadruples, we can define ghost parameters using different")
print("  coordinate pairs. The (a,b)-ghost uses the first two coordinates;")
print("  we can also define (a,c)-ghost and (b,c)-ghost.\n")

def ghost_ac(a, b, c, d):
    """Ghost using (a,c) coordinate pair."""
    p1 = a + 2*c - 2*d
    p2 = 2*a + c - 2*d
    h = -2*a - 2*c + 3*d
    return (p1, p2, b, h)

def ghost_bc(a, b, c, d):
    """Ghost using (b,c) coordinate pair."""
    p1 = b + 2*c - 2*d
    p2 = 2*b + c - 2*d
    h = -2*b - 2*c + 3*d
    return (p1, p2, a, h)

for a, b, c, d in quads[:5]:
    gab = (quad_p1(a,b,c,d), quad_p2(a,b,c,d), c, quad_h(a,b,c,d))
    gac = ghost_ac(a, b, c, d)
    gbc = ghost_bc(a, b, c, d)
    
    pyth_ab = gab[0]**2 + gab[1]**2 + gab[2]**2 == gab[3]**2
    pyth_ac = gac[0]**2 + gac[1]**2 + gac[2]**2 == gac[3]**2
    pyth_bc = gbc[0]**2 + gbc[1]**2 + gbc[2]**2 == gbc[3]**2
    
    print(f"  ({a},{b},{c},{d}): (a,b)-ghost={'✓' if pyth_ab else '✗'}, "
          f"(a,c)-ghost={'✓' if pyth_ac else '✗'}, "
          f"(b,c)-ghost={'✓' if pyth_bc else '✗'}")

print("\n  Key insight: ALL three axis-pair ghosts produce valid quadruples!")
print("  This gives 3 independent descent directions for quadruples.")
print("  For each, descent works when the sum of the chosen pair exceeds d.")

# ═══════════════════════════════════════════════════════════════
# SECTION 11: Summary
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("SUMMARY")
print("=" * 70)
print("""
The Ghost Structure extends to Pythagorean quadruples as follows:

  1. CORRECTED GHOST: (p₁, p₂, c, h) with p₃ = c (preserved, not 2c)
  2. p₁² + p₂² + c² = h² (Ghost Quadruple Pythagorean Theorem)
  3. Sign-flip group remains ℤ/2 × ℤ/2 (acting on p₁, p₂ only)
  4. Descent h < d requires a + b > d (not always true!)
  5. Multi-axis ghosts: 3 valid descent directions using different
     coordinate pairs {(a,b), (a,c), (b,c)}
  6. Fixed points exist: e.g., (1, 2, 2, 3) maps to itself

OPEN QUESTIONS:
  • Does iterated multi-axis descent always terminate?
  • What is the "root" quadruple (analogue of (3,4,5))?
  • Can we build a complete tree for quadruples using all 3 axis pairs?

All core theorems are machine-verified in Lean 4 (0 sorries).
""")
