#!/usr/bin/env python3
"""
Spectral Factoring Demo: Eigenspace projections and the ghost map.

Explores:
1. Projection of triplets onto eigenspaces of the ghost map matrix
2. How the factor gap appears in the λ=-1 eigenspace
3. Orbit structure in eigenspace coordinates
4. Visualization of contracting/expanding dynamics
5. Statistical analysis of deficit channel effectiveness

Usage:
    python spectral_factoring.py
"""

import math
from collections import Counter

# ═══════════════════════════════════════════════════════════════
# Ghost Map Core
# ═══════════════════════════════════════════════════════════════

def gp(a, b, c): return a + 2*b - 2*c
def gq(a, b, c): return 2*a + b - 2*c
def gh(a, b, c): return 3*c - 2*(a + b)
def deficit(a, b, c): return a**2 + b**2 - c**2
def trace(a, b, c): return a + b - c

# ═══════════════════════════════════════════════════════════════
# Section 1: Eigenspace Analysis
# ═══════════════════════════════════════════════════════════════

def eigenspace_analysis():
    print("=" * 60)
    print("SECTION 1: Eigenspace Decomposition")
    print("=" * 60)

    # Ghost matrix eigenvalues: -1, 3+2√2, 3-2√2
    lam1 = -1.0
    lam2 = 3 + 2*math.sqrt(2)
    lam3 = 3 - 2*math.sqrt(2)

    print(f"\n  Eigenvalues of G:")
    print(f"    λ₁ = {lam1:.4f}")
    print(f"    λ₂ = {lam2:.4f}  (expanding)")
    print(f"    λ₃ = {lam3:.4f}  (contracting)")

    # Eigenvectors (normalized)
    # λ=-1: (1, -1, 0)/√2
    # λ=3+2√2: (-1, -1, √2)/2
    # λ=3-2√2: (-1, -1, -√2)/2
    s2 = math.sqrt(2)

    print(f"\n  Eigenvectors:")
    print(f"    v₁ = (1, -1, 0)/√2      [factor gap direction]")
    print(f"    v₂ = (-1, -1, √2)/2     [expanding direction]")
    print(f"    v₃ = (-1, -1, -√2)/2    [contracting direction]")

    # Project some interesting triplets
    print(f"\n  Eigenspace projections of divisor triplets:")
    divisor_triplets = [
        (3, 5, 15),
        (7, 11, 77),
        (11, 13, 143),
        (29, 31, 899),
        (43, 47, 2021),
    ]

    for d, e, N in divisor_triplets:
        # Project onto v₁ = (1,-1,0): gives (d-e)/√2
        proj1 = (d - e) / s2
        # Factor gap from projection
        factor_gap = abs(e - d)
        print(f"    ({d},{e},{N}): proj₁ = {proj1:.3f}, "
              f"|factor gap| = {factor_gap}, "
              f"recovered gap = {abs(proj1)*s2:.0f}")

# ═══════════════════════════════════════════════════════════════
# Section 2: Orbit Dynamics in Eigenspace
# ═══════════════════════════════════════════════════════════════

def orbit_dynamics():
    print("\n" + "=" * 60)
    print("SECTION 2: Orbit Dynamics in Eigenspace Coordinates")
    print("=" * 60)

    s2 = math.sqrt(2)
    lam2 = 3 + 2*s2
    lam3 = 3 - 2*s2

    # Track orbit of (7, 11, 77) in eigenspace
    print(f"\n  Orbit of divisor triplet (7, 11, 77):")
    a, b, c = 7, 11, 77
    for step in range(6):
        proj1 = (a - b) / s2
        proj_expand = (-a - b + s2*c) / 2
        proj_contract = (-a - b - s2*c) / 2

        print(f"    Step {step}: ({a},{b},{c})")
        print(f"      Projections: gap={proj1:.2f}  "
              f"expand={proj_expand:.2f}  contract={proj_contract:.2f}")

        a, b, c = gp(a,b,c), gq(a,b,c), gh(a,b,c)

    # Track factoring triplet
    print(f"\n  Orbit of factoring triplet (1, 77, 5930):")
    a, b, c = 1, 77, 1**2 + 77**2
    for step in range(4):
        proj1 = (a - b) / s2
        t = trace(a, b, c)
        d = deficit(a, b, c)

        print(f"    Step {step}: a={a}, b={b}, c={c}")
        print(f"      gap_proj={proj1:.2f}  trace={t}  deficit={d}")

        a, b, c = gp(a,b,c), gq(a,b,c), gh(a,b,c)

# ═══════════════════════════════════════════════════════════════
# Section 3: Deficit Channel Statistical Analysis
# ═══════════════════════════════════════════════════════════════

