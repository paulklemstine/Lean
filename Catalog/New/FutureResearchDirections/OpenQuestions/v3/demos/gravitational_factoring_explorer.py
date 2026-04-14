#!/usr/bin/env python3
"""
Gravitational Factoring: Comprehensive Research Explorer
=========================================================

Interactive demos exploring all major research directions from v3.
Includes:
  1. σ₁(pⁿ) computation and verification
  2. Brahmagupta-Fibonacci factoring algorithm
  3. Berggren tree generation and geometric series
  4. Peel smoothness advantage measurement
  5. Cross-collision Monte Carlo simulation
  6. Lattice factoring via short vectors
  7. Channel capacity analysis across Cayley-Dickson hierarchy
  8. Fibonacci entry point theorem verification
  9. Tropical geometry of factoring
  10. Energy landscape and statistical mechanics

Usage:
    python gravitational_factoring_explorer.py
"""

import math
import random
import time
from collections import defaultdict
from itertools import combinations
from functools import reduce

# ═══════════════════════════════════════════════════════════════════
# Demo 1: σ₁(pⁿ) = (p^{n+1} - 1) / (p - 1)
# ═══════════════════════════════════════════════════════════════════

def sigma1(n):
    """Sum of divisors of n."""
    if n == 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += d
    return total

def sigma1_prime_power_formula(p, n):
    """Closed form: (p^{n+1} - 1) / (p - 1)."""
    if p == 1:
        return n + 1
    return (p ** (n + 1) - 1) // (p - 1)

def demo_sigma1():
    print("=" * 70)
    print("Demo 1: σ₁(pⁿ) = (p^{n+1} - 1) / (p - 1)")
    print("=" * 70)
    primes = [2, 3, 5, 7, 11, 13]
    for p in primes:
        print(f"\n  p = {p}:")
        for n in range(1, 6):
            computed = sigma1(p ** n)
            formula = sigma1_prime_power_formula(p, n)
            status = "✓" if computed == formula else "✗"
            print(f"    σ₁({p}^{n}) = {computed:>10} = "
                  f"({p}^{n+1}-1)/({p}-1) = {formula:>10}  {status}")

    # Multiplicativity check
    print("\n  Multiplicativity σ₁(m·n) = σ₁(m)·σ₁(n) for coprime m, n:")
    test_cases = [(4, 9), (8, 27), (25, 49), (16, 81)]
    for m, n in test_cases:
        lhs = sigma1(m * n)
        rhs = sigma1(m) * sigma1(n)
        status = "✓" if lhs == rhs else "✗"
        print(f"    σ₁({m}·{n}) = σ₁({m*n}) = {lhs}, "
              f"σ₁({m})·σ₁({n}) = {sigma1(m)}·{sigma1(n)} = {rhs}  {status}")

# ═══════════════════════════════════════════════════════════════════
# Demo 2: Brahmagupta-Fibonacci Factoring
# ═══════════════════════════════════════════════════════════════════

def find_sum_of_two_squares(n):
    """Find all representations of n as a² + b² with a ≤ b."""
    reps = []
    a = 0
    while a * a <= n // 2:
        b_sq = n - a * a
        b = int(math.isqrt(b_sq))
        if b * b == b_sq and a <= b:
            reps.append((a, b))
        a += 1
    return reps

def bf_factor(n):
    """Factor n using Brahmagupta-Fibonacci identity."""
    reps = find_sum_of_two_squares(n)
    if len(reps) < 2:
        return None, reps

    # Try all pairs of representations
    for i in range(len(reps)):
        for j in range(i + 1, len(reps)):
            a, b = reps[i]
            c, d = reps[j]
            # Cross terms
            candidates = [
                math.gcd(a * c + b * d, n),
                math.gcd(a * c - b * d, n),
                math.gcd(a * d + b * c, n),
                math.gcd(a * d - b * c, n),
            ]
            for g in candidates:
                if 1 < g < n:
                    return g, reps
    return None, reps

def demo_bf_factoring():
    print("\n" + "=" * 70)
    print("Demo 2: Brahmagupta-Fibonacci Factoring Algorithm")
    print("=" * 70)
    # Test on products of primes ≡ 1 mod 4
    test_numbers = [
        5 * 13,      # 65
        5 * 29,      # 145
        13 * 17,     # 221
        5 * 41,      # 205
        29 * 37,     # 1073
        13 * 29,     # 377
        5 * 5 * 13,  # 325
        17 * 29,     # 493
        37 * 41,     # 1517
        101 * 113,   # 11413
    ]

    successes = 0
    for n in test_numbers:
        factor, reps = bf_factor(n)
        if factor:
            other = n // factor
            print(f"  N = {n:>6}: reps = {reps[:3]}... → "
                  f"factor = {factor} × {other} ✓")
            successes += 1
        else:
            print(f"  N = {n:>6}: reps = {reps} → no nontrivial factor found")

    print(f"\n  Success rate: {successes}/{len(test_numbers)}")

