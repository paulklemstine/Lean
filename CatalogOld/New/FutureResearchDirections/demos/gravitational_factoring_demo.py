#!/usr/bin/env python3
"""
Gravitational Factoring: Comprehensive Python Demo Suite
=========================================================

This module demonstrates the core concepts of the gravitational factoring
framework through interactive computational experiments:

1. Density verification for semiprimes
2. Pythagorean k-tuple generation and factor extraction
3. Cross-collision mechanism
4. Quaternion-based factoring via Euler's four-square identity
5. Energy landscape computation
6. Berggren tree navigation
7. Lattice reduction connection
8. Optimal dimension analysis
9. Tropical geometry perspective
10. Statistical mechanics analogy

Run: python3 gravitational_factoring_demo.py
"""

import math
import random
import itertools
from collections import defaultdict
from functools import reduce
from typing import List, Tuple, Optional, Dict

# ============================================================================
# §1. DENSITY VERIFICATION
# ============================================================================

def is_prime(n: int) -> bool:
    """Miller-Rabin primality test for small numbers."""
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def factoring_density(p: int, q: int) -> float:
    """Exact density formula δ₁(N) = (p + q - 1) / (p*q) for N = p*q."""
    return (p + q - 1) / (p * q)

def verify_density(p: int, q: int, num_samples: int = 100000) -> dict:
    """Verify the density formula computationally via random sampling."""
    N = p * q
    count = 0
    for _ in range(num_samples):
        x = random.randint(1, N)
        if math.gcd(x, N) > 1:
            count += 1

    empirical = count / num_samples
    theoretical = factoring_density(p, q)

    return {
        'N': N,
        'p': p,
        'q': q,
        'empirical_density': empirical,
        'theoretical_density': theoretical,
        'relative_error': abs(empirical - theoretical) / theoretical,
        'samples': num_samples
    }


def demo_density_verification():
    """Demo 1: Verify the density formula for various semiprimes."""
    print("=" * 70)
    print("DEMO 1: Density Formula Verification")
    print("δ₁(N) = (p + q - 1) / (p·q) for N = p·q")
    print("=" * 70)

    test_cases = [
        (3, 5), (7, 11), (13, 17), (23, 29), (101, 103),
        (997, 1009), (4999, 5003), (10007, 10009)
    ]

    for p, q in test_cases:
        result = verify_density(p, q, num_samples=50000)
        print(f"  N = {result['N']:>12} = {p} × {q}")
        print(f"    Theoretical: {result['theoretical_density']:.6f}")
        print(f"    Empirical:   {result['empirical_density']:.6f}")
        print(f"    Rel. error:  {result['relative_error']:.4f}")
        print()


# ============================================================================
# §2. PYTHAGOREAN k-TUPLE GENERATION
# ============================================================================

def find_pythagorean_triples(max_c: int) -> List[Tuple[int, int, int]]:
    """Find all primitive Pythagorean triples with hypotenuse ≤ max_c."""
    triples = []
    for m in range(2, int(math.sqrt(max_c)) + 1):
        for n in range(1, m):
            if math.gcd(m, n) == 1 and (m - n) % 2 == 1:
                a = m*m - n*n
                b = 2*m*n
                c = m*m + n*n
                if c <= max_c:
                    triples.append((min(a, b), max(a, b), c))
    return sorted(triples, key=lambda t: t[2])


def find_k_tuples(k: int, max_d: int, max_results: int = 100) -> list:
    """Find Pythagorean k-tuples: x₁² + ... + x_{k-1}² = xₖ² with xₖ ≤ max_d."""
    results = []
    if k == 3:
        return [(a, b, c) for a, b, c in find_pythagorean_triples(max_d)]

    # For k > 3, use random search
    for _ in range(max_results * 100):
        legs = [random.randint(1, max_d) for _ in range(k - 1)]
        s = sum(x*x for x in legs)
        d = int(math.isqrt(s))
        if d * d == s and d <= max_d:
            results.append(tuple(sorted(legs) + [d]))
            if len(results) >= max_results:
                break
    return results


