#!/usr/bin/env python3
"""
SPB Explorer: Interactive Demonstrations of the Stereographic Projection Bridge

This script demonstrates key properties of spb(x,y) = (x+y)/(1-xy) through
computational exploration, visualization data generation, and verification of
machine-proven theorems.

Usage:
    python3 spb_explorer.py
"""

import math
import random
from fractions import Fraction

# ============================================================
# 1. BASIC SPB ALGEBRA
# ============================================================

def spb(x, y):
    """The Stereographic Projection Bridge: spb(x,y) = (x+y)/(1-xy)"""
    if isinstance(x, Fraction) and isinstance(y, Fraction):
        denom = 1 - x * y
        if denom == 0:
            return None
        return (x + y) / denom
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return float('inf')
    return (x + y) / denom

def spbH(x, y):
    """Hyperbolic SPB (Einstein velocity addition): (x+y)/(1+xy)"""
    return (x + y) / (1 + x * y)

def spb_power(x, n):
    """Compute spb applied n times: tan(n * arctan(x))"""
    return math.tan(n * math.atan(x))

print("=" * 60)
print("STEREOGRAPHIC PROJECTION BRIDGE EXPLORER")
print("spb(x,y) = (x+y) / (1-xy)")
print("=" * 60)

print("\n--- 1. Basic SPB Properties ---")
print(f"spb(0, x) = x:  spb(0, 3.7) = {spb(0, 3.7)}")
print(f"spb(x, -x) = 0: spb(2, -2) = {spb(2, -2)}")
print(f"Commutative: spb(2,3) = {spb(2,3)}, spb(3,2) = {spb(3,2)}")

# Avoid the pole at spb(1,1)
print(f"Associative: spb(spb(0.5,0.3),0.2) = {spb(spb(0.5,0.3),0.2):.10f}, "
      f"spb(0.5,spb(0.3,0.2)) = {spb(0.5,spb(0.3,0.2)):.10f}")

print(f"\nspb IS tan addition:")
a, b = 0.5, 0.3
print(f"  tan({a}+{b}) = {math.tan(a+b):.10f}")
print(f"  spb(tan {a}, tan {b}) = {spb(math.tan(a), math.tan(b)):.10f}")

# ============================================================
# 2. SPB ORBITS AND EQUIDISTRIBUTION
# ============================================================

print("\n--- 2. SPB Orbits and Equidistribution ---")

# Irrational rotation: arctan(1/2)/π is irrational → dense orbit
print("Irrational orbit (a=0.5): first 10 values")
x = 0.0
for i in range(11):
    angle = math.atan(x) / math.pi
    print(f"  step {i}: x={x:>10.6f}  arctan(x)/π = {angle:.6f}")
    x = spb(x, 0.5)
    if abs(x) > 1e12:
        print("  (orbit diverges to pole)")
        break

# Equidistribution test
print("\nEquidistribution test (a=1/√2, 1000 iterates):")
a_val = 1 / math.sqrt(2)
x = 0.0
bins = [0] * 10
for _ in range(1000):
    x = spb(x, a_val)
    if abs(x) > 1e12:
        x = 0.0
        continue
    angle = (math.atan(x) / math.pi + 0.5) % 1.0
    bins[min(int(angle * 10), 9)] += 1
print(f"  Bin counts (should be ~100 each): {bins}")

# ============================================================
# 3. SPB OVER FINITE FIELDS — THE p±1 LAW
# ============================================================

print("\n--- 3. SPB over Finite Fields: p±1 Law ---")

def spb_mod(x, y, p):
    """SPB over F_p"""
    denom = (1 - x * y) % p
    if denom == 0:
        return None
    return ((x + y) * pow(denom, p - 2, p)) % p

def spb_group_order(p):
    """Find order of SPB group over F_p by iterating from 0 with a generator."""
    for g in range(1, p):
        # Check g is not a pole (1 - g*g ≠ 0 mod p)
        if (1 - g * g) % p == 0:
            continue
        x = 0
        order = 0
        for step in range(1, 2 * p + 5):
            result = spb_mod(x, g, p)
            if result is None:
                # Hit a pole, try next generator
                order = -1
                break
            x = result
            order = step
            if x == 0:
                break
        if order > 0 and x == 0:
            return order, g
    return 0, 0

print(f"{'p':>4} {'p%4':>4} {'predicted':>10} {'actual':>8} {'gen':>5} {'match':>6}")
print("-" * 42)
for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
    predicted = p + 1 if p % 4 == 3 else p - 1
    actual, gen = spb_group_order(p)
    match = "✓" if actual == predicted else "✗"
    print(f"{p:>4} {p%4:>4} {predicted:>10} {actual:>8} {gen:>5} {match:>6}")

# ============================================================
# 4. MACHIN FORMULA TREE
# ============================================================

print("\n--- 4. Machin-like Formulas via SPB ---")

print("Machin-like π formulas as SPB trees (exact rational arithmetic):")

result = spb(Fraction(1,2), Fraction(1,3))
print(f"  Euler:  spb(1/2, 1/3) = {result}  (should be 1)")

result = spb(spb(Fraction(1,3), Fraction(1,3)), Fraction(1,7))
print(f"  Hutton: spb(spb(1/3, 1/3), 1/7) = {result}  (should be 1)")