def deficit_channel_stats():
    print("\n" + "=" * 60)
    print("SECTION 3: Deficit Channel Statistical Analysis")
    print("=" * 60)

    semiprimes = [
        (15, 3, 5), (21, 3, 7), (35, 5, 7),
        (77, 7, 11), (91, 7, 13), (143, 11, 13),
        (221, 13, 17), (323, 17, 19), (437, 19, 23),
        (899, 29, 31), (1517, 37, 41), (2021, 43, 47),
    ]

    print(f"\n  {'N':>6}  {'p×q':>8}  {'deficit hits':>12}  "
          f"{'p-hits':>7}  {'q-hits':>7}  {'first hit':>10}")

    for N, p, q in semiprimes:
        p_hits = 0
        q_hits = 0
        first_hit_x = None
        total_hits = 0

        for x in range(1, min(N, 200)):
            c = x**2 + N**2
            d = deficit(x, N, c)
            g = math.gcd(abs(d), N)
            if g > 1:
                total_hits += 1
                if first_hit_x is None:
                    first_hit_x = x
                if g % p == 0:
                    p_hits += 1
                if g % q == 0:
                    q_hits += 1

        print(f"  {N:>6}  {p}×{q:>3}  {total_hits:>12}  "
              f"{p_hits:>7}  {q_hits:>7}  "
              f"{'x='+str(first_hit_x) if first_hit_x else 'none':>10}")

# ═══════════════════════════════════════════════════════════════
# Section 4: Linear Triplet vs Factoring Triplet
# ═══════════════════════════════════════════════════════════════

def triplet_comparison():
    print("\n" + "=" * 60)
    print("SECTION 4: Triplet Type Comparison")
    print("=" * 60)

    N = 77  # = 7 × 11

    print(f"\n  N = {N} = 7 × 11")
    print(f"\n  --- Linear Triplet (x, N, x+N) ---")
    print(f"  {'x':>4}  {'deficit':>10}  {'gcd(|δ|,N)':>11}  {'trace':>7}")
    for x in range(1, 15):
        d = deficit(x, N, x + N)
        g = math.gcd(abs(d), N)
        t = trace(x, N, x + N)
        marker = " ←" if g > 1 else ""
        print(f"  {x:>4}  {d:>10}  {g:>11}  {t:>7}{marker}")

    print(f"\n  --- Factoring Triplet (x, N, x²+N²) ---")
    print(f"  {'x':>4}  {'deficit':>10}  {'gcd(|δ|,N)':>11}  {'trace':>7}")
    for x in range(1, 15):
        c = x**2 + N**2
        d = deficit(x, N, c)
        g = math.gcd(abs(d), N)
        t = trace(x, N, c)
        marker = " ←" if g > 1 else ""
        print(f"  {x:>4}  {d:>10}  {g:>11}  {t:>7}{marker}")

    print(f"\n  --- Divisor Triplet (d, N/d, N) ---")
    for d in range(1, N+1):
        if N % d == 0:
            e = N // d
            delta = deficit(d, e, N)
            gap = abs(gp(d,e,N) - gq(d,e,N))
            t = trace(d, e, N)
            print(f"  ({d},{e},{N}): deficit={delta}, gap={gap}, trace={t}")

# ═══════════════════════════════════════════════════════════════
# Section 5: Unit Probe Descent vs Factor Structure
# ═══════════════════════════════════════════════════════════════

def unit_probe_analysis():
    print("\n" + "=" * 60)
    print("SECTION 5: Unit Probe Descent Analysis")
    print("=" * 60)

    semiprimes = [(77, 7, 11), (143, 11, 13), (899, 29, 31)]

    for N, p, q in semiprimes:
        print(f"\n  N = {N} = {p} × {q}")
        print(f"  Unit probe descent chain (1, M, M):")
        M = N
        step = 0
        factor_found = False
        while M >= 1:
            gq_val = abs(2 - M)
            g = math.gcd(gq_val, N)
            marker = ""
            if g > 1 and g < N:
                marker = f" ← factor {g} found!"
                factor_found = True
            if step < 15 or marker:
                print(f"    Step {step:>2}: M={M:>4}, |q|={gq_val:>4}, "
                      f"gcd(|q|,N)={g:>3}{marker}")
            M -= 2
            step += 1

        if not factor_found:
            print(f"    No non-trivial factor found via |q|")

        # Check if any |q| value in the chain shares a factor with N
        print(f"  Note: |q| values in chain = N-2, N-4, ..., 1 or 2")
        print(f"  Factor {p} divides |q| = M-2 when M ≡ 2 (mod {p})")
        for M in range(N, 0, -2):
            if (M - 2) % p == 0 and M - 2 > 0:
                print(f"  First hit: M={M}, |q|={M-2}, step={(N-M)//2}")
                break

