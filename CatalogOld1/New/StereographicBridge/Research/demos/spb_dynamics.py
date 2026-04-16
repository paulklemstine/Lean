#!/usr/bin/env python3
"""
SPB Dynamics: Orbits, Equidistribution, and Chaos

Demonstrates:
1. Orbit classification (periodic vs. dense)
2. Equidistribution via Weyl's theorem connection
3. Lyapunov exponents
4. Bifurcation diagram for parametric SPB
5. SPB flow on the Poincaré disk
"""

import math
from collections import Counter

def spb(x, y):
    d = 1 - x * y
    if abs(d) < 1e-15:
        return float('inf')
    return (x + y) / d

def spbH(x, y):
    return (x + y) / (1 + x * y)

def cayley_angle(x):
    """Map x ∈ ℝ to angle θ ∈ (-π, π] via Cayley: C(x) = e^{iθ}
    where θ = 2·arctan(x)"""
    return 2 * math.atan(x)

# ============================================================
# 1. ORBIT CLASSIFICATION
# ============================================================

print("=" * 60)
print("SPB DYNAMICS")
print("=" * 60)

print("\n--- 1. Orbit Classification ---")
print("x ↦ spb(x, a) is conjugate to rotation by 2·arctan(a) on S¹")

test_cases = [
    (1.0, "arctan(1)/π = 1/4, period 4"),
    (math.sqrt(3), "arctan(√3)/π = 1/3, period 6"),
    (0.0, "arctan(0)/π = 0, period 1 (identity)"),
    (1/math.sqrt(3), "arctan(1/√3)/π = 1/6, period 12"),
    (0.5, "arctan(1/2)/π ≈ 0.1476, irrational → dense"),
    (math.e - 2, "arctan(e-2)/π ≈ 0.2161, irrational → dense"),
]

for a, desc in test_cases:
    print(f"\n  a = {a:.6f}: {desc}")
    x = 0.0
    orbit = [x]
    period = None
    for i in range(1, 25):
        x = spb(x, a)
        if abs(x) > 1e10:
            print(f"    Blowup at step {i}")
            break
        orbit.append(x)
        if abs(x) < 1e-10 and i > 0:
            period = i
            print(f"    Period = {period}")
            break
    if period is None:
        angles = [cayley_angle(xi) / math.pi for xi in orbit]
        print(f"    First 10 angles/π: {[f'{a:.4f}' for a in angles[:10]]}")

# ============================================================
# 2. EQUIDISTRIBUTION TEST
# ============================================================

print("\n--- 2. Equidistribution Tests ---")

def equidistribution_test(a, N, n_bins=10):
    """Test equidistribution of spb orbit on S¹"""
    x = 0.0
    bins = [0] * n_bins
    for _ in range(N):
        x = spb(x, a)
        if abs(x) > 1e15:
            return None
        angle = (math.atan(x) / math.pi + 0.5) % 1.0  # map to [0,1)
        bins[min(int(angle * n_bins), n_bins - 1)] += 1
    expected = N / n_bins
    chi_sq = sum((b - expected)**2 / expected for b in bins)
    return bins, chi_sq

irrationals = [
    (0.5, "arctan(0.5)/π"),
    (math.sqrt(2), "arctan(√2)/π"),
    (math.pi/4, "arctan(π/4)/π"),
    (math.e - 2, "arctan(e-2)/π"),
    (1/math.e, "arctan(1/e)/π"),
]

N = 10000
for a, name in irrationals:
    result = equidistribution_test(a, N)
    if result is None:
        print(f"  {name}: orbit diverges")
        continue
    bins, chi_sq = result
    uniformity = max(bins) / min(bins) if min(bins) > 0 else float('inf')
    print(f"  {name}")
    print(f"    Bins: {bins}")
    print(f"    χ² = {chi_sq:.2f} (critical ≈ 16.9 at 95%)")
    print(f"    Max/Min ratio: {uniformity:.3f} (ideal = 1.0)")