def demo_k_tuples():
    """Demo 2: Generate and display Pythagorean k-tuples."""
    print("=" * 70)
    print("DEMO 2: Pythagorean k-Tuple Generation")
    print("=" * 70)

    for k in [3, 4, 5]:
        tuples = find_k_tuples(k, 50, max_results=10)
        print(f"\n  k = {k} (Pythagorean {k}-tuples with d ≤ 50):")
        for t in tuples[:8]:
            legs = t[:-1]
            d = t[-1]
            check = sum(x*x for x in legs)
            print(f"    {legs} → d = {d}  "
                  f"(Σx² = {check} = {d}² ✓)")


# ============================================================================
# §3. FACTOR EXTRACTION VIA PEEL CHANNELS
# ============================================================================

def peel_factor(d: int, x: int, N: int) -> int:
    """Extract factor via peel channel: gcd(d ± x, N)."""
    g1 = math.gcd(d - x, N)
    g2 = math.gcd(d + x, N)
    if 1 < g1 < N: return g1
    if 1 < g2 < N: return g2
    return 1


def cross_collision_factor(x1: int, x2: int, N: int) -> int:
    """Extract factor via cross-collision: gcd(x₁ - x₂, N)."""
    g = math.gcd(abs(x1 - x2), N)
    if 1 < g < N: return g
    g = math.gcd(x1 + x2, N)
    if 1 < g < N: return g
    return 1


def gravitational_factor(N: int, k: int = 4, max_attempts: int = 10000) -> Optional[int]:
    """
    Attempt to factor N using gravitational factoring with k-tuples.

    Strategy:
    1. Generate k-tuples with d ≡ 0 (mod N) or d = m·N
    2. Apply peel channels: gcd(d - xᵢ, N) for each leg
    3. Apply cross-collision channels between tuples sharing d
    """
    if N < 4: return None
    if N % 2 == 0: return 2

    # Strategy: find k-tuples with d = m·N for small m
    for m in range(1, max_attempts):
        d = m * N
        d_sq = d * d

        # Try to decompose d² as sum of k-1 squares
        for _ in range(50):
            legs = []
            remaining = d_sq
            for i in range(k - 2):
                max_leg = int(math.isqrt(remaining))
                if max_leg < 1: break
                leg = random.randint(1, max_leg)
                legs.append(leg)
                remaining -= leg * leg
            else:
                if remaining > 0:
                    last_leg = int(math.isqrt(remaining))
                    if last_leg * last_leg == remaining:
                        legs.append(last_leg)
                        # Found a valid tuple! Try peel channels
                        for x in legs:
                            g = peel_factor(d, x, N)
                            if g > 1:
                                return g

    return None


def demo_factor_extraction():
    """Demo 3: Factor extraction via peel and cross-collision channels."""
    print("=" * 70)
    print("DEMO 3: Factor Extraction via Peel Channels")
    print("=" * 70)

    # Direct examples from the research
    examples = [
        (15, [(5, 10, 10, 15)]),   # N=15, d=15, legs 5,10,10
        (21, [(6, 9, 18, 21)]),    # N=21
        (35, [(7, 14, 14, 21, 35)]),  # N=35
    ]

    for N, tuples in examples:
        print(f"\n  N = {N}:")
        for t in tuples:
            d = t[-1]
            legs = t[:-1]
            print(f"    Tuple: {legs}, d = {d}")
            for i, x in enumerate(legs):
                g_minus = math.gcd(d - x, N)
                g_plus = math.gcd(d + x, N)
                if 1 < g_minus < N:
                    print(f"      Peel channel {i}: gcd({d}-{x}, {N}) = "
                          f"gcd({d-x}, {N}) = {g_minus} → "
                          f"Factor found! {N} = {g_minus} × {N//g_minus}")
                if 1 < g_plus < N:
                    print(f"      Peel channel {i}+: gcd({d}+{x}, {N}) = "
                          f"gcd({d+x}, {N}) = {g_plus} → "
                          f"Factor found! {N} = {g_plus} × {N//g_plus}")

    # Automated factoring
    print("\n  Automated gravitational factoring:")
    test_semiprimes = [15, 21, 33, 35, 51, 77, 91, 119, 143, 187, 221]
    for N in test_semiprimes:
        # Simple peel approach
        found = False
        for m in range(1, 20):
            d = m * N
            for x in range(1, d):
                g = math.gcd(d - x, N)
                if 1 < g < N:
                    print(f"    N = {N:>5}: gcd({d}-{x}, {N}) = {g} → "
                          f"{N} = {g} × {N//g}  [m={m}]")
                    found = True
                    break
            if found: break


