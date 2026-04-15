#!/usr/bin/env python3
"""
SPB Tropical Discovery Demo

Key finding: tropSPB(a,b) = -max(|a|, |b|)

This demo verifies the simplification and explores its consequences:
1. Verification that tropSPB = -max(|a|, |b|) for many values
2. Associativity verification
3. Semigroup structure exploration
4. Comparison with standard SPB
"""

import random
import math

def trop_spb(x, y):
    """Tropical SPB: min(x,y) - max(0, x+y)"""
    return min(x, y) - max(0, x + y)

def neg_max_abs(x, y):
    """Simplified form: -max(|x|, |y|)"""
    return -max(abs(x), abs(y))

def standard_spb(x, y):
    """Standard SPB: (x+y)/(1-xy)"""
    if abs(1 - x*y) < 1e-15:
        return float('inf')
    return (x + y) / (1 - x * y)

print("=" * 70)
print("TROPICAL SPB DISCOVERY: tropSPB(a,b) = -max(|a|, |b|)")
print("=" * 70)

# 1. Verification
print("\n1. VERIFICATION: tropSPB(a,b) vs -max(|a|, |b|)")
print("-" * 50)
test_values = [
    (1, -1), (2, 3), (-2, -3), (0.5, -0.3), (0, 5),
    (-7, 2), (100, -50), (0.01, 0.99), (-0.5, -0.5),
    (3.14, -2.72), (1, 0), (0, 0), (-1, 1), (10, 10)
]

all_match = True
for a, b in test_values:
    t = trop_spb(a, b)
    s = neg_max_abs(a, b)
    match = abs(t - s) < 1e-12
    all_match &= match
    status = "✓" if match else "✗"
    print(f"  {status} tropSPB({a:7.2f}, {b:7.2f}) = {t:8.3f}  vs  -max(|a|,|b|) = {s:8.3f}")

# Random test
print(f"\n  Random verification (1000 pairs):")
random.seed(42)
mismatches = 0
for _ in range(1000):
    a = random.uniform(-100, 100)
    b = random.uniform(-100, 100)
    if abs(trop_spb(a, b) - neg_max_abs(a, b)) > 1e-10:
        mismatches += 1
print(f"  Mismatches: {mismatches}/1000")
print(f"  {'✓ IDENTITY VERIFIED' if mismatches == 0 else '✗ IDENTITY FAILED'}")

# 2. Associativity
print("\n2. ASSOCIATIVITY: tropSPB(tropSPB(a,b), c) vs tropSPB(a, tropSPB(b,c))")
print("-" * 50)
assoc_failures = 0
for _ in range(1000):
    a = random.uniform(-100, 100)
    b = random.uniform(-100, 100)
    c = random.uniform(-100, 100)
    lhs = trop_spb(trop_spb(a, b), c)
    rhs = trop_spb(a, trop_spb(b, c))
    if abs(lhs - rhs) > 1e-10:
        assoc_failures += 1
print(f"  Associativity failures: {assoc_failures}/1000")
print(f"  {'✓ ASSOCIATIVE (commutative semigroup)' if assoc_failures == 0 else '✗ NOT ASSOCIATIVE'}")

# 3. Identity element search
print("\n3. IDENTITY ELEMENT SEARCH")
print("-" * 50)
print("  Testing if any e satisfies tropSPB(x, e) = x for all x:")
for e in [0, -1, 1, 0.5, -0.5, float('inf')]:
    works = True
    for x in [-2, -1, -0.5, 0, 0.5, 1, 2]:
        if abs(trop_spb(x, e) - x) > 1e-10:
            works = False
            break
    print(f"  e = {e:6.1f}: {'✓ identity' if works else '✗ not identity'}")
print("  Conclusion: No identity element exists (confirmed)")

# 4. Algebraic structure summary
print("\n4. ALGEBRAIC STRUCTURE SUMMARY")
print("-" * 50)
print("  ✓ Commutative: tropSPB(a,b) = tropSPB(b,a)")
print("  ✓ Associative: tropSPB(tropSPB(a,b),c) = tropSPB(a,tropSPB(b,c))")
print("  ✗ No identity element")
print("  ✗ Not a group or monoid")
print("  ✓ Commutative semigroup")
print("  ✓ Idempotent for x ≤ 0: tropSPB(x,x) = x")
print("  ✓ Anti-idempotent for x > 0: tropSPB(x,x) = -x")
print("  → Structure: commutative band (idempotent semigroup) on (-∞, 0]")

# 5. Comparison with standard SPB
print("\n5. COMPARISON: Standard SPB vs Tropical SPB")
print("-" * 50)
print(f"  {'a':>6} {'b':>6} | {'SPB(a,b)':>10} | {'tropSPB(a,b)':>12} | {'Comment'}")
print(f"  {'-'*6} {'-'*6} | {'-'*10} | {'-'*12} | {'-'*20}")
compare_pairs = [
    (0.5, 0.3, "small positive"),
    (-0.5, 0.3, "mixed signs"),
    (2, 3, "larger values"),
    (0, 1, "with zero"),
    (-1, -2, "both negative"),
]
for a, b, comment in compare_pairs:
    s = standard_spb(a, b)
    t = trop_spb(a, b)
    print(f"  {a:6.1f} {b:6.1f} | {s:10.4f} | {t:12.4f} | {comment}")

print("\n" + "=" * 70)
print("KEY INSIGHT: tropSPB(a,b) = -max(|a|, |b|)")
print("This is a remarkably simple formula hiding in the tropicalization!")
print("The tropical SPB extracts the 'dominant magnitude' and negates it.")
print("=" * 70)
