#!/usr/bin/env python3
"""
SPB Machin Formula Demo
========================
Demonstrates how classical Machin-like formulas for π can be expressed
purely in terms of SPB operations.

The key identity: arctan(spb(x,y)) = arctan(x) + arctan(y) when xy < 1
"""

import math

def spb(x, y):
    """The Stereographic Projection Bridge: spb(x,y) = (x+y)/(1-xy)"""
    return (x + y) / (1 - x * y)

def spb_chain(x, n):
    """Compute spb^n(x) = n-fold SPB iteration."""
    result = 0  # identity element
    for _ in range(n):
        result = spb(x, result)
    return result

print("=" * 70)
print("SPB MACHIN FORMULA DEMO")
print("=" * 70)

# --- Euler's Formula ---
print("\n--- Euler's Formula ---")
print("π/4 = arctan(1/2) + arctan(1/3)")
euler_spb = spb(1/2, 1/3)
print(f"spb(1/2, 1/3) = {euler_spb}")
print(f"arctan(spb(1/2, 1/3)) = {math.atan(euler_spb):.15f}")
print(f"π/4                   = {math.pi/4:.15f}")
print(f"Match: {abs(euler_spb - 1.0) < 1e-15}")

# --- Hutton's Formula ---
print("\n--- Hutton's Formula ---")
print("π/4 = 2·arctan(1/3) + arctan(1/7)")
step1 = spb(1/3, 1/3)
print(f"spb(1/3, 1/3) = {step1} = {3/4}")
hutton_spb = spb(step1, 1/7)
print(f"spb(3/4, 1/7) = {hutton_spb}")
print(f"Match: {abs(hutton_spb - 1.0) < 1e-15}")

# --- Machin's Formula ---
print("\n--- Machin's Formula ---")
print("π/4 = 4·arctan(1/5) - arctan(1/239)")
s1 = spb(1/5, 1/5)
print(f"Step 1: spb(1/5, 1/5) = {s1} = 5/12")
s2 = spb(s1, s1)
print(f"Step 2: spb(5/12, 5/12) = {s2} = {120/119}")
machin_spb = spb(s2, -1/239)
print(f"Step 3: spb(120/119, -1/239) = {machin_spb}")
print(f"Match: {abs(machin_spb - 1.0) < 1e-15}")

# --- Verification via arctan ---
print("\n--- Numerical Verification ---")
print(f"4·arctan(1/5) - arctan(1/239) = {4*math.atan(1/5) - math.atan(1/239):.15f}")
print(f"π/4                           = {math.pi/4:.15f}")

# --- SPB Addition Chain for tan(nθ) ---
print("\n--- SPB Iteration: tan(nθ) from tan(θ) ---")
theta = 0.3  # arbitrary angle
tan_theta = math.tan(theta)
print(f"θ = {theta}, tan(θ) = {tan_theta:.10f}")
for n in range(1, 8):
    spb_result = spb_chain(tan_theta, n)
    exact = math.tan(n * theta)
    error = abs(spb_result - exact)
    print(f"  spb^{n}(tan θ) = {spb_result:12.8f}, tan({n}θ) = {exact:12.8f}, error = {error:.2e}")

# --- Pythagorean Triples from SPB ---
print("\n--- Pythagorean Triples via SPB Weierstrass Parametrization ---")
print("t = a/b → triple (b²-a², 2ab, b²+a²)")
for a, b in [(1, 2), (1, 3), (2, 3), (1, 4), (3, 4), (2, 5)]:
    x = b**2 - a**2
    y = 2 * a * b
    z = a**2 + b**2
    print(f"  t = {a}/{b} → ({x}, {y}, {z}), check: {x}² + {y}² = {x**2 + y**2} = {z}² = {z**2}")

# --- SPB as addition on S¹ ---
print("\n--- SPB Composition Table (small rationals) ---")
rationals = [0, 1/2, 1, 2, -1, -1/2]
print(f"{'spb':>6}", end="")
for y in rationals:
    print(f" | {y:>7}", end="")
print()
print("-" * 60)
for x in rationals:
    print(f"{x:>6}", end="")
    for y in rationals:
        try:
            val = spb(x, y)
            print(f" | {val:>7.3f}", end="")
        except ZeroDivisionError:
            print(f" |     ∞  ", end="")
    print()

print("\n" + "=" * 70)
print("KEY INSIGHT: Every Machin-like formula for π is an SPB identity!")
print("The formula 1 = spb(spb(spb(1/5, 1/5), spb(1/5, 1/5)), -1/239)")
print("encodes Machin's formula: 4·arctan(1/5) - arctan(1/239) = π/4")
print("=" * 70)