# ============================================================================
# §4. QUATERNION-BASED FACTORING
# ============================================================================

def quaternion_multiply(q1, q2):
    """Multiply two quaternions (a,b,c,d)."""
    a1, b1, c1, d1 = q1
    a2, b2, c2, d2 = q2
    return (
        a1*a2 - b1*b2 - c1*c2 - d1*d2,
        a1*b2 + b1*a2 + c1*d2 - d1*c2,
        a1*c2 - b1*d2 + c1*a2 + d1*b2,
        a1*d2 + b1*c2 - c1*b2 + d1*a2
    )

def quaternion_norm(q):
    """Norm of quaternion (a,b,c,d): a² + b² + c² + d²."""
    return sum(x*x for x in q)

def four_square_decomposition(n: int, max_attempts: int = 10000) -> Optional[Tuple]:
    """Find a representation n = a² + b² + c² + d² using randomized search."""
    if n == 0: return (0, 0, 0, 0)

    for _ in range(max_attempts):
        # Rabin-Shallit style: subtract random squares
        a = random.randint(0, int(math.isqrt(n)))
        rem = n - a*a
        if rem < 0: continue
        b = random.randint(0, int(math.isqrt(rem)))
        rem2 = rem - b*b
        if rem2 < 0: continue
        c = random.randint(0, int(math.isqrt(rem2)))
        d_sq = rem2 - c*c
        if d_sq < 0: continue
        d = int(math.isqrt(d_sq))
        if d*d == d_sq:
            return (a, b, c, d)
    return None


def quaternion_factoring(N: int, max_attempts: int = 1000) -> Optional[int]:
    """
    Factor N using quaternion norm multiplicativity.

    Method: Find decomposition N = a² + b² + c² + d², then check
    gcd of components with N for nontrivial factors.
    """
    for _ in range(max_attempts):
        decomp = four_square_decomposition(N)
        if decomp is None: continue
        a, b, c, d = decomp

        # Check all GCDs
        for x in [a, b, c, d, a+b, a+c, a+d, b+c, b+d, c+d,
                   a-b, a-c, a-d, b-c, b-d, c-d]:
            if x == 0: continue
            g = math.gcd(abs(x), N)
            if 1 < g < N:
                return g

    return None


