#!/usr/bin/env python3
"""Spectral Factoring Analysis: Eigenspace decomposition of the Berggren ghost map.

Analyzes the spectral structure of the ghost map G = B₂⁻¹,
demonstrating eigenspace decomposition, orbit dynamics, deficit statistics,
triplet type comparison, unit probe analysis, and comprehensive racing.
"""

import math
from typing import Tuple, List, Optional


# ── Ghost Map ─────────────────────────────────────────────────────────

def ghost(a: int, b: int, c: int) -> Tuple[int, int, int]:
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def deficit(a: int, b: int, c: int) -> int:
    return a*a + b*b - c*c


# ── Section 1: Eigenspace Decomposition ──────────────────────────────

def section_eigenspace():
    """Decompose vectors into eigenspace components."""
    print("=" * 60)
    print("Section 1: Eigenspace Decomposition")
    print("=" * 60)

    sqrt2 = math.sqrt(2)

    # Eigenvalues
    lam1 = -1.0
    lam2 = 3 + 2*sqrt2  # ≈ 5.828
    lam3 = 3 - 2*sqrt2  # ≈ 0.172

    print(f"  Eigenvalues: λ₁ = {lam1:.4f}, λ₂ = {lam2:.4f}, λ₃ = {lam3:.4f}")
    print(f"  Product: {lam1 * lam2 * lam3:.4f} (should be -1 = det G)")
    print(f"  Sum: {lam1 + lam2 + lam3:.4f} (should be 5 = tr G)")

    # Eigenvectors (normalized)
    v1 = [1/sqrt2, -1/sqrt2, 0]  # λ = -1
    v2 = [-1/2, -1/2, 1/sqrt2]   # λ = 3+2√2
    v3 = [-1/2, -1/2, -1/sqrt2]  # λ = 3-2√2

    print(f"\n  Eigenvectors:")
    print(f"    v₁ = ({v1[0]:.4f}, {v1[1]:.4f}, {v1[2]:.4f})")
    print(f"    v₂ = ({v2[0]:.4f}, {v2[1]:.4f}, {v2[2]:.4f})")
    print(f"    v₃ = ({v3[0]:.4f}, {v3[1]:.4f}, {v3[2]:.4f})")

    # Decompose some vectors
    triples = [(3, 4, 5), (5, 12, 13), (3, 5, 15), (7, 11, 77)]
    for a, b, c in triples:
        # Project onto eigenvectors (using dot product)
        c1 = a*v1[0] + b*v1[1] + c*v1[2]
        c2 = a*v2[0] + b*v2[1] + c*v2[2]
        c3 = a*v3[0] + b*v3[1] + c*v3[2]
        print(f"\n  ({a}, {b}, {c}): coefficients c₁={c1:.3f}, c₂={c2:.3f}, c₃={c3:.3f}")
        print(f"    Factor gap direction (c₁): {c1:.3f}  →  |a-b| = {abs(a-b)}")
        print(f"    Expanding (c₂): {c2:.3f}  ×  {lam2:.3f} = {c2*lam2:.3f} per step")
        print(f"    Contracting (c₃): {c3:.3f}  ×  {lam3:.3f} = {c3*lam3:.3f} per step")


# ── Section 2: Orbit Dynamics ─────────────────────────────────────────

def section_orbit_dynamics():
    """Track orbit evolution and eigenspace projections."""
    print("\n" + "=" * 60)
    print("Section 2: Orbit Dynamics")
    print("=" * 60)

    triple = (3, 5, 15)  # Factoring triplet for N=15
    a, b, c = triple
    print(f"\n  Starting triple: ({a}, {b}, {c})  deficit = {deficit(a, b, c)}")

    for step in range(8):
        d = deficit(a, b, c)
        gap = abs(a - b)
        norm = math.sqrt(a*a + b*b + c*c)
        print(f"  G^{step}: ({a:8d}, {b:8d}, {c:8d})  δ={d:8d}  |a-b|={gap:8d}  ‖v‖={norm:.1f}")
        a, b, c = ghost(a, b, c)