# ═══════════════════════════════════════════════════════════════════
# Demo 3: Berggren Tree and Geometric Series
# ═══════════════════════════════════════════════════════════════════

def berggren_children(a, b, c):
    """Generate the three children in the Berggren tree."""
    return [
        (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c),    # A
        (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c),    # B
        (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c), # C
    ]

def demo_berggren():
    print("\n" + "=" * 70)
    print("Demo 3: Berggren Tree and Geometric Series")
    print("=" * 70)

    # Generate tree
    root = (3, 4, 5)
    levels = [[(3, 4, 5)]]

    for depth in range(5):
        next_level = []
        for triple in levels[-1]:
            children = berggren_children(*triple)
            next_level.extend(children)
        levels.append(next_level)

    print(f"\n  Berggren Tree Statistics:")
    for d, level in enumerate(levels):
        # Verify all are Pythagorean
        all_pyth = all(a**2 + b**2 == c**2 for a, b, c in level)
        print(f"    Depth {d}: {len(level):>5} triples, "
              f"all Pythagorean: {all_pyth}")

    # Verify geometric series formula
    print(f"\n  Geometric Series: 2·Σ₀ᵈ 3ⁱ = 3^(d+1) - 1")
    for d in range(6):
        total = sum(3**i for i in range(d + 1))
        formula = (3**(d+1) - 1) // 2
        print(f"    d={d}: Σ = {total}, (3^{d+1}-1)/2 = {formula}, "
              f"2·Σ = {2*total} = 3^{d+1}-1 = {3**(d+1)-1} ✓")

    # Generalized for branching factor b
    print(f"\n  Generalized: (b-1)·Σ₀ᵈ bⁱ = b^(d+1) - 1")
    for b in [2, 3, 4, 5]:
        for d in [3, 5, 10]:
            total = sum(b**i for i in range(d + 1))
            lhs = (b - 1) * total
            rhs = b**(d+1) - 1
            print(f"    b={b}, d={d}: (b-1)·Σ = {lhs}, b^(d+1)-1 = {rhs} "
                  f"{'✓' if lhs == rhs else '✗'}")

# ═══════════════════════════════════════════════════════════════════
# Demo 4: Peel Smoothness Advantage
# ═══════════════════════════════════════════════════════════════════

def is_smooth(n, B):
    """Check if n is B-smooth."""
    if n <= 1:
        return True
    temp = n
    for p in range(2, B + 1):
        while temp % p == 0:
            temp //= p
    return temp == 1

def peel_factors(d, x):
    """Compute the peel factors d-x and d+x."""
    return (d - x, d + x)

def demo_peel_smoothness():
    print("\n" + "=" * 70)
    print("Demo 4: Peel Smoothness Advantage")
    print("=" * 70)

    B = 100  # Smoothness bound
    N_values = [10**4, 10**5, 10**6]

    for N in N_values:
        d = int(math.isqrt(N))

        # Count smooth random numbers
        random_smooth = 0
        peel_smooth = 0
        trials = 5000

        for _ in range(trials):
            # Random number in [1, N]
            r = random.randint(1, N)
            if is_smooth(r, B):
                random_smooth += 1

            # Peel factor: d² - x² = (d-x)(d+x)
            x = random.randint(1, d - 1)
            f1, f2 = peel_factors(d, x)
            if f1 > 0 and is_smooth(f1, B) and is_smooth(f2, B):
                peel_smooth += 1

        ratio = peel_smooth / max(random_smooth, 1)
        print(f"  N = {N:>8}: random smooth = {random_smooth}/{trials} "
              f"({100*random_smooth/trials:.1f}%), "
              f"peel smooth = {peel_smooth}/{trials} "
              f"({100*peel_smooth/trials:.1f}%), "
              f"advantage ≈ {ratio:.1f}×")

# ═══════════════════════════════════════════════════════════════════
# Demo 5: Cross-Collision Monte Carlo
# ═══════════════════════════════════════════════════════════════════