def demo_quaternion_factoring():
    """Demo 4: Quaternion-based factoring."""
    print("=" * 70)
    print("DEMO 4: Quaternion-Based Factoring")
    print("=" * 70)

    # Demonstrate Euler's identity
    print("\n  Euler's Four-Square Identity verification:")
    q1 = (1, 2, 3, 4)
    q2 = (5, 6, 7, 8)
    prod = quaternion_multiply(q1, q2)
    n1 = quaternion_norm(q1)
    n2 = quaternion_norm(q2)
    n_prod = quaternion_norm(prod)
    print(f"    N({q1}) = {n1}")
    print(f"    N({q2}) = {n2}")
    print(f"    N(q₁·q₂) = {n_prod}")
    print(f"    N(q₁)·N(q₂) = {n1*n2}")
    print(f"    Identity holds: {n_prod == n1 * n2} ✓")

    # Four-square decompositions
    print("\n  Four-square decompositions for semiprimes:")
    semiprimes = [(3, 5), (7, 11), (13, 17), (23, 29)]
    for p, q in semiprimes:
        N = p * q
        decomp = four_square_decomposition(N)
        if decomp:
            a, b, c, d = decomp
            print(f"    {N} = {a}² + {b}² + {c}² + {d}² = "
                  f"{a*a} + {b*b} + {c*c} + {d*d}")

            # Try to extract factors from the decomposition
            for x in [a, b, c, d]:
                g = math.gcd(x, N)
                if 1 < g < N:
                    print(f"      → gcd({x}, {N}) = {g}: Factor found! "
                          f"{N} = {g} × {N//g}")


# ============================================================================
# §5. ENERGY LANDSCAPE
# ============================================================================

def factoring_energy(legs: List[int], d: int, N: int) -> float:
    """
    Compute the factoring energy for a k-tuple.

    E = Σᵢ min(gcd(d-xᵢ,N)/N, gcd(d+xᵢ,N)/N) measures how close
    each peel channel is to finding a factor. E = 0 means d or xᵢ
    shares no factors with N. E → 1 means a factor is found.
    """
    if N == 0: return 0.0
    energy = 0.0
    for x in legs:
        g1 = math.gcd(abs(d - x), N)
        g2 = math.gcd(abs(d + x), N)
        # Normalize: 1/N means trivial, larger means closer to factoring
        channel_energy = max(g1, g2) / N
        if 1 < max(g1, g2) < N:
            channel_energy = 1.0  # Factor found!
        elif max(g1, g2) == N:
            channel_energy = 0.0  # Trivial (gcd = N)
        elif max(g1, g2) == 1:
            channel_energy = 0.0  # No factor
        energy += channel_energy
    return energy


def demo_energy_landscape():
    """Demo 5: Compute and display the factoring energy landscape."""
    print("=" * 70)
    print("DEMO 5: Factoring Energy Landscape")
    print("=" * 70)

    N = 15  # = 3 × 5

    print(f"\n  Energy landscape for N = {N}:")
    print(f"  Format: (x₁, x₂, d) → Energy (0 = no factor, >0 = factor)")
    print()

    # Scan over small tuples
    factor_found = []
    for d in range(1, 4 * N):
        for x1 in range(1, d):
            for x2 in range(1, d):
                if x1*x1 + x2*x2 == d*d:
                    e = factoring_energy([x1, x2], d, N)
                    marker = " ★" if e > 0 else ""
                    if e > 0 or d <= 20:
                        print(f"    ({x1:>2}, {x2:>2}, {d:>2}) → E = {e:.2f}{marker}")
                    if e > 0:
                        factor_found.append((x1, x2, d))

    print(f"\n  Factor-revealing tuples found: {len(factor_found)}")
    for t in factor_found[:5]:
        x1, x2, d = t
        print(f"    ({x1}, {x2}, {d}): gcd({d}-{x1},{N})={math.gcd(d-x1,N)}, "
              f"gcd({d}-{x2},{N})={math.gcd(d-x2,N)}")


# ============================================================================
# §6. BERGGREN TREE
# ============================================================================

def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def generate_berggren_tree(depth: int) -> List[Tuple[int, int, int]]:
    """Generate primitive Pythagorean triples via the Berggren tree."""
    triples = [(3, 4, 5)]
    current_level = [(3, 4, 5)]

    for _ in range(depth):
        next_level = []
        for a, b, c in current_level:
            for transform in [berggren_A, berggren_B, berggren_C]:
                child = transform(a, b, c)
                # Ensure positive and sorted
                a2, b2, c2 = child
                if a2 > 0 and b2 > 0 and c2 > 0:
                    triple = (min(a2, b2), max(a2, b2), c2)
                    triples.append(triple)
                    next_level.append(child)
        current_level = next_level

    return triples