# ── Section 3: Deficit Statistics ─────────────────────────────────────

def section_deficit_stats():
    """Analyze deficit values across different triplet types."""
    print("\n" + "=" * 60)
    print("Section 3: Deficit Statistics")
    print("=" * 60)

    # Pythagorean triples have deficit = 0
    pyth = [(3,4,5), (5,12,13), (8,15,17), (7,24,25)]
    print("\n  Pythagorean triples:")
    for a, b, c in pyth:
        print(f"    ({a}, {b}, {c}): δ = {deficit(a, b, c)}")

    # Divisor triplets
    print("\n  Divisor triplets (d, e, de):")
    divisor_pairs = [(2,3), (3,5), (5,7), (7,11), (3,7)]
    for d, e in divisor_pairs:
        N = d * e
        delt = deficit(d, e, N)
        alt = -((d*d - 1) * (e*e - 1)) + 1
        print(f"    ({d}, {e}, {N}): δ = {delt}  = -(({d}²-1)({e}²-1)) + 1 = {alt}")

    # Unit probes
    print("\n  Unit probes (1, N, N):")
    for N in [5, 10, 15, 21, 35, 100]:
        print(f"    (1, {N}, {N}): δ = {deficit(1, N, N)}")

    # Linear triplets
    print("\n  Linear triplets (x, N, x+N):")
    for x, N in [(1,15), (2,15), (3,15), (5,21), (7,35)]:
        print(f"    ({x}, {N}, {x+N}): δ = {deficit(x, N, x+N)} = -2·{x}·{N} = {-2*x*N}")


# ── Section 4: Triplet Type Comparison ────────────────────────────────

def section_triplet_comparison():
    """Compare factoring effectiveness of different triplet types."""
    print("\n" + "=" * 60)
    print("Section 4: Triplet Type Comparison")
    print("=" * 60)

    N = 77  # = 7 × 11

    print(f"\n  Target: N = {N} = 7 × 11")

    # Type 1: Divisor triplet (if we knew factors)
    d, e = 7, 11
    a, b, c = d, e, d*e
    print(f"\n  Divisor triplet ({a}, {b}, {c}):")
    print(f"    deficit = {deficit(a, b, c)}")
    for step in range(3):
        p, q, h = ghost(a, b, c)
        for val, name in [(p, "p"), (q, "q"), (h, "h")]:
            g = math.gcd(abs(val), N)
            if g > 1:
                print(f"    Step {step}: gcd(|{name}|={abs(val)}, N)={g}", "← factor!" if 1 < g < N else "")
        a, b, c = p, q, h

    # Type 2: Linear triplets
    print(f"\n  Linear triplets (x, N, x+N):")
    for x in range(1, 20):
        d = deficit(x, N, x + N)
        g = math.gcd(abs(d), N)
        if 1 < g < N:
            print(f"    x={x}: δ={d}, gcd(|δ|, N)={g} ← factor!")

    # Type 3: Unit probe
    print(f"\n  Unit probe (1, {N}, {N}):")
    a, b, c = 1, N, N
    for step in range(10):
        p, q, h = ghost(a, b, c)
        g = math.gcd(abs(q), N)
        marker = " ← factor!" if 1 < g < N else ""
        print(f"    Step {step}: q={q}, gcd(|q|, N)={g}{marker}")
        a, b, c = p, q, h


# ── Section 5: Unit Probe Analysis ────────────────────────────────────