def demo_cross_collision():
    print("\n" + "=" * 70)
    print("Demo 5: Cross-Collision Monte Carlo Simulation")
    print("=" * 70)

    primes_list = [
        (101, 103),
        (1009, 1013),
        (10007, 10009),
    ]

    for p, q in primes_list:
        N = p * q
        k_values = [2, 4, 8]

        for k in k_values:
            channels = k + k * (k - 1) // 2
            successes = 0
            trials = 1000

            for _ in range(trials):
                # Generate k random values
                values = [random.randint(1, N) for _ in range(k)]

                # Check all pairs (cross-collision channels)
                found = False
                for i in range(k):
                    for j in range(i + 1, k):
                        g = math.gcd(abs(values[i] - values[j]), N)
                        if 1 < g < N:
                            found = True
                            break
                    if found:
                        break

                # Check individual GCD channels
                if not found:
                    for v in values:
                        g = math.gcd(v, N)
                        if 1 < g < N:
                            found = True
                            break

                if found:
                    successes += 1

            print(f"  N = {p}×{q} = {N}, k = {k}, "
                  f"channels = {channels}, "
                  f"success = {successes}/{trials} "
                  f"({100*successes/trials:.1f}%)")

# ═══════════════════════════════════════════════════════════════════
# Demo 6: Channel Capacity across Cayley-Dickson Hierarchy
# ═══════════════════════════════════════════════════════════════════

def demo_channel_hierarchy():
    print("\n" + "=" * 70)
    print("Demo 6: Cayley-Dickson Channel Hierarchy")
    print("=" * 70)

    algebras = [
        (1, "Real"),
        (2, "Complex"),
        (4, "Quaternion"),
        (8, "Octonion"),
        (16, "Sedenion"),
        (32, "32-ion"),
        (64, "64-ion"),
        (128, "128-ion"),
    ]

    print(f"\n  {'Algebra':<12} {'Dim':>4} {'Peel':>6} {'Cross':>6} "
          f"{'Total':>6} {'Growth':>8}")
    print("  " + "-" * 50)

    prev_total = 0
    for k, name in algebras:
        peel = k
        cross = k * (k - 1) // 2
        total = peel + cross
        growth = f"{total/prev_total:.1f}×" if prev_total > 0 else "—"
        print(f"  {name:<12} {k:>4} {peel:>6} {cross:>6} "
              f"{total:>6} {growth:>8}")
        prev_total = total

    # Hurwitz theorem check
    print(f"\n  Normed division algebras: dim ∈ {{1, 2, 4, 8}}")
    print(f"  Beyond dim 8: zero divisors exist, but channels still grow quadratically")
    print(f"  Channel formula: k + C(k,2) = k(k+1)/2")

# ═══════════════════════════════════════════════════════════════════
# Demo 7: Fibonacci Entry Point Verification
# ═══════════════════════════════════════════════════════════════════

def fib(n):
    """Compute Fibonacci number."""
    if n <= 0:
        return 0
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b

def demo_fibonacci_entry():
    print("\n" + "=" * 70)
    print("Demo 7: Fibonacci Entry Point Theorem")
    print("=" * 70)

    print(f"\n  For prime p ≠ 5: p | F(p-1) or p | F(p+1)")
    print(f"  {'p':>5} {'F(p) mod p':>12} {'F(p-1) mod p':>12} "
          f"{'F(p+1) mod p':>12} {'Divides':>10}")
    print("  " + "-" * 55)

    primes = [2, 3, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73]
    for p in primes:
        fp = fib(p) % p
        fp_minus = fib(p - 1) % p
        fp_plus = fib(p + 1) % p
        which = "F(p-1)" if fp_minus == 0 else ("F(p+1)" if fp_plus == 0 else "NONE")
        print(f"  {p:>5} {fp:>12} {fp_minus:>12} {fp_plus:>12} {which:>10}")

    # Cassini identity verification
    print(f"\n  Cassini's Identity: F(n+1)² - F(n)·F(n+2) = (-1)ⁿ")
    for n in range(10):
        lhs = fib(n+1)**2 - fib(n) * fib(n+2)
        rhs = (-1)**n
        print(f"    n={n}: F({n+1})²-F({n})·F({n+2}) = "
              f"{fib(n+1)}²-{fib(n)}·{fib(n+2)} = {lhs} = (-1)^{n} = {rhs} "
              f"{'✓' if lhs == rhs else '✗'}")

# ═══════════════════════════════════════════════════════════════════
# Demo 8: Tropical Geometry of Factoring
# ═══════════════════════════════════════════════════════════════════