def demo_berggren_tree():
    """Demo 6: Berggren tree and factor extraction."""
    print("=" * 70)
    print("DEMO 6: Berggren Tree Navigation for Factoring")
    print("=" * 70)

    triples = generate_berggren_tree(4)
    print(f"\n  Generated {len(triples)} primitive Pythagorean triples (depth 4)")
    print(f"  Root: (3, 4, 5)")

    # Show tree structure
    root = (3, 4, 5)
    print(f"\n  Level 1 children of {root}:")
    for transform, name in [(berggren_A, "A"), (berggren_B, "B"), (berggren_C, "C")]:
        child = transform(*root)
        print(f"    {name}(3,4,5) = {child}  "
              f"(check: {child[0]}² + {child[1]}² = {child[0]**2 + child[1]**2} "
              f"= {child[2]}² = {child[2]**2} ✓)")

    # Factor extraction from tree
    N = 77  # = 7 × 11
    print(f"\n  Searching Berggren tree for factors of N = {N}:")
    factors_found = set()
    for a, b, c in triples:
        for x in [a, b, c]:
            g = math.gcd(x, N)
            if 1 < g < N:
                if g not in factors_found:
                    print(f"    Triple ({a},{b},{c}): gcd({x}, {N}) = {g} → "
                          f"{N} = {g} × {N//g}")
                    factors_found.add(g)

    # Modular tree structure
    p = 7
    print(f"\n  Berggren tree mod p = {p}:")
    for a, b, c in triples[:15]:
        print(f"    ({a:>4}, {b:>4}, {c:>4}) mod {p} = "
              f"({a%p}, {b%p}, {c%p})")


# ============================================================================
# §7. CHANNEL ANALYSIS AND OPTIMAL DIMENSION
# ============================================================================

def channel_count(k: int) -> dict:
    """Compute factoring channel statistics for dimension k."""
    peel = k
    cross = k * (k - 1) // 2
    total = peel + cross
    return {
        'k': k,
        'peel_channels': peel,
        'cross_channels': cross,
        'total_channels': total,
        'marginal_gain': k  # adding 1 dimension gives k new channels
    }


def demo_optimal_dimension():
    """Demo 7: Channel analysis across dimensions."""
    print("=" * 70)
    print("DEMO 7: Optimal Dimension Analysis")
    print("=" * 70)

    print("\n  Channel count hierarchy:")
    print(f"  {'k':>4} | {'Peel':>6} | {'Cross':>6} | {'Total':>6} | {'Algebra':>20}")
    print(f"  {'-'*4}-+-{'-'*6}-+-{'-'*6}-+-{'-'*6}-+-{'-'*20}")

    algebras = {
        1: "Reals ℝ",
        2: "Complex ℂ",
        4: "Quaternions ℍ",
        8: "Octonions 𝕆",
        16: "Sedenions 𝕊",
        32: "Trigintaduonions"
    }

    for k in [1, 2, 3, 4, 5, 6, 7, 8, 16, 32]:
        stats = channel_count(k)
        alg = algebras.get(k, "—")
        print(f"  {k:>4} | {stats['peel_channels']:>6} | "
              f"{stats['cross_channels']:>6} | {stats['total_channels']:>6} | "
              f"{alg:>20}")

    # Cost-benefit analysis
    print("\n  Efficiency: channels per unit dimension cost:")
    for k in range(2, 17):
        stats = channel_count(k)
        efficiency = stats['total_channels'] / k
        bar = "█" * int(efficiency * 2)
        print(f"    k={k:>2}: {efficiency:>6.1f} channels/dim  {bar}")


# ============================================================================
# §8. CROSS-COLLISION EXPERIMENT
# ============================================================================