def section_unit_probe():
    """Deep analysis of unit probe descent chains."""
    print("\n" + "=" * 60)
    print("Section 5: Unit Probe Deep Analysis")
    print("=" * 60)

    for N in [15, 35, 77, 143]:
        print(f"\n  N = {N}:")
        a, b, c = 1, N, N
        factors_found = {}

        for step in range(N // 2 + 5):
            p, q, h = ghost(a, b, c)
            g = math.gcd(abs(q), N)
            if 1 < g < N and g not in factors_found:
                factors_found[g] = step
            if abs(h) <= 2:
                break
            a, b, c = p, q, h

        if factors_found:
            for f, s in sorted(factors_found.items()):
                print(f"    Factor {f} found at step {s} (expected ≈ {N//(2*f)})")
        else:
            print(f"    No proper factors found")


# ── Section 6: Characteristic Polynomial ──────────────────────────────

def section_char_poly():
    """Verify the characteristic polynomial and its factorization."""
    print("\n" + "=" * 60)
    print("Section 6: Characteristic Polynomial")
    print("=" * 60)

    sqrt2 = math.sqrt(2)
    roots = [-1, 3 + 2*sqrt2, 3 - 2*sqrt2]

    print("  Characteristic polynomial: λ³ - 5λ² - 5λ + 1")
    print("  Factored: (λ+1)(λ² - 6λ + 1)")
    print()

    for r in roots:
        val = r**3 - 5*r**2 - 5*r + 1
        print(f"  p({r:.6f}) = {val:.10f}  {'✓' if abs(val) < 1e-8 else '✗'}")

    print(f"\n  Product of roots: {roots[0]*roots[1]*roots[2]:.6f}  (should be -1)")
    print(f"  Sum of roots: {sum(roots):.6f}  (should be 5)")
    print(f"  Sum of products of pairs: {roots[0]*roots[1] + roots[0]*roots[2] + roots[1]*roots[2]:.6f}  (should be -5)")


# ── Section 7: Comprehensive Racing ──────────────────────────────────

def section_racing():
    """Race different factoring methods on a collection of semiprimes."""
    print("\n" + "=" * 60)
    print("Section 7: Factoring Method Race")
    print("=" * 60)

    def is_prime(n):
        if n < 2: return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0: return False
        return True

    primes = [p for p in range(3, 100) if is_prime(p)]

    results = {"trial": 0, "linear": 0, "unit": 0, "diff": 0, "ghost_gcd": 0}
    total = 0

    for i in range(len(primes)):
        for j in range(i+1, len(primes)):
            N = primes[i] * primes[j]
            if N > 5000:
                continue
            total += 1

            # Trial division steps
            for k in range(2, int(N**0.5) + 1):
                if N % k == 0:
                    results["trial"] += 1
                    break

            # Linear triplet
            found = False
            for x in range(1, min(N, 200)):
                g = math.gcd(2*x*N, N)
                if 1 < g < N:
                    results["linear"] += 1
                    found = True
                    break

            # Unit probe
            a, b, c = 1, N, N
            found_u = False
            for step in range(min(N, 200)):
                p, q, h = ghost(a, b, c)
                g = math.gcd(abs(q), N)
                if 1 < g < N:
                    results["unit"] += 1
                    found_u = True
                    break
                a, b, c = p, q, h

            # Diff triplet
            found_d = False
            for x in range(1, N):
                g = math.gcd(2*x*(N-x), N)
                if 1 < g < N:
                    results["diff"] += 1
                    found_d = True
                    break

            # Ghost GCD (from linear triplet orbit)
            found_g = False
            for x in range(1, min(20, N)):
                a, b, c = x, N, x + N
                for step in range(10):
                    p, q, h = ghost(a, b, c)
                    for val in [p, q, h]:
                        g = math.gcd(abs(val), N)
                        if 1 < g < N:
                            results["ghost_gcd"] += 1
                            found_g = True
                            break
                    if found_g: break
                    a, b, c = p, q, h
                if found_g: break

    print(f"\n  {total} semiprimes tested (up to 5000)")
    for method, count in results.items():
        print(f"    {method:12s}: {count}/{total} = {100*count/total:.1f}%")


# ── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Spectral Factoring Analysis                           ║")
    print("║  Eigenspace decomposition of the Berggren ghost map    ║")
    print("╚══════════════════════════════════════════════════════════╝")

    section_eigenspace()
    section_orbit_dynamics()
    section_deficit_stats()
    section_triplet_comparison()
    section_unit_probe()
    section_char_poly()
    section_racing()

    print("\n" + "=" * 60)
    print("Analysis complete!")
    print("=" * 60)
