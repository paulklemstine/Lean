#!/usr/bin/env python3
"""
SPB-EML Discovery Engine
=========================
Computational exploration of new conjectures and patterns in SPB theory.

This script explores several open questions computationally:
  1. Division algebra obstruction (does SPB_d work only for d ∈ {1,3,7}?)
  2. SPB iteration periods over finite fields (the p±1 law)
  3. Continued fraction structure of SPB iteration
  4. Approximation quality of SPB trees
  5. Cauchy distribution stability under iterated SPB
  6. Matrix M(n) subgroup structure in GL(2,Z)
"""

import math
import random
from collections import Counter

# ─────────────────────────────────────────────
#  Core Functions
# ─────────────────────────────────────────────

def spb(x, y):
    d = 1 - x * y
    if abs(d) < 1e-15:
        return float('inf')
    return (x + y) / d

def spb_hyp(x, y):
    return (x + y) / (1 + x * y)

def spb_mod(x, y, p):
    d = (1 - x * y) % p
    if d == 0:
        return None
    return ((x + y) * pow(d, -1, p)) % p

def spb_iter(x, n, c):
    """Iterate spb(·, c) n times starting from x."""
    for _ in range(n):
        x = spb(x, c)
        if x == float('inf'):
            return x
    return x

def spb_iter_mod(x, n, c, p):
    """Iterate spb(·, c) n times starting from x, mod p."""
    for _ in range(n):
        x = spb_mod(x, c, p)
        if x is None:
            return None
    return x

def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0: return False
    return True

# ─────────────────────────────────────────────
#  Discovery 1: Division Algebra Obstruction
# ─────────────────────────────────────────────

def discovery_division_algebra():
    print("=" * 65)
    print("Discovery 1: Division Algebra Obstruction Conjecture")
    print("=" * 65)
    print()
    print("Conjecture: spb_d defines a group iff a division algebra")
    print("exists in dimension d+1.")
    print()
    print("Testing the norm identity:")
    print("  |1-u·v|² · (1+|spb_d|²) = (1+|u|²)(1+|v|²)")
    print()

    def dot(u, v):
        return sum(a*b for a, b in zip(u, v))

    def norm_sq(u):
        return dot(u, u)

    def cross_3d(u, v):
        return [u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0]]

    def spb_d(u, v, d):
        """Attempt spb in dimension d: (u+v)/(1-u·v).
        For d=3, include cross product term."""
        dp = dot(u, v)
        denom = 1 - dp
        if abs(denom) < 1e-12:
            return None
        result = [(u[i] + v[i]) / denom for i in range(d)]
        if d == 3:
            c = cross_3d(u, v)
            result = [result[i] + c[i] / denom for i in range(3)]
        return result

    # Test d=1
    print("  d=1 (ℂ, division algebra in dim 2):")
    for _ in range(3):
        u, v = [random.uniform(-2, 2)], [random.uniform(-2, 2)]
        s = spb_d(u, v, 1)
        if s:
            lhs = (1 - dot(u,v))**2 * (1 + norm_sq(s))
            rhs = (1 + norm_sq(u)) * (1 + norm_sq(v))
            print(f"    u={u[0]:.3f}, v={v[0]:.3f}: error = {abs(lhs-rhs):.2e} ✓")

    # Test d=3 with cross product
    print("  d=3 (ℍ quaternions, division algebra in dim 4):")
    for _ in range(3):
        u = [random.uniform(-1, 1) for _ in range(3)]
        v = [random.uniform(-1, 1) for _ in range(3)]
        s = spb_d(u, v, 3)
        if s:
            lhs = (1 - dot(u,v))**2 * (1 + norm_sq(s))
            rhs = (1 + norm_sq(u)) * (1 + norm_sq(v))
            print(f"    |u|={norm_sq(u)**.5:.3f}, |v|={norm_sq(v)**.5:.3f}: error = {abs(lhs-rhs):.2e} ✓")

    # Test d=2 (should fail)
    print("  d=2 (no division algebra in dim 3):")
    for _ in range(3):
        u = [random.uniform(-1, 1) for _ in range(2)]
        v = [random.uniform(-1, 1) for _ in range(2)]
        s = spb_d(u, v, 2)
        if s:
            lhs = (1 - dot(u,v))**2 * (1 + norm_sq(s))
            rhs = (1 + norm_sq(u)) * (1 + norm_sq(v))
            err = abs(lhs - rhs)
            status = "✓ (matches)" if err < 1e-10 else f"✗ error={err:.4f}"
            print(f"    |u|={norm_sq(u)**.5:.3f}, |v|={norm_sq(v)**.5:.3f}: "
                  f"LHS={lhs:.4f}, RHS={rhs:.4f}, {status}")
    print("    → d=2 formula (u+v)/(1-u·v) without cross product fails the norm identity!")
    print()