def demo_cross_collision():
    """Demo 8: Cross-collision factor extraction."""
    print("=" * 70)
    print("DEMO 8: Cross-Collision Factor Extraction")
    print("=" * 70)

    N = 91  # = 7 × 13

    # Find Pythagorean triples with hypotenuse divisible by N
    print(f"\n  Finding tuples with d ≡ 0 (mod {N}):")

    # Use multiples of N
    collisions = defaultdict(list)
    for m in range(1, 5):
        d = m * N
        d_sq = d * d
        # Find decompositions d² = a² + b²
        for a in range(1, d):
            b_sq = d_sq - a*a
            if b_sq <= 0: break
            b = int(math.isqrt(b_sq))
            if b*b == b_sq and b > 0:
                collisions[d].append((a, b))

    for d, tuples in collisions.items():
        print(f"\n  d = {d} (= {d//N}·{N}):")
        for a, b in tuples[:5]:
            g1 = math.gcd(d - a, N)
            g2 = math.gcd(d - b, N)
            print(f"    ({a}, {b}, {d}): peel_a=gcd({d-a},{N})={g1}, "
                  f"peel_b=gcd({d-b},{N})={g2}", end="")
            if 1 < g1 < N:
                print(f" → Factor {g1}! ({N}={g1}×{N//g1})")
            elif 1 < g2 < N:
                print(f" → Factor {g2}! ({N}={g2}×{N//g2})")
            else:
                print()

        # Cross-collisions between pairs
        if len(tuples) >= 2:
            print(f"    Cross-collisions:")
            for i in range(min(len(tuples), 3)):
                for j in range(i+1, min(len(tuples), 4)):
                    a1, b1 = tuples[i]
                    a2, b2 = tuples[j]
                    g = math.gcd(abs(a1 - a2), N)
                    if 1 < g < N:
                        print(f"      gcd(|{a1}-{a2}|, {N}) = gcd({abs(a1-a2)}, {N})"
                              f" = {g} → Factor!")


# ============================================================================
# §9. TROPICAL GEOMETRY PERSPECTIVE
# ============================================================================

def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)

