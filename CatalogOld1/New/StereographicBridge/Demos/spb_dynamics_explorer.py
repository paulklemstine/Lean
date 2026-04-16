#!/usr/bin/env python3
"""
SPB Dynamics Explorer
======================
Explores the dynamical system T_a(x) = spb(x, a) and its ergodic properties.

Key results:
- When arctan(a)/π is irrational, orbits are equidistributed w.r.t. Cauchy measure
- Random SPB walks converge to Cauchy distribution
- SPB iteration generates the multiple angle formula: spb^n(tan θ) = tan(nθ)
"""

import math
import random
from collections import Counter

def spb(x, y):
    """SPB: (x+y)/(1-xy)"""
    d = 1 - x * y
    if abs(d) < 1e-15:
        return float('inf')
    return (x + y) / d

def spbH(x, y):
    """Hyperbolic SPB: (x+y)/(1+xy)"""
    return (x + y) / (1 + x * y)

def spb_iter(x, n):
    """n-fold SPB iteration."""
    result = 0
    for _ in range(n):
        result = spb(x, result)
    return result

def cauchy_cdf(x):
    """CDF of the standard Cauchy distribution."""
    return 0.5 + math.atan(x) / math.pi

print("=" * 70)
print("SPB DYNAMICS EXPLORER")
print("=" * 70)

# --- 1. Multiple Angle Formula ---
print("\n--- Multiple Angle Formula: spb^n(tan θ) = tan(nθ) ---")
theta = 0.7
t = math.tan(theta)
print(f"θ = {theta}, tan(θ) = {t:.10f}")
for n in range(1, 11):
    spb_n = spb_iter(t, n)
    exact = math.tan(n * theta)
    err = abs(spb_n - exact)
    print(f"  n={n:2d}: spb^n = {spb_n:14.10f}, tan(nθ) = {exact:14.10f}, err = {err:.2e}")

# --- 2. Equidistribution ---
print("\n--- Equidistribution of SPB Orbits ---")
print("For T_a(x) = spb(x, a) with arctan(a)/π irrational:")

a = math.sqrt(2)  # arctan(√2)/π is irrational
print(f"  a = √2 ≈ {a:.6f}, arctan(a)/π ≈ {math.atan(a)/math.pi:.10f}")

N = 10000
x = 0.0
orbit = []
for _ in range(N):
    x = spb(x, a)
    if abs(x) < 1e10:  # skip near-poles
        orbit.append(x)

# Test equidistribution via KS test against Cauchy
orbit_sorted = sorted(orbit)
n = len(orbit_sorted)
max_diff = 0
for i, val in enumerate(orbit_sorted):
    empirical = (i + 1) / n
    theoretical = cauchy_cdf(val)
    max_diff = max(max_diff, abs(empirical - theoretical))

print(f"  Orbit length: {n}")
print(f"  KS statistic: {max_diff:.6f}")
print(f"  Expected O(1/√N) ≈ {1/math.sqrt(n):.6f}")
print(f"  Equidistributed? {'YES' if max_diff < 3/math.sqrt(n) else 'POSSIBLY NOT'}")

# --- 3. Orbit Statistics ---
print("\n--- Orbit Statistics ---")
# Quartiles of Cauchy: ±1 (Q1, Q3), 0 (median)
below_q1 = sum(1 for x in orbit if x < -1) / n
between = sum(1 for x in orbit if -1 <= x <= 1) / n
above_q3 = sum(1 for x in orbit if x > 1) / n
print(f"  Fraction < -1: {below_q1:.4f} (expected: 0.25)")
print(f"  Fraction in [-1,1]: {between:.4f} (expected: 0.50)")
print(f"  Fraction > 1: {above_q3:.4f} (expected: 0.25)")

# --- 4. Random SPB Walk ---
print("\n--- Random SPB Walk ---")
print("x_{n+1} = spb(x_n, a_n) with a_n ~ Cauchy(0,1)")

n_walks = 5000
n_steps = 50
final_values = []

for _ in range(n_walks):
    x = 0.0
    for _ in range(n_steps):
        a = math.tan(math.pi * (random.random() - 0.5))
        x = spb(x, a)
        if abs(x) > 1e15:
            x = math.tan(math.pi * (random.random() - 0.5))
    final_values.append(x)

# Statistics
valid = [v for v in final_values if abs(v) < 1e10]
valid_sorted = sorted(valid)
n_valid = len(valid)
median = valid_sorted[n_valid // 2]
q1 = valid_sorted[n_valid // 4]
q3 = valid_sorted[3 * n_valid // 4]
iqr = q3 - q1

print(f"  {n_steps} steps, {n_walks} walks")
print(f"  Median: {median:.4f} (expected: ≈ 0)")
print(f"  IQR: {iqr:.4f} (expected: ≈ 2)")
print(f"  Q1: {q1:.4f} (expected: ≈ -1)")
print(f"  Q3: {q3:.4f} (expected: ≈ +1)")

# --- 5. Hyperbolic SPB Contraction ---
print("\n--- Hyperbolic SPB: Contraction on (-1,1) ---")
print("For |x|, |y| < r < 1: |spbH(x,y)| < 1")

for r in [0.1, 0.3, 0.5, 0.7, 0.9, 0.99]:
    max_output = 0
    for _ in range(10000):
        x = random.uniform(-r, r)
        y = random.uniform(-r, r)
        result = abs(spbH(x, y))
        max_output = max(max_output, result)
    bound = 2 * r / (1 + r**2)
    print(f"  r={r:.2f}: max |spbH| = {max_output:.6f}, bound 2r/(1+r²) = {bound:.6f}")

# --- 6. SPB Orbits for Different a ---
print("\n--- Orbit Periods for Rational arctan(a)/π ---")
for a_val, desc in [(1.0, "a=1, arctan(1)/π=1/4"), 
                     (math.sqrt(3), "a=√3, arctan(√3)/π=1/3"),
                     (1/math.sqrt(3), "a=1/√3, arctan/π=1/6")]:
    x = 0.0
    period = None
    for n in range(1, 100):
        x = spb(x, a_val)
        if abs(x) < 1e-10:
            period = n
            break
    print(f"  {desc}: period = {period}")

print("\n" + "=" * 70)
print("KEY INSIGHT: SPB dynamics on ℝ is conjugate (via Cayley transform)")
print("to rotation on S¹. Equidistribution follows from Weyl's theorem!")
print("=" * 70)