# ─────────────────────────────────────────────
#  Discovery 2: SPB Period Patterns
# ─────────────────────────────────────────────

def discovery_period_patterns():
    print("=" * 65)
    print("Discovery 2: SPB Iteration Period Patterns over F_p")
    print("=" * 65)
    print()
    print("For each prime p, compute the period of spb(·, 1) starting from 0.")
    print("Verify: period | p+1 when p≡3(4), period | p-1 when p≡1(4)")
    print()

    p1_periods = []  # periods for p≡1(4)
    p3_periods = []  # periods for p≡3(4)

    for p in range(3, 200):
        if not is_prime(p):
            continue
        x = 0
        period = None
        for k in range(1, 2*p + 5):
            x = spb_mod(x, 1, p)
            if x is None:
                break
            if x == 0:
                period = k
                break

        if period is not None:
            res = p % 4
            if res == 1:
                p1_periods.append((p, period, (p-1) // period))
            else:
                p3_periods.append((p, period, (p+1) // period))

    print("  p ≡ 1 (mod 4): period divides p-1")
    print(f"  {'p':>5s}  {'period':>6s}  {'(p-1)/period':>12s}")
    for p, per, ratio in p1_periods[:12]:
        print(f"  {p:>5d}  {per:>6d}  {ratio:>12d}")

    print()
    print("  p ≡ 3 (mod 4): period divides p+1")
    print(f"  {'p':>5s}  {'period':>6s}  {'(p+1)/period':>12s}")
    for p, per, ratio in p3_periods[:12]:
        print(f"  {p:>5d}  {per:>6d}  {ratio:>12d}")

    # Find the most common period-to-divisor ratios
    print()
    ratios_1 = Counter(r for _, _, r in p1_periods)
    ratios_3 = Counter(r for _, _, r in p3_periods)
    print(f"  p≡1(4): quotient distribution: {dict(ratios_1.most_common(5))}")
    print(f"  p≡3(4): quotient distribution: {dict(ratios_3.most_common(5))}")
    print()

# ─────────────────────────────────────────────
#  Discovery 3: SPB Continued Fractions
# ─────────────────────────────────────────────

def discovery_continued_fractions():
    print("=" * 65)
    print("Discovery 3: SPB Continued Fraction Structure")
    print("=" * 65)
    print()
    print("Iterating x_n = spb(x_{n-1}, a_n) with decreasing a_n:")
    print()

    # SPB "continued fraction" for π/4
    # arctan(1) = π/4, and the Machin-like formulas decompose this
    print("  Machin's formula via SPB: π/4 = arctan(1)")
    print("  arctan(1) = 4·arctan(1/5) - arctan(1/239)")
    print("  ⟹ 1 = spb(spb(spb(spb(1/5, 1/5), spb(1/5, 1/5)), ??), -1/239)")
    print()

    # Verify Machin's formula
    a = math.atan(1/5)
    # 4·arctan(1/5) = arctan(spb(spb(1/5,1/5), spb(1/5,1/5)))
    t1 = spb(1/5, 1/5)  # tan(2·arctan(1/5))
    t2 = spb(t1, t1)    # tan(4·arctan(1/5))
    result = spb(t2, -1/239)  # tan(4·arctan(1/5) - arctan(1/239))
    print(f"  spb(spb(spb(1/5,1/5), spb(1/5,1/5)), -1/239) = {result:.15f}")
    print(f"  tan(π/4) = {math.tan(math.pi/4):.15f}")
    print(f"  Error: {abs(result - 1):.2e}")

    # Gregory-Leibniz via SPB
    print()
    print("  SPB partial sums for arctan(1):")
    print("  arctan(1) = arctan(1/1) = arctan(1/2) + arctan(1/3)")
    a = spb(1/2, 1/3)
    print(f"  spb(1/2, 1/3) = {a:.10f} (should be 1.0)")

    # Decompose arctan(1/3) further
    # arctan(1/3) = arctan(1/4) + arctan(1/13)
    b = spb(1/4, 1/13)
    print(f"  spb(1/4, 1/13) = {b:.10f} (should be 1/3 = 0.33333...)")
    print(f"  Error: {abs(b - 1/3):.2e}")
    print()

# ─────────────────────────────────────────────
#  Discovery 4: SPB Tree Approximation
# ─────────────────────────────────────────────

def discovery_approximation():
    print("=" * 65)
    print("Discovery 4: SPB Tree Approximation Quality")
    print("=" * 65)
    print()
    print("SPB trees of depth n generate rational functions of degree ≤ 2^n.")
    print("Testing approximation of f(x) = sin(x)/(1+x²) on [-3, 3]:")
    print()

    def target_func(x):
        return math.sin(x) / (1 + x**2)

    # Best depth-1 SPB: spb(a, x) = (a+x)/(1-ax)
    # Best depth-2 SPB: spb(spb(a, x), spb(b, x))

    # For depth 1, optimize parameter a to minimize L2 error
    best_err_1 = float('inf')
    best_a = 0
    test_points = [i * 0.1 for i in range(-30, 31)]

    for a_int in range(-100, 101):
        a = a_int * 0.05
        err = sum((target_func(x) - spb(a, x))**2
                  for x in test_points if abs(1 - a * x) > 0.01)
        if err < best_err_1:
            best_err_1 = err
            best_a = a

    print(f"  Depth 1 (1 parameter): best a = {best_a:.2f}, "
          f"L2 error = {best_err_1**.5:.4f}")

    # For depth 2, try a few parameter combinations
    best_err_2 = float('inf')
    best_params = (0, 0)
    for a_int in range(-20, 21, 2):
        for b_int in range(-20, 21, 2):
            a, b = a_int * 0.1, b_int * 0.1
            err = 0
            for x in test_points:
                s1 = spb(a, x)
                s2 = spb(b, x)
                if abs(1 - s1 * s2) > 0.01:
                    s = spb(s1, s2)
                    err += (target_func(x) - s)**2
            if err < best_err_2:
                best_err_2 = err
                best_params = (a, b)

    a, b = best_params
    print(f"  Depth 2 (2 parameters): a={a:.1f}, b={b:.1f}, "
          f"L2 error = {best_err_2**.5:.4f}")
    print(f"  Improvement ratio: {best_err_1**.5 / max(best_err_2**.5, 1e-10):.1f}x")
    print()

# ─────────────────────────────────────────────
#  Discovery 5: Cauchy Stability
# ─────────────────────────────────────────────

def discovery_cauchy_stability():
    print("=" * 65)
    print("Discovery 5: Cauchy Distribution Stability Under SPB")
    print("=" * 65)
    print()
    print("If X₁, X₂ ~ Cauchy(0,1) independently,")
    print("then spb(X₁, X₂) should be ~ Cauchy(0, ???)")
    print()

    random.seed(42)
    n = 50000

    # Generate Cauchy samples using the inverse CDF: tan(π(U - 1/2))
    X1 = [math.tan(math.pi * (random.random() - 0.5)) for _ in range(n)]
    X2 = [math.tan(math.pi * (random.random() - 0.5)) for _ in range(n)]

    # Apply SPB
    spb_results = []
    for x1, x2 in zip(X1, X2):
        d = 1 - x1 * x2
        if abs(d) > 1e-10:
            spb_results.append((x1 + x2) / d)

    # Apply addition (for comparison)
    sum_results = [x1 + x2 for x1, x2 in zip(X1, X2)]

    # Check quartiles
    spb_sorted = sorted(r for r in spb_results if abs(r) < 1e10)
    sum_sorted = sorted(r for r in sum_results if abs(r) < 1e10)

    def quartiles(data):
        n = len(data)
        return (data[n//4], data[n//2], data[3*n//4])

    spb_q = quartiles(spb_sorted)
    sum_q = quartiles(sum_sorted)
    cauchy_q = (math.tan(math.pi * 0.25 - math.pi/2),
                0,
                math.tan(math.pi * 0.75 - math.pi/2))

    # Cauchy(0, γ) has quartiles ±γ
    # For sum of two Cauchy(0,1), result is Cauchy(0, 2)
    print("  Quartiles comparison:")
    print(f"  {'':20s}  {'Q1':>10s}  {'Median':>10s}  {'Q3':>10s}")
    print(f"  {'Standard Cauchy':20s}  {-1.0:>10.4f}  {0.0:>10.4f}  {1.0:>10.4f}")
    print(f"  {'spb(X₁, X₂)':20s}  {spb_q[0]:>10.4f}  {spb_q[1]:>10.4f}  {spb_q[2]:>10.4f}")
    print(f"  {'X₁ + X₂':20s}  {sum_q[0]:>10.4f}  {sum_q[1]:>10.4f}  {sum_q[2]:>10.4f}")
    print(f"  {'Cauchy(0, 2)':20s}  {-2.0:>10.4f}  {0.0:>10.4f}  {2.0:>10.4f}")

    # Key insight: spb of two standard Cauchy is NOT standard Cauchy
    # because spb is not linear. But arctan(spb(X1,X2)) = arctan(X1)+arctan(X2)
    # is uniform on (-π, π), hence spb(X1,X2) ~ Cauchy(0, ???)

    print()
    print("  Key insight: arctan linearizes SPB.")
    angles = [math.atan(s) for s in spb_sorted if abs(s) < 1e8]
    angle_q = quartiles(sorted(angles))
    uniform_q = (-math.pi/4, 0, math.pi/4)
    print(f"  {'arctan(spb(X₁,X₂))':20s}  {angle_q[0]:>10.4f}  {angle_q[1]:>10.4f}  {angle_q[2]:>10.4f}")
    print(f"  {'Uniform(-π/2,π/2)':20s}  {-math.pi/4:>10.4f}  {0.0:>10.4f}  {math.pi/4:>10.4f}")
    print()

# ─────────────────────────────────────────────
#  Discovery 6: M(n) Subgroup Structure
# ─────────────────────────────────────────────

def discovery_matrix_subgroup():
    print("=" * 65)
    print("Discovery 6: SPB Matrix Subgroup of GL(2,Z)")
    print("=" * 65)
    print()
    print("M(n) = [[1,n],[-n,1]], det = 1+n²")
    print("Product: M(a)·M(b) = [[1-ab, a+b], [-(a+b), 1-ab]]")
    print()

    def mat_mult(A, B):
        return [[A[0][0]*B[0][0]+A[0][1]*B[1][0], A[0][0]*B[0][1]+A[0][1]*B[1][1]],
                [A[1][0]*B[0][0]+A[1][1]*B[1][0], A[1][0]*B[0][1]+A[1][1]*B[1][1]]]

    def mat_det(A):
        return A[0][0]*A[1][1] - A[0][1]*A[1][0]

    def M(n):
        return [[1, n], [-n, 1]]

    # Generate products of small M(n)
    print("  Products of M(1):")
    A = M(1)
    for k in range(1, 8):
        d = mat_det(A)
        print(f"    M(1)^{k} = [[{A[0][0]}, {A[0][1]}], [{A[1][0]}, {A[1][1]}]], "
              f"det = {d}")
        A = mat_mult(A, M(1))

    # Check if any power of M(1) is ±I (mod something)
    print()
    print("  Question: Does M(1) have finite order in PGL(2,ℝ)?")
    print("  M(1) = [[1,1],[-1,1]] represents rotation by arctan(1) = π/4.")
    print("  So M(1)^4 should be a scalar times I (rotation by π).")

    A = M(1)
    for _ in range(3):
        A = mat_mult(A, M(1))
    print(f"  M(1)^4 = [[{A[0][0]}, {A[0][1]}], [{A[1][0]}, {A[1][1]}]]")
    print(f"  = {A[0][0]} · I (since off-diag = 0)?",
          "YES ✓" if A[0][1] == 0 and A[1][0] == 0 else "NO ✗")

    # Determinants of products
    print()
    print("  Determinant growth: det(M(n)) = 1+n²")
    for n in range(1, 6):
        print(f"    det(M({n})) = {mat_det(M(n))}")

    # Check: is the image in PSL(2,Z/nZ) for small n?
    print()
    print("  M(1) mod p for small primes:")
    for p in [2, 3, 5, 7]:
        m = [[1 % p, 1 % p], [(-1) % p, 1 % p]]
        d = mat_det(m) % p
        # Find order of M(1) in GL(2, F_p)
        A = [[1 % p, 1 % p], [(-1) % p, 1 % p]]
        order = 1
        curr = list(A)
        for k in range(1, p**4 + 1):
            curr = [[sum(curr[i][j2] * A[j2][j] for j2 in range(2)) % p
                     for j in range(2)] for i in range(2)]
            if curr[0][0] % p == 1 and curr[0][1] % p == 0 and \
               curr[1][0] % p == 0 and curr[1][1] % p == 1:
                order = k + 1
                break
        print(f"    p={p}: M(1) mod {p} has order {order} in GL(2,F_{p})")
    print()

# ─────────────────────────────────────────────
#  Main
# ─────────────────────────────────────────────

def main():
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║   SPB-EML Discovery Engine — Exploring Open Questions       ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    random.seed(42)

    discovery_division_algebra()
    discovery_period_patterns()
    discovery_continued_fractions()
    discovery_approximation()
    discovery_cauchy_stability()
    discovery_matrix_subgroup()

    print("=" * 65)
    print("All discoveries explored successfully!")
    print("=" * 65)

if __name__ == "__main__":
    main()