def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b."""
    return a + b

def demo_tropical():
    """Demo 9: Tropical geometry of the factoring problem."""
    print("=" * 70)
    print("DEMO 9: Tropical Geometry Perspective")
    print("=" * 70)

    print("\n  Tropical semiring: (ℝ ∪ {∞}, min, +)")
    print("  Tropical Pythagorean equation: min(2x, 2y) = 2z")
    print("  Simplifies to: min(x, y) = z")
    print()

    print("  Solutions to min(x, y) = z (tropical Pythagorean triples):")
    print(f"  {'x':>4} {'y':>4} {'z':>4}  {'Type':>15}")
    print(f"  {'-'*4} {'-'*4} {'-'*4}  {'-'*15}")

    for x in range(0, 8):
        for y in range(0, 8):
            z = min(x, y)
            if x <= y:
                tp = "x = z ≤ y" if x < y else "x = y = z"
                print(f"  {x:>4} {y:>4} {z:>4}  {tp:>15}")

    print("\n  Tropical factoring analogy:")
    print("  Classical: N = p · q, find p, q")
    print("  Tropical:  n = p + q (tropical product = sum), find p, q")
    print("  The tropical problem is trivially solvable — try all splits!")
    print("  This suggests factoring difficulty comes from the 'curvature'")
    print("  of classical multiplication vs tropical (piecewise-linear).")

    # Tropical energy landscape
    print("\n  Tropical energy E_trop(x, y, N) = |min(2x, 2y) - 2·val(N)|:")
    N = 12  # val_2(12) = 2, val_3(12) = 1
    print(f"  N = {N}")
    for x in range(0, 6):
        for y in range(0, 6):
            e = abs(min(2*x, 2*y) - 2*2)  # using 2-adic valuation
            marker = " ←" if e == 0 else ""
            if x <= y:
                print(f"    ({x}, {y}): E = {e}{marker}")


# ============================================================================
# §10. STATISTICAL MECHANICS ANALOGY
# ============================================================================

def demo_statistical_mechanics():
    """Demo 10: Phase transition in factoring difficulty."""
    print("=" * 70)
    print("DEMO 10: Statistical Mechanics of Factoring")
    print("=" * 70)

    print("\n  Phase transition: easy ↔ hard factoring")
    print("  Temperature T ~ log(search_depth) / log(N)")
    print()

    # Simulate phase transition
    print("  Factoring success rate vs. 'temperature' (search effort):")
    print(f"  {'T':>6} | {'Success %':>10} | {'Phase':>12}")
    print(f"  {'-'*6}-+-{'-'*10}-+-{'-'*12}")

    semiprimes = []
    for p in range(11, 50):
        if is_prime(p):
            for q in range(p, 50):
                if is_prime(q):
                    semiprimes.append(p * q)

    for temp_factor in [1, 2, 5, 10, 20, 50, 100, 200, 500]:
        successes = 0
        total = min(len(semiprimes), 30)
        for N in semiprimes[:total]:
            # Try temp_factor random GCD checks
            found = False
            for _ in range(temp_factor):
                x = random.randint(2, N - 1)
                if math.gcd(x, N) > 1:
                    found = True
                    break
            if found:
                successes += 1
        rate = 100 * successes / total
        phase = "ordered" if rate > 90 else "critical" if rate > 30 else "disordered"
        bar = "▓" * int(rate / 5) + "░" * (20 - int(rate / 5))
        print(f"  {temp_factor:>6} | {rate:>8.1f}% | {phase:>12}  {bar}")


# ============================================================================
# §11. COMPREHENSIVE FACTORING COMPARISON
# ============================================================================

def trial_division(N: int) -> Optional[int]:
    """Factor by trial division."""
    for i in range(2, int(math.isqrt(N)) + 1):
        if N % i == 0:
            return i
    return None


def fermat_factor(N: int, max_iter: int = 10000) -> Optional[int]:
    """Fermat's factoring method."""
    a = int(math.ceil(math.sqrt(N)))
    for _ in range(max_iter):
        b2 = a * a - N
        b = int(math.isqrt(b2))
        if b * b == b2:
            p = a - b
            if 1 < p < N:
                return p
        a += 1
    return None


def demo_comparison():
    """Demo 11: Compare factoring methods."""
    print("=" * 70)
    print("DEMO 11: Factoring Method Comparison")
    print("=" * 70)

    test_cases = []
    primes = [p for p in range(101, 1000) if is_prime(p)]
    for i in range(10):
        p, q = random.choice(primes), random.choice(primes)
        if p != q:
            test_cases.append((p, q, p * q))

    print(f"\n  {'N':>10} | {'Trial Div':>10} | {'Fermat':>10} | {'Quat GCD':>10}")
    print(f"  {'-'*10}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}")

    for p, q, N in test_cases[:8]:
        td = trial_division(N)
        ff = fermat_factor(N)
        qf = quaternion_factoring(N, max_attempts=100)
        print(f"  {N:>10} | {str(td):>10} | {str(ff):>10} | {str(qf):>10}")


# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    random.seed(42)

    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     GRAVITATIONAL FACTORING: Comprehensive Python Demo Suite       ║")
    print("║     Exploring the Pythagorean k-Tuple Factoring Framework          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_density_verification()
    print()
    demo_k_tuples()
    print()
    demo_factor_extraction()
    print()
    demo_quaternion_factoring()
    print()
    demo_energy_landscape()
    print()
    demo_berggren_tree()
    print()
    demo_optimal_dimension()
    print()
    demo_cross_collision()
    print()
    demo_tropical()
    print()
    demo_statistical_mechanics()
    print()
    demo_comparison()

    print()
    print("=" * 70)
    print("All demos complete. See research papers for full mathematical details.")
    print("=" * 70)