# ============================================================
# 3. LYAPUNOV EXPONENTS
# ============================================================

print("\n--- 3. Lyapunov Exponents ---")
print("For T_a(x) = spb(x, a), the derivative is (1+a²)/(1-xa)²")
print("Lyapunov exponent λ = lim (1/n) Σ log|T_a'(x_k)|")

for a in [0.3, 0.5, 1.0, math.sqrt(2), 2.0]:
    x = 0.1
    lyap_sum = 0.0
    N = 10000
    valid = True
    for i in range(N):
        denom = 1 - x * a
        if abs(denom) < 1e-12:
            valid = False
            break
        deriv = (1 + a**2) / denom**2
        lyap_sum += math.log(abs(deriv))
        x = spb(x, a)
    if valid:
        lyapunov = lyap_sum / N
        print(f"  a = {a:.4f}: λ = {lyapunov:.6f} {'(rotation, λ≈0)' if abs(lyapunov) < 0.1 else ''}")

# ============================================================
# 4. SPB FLOW TRAJECTORIES
# ============================================================

print("\n--- 4. SPB Flow: dx/dt = spb(x, a) ---")
print("Solution: x(t) = tan(arctan(x₀) + arctan(a)·t)")

def spb_flow(x0, a, t):
    """Exact solution of dx/dt = spb(x, a(t)) for constant a"""
    return math.tan(math.atan(x0) + math.atan(a) * t)

print("\nFlow trajectories for a = 0.5, various x₀:")
for x0 in [-2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0]:
    trajectory = []
    for t_step in range(11):
        t = t_step * 0.5
        try:
            xt = spb_flow(x0, 0.5, t)
            trajectory.append(f"{xt:.3f}")
        except:
            trajectory.append("∞")
    print(f"  x₀={x0:>5.1f}: {' → '.join(trajectory[:6])}")

# ============================================================
# 5. SPB BIFURCATION
# ============================================================

print("\n--- 5. Fixed Points and Bifurcations ---")
print("The map x ↦ spb(spb(x, a), a) = spb²(x, a)")
print("has fixed points where 2·arctan(a) is a half-integer multiple of π")

print("\nPeriod-2 orbits of x ↦ spb(x, a):")
for a_num in range(1, 20):
    a = a_num * 0.1
    # Period-2 iff 2·arctan(a) = π/2, i.e., arctan(a) = π/4, i.e., a = 1
    # More generally, period-n iff n·arctan(a) = k·π for some k
    # Check: is there a 2-cycle from x=0?
    x = 0.0
    x = spb(x, a)
    x = spb(x, a)
    if abs(x) < 1e-10 and abs(a - 1.0) > 0.01:
        print(f"  a = {a:.1f}: period divides 2")

# ============================================================
# 6. HYPERBOLIC SPB CONTRACTION
# ============================================================

print("\n--- 6. Hyperbolic SPB Contraction ---")
print("For |a| < 1, x ↦ spbH(x, a) maps (-1,1) → (-1,1)")

a = 0.5
print(f"\nFixed point of x ↦ spbH(x, {a}):")
# Fixed point: (x+a)/(1+xa) = x → x+a = x+x²a → a(1-x²)=0 → no fixed point for a≠0
# Wait: a(1-x²) = 0 has no solution in (-1,1) for a≠0
# Actually let me recompute: spbH(x,a)=x → x+a = x(1+xa) = x+x²a → a = x²a → x² = 1
# So no fixed point in open interval!
print("  No fixed point in (-1,1) for a ≠ 0 (confirmed)")

print("\nIteration converges to boundary:")
x = 0.0
for i in range(20):
    x = spbH(x, a)
    print(f"  step {i+1}: x = {x:.10f}")

print("\n" + "=" * 60)
print("DYNAMICS EXPLORATION COMPLETE")
print("=" * 60)