# ═══════════════════════════════════════════════════════════════
# Section 6: Characteristic Polynomial Verification
# ═══════════════════════════════════════════════════════════════

def char_poly_verify():
    print("\n" + "=" * 60)
    print("SECTION 6: Ghost Matrix Characteristic Polynomial")
    print("=" * 60)

    # char(G) = -(λ³ - 5λ² - 5λ + 1) = -(λ+1)(λ² - 6λ + 1)
    print(f"\n  Characteristic polynomial: (λ+1)(λ² - 6λ + 1) = 0")
    print(f"  Roots: λ₁ = -1, λ₂ = 3+2√2, λ₃ = 3-2√2")

    s2 = math.sqrt(2)
    roots = [-1, 3 + 2*s2, 3 - 2*s2]

    for lam in roots:
        val = lam**3 - 5*lam**2 - 5*lam + 1
        print(f"    p({lam:.4f}) = {val:.10f}")

    # Product of eigenvalues = (-1)(3+2√2)(3-2√2) = (-1)(9-8) = -1 = det(G) ✓
    prod = roots[0] * roots[1] * roots[2]
    print(f"\n  Product of eigenvalues: {prod:.4f} (should be -1 = det(G))")
    # Sum of eigenvalues = -1 + 3+2√2 + 3-2√2 = 5 = tr(G) ✓
    sum_ev = sum(roots)
    print(f"  Sum of eigenvalues: {sum_ev:.4f} (should be 5 = tr(G))")

    # Contracting direction analysis
    print(f"\n  Contracting eigenvalue λ₃ = {roots[2]:.6f}")
    print(f"  After k iterations, contraction = λ₃^k:")
    for k in range(1, 11):
        print(f"    k={k:>2}: λ₃^k = {roots[2]**k:.8f}  "
              f"(factor {1/roots[2]**k:.1f}× magnification)")

# ═══════════════════════════════════════════════════════════════
# Section 7: Comprehensive Factoring Race
# ═══════════════════════════════════════════════════════════════

def factoring_race():
    print("\n" + "=" * 60)
    print("SECTION 7: Comprehensive Factoring Race")
    print("=" * 60)

    semiprimes = [
        (77, 7, 11), (143, 11, 13), (221, 13, 17),
        (323, 17, 19), (437, 19, 23), (667, 23, 29),
        (899, 29, 31), (1147, 31, 37), (1517, 37, 41),
        (2021, 43, 47), (2491, 47, 53), (3127, 53, 59),
    ]

    print(f"\n  {'N':>6}  {'Trial':>6}  {'Ghost':>6}  "
          f"{'Linear':>7}  {'UnitP':>6}  {'Best':>6}  {'Speedup':>8}")

    for N, p, q in semiprimes:
        # Trial division
        trial = 0
        for i in range(2, N):
            trial += 1
            if N % i == 0:
                break

        # Ghost GCD (factoring triplet)
        ghost = N  # worst case
        for x in range(1, N):
            c = x**2 + N**2
            g1 = math.gcd(abs(gp(x, N, c)), N)
            g2 = math.gcd(abs(gq(x, N, c)), N)
            if (1 < g1 < N) or (1 < g2 < N):
                ghost = x
                break

        # Linear triplet deficit
        linear = N
        for x in range(1, N):
            d = deficit(x, N, x + N)
            g = math.gcd(abs(d), N)
            if 1 < g < N:
                linear = x
                break

        # Unit probe
        unit_p = N
        M = N
        step = 0
        while M >= 1:
            gq_v = abs(2 - M)
            g = math.gcd(gq_v, N)
            if 1 < g < N:
                unit_p = step
                break
            M -= 2
            step += 1

        best = min(ghost, linear, unit_p)
        speedup = trial / best if best > 0 else 0

        print(f"  {N:>6}  {trial:>6}  {ghost:>6}  {linear:>7}  "
              f"{unit_p:>6}  {best:>6}  {speedup:>7.1f}×")

# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Spectral Factoring: Eigenspace Analysis of Ghost Map   ║")
    print("╚══════════════════════════════════════════════════════════╝")

    eigenspace_analysis()
    orbit_dynamics()
    deficit_channel_stats()
    triplet_comparison()
    unit_probe_analysis()
    char_poly_verify()
    factoring_race()

    print("\n" + "=" * 60)
    print("All analyses complete.")
    print("=" * 60)