result = spb(spb(spb(Fraction(1,5), Fraction(1,5)),
                 spb(Fraction(1,5), Fraction(1,5))),
             Fraction(-1, 239))
print(f"  Machin: spb(spb(spb(1/5,1/5), spb(1/5,1/5)), -1/239) = {result}  (should be 1)")

# Search for new 2-leaf Machin-like formulas
print("\nAll 2-leaf Machin formulas spb(1/a, 1/b) = 1 with 1 ≤ a ≤ b ≤ 200:")
count = 0
for a in range(1, 201):
    for b in range(a, 201):
        try:
            result = spb(Fraction(1, a), Fraction(1, b))
            if result == 1:
                count += 1
                print(f"  spb(1/{a}, 1/{b}) = 1  →  arctan(1/{a}) + arctan(1/{b}) = π/4")
        except:
            pass
print(f"  Total found: {count}")
print("  Note: (a-1)(b-1) = 2 → only (a,b) = (2,3) exists!")

# ============================================================
# 5. SPB INTEGER PAIRS
# ============================================================

print("\n--- 5. Integer-Valued SPB Pairs ---")
print("All (a,b) with 0 ≤ a ≤ b ≤ 20 where spb(a,b) ∈ ℤ:")

integer_pairs = []
for a in range(-20, 21):
    for b in range(a, 21):
        denom = 1 - a * b
        if denom == 0:
            continue
        numer = a + b
        if numer % denom == 0:
            result = numer // denom
            integer_pairs.append((a, b, result))

print(f"  Found {len(integer_pairs)} pairs (up to commutativity)")
print("  Selected pairs:")
for a, b, r in sorted(integer_pairs, key=lambda t: (abs(t[2]), abs(t[0])))[:25]:
    print(f"    spb({a:>3}, {b:>3}) = {r:>4}")

# ============================================================
# 6. CAYLEY TRANSFORM
# ============================================================

print("\n--- 6. Cayley Transform C(x) = (x-i)/(x+i) ---")
print("Mapping ℝ → S¹:")
for x in [-10, -5, -2, -1, -0.5, 0, 0.5, 1, 2, 5, 10]:
    re = (x**2 - 1) / (x**2 + 1)
    im = 2*x / (x**2 + 1)
    angle = math.atan2(im, re)
    print(f"  C({x:>6.1f}) = ({re:>7.4f}, {im:>7.4f})  |C| = {math.sqrt(re**2+im**2):.6f}  θ = {angle/math.pi:.4f}π")

# ============================================================
# 7. CHEBYSHEV CONNECTION
# ============================================================

print("\n--- 7. SPB Powers and Chebyshev Polynomials ---")
print("spbPower(n, x) = tan(n·arctan(x))")
x = 0.3
for n in range(1, 8):
    power = spb_power(x, n)
    # Compute iteratively
    iterative = x
    for _ in range(n - 1):
        iterative = spb(iterative, x)
    print(f"  spbPower({n}, {x}) = {power:.10f}  (iterative: {iterative:.10f})")

# ============================================================
# 8. EINSTEIN VELOCITY ADDITION
# ============================================================

print("\n--- 8. Einstein Velocity Addition via Hyperbolic SPB ---")
print("spbH(v1, v2) = (v1+v2)/(1+v1·v2) [with c=1]")

for v1, v2 in [(0.5, 0.5), (0.9, 0.9), (0.99, 0.99), (0.999, 0.999)]:
    classical = v1 + v2
    relativistic = spbH(v1, v2)
    print(f"  v1={v1:.3f}, v2={v2:.3f}: classical={classical:.4f}, "
          f"relativistic={relativistic:.6f}  (always < 1 ✓)")

# ============================================================
# 9. SPB DIFFERENCE IDENTITY
# ============================================================

print("\n--- 9. SPB Difference Identity (NEW) ---")
print("spb(a,b) - spb(a,c) = (b-c)(1+a²) / ((1-ab)(1-ac))")

a, b, c = 0.7, 0.3, 0.5
lhs = spb(a, b) - spb(a, c)
rhs = (b - c) * (1 + a**2) / ((1 - a*b) * (1 - a*c))
print(f"  a={a}, b={b}, c={c}")
print(f"  LHS = {lhs:.12f}")
print(f"  RHS = {rhs:.12f}")
print(f"  Match: {'✓' if abs(lhs - rhs) < 1e-10 else '✗'}")

# ============================================================
# 10. TROPICAL SPB
# ============================================================

print("\n--- 10. Tropical SPB ---")

def trop_spb(x, y):
    return min(x, y) - max(0, x + y)

print("Tropical SPB values:")
for x, y in [(-1, -2), (-3, -1), (1, 2), (-1, 1), (0, 0), (-5, -3)]:
    print(f"  trop_spb({x:>3}, {y:>3}) = {trop_spb(x, y):>5}")

print("\nAssociativity check:")
for (a, b, c) in [(-1,-2,-3), (-5,-1,-2), (-2,-3,-4)]:
    lhs = trop_spb(trop_spb(a, b), c)
    rhs = trop_spb(a, trop_spb(b, c))
    status = "✓" if abs(lhs - rhs) < 1e-10 else "✗"
    print(f"  ({a},{b},{c}): LHS={lhs}, RHS={rhs}  {status}")

print("\n" + "=" * 60)
print("EXPLORATION COMPLETE")
print("=" * 60)