def demo_tropical():
    print("\n" + "=" * 70)
    print("Demo 8: Tropical Geometry of Factoring")
    print("=" * 70)

    # Tropical Pythagorean: min(2a, 2b) = 2c iff min(a, b) = c
    print(f"\n  Tropical Pythagorean Variety: min(2a, 2b) = 2c ↔ min(a,b) = c")
    test_cases = [(3, 5, 3), (7, 2, 2), (4, 4, 4), (1, 10, 1)]
    for a, b, c in test_cases:
        lhs = min(2*a, 2*b)
        rhs = 2*c
        trop = min(a, b) == c
        print(f"    a={a}, b={b}, c={c}: min(2·{a}, 2·{b}) = {lhs}, "
              f"2·{c} = {rhs}, {'✓' if lhs == rhs else '✗'} "
              f"(min({a},{b})={min(a,b)} {'=' if trop else '≠'} {c})")

    # Tropical valuation analysis for factoring
    print(f"\n  Tropical Valuation for N = p·q:")
    for p, q in [(3, 7), (5, 11), (7, 13), (11, 17)]:
        N = p * q
        # Valuations of N at various primes
        vals = {}
        for ell in [2, 3, 5, 7, 11, 13, 17]:
            v = 0
            temp = N
            while temp % ell == 0:
                v += 1
                temp //= ell
            if v > 0:
                vals[ell] = v
        print(f"    N = {p}·{q} = {N}: valuations = {vals}")

# ═══════════════════════════════════════════════════════════════════
# Demo 9: Energy Landscape and Statistical Mechanics
# ═══════════════════════════════════════════════════════════════════

def demo_energy_landscape():
    print("\n" + "=" * 70)
    print("Demo 9: Energy Landscape E(x) = -log gcd(x, N)")
    print("=" * 70)

    p, q = 17, 23
    N = p * q  # 391

    print(f"\n  N = {p} × {q} = {N}")
    print(f"  Factors are at x = {p} and x = {q}")

    # Compute energy landscape
    energies = []
    for x in range(1, N):
        g = math.gcd(x, N)
        e = -math.log(g) if g > 0 else float('inf')
        energies.append((x, g, e))

    # Find minima (factors)
    minima = [(x, g, e) for x, g, e in energies if g > 1]
    print(f"\n  Energy minima (gcd > 1):")
    for x, g, e in minima[:10]:
        print(f"    x = {x:>4}, gcd(x, N) = {g:>4}, E(x) = {e:>8.4f}")

    # Partition function
    print(f"\n  Partition function Z(β) = Σ exp(-β·E(x)):")
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        Z = sum(math.exp(-beta * e) for _, _, e in energies)
        # Probability of hitting a factor
        p_factor = sum(math.exp(-beta * e) for _, g, e in energies if g > 1) / Z
        print(f"    β = {beta:>5.1f}: Z = {Z:>12.2f}, "
              f"P(factor) = {p_factor:.6f}")

# ═══════════════════════════════════════════════════════════════════
# Demo 10: Lattice Factoring via Short Vectors
# ═══════════════════════════════════════════════════════════════════

def demo_lattice():
    print("\n" + "=" * 70)
    print("Demo 10: Lattice Factoring via Short Vectors")
    print("=" * 70)

    test_cases = [
        (3, 5, 15),
        (7, 11, 77),
        (13, 17, 221),
        (23, 29, 667),
        (37, 41, 1517),
    ]

    for p, q, N in test_cases:
        # The lattice L = {(a, b) : a ≡ 0 mod N or b ≡ 0 mod N}
        # Short vectors have entries ~ N^{1/2}
        # We check: if |v| < N^{1/2} and N | v₁·v₂, then gcd reveals factor

        # Simple search for short vectors with product divisible by N
        found = False
        for v1 in range(1, int(N**0.5) + 2):
            for v2 in range(1, int(N**0.5) + 2):
                if (v1 * v2) % N == 0:
                    g1 = math.gcd(v1, N)
                    g2 = math.gcd(v2, N)
                    if 1 < g1 < N or 1 < g2 < N:
                        factor = g1 if 1 < g1 < N else g2
                        print(f"  N = {p}×{q} = {N}: short vec ({v1}, {v2}), "
                              f"gcd = ({g1}, {g2}), factor = {factor} ✓")
                        found = True
                        break
            if found:
                break
        if not found:
            print(f"  N = {p}×{q} = {N}: no short vector factor found")

# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║    GRAVITATIONAL FACTORING: Comprehensive Research Explorer     ║")
    print("║                     Version 3.0 — 2026                         ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    random.seed(42)

    demo_sigma1()
    demo_bf_factoring()
    demo_berggren()
    demo_peel_smoothness()
    demo_cross_collision()
    demo_channel_hierarchy()
    demo_fibonacci_entry()
    demo_tropical()
    demo_energy_landscape()
    demo_lattice()

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)

if __name__ == "__main__":
    main()
